import getopt, sys, os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
    if re.match('^f\s', arg):
        script_directory = java.io.File(arg.split()[1]).getParent()
        execfile(script_directory + '/common.py')


def printUsage():
    print
    print 'Usage: $WAS_HOME/bin/wsadmin -lang jython'
    print '[-profileName profilename]'
    print '[-user username]'
    print '[-password password]'
    print '-f /tmp/configure_security_auditing.py.py'
    print '[--auditorId <DN>]'
    print '[--auditName <name>]'
    print '[--auditOutcome <list>]'
    print '[--auditEventType <list>]'
    print '      $WAS_HOME      is the installation directory for WebSphere'
    print '                      Application Server'
    print '      profilename    is the WebSphere Application Server profile'
    print '      username       is the WebSphere Application Server'
    print '                      user'
    print '      password       is the user password'
    print '      auditorId      is the distinguished name of auditor in LDAP'
    print '      auditName      is the name of the audit rule'
    print '      auditOutcome   is a comma separated list of outcome included in filter'
    print '      auditEventType is a comma separated list of events included in filter'
    print
    print 'Sample:'
    print '=============================================================================='
    print '/opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython'
    print ' -profileName Dmgr01 -user wasadmin -password passw0rd'
    print ' -f "/tmp/configureLTPA.py"'
    print ' --auditorId "uid=wasadmin,ou=users,o=example"'
    print ' --auditName repositorySave'
    print ' --auditOutcome "SUCCESS"'
    print ' --auditEventType "ADMIN_REPOSITORY_SAVE,SECURITY_MGMT_AUDIT"'
    print '=============================================================================='
    print


# sort the wsadmin sys.argv list into a tuple
optlist, args = getopt.getopt(
    sys.argv, 'x',
    ['auditorId=', 'auditName=', 'auditOutcome=', 'auditEventType='])

# convert the tuple into a dict
optdict = dict(optlist)

defaultVmmRealmID = AdminTask.getIdMgrDefaultRealm()
serverId = AdminTask.getAccessIdFromServerId(
    '[-realmName ' + defaultVmmRealmID + ']').split('/')[1]

# map the dict value into specific variables, and assign default values if no
# value specified
auditorId = optdict.get('--auditorId', serverId)
auditName = optdict.get('--auditName', 'all')
auditOutcome = optdict.get(
    '--auditOutcome', 'ERROR,WARNING,INFO,SUCCESS,FAILURE,REDIRECT,DENIED')
auditEventType = optdict.get(
    '--auditEventType',
    'ADMIN_REPOSITORY_SAVE,SECURITY_SIGNING,SECURITY_RUNTIME_KEY,SECURITY_RUNTIME,SECURITY_RESOURCE_ACCESS,SECURITY_MGMT_RESOURCE,SECURITY_MGMT_REGISTRY,SECURITY_MGMT_PROVISIONING,SECURITY_MGMT_POLICY,SECURITY_MGMT_KEY,SECURITY_MGMT_CONFIG,SECURITY_MGMT_AUDIT,SECURITY_ENCRYPTION,SECURITY_AUTHZ,SECURITY_AUTHN_TERMINATE,SECURITY_AUTHN_MAPPING,SECURITY_AUTHN_DELEGATION,SECURITY_AUTHN_CREDS_MODIFY,SECURITY_AUTHN'
)

newAuditNotification = auditName + 'Notification'
newAuditFactoryName = auditName + 'AuditEventFactory'
newAuditEmitter = auditName + 'AuditLog'
newAuditFilterName = auditName + 'Filter'
newAuditFilterOutcome = auditOutcome
newAuditFilterEventType = auditEventType

# show operator the final values, both set by operator, but also default
print
print '##############################################################################'
print '# creating new audit log with the following values:                          #'
print '##############################################################################'
print
print 'auditorId               = ' + auditorId
print 'newAuditNotification    = ' + newAuditNotification
print 'newAuditFactoryName     = ' + newAuditFactoryName
print 'newAuditEmitter         = ' + newAuditEmitter
print 'newAuditFilterName      = ' + newAuditFilterName
print 'newAuditFilterOutcome   = ' + newAuditFilterOutcome
print 'newAuditFilterEventType = ' + newAuditFilterEventType
print

print 'disabling audit notification monitor'
auditNotificationMonitors = AdminTask.listAuditNotificationMonitors()
auditNotificationMonitorAttributes = stringToList(auditNotificationMonitors)
for auditNotificationMonitorAttributePair in auditNotificationMonitorAttributes:
    if (auditNotificationMonitorAttributePair[0] == 'monitorRef'):
        result = AdminTask.modifyAuditNotificationMonitor(
            '[-monitorRef ' + auditNotificationMonitorAttributePair[1] +
            ' -enable false ]')
        result = AdminTask.deleteAuditNotificationMonitorByRef(
            '-monitorRef ' + auditNotificationMonitorAttributePair[1] + ']')

print 'disable security auditing'
result = AdminTask.modifyAuditPolicy(
    '[-auditEnabled false -auditPolicy NOWARN -verbose false ]')

print 'delete existing audit notification ' + newAuditNotification
auditNotifications = AdminTask.listAuditNotifications().splitlines()
for auditNotification in auditNotifications:
    auditNotificationAttributes = stringToList(auditNotification)
    auditNotificationAttributeDict = {}
    for auditNotificationAttributePair in auditNotificationAttributes:
        auditNotificationAttributeDict[auditNotificationAttributePair[
            0]] = auditNotificationAttributePair[1]
    if (auditNotificationAttributeDict['name'] == newAuditNotification):
        result = AdminTask.deleteAuditNotification(
            '[-notificationRef ' +
            auditNotificationAttributeDict['notificationRef'] + ']')

print 'delete existing audit notification ' + newAuditNotification
auditNotificationRefs = AdminTask.getAuditNotificationRef().splitlines()
for auditNotificationRef in auditNotificationRefs:
    auditNotification = AdminTask.getAuditNotification(
        '[-notificationRef ' + auditNotificationRef + ']')
    auditNotificationAttributes = stringToList(auditNotification)
    for auditNotificationAttributePair in auditNotificationAttributes:
        if (auditNotificationAttributePair[0] == 'name'):
            if (auditNotificationAttributePair[1] == newAuditNotification):
                AdminTask.deleteAuditNotification(
                    '[-notificationRef ' + auditNotificationRef + ']')

print 'delete old existing audit event factory ' + newAuditFactoryName
auditEventFactories = AdminTask.listAuditEventFactories()
auditEventFactories = re.sub('\n', ' ', auditEventFactories)
auditEventFactories = re.sub('\s\[\[name', ',[[name', auditEventFactories)
auditEventFactories = auditEventFactories.split(',')
for auditEventFactory in auditEventFactories:
    auditEventFactoryAttributePairs = stringToList(auditEventFactory)
    for auditEventFactoryAttributePair in auditEventFactoryAttributePairs:
        if (auditEventFactoryAttributePair[0] == 'name'):
            if (auditEventFactoryAttributePair[1] == newAuditFactoryName):
                result = AdminTask.deleteAuditEventFactoryByName(
                    '[-uniqueName ' + newAuditFactoryName + ']')

print 'delete existing audit emitter ' + newAuditEmitter
auditEmitters = AdminTask.listAuditEmitters()
auditEmitters = re.sub('\n', ' ', auditEmitters)
auditEmitters = re.sub('\s\[\[name', ',[[name', auditEmitters)
auditEmitters = auditEmitters.split(',')
for auditEmitter in auditEmitters:
    auditEmitterAttributePairs = stringToList(auditEmitter)
    for auditEmitterAttributePair in auditEmitterAttributePairs:
        if (auditEmitterAttributePair[0] == 'name'):
            if (auditEmitterAttributePair[1] == newAuditEmitter):
                result = AdminTask.deleteAuditEmitterByName(
                    '[-uniqueName ' + newAuditEmitter + ']')

print 'delete existing audit filter: ' + newAuditFilterName
auditSpecifications = AdminTask.listAuditFiltersByRef().split()
for auditSpecification in auditSpecifications:
    auditFilterAttributes = AdminTask.getAuditFilter(
        '[-filterRef ' + auditSpecification + ' ]')
    auditFilterAttributePairs = stringToList(auditFilterAttributes)
    for auditFilterAttributePair in auditFilterAttributePairs:
        if (auditFilterAttributePair[0] == 'name'):
            if (auditFilterAttributePair[1] == newAuditFilterName):
                result = AdminTask.deleteAuditFilterByRef(
                    '[-filterRef ' + auditSpecification + ']')

saveConfiguration()

print 'create new audit specification ' + newAuditFilterName
auditSpecification = AdminTask.createAuditFilter(
    '[-name ' + newAuditFilterName + ' -outcome ' + newAuditFilterOutcome +
    ' -eventType ' + newAuditFilterEventType + ']')

print 'create new audit service provider ' + newAuditEmitter
auditServiceProvider = AdminTask.createBinaryEmitter(
    '[-uniqueName ' + newAuditEmitter +
    ' -className com.ibm.ws.security.audit.BinaryEmitterImpl -eventFormatterClass -fileLocation $(LOG_ROOT) -maxFileSize 100 -maxLogs 100 -wrapBehavior WRAP -auditFilters '
    + auditSpecification + ' ]')

print 'create new audit event factory ' + newAuditFactoryName
auditEventFactory = AdminTask.createAuditEventFactory(
    '[-uniqueName ' + newAuditFactoryName +
    ' -className com.ibm.ws.security.audit.AuditEventFactoryImpl -provider ' +
    auditServiceProvider + ' -auditFilters ' + auditSpecification + ' ]')

print 'create new audit notification ' + newAuditNotification
wSNotification = AdminTask.createAuditNotification(
    '[-notificationName ' + newAuditNotification +
    ' -sendEmail false -emailList  -logToSystemOut true ]')

print 'create new audit notification monitor AuditMonitor'
auditNotificationMonitor = AdminTask.createAuditNotificationMonitor(
    '[-monitorName AuditMonitor -notificationRef ' + wSNotification +
    ' -enable true ]')

print 'create new audit notification monitor ' + auditNotificationMonitor
result = AdminTask.modifyAuditNotificationMonitor(
    '[-monitorRef ' + auditNotificationMonitor + ' -notificationRef ' +
    wSNotification + ' -enable true ]')

print 'enable auditing with ' + auditorId + ' as auditor'
result = AdminTask.modifyAuditPolicy(
    '[-auditEnabled true -auditPolicy WARN -auditorId ' + auditorId +
    ' -verbose true ]')

saveConfiguration()
