#!/usr/bin/env python3
from   lxml import etree as ET
from   glob import glob
import os

prjxml='scope_test_v2.xml'

def get_seed(xmlnam):
  etree = ET.parse( xmlnam )
  root=etree.getroot()
  return etree.xpath('efx:place_and_route/efx:param[@name="seed"]/@value', namespaces=root.nsmap)[0]

def print_wns(xmlnam):
  print("Checking {}".format(xmlnam))
  xmldir = os.path.dirname(xmlnam)
  if 0 == len(xmldir):
    xmldir = "."
  etree = ET.parse( glob( xmldir + '/outflow/*route.rpt.xml')[0] )
  root=etree.getroot()
  errs=etree.xpath('/efx:tool_report/efx:group[@name="Timing"]/efx:group_data[@severity="error"]',namespaces=root.nsmap)
  print("SEED {:4s}:".format(get_seed(xmlnam)), end='')
  if ( 0 == len(errs) ):
    print(" OK - Timing passed")
  first = True
  for e in errs:
    if ( not first ):
      print("          ", end='')
      first = True
    print(" ERROR: {} -- {}".format(e.xpath("@name")[0], e.xpath("@value")[0]))

for xmlfeil in glob('**/'+prjxml, recursive=True):
  print_wns(xmlfeil)
