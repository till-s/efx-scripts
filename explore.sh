#!/usr/bin/env bash

# This is different from the sweeper provided by efinix.
# We want the git-hash to be synthesized into the design.
# Efinix uses multiple PNR runs on the same synthesized
# design which means that the hash cannot be incorporated.
#
# Here we
#  checkout multiple subdirectories
#  create a seed-branch in each subdir
#  commit to the seed-branch
#  run the tool
# Eventually, we have timing reports from the desings
# which do have the git-hash included.

while getopts "hp:s:" opt; do
  case $opt in
    p)
      xmlname="$OPTARG"
    ;;
    s)
      seeds="$OPTARG"
    ;;
    *) echo "Usage: $0 [-h] [-p <project_xml>]   [-s <seeds>]"
       exit 0
    ;;
  esac
done

scriptdir="`dirname $0`"
if [ -z "$xmlname" ]; then
  xmlname=$(${scriptdir}/defaultProject.py)
fi

echo "Using project ${xmlname}"

constraints="`basename ${xmlname} .xml`.pt.sdc"
perixmlname="`basename ${xmlname} .xml`.peri.xml"


submodules=$(git submodule status | awk '{print $2}')

if [[ "$0" =~ ^/.* ]] ; then
  scriptupupdir="${scriptdir}"
  scriptupdir="${scriptdir}"
else
  # find scripts from the subdir where we clone the project
  scriptupupdir="../../${scriptdir}"
  scriptupdir="../${scriptdir}"
fi

mkdir -p explore
pushd explore
for i in ${seeds}; do
    if [ ! -d swipe_${i} ]; then
      git clone ../ swipe_${i}
    fi
    pushd swipe_${i}
    if ! [ -e ${constraints} ] || ! [ -e ${perixmlname} ]; then
      ${scriptupupdir}/generate_project.py
    fi
    for m in ${submodules}; do
      git config --replace-all "submodule.modules/`basename ${m}`.url" "../../${m}"
    done
    git submodule update --init --recursive
    sed -i -e 's/name="seed" *value="[0-9]\+"/name="seed" value="'"${i}"'"/' "${xmlname}"
    git checkout -B "seed_${i}"
    if ! git diff-index --quiet HEAD --; then
      git commit -m "Seed ${i}" ${xmlname}
    fi
    ${scriptupupdir}/update_git_version_pkg.sh
    efx_run ${xmlname} &
    popd
done
wait
${scriptupdir}/extract_wns.py -p ${xmlname}
