auditLogFileName = 'logs/WebSphere_Portal/wp_audit_$CREATE_TIME.log'

def setResourceEnvironmentProviderProperty(id, name, value):
  print 'Setting resource environment provider custom property, ' + id + ' - name: ' + name + ', value: ' + value
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
setResourceEnvironmentProviderProperty('/ResourceEnvironmentProvider/WP AuditService/', 'audit.service.enable', 'true')
setResourceEnvironmentProviderProperty('/ResourceEnvironmentProvider/WP AuditService/', 'audit.logging.class', 'com.ibm.wps.services.audit.logging.impl.AuditLoggingImpl')
setResourceEnvironmentProviderProperty('/ResourceEnvironmentProvider/WP AuditService/', 'audit.logFileName',auditLogFileName)
setResourceEnvironmentProviderProperty('/ResourceEnvironmentProvider/WP AuditService/', 'audit.showTransactionID.enable', 'true')
setResourceEnvironmentProviderProperty('/ResourceEnvironmentProvider/WP AuditService/', 'audit.projects.enable', 'true')
setResourceEnvironmentProviderProperty('/ResourceEnvironmentProvider/WP AuditService/', 'audit.groupEvents.enable', 'true')
setResourceEnvironmentProviderProperty('/ResourceEnvironmentProvider/WP AuditService/', 'audit.userEvents.enable', 'true')
setResourceEnvironmentProviderProperty('/ResourceEnvironmentProvider/WP AuditService/', 'audit.portletEvents.enable', 'true')
setResourceEnvironmentProviderProperty('/ResourceEnvironmentProvider/WP AuditService/', 'audit.roleEvents.enable', 'true')
setResourceEnvironmentProviderProperty('/ResourceEnvironmentProvider/WP AuditService/', 'audit.roleBlockEvents.enable', 'true')
setResourceEnvironmentProviderProperty('/ResourceEnvironmentProvider/WP AuditService/', 'audit.ownerEvents.enable', 'true')
setResourceEnvironmentProviderProperty('/ResourceEnvironmentProvider/WP AuditService/', 'audit.resourceEvents.enable', 'false')
setResourceEnvironmentProviderProperty('/ResourceEnvironmentProvider/WP AuditService/', 'audit.externalizationEvents.enable', 'false')
setResourceEnvironmentProviderProperty('/ResourceEnvironmentProvider/WP AuditService/', 'audit.userInGroupEvents.enable', 'true')
setResourceEnvironmentProviderProperty('/ResourceEnvironmentProvider/WP AuditService/', 'audit.webModuleEvents.enable', 'false')
setResourceEnvironmentProviderProperty('/ResourceEnvironmentProvider/WP AuditService/', 'audit.domainAdminDataEvents.enable', 'true')
setResourceEnvironmentProviderProperty('/ResourceEnvironmentProvider/WP AuditService/', 'audit.designerDeployServiceEvents.enable', 'false')
setResourceEnvironmentProviderProperty('/ResourceEnvironmentProvider/WP AuditService/', 'audit.impersonationEvents.enable', 'true')
setResourceEnvironmentProviderProperty('/ResourceEnvironmentProvider/WP AuditService/', 'audit.taggingEvents.enable', 'false')
setResourceEnvironmentProviderProperty('/ResourceEnvironmentProvider/WP AuditService/', 'audit.ratingEvents.enable', 'false')
setResourceEnvironmentProviderProperty('/ResourceEnvironmentProvider/WP AuditService/', 'audit.projectPublishEvents.enable', 'false')
setResourceEnvironmentProviderProperty('/ResourceEnvironmentProvider/WP AuditService/', 'audit.customevents', 'com.ibm.workplace.wcm.services.editions.EditionsAuditLogger')
setResourceEnvironmentProviderProperty('/ResourceEnvironmentProvider/WP AuditService/', 'audit.vanityURLEvents.enable', 'false')
result = AdminConfig.save()
