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
    print '-f /tmp/configureLTPA.py <domain name>'
    print '      $WAS_HOME     is the installation directory for WebSphere'
    print '                     Application Server'
    print '      profilename   is the WebSphere Application Server profile'
    print '      username      is the WebSphere Application Server user name'
    print '      password      is the WebSphere Application Server user password'
    print '      domain name   is the DNS domain name of services that can'
    print '                     consume the LTPA cookie'
    print
    print 'Sample:'
    print '=============================================================================='
    print '/opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython'
    print ' -profileName Dmgr01 -user wasadmin -password passw0rd'
    print ' -f "/tmp/configureLTPA.py" .example.com'
    print '=============================================================================='
    print


if not (len(sys.argv) == 1):
    sys.stderr.write('Invalid number of arguments\n')
    printUsage()
    sys.exit(101)

ssoDomain = sys.argv[0]

print '##############################################################################'
print '# Configuring single sign-on                                                 #'
print '##############################################################################'

print 'set single sign-on domain, and enable LTPA interoperability mode'
result = AdminTask.configureSingleSignon(
    '-enable true -domainName "' + ssoDomain +
    '" -interoperable true -requiresSSL false')

print 'setting LTPA v1 token names to LtpaToken'
result = AdminTask.setAdminActiveSecuritySettings(
    '[-customProperties[\"com.ibm.websphere.security.customLTPACookieName=LtpaToken\"]]'
)
print 'setting LTPA v2 token names to LtpaToken2'
result = AdminTask.setAdminActiveSecuritySettings(
    '[-customProperties[\"com.ibm.websphere.security.customSSOCookieName=LtpaToken2\"]]'
)

saveConfiguration()
