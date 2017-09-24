def printUsage():
    print ''
    print 'Usage: $WAS_HOME/bin/wsadmin -lang jython'
    print '[-profileName profilename]'
    print '[-user username] [-password password]'
    print '-f /tmp/manageLTPAKeys.py'
    print '<export|import> LTPAKeyFile keyPassword'
    print '      $WAS_HOME     is the installation directory for WebSphere'
    print '                     Application Server'
    print '      profilename   is the WebSphere Application Server profile'
    print '      username      is the WebSphere Application Server'
    print '                     user'
    print '      password      is the user password'
    print '      export|import either export, or import key'
    print '      LTPAKeyFile   is the file from which you are'
    print '                     importing the LTPA keys'
    print '      keyPassword   is the password that was used to'
    print '                     encrypt the keys'
    print ''
    print 'Sample:'
    print '===================================================================='
    print '/opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython'
    print ' -profileName Dmgr01 -user wasadmin -password passw0rd' 
    print ' -f \"/tmp/manageLTPAKeys.py\" \"/tmp/example-ltpa.key\"  \"passw0rd\"'
    print '===================================================================='
    print ''

if not (len(sys.argv) == 3):
   sys.stderr.write('Invalid number of arguments\n')
   printUsage()
   sys.exit(101)

operation=sys.argv[0]
filename=sys.argv[1]
password=sys.argv[2]

if ( operation == 'export' ):
  result = AdminTask.exportLTPAKeys('-ltpaKeyFile ' + filename + ' -password ' + password)
elif ( operation == 'import' ):
  result = AdminTask.importLTPAKeys('-ltpaKeyFile ' + filename + ' -password ' + password)
else:
  print 'does not understand operation ' + operation

print '===================================================='
print 'LTPA key have successfully been ' + operation + 'ed!'
print '===================================================='
