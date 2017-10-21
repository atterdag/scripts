import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
  if re.match('^f\s',arg):
    script_directory = java.io.File(arg.split()[1]).getParent()
    execfile( script_directory + '/common.py')

saveConfiguration()

# define credentials, and priviledge
healthcenterUsername = '${HEALTHCENTER_USERNAME}'
healthcenterPassword = '${HEALTHCENTER_PASSWORD}'
healthcenterPrivilege = '${HEALTHCENTER_PRIVILEGE}'

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

print 'creating ' + os.environ['CONFIG_ROOT'] + '/cells/' + cell + '/healthcenter.jks'
result = AdminTask.createKeyStore('[-keyStoreName HealthCenterKeystore -scopeName (cell):' + cell + ' -keyStoreDescription "Key store for Health Center certificates" -keyStoreLocation \${CONFIG_ROOT}/cells/' + cell + '/healthcenter.jks -keyStorePassword WebAS -keyStorePasswordVerify WebAS -keyStoreType JKS    -keyStoreInitAtStartup false -keyStoreReadOnly false -keyStoreStashFile false -keyStoreUsage SSLKeys ]')

saveConfiguration()

print 'creating self-signed certificate in ' + os.environ['CONFIG_ROOT'] + '/cells/' + cell + '/healthcenter.jks'
result = AdminTask.createSelfSignedCertificate('[-signatureAlgorithm SHA256withRSA -keyStoreName HealthCenterKeystore -keyStoreScope (cell):' + cell + ' -certificateAlias HealthCenterCertificate -certificateVersion -certificateSize 2048 -certificateCommonName HealthCenterCertificate -certificateValidDays 365 ]')

synchronizeActiveNodes()

print 'extracting public certificates from HealthCenterKeystore'
result = AdminTask.extractSignerCertificate('[-keyStoreName HealthCenterKeystore -keyStoreScope (cell):' + cell + ' -certificateFilePath /tmp/root.cer -base64Encoded true -certificateAlias root ]')
result = AdminTask.extractCertificate('[-certificateFilePath /tmp/healthcenter.cer -base64Encoded true -certificateAlias HealthCenterCertificate -keyStoreName HealthCenterKeystore -keyStoreScope (cell):' + cell + ' ]')
