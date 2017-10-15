inputFile = '/tmp/samlidp.xml'
signingCertAlias = 'ADFS Signing - adfs.example.com'

execfile('common.py')

cell = AdminControl.getCell()
result = AdminTask.importSAMLIdpMetadata('-idpMetadataFileName ' + inputFile + ' -idpId 1 -ssoId 1 -signingCertAlias ' + signingCertAlias)

saveConfiguration()
