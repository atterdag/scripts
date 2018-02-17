import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
    if re.match('^f\s', arg):
        script_directory = java.io.File(arg.split()[1]).getParent()
        execfile(script_directory + '/common.py')

cell = AdminControl.getCell()

print 'creating key store for SAML certificates at cell scope'
result = AdminTask.createKeyStore(
    '[-keyStoreName SAMLKeyStore -scopeName (cell):' + cell +
    ' -keyStoreDescription "Key store for SAML certificates" -keyStoreLocation ${CONFIG_ROOT}/cells/'
    + cell +
    '/saml.p12 -keyStorePassword WebAS -keyStorePasswordVerify WebAS -keyStoreType PKCS12 -keyStoreInitAtStartup false -keyStoreReadOnly false -keyStoreStashFile false -keyStoreUsage SSLKeys ]'
)

saveConfiguration()

print 'creating selfsigned SAML certificate'
result = AdminTask.createSelfSignedCertificate(
    '[-signatureAlgorithm SHA1withRSA -keyStoreName SAMLKeyStore -keyStoreScope (cell):'
    + cell +
    ' -certificateAlias samlSP-certificate -certificateVersion -certificateSize 2048 -certificateCommonName samlSP-certificate -certificateValidDays 365 ]'
)

saveConfiguration()
