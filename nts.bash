
########################################################%%%%%%%%%%%%%%%%%%%#
                                                       # Table of contents #
########################################################%%%%%%%%%%%%%%%%%%%#

# 0. Overview
# 1. Constant
# 2. Helpers
# 3. Drafting
# 4. Review

########################################################%%%%%%%%%%%%%%%%%%%#
                                                                # Overview #
########################################################%%%%%%%%%%%%%%%%%%%#

# I like to have a consistent note taking system across computers
# I also like that system to be as automated as possible
# Oh and I want it to be totally custom because because

# The three main functions I use are:
#  1. now()
#   * take me to a dated markdown file for me to get started jotting ideas
#  2. temp()
#   * take me to a new, dated folder where I might put multiple things in
#  3. recap()
#   * review recent notes (only from now() for now)

# Future:
# * organization of existing now() and temp() files
#   * I have accumulated many and there is overlap that would make sense
#     to be put together
# * projects
#   * this might be a way to organize the above...
#     but I also want to "define" projects

# Structure of my current ~/notes dir
# * daily
# * temps
# * topics      (a form of organization -- but I create these individually)
# * task_notes  (old notes associated with taskwarrior tasks)

#################################################################%%%%%%%%%%#
                                                                # Constant #
#################################################################%%%%%%%%%%#

if [[ "$NTS_DIR_DAILY" == "" ]]; then
  NTS_DIR_DAILY=~/notes/daily
fi

if [[ "$NTS_DIR_TEMP" == "" ]]; then
  NTS_DIR_TEMP=~/notes/temps
fi

#################################################################%%%%%%%%%%#
                                                                # Helpers  #
#################################################################%%%%%%%%%%#

today() {
  echo $(date "+%Y-%m-%d")
}

#################################################################%%%%%%%%%%#
                                                                # Drafting #
#################################################################%%%%%%%%%%#

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


#################################################################%%%%%%%%%%#
                                                                # Review   #
#################################################################%%%%%%%%%%#

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
