#!/bin/sh
# Initialisation of the default value
# TODO put that into interactive script

#LOG_FILE="/var/log/xwiki/installation.log"
LOG_FILE="./installation.log";
TIMESLOT=`date +%Y-%m-%d-%H-%M-%S`;
#TOMCAT_VERSION=""
XWIKI_WEBAPP_VERSION="xwiki-enterprise-web-6.2.4"
MYSQL_JAR_VERSION="5.1.33"
LIBREOFFICE_PATH="/opt/libreoffice4.1/"
XWIKI_DIRECTORY="/usr/local/xwiki"
XWIKI_WORKDIR_NAME="xwiki-workdir"
TARGET_SERVER_NAME="defaul.devxwikisas.com"

SUPER_ADMIN_PASSWORD=$(openssl rand -hex 64 | head -c 12);
MYSQL_XWIKI_USER_PASSWORD=$(openssl rand -hex 64 | head -c 12);
VALIDATION_KEY=$(openssl rand -hex 64 | head -c 32);
ENCRYPTION_KEY=$(openssl rand -hex 64 | head -c 32);

echo "Please enter the new TARGET_SERVER_NAME ($TARGET_SERVER_NAME): " &&
read input_servername &&
if [ -z $input_servername ]
  then
    echo "using $TARGET_SERVER_NAME"
  else
  	TARGET_SERVER_NAME=$input_servername 
    echo "using $TARGET_SERVER_NAME"
  	
fi
CHECK_HTTP_URL=$(echo "\"http://$TARGET_SERVER_NAME/xwiki/bin/view/Main/WebHome\"");

echo "Please enter the new XWIKI_WEBAPP_VERSION ($XWIKI_WEBAPP_VERSION): " &&
read input_xwiki_webapp_version &&
if [ -z $input_xwiki_webapp_version ]
  then
    echo "using $XWIKI_WEBAPP_VERSION"
  else
  	XWIKI_WEBAPP_VERSION=$input_xwiki_webapp_version 
    echo "using $XWIKI_WEBAPP_VERSION"
  	
fi
echo "Please enter the new LIBREOFFICE_PATH ($LIBREOFFICE_PATH): " &&
read input_libreoffice_path &&
if [ -z $input_libreoffice_path ]
  then
    echo "using $LIBREOFFICE_PATH"
  else
  	XWIKI_WORKDIR_NAME=$input_libreoffice_path 
    echo "using $LIBREOFFICE_PATH"  	
fi
echo "Please enter the new XWIKI_WORKDIR_NAME ($XWIKI_WORKDIR_NAME): " &&
read input_xwiki_workdir_name &&
if [ -z $input_xwiki_workdir_name ]
  then
    echo "using $XWIKI_WORKDIR_NAME"
  else
  	XWIKI_WORKDIR_NAME=$input_xwiki_workdir_name 
    echo "using $XWIKI_WORKDIR_NAME"  	
fi
echo "Please enter the new XWIKI_DIRECTORY ($XWIKI_DIRECTORY): " &&
read input_xwiki_directory &&
if [ -z $input_xwiki_directory ]
  then
    echo "using $XWIKI_DIRECTORY"
  else
  	XWIKI_DIRECTORY=$input_xwiki_directory 
    echo "using $XWIKI_DIRECTORY"  	
fi



# get the needed files
wget http://download.forge.ow2.org/xwiki/$XWIKI_WEBAPP_VERSION.war && 
wget http://central.maven.org/maven2/mysql/mysql-connector-java/$MYSQL_JAR_VERSION/mysql-connector-java-$MYSQL_JAR_VERSION.jar &&

sudo mkdir /usr/local/$XWIKI_WEBAPP_VERSION
sudo unzip $XWIKI_WEBAPP_VERSION.war -d /usr/local/$XWIKI_WEBAPP_VERSION
# if exist

if [ -d "$XWIKI_DIRECTORY" ]; then
  sudo unlink /usr/local/xwiki
fi

if [ -d "$XWIKI_DIRECTORY" ]; then
  sudo rm -ri /usr/local/xwiki 
fi
if [ -d "$XWIKI_WORKDIR_NAME" ]; then
  sudo unlink /usr/local/$XWIKI_WORKDIR_NAME
fi

sudo ln -s /usr/local/$XWIKI_WEBAPP_VERSION /usr/local/xwiki
sudo cp mysql-connector-java-$MYSQL_JAR_VERSION.jar /usr/local/xwiki/WEB-INF/lib
# config wiki.cfg
sudo cp /usr/local/xwiki/WEB-INF/xwiki.cfg /usr/local/xwiki/WEB-INF/xwiki.cfg.$TIMESLOT 

sudo sed -i -e "s/xwiki\.authentication\.validationKey=totototototototototototototototo/xwiki.authentication.validationKey=$VALIDATION_KEY/g" /usr/local/xwiki/WEB-INF/xwiki.cfg
sudo sed -i -e "s/xwiki\.authentication\.encryptionKey=titititititititititititititititi/xwiki.authentication.encryptionKey=$ENCRYPTION_KEY/g" /usr/local/xwiki/WEB-INF/xwiki.cfg
sudo sed -i -e "s/# xwiki\.superadminpassword=system/# xwiki.superadminpassword=$SUPER_ADMIN_PASSWORD/g" /usr/local/xwiki/WEB-INF/xwiki.cfg

sudo sed -i -e "s/# xwiki.store.cache.capacity=100/xwiki.store.cache.capacity=1000/g" /usr/local/xwiki/WEB-INF/xwiki.cfg
sudo sed -i -e "s/# xwiki.store.attachment.hint=hibernate/xwiki.store.attachment.hint=file/g" /usr/local/xwiki/WEB-INF/xwiki.cfg
sudo sed -i -e "s/# xwiki.store.attachment.versioning.hint=hibernate/xwiki.store.attachment.versioning.hint=file/g" /usr/local/xwiki/WEB-INF/xwiki.cfg
sudo sed -i -e "s/# xwiki.store.attachment.recyclebin.hint=hibernate/xwiki.store.attachment.recyclebin.hint=file/g" /usr/local/xwiki/WEB-INF/xwiki.cfg





# config wiki.properties
sudo cp /usr/local/xwiki/WEB-INF/xwiki.properties /usr/local/xwiki/WEB-INF/xwiki.properties.$TIMESLOT 
sudo sh -c "echo \"environment.permanentDirectory=/usr/local/$XWIKI_DIRECTORY\nopenoffice.autoStart=false\nopenoffice.homePath=$LIBREOFFICE_PATH\" > /usr/local/xwiki/WEB-INF/xwiki.properties"

# config hibernate.cfg.xml
sudo cp /usr/local/xwiki/WEB-INF/hibernate.cfg.xml /usr/local/xwiki/WEB-INF/hibernate.cfg.xml.$TIMESLOT
#TODO add password
sudo sh -c "echo \"<?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?>\n<\041DOCTYPE hibernate-configuration PUBLIC\n  \\\"-//Hibernate/Hibernate Configuration DTD//EN\\\"\n  \\\"http://www.hibernate.org/dtd/hibernate-configuration-3.0.dtd\\\">\n<hibernate-configuration>\n  <session-factory>\n\n    <property name=\\\"show_sql\\\">false</property>\n    <property name=\\\"use_outer_join\\\">true</property>\n    <property name=\\\"connection.pool_size\\\">2</property>\n    <property name=\\\"statement_cache.size\\\">2</property>\n    <property name=\\\"jdbc.use_scrollable_resultset\\\">false</property>\n\n    <\041-- DBCP Connection Pooling configuration\n    -->\n    <property name=\\\"dbcp.defaultAutoCommit\\\">false</property>\n    <property name=\\\"dbcp.maxActive\\\">50</property>\n    <property name=\\\"dbcp.maxIdle\\\">5</property>\n    <property name=\\\"dbcp.maxWait\\\">30000</property>\n    <property name=\\\"dbcp.whenExhaustedAction\\\">1</property>\n    <property name=\\\"dbcp.ps.whenExhaustedAction\\\">1</property>\n    <property name=\\\"dbcp.ps.maxWait\\\">120000</property>\n    <property name=\\\"dbcp.ps.maxIdle\\\">20</property>\n    <property name=\\\"connection.provider_class\\\">com.xpn.xwiki.store.DBCPConnectionProvider</property>\n\n    <\041-- MySQL configuration.\n         Uncomment if you want to use MySQL and comment out other database configurations.\n\n     -->\n    <property name=\\\"connection.url\\\">jdbc:mysql://localhost/xwiki</property>\n    <property name=\\\"connection.username\\\">xwiki</property>\n    <property name=\\\"connection.password\\\">xwiki</property>\n    <property name=\\\"connection.driver_class\\\">com.mysql.jdbc.Driver</property>\n    <property name=\\\"dialect\\\">org.hibernate.dialect.MySQL5InnoDBDialect</property>\n    <property name=\\\"dbcp.ps.maxActive\\\">20</property>\n    <mapping resource=\\\"xwiki.hbm.xml\\\"/>\n    <mapping resource=\\\"feeds.hbm.xml\\\"/>\n    <mapping resource=\\\"activitystream.hbm.xml\\\"/>\n    <mapping resource=\\\"instance.hbm.xml\\\"/>\n    \n  </session-factory>\n</hibernate-configuration>\" > /usr/local/xwiki/WEB-INF/hibernate.cfg.xml"

# config xinit.cfg
sudo cp /etc/xinit/xinit.cfg  /etc/xinit/xinit.cfg.$TIMESLOT 
sudo sed -i -e "s!CHECK_HTTP_URL=\"http:\/\/localhost\/\"!CHECK_HTTP_URL="$CHECK_HTTP_URL"!g" /etc/xinit/xinit.cfg &&
sudo sed -i -e 's/#EXPECT_HTTP_RESPONSE_CODE=\"200\"/EXPECT_HTTP_RESPONSE_CODE="200,401"/g' /etc/xinit/xinit.cfg &&
sudo sed -i -e 's/MEM_MAX=\"712m\"/MEM_MAX="1024m"/g' /etc/xinit/xinit.cfg &&
sudo sed -i -e 's/CHECK_HTTP=\"no\"/CHECK_HTTP="yes"/g' /etc/xinit/xinit.cfg
 

# creating apache server config
sudo sh -c "echo \"<VirtualHost *:80>\n    ServerName $TARGET_SERVER_NAME\n\n    ErrorLog /var/log/apache2/xwiki-error.log\n    CustomLog /var/log/apache2/xwiki-access.log combined\n\n    RedirectMatch ^/\044 /xwiki/bin/view/Main/WebHome\n    RedirectMatch ^/xwiki/\044 /xwiki/bin/view/Main/WebHome\n    DocumentRoot /var/www/\n\n    ProxyErrorOverride On\n    ProxyPass /xwiki-static/ \041\n    ErrorDocument 503 /xwiki-static/error.html\n\n#    <Location /xwiki>\n#        Order Allow,Deny\n#        AuthType Digest\n#        AuthName \\\"Private\\\"\n#        AuthDigestAlgorithm MD5\n#        AuthDigestQop auth\n#        AuthDigestProvider file\n#        AuthUserFile /etc/apache2/htdigest\n#        Require valid-user\n#        Allow from localhost\n#        Allow from 127.0.0.1\n#        Allow from 188.165.44.90\n#        Allow from 192.168.1.115\n#        Allow from 5.196.170.100\n#         Include xwikisas-ips\n#        Satisfy Any\n#    </Location>\n\n    <Location /xwiki/rest>\n         RequestHeader unset Authorization\n    </Location>\n\n    ProxyRequests Off\n    <Proxy *>\n        Order deny,allow\n        Allow from all\n    </Proxy>\n    ProxyPreserveHost On\n    ProxyPass /xwiki ajp://localhost:8009/xwiki retry=5\n    ProxyPassReverse /xwiki ajp://localhost:8009/xwiki\n    # ProxyPass /manager ajp://localhost:8009/manager\n\n<Directory \\\"/\\\">\n    Order Allow,Deny\n    Allow from all\n    Deny from env=bad_bot\n</Directory>\n\n</VirtualHost>\" > /etc/apache2/sites-available/$TARGET_SERVER_NAME"
sudo sh -c "echo \"<VirtualHost *:80>\n    ServerName $TARGET_SERVER_NAME\n\n        RewriteEngine On\n        RewriteCond %{HTTPS} \041=on\n        RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]\n\n</VirtualHost>\n\n<VirtualHost *:443>\n    ServerName $TARGET_SERVER_NAME\n\n    ErrorLog /var/log/apache2/xwiki-error.log\n    CustomLog /var/log/apache2/xwiki-access.log combined\n\n    RedirectMatch ^/\044 /xwiki/bin/view/Main/WebHome\n    RedirectMatch ^/xwiki/\044 /xwiki/bin/view/Main/WebHome\n    DocumentRoot /var/www/\n\n    ProxyErrorOverride On\n    ProxyPass /xwiki-static/ \041\n    ErrorDocument 503 /xwiki-static/error.html\n\n    <Location /xwiki/rest>\n         RequestHeader unset Authorization\n    </Location>\n\n    ProxyRequests Off\n    <Proxy *>\n        Order deny,allow\n        Allow from all\n    </Proxy>\n    ProxyPreserveHost On\n    ProxyPass /xwiki ajp://localhost:8009/xwiki retry=5\n    ProxyPassReverse /xwiki ajp://localhost:8009/xwiki\n    # ProxyPass /manager ajp://localhost:8009/manager\n\n<Directory \\\"/\\\">\n    Order Allow,Deny\n    Allow from all\n    Deny from env=bad_bot\n</Directory>\n\n\n    SSLEngine on\n    SSLCertificateKeyFile /etc/apache2/ssl/star.$TARGET_SERVER_NAME.key\n    SSLCertificateFile /etc/apache2/ssl/star.$TARGET_SERVER_NAME.crt\n    SSLCertificateChainFile /etc/apache2/ssl/startssl.ca\n\n\n</VirtualHost>\" > /etc/apache2/sites-available/ssl.$TARGET_SERVER_NAME"

for a in /etc/apache2/sites-enabled/*; do server=$(basename $a); echo $server ;	sudo /usr/sbin/a2dissite $server ; done

sudo /usr/sbin/a2ensite $TARGET_SERVER_NAME &&
sudo /usr/sbin/a2enmod  headers &&
sudo /usr/sbin/a2enmod auth_digest &&
sudo /usr/sbin/a2enmod ssl &&
sudo chown -R tomcat. /usr/local/xwiki* &&


# Creating database
mysql -u root -e "create database xwiki default character set utf8 collate utf8_bin"
mysql -u root -e "grant all privileges on *.* to xwiki@localhost identified by 'xwiki'"

echo "# if needed\n# htdigest -c /etc/apache2/htdigest Private Admin\n"

sudo /etc/init.d/mysql restart
sudo /etc/init.d/apache2 restart
sudo /etc/init.d/xwiki.sh restart


echo "Now wait a while for the server to start"

sleep 20



  

