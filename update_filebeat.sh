sleep 1
    sed -i "/paths:$/a\
    \  - /var/log/clamav/*.log" /etc/filebeat/filebeat.yml
    echo -e " "

    echo -e " "
    echo "Starting up the filebeat.service"
    systemctl daemon-reload
    sleep 1
    systemctl restart filebeat.service
    systemctl is-active filebeat.service >/dev/null 2>&1 && echo "Congradulations.. Filebeat is now starting & sending logs" || echo "Something is Wrong.! Check the configuration"
