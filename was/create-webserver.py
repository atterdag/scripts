import getopt
import sys
import re

# the dict function is missing from the wsadmin jython, so we have to make our
# own
def dict(sequence):
  resultDict = {}
  for key, value in sequence:
    resultDict[key] = value
  return resultDict

def printUsage():
    print ''
    print 'Usage: \$WAS_HOME/bin/wsadmin -lang jython'
    print '[-profileName profilename]'
    print '[-user username]'
    print '[-password password]'
    print '-f /tmp/create-webserver.py'
    print '--fqdn <search base DN>'
    print '[--ihsInstallRoot <bind DN>]'
    print '[--plgInstallRoot <bind password>]'
    print '[--adminPort <LDAP hostname>]'
    print '[--adminUserID <listening port>]'
    print '[--adminPasswd <bind DN>]'
    print '[--adminProtocol <bind password>]'
    print '[--operatingSystem <LDAP hostname>]'
    print '      $WAS_HOME         is the installation directory for WebSphere'
    print '                         Application Server'
    print '      profilename       is the WebSphere Application Server profile'
    print '      username          is the WebSphere Application Server'
    print '                         user'
    print '      password          is the user password'
    print '      <options>     should be pretty self explanitory'
    print '      [<options>]   are optional'
    print ''
    print 'Sample:'
    print '===================================================================='
    print '/opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython'
    print ' -profileName Dmgr01 -user wasadmin -password passw0rd'
    print ' -f "/tmp/configureLTPA.py"'
    print ' --fqdn \'ihs855-1.dmz.example.com\''
    print ' --ihsInstallRoot \'/opt/IBM/HTTPServer\''
    print ' --plgInstallRoot \'/opt/IBM/WebSphere/Plugins\''
    print ' --adminPort \'8008\''
    print ' --adminUserID \'ihsadmin\''
    print ' --adminPasswd \'passw0rd\''
    print ' --adminProtocol \'HTTP\''
    print ' --operatingSystem \'linux\''
    print '===================================================================='
    print ''

# sort the wsadmin sys.argv list into a tuple
optlist, args = getopt.getopt(sys.argv, 'x', [
  'fqdn=',
  'ihsInstallRoot=',
  'plgInstallRoot=',
  'adminPort=',
  'adminUserID=',
  'adminPasswd=',
  'adminProtocol=',
  'operatingSystem='
])

# convert the tuple into a dict
optdict = dict(optlist)

# map the dict value into specific variables, and assign default values if no
# value specified
fqdn             = optdict.get('--fqdn', '')
ihsInstallRoot   = optdict.get('--ihsInstallRoot', '/opt/IBM/HTTPServer')
plgInstallRoot   = optdict.get('--plgInstallRoot', '/opt/IBM/WebSphere/Plugins')
adminPort        = optdict.get('--adminPort', '8008')
adminUserID      = optdict.get('--adminUserID', 'ihsadmin')
adminPasswd      = optdict.get('--adminPasswd', 'passw0rd')
adminProtocol    = optdict.get('--adminProtocol', 'HTTP')
operatingSystem  = optdict.get('--operatingSystem', 'linux')

# check for required values
if ( fqdn == '' ):
  printUsage()
  print 'missing required switch'
  sys.exit(2)

hostname = fqdn.split('.')[0]
domain = re.sub(hostname + '.','',fqdn)
nodeName = hostname + 'UnmanagedNode'

# show operator the final values, both set by operator, but also default
print
print '##############################################################################'
print '# register IHS with the following values:'
print '##############################################################################'
print
print 'fqdn             = ' + fqdn
print 'nodeName         = ' + nodeName
print 'ihsInstallRoot   = ' + ihsInstallRoot
print 'plgInstallRoot   = ' + plgInstallRoot
print 'adminPort        = ' + adminPort
print 'adminUserID      = ' + adminUserID
print 'adminPasswd      = ' + adminPasswd
print 'adminProtocol    = ' + adminProtocol
print 'operatingSystem  = ' + operatingSystem
print

unmanagedNodes = AdminTask.listUnmanagedNodes().splitlines()
for unmanagedNode in unmanagedNodes:
  if ( unmanagedNode == nodeName ):
    webservers = AdminTask.listServers('[-serverType WEB_SERVER -nodeName ' + unmanagedNode + ']').splitlines()
    for webserver in webservers:
      webserverName = AdminConfig.showAttribute(webserver, 'name')
      print 'deleting previous server: ' + nodeName + '/' + webserverName
      AdminTask.deleteWebServer('[-serverName ' + webserverName + ' -nodeName ' + nodeName + ']')
    print 'deleting previous node:   ' + nodeName
    AdminTask.removeUnmanagedNode('[-nodeName ' + nodeName + ']')
print
print 'creating new unmanaged node: ' + nodeName
AdminTask.createUnmanagedNode('[-nodeName ' + nodeName + ' -hostName ' + fqdn + ' -nodeOperatingSystem ' + operatingSystem + ']')
print 'creating new web server:     ' + nodeName + '/webserver1'
AdminTask.createWebServer(hostname + 'UnmanagedNode', '[-name webserver1 -templateName IHS -serverConfig [-webPort 80 -webInstallRoot ' + ihsInstallRoot + ' -webProtocol HTTP -pluginInstallRoot ' + plgInstallRoot + ' -webAppMapping ALL] -remoteServerConfig [-adminPort ' + adminPort + ' -adminUserID ' + adminUserID + ' -adminPasswd ' + adminPasswd + ' -adminProtocol ' + adminProtocol + ']]')

print
print '***** saving configuration *****'
result = AdminConfig.save()
