#!/usr/bin/python
import argparse
import xmlrpclib
from lxml import etree
import re
import sys

def unregister(username, password, server_url, id):
  xmlrpclib.Server(server_url)
  sc = xmlrpclib.Server(server_url)
  sk = sc.auth.login(username, password)
  result = sc.system.deleteSystems(sk,[id])
  return result


def get_system_id():
  root = etree.parse('/etc/sysconfig/rhn/systemid')
  system_id = root.xpath("./param/value/struct/member/name[text()='system_id']/../value/string/text()")[0]
  id = re.search('(?<=ID-)[0-9]+$', system_id).group(0)
  return int(id)

def main():
  parser = argparse.ArgumentParser(description="Unregister the system from Spacewalk Server, Red Hat Satellite or Red Hat Network Classic.")
  parser.add_argument("-u", "--username", dest="username", type=str, required=True,
                      help="The username to register the system with under Spacewalk Server, Red Hat Satellite or Red Hat Network Classic.")
  parser.add_argument("-p", "--password", dest="password", type=str, required=True,
                      help="The password associated with the username specified with the --username option. This is an unencrypted password.")
  parser.add_argument("-s", "--serverurl", dest="server_url", type=str, required=True,
                      help="Specify a URL to as the server.")

  args = parser.parse_args()

  try:
    system_id = get_system_id()
    if unregister(args.username, args.password, args.server_url, system_id) != 1:
      return 1
  except xmlrpclib.ProtocolError as err:
    print "A fault occurred"
    print "Fault string: %s" % err
    return 1
  except xmlrpclib.Fault as err:
    print "A fault occurred"
    print "Fault code: %d" % err.faultCode
    print "Fault string: %s" % err.faultString
    return 1
  except IOError as err:
    print "A fault occurred"
    print "Fault string: %s" % err
    return 1

  print "Unregister successful"
  return 0

if __name__ == "__main__":
    sys.exit(main())
