#!/bin/bash
set -e

source ./tools/awscli.sh
source ./tools/cloudsdk.sh
source ./tools/docker.sh
source ./tools/go.sh
source ./tools/python3.sh

install_all=""
install_list=""
available_tools="awscli cloudsdk docker go python3 pip ipython"

display_help() {
  cat << EOF

USAGE: $(basename $0) [OPTIONS] [TOOL...]

COPYRIGHT:  Copyright (c) 2019 Ogun Acik

DESCRIPTION:
  Easy installer for some tools I use on my development workstation.
  Supported platforms : linux/amd64
  Supported distros   : Debian{9,10} Ubuntu{16,18} Centos{7,}
  Available tools     : ${available_tools}

OPTIONS:
  -h - Show this help and exit
  -a - Install all available tools. No argument list required.

EXAMPLES:
  $ sudo ./$(basename $0) go docker cloudsdk
    # Install go, docker and cloudsdk

  $ sudo ./$(basename $0) ansible
    # Install ansible

  $ sudo ./$(basename $0) -a
    # Install all available tools: (${available_tools})

REQUIREMENTS:
  su permission, git, curl

EOF
}

get_distribution() {
  lsb_dist=""

  if [ -r /etc/os-release ]; then
    source /etc/os-release
    id="${ID}"
    version_id=$(echo "${VERSION_ID}" | cut -d "." -f 1)
  fi

  lsb_dist="$(echo "${id}"_"${version_id}" | tr '[:upper:]' '[:lower:]')"
  echo "${lsb_dist}"
}

# Parse and evaluate options
while [[ $# -gt 0 ]]; do
  case "${1}" in
  -h)
    display_help
    exit 0
    ;;
  -a)
    install_all=1
    shift
    break
    ;;
  *)
    break
    ;;
  esac
  shift
done

# Define installation list
if [[ -n "${install_all}" ]]; then
  install_list="${available_tools}"
else
  install_list="${@}"
fi

# Install tool(s)
for pkg in $install_list; do
  cmd="$(get_distribution)"_"${pkg}"
  if c=$(command -v "${cmd}"); then
    echo "${cmd}"
  else
    echo
    echo "ERROR: ${pkg} doesn't exist in available tools."
    echo "Run ./$(basename $0) -h for help." 
    echo
    exit 1
  fi
done
