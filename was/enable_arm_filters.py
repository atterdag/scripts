# Set filters to true to enable the specific filter
pmiRmFilterEnable = { 'EJB': 'false', 'URI': 'false', 'JMS': 'false', 'WEB_SERVICES': 'false', 'EXTENDED': 'false', 'SOURCE_IP': 'false'}

execfile('common.py')

pmiRmFilters = AdminConfig.list('PMIRMFilter').splitlines()
for pmiRmFilter in pmiRmFilters:
  pmiRmFilterType = AdminConfig.showAttribute(pmiRmFilter, 'type')
  print 'setting Request Metrics Filter ' +  pmiRmFilterType + ' to ' + pmiRmFilterEnable.get(pmiRmFilterType)
  result = AdminConfig.modify(pmiRmFilter, '[[enable "' + pmiRmFilterEnable.get(pmiRmFilterType) + '" ]]')

synchronizeActiveNodes()
