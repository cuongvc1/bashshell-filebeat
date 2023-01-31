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
fi

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
- add_cloud_metadata: {}
- add_docker_metadata: {}
- add_kubernetes_metadata: {}
END

# tags: ["testTag"]

## su dung cmd de nhap path

sleep 1
declare -a a
echo -n "Nhap so path muon xem log: "
read n
for ((i=1;i<=n;i++));do
	echo -n "Path[$i]= "
	read m
	a[$i]=$m
	sed -i "/paths:$/a\ - $m" /etc/filebeat/filebeat.yml
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



# sleep 1
# read -e -p 'tag of logs. [E.x. testTag] => ' TAG1
# /bin/sed -i s/testTag/$TAG1/g /etc/filebeat/filebeat.yml
# echo -e " "

echo -e " "
echo "Starting up the filebeat.service"
systemctl daemon-reload
sleep 1
systemctl start filebeat.service
systemctl is-active filebeat.service >/dev/null 2>&1 && echo "Congradulations.. Filebeat is now starting & sending logs" || echo "Something is Wrong.! Check the configuration"
