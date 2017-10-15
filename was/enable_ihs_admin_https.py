execfile('common.py')

webservers = AdminConfig.list('WebServer').splitlines()
for webserver in webservers:
 print 'settings HTTPS for IHS administration server: ' + webserver
 result = AdminConfig.modify(webserver, '[[webserverAdminProtocol "HTTPS"]]')

saveConfiguration()
