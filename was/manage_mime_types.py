import os, re, java.io.File
command = os.environ.get('IBM_JAVA_COMMAND_LINE')
for arg in command.split(' -'):
  if re.match('^f\s',arg):
    script_directory = java.io.File(arg.split()[1]).getParent()
    execfile( script_directory + '/common.py')

# List all MIME types
#listMimeTypes()

# List a specific MIME type
#listMimeTypes('video/x-motion-jpeg')

# Add/update MIME Type (multiple extensions are separate with ";" - for instance 'jpeg;jpg')
setMimeEntry('application/x-font-ttf','ttf')

saveConfiguration()
