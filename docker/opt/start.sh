#!/bin/sh
## Preparando todas as variáveis como IP, Nome do host, etc, todas elas no contêiner
sleep 5
HOSTNAME=$(hostname -s)
DOMAIN=$(hostname -d)
CONTAINERIP=$(ifconfig |grep -A1 eth0 |grep inet|awk '{print $2}')
RANDOMHAM=$(date +%s|sha256sum|base64|head -c 10)
RANDOMSPAM=$(date +%s|sha256sum|base64|head -c 10)
RANDOMVIRUS=$(date +%s|sha256sum|base64|head -c 10)

## Instalando o servidor DNS ##
#echo "Configurando o servidor DNS"
#mv /etc/dnsmasq.conf /etc/dnsmasq.conf.old
#cat <<EOF >>/etc/dnsmasq.conf
#server=8.8.8.8
#listen-address=127.0.0.1
#domain=$DOMAIN
#mx-host=$DOMAIN,$HOSTNAME.$DOMAIN,0
#address=/$HOSTNAME.$DOMAIN/$CONTAINERIP
#user=root
#EOF
#sudo systemctl restart dnsmasq

## Configurando servidor sshd ##
echo "Configurando o servidor sshd."
/usr/bin/ssh-keygen -A
/sbin/sshd -D &

## Criando o arquivo de configuração do Zimbra Collaboration ##
touch /opt/zimbra-install/installZimbraScript
cat <<EOF >/opt/zimbra-install/installZimbraScript
AVDOMAIN="$DOMAIN"
AVUSER="compos@$DOMAIN"
CREATEADMIN="compos@$DOMAIN"
CREATEADMINPASS="$PASSWORD"
CREATEDOMAIN="$DOMAIN"
DOCREATEADMIN="no"
DOCREATEDOMAIN="no"
DOTRAINSA="yes"
ENABLEGALSYNCACCOUNTS="yes"
EXPANDMENU="no"
EphemeralBackendURL="ldap://default"
HOSTNAME="$HOSTNAME.$DOMAIN"
HTTPPORT="80"
HTTPPROXY="TRUE"
HTTPPROXYPORT="0"
HTTPSPORT="443"
HTTPSPROXYPORT="0"
IMAPPORT="143"
IMAPPROXYPORT="0"
IMAPSSLPORT="993"
IMAPSSLPROXYPORT="0"
INSTALL_WEBAPPS="service zimbra zimbraAdmin zimlet"
JAVAHOME="/opt/zimbra/common/lib/jvm/java"
LDAPAMAVISPASS="$PASSWORD"
LDAPPOSTPASS="$PASSWORD"
LDAPROOTPASS="$PASSWORD"
LDAPADMINPASS="$PASSWORD"
LDAPREPPASS="$PASSWORD"
LDAPBESSEARCHSET="set"
LDAPDEFAULTSLOADED="1"
LDAPHOST="$HOSTNAME.$DOMAIN"
LDAPPORT="389"
LDAPREPLICATIONTYPE="master"
LDAPSERVERID="2"
MAILBOXDMEMORY="1971"
MAILPROXY="TRUE"
MODE="redirect"
MYSQLMEMORYPERCENT="30"
POPPORT="110"
POPPROXYPORT="0"
POPSSLPORT="995"
POPSSLPROXYPORT="0"
PROXYMODE="redirect"
REMOTEIMAPBINDPORT="8143"
REMOTEIMAPSSLBINDPORT="8993"
REMOVE="no"
RUNARCHIVING="no"
RUNAV="no"
RUNCBPOLICYD="no"
RUNDKIM="yes"
RUNSA="yes"
RUNVMHA="no"
SERVICEWEBAPP="yes"
SMTPDEST="compos@$DOMAIN"
SMTPHOST="$HOSTNAME.$DOMAIN"
SMTPNOTIFY="yes"
SMTPSOURCE="compos@$DOMAIN"
SNMPNOTIFY="yes"
SNMPTRAPHOST="$HOSTNAME.$DOMAIN"
SPELLURL="http://$HOSTNAME.$DOMAIN:7780/aspell.php"
STARTSERVERS="yes"
SYSTEMMEMORY="3.8"
TRAINSAHAM="ham.$RANDOMHAM@$DOMAIN"
TRAINSASPAM="spam.$RANDOMSPAM@$DOMAIN"
UIWEBAPPS="yes"
UPGRADE="yes"
USEEPHEMERALSTORE="yes"
USEKBSHORTCUTS="TRUE"
USESPELL="yes"
VERSIONUPDATECHECKS="TRUE"
VIRUSQUARANTINE="virus-quarantine.$RANDOMVIRUS@$DOMAIN"
ZIMBRA_REQ_SECURITY="yes"
ldap_bes_searcher_password="$PASSWORD"
ldap_dit_base_dn_config="cn=zimbra"
ldap_nginx_password="$PASSWORD"
ldap_url="ldap://$HOSTNAME.$DOMAIN:389"
mailboxd_directory="/opt/zimbra/mailboxd"
mailboxd_keystore="/opt/zimbra/mailboxd/etc/keystore"
mailboxd_keystore_password="$PASSWORD"
mailboxd_server="jetty"
mailboxd_truststore="/opt/zimbra/common/lib/jvm/java/lib/security/cacerts"
mailboxd_truststore_password="changeit"
postfix_mail_owner="postfix"
postfix_setgid_group="postdrop"
ssl_default_digest="sha256"
zimbraDNSMasterIP=""
zimbraDNSTCPUpstream="no"
zimbraDNSUseTCP="yes"
zimbraDNSUseUDP="yes"
zimbraDefaultDomainName="$DOMAIN"
zimbraFeatureBriefcasesEnabled="Enabled"
zimbraFeatureTasksEnabled="Enabled"
zimbraIPMode="ipv4"
zimbraMtaMyNetworks="127.0.0.0/8 [::1]/128 $CONTAINERIP/32"
zimbraPrefTimeZoneId="America/Bahia"
zimbraReverseProxyLookupTarget="TRUE"
zimbraVersionCheckInterval="1d"
zimbraVersionCheckNotificationEmail="compos@$DOMAIN"
zimbraVersionCheckNotificationEmailFrom="compos@$DOMAIN"
zimbraVersionCheckSendNotifications="TRUE"
zimbra_ldap_userdn="uid=zimbra,cn=admins,cn=zimbra"
zimbra_require_interprocess_security="1"
zimbra_server_hostname="$HOSTNAME.$DOMAIN"
INSTALL_PACKAGES="zimbra-core zimbra-ldap zimbra-logger zimbra-mta zimbra-snmp zimbra-store zimbra-apache zimbra-spell "
EOF

##Instale a colaboração Zimbra ##

echo "Downloading Zimbra Collaboration 8.8.12"
wget -O /opt/zimbra-install/zimbra.tar.gz https://files.zimbra.com/downloads/8.8.12_GA/zcs-NETWORK-8.8.12_GA_3794.RHEL7_64.20190329045002.tgz

echo "Extracting files from the archive"
tar xzvf /opt/zimbra-install/zimbra.tar.gz -C /opt/zimbra-install/

echo "Installing Zimbra Collaboration just the Software"
cd /opt/zimbra-install/zcs-* && ./install.sh -s < /opt/zimbra-install/installZimbra-keystrokes

# Solução de problemas de instalação.
mkdir -p /opt/zimbra/common/lib/jvm/java/jre/lib/security
chown -R zimbra:zimbra /opt/zimbra/common/lib/jvm/java/jre/lib/security

echo "Instalando o Zimbra Collaboration injetando a configuração"
/opt/zimbra/libexec/zmsetup.pl -c /opt/zimbra-install/installZimbraScript

echo "Adicionando repositório do ZetAlliance"
wget https://copr.fedorainfracloud.org/coprs/zetalliance/zimlets/repo/#epel-7/zetalliance-zimlets-epel-7.repo -O /etc/yum.repos.d/zetalliance-#zimlets-epel-7.repo

echo "Instalando o zimbra-patch"
yum clean metadata
yum check-update
yum install zimbra-patch -y

echo "Reiniciando o Zimbra"
su - zimbra -c 'zmcontrol restart'

echo "yum clean all"
yum clean all

echo "Substituindo Script do Instalador pelo Script Inicial"
mv /opt/start.sh /opt/start.sh_installer && mv /opt/start.sh_postinstall /opt/start.sh

echo "Removing Install Files"
cd ~
rm -rf /opt/zimbra-install

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
