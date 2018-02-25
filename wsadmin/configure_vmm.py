import getopt, sys, os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
    if re.match('^f\s', arg):
        script_directory = java.io.File(arg.split()[1]).getParent()
        execfile(script_directory + '/common.py')


# printed if syntax is wrong
def printUsage():
    print
    print 'Usage: $WAS_HOME/bin/wsadmin -lang jython'
    print '[-profileName profilename]'
    print '[-user username]'
    print '[-password password]'
    print '-f /tmp/configureLTPA.py'
    print '--ldapBaseDN <search base DN>'
    print '--ldapBindDN <bind DN>'
    print '--ldapBindPW <bind password>'
    print '--ldapHostName <LDAP hostname>'
    print '[--ldapPort <listening port>]'
    print '--ldapType = <IDS|AD|Domino>'
    print '[--ldapSSL <true|false>]'
    print '[--backupLdapHostName <backup LDAP hostname>]'
    print '[--backupLdapPort <backup LDAP port>]'
    print '--ldapTimeout = <timeout in secs>'
    print '[--ldapGroupOc <group DSE object class>]'
    print '[--ldapGroupOcForCreate <group DSE object class>]'
    print '[--ldapUserOc <user DSE object class>]'
    print '[--ldapUserOcForCreate <user DSE object class>]'
    print '[--ldapMemberAttribute <group member attribute>]'
    print '[--ldapMemberScope <direct|nested|all>]'
    print '[--ldapMembershipAttribute <group membership attribute>]'
    print '[--ldapMembershipScope <direct|nested>]'
    print '[--ldapUserIdAttribute <user name attribute>]'
    print '[--serverId <WAS server ID\'s DN>'
    print '[--serverIdPassword <WAS server ID\'s password>]'
    print '--primaryAdminId <WAS primary administrator ID>'
    print '[--vmmBaseDN <VMM base DN>]'
    print '[--vmmRealmID <VMM realm name>]'
    print '[--vmmRepositoryID <LDAP repository name>]'
    print '[--vmmUserDefaultParent <DN in LDAP DIT>]'
    print '[--vmmGroupDefaultParent <DN in LDAP DIT>]'
    print
    print '      $WAS_HOME     is the installation directory for WebSphere'
    print '                     Application Server'
    print '      profilename   is the WebSphere Application Server profile'
    print '      username      is the WebSphere Application Server'
    print '                     user'
    print '      password      is the user password'
    print '      <options>     should be pretty self explanitory'
    print '      [<options>]   are optional'
    print
    print 'Sample:'
    print '=============================================================================='
    print '/opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython'
    print ' -profileName Dmgr01 -user wasadmin -password passw0rd'
    print ' -f \"/tmp/configureLTPA.py\"'
    print ' --ldapBaseDN \'o=example\''
    print ' --ldapBindDN \'cn=ldapbind,ou=DSA,o=example\''
    print ' --ldapBindPW \'passw0rd\''
    print ' --ldapHostName \'sdsm.example.com\''
    print ' --ldapPort \'636\''
    print ' --backupLdapHostName \'sdss.example.com\''
    print ' --backupLdapPort \'636\''
    print ' --ldapSSL \'true\''
    print ' --ldapType \'IDS\''
    print ' --ldapUserOc \'inetOrgPerson\''
    print ' --ldapUserIdAttribute \'uid\''
    print ' --ldapGroupOc \'groupOfNames\''
    print ' --ldapMemberAttribute \'member\''
    print ' --ldapMemberScope \'nested\''
    print ' --ldapMembershipAttribute \'ibm-allGroups\''
    print ' --ldapMembershipScope \'nested\''
    print ' --ldapTimeout \'30\''
    print ' --primaryAdminId \'wasadmin\''
    print ' --serverId \'uid=wasadmin,ou=users,o=example\''
    print ' --serverIdPassword \'passw0rd\''
    print ' --vmmBaseDN \'o=example\''
    print ' --vmmRealmID \'defaultWIMFileBasedRealm\''
    print ' --vmmRepositoryID \'ldap.example.com:636\''
    print ' --vmmUserDefaultParent \'ou=users\''
    print '=============================================================================='
    print


##############################################################################
# Set values according to your LDAP environment                              #
##############################################################################
# sort the wsadmin sys.argv list into a tuple
optlist, args = getopt.getopt(sys.argv, 'x', [
    'ldapBaseDN=', 'ldapBindDN=', 'ldapBindPW=', 'ldapHostName=', 'ldapPort=',
    'backupLdapHostName=', 'backupLdapPort=', 'ldapSSL=', 'ldapUserOc=',
    'ldapUserOcForCreate=', 'ldapUserIdAttribute=', 'ldapGroupOc=',
    'ldapGroupOcForCreate=', 'ldapMemberAttribute=', 'ldapMemberScope=',
    'ldapMembershipAttribute=', 'ldapMembershipScope=', 'ldapTimeout=',
    'ldapType=', 'primaryAdminId=', 'serverId=', 'serverIdPassword=',
    'vmmBaseDN=', 'vmmRealmID=', 'vmmRepositoryID=', 'vmmUserDefaultParent=',
    'vmmGroupDefaultParent='
])

# convert the tuple into a dict
optdict = dict(optlist)

# map the dict value into specific variables, and assign default values if no
# value specified
ldapBaseDN = optdict.get('--ldapBaseDN', '')
ldapBindDN = optdict.get('--ldapBindDN', '')
ldapBindPW = optdict.get('--ldapBindPW', '')
ldapHostName = optdict.get('--ldapHostName', '')
ldapPort = optdict.get('--ldapPort', '389')
backupLdapHostName = optdict.get('--backupLdapHostName', '')
backupLdapPort = optdict.get('--backupLdapPort', '')
ldapSSL = optdict.get('--ldapSSL', 'false')
ldapType = optdict.get('--ldapType', '')
ldapTimeout = optdict.get('--ldapTimeout', '30')
serverId = optdict.get('--serverId', 'autogenerated')
serverIdPassword = optdict.get('--serverIdPassword', '')
primaryAdminId = optdict.get('--primaryAdminId', '')
vmmBaseDN = optdict.get('--vmmBaseDN', ldapBaseDN)
vmmRealmID = optdict.get('--vmmRealmID', 'defaultWIMFileBasedRealm')
vmmRepositoryID = optdict.get('--vmmRepositoryID',
                              ldapHostName + ':' + ldapPort)
vmmUserDefaultParent = optdict.get('--vmmUserDefaultParent', '')
vmmGroupDefaultParent = optdict.get('--vmmGroupDefaultParent', '')

# set LDAP type default values
if (ldapType == 'IDS'):
    ldapUserOc = optdict.get('--ldapUserOc', 'inetOrgPerson')
    ldapUserOcForCreate = optdict.get('--ldapUserOcForCreate', 'inetOrgPerson')
    ldapUserIdAttribute = optdict.get('--ldapUserIdAttribute', 'uid')
    ldapGroupOc = optdict.get('--ldapGroupOc', 'groupOfNames')
    ldapGroupOcForCreate = optdict.get('--ldapGroupOcForCreate', 'groupOfNames')
    ldapMemberAttribute = optdict.get('--ldapMemberAttribute', 'member')
    ldapMemberScope = optdict.get('--ldapMemberScope', 'nested')
    ldapMembershipAttribute = optdict.get('--ldapMembershipAttribute',
                                          'ibm-allGroups')
    ldapMembershipScope = optdict.get('--ldapMembershipScope', 'nested')
elif (ldapType == 'AD'):
    ldapUserOc = optdict.get('--ldapUserOc', 'user')
    ldapUserOcForCreate = optdict.get('--ldapUserOcForCreate', 'user')
    ldapUserIdAttribute = optdict.get('--ldapUserIdAttribute',
                                      'samAccountName')
    ldapGroupOc = optdict.get('--ldapGroupOc', 'group')
    ldapGroupOcForCreate = optdict.get('--ldapGroupOcForCreate', 'group')
    ldapMemberAttribute = optdict.get('--ldapMemberAttribute', 'member')
    ldapMemberScope = optdict.get('--ldapMemberScope', 'direct')
    ldapMembershipAttribute = optdict.get('--ldapMembershipAttribute',
                                          'memberOf')
    ldapMembershipScope = optdict.get('--ldapMembershipScope', 'direct')
elif (ldapType == 'Domino'):
    ldapUserOc = optdict.get('--ldapUserOc', 'DominoPerson')
    ldapUserOcForCreate = optdict.get('--ldapUserOcForCreate', 'DominoPerson')
    ldapUserIdAttribute = optdict.get('--ldapUserIdAttribute', 'uid')
    ldapGroupOc = optdict.get('--ldapGroupOc', 'DominoGroup')
    ldapGroupOcForCreate = optdict.get('--ldapGroupOcForCreate', 'DominoGroup')
    ldapMemberAttribute = optdict.get('--ldapMemberAttribute', 'member')
    ldapMemberScope = optdict.get('--ldapMemberScope', 'nested')
    ldapMembershipAttribute = optdict.get('--ldapMembershipAttribute',
                                          'dominoAccessGroups ')
    ldapMembershipScope = optdict.get('--ldapMembershipScope', 'nested')

# check for required values
if (ldapBaseDN == '' or ldapBindDN == '' or ldapBindPW == ''
        or ldapHostName == '' or ldapType == '' or primaryAdminId == ''):
    printUsage()
    print 'missing required switch'
    sys.exit(2)

# ensure if serverId is set, that serverIdPassword is also set
if (serverId != 'autogenerated' and serverIdPassword == ''):
    printUsage()
    print
    print 'if serverId is set, then serverIdPassword must also be set'
    sys.exit(2)

# show operator the final values, both set by operator, but also default
print 'configuring VMM with the following values:'
print
print 'ldapBaseDN               = ' + ldapBaseDN
print 'ldapBindDN               = ' + ldapBindDN
print 'ldapBindPW               = ' + ldapBindPW
print 'ldapHostName             = ' + ldapHostName
print 'ldapPort                 = ' + ldapPort
print 'backupLdapHostName       = ' + backupLdapHostName
print 'backupLdapPort           = ' + backupLdapPort
print 'ldapSSL                  = ' + ldapSSL
print 'ldapUserOc               = ' + ldapUserOc
print 'ldapUserOcForCreate      = ' + ldapUserOcForCreate
print 'ldapUserIdAttribute      = ' + ldapUserIdAttribute
print 'ldapGroupOc              = ' + ldapGroupOc
print 'ldapGroupOcForCreate     = ' + ldapGroupOcForCreate
print 'ldapMemberAttribute      = ' + ldapMemberAttribute
print 'ldapMemberScope          = ' + ldapMemberScope
print 'ldapMembershipAttribute  = ' + ldapMembershipAttribute
print 'ldapMembershipScope      = ' + ldapMembershipScope
print 'ldapTimeout              = ' + ldapTimeout
print 'ldapType                 = ' + ldapType
print 'primaryAdminId           = ' + primaryAdminId
print 'serverId                 = ' + serverId
print 'serverIdPassword         = ' + serverIdPassword
print 'vmmBaseDN                = ' + vmmBaseDN
print 'vmmRealmID               = ' + vmmRealmID
print 'vmmRepositoryID          = ' + vmmRepositoryID
print 'vmmUserDefaultParent     = ' + vmmUserDefaultParent
print 'vmmGroupDefaultParent    = ' + vmmGroupDefaultParent
print
##############################################################################
# No need to change anything after this point ...                            #
##############################################################################

print
print '##############################################################################'
print '# resetting VMM to default configuration                                     #'
print '##############################################################################'
print

cell = AdminControl.getCell()
print 'read cell name: ' + cell

defaultVmmRealmID = AdminTask.getIdMgrDefaultRealm()
print 'default VMM realm name: ' + defaultVmmRealmID

print 'retriving list of existing repository IDs'
repositoryIds = extractRepositoryIds(AdminTask.listIdMgrRepositories())

defaultVmmConfiguration = 'false'
for repositoryId in repositoryIds:
    if (repositoryId == 'InternalFileRepository'):
        realmBaseEntries = AdminTask.listIdMgrRealmBaseEntries(
            '[-name "' + defaultVmmRealmID + '"]').splitlines()
        for realmBaseEntry in realmBaseEntries:
            if (realmBaseEntry == 'o=defaultWIMFileBasedRealm'):
                defaultVmmConfiguration = 'true'

if (defaultVmmConfiguration == 'false'):
    print 'creating base entry "o=defaultWIMFileBasedRealm" under repository "InternalFileRepository"'
    result = AdminTask.addIdMgrRealmBaseEntry(
        '[-name defaultWIMFileBasedRealm -baseEntry o=defaultWIMFileBasedRealm]'
    )

for repositoryId in repositoryIds:
    if repositoryId == vmmRepositoryID:
        baseEntries = AdminTask.listIdMgrRepositoryBaseEntries(
            '[-id "' + vmmRepositoryID + '"]')
        baseEntries = re.sub('^\{', '', baseEntries)
        baseEntries = re.sub('\}$', '', baseEntries)
        result = AdminTask.configureAdminWIMUserRegistry(
            '[-realmName ' + defaultVmmRealmID + ' -verifyRegistry false ]')
        print 'deleting base DNs under repository: ' + repositoryId
        for baseEntry in baseEntries.split(', '):
            entries = baseEntry.split('=')
            for key, value in zip(entries[0::2], entries[1:2]):
                vmmBaseEntry = key + '=' + value
                print ' - ' + vmmBaseEntry
                try:
                    result = AdminTask.deleteIdMgrRealmBaseEntry(
                        '[-name ' + defaultVmmRealmID + ' -baseEntry ' +
                        vmmBaseEntry + ']')
                except:
                    pass
                try:
                    result = AdminTask.deleteIdMgrRepositoryBaseEntry(
                        '[-id ' + repositoryId + ' -name ' + vmmBaseEntry + ']'
                    )
                except:
                    pass
        print 'deleting existing repository ' + vmmRepositoryID
        result = AdminTask.deleteIdMgrRepository('[-id ' + repositoryId + ']')

saveConfiguration()

print
print '##############################################################################'
print '# adding, and configuring repository                                         #'
print '##############################################################################'
print

print 'create federated repository ' + vmmRepositoryID
if (ldapSSL == 'true'):
    result = AdminTask.createIdMgrLDAPRepository(
        '[-default true -id ' + vmmRepositoryID +
        ' -adapterClassName com.ibm.ws.wim.adapter.ldap.LdapAdapter -ldapServerType '
        + ldapType +
        ' -sslConfiguration -certificateMapMode exactdn -supportChangeLog none -certificateFilter -loginProperties '
        + ldapUserIdAttribute + ']')
else:
    result = AdminTask.createIdMgrLDAPRepository(
        '[-default true -id ' + vmmRepositoryID +
        ' -adapterClassName com.ibm.ws.wim.adapter.ldap.LdapAdapter -ldapServerType '
        + ldapType + ' -supportChangeLog none -loginProperties ' +
        ldapUserIdAttribute + ']')

print 'adding LDAP server to repository ' + vmmRepositoryID
if (ldapSSL == 'true'):
    result = AdminTask.addIdMgrLDAPServer(
        '[-id ' + vmmRepositoryID + ' -host ' + ldapHostName + ' -bindDN "' +
        ldapBindDN + '" -bindPassword "' + ldapBindPW +
        '" -referal ignore -sslEnabled ' + ldapSSL + ' -ldapServerType ' +
        ldapType +
        ' -sslConfiguration -certificateMapMode exactdn -certificateFilter -authentication simple -port  '
        + ldapPort + ']')
else:
    result = AdminTask.addIdMgrLDAPServer(
        '[-id ' + vmmRepositoryID + ' -host ' + ldapHostName + ' -bindDN "' +
        ldapBindDN + '" -bindPassword "' + ldapBindPW +
        '" -referal ignore -sslEnabled ' + ldapSSL + ' -ldapServerType ' +
        ldapType + ' -authentication simple -port  ' + ldapPort + ']')

if (backupLdapHostName != ''):
    print 'adding backup LDAP server to repository'
    result = AdminTask.addIdMgrLDAPBackupServer(
        '[-id ' + vmmRepositoryID + ' -primary_host ' + ldapHostName +
        ' -host ' + backupLdapHostName + ' -port ' + backupLdapPort + ']')

print 'setting LDAP connection timeout on ' + vmmRepositoryID
result = AdminTask.updateIdMgrLDAPServer(
    '[-id ' + vmmRepositoryID + ' -host ' + ldapHostName +
    ' -connectTimeout ' + ldapTimeout + ']')

print 'defining LDAP search limits on ' + vmmRepositoryID
result = AdminTask.updateIdMgrLDAPRepository(
    '[-id ' + vmmRepositoryID +
    ' -searchTimeLimit 120000 -searchCountLimit 500]')

print 'disabling obsolete LDAP connection pool ' + vmmRepositoryID
result = AdminTask.updateIdMgrLDAPServer(
    '[-id ' + vmmRepositoryID + ' -host ' + ldapHostName +
    ' -connectionPool false]')

print 'configuring LDAP context pool ' + vmmRepositoryID
result = AdminTask.setIdMgrLDAPContextPool(
    '[-id ' + vmmRepositoryID +
    ' -enabled true -initPoolSize 1 -maxPoolSize 20 -prefPoolSize 3 -poolTimeOut 2700]'
)

print 'defining LDAP attribute cache size on ' + vmmRepositoryID
result = AdminTask.setIdMgrLDAPAttrCache(
    '[-id ' + vmmRepositoryID +
    ' -enabled true -cacheSize 4000 -cacheDistPolicy none -cacheTimeOut 1200]')

print 'defining LDAP results cache size on ' + vmmRepositoryID
result = AdminTask.setIdMgrLDAPSearchResultCache(
    '[-id ' + vmmRepositoryID +
    ' -enabled true -cacheSize 2000 -cacheDistPolicy none -cacheTimeOut 600]')

print 'defining LDAP group search filter for ' + vmmRepositoryID
result = AdminTask.updateIdMgrLDAPEntityType(
    '[-id ' + vmmRepositoryID + ' -name Group -objectClasses ' + ldapGroupOc +
    ' -searchBases  -searchFilter (objectClass=' + ldapGroupOc +
    ') -objectClassesForCreate ' + ldapGroupOcForCreate + ']')

print 'defining LDAP user search filter for ' + vmmRepositoryID
result = AdminTask.updateIdMgrLDAPEntityType(
    '[-id ' + vmmRepositoryID + ' -name PersonAccount -objectClasses ' +
    ldapUserOc + ' -searchBases  -searchFilter (objectClass=' + ldapUserOc +
    ') -objectClassesForCreate ' + ldapUserOcForCreate + ']')

print 'defining LDAP group membership attribute, and scope ' + vmmRepositoryID
result = AdminTask.setIdMgrLDAPGroupConfig(
    '[-id ' + vmmRepositoryID + ' -name ' + ldapMembershipAttribute +
    ' -scope ' + ldapMembershipScope + ']')

print 'defining LDAP group member attribute, and scope ' + vmmRepositoryID
result = AdminTask.updateIdMgrLDAPGroupMemberAttr(
    '[-id ' + vmmRepositoryID + ' -name ' + ldapMemberAttribute +
    ' -objectClass ' + ldapGroupOc + ' -scope ' + ldapMemberScope + ']')

saveConfiguration()

print
print '##############################################################################'
print '# adding base DN, and setting primary administration ID                      #'
print '##############################################################################'
print

print 'adding repository baseDN ' + ldapBaseDN + ' to WAS VMM baseDN ' + vmmBaseDN
result = AdminTask.addIdMgrRepositoryBaseEntry(
    '[-id ' + vmmRepositoryID + ' -name ' + ldapBaseDN +
    ' -nameInRepository ' + vmmBaseDN + ']')

print 'adding WAS VMM base DN ' + vmmBaseDN + ' to realm'
result = AdminTask.addIdMgrRealmBaseEntry(
    '[-name defaultWIMFileBasedRealm -baseEntry ' + vmmBaseDN + ']')

if (serverId == 'autogenerated'):
    print 'setting realm primary ID to ' + primaryAdminId + ', and automatically generate server identity'
    result = AdminTask.configureAdminWIMUserRegistry(
        '[-autoGenerateServerId true -primaryAdminId ' + primaryAdminId +
        ' -ignoreCase true -customProperties  -verifyRegistry false ]')
else:
    print 'setting realm primary ID to ' + primaryAdminId + ', and server ID to ' + serverId
    result = AdminTask.configureAdminWIMUserRegistry(
        '[-autoGenerateServerId false -primaryAdminId ' + primaryAdminId +
        ' -serverId ' + serverId + ' -serverIdPassword ' + serverIdPassword +
        ' -ignoreCase true -customProperties  -verifyRegistry false ]')

print 'validate realm administrator'
result = AdminTask.validateAdminName(
    '[-registryType WIMUserRegistry -adminUser ' + primaryAdminId + ' ]')

saveConfiguration()

print
print '##############################################################################'
print '# renaming realm (if needed), and allow operation if repositories are down   #'
print '##############################################################################'
print

if defaultVmmRealmID != vmmRealmID:
    #print 'disable realm verification'
    #result = AdminTask.configureAdminWIMUserRegistry('[-realmName ' + vmmRealmID + ' -verifyRegistry false ]')

    print 'renaming realm to ' + vmmRealmID
    result = AdminTask.renameIdMgrRealm(
        '[-name defaultWIMFileBasedRealm -newName ' + vmmRealmID + ']')

#print 'validate primary ID'
#result = AdminTask.validateAdminName('[-registryType WIMUserRegistry -adminUser ' + primaryAdminId + ' ]')

print 'set current realm definition to Federated repositories'
result = AdminTask.configureAdminWIMUserRegistry(
    '[-realmName ' + vmmRealmID + ' -verifyRegistry true ]')

print 'allow WAS to run if repository is unavailable'
result = AdminTask.updateIdMgrRealm(
    '[-name ' + vmmRealmID + ' -allowOperationIfReposDown true]')

saveConfiguration()

print
print '##############################################################################'
print '# configuring default parent for VMM supported entity types                  #'
print '##############################################################################'
print

print "setting default parent for PersonAccount entity type"
result = AdminTask.updateIdMgrSupportedEntityType(
    '[-name "PersonAccount" -defaultParent "' + vmmUserDefaultParent + '"]')

print "setting default parent for Group entity type"
result = AdminTask.updateIdMgrSupportedEntityType(
    '[-name "Group" -defaultParent "' + vmmGroupDefaultParent + '"]')

saveConfiguration()

print
print '##############################################################################'
print '# deleting remaining default VMM configuration                               #'
print '##############################################################################'
print

print "delete file based repository base entry"
result = AdminTask.deleteIdMgrRealmBaseEntry(
    '[-name ' + vmmRealmID + ' -baseEntry o=defaultWIMFileBasedRealm]')

# print "delete file based repository"
# result = AdminTask.deleteIdMgrRepository('[-id InternalFileRepository]')

saveConfiguration()

print
print '##############################################################################'
print '# enabling security                                                          #'
print '##############################################################################'
print

print 'set active user reposity to WIM'
result = AdminTask.setAdminActiveSecuritySettings(
    '-activeUserRegistry WIMUserRegistry')

print 'enabling global, and administrative security'
result = AdminTask.setAdminActiveSecuritySettings('-enableGlobalSecurity true')

print 'enabling application security'
result = AdminTask.setAdminActiveSecuritySettings('-appSecurityEnabled true')

print 'disabling java 2 security'
result = AdminTask.setAdminActiveSecuritySettings(
    '-enforceJava2Security false')

saveConfiguration()
