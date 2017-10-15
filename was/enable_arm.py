execfile('common.py')

pmiRequestMetrics = AdminConfig.list('PMIRequestMetrics')
print 'enabling ARM, and setting destination to standard logs'
result = AdminConfig.modify(pmiRequestMetrics, '[[traceLevel "HOPS"] [armTransactionFactory ""] [dynamicEnable "true"] [enable "true"] [armType "ARM40"] [enableLog "true"] [enableARM "true"]]')

synchronizeActiveNodes()
