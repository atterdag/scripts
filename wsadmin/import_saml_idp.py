import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
  if re.match('^f\s',arg):
    script_directory = java.io.File(arg.split()[1]).getParent()
    execfile( script_directory + '/common.py')

inputFile = '/tmp/samlidp.xml'
signingCertAlias = 'ADFS Signing - adfs.example.com'

cell = AdminControl.getCell()
result = AdminTask.importSAMLIdpMetadata('-idpMetadataFileName ' + inputFile + ' -idpId 1 -ssoId 1 -signingCertAlias ' + signingCertAlias)

saveConfiguration()
