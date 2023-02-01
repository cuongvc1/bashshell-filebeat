#!/bin/sh

echo -e "set up filebeat or edit filebeat"
# echo -n "Moi nhap: "
# read choose
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

# cat <<END >/etc/filebeat/filebeat.yml
# 	filebeat.prospectors:
# 	- input_type: log
# 	paths:
# 		- filename.log
# 	tags: ["testTag"]
# 	output.logstash:
# 	hosts: ["0.0.0.0:5044"]
# END

# Filebeat Config
cat <<END >/etc/filebeat/filebeat.yml
filebeat.inputs:
- enabled: true
  paths:
  tags: `hostname`
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
for ((i=1;i<=n;i++));do
	echo -n "paths[$i]= "
	read m
	a[$i]=$m
	sed -i "/paths:$/a\
	\ - $m" /etc/filebeat/filebeat.yml
	echo -e " "
done

## su dung file de nhap path

# sleep 1
# a=($( cat /etc/filebeat/path.txt | tr -d '-'))

# for i in "${a[@]}"
# do
#   sed -i "/paths:$/a\
# \ - $i" /etc/filebeat/filebeat.yml
# done
# echo -e " "


## su dung 1 path

# sleep 1
# echo -e "Configuring the Agent...?"
# sleep 2
# read -e -p 'File can lay log. [E.x. /var/log/syslog.log] => ' PATH1
# if [[ $PATH1 == *"/"* ]]; then
# 	PATH1=${PATH1//\//\\\/}
# fi
# /bin/sed -i s/filename.log/$PATH1/g /etc/filebeat/filebeat.yml
# echo -e " "


# sleep 1
# read -e -p 'tag of logs. [E.x. testTag] => ' TAG1
# /bin/sed -i s/testTag/$TAG1/g /etc/filebeat/filebeat.yml
# echo -e " "

## output filebeat neu khong cho default

# sleep 1
# while [[ "$oagent" != "opensearch" ]] && [[ "$oagent" != "logstash" ]] || [[ "$oagent" == '' ]]
# 	do
# 		read -e -p 'Do you want to ship logs over opensearch OR Logstash. [E.x. logstash] => ' oagent
# 	done
# /bin/sed -i s/output.agent/output.$oagent/g /etc/filebeat/filebeat.yml
# echo -e " "

# nhap port
# sleep 1
# while [[ $IPnPORT == '' ]]
# #while [[ IPnPORT != [0-9]*.[0-9]*.[0-9]*.[0-9]*:[0-9]* ]] || [[ $IPnPORT == '' ]]
# 	do
# 		read -e -p 'Type the IP address & the TCP Port of Logstash. [E.x. 0.0.0.0:5044] => ' IPnPORT
# 	done
# /bin/sed -i s/0.0.0.0:5044/$IPnPORT/g /etc/filebeat/filebeat.yml
# echo -e " "

echo -e " "
echo "Starting up the filebeat.service"
systemctl daemon-reload
sleep 1
systemctl restart filebeat.service
systemctl is-active filebeat.service >/dev/null 2>&1 && echo "Congradulations.. Filebeat is now starting & sending logs" || echo "Something is Wrong.! Check the configuration"
