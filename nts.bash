
##########################%%%%%%%%%%%%%%%%%%%#
                         # Table of contents #
##########################%%%%%%%%%%%%%%%%%%%#

# 1. Constant
# 2. Helpers
# 3. Drafting
# 4. Review

###################################%%%%%%%%%%#
                                  # Constant #
###################################%%%%%%%%%%#

if [[ "$NTS_DIR_DAILY" == "" ]]; then
  NTS_DIR_DAILY=~/notes/daily
fi

if [[ "$NTS_DIR_TEMP" == "" ]]; then
  NTS_DIR_TEMP=~/notes/temps
fi

###################################%%%%%%%%%%#
                                  # Helpers  #
###################################%%%%%%%%%%#

today() {
  echo $(date "+%Y-%m-%d")
}

###################################%%%%%%%%%%#
                                  # Drafting #
###################################%%%%%%%%%%#

wnow() {
  echo ${NTS_DIR_DAILY}/$(today).md
}

now() {
  ${EDITOR} $(wnow)
}

temp() {
  local dirname="$1"
  cd ${NTS_DIR_TEMP}
  # Add unique identifier for easy filtering
  base_dirname="$(today)_$(uuidgen | cut -c -8)"
  if [[ "$dirname" != "" ]]; then
    dirname="${base_dirname}_${dirname}" 
  else
    dirname="${base_dirname}" 
  fi

  # go to the directory even if it exists
  mkdir ${dirname}; cd ${dirname}
}

gotemp() {
  local dirname="$(cd ${NTS_DIR_TEMP}; ls -t | fzf)"
  if [[ "$dirname" != "" ]]; then
    cd "${NTS_DIR_TEMP}/${dirname}"
  fi
}


###################################%%%%%%%%%%#
                                  # Review   #
###################################%%%%%%%%%%#

recap() {                
  if [[ $# -gt 0 ]]; then
    num=$1
  else
    num=10
  fi

  ( cd ${NTS_DIR_DAILY}
    (for f in $(ls -vt *.md | head -n ${num}); do
    echo ; echo --- $f ---          # newlines between files
    cat $f                          # print file after metadata
    done)  | tee ~/share/reports/recap.md | $EDITOR -   )
}
