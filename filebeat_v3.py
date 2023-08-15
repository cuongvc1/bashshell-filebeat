#!/bin/sh

# Kiểm tra xem filebeat có tồn tại trong danh sách các tiến trình hay không
if pgrep -x "filebeat" > /dev/null; then
    # Kiểm tra xem dòng cấu hình đã tồn tại trong tệp cấu hình hay không
    if grep -q "/var/log/clamav/\*.log" /etc/filebeat/filebeat.yml; then 
    # Trả về giá trị 0 nếu dòng đã tồn tại
        echo "Done. Filebeat configurati"
    else 
    # Trả về giá trị 1 nếu dòng chưa tồn tại
        sleep 1
            sed -i "/paths:$/a\
            \  - /var/log/clamav/*.log" /etc/filebeat/filebeat.yml
            echo -e " "
            echo "Restart filebeat"
            systemctl daemon-reload
            sleep 1
            systemctl restart filebeat.service
            systemctl is-active filebeat.service >/dev/null 2>&1 && echo "Congradulations.. Filebeat is now starting & sending logs" || echo "Something is Wrong.! Check the configuration"
    fi
else # Trả về giá trị 1 nếu chưa cài đặt
    # Kiểm tra file /etc/os-release
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        if [[ $ID == "ubuntu" ]]; then
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

# Filebeat Config
cat <<END >/etc/filebeat/filebeat.yml
filebeat.inputs:
- enabled: true
  paths:
  - /var/log/clamav/*.log
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

            echo -e " "
            echo "Starting up the filebeat.service"
            systemctl daemon-reload
            sleep 1
            systemctl restart filebeat.service
            systemctl is-active filebeat.service >/dev/null 2>&1 && echo "Congradulations.. Filebeat is now starting & sending logs" || echo "Something is Wrong.! Check the configuration"
        elif [[ $ID == "centos" ]]; then
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
  - /var/log/clamav/*.log
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

            echo -e " "
            echo "Starting up the filebeat.service"
            systemctl daemon-reload
            sleep 1
            systemctl restart filebeat.service
            systemctl is-active filebeat.service >/dev/null 2>&1 && echo "Congradulations.. Filebeat is now starting & sending logs" || echo "Something is Wrong.! Check the configuration"

        elif [[ $ID == "rhel" ]]; then
            echo "3"
        else
            echo "Unknown distribution"
        fi
    else
        echo "Cannot determine the distribution"
    fi    
fi
