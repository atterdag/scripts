#!/bin/sh
cat > /tmp/wctcmdpp.sh << EOF
#!/bin/sh

USAGE="Usage: \$0 -defLocPathname  -defLocName  -response ";

if [ "\$3" = "" ]; then
    echo \$USAGE;
    exit 1
fi

ARGS=\$(getopt --alternative --options p:n:r:h --longoptions 'defLocPathname:,defLocName:,response:,help' --name wctcmdpp.sh -- "\$@");

echo "reading command line arguments"

eval set -- "\$ARGS";

while true; do
  case "\$1" in
    -p|--defLocPathname)
      shift;
      if [ -d \$1 ]; then
        if [ -n "\$1" ]; then
          defLocPathname=\$1;
          shift;
        fi
      else
       echo "\$1 not found"
       exit 1
      fi
      ;;
    -n|--defLocName)
      shift;
      if [ -n \$1 ]; then
        defLocName=\$1;
        shift;
      fi
      ;;
    -r|--response)
      shift;
      if [ -f \$1 ]; then
        if [ -n "\$1" ]; then
          response=\$1;
          shift;
        fi
      else
       echo "\$1 not found"
       exit 1
      fi
      ;;
    -h|--help)
      echo \$USAGE;
      exit 1
      ;;
    --)
      shift;
      break;
      ;;
    esac
done

echo "reading in properties from:               \$response"
. \$response

IHS_CONF_DIR=\$(dirname \$webServerConfigFile1)
SERVERROOT=\$(dirname \$IHS_CONF_DIR)

echo "PLG installation directory:               \$defLocPathname"
echo "webserver PLG configuration directory:    \$defLocName"
echo "identified IHS installation directory as: \${SERVERROOT}"

echo "------------------------------------------------------------------------------"
echo "starting IHS configuration:"
for file in {bin/apachectl,bin/apu-1-config,bin/apr-1-config,bin/apxs,bin/dbmmanage,bin/envvars-std,bin/gsk_envvars,bin/gskcapicmd,bin/gskcmd,bin/gskver,bin/ikeyman,bin/setupadm,build/apr_rules.mk,build/config_vars.mk,conf/httpd.conf.default,lib/libaprutil-1.la,lib/libapr-1.la,bin/adminctl,conf/admin.conf.default}; do
  echo "updating variables for file:              \${SERVERROOT}/\$file"
  sed -i "s|@@ServerRoot@@|\${SERVERROOT}|g" \${SERVERROOT}/\$file
  sed -i "s|@@SERVERROOT@@|\${SERVERROOT}|g" \${SERVERROOT}/\$file
  sed -i "s|@@PERL@@|`which perl`|g" \${SERVERROOT}/\$file
  sed -i "s|@@JAVADIR@@|\${SERVERROOT}/java/jre|g" \${SERVERROOT}/\$file
  sed -i "s|@@GSK7LIBDIR@@|\${SERVERROOT}/gsk8/lib64|g" \${SERVERROOT}/\$file
  sed -i "s|@@SHLIBPATH_ENVAR@@|LD_LIBRARY_PATH|g" \${SERVERROOT}/\$file
  sed -i "s|@@Port@@|\$webServerPortNumber|g" \${SERVERROOT}/\$file
  sed -i "s|@@User@@|nobody|g" \${SERVERROOT}/\$file
  sed -i "s|@@Group@@|nobody|g" \${SERVERROOT}/\$file
  sed -i "s|@@ServerName@@|\${HOSTNAME}|g" \${SERVERROOT}/\$file
  sed -i "s|@@AdminPort@@|\$ihsAdminPort|g" \${SERVERROOT}/\$file
done

echo "creating environment variables file:      \${SERVERROOT}/bin/envvars"
cp \${SERVERROOT}/bin/envvars-std \${SERVERROOT}/bin/envvars

echo "creating IHS configuration file:          \${SERVERROOT}/conf/httpd.conf"
cp \${SERVERROOT}/conf/httpd.conf.default \${SERVERROOT}/conf/httpd.conf

echo "creating MIME types file:                 \${SERVERROOT}/conf/mime.types"
cp \${SERVERROOT}/conf/mime.types.default \${SERVERROOT}/conf/mime.types

echo "creating directory:                       \${SERVERROOT}/cgi-bin"
mkdir \${SERVERROOT}/cgi-bin

echo "------------------------------------------------------------------------------"
echo "creating PLG configuration"

echo "creating configuration directory:         \$webServerDefinition"
cp -r \${defLocPathname}/config/templates \$defLocName

echo "adding PLG module, and configuration to IHS config file"
cat >> \${SERVERROOT}/conf/httpd.conf << EOT

LoadModule was_ap22_module \${defLocPathname}/bin/\${webServerInstallArch}bits/mod_was_ap22_http.so
WebSpherePluginConfig \${defLocName}/plugin-cfg.xml

EOT

if [ "\$enableAdminServerSupport" == "true" ]; then
  echo "------------------------------------------------------------------------------"
  echo "starting IHS Administration Server configuration"
  
  if [ "\$ihsAdminCreateUserAndGroup" == "true" ]; then
    echo "creating IHS AdminServer runtime group:   \$ihsAdminUnixUserGroup"
    groupadd \$ihsAdminUnixUserGroup
    
    echo "creating IHS AdminServer  runtime user:   \$ihsAdminUnixUserID"
    useradd -s /bin/false -g \$ihsAdminUnixUserGroup \$ihsAdminUnixUserID
  fi

  echo "creating IHS AdminServer config file:     \${SERVERROOT}/conf/admin.conf"
  cp \${SERVERROOT}/conf/admin.conf.default \${SERVERROOT}/conf/admin.conf

  echo "creating IHS AdminServer web admin user:  \$ihsAdminUserID"
  \${SERVERROOT}/bin/htpasswd -cmb /opt/IBM/HTTPServer/conf/admin.passwd \$ihsAdminUserID \$ihsAdminPassword

  echo "------------------------------------------------------------------------------"
  echo "finalizing IHS, and IHS Administration Server configuration"
  \${SERVERROOT}/bin/setupadm \\
  -usr \$ihsAdminUnixUserID \\
  -grp \$ihsAdminUnixUserGroup \\
  -cfg \${SERVERROOT}/conf/httpd.conf \\
  -plg \${defLocName}/plugin-cfg.xml \\
  -adm \${SERVERROOT}/conf/admin.conf
else
  echo "------------------------------------------------------------------------------"
  echo "skipping IHS Administration Server configuration"

  echo "------------------------------------------------------------------------------"
  echo "finalizing IHS configuration"
  \${SERVERROOT}/bin/setupadm \\
  -usr \$ihsAdminUnixUserID \\
  -grp $ihsAdminUnixUserGroup \\
  -cfg ${SERVERROOT}/conf/httpd.conf \\
  -plg \${defLocName}/plugin-cfg.xml
fi

echo "------------------------------------------------------------------------------"
echo "finalizing PLG configuration"
echo "allowing read/write to PLG dir to group:  \$ihsAdminUnixUserGroup"
chmod -R g+w \${defLocName}
chgrp -R ihs \${defLocName}

echo "creating response file:                   \${defLocName}/\${webServerDefinition}.responseFile"

cat > \${defLocName}/\${webServerDefinition}.responseFile << RESPONSFILE_END
configType=\$configType
defLocPathname=\$defLocPathname
enableAdminServerSupport=\$enableAdminServerSupport
enableUserAndPass=\$enableUserAndPass
enableWinService=\$enableWinService
ihsAdminCreateUserAndGroup=\$ihsAdminCreateUserAndGroup
ihsAdminPassword=\$ihsAdminPassword
ihsAdminPort=\$ihsAdminPort
ihsAdminUnixUserGroup=\$ihsAdminUnixUserGroup
ihsAdminUnixUserID=\$ihsAdminUnixUserID
ihsAdminUserGroup=\$ihsAdminUserGroup
ihsAdminUserID=\$ihsAdminUserID
mapWebServerToApplications=\$mapWebServerToApplications
profilePath=\$defLocPathname/profiles/
wasMachineHostname=\$wasMachineHostname
webServerConfigFile1=\$webServerConfigFile1
webServerDefinition=\$webServerDefinition
webServerHostName=\$webServerHostName
webServerInstallArch=\$webServerInstallArch
webServerPortNumber=\$webServerPortNumber
webServerSelected=\$webServerSelected
webServerType=\$webServerType
RESPONSFILE_END
EOF
chmod +x /tmp/wctcmdpp.sh
