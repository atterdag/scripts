import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
  if re.match('^f\s',arg):
    script_directory = java.io.File(arg.split()[1]).getParent()
    execfile( script_directory + '/common.py')

databaseHostOne='db2-1.example.com'
databasePortOne='50001'
databaseName='appdata'
databaseUsername='db2run1'
databasePassword='passw0rd'
databaseDriverPath='/opt/ibm/db2/V10.5/java'
applicationServerCluster='serverCluster'
newDatasourceName=databaseName + 'dbDS'
newJDBCProviderName=databaseName + 'dbJDBC_db2'
newDatasourceJAAS=databaseName + 'dbDSJAASAuth'

# If using client rerouting, then set databaseHadr to true, databaseHostTwo
# to 2nd DB host, and databasePortTwo to 2nd DB port.
databaseHadr='false'
databaseHostTwo=''
databasePortTwo=''

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
  authDataEntryAlias = re.sub('\[\[alias ','', authDataEntryList[0])
  if authDataEntryAlias == newDatasourceJAAS:
    print 'deleting existing conflicting JAAS entries: ' + authDataEntryAlias
    result = AdminTask.deleteAuthDataEntry('[-alias ' + newDatasourceJAAS + ' ]')

synchronizeActiveNodes()

variableSubstitutionEntries = AdminConfig.list('VariableSubstitutionEntry').splitlines()
for variableSubstitutionEntry in variableSubstitutionEntries:
  variableSubstitutionEntrySymbolicName = AdminConfig.showAttribute(variableSubstitutionEntry, 'symbolicName')
  if (variableSubstitutionEntrySymbolicName == 'DB2_JCC_DRIVER_PATH'):
    print 'found WAS variable DB2_JCC_DRIVER_PATH - setting value to ' + databaseDriverPath
    result = AdminConfig.modify(variableSubstitutionEntry, '[[value \"' + databaseDriverPath + '\"]]')
  if (variableSubstitutionEntrySymbolicName == 'UNIVERSAL_JDBC_DRIVER_PATH'):
    print 'found WAS variable UNIVERSAL_JDBC_DRIVER_PATH - setting value to ' + databaseDriverPath
    result = AdminConfig.modify(variableSubstitutionEntry, '[[value \"' + databaseDriverPath + '\"]]')
  if (variableSubstitutionEntrySymbolicName == 'DB2_JCC_DRIVER_NATIVEPATH'):
    print 'found WAS variable DB2_JCC_DRIVER_NATIVEPATH - setting value to ' + databaseDriverPath
    result = AdminConfig.modify(variableSubstitutionEntry, '[[value \"' + databaseDriverPath + '\"]]')

print 'creating JAAS entries'
result = AdminTask.setAdminActiveSecuritySettings('[-customProperties[\"com.ibm.websphere.security.JAASAuthData.removeNodeNameGlobal=true\"]]')
result = AdminConfig.save()
result = AdminTask.createAuthDataEntry('[-alias ' + newDatasourceJAAS + ' -user ' + databaseUsername + ' -password ' + databasePassword + ' -description \"JAAS Alias for DataSource ' + newDatasourceName + '\" ]')
result = AdminTask.setAdminActiveSecuritySettings('[-customProperties[\"com.ibm.websphere.security.JAASAuthData.removeNodeNameGlobal=\"]]')
result = AdminConfig.save()

print 'creating JDBCProvider'
JDBCProvider = AdminTask.createJDBCProvider('[-scope Cluster=' + applicationServerCluster + ' -databaseType DB2 -providerType \"DB2 Universal JDBC Driver Provider\" -implementationType \"XA data source\" -name ' + newJDBCProviderName + ' -description \"\" -classpath [${DB2_JCC_DRIVER_PATH}/db2jcc4.jar ${UNIVERSAL_JDBC_DRIVER_PATH}/db2jcc_license_cu.jar ${DB2_JCC_DRIVER_PATH}/db2jcc_license_cisuz.jar ${PUREQUERY_PATH}/pdq.jar ${PUREQUERY_PATH}/pdqmgmt.jar ] -nativePath [${DB2UNIVERSAL_JDBC_DRIVER_NATIVEPATH} ]]')
result = AdminConfig.save()

print 'creating DataSources'
Datasource = AdminTask.createDatasource(JDBCProvider, '[-name ' + newDatasourceName + ' -jndiName jdbc/' + newDatasourceName + ' -dataStoreHelperClassName com.ibm.websphere.rsadapter.DB2UniversalDataStoreHelper -containerManagedPersistence false -componentManagedAuthenticationAlias ' + newDatasourceJAAS + ' -xaRecoveryAuthAlias ' + newDatasourceJAAS + ' -configureResourceProperties [[databaseName java.lang.String ' + databaseName + '] [driverType java.lang.Integer 4] [serverName java.lang.String ' + databaseHostOne + '] [portNumber java.lang.Integer ' + databasePortOne + ']]]')
result = AdminConfig.create('MappingModule', Datasource, '[[authDataAlias \"\"] [mappingConfigAlias DefaultPrincipalMapping]]')
result = AdminConfig.save()
dmgr = AdminControl.completeObjectName('type=DeploymentManager,*')
print 'synchronizing nodes'
result = AdminControl.invoke(dmgr, 'syncActiveNodes', '[false]')

configureDataSourceConnectionPool('/ServerCluster/' + applicationServerCluster + '/JDBCProvider/' + newJDBCProviderName + '/DataSource/' + newDatasourceName + '/', 1, 100, 30)
configureDataSourceStatementCacheSize('/ServerCluster/' + applicationServerCluster + '/JDBCProvider/' + newJDBCProviderName + '/DataSource/' + newDatasourceName + '/', 50)
if ( databaseHadr == 'true' ):
  configureDataSourceClientReroute('/ServerCluster/' + applicationServerCluster + '/JDBCProvider/' + newJDBCProviderName + '/DataSource/' + newDatasourceName + '/', databaseHostOne + ',' + databaseHostTwo, databasePortOne + ',' + databasePortTwo, 30, 3 )

saveConfiguration()
