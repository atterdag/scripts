import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
    if re.match('^f\s', arg):
        script_directory = java.io.File(arg.split()[1]).getParent()
        execfile(script_directory + '/common.py')


def printUsage():
    print ''
    print 'Usage: <profile root>/bin/wsadmin -lang jython'
    print '       [-user username] [-password password]'
    print '       -f /tmp/startServer.py'
    print '       <server name>'
    print ''


if not (len(sys.argv) == 1):
    print ''
    sys.stderr.write('missing server name arguement\n')
    printUsage()
    sys.exit(101)

startServer(sys.argv[0])
