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
    print '--sessionMaximum number'
    print '[--sessionTimeout seconds]'
    print '[--threadpoolWebContainer number]'
    print '[--transactionLifetimeTimeout seconds]'
    print '      $WAS_HOME         is the installation directory for WebSphere'
    print '                         Application Server'
    print '      profilename       is the WebSphere Application Server profile'
    print '      username          is the WebSphere Application Server'
    print '                         user'
    print '      password          is the user password'
    print '      sessionMaximum    is the maximum number of concurrent sessions'
    print '      sessionTimeout    is the how long a session lasts'
    print '      threadpoolWebContainer is the amount of allowed web container threads'
    print '      transactionLifetimeTimeout is the transaction timeout time'
    print
    print 'Sample:'
    print '=============================================================================='
    print '/opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython'
    print ' -profileName Dmgr01 -user wasadmin -password passw0rd'
    print ' -f "/tmp/configureLTPA.py"'
    print ' --sessionMaximum 10000'
    print ' --sessionTimeout 10'
    print ' --threadpoolWebContainer 50'
    print ' --transactionLifetimeTimeout 600'
    print '=============================================================================='
    print


# sort the wsadmin sys.argv list into a tuple
optlist, args = getopt.getopt(sys.argv, 'x', [
    'sessionMaximum=', 'sessionTimeout=', 'threadpoolWebContainer=',
    'transactionLifetimeTimeout='
])

# convert the tuple into a dict
optdict = dict(optlist)

# map the dict value into specific variables, and assign default values if no
# value specified
sessionMaximum = optdict.get('--sessionMaximum', '')
sessionTimeout = optdict.get('--sessionTimeout', '30')
threadpoolWebContainer = optdict.get('--threadpoolWebContainer', '50')
transactionLifetimeTimeout = optdict.get('--transactionLifetimeTimeout', '600')

# check for required values
if (sessionMaximum == ''):
    printUsage()
    print 'missing required switch'
    sys.exit(2)

nodes = AdminConfig.list('Node').splitlines()
for node in nodes:
    nodeName = AdminConfig.showAttribute(node, 'name')
    print 'iterating through all servers in node ' + nodeName
    servers = AdminTask.listServers(
        '[-serverType APPLICATION_SERVER -nodeName ' + nodeName + ']'
    ).splitlines()
    for server in servers:
        setSessionTuning(server, sessionTimeout, sessionMaximum)
        setWebcontainerThreadpoolTuning(server, threadpoolWebContainer)
        print 'enabling starting WAS components as needed on ' + server
        result = AdminConfig.modify(server, '[[provisionComponents true]]')
        print 'enabling servlet caching on ' + server
        result = AdminConfig.modify(
            AdminConfig.list('WebContainer', server),
            '[[enableServletCaching true]]')
        print 'enabling portlet fragment caching on ' + server
        result = AdminConfig.modify(
            AdminConfig.list('PortletContainer', server),
            '[[enablePortletCaching true]]')
        print 'setting transaction timeout to ' + transactionLifetimeTimeout + ' on ' + server
        result = AdminConfig.modify(
            AdminConfig.list('TransactionService', server),
            '[[totalTranLifetimeTimeout ' + transactionLifetimeTimeout + ']]')

setLtpaTimeout(sessionTimeout)

saveConfiguration()
