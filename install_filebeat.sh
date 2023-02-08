#!/bin/sh
echo "1. infrastructure
2. cloud_platform
3. cloud_services"
read -e -p 'Please choose for index_name, 1 or 2 or 3. [E.x. infrastructure || cloud_platform || cloud_services ] => ' team

if [ $team == 1 ]
then
    curl -o filebeat_security_system.sh https://raw.githubusercontent.com/cuongvc1/bashshell-filebeat/main/filebeat_cloud_service.sh
    bash filebeat_security_system.sh
else
if [ $team == 2 ]
then
    curl -o filebeat_cloud_platform.sh https://raw.githubusercontent.com/cuongvc1/bashshell-filebeat/main/filebeat_cloud_platform.sh 
    bash filebeat_cloud_platform.sh 
else
if [ $team == 3 ]
then
    curl -o filebeat_cloud_service.sh https://raw.githubusercontent.com/cuongvc1/bashshell-filebeat/main/filebeat_cloud_service.sh 
    bash filebeat_cloud_service.sh
else
    exit 0
fi
fi
fi