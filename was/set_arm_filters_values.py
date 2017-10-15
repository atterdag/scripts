import re

execfile('common.py')

setPmiFilterValue('URI','/snoop','true')
setPmiFilterValue('URI','/wps','true')
#removePmiFilterValue('URI','/wps')

synchronizeActiveNodes()

pmiRequestMetrics = AdminConfig.list('PMIRequestMetrics')
pmiRequestMetricsEnable = AdminConfig.showAttribute(pmiRequestMetrics, 'enable')
if pmiRequestMetricsEnable != 'true':
  print 'ARM is not enabled, please run the set_arm_filters.py script to enable'
