outputFile = "/tmp/spdata.xml"

print 'exporting SAML SP meta data into /tmp/spdata.xml'
result = AdminTask.exportSAMLSpMetadata('-spMetadataFileName ' + outputFile + ' -ssoId 1')
