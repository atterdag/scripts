import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
  if re.match('^f\s',arg):
    script_directory = java.io.File(arg.split()[1]).getParent()
    execfile( script_directory + '/common.py')

webservers = AdminConfig.list('WebServer').splitlines()
for webserver in webservers:
 print 'settings HTTPS for IHS administration server: ' + webserver
 result = AdminConfig.modify(webserver, '[[webserverAdminProtocol "HTTPS"]]')

saveConfiguration()
