import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
  if re.match('^f\s',arg):
    script_directory = java.io.File(arg.split()[1]).getParent()
    execfile( script_directory + '/common.py')

print 'configure SAML TAI not require a session SAML token cookie before attempting login'
result = AdminTask.configureInterceptor('[-interceptor com.ibm.ws.security.web.saml.ACSTrustAssociationInterceptor -customProperties ["sso_1.sp.login.error.page=","sso_1.sp.acsErrorPage=","sso_1.sp.filter=VPscope==base"] ]')

saveConfiguration()
