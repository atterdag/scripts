print "enabling single sign-on"
result = AdminTask.configureSingleSignon('-enable true -domainName .example.com -interoperable true')
print "setting LTPA token names to LtpaToken, and LtpaToken2"
result = AdminTask.setAdminActiveSecuritySettings('[-customProperties[\"com.ibm.websphere.security.customLTPACookieName=LtpaToken\"]]')
result = AdminTask.setAdminActiveSecuritySettings('[-customProperties[\"com.ibm.websphere.security.customSSOCookieName=LtpaToken2\"]]')
print "allow operation if some of the repositories are down"
result = AdminTask.updateIdMgrRealm('[-name defaultWIMFileBasedRealm -allowOperationIfReposDown true]') 
print "*** saving configuration ***"
result = AdminConfig.save()
