#!/usr/bin/env python3
import glob
import re

def getProjectXml():
  # Must be run from the project directory
  projmatch = None
  for xml in glob.glob( '*.xml' ): 
    m = re.match( '^([^.]*)[.]xml$', xml )
    if not m is None:
      if not projmatch is None:
        raise RuntimeError( "project XML not found; too many <xxx.xml> files in this directory" )
      projmatch = m
  if projmatch is None:
    raise RuntimeError("project XML not found; expect to run in the project directory and find one '<proj_name>.xml' file")
  return projmatch.group(0), projmatch.group(1)

if __name__ == "__main__":
  prjxml, prjnam = getProjectXml()
  print(prjxml,end='')
