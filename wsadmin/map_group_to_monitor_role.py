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
  print '-f /tmp/map_group_to_monitor_role.py'
  print '"<realm name>" "<group RDN value>" "<group DN>"'
  print '      $WAS_HOME         is the installation directory for WebSphere'
  print '                         Application Server'
  print '      profilename       is the WebSphere Application Server profile'
  print '      username          is the WebSphere Application Server user name'
  print '      password          is the WebSphere Application Server user password'
  print '      realm name        is the VMM realm name'
  print '      group RDN value   is group relative distinguished name value'
  print '      group DN value    is group full distinguished name'
  print
  print 'Sample:'
  print '=============================================================================='
  print '/opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython'
  print ' -profileName Dmgr01 -user wasadmin -password passw0rd'
  print ' -f "/tmp/map_group_to_monitor_role.py"'
  print ' "wasmonitors" "cn=wasmonitors,ou=groups,o=example"'
  print '=============================================================================='
  print

if not (len(sys.argv) == 2):
  sys.stderr.write('Invalid number of arguments\n')
  printUsage()
  sys.exit(101)

groupID = sys.argv[0]
groupDN = sys.argv[1]
realmName = AdminTask.getIdMgrDefaultRealm()

print '##############################################################################'
print '# Removing ' + groupID + ' from any existing mappings'
print '##############################################################################'
print
groups = AdminConfig.list('GroupExt')
if len(groups) > 0:
  groups = groups.splitlines()
  for group in groups:
    groupName = AdminConfig.showAttribute(group, 'name')
    if groupName == groupID + '@' + realmName:
      print 'removing ' + groupName
      result = AdminConfig.remove(group)

print '##############################################################################'
print '# Mapping group ' + groupID + ' to admin console roles'
print '##############################################################################'
result = AdminTask.mapGroupsToAdminRole('[-roleName monitor              -accessids [group:' + realmName + '/' + groupDN + '] -groupids [' + groupID + '@' + realmName + ']]')

synchronizeActiveNodes()

print 'refreshing roles'
authGrpMgrDmgr = AdminControl.completeObjectName('WebSphere:type=AuthorizationGroupManager,process=dmgr,*')
result = AdminControl.invoke(authGrpMgrDmgr, 'refreshAll')
