#!/bin/sh
# update of war the default value
# TODO put that into interactive script

#LOG_FILE="/var/log/xwiki/installation.log"
LOG_FILE="./installation.log";
TIMESLOT=`date +%Y-%m-%d-%H-%M-%S`;
#TOMCAT_VERSION=""
XWIKI_WEBAPP_VERSION="xwiki-enterprise-web-6.3"
MYSQL_JAR_VERSION="5.1.33"
LIBREOFFICE_PATH="/opt/libreoffice4.1/"
XWIKI_DIRECTORY="/usr/local/xwiki"
XWIKI_WORKDIR_NAME="xwiki-workdir"

echo "Please enter the new XWIKI_WEBAPP_VERSION ($XWIKI_WEBAPP_VERSION): " &&
read input_xwiki_webapp_version &&
if [ -z $input_xwiki_webapp_version ]
  then
    echo "using $XWIKI_WEBAPP_VERSION"
  else
  	XWIKI_WEBAPP_VERSION=$input_xwiki_webapp_version 
    echo "using $XWIKI_WEBAPP_VERSION"
	
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
sudo cp mysql-connector-java-$MYSQL_JAR_VERSION.jar /usr/local/$XWIKI_WEBAPP_VERSION/WEB-INF/lib

# copie xwiki.properties
sudo cp /usr/local/$XWIKI_WEBAPP_VERSION/WEB-INF/xwiki.properties /usr/local/$XWIKI_WEBAPP_VERSION/WEB-INF/xwiki.properties.$TIMESLOT
sudo cp /usr/local/xwiki/WEB-INF/xwiki.properties /usr/local/$XWIKI_WEBAPP_VERSION/WEB-INF/xwiki.properties

# copie xwiki.cfg
sudo cp /usr/local/$XWIKI_WEBAPP_VERSION/WEB-INF/xwiki.cfg /usr/local/$XWIKI_WEBAPP_VERSION/WEB-INF/xwiki.cfg.$TIMESLOT
sudo cp /usr/local/xwiki/WEB-INF/xwiki.cfg /usr/local/$XWIKI_WEBAPP_VERSION/WEB-INF/xwiki.cfg

# copie hibernate.cfg.xml
sudo cp /usr/local/$XWIKI_WEBAPP_VERSION/WEB-INF/hibernate.cfg.xml /usr/local/$XWIKI_WEBAPP_VERSION/WEB-INF/hibernate.cfg.xml.$TIMESLOT
sudo cp /usr/local/xwiki/WEB-INF/hibernate.cfg.xml /usr/local/$XWIKI_WEBAPP_VERSION/WEB-INF/hibernate.cfg.xml

sudo /etc/init.d/xwiki.sh maintenance on && sudo /etc/init.d/xwiki.sh stop

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
sudo chown -R tomcat. /usr/local/xwiki* &&

sudo /etc/init.d/xwiki.sh restart && sudo /etc/init.d/xwiki.sh maintenance off


sleep 20



  

