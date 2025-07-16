#!/bin/bash


RED=$(printf "\033[38;5;197m\n")
RESET=$(tput sgr0 )
GREEN=$(printf "\033[38;5;29m\n")

AMROS_VERSION=$(dpkg -l | grep -P "ros-kinetic-amros\s" | perl -ane 'print "$F[2]\n";')

if [[ ${AMROS_VERSION} == "" ]] ; then
    AMROS_VERSION=$(printf "${RED}Not found${RESET}")
else
    AMROS_VERSION=$(printf "${GREEN}${AMROS_VERSION}${RESET}")
fi

printf "%-20.20s\t\t%s\n\n" "ros-kinetic-amros" "${AMROS_VERSION}"

function rospack_find()
{
    rp=$(rospack find $1 2>/dev/null)
    if [[ $? != 0 ]] ; then
	rp=$(printf "${RED}Not Found${RESET}")
    else
	rp=$(printf "${GREEN}$rp${RESET}")
    fi
    echo -ne "$rp"
}

printf "%-20.20s\t\t%s\n" "CMAKE_PREFIX_PATH"  "${CMAKE_PREFIX_PATH}"
printf "%-20.20s\t\t%s\n" "visbox(pcm)"  "$(rospack_find point_cloud_manager_dbg)"
printf "%-20.20s\t\t%s\n" "ouster_ros"  "$(rospack_find ouster_ros 2>&1)"
printf "%-20.20s\t\t%s\n" "am_utils"  "$(rospack_find am_utils)"
printf "%-20.20s\t\t%s\n" "latency_testing"  "$(rospack_find latency_testing)"
printf "%-20.20s\t\t%s\n" "am_vr(file_server)"  "$(rospack_find file_server)"
printf "%-20.20s\t\t%s\n" "darknet_ros" "$(rospack_find darknet_ros)"
printf "%-20.20s\t\t%s\n" "shm_transport" "$(rospack_find shm_transport)"

