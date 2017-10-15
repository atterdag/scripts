execfile('common.py')

print 'configure SAML TAI not require a session SAML token cookie before attempting login'
result = AdminTask.configureInterceptor('[-interceptor com.ibm.ws.security.web.saml.ACSTrustAssociationInterceptor -customProperties ["sso_1.sp.login.error.page=","sso_1.sp.acsErrorPage=","sso_1.sp.filter=VPscope==base"] ]')

saveConfiguration()
