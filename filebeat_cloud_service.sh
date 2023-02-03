#!/bin/sh

echo -e "set up filebeat or edit filebeat"
counter=0

while [[ "$choose" != "setup" ]] && [[ "$choose" != "edit" ]] || [[ "$choose" == '' ]]
	do
		read -e -p 'Do you want to Setup or Edit. [E.x. setup || edit] => ' choose
		counter=$((counter + 1))
         if [ $counter == 3 ]
        then
            exit 0
        fi
		echo "Incorrect choose: , $choose)"
	done

if [ $choose == setup ]
then
	wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
	apt-get install apt-transport-https
	echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-8.x.list
	apt-get update
	sudo apt-get install filebeat
	touch /etc/filebeat/filebeat.yml
	cd
	chown root:root /etc/filebeat/filebeat.yml
	systemctl start filebeat.service
	systemctl enable filebeat.service
fi

# Filebeat Config
cat <<END >/etc/filebeat/filebeat.yml
filebeat.inputs:
- enabled: true
  paths:
  - /var/log/syslog
  - /var/log/auth.log
  tags: cloud_service
  type: log
output.logstash:
  hosts: 
  - 172.25.210.213:5033
setup.template.settings:
  index.number_of_shards: 1
processors:
- add_host_metadata:
    when.not.contains.tags: forwarded
- add_cloud_metadata: null
- add_docker_metadata: null
- add_kubernetes_metadata: null
END

# tags: ["testTag"]

## su dung cmd de nhap path

sleep 1
declare -a a
echo -n "Nhap so path muon xem log: "
read n
for ((i=1;i<=n;i++));
do
	echo -n "paths[$i]= "
	read m
	a[$i]=$m
	sed -i "/paths:$/a\
	\  - $m" /etc/filebeat/filebeat.yml
	echo -e " "
done

#sleep 1
#echo -n "Nhap ten tags: "
#read -e -p 'tag of logs. [E.x. testTag] => ' TAG1
#/bin/sed -i s/testTag/$TAG1/g /etc/filebeat/filebeat.yml
#echo -e " "

echo -e " "
echo "Starting up the filebeat.service"
systemctl daemon-reload
sleep 1
systemctl restart filebeat.service
systemctl is-active filebeat.service >/dev/null 2>&1 && echo "Congradulations.. Filebeat is now starting & sending logs" || echo "Something is Wrong.! Check the configuration"
