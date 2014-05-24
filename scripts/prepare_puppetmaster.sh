#!/bin/bash

# This script prepares the Puppet Master for the synchronisation of a Puppet Agent.
# by putting the right institution's files into the right Puppet Master's directories.

MODULESDIR="/etc/puppet/modules"

if [ -d "/etc/puppet/environments" ]
then
	MODULESDIR="/etc/puppet/environments/production/modules"
	MODULESDIR_TEST="/etc/puppet/environments/test/modules"
fi

#PUPPET_USER="root"
#PUPPET_SERVER="<YOUR_PUPPET_MASTER_FQDN>"
FILES="KO"
CERT="KO"

#prompt_file() {
#    scp $1 $PUPPET_USER@$PUPPET_SERVER:/etc/puppet/$2/$3
#}

generate_cert(){
  read -p "Insert the Domain Name for the HTTPS Certificate of the IdP to be installed [eg: example.com]: " DOMAIN_NAME
  
  if [[ "${DOMAIN_NAME}" =~ '^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[it|com|net|org]' ]]; then
    echo "ERROR: you have to specify a valid Domain Name  for the IdP!"
    exit 1
  fi

  openssl req -newkey rsa:2048 -x509 -nodes -out config-files/${IDP_HOSTNAME}-cert-server.pem -keyout config-files/${IDP_HOSTNAME}-key-server.pem -days 3650 -subj "/CN=${IDP_HOSTNAME}.${DOMAIN_NAME}"

  echo "Generating CSR request and sending it via email:"
  openssl req -new -key config-files/${IDP_HOSTNAME}-key-server.pem -out /tmp/${IDP_HOSTNAME}-csr-request.csr -subj "/CN=${IDP_HOSTNAME}.${DOMAIN_NAME}"

  MYPATH="`dirname "$0"`"
  python ${MYPATH}/sendemail.py ${IDP_HOSTNAME}

  rm -f /tmp/${IDP_HOSTNAME}-csr-request.csr
}

generate_default_files(){
  cp ${MODULESDIR}/shib2idp/files/tou/example-tou.html.txt config-files/${IDP_HOSTNAME}-tou.html
  cp ${MODULESDIR}/shib2idp/files/stili/sample-logo-32x32_en.png config-files/${IDP_HOSTNAME}-logo-32x32_en.png
  cp ${MODULESDIR}/shib2idp/files/stili/sample-logo-32x32_it.png config-files/${IDP_HOSTNAME}-logo-32x32_it.png
  cp ${MODULESDIR}/shib2idp/files/stili/sample-logo-160x120_en.png config-files/${IDP_HOSTNAME}-logo-160x120_en.png
  cp ${MODULESDIR}/shib2idp/files/stili/sample-logo-160x120_it.png config-files/${IDP_HOSTNAME}-logo-160x120_it.png
  cp ${MODULESDIR}/shib2idp/files/stili/sample-login.css config-files/${IDP_HOSTNAME}-login.css
}

read -p "Insert the Hostname for the IdP to be installed [eg: puppetclient]: " IDP_HOSTNAME
if [ "${IDP_HOSTNAME}" = '' ]; then
  echo "ERROR: you have to specify a valid Hostname for IdP!"
  exit 1
fi

read -p "Have you a cert-server.pem and a key-server.pem for your IdP? [Y|N] " yn
case $yn in
  [Yy]* )
    if [ -f config-files/${IDP_HOSTNAME}-cert-server.pem ] && [ -f config-files/${IDP_HOSTNAME}-key-server.pem ];
    then
      CERT="OK"
    else
      echo -e "Please put your credentials into dir 'config-files' named to\n${IDP_HOSTNAME}-cert-server.pem and\n${IDP_HOSTNAME}-key-server.pem and restart the script, please"
      exit 2
    fi
    ;;
  [Nn]* ) 
    echo "Now I create a new credential for you!"
    generate_cert
    CERT="OK"
    ;;
  * )
    echo "ERROR: Please answer 'yes' or 'no'."
    ;;
esac

read -p "Have you all configuration files for your IdP? [Y|N] " yn
case $yn in
  [Yy]* ) 
    if [ -f config-files/${IDP_HOSTNAME}-tou.html ] &&
       [ -f config-files/${IDP_HOSTNAME}-logo-32x32_en.png ] &&
       [ -f config-files/${IDP_HOSTNAME}-logo-32x32_it.png ] &&
       [ -f config-files/${IDP_HOSTNAME}-logo-160x120_en.png ] &&
       [ -f config-files/${IDP_HOSTNAME}-logo-160x120_it.png ] &&
       [ -f config-files/${IDP_HOSTNAME}-login.css ];
    then
      FILES="OK"
    else
      echo -e "Please put your configuration files into 'config-files' directory named to \n${IDP_HOSTNAME}-tou.html,\n${IDP_HOSTNAME}-logo-32x32_en.png,\n${IDP_HOSTNAME}-logo-32x32_it.png,\n${IDP_HOSTNAME}-logo-160x120_en.png,\n${IDP_HOSTNAME}-logo-160x120_it.png,\n${IDP_HOSTNAME}-login.css and restart the script, please."
      # I am into "config-files" directory here.
      find . -type f -not -name "*.txt" | xargs rm
      exit 2
    fi
    ;;
  [Nn]* ) 
    echo "Now I create your configuration files using the default ones!"
    generate_default_files
    FILES="OK"
    ;;
  * )
    echo "ERROR: Please answer 'yes' or 'no'."
    ;;
esac

if [ ${FILES}==${CERT} ];
then
  cd config-files
  # prompt_file exec this => scp $1 $PUPPET_USER@$PUPPET_SERVER:/etc/puppet/$2/$3

  # prompt_file "${IDP_HOSTNAME}-key-server.pem" "modules/shib2common/files/certs" "${IDP_HOSTNAME}-key-server.pem"
  # prompt_file "${IDP_HOSTNAME}-cert-server.pem" "modules/shib2common/files/certs" "${IDP_HOSTNAME}-cert-server.pem"
  # prompt_file "${IDP_HOSTNAME}-tou.html" "modules/shib2idp/files/tou" "${IDP_HOSTNAME}-tou.html"

  # prompt_file "${IDP_HOSTNAME}-login.css" "modules/shib2idp/files/styles" "${IDP_HOSTNAME}-login.css"

  # prompt_file "${IDP_HOSTNAME}-logo-32x32_en.png" "modules/shib2idp/files/styles" "${IDP_HOSTNAME}-logo-32x32_en.png"
  # prompt_file "${IDP_HOSTNAME}-logo-32x32_it.png" "modules/shib2idp/files/styles" "${IDP_HOSTNAME}-logo-32x32_it.png"
  # prompt_file "${IDP_HOSTNAME}-logo-160x120_en.png" "modules/shib2idp/files/styles" "${IDP_HOSTNAME}-logo-160x120_en.png"
  # prompt_file "${IDP_HOSTNAME}-logo-160x120_it.png" "modules/shib2idp/files/styles" "${IDP_HOSTNAME}-logo-160x120_it.png"

  mv "${IDP_HOSTNAME}-key-server.pem" "${MODULESDIR}/shib2common/files/certs"
  mv "${IDP_HOSTNAME}-cert-server.pem" "${MODULESDIR}/shib2common/files/certs"
  mv "${IDP_HOSTNAME}-tou.html" "${MODULESDIR}/shib2idp/files/tou"

  mv "${IDP_HOSTNAME}-login.css" "${MODULESDIR}/shib2idp/files/stili"

  mv "${IDP_HOSTNAME}-logo-32x32_en.png" "${MODULESDIR}/shib2idp/files/stili"
  mv "${IDP_HOSTNAME}-logo-32x32_it.png" "${MODULESDIR}/shib2idp/files/stili"
  mv "${IDP_HOSTNAME}-logo-160x120_en.png" "${MODULESDIR}/shib2idp/files/stili"
  mv "${IDP_HOSTNAME}-logo-160x120_it.png" "${MODULESDIR}/shib2idp/files/stili"

  if [ ! -z "${MODULESDIR_TEST}" ]; then
      cp $MODULESDIR/shib2common/files/certs/$IDP_HOSTNAME-* $MODULESDIR_TEST/shib2common/files/certs
      cp $MODULESDIR/shib2idp/files/tou/$IDP_HOSTNAME-tou.html $MODULESDIR_TEST/shib2idp/files/tou
      cp $MODULESDIR/shib2idp/files/stili/$IDP_HOSTNAME-log* $MODULESDIR_TEST/shib2idp/files/styles
  fi

  #echo "Restarting puppet master on $PUPPET_SERVER..."
  #ssh $PUPPET_USER@$PUPPET_SERVER "service puppetmaster restart"
  #echo "Restarting Puppet Master"
  #service puppetmaster restart

  # I am into config-files directory here.
  #find . -type f -not -name "*.txt" | xargs rm

else
  echo "ERROR!!!"
fi

