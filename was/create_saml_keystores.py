execfile('common.py')

cell = AdminControl.getCell()

print 'creating key store for SAML certificates at cell scope'
result = AdminTask.createKeyStore('[-keyStoreName SAMLKeyStore -scopeName (cell):' + cell + ' -keyStoreDescription "Key store for SAML certificates" -keyStoreLocation \${CONFIG_ROOT}/cells/' + cell + '/saml.p12 -keyStorePassword WebAS -keyStorePasswordVerify WebAS -keyStoreType PKCS12 -keyStoreInitAtStartup false -keyStoreReadOnly false -keyStoreStashFile false -keyStoreUsage SSLKeys ]')

saveConfiguration()

print 'adding Example CA to keystore'
result = AdminTask.addSignerCertificate('[-keyStoreName SAMLKeyStore -keyStoreScope (cell):' + cell + ' -certificateFilePath /net/main/srv/common-setup/ssl/cacert.pem -base64Encoded true -certificateAlias example-ca ]')
print 'creating selfsigned SAML certificate'
result = AdminTask.createSelfSignedCertificate('[-signatureAlgorithm SHA1withRSA -keyStoreName SAMLKeyStore -keyStoreScope (cell):' + cell + ' -certificateAlias samlSP-certificate -certificateVersion -certificateSize 2048 -certificateCommonName samlSP-certificate -certificateValidDays 365 ]')

saveConfiguration()
