###### STILL DEVEOPED ######
import getopt, os, re, java.io.File
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
    print '-f /tmp/create-webserver.py'
    print '--property <"key=value">'
    print '[--serverName <server name>]'
    print '[--nodeName <node name>]'
    print '      $WAS_HOME         is the installation directory for WebSphere'
    print '                         Application Server'
    print '      profilename       is the WebSphere Application Server profile'
    print '      username          is the WebSphere Application Server user'
    print '      password          is the user password'
    print '      property          property in key=value format'
    print '      serverName        the        '
    print '      managedNodeName   is the node agents maximum HEAP size in MB'
    print
    print 'Sample:'
    print '=============================================================================='
    print '/opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython'
    print ' -profileName Dmgr01 -user wasadmin -password passw0rd'
    print ' -f "/tmp/configureLTPA.py"'
    print ' --property "ibm.stream.nio=true"'
    print ' --serverName server1'
    print ' --managedNodeName was90-1Node01'
    print '=============================================================================='
    print


# sort the wsadmin sys.argv list into a tuple
optlist, args = getopt.getopt(sys.argv, 'x', [
    'property=', 'serverName=', 'managedNodeName='
])

# convert the tuple into a dict
optdict = dict(optlist)

# check for required values
if (property == ''):
    printUsage()
    print 'missing required switch'
    sys.exit(2)

def setJvmGenericArguements(nodeName, serverName, newArgument):
    existingJVMProperties = AdminTask.showJVMProperties('[-nodeName ' + nodeName + ' -serverName ' + serverName + ' -propertyName genericJvmArguments]')
    match = re.search(newArgument, existingJVMProperties)
    if not match:
        print nodeName + '/' + serverName + ' JVM arguement "' + newArgument + '" not found - adding'
        newJVMProperties = existingJVMProperties + ' ' + newArgument
        result = AdminTask.setJVMProperties('[-nodeName ' + nodeName + ' -serverName ' + serverName + ' -genericJvmArguments "' + newJVMProperties + '"]')
    else:
        print nodeName + '/' + serverName + ' JVM on arguement "' + newArgument + '" is already present - skipping'

def setJvmCustomProperties(server, jvmCustomProperties):
    print 'setting custom JVM properties on ' + server
    jvm = AdminConfig.list('JavaVirtualMachine', server)
    existingCustomJvmProperties = AdminConfig.list('Property', jvm).splitlines()
    for existingCustomJvmProperty in existingCustomJvmProperties:
        existingCustomJvmPropertyName = AdminConfig.showAttribute(existingCustomJvmProperty, 'name')
        for jvmCustomProperty in jvmCustomProperties:
            if jvmCustomProperty[0][1] == existingCustomJvmPropertyName:
                print 'removing old custom JVM property ' + existingCustomJvmPropertyName
                result = AdminConfig.remove(existingCustomJvmProperty)
    for jvmCustomProperty in jvmCustomProperties:
        print 'setting custom JVM property ' + jvmCustomProperty[0][1] + ' to value ' + jvmCustomProperty[1][1]
        AdminConfig.create('Property', jvm, jvmCustomProperty)

if nodeName == '':
    managedNodeNames = AdminTask.listManagedNodes().splitlines()
    for managedNodeName in managedNodeNames:
        applicationServers = AdminTask.listServers('[-serverType APPLICATION_SERVER -nodeName ' + managedNodeName + ']').splitlines()
        for applicationServer in applicationServers:
            applicationServerName = AdminConfig.showAttribute(applicationServer, 'name')
            if applicationServerName == serverName:
                setJvmCustomProperties(managedNodeName, serverName)
else:
    setJvmCustomProperties(managedNodeName, serverName)

AdminConfig.create('Property', jvm, '[[validationExpression ""] [name "testName"] [description "testDescription"] [value "testValue"] [required "false"]]')
setJvmCustomProperties(server,[[['name', 'com.ibm.java.diagnostics.healthcenter.agent.port'],['value', '1972']]])
setJvmGenericArguements(nodeName, serverName, '-Xhealthcenter')

saveConfiguration()

synchronizeActiveNodes()
