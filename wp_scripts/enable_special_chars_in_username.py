def setResourceEnvironmentProviderProperty(id, name, value):
  print 'Setting resource environment provider on ' + id + ' - name: ' + name + ', value: ' + value
  j2eePropertySetId = AdminConfig.getid(id + 'J2EEResourcePropertySet//')
  j2eePropertyIds = AdminConfig.list('J2EEResourceProperty', j2eePropertySetId)
  if len(j2eePropertyIds) > 0:
    j2eePropertyIds = j2eePropertyIds.splitlines()
    for j2eePropertyId in j2eePropertyIds:
      j2eePropertyName = AdminConfig.showAttribute(j2eePropertyId, 'name')
      if j2eePropertyName == name:
        AdminConfig.modify(j2eePropertyId, [['value', value]])
        return
  AdminConfig.create('J2EEResourceProperty', j2eePropertySetId, [['name', name], ['value', value]])
setResourceEnvironmentProviderProperty('/ResourceEnvironmentProvider/WP ValidationService/', 'user.UNIQUEID.extra_chars', '-._@')
result = AdminConfig.save()
