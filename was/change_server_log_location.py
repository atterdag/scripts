rootLogDirectory = '/var/log/was'

execfile('common.py')

cell = AdminControl.getCell()
nodes = AdminTask.listNodes().splitlines()
for node in nodes:
  nodeId = AdminConfig.getid('/Node:' + node + '/')
  variableSubstitutionEntries = AdminConfig.list('VariableSubstitutionEntry',nodeId).splitlines()
  variableSubstitutionEntryNameFound = 'false'
  for variableSubstitutionEntry in variableSubstitutionEntries:
    variableSubstitutionEntryName = AdminConfig.showAttribute(variableSubstitutionEntry, 'symbolicName')
    if variableSubstitutionEntryName == 'WAS_NODE_NAME':
      variableSubstitutionEntryNameFound = 'true'
    if variableSubstitutionEntryName == 'LOG_ROOT':
      print 'Modifying variable: ' + variableSubstitutionEntryName + ', value: ' + rootLogDirectory + '/\${WAS_CELL_NAME}/\${WAS_NODE_NAME} on node: ' + node
      result = AdminConfig.modify(variableSubstitutionEntry, [['value', rootLogDirectory + '/\${WAS_CELL_NAME}/\${WAS_NODE_NAME}']])
    if variableSubstitutionEntryName == 'SERVER_LOG_ROOT':
      print 'Modifying variable: ' + variableSubstitutionEntryName + ', value: \${LOG_ROOT}/\${WAS_SERVER_NAME} on node: ' + node
      result = AdminConfig.modify(variableSubstitutionEntry, [['value', '\${LOG_ROOT}/\${WAS_SERVER_NAME}']])
  print "ensuring that all nodes have a WAS_NODE_NAME variable"
  if variableSubstitutionEntryNameFound == 'false':
    print "creating variable WAS_NODE_NAME=" + node
    result = AdminConfig.create('VariableSubstitutionEntry', '(cells/' + cell + '/node/' + node + '|variables.xml#VariableMap_1)', '[[symbolicName "WAS_NODE_NAME"] [value "' + node + '"]]')

saveConfiguration()
