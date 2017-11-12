import getopt, sys, os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
  if re.match('^f\s',arg):
    script_directory = java.io.File(arg.split()[1]).getParent()
    execfile( script_directory + '/common.py')

def printUsage():
  print
  print 'Usage: \$WAS_HOME/bin/wsadmin -lang jython'
  print '[-profileName profilename]'
  print '[-user username]'
  print '[-password password]'
  print '-f /tmp/create-webserver.py'
  print '--fqdn <IHS FQDN>'
  print '[--ihsInstallRoot <directory path>]'
  print '[--plgInstallRoot <directory path>]'
  print '[--adminPort <listening port>]'
  print '[--adminUserID <username>]'
  print '[--adminPasswd <password>]'
  print '[--adminProtocol <HTTP|HTTPS>]'
  print '[--operatingSystem <linux|aix|windows>]'
  print '      $WAS_HOME         is the installation directory for WebSphere'
  print '                         Application Server'
  print '      profilename       is the WebSphere Application Server profile'
  print '      username          is the WebSphere Application Server'
  print '                         user'
  print '      password          is the user password'
  print '      <options>     should be pretty self explanitory'
  print '      [<options>]   are optional'
  print
  print 'Sample:'
  print '=============================================================================='
  print '/opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython'
  print ' -profileName Dmgr01 -user wasadmin -password passw0rd'
  print ' -f "/tmp/configureLTPA.py"'
  print ' --fqdn "ihs855-1.dmz.example.com"'
  print ' --ihsInstallRoot "/opt/IBM/HTTPServer"'
  print ' --plgInstallRoot "/opt/IBM/WebSphere/Plugins"'
  print ' --adminPort 8008'
  print ' --adminUserID "ihsadmin"'
  print ' --adminPasswd "passw0rd"'
  print ' --adminProtocol HTTP'
  print ' --operatingSystem linux'
  print '=============================================================================='
  print

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
print '# register IHS with the following values:                                    #'
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
AdminTask.createWebServer(hostname + 'UnmanagedNode', '[-name webserver1 -templateName IHS -serverConfig [-webPort 80 -serviceName -webInstallRoot ' + ihsInstallRoot + ' -webProtocol HTTPS -configurationFile  -errorLogfile  -accessLogfile  -pluginInstallRoot ' + plgInstallRoot + ' -webAppMapping ALL] -remoteServerConfig [-adminPort '  + adminPort + ' -adminUserID ' + adminUserID + ' -adminPasswd ' + adminPasswd + ' -adminProtocol ' + adminProtocol + ']]')

saveConfiguration()

print
print '##############################################################################'
print '# creating host aliases for *:80, and *.443                                  #'
print '##############################################################################'
print
import re
cell = AdminControl.getCell()
default_hostId = AdminConfig.getid('/Cell:' + cell + '/VirtualHost:default_host/')
default_hostIdAliases = AdminConfig.showAttribute(default_hostId,'aliases')
default_hostIdAliases = re.sub('^\[|\]$','',default_hostIdAliases)
for default_hostIdAlias in default_hostIdAliases.split():
  default_hostIdAliasHostname = AdminConfig.showAttribute(default_hostIdAlias,'hostname')
  default_hostIdAliasPort = AdminConfig.showAttribute(default_hostIdAlias,'port')
  if ( default_hostIdAliasHostname == '*' and ( default_hostIdAliasPort == '80' or default_hostIdAliasPort == '443') ):
    print 'deleting existing: ' + default_hostIdAliasHostname + ':' + default_hostIdAliasPort
    result = AdminConfig.remove(default_hostIdAlias)

print 'creating new host alias: *:80'
result = AdminConfig.create('HostAlias', AdminConfig.getid('/Cell:' + cell + '/VirtualHost:default_host/'), '[[port "80"] [hostname "*"]]')
print 'creating new host alias: *:443'
result = AdminConfig.create('HostAlias', AdminConfig.getid('/Cell:' + cell + '/VirtualHost:default_host/'), '[[port "443"] [hostname "*"]]')

print
print '##############################################################################'
print '# configure plugin to not timeout when communicating with application server #'
print '##############################################################################'
print
webserverPluginSettingsIds = AdminConfig.list('WebserverPluginSettings').splitlines()
for webserverPluginSettingsId in webserverPluginSettingsIds:
  serverIOTimeout = AdminConfig.showAttribute(webserverPluginSettingsId, 'ServerIOTimeout')
  print "modifying ServerOITimeout from " + serverIOTimeout + " to 0"
  result = AdminConfig.modify(webserverPluginSettingsId, '[[ServerIOTimeout "0"]]')

saveConfiguration()
propagatePluginCfg()
