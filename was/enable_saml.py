execfile('common.py')

print 'adding SAML TAI'
result = AdminTask.addSAMLTAISSO('-enable true -acsUrl https://was855ihs.dmz.example.com:443/samlsps/wps -trustStoreName SAMLKeyStore -keyStoreName SAMLKeyStore -keyAlias samlSP-certificate -keyName samlSP-certificate -keyPassword WebAS -errorPage https://adfs.example.com/adfs/ls/IdpInitiatedSignOn.aspx?loginToRp=https://was855ihs.dmz.example.com:443/samlsps/wps -idMap localRealm')
print '******* saving configuration *******'
result = AdminConfig.save()
print 'setting additional SAML TAI properties'
result = AdminTask.configureInterceptor('[-interceptor com.ibm.ws.security.web.saml.ACSTrustAssociationInterceptor -customProperties ["sso_1.sp.targetUrl=https://was855ihs.dmz.example.com/wps/myportal","sso_1.sp.principalName=uid","sso_1.sp.acsErrorPage=https://adfs.example.com/adfs/ls/IdpInitiatedSignOn.aspx?loginToRp=https://was855ihs.dmz.example.com:443/samlsps/wps","sso_1.sp.useRealm=ldap.example.com:636","sso_1.sp.login.error.page=https://adfs.example.com/adfs/ls/IdpInitiatedSignOn.aspx?loginToRp=https://was855ihs.dmz.example.com:443/samlsps/wps","sso_1.sp.useRealm=ldap.example.com:636","sso_1.sp.filter=request-url%=/wps/myportal"] ]')

saveConfiguration()
