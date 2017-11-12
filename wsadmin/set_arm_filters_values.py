import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
  if re.match('^f\s',arg):
    script_directory = java.io.File(arg.split()[1]).getParent()
    execfile( script_directory + '/common.py')

def printUsage():
  print
  print 'Usage: $WAS_HOME/bin/wsadmin -lang jython'
  print '[-profileName profilename]'
  print '[-user username] [-password password]'
  print '-f /tmp/set_arm_filters_values.py'
  print '<set|remove> <context root>'
  print '      $WAS_HOME     is the installation directory for WebSphere'
  print '                     Application Server'
  print '      profilename   is the WebSphere Application Server profile'
  print '      username      is the WebSphere Application Server user name'
  print '      password      is the WebSphere Application Server user password'
  print '      set|remove    either export, or import key'
  print '      context root  is the applicaton context root'
  print
  print 'Sample:'
  print '=============================================================================='
  print '/opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython'
  print ' -profileName Dmgr01 -user wasadmin -password passw0rd'
  print ' -f "/tmp/set_arm_filters_values.py" set "/snoop"'
  print '=============================================================================='
  print

if not (len(sys.argv) == 2):
  sys.stderr.write('Invalid number of arguments\n')
  printUsage()
  sys.exit(101)

operation=sys.argv[0]
contextRoot=sys.argv[1]

if ( operation == 'set' ):
  setPmiFilterValue('URI',contextRoot,'true')
elif ( operation == 'remove' ):
  removePmiFilterValue('URI',contextRoot)
else:
  print 'does not understand operation ' + operation

saveConfiguration()
synchronizeActiveNodes()

pmiRequestMetrics = AdminConfig.list('PMIRequestMetrics')
pmiRequestMetricsEnable = AdminConfig.showAttribute(pmiRequestMetrics, 'enable')
if pmiRequestMetricsEnable != 'true':
  print 'ARM is not enabled, please run the enable_arm_filters.py script to enable'
