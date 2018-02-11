import java.lang.String as jstr
import java.util.Properties as jprops
import java.io as jio
import javax.management as jmgmt

def printUsage():
    print ""
    print "Usage: install_root/bin/wsadmin -lang jython"
    print "[-user username] [-password password]"
    print "-f /tmp/importLTPAKeys.py LTPAKeyFile key_password"
    print "where install_root is the root directory for WebSphere"
    print "                    Application Server"
    print "      username     is the WebSphere Application Server"
    print "                    user"
    print "      password     is the user password"
    print "      LTPAKeyFile  is the file from which you are"
    print "                    importing the LTPA keys"
    print "      key_password is the password that was used to"
    print "                    encrypt the keys"
    print ""
    print "Sample:"
    print "===================================================================="
    print "wsadmin -lang jython -user tipadmin -password admin123" 
    print " -f \"/tmp/importLTPAKeys.py\" \"/tmp/ltpakeys.txt\" admin123"
    print "===================================================================="
    print ""

# Verify that the correct number of parameters exist
if not (len(sys.argv) == 2):
   sys.stderr.write("Invalid number of arguments\n")
   printUsage()
   sys.exit(101)

password=jstr(sys.argv[1]).getBytes()

security=AdminControl.queryNames( 'process=dmgr,type=SecurityAdmin,*' )

securityON=jmgmt.ObjectName(security)

fin=jio.FileInputStream(sys.argv[0])
ltpaKeys=jprops()
ltpaKeys.load(fin)
fin.close()

params=[ltpaKeys, password]
signature=['java.util.Properties', '[B']

AdminControl.invoke_jmx(securityON,'importLTPAKeys', params, signature)
