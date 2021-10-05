#!/bin/bash
sudo useradd --no-create-home --shell /usr/sbin/nologin prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus
sudo apt-get update && apt-get upgrade
wget https://github.com/prometheus/prometheus/releases/download/v2.26.0/prometheus-2.26.0.linux-amd64.tar.gz
tar xfz prometheus-*.tar.gz
cd prometheus-2.26.0.linux-amd64
sudo cp ./prometheus /usr/local/bin/
sudo cp ./promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
sudo cp -r ./consoles /etc/prometheus
sudo cp -r ./console_libraries /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
cd .. && rm -rf prometheus*
sudo touch /etc/prometheus/prometheus.yml
sudo echo "global:
        scrape_interval: 15s
        evaluation_interval: 15s

      rule_files:
        # - \"first.rules\"
        # - \"second.rules\"

      scrape_configs:
        - job_name: \"prometheus\"
          scrape_interval: 5s
          static_configs:
            - targets: [\"localhost:9090\"]
        - job_name: \"substrate_node\"
          scrape_interval: 5s
          static_configs:
            - targets: [\"localhost:9615\"]" > /etc/prometheus/prometheus.yml
sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml
sudo touch /etc/systemd/system/prometheus.service
sudo echo "[Unit]
             Description=Prometheus Monitoring
             Wants=network-online.target
             After=network-online.target

           [Service]
             User=prometheus
             Group=prometheus
             Type=simple
             ExecStart=/usr/local/bin/prometheus \
             --config.file /etc/prometheus/prometheus.yml \
             --storage.tsdb.path /var/lib/prometheus/ \
             --web.console.templates=/etc/prometheus/consoles \
             --web.console.libraries=/etc/prometheus/console_libraries
             ExecReload=/bin/kill -HUP \$MAINPID

           [Install]
             WantedBy=multi-user.target" > /etc/systemd/system/prometheus.service
sudo systemctl daemon-reload && sudo systemctl enable prometheus && sudo systemctl start prometheus
sudo apt-get install -y apt-transport-https
sudo apt-get install -y software-properties-common wget
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install grafana
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
