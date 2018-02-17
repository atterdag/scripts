import getopt
import os
import re
import java.io.File
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
    print '-f /tmp/create_db2_datasource.py'
    print '--databaseHostOne FQDN'
    print '--databasePortOne port'
    print '--databaseName name'
    print '--databaseUsername username'
    print '--databasePassword password'
    print '--databaseDriverPath directory'
    print '--applicationServerCluster name'
    print '[--databaseHadr true|false]'
    print '[--databaseHostTwo FQDN]'
    print '[--databasePortTwo port]'
    print '      $WAS_HOME                is the installation directory for WebSphere'
    print '                                Application Server'
    print '      profilename              is the WebSphere Application Server profile'
    print '      username                 is the WebSphere Application Server'
    print '                                user'
    print '      password                 is the user password'
    print '      databaseHostOne          is the FDDN of the primary database server'
    print '      databasePortOne          is the listing port of the database server'
    print '      databaseName             is the database name'
    print '      databaseUsername         is the database runtime user name'
    print '      databasePassword         is the database runtime user password'
    print '      databaseDriverPath       is the directory of the database JDBC drivers'
    print '      applicationServerCluster is the cluster name scope that the datasource'
    print '                                is created at'
    print '      databaseHadr             is set to true if using client rerouting, and'
    print '                                then set databaseHostTwo to 2nd DB host, and'
    print '                                databasePortTwo to 2nd DB port'
    print '      databaseHostTwo          is the standby database server FQDN'
    print '      databasePortTwo          is the standby database server listening port'
    print
    print 'Sample:'
    print '=============================================================================='
    print '/opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -lang jython'
    print ' -profileName Dmgr01 -user wasadmin -password passw0rd'
    print ' -f "/tmp/create_db2_datasource.py"'
    print ' --databaseHostOne db2-1.example.com'
    print ' --databasePortOne 50001'
    print ' --databaseName appdata'
    print ' --databaseUsername db2run1'
    print ' --databasePassword passw0rd'
    print ' --databaseDriverPath /opt/ibm/db2/V11.1/java'
    print ' --applicationServerCluster serverCluster'
    print ' --databaseHadr true'
    print ' --databaseHostTwo db2 - 2.example.com
    print ' --databasePortTwo 50001'
    print '=============================================================================='
    print


# sort the wsadmin sys.argv list into a tuple
optlist, args = getopt.getopt(sys.argv, 'x', [
    'databaseHostOne=',
    'databasePortOne=',
    'databaseName=',
    'databaseUsername=',
    'databasePassword=',
    'databaseDriverPath=',
    'applicationServerCluster=',
    'databaseHadr=',
    'databaseHostTwo=',
    'databasePortTwo='
])

# convert the tuple into a dict
optdict = dict(optlist)

# map the dict value into specific variables, and assign default values if no
# value specified
databaseHostOne = optdict.get('--databaseHostOne', '')
databasePortOne = optdict.get('--databasePortOne', '')
databaseName = optdict.get('--databaseName', '')
databaseUsername = optdict.get('--databaseUsername', '')
databasePassword = optdict.get('--databasePassword', '')
databaseDriverPath = optdict.get('--databaseDriverPath', '')
applicationServerCluster = optdict.get('--applicationServerCluster', '')
databaseHadr = optdict.get('--databaseHadr', 'false')
databaseHostTwo = optdict.get('--databaseHostTwo', '')
databasePortTwo = optdict.get('--databasePortTwo', '')

# check for required values
if (databaseHostOne == ''
    or databasePortOne == ''
    or databaseName == ''
    or databaseUsername == ''
    or databasePassword == ''
    or databaseDriverPath == ''
        or applicationServerCluster == ''):
    printUsage()
    print 'missing required switch'
    sys.exit(2)

newDatasourceName = databaseName + 'dbDS'
newJDBCProviderName = databaseName + 'dbJDBC_db2'
newDatasourceJAAS = databaseName + 'dbDSJAASAuth'

dataSources = AdminConfig.list('DataSource').splitlines()
for dataSource in dataSources:
    dataSourceName = AdminConfig.showAttribute(dataSource, 'name')
    if dataSourceName == newDatasourceName:
        print 'removing existing DataSources: ' + dataSourceName
        result = AdminConfig.remove(dataSource)

jDBCProviders = AdminConfig.list('JDBCProvider').splitlines()
for jDBCProvider in jDBCProviders:
    jDBCProviderName = AdminConfig.showAttribute(jDBCProvider, 'name')
    if jDBCProviderName == newJDBCProviderName:
        print 'removing existing JDBC provider: ' + jDBCProviderName
        result = AdminConfig.remove(jDBCProvider)

authDataEntries = AdminTask.listAuthDataEntries().splitlines()
for authDataEntry in authDataEntries:
    authDataEntryList = authDataEntry.split('] [')
    authDataEntryAlias = re.sub('\[\[alias ', '', authDataEntryList[0])
    if authDataEntryAlias == newDatasourceJAAS:
        print 'deleting existing conflicting JAAS entries: ' + authDataEntryAlias
        result = AdminTask.deleteAuthDataEntry(
            '[-alias ' + newDatasourceJAAS + ' ]')

synchronizeActiveNodes()

variableSubstitutionEntries = AdminConfig.list(
    'VariableSubstitutionEntry').splitlines()
for variableSubstitutionEntry in variableSubstitutionEntries:
    variableSubstitutionEntrySymbolicName = AdminConfig.showAttribute(
        variableSubstitutionEntry, 'symbolicName')
    if (variableSubstitutionEntrySymbolicName == 'DB2_JCC_DRIVER_PATH'):
        print 'found WAS variable DB2_JCC_DRIVER_PATH - setting value to ' + databaseDriverPath
        result = AdminConfig.modify(
            variableSubstitutionEntry, '[[value \"' + databaseDriverPath + '\"]]')
    if (variableSubstitutionEntrySymbolicName == 'UNIVERSAL_JDBC_DRIVER_PATH'):
        print 'found WAS variable UNIVERSAL_JDBC_DRIVER_PATH - setting value to ' + databaseDriverPath
        result = AdminConfig.modify(
            variableSubstitutionEntry, '[[value \"' + databaseDriverPath + '\"]]')
    if (variableSubstitutionEntrySymbolicName == 'DB2_JCC_DRIVER_NATIVEPATH'):
        print 'found WAS variable DB2_JCC_DRIVER_NATIVEPATH - setting value to ' + databaseDriverPath
        result = AdminConfig.modify(
            variableSubstitutionEntry, '[[value \"' + databaseDriverPath + '\"]]')

print 'creating JAAS entries'
result = AdminTask.setAdminActiveSecuritySettings(
    '[-customProperties[\"com.ibm.websphere.security.JAASAuthData.removeNodeNameGlobal=true\"]]')
result = AdminConfig.save()
result = AdminTask.createAuthDataEntry('[-alias ' + newDatasourceJAAS + ' -user ' + databaseUsername +
                                       ' -password ' + databasePassword + ' -description \"JAAS Alias for DataSource ' + newDatasourceName + '\" ]')
result = AdminTask.setAdminActiveSecuritySettings(
    '[-customProperties[\"com.ibm.websphere.security.JAASAuthData.removeNodeNameGlobal=\"]]')
result = AdminConfig.save()

print 'creating JDBCProvider'
JDBCProvider = AdminTask.createJDBCProvider('[-scope Cluster=' + applicationServerCluster + ' -databaseType DB2 -providerType \"DB2 Universal JDBC Driver Provider\" -implementationType \"XA data source\" -name ' + newJDBCProviderName +
                                            ' -description \"\" -classpath [${DB2_JCC_DRIVER_PATH}/db2jcc4.jar ${UNIVERSAL_JDBC_DRIVER_PATH}/db2jcc_license_cu.jar ${DB2_JCC_DRIVER_PATH}/db2jcc_license_cisuz.jar ${PUREQUERY_PATH}/pdq.jar ${PUREQUERY_PATH}/pdqmgmt.jar ] -nativePath [${DB2UNIVERSAL_JDBC_DRIVER_NATIVEPATH} ]]')
result = AdminConfig.save()

print 'creating DataSources'
Datasource = AdminTask.createDatasource(JDBCProvider, '[-name ' + newDatasourceName + ' -jndiName jdbc/' + newDatasourceName + ' -dataStoreHelperClassName com.ibm.websphere.rsadapter.DB2UniversalDataStoreHelper -containerManagedPersistence false -componentManagedAuthenticationAlias ' +
                                        newDatasourceJAAS + ' -xaRecoveryAuthAlias ' + newDatasourceJAAS + ' -configureResourceProperties [[databaseName java.lang.String ' + databaseName + '] [driverType java.lang.Integer 4] [serverName java.lang.String ' + databaseHostOne + '] [portNumber java.lang.Integer ' + databasePortOne + ']]]')
result = AdminConfig.create('MappingModule', Datasource,
                            '[[authDataAlias \"\"] [mappingConfigAlias DefaultPrincipalMapping]]')
result = AdminConfig.save()
dmgr = AdminControl.completeObjectName('type=DeploymentManager,*')
print 'synchronizing nodes'
result = AdminControl.invoke(dmgr, 'syncActiveNodes', '[false]')

configureDataSourceConnectionPool('/ServerCluster/' + applicationServerCluster + '/JDBCProvider/' +
                                  newJDBCProviderName + '/DataSource/' + newDatasourceName + '/', 1, 100, 30)
configureDataSourceStatementCacheSize('/ServerCluster/' + applicationServerCluster +
                                      '/JDBCProvider/' + newJDBCProviderName + '/DataSource/' + newDatasourceName + '/', 50)
if (databaseHadr == 'true'):
    configureDataSourceClientReroute('/ServerCluster/' + applicationServerCluster + '/JDBCProvider/' + newJDBCProviderName +
                                     '/DataSource/' + newDatasourceName + '/', databaseHostOne + ',' + databaseHostTwo, databasePortOne + ',' + databasePortTwo, 30, 3)

saveConfiguration()
