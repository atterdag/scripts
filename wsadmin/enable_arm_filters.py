import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
    if re.match('^f\s', arg):
        script_directory = java.io.File(arg.split()[1]).getParent()
        execfile(script_directory + '/common.py')

# Set filters to true to enable the specific filter
pmiRmFilterEnable = {
    'EJB': 'false',
    'URI': 'false',
    'JMS': 'false',
    'WEB_SERVICES': 'false',
    'EXTENDED': 'false',
    'SOURCE_IP': 'false'
}

pmiRmFilters = AdminConfig.list('PMIRMFilter').splitlines()
for pmiRmFilter in pmiRmFilters:
    pmiRmFilterType = AdminConfig.showAttribute(pmiRmFilter, 'type')
    print 'setting Request Metrics Filter ' + pmiRmFilterType + ' to ' + pmiRmFilterEnable.get(
        pmiRmFilterType)
    result = AdminConfig.modify(
        pmiRmFilter,
        '[[enable "' + pmiRmFilterEnable.get(pmiRmFilterType) + '" ]]')

synchronizeActiveNodes()
