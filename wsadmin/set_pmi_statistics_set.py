import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
    if re.match('^f\s', arg):
        script_directory = java.io.File(arg.split()[1]).getParent()
        execfile(script_directory + '/common.py')


def printUsage():
    print
    print 'Usage: $WAS_HOME/bin/wsadmin -lang jython'
    print '[-profileName profilename]'
    print '[-user username] [-password password]'
    print '-f /tmp/set_pmi_statistics_set.py <set>'
    print '      $WAS_HOME     is the installation directory for WebSphere'
    print '                     Application Server'
    print '      profilename   is the WebSphere Application Server profile'
    print '      username      is the WebSphere Application Server user name'
    print '      password      is the WebSphere Application Server user password'
    print '      set           can either be "none", "basic", "extended", "all", or'
    print '                     "custom". If using "custom", then you must define the'
    print '                     specific counters manually in ISC.'
    print
    print 'Sample:'
    print '=============================================================================='
    print '/opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython'
    print ' -profileName Dmgr01 -user wasadmin -password passw0rd'
    print ' -f "/tmp/set_pmi_statistics_set.py" all'
    print '=============================================================================='
    print


if not (len(sys.argv) == 2):
    sys.stderr.write('Invalid number of arguments\n')
    printUsage()
    sys.exit(101)

statisticSet = sys.argv[0]

cell = AdminControl.getCell()
managedNodeNames = AdminTask.listManagedNodes().splitlines()
for managedNodeName in managedNodeNames:
    print 'iterating through all servers in node ' + managedNodeName
    servers = AdminTask.listServers(
        '[-serverType APPLICATION_SERVER -nodeName ' + managedNodeName + ']'
    ).splitlines()
    for server in servers:
        serverName = AdminConfig.showAttribute(server, 'name')
        print 'listing PMI services in server ' + serverName
        pmiServices = AdminConfig.list(
            'PMIService',
            AdminConfig.getid('/Cell:' + cell + '/Node:' + managedNodeName +
                              '/Server:' + serverName + '/')).splitlines()
        for pmiService in pmiServices:
            print pmiService
            print 'setting PMI statistics set to ' + statisticSet + ' on ' + managedNodeName + '/' + serverName
            result = AdminConfig.modify(
                pmiService,
                '[[synchronizedUpdate false] [enable true] [statisticSet ' +
                statisticSet + ' ]]')
        perfPrivateMBean = AdminControl.queryNames(
            'WebSphere:name=PerfPrivateMBean,node=' + managedNodeName +
            ',process=' + serverName + ',*')
        if perfPrivateMBean != '':
            result = AdminControl.invoke(perfPrivateMBean,
                                         'setSynchronizedUpdate', '[false]')
            result = AdminControl.invoke(perfPrivateMBean, 'setStatisticSetID',
                                         '[' + statisticSet + ']')

synchronizeActiveNodes()
