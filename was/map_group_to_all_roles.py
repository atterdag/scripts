execfile('common.py')

def printUsage():
    print ''
    print 'Usage: $WAS_HOME/bin/wsadmin -lang jython'
    print '[-profileName profilename]'
    print '[-user username] [-password password]'
    print '-f /tmp/mapGroupToAllRoles.py'
    print '"<realm name>" "<group RDN value>" "<group DN>"'
    print '      $WAS_HOME         is the installation directory for WebSphere'
    print '                         Application Server'
    print '      profilename       is the WebSphere Application Server profile'
    print '      username          is the WebSphere Application Server'
    print '                         user'
    print '      password          is the user password'
    print '      <realm name>      is the VMM realm name'
    print '      <group RDN value> is group relative distinguished name value'
    print '      <group DN value>  is group full distinguished name'
    print ''
    print 'Sample:'
    print '===================================================================='
    print '/opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython'
    print ' -profileName Dmgr01 -user wasadmin -password passw0rd'
    print ' -f "/tmp/configureLTPA.py" "ldap.example.com:636"'
    print ' "wasadmins" "cn=wasadmins,ou=groups,o=example"'
    print '===================================================================='
    print ''

if not (len(sys.argv) == 3):
   sys.stderr.write('Invalid number of arguments\n')
   printUsage()
   sys.exit(101)

realmName = sys.argv[0]
groupID = sys.argv[1]
groupDN = sys.argv[2]

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
result = AdminTask.mapGroupsToAdminRole('[-roleName adminsecuritymanager -accessids [group:' + realmName + '/' + groupDN + '] -groupids [' + groupID + '@' + realmName + ']]')
result = AdminTask.mapGroupsToAdminRole('[-roleName administrator        -accessids [group:' + realmName + '/' + groupDN + '] -groupids [' + groupID + '@' + realmName + ']]')
result = AdminTask.mapGroupsToAuditRole('[-roleName auditor              -accessids [group:' + realmName + '/' + groupDN + '] -groupids [' + groupID + '@' + realmName + ']]')
result = AdminTask.mapGroupsToAdminRole('[-roleName iscadmins            -accessids [group:' + realmName + '/' + groupDN + '] -groupids [' + groupID + '@' + realmName + ']]')
result = AdminTask.mapGroupsToAdminRole('[-roleName configurator         -accessids [group:' + realmName + '/' + groupDN + '] -groupids [' + groupID + '@' + realmName + ']]')
result = AdminTask.mapGroupsToAdminRole('[-roleName deployer             -accessids [group:' + realmName + '/' + groupDN + '] -groupids [' + groupID + '@' + realmName + ']]')
result = AdminTask.mapGroupsToAdminRole('[-roleName monitor              -accessids [group:' + realmName + '/' + groupDN + '] -groupids [' + groupID + '@' + realmName + ']]')
result = AdminTask.mapGroupsToAdminRole('[-roleName operator             -accessids [group:' + realmName + '/' + groupDN + '] -groupids [' + groupID + '@' + realmName + ']]')

synchronizeActiveNodes()

print 'refreshing roles'
authGrpMgrDmgr = AdminControl.completeObjectName('WebSphere:type=AuthorizationGroupManager,process=dmgr,*')
result = AdminControl.invoke(authGrpMgrDmgr, 'refreshAll')
