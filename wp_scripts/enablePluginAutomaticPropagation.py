print "enabling automatic generation, and propagation of plugin configuration"

pluginPropertiesIds = AdminConfig.list('PluginProperties').splitlines()
for pluginPropertiesId in pluginPropertiesIds:
  result = AdminConfig.modify(pluginPropertiesId, '[[PluginGeneration "AUTOMATIC"]]')
  result = AdminConfig.modify(pluginPropertiesId, '[[PluginPropagation "AUTOMATIC"]]')

print "***** saving configuration *****"
result = AdminConfig.save()
