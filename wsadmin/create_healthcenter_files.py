import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
  if re.match('^f\s',arg):
    script_directory = java.io.File(arg.split()[1]).getParent()
    execfile( script_directory + '/common.py')

def printUsage():
  print
  print 'Usage: $WAS_HOME/bin/wsadmin -lang jython'
  print '[-user username] [-password password]'
  print '-f /tmp/create_healthcenter_files.py <hcusername> <hcpassword> <hcprivilege>'
  print '[hckeystorepw]'
  print '      $WAS_HOME     is the installation directory for WebSphere'
  print '      username      is the WebSphere Application Server user name'
  print '      password      is the WebSphere Application Server user password'
  print '      hcusername    is the healthcenter username'
  print '      hcpassword    is the healthcenter password'
  print '      hcprivilege   is the healthcenter privilege'
  print '      hckeystorepw  is the healthcenter keystore password'
  print
  print 'Sample:'
  print '=============================================================================='
  print 'wsadmin -lang jython -user wasadmin -password passw0rd'
  print ' -f "/tmp/create_healthcenter_files.py "healthcenter" "passw0rd" readwrite'
  print '=============================================================================='
  print

# Verify that the correct number of parameters exist
if not (len(sys.argv) >= 3):
  sys.stderr.write("Invalid number of arguments\n")
  printUsage()
  sys.exit(101)

healthcenterUsername = sys.argv[0]
healthcenterPassword = sys.argv[1]
healthcenterPrivilege = sys.argv[2]
healthcenterKeystorePassword = sys.argv[3]

if ( healthcenterKeystorePassword == '' ):
  healthcenterKeystorePassword = 'WebAS'

cell = AdminControl.getCell()
healthcenterDirectory = os.environ['CONFIG_ROOT'] + '/cells/' + cell + '/healthcenter/'

if not os.path.exists(healthcenterDirectory):
  print 'creating healthcenter configuration directory, ' + healthcenterDirectory
  os.makedirs(healthcenterDirectory)

print 'creating ' + healthcenterDirectory + 'authentication.txt'
authenticationFile = open(healthcenterDirectory + 'authentication.txt','w')
authenticationFile.write(healthcenterUsername + ' ' + healthcenterPassword + '\n')
authenticationFile.flush()
authenticationFile.close()

print 'creating ' + healthcenterDirectory + 'authorization.txt'
authorizationFile = open(healthcenterDirectory + 'authorization.txt','w')
authorizationFile.write(healthcenterUsername + ' ' + healthcenterPrivilege + '\n')
authorizationFile.flush()
authorizationFile.close()

if os.path.exists(os.environ['CONFIG_ROOT'] + '/cells/' + cell + '/healthcenter.jks'):
  print 'deleting existing ' + os.environ['CONFIG_ROOT'] + '/cells/' + cell + '/healthcenter.jks'
  result = AdminTask.deleteKeyStore('[-keyStoreName HealthCenterKeystore -scopeName (cell):' + cell + ' ]')
  os.remove(os.environ['CONFIG_ROOT'] + '/cells/' + cell + '/healthcenter.jks')

synchronizeActiveNodes()

print 'creating ' + os.environ['CONFIG_ROOT'] + '/cells/' + cell + '/healthcenter.jks'
result = AdminTask.createKeyStore('[-keyStoreName HealthCenterKeystore -scopeName (cell):' + cell + ' -keyStoreDescription "Key store for Health Center certificates" -keyStoreLocation \${CONFIG_ROOT}/cells/' + cell + '/healthcenter.jks -keyStorePassword ' + healthcenterKeystorePassword + ' -keyStorePasswordVerify ' + healthcenterKeystorePassword + ' -keyStoreType JKS    -keyStoreInitAtStartup false -keyStoreReadOnly false -keyStoreStashFile false -keyStoreUsage SSLKeys ]')

saveConfiguration()

print 'creating self-signed certificate in ' + os.environ['CONFIG_ROOT'] + '/cells/' + cell + '/healthcenter.jks'
result = AdminTask.createSelfSignedCertificate('[-signatureAlgorithm SHA256withRSA -keyStoreName HealthCenterKeystore -keyStoreScope (cell):' + cell + ' -certificateAlias HealthCenterCertificate -certificateVersion -certificateSize 2048 -certificateCommonName HealthCenterCertificate -certificateValidDays 365 ]')

synchronizeActiveNodes()

if os.path.exists('/tmp/root.cer'):
  print 'deleting existing /tmp/root.cer'
  os.remove('/tmp/root.cer')

print 'extracting public certificates from HealthCenterKeystore'
result = AdminTask.extractSignerCertificate('[-keyStoreName HealthCenterKeystore -keyStoreScope (cell):' + cell + ' -certificateFilePath /tmp/root.cer -base64Encoded true -certificateAlias root ]')

if os.path.exists('/tmp/healthcenter.cer'):
  print 'deleting existing /tmp/healthcenter.cer'
  os.remove('/tmp/healthcenter.cer')

result = AdminTask.extractCertificate('[-certificateFilePath /tmp/healthcenter.cer -base64Encoded true -certificateAlias HealthCenterCertificate -keyStoreName HealthCenterKeystore -keyStoreScope (cell):' + cell + ' ]')
