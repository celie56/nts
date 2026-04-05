################################################################################
                                  # Overview #
################################################################################
#
# This system is designed to expose 4 shell functions:
#  1. now
#     open today's daily markdown file
#  
#  2. temp "some note description"
#     take me to a new, dated Atom where I might put multiple things in
#
#  3. tnote 1 # some integer taskwarrior index
#     creates (if needed) and opens the Atom for a task from taskwarrior
#
#  4. recap
#     review recent notes 
#
# The file structure is expected to look like:
# --------------------------------------------
#     notes/
#         daily/
#             20260104.md
#         atoms/
#             20260104_ABCD6789/
#                 README.md
# --------------------------------------------
#
################################################################################
                               # Configuration #
################################################################################

if [[ "$NTS_DIR" == "" ]]; then
  NTS_DIR="${HOME}/notes"
fi

################################################################################
                                   # Daily #
################################################################################
today() { # produces YYYYMMDD like 20260104
  date "+%Y%m%d"
}
wnow() { 
    echo "${NTS_DIR}/daily/$(today).md"
}
now() {
  ${EDITOR} "$(wnow)"
}

################################################################################
                                   # Notes #
################################################################################
create_note() {

    # Gather inputs
    local date="$1" uuid="$2" desc="$3"
    if [[ -z $date || -z $uuid || -z $desc ]]; then
        echo "invalid usage of create_note" >&2
        return 1
    fi

    # Create the atom
    cd "${NTS_DIR}/atoms"
    local dirname="${date}_${uuid}"
    mkdir -p "${dirname}"   # creates the directory if it does not exist
    cd       "${dirname}"
    local note="README.md"

    # Create and add description if the file does not already exist
    if [[ ! -f "${note}" ]]; then
        echo "# ${desc}" > ${note}
    fi

    # Update the daily if the atom is not already present
    grep -Fq -- "${dirname}" "$(wnow)" 2>/dev/null \
        || echo "* [${desc}](../atoms/${dirname}/${note})" >> "$(wnow)"

    $EDITOR "${note}"

}

gen_uuid() { # produces unique id like aBcD1234
    uuidgen | cut -c -8
}
temp() {
    if [[ -z $1 ]]; then
        echo "invalid usage: temp [description]"; return 1;
    fi
    create_note "$(today)" "$(gen_uuid)" "$1"
}

tnote() {
    local task_id="$1"
    local description="$(task ${task_id} info | grep "^Description" | cut -d ' ' -f 2- | sed 's/^[ \t]*//')"
    local uuid="$(task ${task_id} uuids | cut -c -8 )"
    local creation_date="$(task ${task_id} | grep Entered | awk '{print $2}')"
          creation_date="${creation_date//[^0-9]/}"

    create_note "${creation_date}" "${uuid}" "${description}"
}

################################################################################
                                   # Review #
################################################################################

recap() {                
    local num=${1:-50}
    local report="${HOME}/temp.recap.md"

    (   cd "${NTS_DIR}/daily"   # we want relative links to work in vim
        (   for f in $(ls -vt -- *.md | head -n ${num}); do
            echo ; echo "--- $f ---"          # newlines between files
            cat "$f"                          # print file after metadata
            done
        )     > "${report}"
        $EDITOR "${report}"
    )
}
