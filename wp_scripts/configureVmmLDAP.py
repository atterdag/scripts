ldapHostName = 'ldap.example.com'
ldapPort = '636'
ldapTimeout = '30'
ldapConnectionPool = 'false'
vmmRealmID = ldapHostName + ':' + ldapPort
vmmRepositoryID = 'RepositoryID_' + ldapHostName + ':' + ldapPort

print 'setting LDAP connection timeout on ' + vmmRepositoryID
result = AdminTask.updateIdMgrLDAPServer('[-id ' + vmmRepositoryID + ' -host ' + ldapHostName + ' -connectTimeout ' + ldapTimeout + ']')

print 'enabling LDAP connection pool ' + vmmRepositoryID
result = AdminTask.updateIdMgrLDAPServer('[-id ' + vmmRepositoryID + ' -host ' + ldapHostName + ' -connectionPool ' + ldapConnectionPool + ']')

print '***** saving configuration *****'
result = AdminConfig.save()
