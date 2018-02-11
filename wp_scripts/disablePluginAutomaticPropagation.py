print "disabling automatic generation, and propagation of plugin configuration"
pluginPropertiesIds = AdminConfig.list('PluginProperties').splitlines()
for pluginPropertiesId in pluginPropertiesIds:
  result = AdminConfig.modify(pluginPropertiesId, '[[PluginGeneration "MANUAL"]]')
  result = AdminConfig.modify(pluginPropertiesId, '[[PluginPropagation "MANUAL"]]')
print "***** saving configuration *****"
result = AdminConfig.save()
