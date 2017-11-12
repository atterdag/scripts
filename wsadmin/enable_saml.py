import os, re, java.io.File
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
  print '--idpFqdn FQDN'
  print '--appFqdn port'
  print '--appContextRoot name'
  print '[--principalName username]'
  print '[--acsUrl password]'
  print '[--errorPage directory]'
  print '[--targetUrl name]'
  print '[--filter true|false]'
  print '      $WAS_HOME                is the installation directory for WebSphere'
  print '                                Application Server'
  print '      profilename              is the WebSphere Application Server profile'
  print '      username                 is the WebSphere Application Server'
  print '                                user'
  print '      password                 is the user password'
  print '      idpFqdn                  is the IdP FQDN'
  print '      appFqdn                  is the first point of entry for the WAS cluster'
  print '      appContextRoot           is the context root of the application'
  print '      principalName            is the IdP subject attribute'
  print '      acsUrl                   is the ACS URL of the SAML SP application'
  print '      errorPage                is the URL to send users if their auth check fails'
  print '      targetUrl                is the URL to send users if their auth check pass'
  print '      filter                   is the WAS ACS application activation filter'
  print
  print 'Sample:'
  print '=============================================================================='
  print '/opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython'
  print ' -profileName Dmgr01 -user wasadmin -password passw0rd'
  print ' -f "/tmp/configureLTPA.py"'
  print ' --idpFqdn adfs.example.com'
  print ' --appFqdn app.example.com'
  print ' --appContextRoot /snoop'
  print ' --principalName uid'
  print '=============================================================================='
  print

# sort the wsadmin sys.argv list into a tuple
optlist, args = getopt.getopt(sys.argv, 'x', [
  'idpFqdn=',
  'appFqdn=',
  'appContextRoot=',
  'principalName=',
  'acsUrl=',
  'errorPage=',
  'targetUrl=',
  'filter=',
  'databaseHostTwo=',
  'databasePortTwo='
])

# convert the tuple into a dict
optdict = dict(optlist)

# map the dict value into specific variables, and assign default values if no
# value specified
idpFqdn        = optdict.get('--idpFqdn', '')
appFqdn        = optdict.get('--appFqdn', '')
appContextRoot = optdict.get('--appContextRoot', '')
principalName  = optdict.get('--principalName', 'uid')
acsUrl         = optdict.get('--acsUrl', 'https://' + lbFqdn + ':443/samlsps/wps')
errorPage      = optdict.get('--errorPage', 'https://' + idpFqdn + '/adfs/ls/IdpInitiatedSignOn.aspx?loginToRp=' + acsUrl)
targetUrl      = optdict.get('--targetUrl', 'https://' + lbFqdn + appContextRoot)
filter         = optdict.get('--filter', 'request-url%=' + appContextRoot)

# check for required values
if ( idpFqdn == ''
  or appFqdn == ''
  or appContextRoot == '' ):
  printUsage()
  print 'missing required switch'
  sys.exit(2)

useRealm = AdminTask.getIdMgrDefaultRealm()

print 'adding SAML TAI'
result = AdminTask.addSAMLTAISSO('-enable true -acsUrl ' + acsUrl + ' -trustStoreName SAMLKeyStore -keyStoreName SAMLKeyStore -keyAlias samlSP-certificate -keyName samlSP-certificate -keyPassword WebAS -errorPage ' + errorPage + ' -idMap localRealm')

saveConfiguration()

print 'setting additional SAML TAI properties'
result = AdminTask.configureInterceptor('[-interceptor com.ibm.ws.security.web.saml.ACSTrustAssociationInterceptor -customProperties ["sso_1.sp.targetUrl=' + targetUrl + '","sso_1.sp.principalName=' + principalName + '","sso_1.sp.acsErrorPage=' + errorPage + '","sso_1.sp.useRealm='  + useRealm + '","sso_1.sp.login.error.page=' + errorPage + '","sso_1.sp.filter= ' + filter + '"]]')

saveConfiguration()
