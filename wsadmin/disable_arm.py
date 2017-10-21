import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
  if re.match('^f\s',arg):
    script_directory = java.io.File(arg.split()[1]).getParent()
    execfile( script_directory + '/common.py')

pmiRequestMetrics = AdminConfig.list('PMIRequestMetrics')
print 'disabling ARM'
result = AdminConfig.modify(pmiRequestMetrics, '[[traceLevel "HOPS"] [armTransactionFactory ""] [dynamicEnable "true"] [enable "false"] [armType "ARM40"] [enableLog "false"] [enableARM "false"]]')

synchronizeActiveNodes()
