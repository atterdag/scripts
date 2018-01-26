import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
    if re.match('^f\s', arg):
        script_directory = java.io.File(arg.split()[1]).getParent()
        execfile(script_directory + '/common.py')


def printUsage():
    print
    print 'Usage: $WAS_HOME/bin/wsadmin -lang jython'
    print '[-profileName profilename]'
    print '[-user username] [-password password]'
    print '-f /tmp/import_saml_idp.py <inputFile> <signingCertAlias>'
    print '      $WAS_HOME        is the installation directory for WebSphere'
    print '                        Application Server'
    print '      profilename      is the WebSphere Application Server profile'
    print '      username         is the WebSphere Application Server user name'
    print '      password         is the WebSphere Application Server user password'
    print '      inputFile        is the SAML IdP metadata XML file'
    print '      signingCertAlias is the common name of the signer certificate'
    print
    print 'Sample:'
    print '=============================================================================='
    print '/opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython'
    print ' -profileName Dmgr01 -user wasadmin -password passw0rd'
    print ' -f "/tmp/import_saml_idp.py"'
    print ' "/tmp/samlidp.xml" "ADFS Signing - adfs.example.com"'
    print '=============================================================================='
    print


if not (len(sys.argv) == 2):
    sys.stderr.write('Invalid number of arguments\n')
    printUsage()
    sys.exit(101)

inputFile = sys.argv[0]
signingCertAlias = sys.argv[1]

cell = AdminControl.getCell()
result = AdminTask.importSAMLIdpMetadata(
    '-idpMetadataFileName ' + inputFile +
    ' -idpId 1 -ssoId 1 -signingCertAlias ' + signingCertAlias)

saveConfiguration()
