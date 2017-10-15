execfile('common.py')

print 'set SAML TAI login attribute to mail'
result = AdminTask.configureInterceptor('[-interceptor com.ibm.ws.security.web.saml.ACSTrustAssociationInterceptor -customProperties ["sso_1.sp.principalName=mail"] ]')

saveConfiguration()
