import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
    if re.match('^f\s', arg):
        script_directory = java.io.File(arg.split()[1]).getParent()
        execfile(script_directory + '/common.py')

pluginProperties = AdminConfig.list('PluginProperties').splitlines()
for pluginProperty in pluginProperties:
    setPluginProperty(
        pluginProperty, 'UseInsecure', 'false',
        'Specifies that if you want to allow the plug-in to create unsecured connections when secure connections are defined, as was done in previous versions of Websphere Application Server, you need to create the custom property UseInsecure=true.'
    )
    setPluginProperty(
        pluginProperty, 'StrictSecurity', 'true',
        'Indicates that you want to allow the plug-in to enable security compatible with the application server FIPS SP800-131 and TLSv1.2 handshake protocol settings.'
    )

saveConfiguration()
