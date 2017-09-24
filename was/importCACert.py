import re 

def printUsage():
    print ""
    print 'Usage: $WAS_HOME/bin/wsadmin -lang jython'
    print "[-user username] [-password password]"
    print "-f /tmp/importCACert.py caFile caLabel"
    print '      $WAS_HOME     is the installation directory for WebSphere'
    print "      username     is the WebSphere Application Server"
    print "                    user"
    print "      password     is the user password"
    print "      CaFile       is the file from which you are"
    print "                    importing the cell truststore"
    print "      label        is the label of the the certificate"
    print "                    in the keystore"
    print ""
    print "Sample:"
    print "===================================================================="
    print "wsadmin -lang jython -user tipadmin -password admin123" 
    print " -f \"/tmp/import-ca-certs.py\" \"/tmp/example-root-ca.cer\" example-root-ca"
    print "===================================================================="
    print ""


# Verify that the correct number of parameters exist
if not (len(sys.argv) == 2):
   sys.stderr.write("Invalid number of arguments\n")
   printUsage()
   sys.exit(101)

ca_path = sys.argv[0] 
ca_alias = sys.argv[1] 

cell = AdminControl.getCell() 

certificates = AdminTask.listSignerCertificates('[-keyStoreName CellDefaultTrustStore -keyStoreScope (cell):' + cell + ' ]').splitlines() 
for certificate in certificates: 
 certificate = re.sub('^\[\[','[',certificate) 
 certificate = re.sub('\]\]$',']',certificate) 
 details = re.findall(r'\[([^]]*)\]',certificate) 
 for detail in details: 
   if ( detail == 'alias ' + ca_alias + '' ): 
     print 'old ca certificate ' + ca_alias + ' found - deleting' 
     result = AdminTask.deleteSignerCertificate('[-keyStoreName CellDefaultTrustStore -keyStoreScope (cell):' + cell + ' -certificateAlias ' + ca_alias + ' ]') 

print 'Adding custom ' + ca_alias + ' CA to cell default trust store' 
result = AdminTask.addSignerCertificate('[-keyStoreName CellDefaultTrustStore -keyStoreScope (cell):' + cell + ' -certificateFilePath ' + ca_path + ' -base64Encoded true -certificateAlias ' + ca_alias + ' ]') 
print '*** saving configuration ***' 
result = AdminConfig.save() 
