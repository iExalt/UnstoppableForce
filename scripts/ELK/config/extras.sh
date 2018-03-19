sleep 45s
cd /root
echo here
curl -O https://gist.githubusercontent.com/thisismitch/3429023e8438cc25b86c/raw/d8c479e2a1adcea8b1fe86570e42abab0f10f364/filebeat-index-template.json
echo here2
curl -X PUT 'http://localhost:9200/_template/filebeat?pretty' -d@filebeat-index-template.json
curl -L -O https://download.elastic.co/beats/dashboards/beats-dashboards-1.2.2.zip
unzip beats-dashboards-*.zip
cd beats-dashboards-*
sh load.sh
