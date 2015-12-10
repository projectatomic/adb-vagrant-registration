#!/usr/bin/python
import argparse
import xmlrpclib
import os.path
import sys

def main():
  parser = argparse.ArgumentParser(description="Unregister the system from Spacewalk Server, Red Hat Satellite or Red Hat Network Classic.")
  parser.add_argument("-s", "--serverurl", dest="server_url", type=str, required=True,
                      help="Specify a URL to as the server.")
  parser.add_argument("-f", "--file", dest="system_id", type=str, default='/etc/sysconfig/rhn/systemid',
                      help="Specify a path to the RHN systemid file.")

  args = parser.parse_args()

  try:
    if not os.path.exists(args.system_id):
      print "System is not registered to RHN"
      return 1
    client =  xmlrpclib.Server(args.server_url)
    client.system.delete_system(open(args.system_id).read())
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
  except Exception as e:
    print "A fault occurred"
    print "Fault: %s" % e
    return 1
  print "Unregister successful"
  return 0

if __name__ == "__main__":
    sys.exit(main())
