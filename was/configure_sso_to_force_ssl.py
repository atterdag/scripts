execfile('common.py')

print "forcing single sign-on to use SSL"
result = AdminTask.configureSingleSignon('-requiresSSL true')

saveConfiguration()
