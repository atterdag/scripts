execfile('common.py')

# List all MIME types
#listMimeTypes()

# List a specific MIME type
#listMimeTypes('video/x-motion-jpeg')

# Add/update MIME Type (multiple extensions are separate with ";" - for instance 'jpeg;jpg')
setMimeEntry('application/x-font-ttf','ttf')

saveConfiguration()
