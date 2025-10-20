#!/usr/bin/env bash

pkgfnam="GitVersionPkg.vhd"
pkgdnam="."

while getopts "hf:d:" opt; do
  case $opt in
    f)
      pkgfnam="$OPTARG"
    ;;
    d) 
      pkgdnam="$OPTARG"
    ;;
    *) echo "Usage: $0 [-h] [-f <output_filename>] [-d <output_dir>]"
       echo " -f <output_filename> (defaults to 'GitVersionPkg.vhd')"
       echo " -d <output_dir>      (defaults to '.')"
       exit 0
    ;;
  esac
done

f="$pkgdnam/$pkgfnam"
ver="00000000"

if git diff-index --quiet HEAD -- ; then
  ver=`git rev-parse --short=8 HEAD`
else
  echo "HEAD seems to be dirty; using version 00000000"
fi

mkdir -p "$pkgdnam"

echo "-- AUTOMATICALLY GENERATED; DO NOT EDIT"                                 >  $f
echo "library ieee;"                                                           >> $f
echo "use ieee.std_logic_1164.all;"                                            >> $f
echo ""                                                                        >> $f
echo "package GitVersionPkg is"                                                >> $f
echo "   constant GIT_VERSION_C : std_logic_vector(31 downto 0) := x\"$ver\";" >> $f
echo "end package GitVersionPkg;"                                              >> $f
