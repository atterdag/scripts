execfile('common.py')

pmiRequestMetrics = AdminConfig.list('PMIRequestMetrics')
print 'disabling ARM'
result = AdminConfig.modify(pmiRequestMetrics, '[[traceLevel "HOPS"] [armTransactionFactory ""] [dynamicEnable "true"] [enable "false"] [armType "ARM40"] [enableLog "false"] [enableARM "false"]]')

synchronizeActiveNodes()
