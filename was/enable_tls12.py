import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
  if re.match('^f\s',arg):
    script_directory = java.io.File(arg.split()[1]).getParent()
    execfile( script_directory + '/common.py')

sslConfigs = AdminTask.listSSLConfigs('[-all true -displayObjectName true ]').splitlines()
for sslConfig in sslConfigs:
  alias = AdminConfig.showAttribute(sslConfig,'alias')
  if ( alias == 'CellDefaultSSLSettings' or alias == 'NodeDefaultSSLSettings' ):
    scope = AdminConfig.showAttribute(sslConfig,'managementScope')
    scopeName = AdminConfig.showAttribute(scope,'scopeName')
    print 'changing SSL protocol to group SSL_TLSv2 for ' + alias + ' at ' + scopeName
    result = AdminTask.modifySSLConfig('[-alias ' + alias + ' -scopeName ' + scopeName + ' -sslProtocol SSL_TLSv2 ]')

synchronizeActiveNodes()
