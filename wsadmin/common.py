print '##############################################################################'
print '# Loading common functions                                                   #'
print '##############################################################################'


def configureDataSourceClientReroute(dataSourceName, hosts, ports,
                                     retryInterval, retryCount):
    print
    print '##############################################################################'
    print '# Configuring Client Rerouting for DataSource: ' + dataSourceName
    print '##############################################################################'
    dataSourceId = AdminConfig.getid(dataSourceName)
    propertySet = AdminConfig.showAttribute(dataSourceId, 'propertySet')
    setJ2eeResourceProperty(propertySet, 'clientRerouteAlternateServerName',
                            hosts)
    setJ2eeResourceProperty(propertySet, 'clientRerouteAlternatePortNumber',
                            ports)
    setJ2eeResourceProperty(propertySet, 'retryIntervalForClientReroute',
                            retryInterval)
    setJ2eeResourceProperty(propertySet, 'maxRetriesForClientReroute',
                            retryCount)


def configureDataSourceConnectionPool(dataSourceName, minConnections,
                                      maxConnections, agedTimeout):
    print
    print '##############################################################################'
    print '# Configuring Connection Pool for DataSource: ' + dataSourceName
    print '##############################################################################'
    dataSourceId = AdminConfig.getid(dataSourceName)
    connectionPool = AdminConfig.list('ConnectionPool', dataSourceId)
    attributes = [['minConnections',
                   minConnections], ['maxConnections', maxConnections],
                  ['agedTimeout', agedTimeout]]
    result = AdminConfig.modify(connectionPool, attributes)


def configureDataSourceStatementCacheSize(dataSourceName, statementCacheSize):
    print
    print '##############################################################################'
    print '# Configuring statement cache size for DataSource: ' + dataSourceName
    print '##############################################################################'
    dataSourceId = AdminConfig.getid(dataSourceName)
    if len(dataSourceId) < 1: return
    attributes = [['statementCacheSize', statementCacheSize]]
    AdminConfig.modify(dataSourceId, attributes)


def configureHpel(server, nodeName):
    serverName = AdminConfig.showAttribute(server, 'name')
    print
    print '##############################################################################'
    print '# Enable HPEL on server ' + nodeName + '/' + serverName
    print '##############################################################################'
    RASLoggingService = AdminConfig.getid(
        '/Cell:' + cell + ' /Node:' + nodeName + '/Server:' + serverName +
        '/RASLoggingService:/')
    result = AdminConfig.modify(RASLoggingService, '[[enable false]]')
    highPerformanceExtensibleLogging = AdminConfig.getid(
        '/Cell:' + cell + '/Node:' + nodeName + '/Server:' + serverName +
        '/HighPerformanceExtensibleLogging:/')
    result = AdminConfig.modify(highPerformanceExtensibleLogging,
                                '[[enable true]]')
    hpelLog = AdminConfig.showAttribute(highPerformanceExtensibleLogging,
                                        'hpelLog')
    hpelTextLog = AdminConfig.showAttribute(highPerformanceExtensibleLogging,
                                            'hpelTextLog')
    hpelTrace = AdminConfig.showAttribute(highPerformanceExtensibleLogging,
                                          'hpelTrace')
    for log in (hpelLog, hpelTextLog, hpelTrace):
        print ' - configuring ' + log + ':'
        print '   - restart log at 12 AM'
        result = AdminConfig.modify(log, '[[fileSwitchTime 168]]')
        print '   - setting out of space action to purge old records'
        result = AdminConfig.modify(log, '[[outOfSpaceAction PurgeOld]]')
        print '   - disable purge by size'
        result = AdminConfig.modify(log, '[[purgeBySizeEnabled false]]')
        print '   - disable purge by time'
        result = AdminConfig.modify(log, '[[purgeByTimeEnabled false]]')


def configureJvmLogRotation(server):
    print
    print '##############################################################################'
    print '# Setting JVM logs to rotate every night at 00:00'
    print '##############################################################################'
    logtypes = ['outputStreamRedirect', 'errorStreamRedirect']
    for logtype in logtypes:
        log = AdminConfig.showAttribute(server, logtype)
        result = AdminConfig.modify(
            log, [['baseHour', 24], ['maxNumberOfBackupFiles', 30],
                  ['rolloverPeriod', 24], ['rolloverType', 'TIME']])
        print AdminConfig.show(log)


def configureJvmStartupTrace(server, level):
    print
    print '##############################################################################'
    print '# Setting startup trace specification for ' + server
    print '##############################################################################'
    traceService = AdminConfig.list('TraceService', server)
    result = AdminConfig.modify(traceService,
                                [['startupTraceSpecification', level]])


def configureJvmRuntimeTrace(server, level):
    print
    print '##############################################################################'
    print '# Setting runtime trace specification for ' + server
    print '##############################################################################'
    serverName = AdminConfig.showAttribute(server, 'name')
    traceServiceCompleteObjectName = AdminControl.completeObjectName(
        'type=TraceService,process=' + serverName + ',*')
    reult = AdminControl.setAttribute(traceServiceCompleteObjectName,
                                      'traceSpecification', level)


def configureTraceLog(server, number, size):
    print
    print '##############################################################################'
    print '# Setting trace file, and rotation size on ' + server
    print '##############################################################################'
    traceService = AdminConfig.list('TraceService', server)
    traceLog = AdminConfig.showAttribute(traceService, 'traceLog')
    result = AdminConfig.modify(
        traceLog, [['maxNumberOfBackupFiles', number], ['rolloverSize', size]])
    print 'show trace log settings'
    print AdminConfig.show(traceLog)


# the dict function is missing from the wsadmin jython, so we have to make our
# own
def dict(sequence):
    resultDict = {}
    for key, value in sequence:
        resultDict[key] = value
    return resultDict


def extractRepositoryIds(repositories):
    repositories = re.sub('^\{', '', repositories)
    repositories = re.sub('\}$', '', repositories)
    repositories = re.sub('}, ', '}|', repositories)
    repositoryIds = []
    for repository in repositories.split('|'):
        repositoryId, properties = repository.split('=', 1)
        repositoryIds.append(repositoryId)
    return repositoryIds


def fullSynchronizeNodes():
    print
    print '##############################################################################'
    print '# Full synchronize in background                                             #'
    print '##############################################################################'
    cell = AdminControl.getCell()
    cellCompleteobjectName = AdminControl.completeObjectName(
        'type=CellSync,cell=' + cell + ',*')
    nodes = AdminTask.listNodes().splitlines()
    for node in nodes:
        nodeCompleteObjectName = AdminControl.completeObjectName(
            'type=NodeSync,node=' + node + ',*')
        if (nodeCompleteObjectName != ''):
            nodeAgentCompleteObjectName = AdminControl.completeObjectName(
                'type=ConfigRepository,node=' + node + ',process=nodeagent,*')
            print "performing full resynchronize of " + node + ":"
            result = AdminControl.invoke(nodeCompleteObjectName, 'sync')
            result = AdminControl.invoke(nodeAgentCompleteObjectName,
                                         'refreshRepositoryEpoch')
            result = AdminControl.invoke(cellCompleteobjectName, 'syncNode',
                                         '[' + node + ']')


def listMimeTypes(type='all'):
    print
    print '##############################################################################'
    print '# Listing MIME for: ' + type
    print '##############################################################################'
    virtualHostId = AdminConfig.getid('/VirtualHost:default_host')
    mimeEntries = AdminConfig.list('MimeEntry', virtualHostId)
    for mimeEntry in mimeEntries.splitlines():
        mimeEntryType = AdminConfig.showAttribute(mimeEntry, 'type')
        if type == 'all':
            print 'type:       ' + mimeEntryType
            print 'extensions: ' + AdminConfig.showAttribute(
                mimeEntry, 'extensions')
            print '------------------------------------------------------------------------------'
        elif type == mimeEntryType:
            print 'type:       ' + mimeEntryType
            print 'extensions: ' + AdminConfig.showAttribute(
                mimeEntry, 'extensions')


def listPmiFilterValues():
    print
    print '##############################################################################'
    print '# List PMI filters values                                                    #'
    print '##############################################################################'
    pmiRmFilters = AdminConfig.list('PMIRMFilter').splitlines()
    for pmiRmFilter in pmiRmFilters:
        pmiRmFilterType = AdminConfig.showAttribute(pmiRmFilter, 'type')
        filterValues = AdminConfig.showAttribute(pmiRmFilter, 'filterValues')
        filterValues = stringToList(filterValues)
        for filterValue in filterValues[0]:
            filterValueValue = AdminConfig.showAttribute(filterValue, 'value')
            filterValueEnable = AdminConfig.showAttribute(
                filterValue, 'enable')
            print pmiRmFilterType + ', ' + filterValueValue + ', ' + filterValueEnable


def propagatePluginCfg():
    print
    print '##############################################################################'
    print '# Generating, and propagating websphere plugin configuration, and keystores  #'
    print '##############################################################################'
    nodeNames = AdminTask.listNodes().splitlines()
    for nodeName in nodeNames:
        webservers = AdminTask.listServers('[-serverType WEB_SERVER -nodeName '
                                           + nodeName + ']').splitlines()
        for webserver in webservers:
            webserverName = AdminConfig.showAttribute(webserver, 'name')
            generator = AdminControl.completeObjectName(
                'type=PluginCfgGenerator,*')
            print 'Generating plugin-cfg.xml for ' + webserverName + ' on ' + nodeName
            result = AdminControl.invoke(
                generator, 'generate',
                '/opt/IBM/WebSphere/AppServer/profiles/Dmgr01/config ' + cell +
                ' ' + nodeName + ' ' + webserverName + ' false')
            print 'Propagating plugin-cfg.xml for ' + webserverName + ' on ' + nodeName
            result = AdminControl.invoke(
                generator, 'propagate',
                '/opt/IBM/WebSphere/AppServer/profiles/Dmgr01/config ' + cell +
                ' ' + nodeName + ' ' + webserverName)
            print 'Propagating keyring for ' + webserverName + ' on ' + nodeName
            result = AdminControl.invoke(
                generator, 'propagateKeyring',
                '/opt/IBM/WebSphere/AppServer/profiles/Dmgr01/config ' + cell +
                ' ' + nodeName + ' ' + webserverName)
            webserverCON = AdminControl.completeObjectName('type=WebServer,*')


def removePmiFilterValue(type, value):
    print
    print '##############################################################################'
    print '# Removing PMI filter value ' + value + ' from type ' + type
    print '##############################################################################'
    pmiRmFilters = AdminConfig.list('PMIRMFilter').splitlines()
    for pmiRmFilter in pmiRmFilters:
        pmiRmFilterType = AdminConfig.showAttribute(pmiRmFilter, 'type')
        if pmiRmFilterType == type:
            filterValues = AdminConfig.showAttribute(pmiRmFilter,
                                                     'filterValues')
            filterValues = stringToList(filterValues)
            for filterValue in filterValues[0]:
                filterValueValue = AdminConfig.showAttribute(
                    filterValue, 'value')
                if filterValueValue == value:
                    print 'removing existing ' + type + ' filter value, ' + value
                    result = AdminConfig.remove(filterValue)
                    return
            print 'no existing ' + type + ' filter value, ' + value + ' was found'


def restartApplicationServers():
    print
    print '##############################################################################'
    print '# Restarting all application servers in foreground                           #'
    print '##############################################################################'
    nodes = AdminConfig.list('Node').splitlines()
    for node in nodes:
        nodeName = AdminConfig.showAttribute(node, 'name')
        nodeAgentCompleteObjectName = AdminControl.completeObjectName(
            'type=NodeAgent,node=' + nodeName + ',process=nodeagent,*')
        if (nodeAgentCompleteObjectName != ''):
            servers = AdminTask.listServers(
                '[-serverType APPLICATION_SERVER -nodeName ' + nodeName + ']'
            ).splitlines()
            for server in servers:
                serverName = AdminConfig.showAttribute(server, 'name')
                serverCompleteObjectName = AdminControl.completeObjectName(
                    'type=Server,node=' + nodeName + ',process=' + serverName +
                    ',*')
                if (serverCompleteObjectName != ''):
                    print 'stopping ' + nodeName + '/' + serverName
                    print AdminControl.stopServer(serverName, nodeName)
                else:
                    print nodeName + '/' + serverName + ' is already stopped'
            for server in servers:
                print 'starting ' + nodeName + '/' + serverName
                serverName = AdminConfig.showAttribute(server, 'name')
                print AdminControl.startServer(serverName, nodeName)


def rippleRestartClusters():
    cell = AdminControl.getCell()
    serverClusters = AdminConfig.list('ServerCluster').splitlines()
    for serverCluster in serverClusters:
        clusterName = AdminConfig.showAttribute(serverCluster, 'name')
        print
        print '##############################################################################'
        print '# Performing background ripple start of cluster: ' + clusterName
        print '##############################################################################'
        clusterCompleteObjectName = AdminControl.completeObjectName(
            'cell=' + cell + ',type=Cluster,name=' + clusterName + ',*')
        result = AdminControl.invoke(clusterCompleteObjectName, 'rippleStart')


def saveConfiguration():
    print
    print '***** saving configuration *****'
    result = AdminConfig.save()


def setDefaultCookieName(server, name):
    print
    print '##############################################################################'
    print '# Setting session cookie name to ' + name + ' on ' + server
    print '##############################################################################'
    cookies = AdminConfig.list('Cookie', server).splitlines()
    for cookie in cookies:
        cookieName = AdminConfig.showAttribute(cookie, 'name')
        result = AdminConfig.modify(cookie, [['name', name]])


def setHttponlyCookies(server, name):
    print
    print '##############################################################################'
    print '# Setting httponly option on ' + name + ' cookie'
    print '##############################################################################'
    wc = AdminConfig.list('WebContainer', server)
    for prop in AdminConfig.list('Property', wc).splitlines():
        if AdminConfig.showAttribute(
                prop, 'name') == 'com.ibm.ws.webcontainer.setHttponlyCookies':
            result = AdminConfig.remove(prop)
    result = AdminConfig.create(
        'Property', wc, [['validationExpression', ''], [
            'name', 'com.ibm.ws.webcontainer.setHttponlyCookies'
        ], ['description', ''], ['value', name], ['required', 'false']])


def setJ2eeResourceProperty(propertySet, name, value):
    print
    print '##############################################################################'
    print '# Setting J2EE resource property ' + name + ' on ' + propertySet
    print '##############################################################################'
    j2eeResourceProperty = AdminConfig.list('J2EEResourceProperty',
                                            propertySet)
    if len(j2eeResourceProperty) > 0:
        j2eeResourceProperty = j2eeResourceProperty.splitlines()
        for property in j2eeResourceProperty:
            found = 0
            n = AdminConfig.showAttribute(property, 'name')
            if n == name:
                result = AdminConfig.modify(property, [['value', value]])
                found = 1
                return
        if found == 0:
            result = AdminConfig.create(
                'J2EEResourceProperty', propertySet,
                [['name', name], ['type', 'java.lang.String'],
                 ['description', ''], ['value', value], ['required', 'false']])


def setJavaVirtualMachineProperty(server, property):
    print
    print '##############################################################################'
    print '# Setting JVM property on ' + server
    print '##############################################################################'
    javaVirtualMachine = AdminConfig.list('JavaVirtualMachine', server)
    AdminConfig.modify(javaVirtualMachine, property)


def setJvmGenericArguements(nodeName, serverName, newArgument):
    existingJVMProperties = AdminTask.showJVMProperties(
        '[-nodeName ' + nodeName + ' -serverName ' + serverName +
        ' -propertyName genericJvmArguments]')
    match = re.search(newArgument, existingJVMProperties)
    if not match:
        print 'adding generic JVM arguement ' + newArgument + ' on ' + nodeName + '/' + serverName
        newJVMProperties = existingJVMProperties + ' ' + newArgument
        result = AdminTask.setJVMProperties(
            '[-nodeName ' + nodeName + ' -serverName ' + serverName +
            ' -genericJvmArguments "' + newJVMProperties + '"]')
    else:
        print 'skipping existing generic JVM arguement ' + newArgument + ' on ' + nodeName + '/' + serverName


def setJvmCustomProperties(server, jvmCustomProperties):
    print 'setting custom JVM properties on ' + server
    jvm = AdminConfig.list('JavaVirtualMachine', server)
    existingCustomJvmProperties = AdminConfig.list('Property',
                                                   jvm).splitlines()
    for existingCustomJvmProperty in existingCustomJvmProperties:
        existingCustomJvmPropertyName = AdminConfig.showAttribute(
            existingCustomJvmProperty, 'name')
        for jvmCustomProperty in jvmCustomProperties:
            if jvmCustomProperty[0][1] == existingCustomJvmPropertyName:
                print 'removing old custom JVM property ' + existingCustomJvmPropertyName
                result = AdminConfig.remove(existingCustomJvmProperty)
    for jvmCustomProperty in jvmCustomProperties:
        print 'setting custom JVM property ' + jvmCustomProperty[0][1] + ' to value ' + jvmCustomProperty[1][1]
        AdminConfig.create('Property', jvm, jvmCustomProperty)


def setLtpaTimeout(timeout):
    print 'setting LTPA timeout to ' + timeout
    ltpa = AdminConfig.list('LTPA')
    AdminConfig.modify(ltpa, '[[timeout ' + timeout + ']]')


def setMimeEntry(type, extensions):
    print('adding MIME Type: ' + type)
    virtualHostId = AdminConfig.getid('/VirtualHost:default_host')
    mimeEntries = AdminConfig.list('MimeEntry', virtualHostId)
    for mimeEntry in mimeEntries.splitlines():
        mimeEntryType = AdminConfig.showAttribute(mimeEntry, 'type')
        if mimeEntryType == type:
            result = AdminConfig.modify(mimeEntry,
                                        [['extensions', extensions]])
            return
    result = AdminConfig.create('MimeEntry', virtualHostId,
                                [['type', type], ['extensions', extensions]])


def setPluginProperty(pluginProperty, name, value, description='""'):
    print
    print '##############################################################################'
    print '# Setting ' + name + ' custom property on ' + pluginProperty
    print '##############################################################################'
    existingProperties = AdminConfig.showAttribute(pluginProperty,
                                                   'properties').split()
    create = 'true'
    for existingProperty in existingProperties:
        existingProperty = re.sub('^\[', '', existingProperty)
        existingProperty = re.sub('\]$', '', existingProperty)
        if re.search(name, existingProperty):
            create = 'false'
            matchingProperty = existingProperty
    if create == 'true':
        print 'creating new plugin custom property ' + name + ' with value ' + value
        result = AdminConfig.create(
            'Property', pluginProperty,
            [['name', name], ['value', value], ['description', description],
             ['required', 'false']])
    else:
        print 'modifying existing plugin custom property ' + name + ' with value ' + value
        result = AdminConfig.modify(
            matchingProperty,
            [['name', name], ['value', value], ['description', description],
             ['required', 'false']])


def setPmiFilterValue(type, value, enable):
    pmiRmFilters = AdminConfig.list('PMIRMFilter').splitlines()
    for pmiRmFilter in pmiRmFilters:
        pmiRmFilterType = AdminConfig.showAttribute(pmiRmFilter, 'type')
        if pmiRmFilterType == type:
            filterValues = AdminConfig.showAttribute(pmiRmFilter,
                                                     'filterValues')
            filterValues = stringToList(filterValues)
            for filterValue in filterValues[0]:
                filterValueValue = AdminConfig.showAttribute(
                    filterValue, 'value')
                if filterValueValue == value:
                    print 'setting existing ' + type + ' filter value, ' + value + ', to ' + enable
                    result = AdminConfig.modify(
                        filterValue,
                        '[[enable "' + enable + '"] [value "' + value + '"]]')
                    filterExist = 'true'
                    return
            print 'creating new ' + type + ' filter value, ' + value + ', to ' + enable
            result = AdminConfig.create(
                'PMIRMFilterValue', pmiRmFilter,
                '[[enable "' + enable + '"] [value "' + value + '"]]')


def setProcessExecution(server, user, group):
    print
    print '##############################################################################'
    print '# Setting java process runtime user to ' + user + ' for ' + server
    print '##############################################################################'
    processExecution = AdminConfig.list('ProcessExecution', server)
    result = AdminConfig.modify(processExecution,
                                [['runAsUser', user], ['runAsGroup', group]])


def setSessionTuning(server, timeout, inMemorySessions):
    print
    print '##############################################################################'
    print '# Setting session timeout to ' + timeout + ' minutes and max in memory session'
    print '# count to ' + inMemorySessions + ' on ' + server
    print '##############################################################################'
    tuningParams = AdminConfig.list('TuningParams', server)
    AdminConfig.modify(tuningParams,
                       [['invalidationTimeout', timeout],
                        ['maxInMemorySessionCount', inMemorySessions]])


def setWebcontainerThreadpoolTuning(server, size):
    print
    print '##############################################################################'
    print '# Setting webcontainer thread pool                                           #'
    print '##############################################################################'
    threadPools = AdminConfig.list('ThreadPool', server).splitlines()
    for threadPool in threadPools:
        if AdminConfig.showAttribute(threadPool, 'name') == 'WebContainer':
            print 'setting web container thread pool for ' + server + ' to maximumSize ' + size
            result = AdminConfig.modify(threadPool, [['maximumSize', size]])


def startServer(name):
    print
    print '##############################################################################'
    print '# Starting application server with name: ' + name
    print '##############################################################################'
    managedNodeNames = AdminTask.listManagedNodes().splitlines()
    for managedNodeName in managedNodeNames:
        applicationServers = AdminTask.listServers(
            '[-serverType APPLICATION_SERVER -nodeName ' + managedNodeName +
            ']').splitlines()
        for applicationServer in applicationServers:
            applicationServerName = AdminConfig.showAttribute(
                applicationServer, 'name')
            if applicationServerName == name:
                print 'starting ' + applicationServerName + ' on ' + managedNodeName
                result = AdminControl.startServer(applicationServerName,
                                                  managedNodeName)
            else:
                print ''
                sys.stderr.write('!!! server name not found\n')


def stringToList(str):
    str = re.sub('^\[\[', '[', str)
    str = re.sub('\]\]$', ']', str)
    str = re.findall(r'\[([^]]*)\]', str)
    lst = []
    for strPair in str:
        lst.append(strPair.split(' '))
    return lst


def synchronizeActiveNodes():
    print
    print '##############################################################################'
    print '# Synchronizing active node in foreground                                    #'
    print '##############################################################################'
    saveConfiguration()
    dmgr = AdminControl.completeObjectName('type=DeploymentManager,*')
    nodes = AdminControl.invoke(dmgr, 'syncActiveNodes', 'true')
    print 'the following nodes have been synchronized:'
    for node in nodes.splitlines():
        print ' - ' + node


def deleteServer(managedNodeName, serverName):
    print
    print '##############################################################################'
    print '# Delete server on specified managed node                                    #'
    print '##############################################################################'
    applicationServers = AdminTask.listServers(
        '[-serverType APPLICATION_SERVER -nodeName ' + managedNodeName + ']'
    ).splitlines()
    for applicationServer in applicationServers:
        applicationServerName = AdminConfig.showAttribute(
            applicationServer, 'name')
        if applicationServerName == serverName:
            print 'stopping ' + applicationServerName + ' on ' + managedNodeName
            result = AdminControl.stopServer(applicationServerName,
                                             managedNodeName)
            print 'deleting ' + applicationServerName + ' on ' + managedNodeName
            result = AdminTask.deleteServer(
                '[-serverName ' + applicationServerName + ' -nodeName ' +
                managedNodeName + ' ]')


print '##############################################################################'
print '# Reading cell name                                                          #'
print '##############################################################################'
cell = AdminControl.getCell()
