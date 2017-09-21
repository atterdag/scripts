#!/bin/sh
echo "create python script to configure vmm"
cat > /tmp/configureVmm.py << EOF
customCaFile="/net/main/srv/common-setup/ssl/cacert.pem"
customCaLabel="example-ca"
ldapType="IDS"
ldapHostName="ldap.example.com"
ldapPort="636"
ldapBaseDN="o=example"
ldapBindDN="uid=ldapbind,ou=users,o=example"
ldapBindPW="passw0rd"
ldapUserIdAttribute="uid"
ldapGroupOC="groupOfNames"
ldapUserOC="inetOrgPerson"
vmmRepositoryID="RepositoryID_" + ldapHostName + ":636"
vmmBaseDN=ldapBaseDN
vmmServerID="wasadmin"
vmmRealmID="ExampleRealm"
ssoDomain=".example.com"

cell = AdminControl.getCell()

print "read cell name: " + cell

print "adding custom certifying authority to cell default trust store"
result = AdminTask.addSignerCertificate('[-keyStoreName CellDefaultTrustStore -keyStoreScope (cell):' + cell + ' -certificateFilePath ' + customCaFile + ' -base64Encoded true -certificateAlias ' + customCaLabel + ' ]')

print "*** saving configuration ***"
result = AdminConfig.save()

print "create federated repository"
result = AdminTask.createIdMgrLDAPRepository('[-default true -id ' + vmmRepositoryID + ' -adapterClassName com.ibm.ws.wim.adapter.ldap.LdapAdapter -ldapServerType ' + ldapType + ' -sslConfiguration -certificateMapMode exactdn -supportChangeLog none -certificateFilter -loginProperties ' + ldapUserIdAttribute + ']')

print "adding LDAP server to repository"
result = AdminTask.addIdMgrLDAPServer('[-id ' + vmmRepositoryID + ' -host ' + ldapHostName + ' -bindDN ' + ldapBindDN + ' -bindPassword ' + ldapBindPW + ' -referal ignore -sslEnabled true -ldapServerType ' + ldapType + ' -sslConfiguration -certificateMapMode exactdn -certificateFilter -authentication simple -port  ' + ldapPort + ']') 

print "defining LDAP search limits"
result = AdminTask.updateIdMgrLDAPRepository('[-id ' + vmmRepositoryID + ' -searchTimeLimit 120000 -searchCountLimit 500]')

print "set LDAP connect timeout"
AdminTask.updateIdMgrLDAPServer('[-id ' + vmmRepositoryID + ' -host ' + ldapHostName + ' -connectTimeout 30]') 

print "enabling LDAP context pool"
result = AdminTask.updateIdMgrLDAPServer('[-id ' + vmmRepositoryID + ' -host ' + ldapHostName + ' -connectionPool true]')

print "configuring LDAP context pool size"
result = AdminTask.setIdMgrLDAPContextPool('[-id ' + vmmRepositoryID + ' -enabled true -initPoolSize 1 -maxPoolSize 0 -prefPoolSize 3 -poolTimeOut 30]')

print "defining LDAP attribute cache size"
result = AdminTask.setIdMgrLDAPAttrCache('[-id ' + vmmRepositoryID + ' -enabled true -cacheSize 4000 -cacheDistPolicy none -cacheTimeOut 1200]')

print "defining LDAP results cache size"
result = AdminTask.setIdMgrLDAPSearchResultCache('[-id ' + vmmRepositoryID + ' -enabled true -cacheSize 2000 -cacheDistPolicy none -cacheTimeOut 600]')

print "defining LDAP group search filter"
result = AdminTask.updateIdMgrLDAPEntityType('[-id ' + vmmRepositoryID + ' -name Group -objectClasses groupOfNames -searchBases  -searchFilter (objectClass=' + ldapGroupOC + ')]')

print "defining LDAP user search filter"
result = AdminTask.updateIdMgrLDAPEntityType('[-id ' + vmmRepositoryID + ' -name PersonAccount -objectClasses inetOrgPerson -searchBases  -searchFilter (objectClass=' + ldapUserOC + ')]')

print "defining LDAP group membership attribute, and scope"
result = AdminTask.setIdMgrLDAPGroupConfig('[-id ' + vmmRepositoryID + ' -name ibm-allGroups -scope nested]')

print "defining LDAP group member attribute, and scope"
result = AdminTask.updateIdMgrLDAPGroupMemberAttr('[-id ' + vmmRepositoryID + ' -name member -objectClass groupOfNames -scope nested]')

print "*** saving configuration ***"
result = AdminConfig.save()

print "adding repository base DN to WAS VMM base DN"
result = AdminTask.addIdMgrRepositoryBaseEntry('[-id ' + vmmRepositoryID + ' -name ' + ldapBaseDN + ' -nameInRepository ' + vmmBaseDN + ']')

print "adding WAS VMM base DN to realm"
result = AdminTask.addIdMgrRealmBaseEntry('[-name defaultWIMFileBasedRealm -baseEntry ' + vmmBaseDN + ']')

print "setting realm primary ID"
result = AdminTask.configureAdminWIMUserRegistry('[-autoGenerateServerId true -primaryAdminId wasadmin_local -ignoreCase true -customProperties  -verifyRegistry false ]')

print "validate realm administrator"
result = AdminTask.validateAdminName('[-registryType WIMUserRegistry -adminUser wasadmin_local ]')

print "*** saving configuration ***"
result = AdminConfig.save()

print "renaming realm to " + vmmRealmID
result = AdminTask.renameIdMgrRealm('[-name defaultWIMFileBasedRealm -newName ' + vmmRealmID + ']')

print "disable realm verification"
result = AdminTask.configureAdminWIMUserRegistry('[-realmName ' + vmmRealmID + ' -verifyRegistry false ]')

print "changing realm server primary ID"
result = AdminTask.configureAdminWIMUserRegistry('[-autoGenerateServerId true -primaryAdminId ' + vmmServerID + ' -ignoreCase true -customProperties  -verifyRegistry false ]')

print "disallow WAS to run if repository is unavailable"
result = AdminTask.updateIdMgrRealm('[-name ' + vmmRealmID + ' -allowOperationIfReposDown false]')

print "validate primary ID"
result = AdminTask.validateAdminName('[-registryType WIMUserRegistry -adminUser ' + vmmServerID + ' ]')

print "*** saving configuration ***"
result = AdminConfig.save()

print "delete file based repository"
result = AdminTask.deleteIdMgrRealmBaseEntry('[-name ' + vmmRealmID + ' -baseEntry o=defaultWIMFileBasedRealm]')

print "*** saving configuration ***"
result = AdminConfig.save()

print "enabling administrative security"
result = AdminTask.setAdminActiveSecuritySettings('-enableGlobalSecurity true')

print "enabling application security"
result = AdminTask.setAdminActiveSecuritySettings('-appSecurityEnabled true')

print "disabling java 2 security"
result = AdminTask.setAdminActiveSecuritySettings('-enforceJava2Security false')

print "*** saving configuration ***"
result = AdminConfig.save()

print "enabling single sign-on"
result = AdminTask.configureSingleSignon('-enable true -domainName ' + ssoDomain + ' -interoperable true')

print "setting LTPA token names to LtpaToken, and LtpaToken2"
result = AdminTask.setAdminActiveSecuritySettings('[-customProperties[\"com.ibm.websphere.security.customLTPACookieName=LtpaToken\"]]')
result = AdminTask.setAdminActiveSecuritySettings('[-customProperties[\"com.ibm.websphere.security.customSSOCookieName=LtpaToken2\"]]')

print "*** saving configuration ***"
result = AdminConfig.save()
EOF
echo "running python script to configure vmm"
/opt/IBM/WebSphere/AppServer/profiles/Dmgr01/bin/wsadmin.sh -lang jython -username wasadmin_local -password passw0rd -f /tmp/configureVmm.py
