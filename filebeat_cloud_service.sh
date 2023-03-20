#!/bin/sh

echo "1. ubuntu
2. centos"
read -e -p 'Chon OS-server 1 or 2. [E.x. Ubuntu || Centos] => ' os

if [ $os == 1 ]
then
    echo "You choose Ubuntu server)"
    echo -e "set up filebeat or edit filebeat"
    counter=0

    while [[ "$choose" != "1" ]] && [[ "$choose" != "2" ]] || [[ "$choose" == '' ]]
        do
            read -e -p 'Ban muon chon 1 or 2. [E.x. 1-setup || 2-edit] => ' choose
            counter=$((counter + 1))
            if [ $counter == 3 ]
            then
                exit 0
            fi
        done

    if [ $choose == 1 ]
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
  tags: cloud_services
  type: log
output.logstash:
  hosts: 
  - collectlog.infiniband.vn:5033
setup.template.settings:
  index.number_of_shards: 1
processors:
- add_host_metadata:
    when.not.contains.tags: forwarded
- add_cloud_metadata: null
- add_docker_metadata: null
- add_kubernetes_metadata: null
END

    sleep 1
    declare -a a
    echo -n "--------------------------------------------------------------------
Path mac dinh:
- /var/log/syslog
- /var/log/auth.log
Neu khong muon them path. Nhan phim 0 -> enter
Neu muon them path. Nhap so path muon xem log: "
    read n
    for ((i=1;i<=n;i++));
    do
        echo -n "paths[$i]= "
        read m
        a[$i]=$m
        sed -i "/paths:$/a\
        \    - $m" /etc/filebeat/filebeat.yml
        echo -e " "
    done

    echo -e " "
    echo "Starting up the filebeat.service"
    systemctl daemon-reload
    sleep 1
    systemctl restart filebeat.service
    systemctl is-active filebeat.service >/dev/null 2>&1 && echo "Congradulations.. Filebeat is now starting & sending logs" || echo "Something is Wrong.! Check the configuration"

else
if [ $os == 2 ]
then
    echo "You choose Centos server)"

    echo -e "set up filebeat or edit filebeat"
    counter=0

    while [[ "$choose" != "1" ]] && [[ "$choose" != "2" ]] || [[ "$choose" == '' ]]
        do
            read -e -p 'Ban muon chon 1 or 2. [E.x. 1-setup || 2-edit] => ' choose
        counter=$((counter + 1))
        if [ $counter == 3 ]
        then
            exit 0
        fi
    done

    if [ $choose == 1 ]
    then
        rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
        touch /etc/yum.repos.d/elastic.repo
#Create a file with a .repo extension 
cat <<END >/etc/yum.repos.d/elastic.repo
[elastic-8.x]
name=Elastic repository for 8.x packages
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
END
        yum install filebeat
        cd
        chown root:root /etc/filebeat/filebeat.yml
        systemctl start filebeat.service
        systemctl enable filebeat.service
    
# Filebeat Config
cat <<END >/etc/filebeat/filebeat.yml
filebeat.inputs:
- enabled: true
  paths:
  - /var/log/messages
  - /var/log/secure
  tags: cloud_services
  type: log
output.logstash:
  hosts: 
  - collectlog.infiniband.vn:5033
setup.template.settings:
  index.number_of_shards: 1
processors:
- add_host_metadata:
    when.not.contains.tags: forwarded
- add_cloud_metadata: null
- add_docker_metadata: null
- add_kubernetes_metadata: null
END

## su dung cmd de nhap path

    sleep 1
    declare -a a
    echo -n "--------------------------------------------------------------------
Path mac dinh: 
- /var/log/messages
- /var/log/secure
Neu khong muon them path. Nhan phim 0 -> enter
Neu muon them path. Nhap so path muon xem log: "
    read n
    for ((i=1;i<=n;i++));
    do
        echo -n "paths[$i]= "
        read m
        a[$i]=$m
        sed -i "/paths:$/a\
        \    - $m" /etc/filebeat/filebeat.yml
        echo -e " "
    done


    echo -e " "
    echo "Starting up the filebeat.service"
    systemctl daemon-reload
    sleep 1
    systemctl restart filebeat.service
    systemctl is-active filebeat.service >/dev/null 2>&1 && echo "Congradulations.. Filebeat is now starting & sending logs" || echo "Something is Wrong.! Check the configuration"
fi
fi
fi
