import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
    if re.match('^f\s', arg):
        script_directory = java.io.File(arg.split()[1]).getParent()
        execfile(script_directory + '/common.py')


def printUsage():
    print
    print 'Usage: $WAS_HOME/bin/wsadmin -lang jython'
    print '[-user username] [-password password]'
    print '-f /tmp/import_ca_certificates.py caFile caLabel'
    print '      $WAS_HOME     is the installation directory for WebSphere'
    print '      username      is the WebSphere Application Server user name'
    print '      password      is the WebSphere Application Server user password'
    print '      caFile        is the file from which you are'
    print '                     importing the cell truststore'
    print '      caLabel       is the label of the the certificate'
    print '                     in the keystore'
    print
    print 'Sample:'
    print '=============================================================================='
    print 'wsadmin -lang jython -user wasadmin -password passw0rd'
    print ' -f "/tmp/import_ca_certificates.py"'
    print ' "/tmp/example-root-ca.cer" "example-root-ca"'
    print '=============================================================================='
    print


# Verify that the correct number of parameters exist
if not (len(sys.argv) == 2):
    sys.stderr.write("Invalid number of arguments\n")
    printUsage()
    sys.exit(101)

ca_path = sys.argv[0]
ca_alias = sys.argv[1]

cell = AdminControl.getCell()

print '##############################################################################'
print '# Deleting existing certificate with same label                              #'
print '##############################################################################'
print
certificates = AdminTask.listSignerCertificates(
    '[-keyStoreName CellDefaultTrustStore -keyStoreScope (cell):' + cell + ' ]'
).splitlines()
for certificate in certificates:
    certificate = re.sub('^\[\[', '[', certificate)
    certificate = re.sub('\]\]$', ']', certificate)
    details = re.findall(r'\[([^]]*)\]', certificate)
    for detail in details:
        if (detail == 'alias ' + ca_alias + ''):
            print 'old ca certificate ' + ca_alias + ' found - deleting'
            result = AdminTask.deleteSignerCertificate(
                '[-keyStoreName CellDefaultTrustStore -keyStoreScope (cell):' +
                cell + ' -certificateAlias ' + ca_alias + ' ]')

print '##############################################################################'
print '# Adding certificate                                                         #'
print '##############################################################################'
print
print 'Adding custom ' + ca_alias + ' CA to cell default trust store'
result = AdminTask.addSignerCertificate(
    '[-keyStoreName CellDefaultTrustStore -keyStoreScope (cell):' + cell +
    ' -certificateFilePath ' + ca_path +
    ' -base64Encoded true -certificateAlias ' + ca_alias + ' ]')

saveConfiguration()
