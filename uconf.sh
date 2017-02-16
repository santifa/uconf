#!/bin/sh -
###############################################################################
#
# uconf.sh is a management script for user configurations aka dot files.
# See function usage or `uconf.sh help` for more information.
#
# Copyright 2017 Henrik Jürges
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###############################################################################

# "strict" mode; enable tracing
set -euo pipefail; [ ! -z ${CFG_TRACE:-""} ] && set -x
IFS=$' \t\n'

# secure env
\unalias -a
unset -f command
PATH="$(command -p getconf CS_PATH):$PATH"

# set basics infos and failure method
readonly VERSION="0.7.0"
readonly PROG=$(command -p basename $0)
fail() { echo "$1" && exit 1; }

# check if custom documentation name provided or use default
[ -z ${CFG_DOC:-""} ] && readonly CFG_DOC=Readme.md
# check for configuration root
[ -z ${CFG_HOME:-""} ] && fail "Please set a home directory with export CFG_HOME=<path>"
[ -e ${CFG_HOME} ] || echo "Creating ${CFG_HOME}" && command mkdir -p ${CFG_HOME};

# show the help information
cfg_usage() {
    command -p cat <<EOF
Easy dot file management.
Local files are bundled to a configuration which is stored
in a repository. See more at https://github.com/santifa/uconf

Export configuration variables 
       uconf home: "export CFG_HOME=<path>"
       uconf doc file name with "export CFG_DOC=<filename>"
       uconf vcs cmds "export CFG_VCS_I=git init"
See repository for more examples.

Usage: $PROG <cmd> <cfg> <arguments>

CMD
  help   - Print this help message
  create - create a new configuration for a list of files
  add    - add new files to a configuration
  rm     - remove files from a configuration
  delete - delete an existing configuration
  save   - save file defined in a configuration
  load   - load files from the configuration
  status - show the ".cfg" file
  doc    - opens the doc file for a configuration
  vcs    - use vcs commands after configuration: 
           add, commit, push, pull

Except "help" all other CMDs need a CFG (configuration name).
Current version $VERSION
EOF
    exit $1
}

# create a new configuration if not already present
cfg_create() {
    [ -e ${CFG_SRC} ] && fail "Configuration ${CFG} already present."
    echo "Creating configuration directory ${CFG}:${CFG_SRC}"
    command -p mkdir -p ${CFG_SRC}
    
    echo "files=$@" > "${DOTFILE}"    
    echo "doc=${CFG_DOC}" >> "${DOTFILE}"   
}

# add all non duplicant files to a configuration
cfg_add() {    
    local file=
    for file in ${@}; do
        if ! grep -q "^files=.* ${file} .*" ${DOTFILE}; then
            sed -i "1s#\$# ${file}#" ${DOTFILE}
        fi
    done
    # remove possible whitespaces in front 
    sed -i "1s#^files= *#files=#" ${DOTFILE}
}

# remove all matching files from a configuration
cfg_rm() {
    local file=
    for file in ${@}; do
        sed -i "1s#${file}##" ${DOTFILE}
    done
    # remove possible whitespaces in front 
    sed -i "1s#^files= *#files=#" ${DOTFILE}
}

# store the local files into the configuration folder
cfg_save() {
    local origins=`grep -m 1 "files=" ${DOTFILE} | sed 's/files=//' | sed "s#~/#${HOME}/#g"`
    local file=
    for file in ${origins}; do
        cp -urf ${file} ${CFG_SRC}
    done
    echo "${CFG} saved"
}

# load a stored configuration
cfg_load() {   
    local origins=`grep -m 1 "files=" ${DOTFILE} | sed 's/files=//' | sed "s#~/#${HOME}/#g"`
    local file=
    for file in ${origins}; do
        if [ -d $file ]; then
            # copy directory content back
            local name=$(basename $file)
            cp -rf ${CFG_SRC}/$name/* ${file}
        else
            # load a file to provided path 
            local name=$(basename $file)
            cp -f ${CFG_SRC}/$name "${file}"
        fi      
    done
    echo "${CFG} loaded"
}

# delete an existing configuration
cfg_delete() {
    read -p "Do you wish to delete ${CFG}? [yn] " yn
    case $yn in
        [Yy]* ) rm -rf ${CFG_SRC};;
        * ) echo "Aborting" && exit;;
    esac
}

# add or change documentation
cfg_doc() {
    [ -z ${EDITOR:-""} ] && fail "No \$EDITOR enviroment variable set."
    local doc=`grep -m 1 "doc=" ${DOTFILE} | sed 's/doc=//'`
    ${EDITOR} ${CFG_SRC}/${doc}
}

# show the state of a configuration
cfg_status() { echo "Configuration => ${CFG} : ${CFG_SRC}" && cat ${DOTFILE}; }

cfg_vcs() {
    local vcs_cmd=${1:-}
    cd ${CFG_HOME}
    case $vcs_cmd in
        add)     [ ! -z "${CFG_VCS_A:-}" ] && ${CFG_VCS_A} ${2:-};; # add configuration
        commit)  [ ! -z "${CFG_VCS_A:-}" ] && ${CFG_VCS_C} ${2:-};; # if messages are needed
        push)   ([ ! -z "${CFG_VCS_A:-}" ] && ${CFG_VCS_PUSH}) || fail "Push not possible";;
        pull)   ([ ! -z "${CFG_VCS_A:-}" ] && ${CFG_VCS_PULL}) || fail "Pull not possible";;
        status) ([ ! -z "${CFG_VCS_S:-}" ] && ${CFG_VCS_S}) || fail "Can't get state";;
        *) cfg_usage 1;;
    esac
}

# execute uconf.sh and determine which method is called
cfg_main() {
    # check that we have a command and handle basic ones
    readonly CMD=${1:-}; shift || fail "No command provided."
    [ $CMD = "help" ] && cfg_usage 0
    [ $CMD = "show" ] && command ls -l ${CFG_HOME} && exit 0; # show all configurations

    # handle vcs commands 
    [ $CMD = "vcs" ] && cfg_vcs $@ && exit 0;
    
    # set basic paths
    readonly CFG=${1:-}; shift || fail "No configuration name provided."
    readonly CFG_SRC=${CFG_HOME}/${CFG}
    readonly DOTFILE=${CFG_SRC}/.cfg

    
    # allow only relativ to home or absolute path
    local file=
    local files=()
    local i=0
    for file in $@; do
        files[$i]=`realpath $file | sed "s#^${HOME}#~#"`
        i=$(($i + 1))
    done

    # either we create a new configuration or we need valid paths
    [ $CMD = "create" ] && cfg_create ${files[@]} && exit 0
    [ -e ${CFG_SRC} ] || fail "No such configuration ${CFG}"
    [ -e ${DOTFILE} ] || fail "No dotfile for ${CFG}. Not correctly created?"

    
    case "${CMD}" in
        add)  cfg_add ${files[@]};;
        rm)   cfg_rm ${files[@]};;
        save) cfg_save;;
        load) cfg_load;;
        delete) cfg_delete;;
        status) cfg_status;;
        doc)  cfg_doc;;
        *)    cfg_usage 1;;
    esac
    exit 0
}

cfg_main ${@}
