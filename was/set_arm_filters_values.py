import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
  if re.match('^f\s',arg):
    script_directory = java.io.File(arg.split()[1]).getParent()
    execfile( script_directory + '/common.py')

execfile('common.py')

setPmiFilterValue('URI','/snoop','true')
setPmiFilterValue('URI','/wps','true')
#removePmiFilterValue('URI','/wps')

synchronizeActiveNodes()

pmiRequestMetrics = AdminConfig.list('PMIRequestMetrics')
pmiRequestMetricsEnable = AdminConfig.showAttribute(pmiRequestMetrics, 'enable')
if pmiRequestMetricsEnable != 'true':
  print 'ARM is not enabled, please run the set_arm_filters.py script to enable'
