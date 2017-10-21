cat > /opt/IBM/HTTPServer/conf/httpd.conf.include << EOF
LoadModule deflate_module modules/mod_deflate.so
LoadModule expires_module modules/mod_expires.so
LoadModule headers_module modules/mod_headers.so
LoadModule ibm_ssl_module modules/mod_ibm_ssl.so
LoadModule rewrite_module modules/mod_rewrite.so

# worker MPM
#
# For tuning recommendations, refer to <NEWINFOCENTERURL>.
#
# ThreadLimit: maximum setting of ThreadsPerChild
# ServerLimit: maximum setting of StartServers
# StartServers: initial number of server processes to start
# MaxClients: maximum number of simultaneous client connections
# MinSpareThreads: minimum number of worker threads which are kept spare
# MaxSpareThreads: maximum number of worker threads which are kept spare
# ThreadsPerChild: constant number of worker threads in each server process
# MaxRequestsPerChild: maximum number of requests a server process serves
<IfModule worker.c>
  ThreadLimit        100
  ServerLimit       1000
  StartServers        50
  MaxClients       10000
  MinSpareThreads     25
  MaxSpareThreads     75
  ThreadsPerChild     25
  MaxRequestsPerChild  0
</IfModule>

#
# ServerAdmin: Your address, where problems with the server should be
# e-mailed.  This address appears on some server-generated pages, such
# as error documents.  e.g. admin@your-domain.com
#
ServerAdmin webmaster@example.com

#
# ServerTokens
# This directive configures what you return as the Server HTTP response
# Header. The built-in default is 'Full' which sends information about
# the OS-type and compiled in modules.  The recommended value is 'Prod'
# which sends the least information.
# Set to one of:  Full | OS | Minor | Minimal | Major | Prod
# where Full conveys the most information, and Prod the least.
#
ServerTokens Prod

#
# Optionally add a line containing the server version and virtual host
# name to server-generated pages (internal error documents, FTP directory
# listings, mod_status and mod_info output etc., but not CGI generated
# documents or custom error documents).
# Set to "EMail" to also include a mailto: link to the ServerAdmin.
# Set to one of:  On | Off | EMail
#
ServerSignature Off

#
# The AllowEncodedSlashes directive allows URLs which contain encoded
# path separators (%2F for / and additionally %5C for \ on according
# systems) to be used. Normally such URLs are refused with a 404 (Not
# found) error.
AllowEncodedSlashes On

#
# Action lets you define media types that will execute a script whenever
# a matching file is called. This eliminates the need for repeated URL
# pathnames for oft-used CGI file processors.
# Format: Action media/type /cgi-script/location
# Format: Action handler-name /cgi-script/location
#

#
# Customizable error responses come in three flavors:
# 1) plain text 2) local redirects 3) external redirects
#
# Some examples:
#ErrorDocument 500 "The server made a boo boo."
#ErrorDocument 404 /missing.html
#ErrorDocument 404 "/cgi-bin/missing_handler.pl"
#ErrorDocument 402 http://www.example.com/subscription_info.html
#
ErrorDocument 500 /500.html

#
# IBM standard configurations and optimizations - picked up from various IBM
# documentations.
#

# SSL Configuration
<IfModule mod_ibm_ssl.c>
  Listen 0.0.0.0:443
  <VirtualHost *:443>
    ServerName $HOSTNAME.example.com
    #DocumentRoot htdocs

    # Enable SSL for this VirtualHost - duh!
    SSLEnable

    # Use the FIPS 140-2 validated cryptographic modules and ciphers 
    # available in the bundled GSKit library.
    SSLFIPSEnable

    # Only allow TLSv1.2
    SSLProtocolEnable TLSv12

    # And disable all other SSL protocols
    SSLProtocolDisable SSLv2 SSLv3 TLSv1 TLSv11

    # First allow all ciphers, and then later disallow specified
    SSLCipherSpec TLSv12
  </VirtualHost>

  # Disable all SSL from here on
  SSLDisable

  # Define the server configuration default certificate
  SSLServerCert $HOSTNAME.example.com

  # Server configuration default keystore
  Keyfile "/opt/IBM/HTTPServer/conf/$HOSTNAME.example.com.kdb"

  # Default keystore stash file
  SSLStashFile "/opt/IBM/HTTPServer/conf/$HOSTNAME.example.com.sth"
</IfModule>

# Adjust expire time on static elements
<IfModule mod_expires.c>
  # Adjust the expiry period on cached files by adding the following rules
  ExpiresActive On
  <LocationMatch  /*/(nav|static|common/styles|images)/ >
    ExpiresByType application/x-javascript "access plus 1 day"
    ExpiresByType application/javascript "access plus 1 day"
    ExpiresByType text/javascript "access plus 1 day"
    ExpiresByType text/css "access plus 1 day"
    ExpiresByType text/plain "access plus 1 day"
    ExpiresByType text/xsl "access plus 1 day"
    ExpiresByType image/gif "access plus 1 day"
    ExpiresByType image/jpeg "access plus 1 day"
    ExpiresByType image/png "access plus 1 day"
    ExpiresByType image/bmp "access plus 1 day"
    ExpiresByType image/icon "access plus 1 day"
  </LocationMatch>
</IfModule>

# Enable compression of static elements
<IfModule mod_deflate.c>
  setOutputFilter DEFLATE

  # Add the following statements to compress multiple content types used by
  # Lotus® Connections
  # Only the specified MIME types will be compressed.

  AddOutputFilterByType DEFLATE text/html
  AddOutputFilterByType DEFLATE application/xhtml+xml
  AddOutputFilterByType DEFLATE text/plain text/xml
  AddOutputFilterByType DEFLATE application/x-javascript
  AddOutputFilterByType DEFLATE text/css text/javascript
  AddOutputFilterByType DEFLATE application/xml
  AddOutputFilterByType DEFLATE application/atom+xml
  AddOutputFilterByType DEFLATE text/javascript

  # Add the following statement to compress binary content downloaded from
  # Activities to work around a Microsoft Internet Explorer 6 issue with some
  # binary content

  # Add the following statements to specifically indicate that only text/html
  # content should be compressed for older browsers. Uncomment the final line if
  # your environment includes support for Microsoft Internet Explorer 6 SP1 or
  # if you experience web browser hangs or other issues with Microsoft Internet
  # Explorer 6 releases after SP1.
  # Ensure that only text/html content is compressed for older browsers

  BrowserMatch ^Mozilla/4 gzip-only-text/html
  BrowserMatch ^Mozilla/4\.0[678] no-gzip
  BrowserMatch \bMSIE !no-gzip !gzip-only-text/html

  # Uncomment the following line if you encounter freezing issues with Internet Explorer 6
  #BrowserMatch \bMSIE\s6.0 gzip-only-text/html

  # Add the following statement to specifically indicate that image files and
  # binaries must not be compressed to prevent Web browser hangs
  # Ensures that images and executable binaries are not compressed
  SetEnvIfNoCase Request_URI \.(?:gif|jpe?g|png|exe)$ no-gzip dont-vary
</IfModule>

# Enable compression of static elements -- CONTINUED
<IfModule mod_deflate.c>
  # Add the following statement to ensure that proxy servers do not modify the
  # User Agent header needed by the above statements
  # Make sure proxies do not deliver the wrong content
  Header append Vary User-Agent env=!dont-vary
</IfModule>

# Change logout URLs to point to TAM/WS logout URL
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteCond %{REQUEST_URI} /(.*)/ibm_security_logout(.*)
  RewriteCond %{QUERY_STRING} !=logoutExitPage=http://w3.example.com/ihs-index.html
  RewriteRule /(.*)/ibm_security_logout(.*) //ibm_security_logout?logoutExitPage=http://$HOSTNAME.example.com/ihs-index.html [noescape,L,R]
</IfModule>
EOF
echo "Include conf/httpd.conf.include" >> /opt/IBM/HTTPServer/conf/httpd.conf
