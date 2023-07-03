# BlackBox 

## Download

````bash
sudo useradd --no-create-home --shell /bin/false blackbox_exporter
https://github.com/prometheus/blackbox_exporter/releases #check last release and download into /opt
sha256sum blackbox_exporter.tgz # check checksum 
cd /opt/
tar xvfz blackbox_exporter.tgz
cd /opt/blackbox_exporter
cp ./blackbox_exporter /usr/local/bin
chown blackbox_exporter:blackbox_exporter /usr/local/bin/blackbox_exporter
rm -rf ./blackbox_exporter-0.12.0.linux-amd64.tar.gz ~/blackbox_exporter-0.12.0.linux-amd64

````

## Install

````bash
mkdir /etc/blackbox_exporter
chown blackbox_exporter:blackbox_exporter /etc/blackbox_exporter -R
vim /etc/blackbox_exporter/blackbox.yml
````

````yaml
modules:
  http_2xx:
    prober: http
  http_post_2xx:
    prober: http
    http:
      method: POST
  tcp_connect:
    prober: tcp
  pop3s_banner:
    prober: tcp
    tcp:
      query_response:
      - expect: "^+OK"
      tls: true
      tls_config:
        insecure_skip_verify: false
  ssh_banner:
    prober: tcp
    tcp:
      query_response:
      - expect: "^SSH-2.0-"
      - send: "SSH-2.0-blackbox-ssh-check"
  irc_banner:
    prober: tcp
    tcp:
      query_response:
      - send: "NICK prober"
      - send: "USER prober prober prober :prober"
      - expect: "PING :([^ ]+)"
        send: "PONG ${1}"
      - expect: "^:[^ ]+ 001"
  icmp:
    prober: icmp
      
````

## Make Service File

````bash
vim     /etc/systemd/system/blackbox_exporter.service

[Unit]
Description=Blackbox Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=blackbox_exporter
Group=blackbox_exporter
Type=simple
ExecStart=/usr/local/bin/blackbox_exporter --config.file /etc/blackbox_exporter/blackbox.yml

[Install]
WantedBy=multi-user.target
````

## Start Service

````bash

systemctl daemon-reload
systemctl enable blackbox_exporter --now
systemctl status blackbox_exporter
````

# prometheus

````bash
mkdir /etc/prometheus
mkdir /var/lib/prometheus
useradd --no-create-home --shell /bin/false prometheus
chown -R prometheus:prometheus /var/lib/prometheus

````

## Download 

````bash
cd /opt/
wget https://github.com/prometheus/prometheus/releases/download/v2.32.1/prometheus-2.32.1.linux-amd64.tar.gz # dowanload the latest version and check hash
tar xvfz prometheus-2.32.1.linux-amd64.tar.gz 
````

## Install 

````bash
cd prometheus-2.32.1.linux-amd64
cp ./prometheus /usr/local/bin/
cp ./promtool /usr/local/bin/
chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool
cp -r ./consoles /etc/prometheus
cp -r ./console_libraries /etc/prometheus
cp ./prometheus.yml /etc/prometheus/prometheus.yml
chown -R prometheus:prometheus /etc/prometheus/

````

## Make Service File

````bash
vim /etc/systemd/system/prometheus.service

[Unit]
Description=Prometheus
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
    --web.console.libraries=/etc/prometheus/console_libraries \
    --web.external-url http://localhost

[Install]
WantedBy=multi-user.target
````

## Enable SSL (optional)

- Generate self-signed certificate

  ````bash
  openssl req   -x509   -newkey rsa:4096   -nodes   -keyout monitor.bpabanx.com.key -out your_domain_name.crt
  ````

  

````bash
vim /etc/prometheus/web-config.yml
tls_server_config:
  cert_file: /etc/prometheus/ssl/CERT_FILE.crt
  key_file:  /etc/prometheus/ssl/PRIVATE_FILE.key
basic_auth_users:
        admin: YOUR-HASH-PASS
````

- If you need to enable authentication, you must make a hash password (bcrypt format) with below command

  ````bash
  htpasswd -nBC 12 '' | tr -d ':\n'       
  New password:
  Re-type new password:                                              
  $2y$12$WLw2sYa.NYZoBVoCOE84qe3xNm7kbSoKVIBXP.PvqNDna60vnZhEW
  ````

- You can also use python library to produce hash password

  ````bash
  python -c 'import bcrypt; print(bcrypt.hashpw(b"<YOUR-PASSWORD>", bcrypt.gensalt(rounds=15)).decode("ascii"))'
  ````

- Change service file 

  ````bash
  vim /etc/systemd/system/prometheus.service
  # addd below line to ExecStart
      --web.config.file /etc/prometheus/web-config.yml \
  # change below line in ExecStart
  --web.external-url https://your_domain_name
  ````

- If you enable SSL and password in prometheus, you should reconfig `grafana` and set password and https url

- If you enable SSL, you should change default config of prometheus

  ````bash
  vim /etc/prometheus/prometheus.yml
    - job_name: "prometheus"
      scheme: https
      tls_config:
         insecure_skip_verify: true
      basic_auth:
        username: admin
        password: <CLEAR_PASSWORD>
  
      # metrics_path defaults to '/metrics'
      # scheme defaults to 'http'.
  
      static_configs:
        - targets: ["localhost:9090"]
  
  ````

  

## Start Service

````bash
systemctl daemon-reload
systemctl enable prometheus --now
systemctl status prometheus
````



# Grafana

````bash
useradd -r  -d /usr/share/grafana -s /sbin/nologin     -c "grafana user" grafana
````

## Download

````bash
cd /opt
wget https://grafana.com/grafana/download?edition=oss # download the latest version 
````

## Install

````bash
wget https://dl.grafana.com/oss/release/grafana-8.3.4.linux-amd64.tar.gz
tar xvfz grafana-8.3.4.tgz
rm  grafana-8.3.4.tgz -f
cd grafana-8.3.4

mkdir -p /usr/share/grafana/ /var/lib/grafana/plugins /etc/grafana /var/log/grafana
cp -r . /usr/share/grafana
cp -r config/* /etc/grafana
cp -r plugins/* /var/lib/grafana/plugins/
cp conf/sample.ini /etc/grafana/grafana.ini
cp bin/grafana-server bin/grafana-cli /usr/local/bin 


````

## Make config files

````bash
vim /etc/sysconfig/grafana-server

GRAFANA_USER=grafana

GRAFANA_GROUP=grafana

GRAFANA_HOME=/usr/share/grafana

LOG_DIR=/var/log/grafana

DATA_DIR=/var/lib/grafana

MAX_OPEN_FILES=10000

CONF_DIR=/etc/grafana

CONF_FILE=/etc/grafana/grafana.ini

RESTART_ON_UPGRADE=true

PLUGINS_DIR=/var/lib/grafana/plugins

PROVISIONING_CFG_DIR=/etc/grafana/provisioning

# Only used on systemd systems
PID_FILE_DIR=/var/run/grafana

````



## Change owner of files

````bash
chown grafana:grafana -R  /var/lib/grafana/ /etc/grafana/provisioning  /etc/grafana/ /usr/local/bin/grafana-* /usr/share/grafana/  /var/log/grafana/   
````

## Make service file

````bash
vim /etc/systemd/system/grafana.service
[Unit]
Description=Grafana instance
Documentation=http://docs.grafana.org
Wants=network-online.target
After=network-online.target
After=postgresql.service mariadb.service mysqld.service

[Service]
EnvironmentFile=/etc/sysconfig/grafana-server
User=grafana
Group=grafana
Type=notify
Restart=on-failure
WorkingDirectory=/usr/share/grafana
RuntimeDirectory=grafana
RuntimeDirectoryMode=0750
ExecStart=/usr/local/bin/grafana-server                                                  \
                            --config=${CONF_FILE}                                   \
                            --pidfile=${PID_FILE_DIR}/grafana-server.pid            \
                            cfg:default.paths.logs=${LOG_DIR}                       \
                            cfg:default.paths.data=${DATA_DIR}                      \
                            cfg:default.paths.plugins=${PLUGINS_DIR}                \
                            cfg:default.paths.provisioning=${PROVISIONING_CFG_DIR}

LimitNOFILE=10000
TimeoutStopSec=20
CapabilityBoundingSet=
DeviceAllow=
LockPersonality=true
MemoryDenyWriteExecute=false
NoNewPrivileges=true
PrivateDevices=true
PrivateTmp=true
ProtectClock=true
ProtectControlGroups=true
ProtectHome=true
ProtectHostname=true
ProtectKernelLogs=true
ProtectKernelModules=true
ProtectKernelTunables=true
ProtectProc=invisible
ProtectSystem=full
RemoveIPC=true
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX
RestrictNamespaces=true
RestrictRealtime=true
RestrictSUIDSGID=true
SystemCallArchitectures=native
UMask=0027

[Install]
WantedBy=multi-user.target
````

## Enable SSL(optional)

````bash
vim /etc/grafana/grafana.ini
[server]
#protocol = http
protocol = https

cert_file = /etc/grafana/ssl/CERT_FILE.crt
cert_key = /etc/grafana/ssl/PRIVATE_KEY.key


````

- Please change default password after login.

## Start Grafana service

````bash
systemctl daemon-reload
systemctl enable grafana --now
systemctl status grafana
````

- Remove unnecessary files





# AlertManager

````bash
useradd --no-create-home --shell /bin/false alertmanager
mkdir /etc/alertmanager
mkdir /var/lib/alertmanager
````



## Download

````bash
cd /opt/
wget https://github.com/prometheus/alertmanager/releases/download/v0.23.0/alertmanager-0.23.0.linux-amd64.tar.gz # dowanload the latest version and check hash
tar xvfz alertmanager-0.23.0.linux-amd64.tar.gz
````

## Install

````bash
cd alertmanager-0.23.0.linux-amd64.
cp ./alertmanager /usr/local/bin/
cp ./amtool /usr/local/bin/amtool
cp ./alertmanager.yml /etc/alertmanager/
chown alertmanager:alertmanager /usr/local/bin/alertmanager
chown alertmanager:alertmanager /usr/local/bin/amtool
chown -R alertmanager:alertmanager /etc/alertmanager/
chown -R alertmanager:alertmanager /var/lib/alertmanager
````



## Make Service File

- Please note that to `--web.external-url `

````bash
vim /etc/systemd/system/alertmanager.service

[Unit]
Description=Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple
WorkingDirectory=/etc/alertmanager/
ExecStart=/usr/local/bin/alertmanager --config.file=/etc/alertmanager/alertmanager.yml --web.external-url http://localhost:9093

[Install]
WantedBy=multi-user.target
````



## Start Service

````bash
systemctl daemon-reload
systemctl enable alertmanager --now
systemctl status alertmanager
````



# sachet

## Compile

````bash
yum install go
go get github.com/messagebird/sachet/cmd/sachet


# or download binary  in https://github.com/messagebird/sachet/releases

````

## Install 

````bash
mkdir /etc/sachet
useradd --no-create-home --shell /bin/false sachet
cd ~/go/bin/
cp sachet /usr/local/bin
chown sachet:sachet /usr/local/bin/sachet 
chown -R sachet:sachet /etc/sachet  
````

## Config

````bash
cd /etc/sachet
wget https://github.com/messagebird/sachet/blob/master/examples/config.yaml  
vim /etc/sachet/config.yaml

providers:
        
        
  kavenegar:
    api_token: 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
templates:
  - telegram.tmpl

receivers:
  - name: 'kavenegar'
    provider: 'kavenegar'
    #  from: '10008663'
    to:
     - '09380956874'


````

## Make service file

````bash
vim /etc/systemd/system/sachet.service

[Unit]
Description=Sachet: SMS center for prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=sachet
Group=sachet
Type=simple
WorkingDirectory=/etc/sachet/
ExecStart=/usr/local/bin/sachet -config /etc/sachet/config.yaml

[Install]
WantedBy=multi-user.target

````

## Start service

````bash
chown -R sachet:sachet /etc/sachet
systemctl daemon-reload
systemctl enable sachet.service --now
systemctl status sachet
````

### Change in alert manager

- You should change alter manager to send request to `sachet` webhook. Please note you should enable `blackbox` config for icmp in `prometheus` config

- READ this link : https://github.com/prometheus/blackbox_exporter#permissions

  ```bash
  $> vim /etc/alertmanager/alertmanager
  route:
    group_by: ['instance', 'severity']
    group_wait: 30s
    group_interval: 5m
    repeat_interval: 3h
    receiver: 'kavenegar'
  receivers:
  - name: 'kavenegar'
    webhook_configs:
            #- url: 'http://127.0.0.1:5001'
      - url: 'http://localhost:9876/alert'
  inhibit_rules:
    - source_match:
        severity: 'critical'
      target_match:
        severity: 'warning'
      equal: ['alertname', 'dev', 'instance']
  
  
  
  ```

- Define new `icmp rules` to catch down device

  ```bash
  $> vim /etc/prometheus/icmp_rules.yml
  groups:
  - name: alert.rules
    rules:
    - alert: InstanceDown
      expr: probe_icmp_duration_seconds{phase="resolve"} == 0
      for: 1m
      labels:
        severity: "critical"
      annotations:
        summary: "The link {{ $labels.instance }} is down"
        # description: "{{ $labels.instance }} ob {{ $labels.job }} has been down for more than 1 minutes."
  ```

- Add `icmp_rules` to `prometheus.yml`

  ```bash
  # Alertmanager configuration
  alerting:
    alertmanagers:
      - static_configs:
          - targets:
             - localhost:9093
  
  # Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
  rule_files:
     - icmp_rules.yml
  
  ```

  



## Windows Exporter



- Download windows exporter from https://github.com/prometheus-community/windows_exporter/releases (MSI file)

- In order to enable https, you need to certificate and private key file. For making self-signed certificate, you can use below command

  ````bash
  openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 -keyout node_exporter.key -out node_exporter.crt -subj "/C=CN/IR=Tehran/L=Tehran/O=example.info/CN=localhost"
  ````

- If you need to enable authentication, you must make a hash password (bcrypt format) with below command

  ````bash
  htpasswd -nBC 12 '' | tr -d ':\n'       
  New password:
  Re-type new password:                                              
  $2y$12$WLw2sYa.NYZoBVoCOE84qe3xNm7kbSoKVIBXP.PvqNDna60vnZhEW
  ````

- You can also use python library to produce hash password

  ````bash
  python -c 'import bcrypt; print(bcrypt.hashpw(b"<YOUR-PASSWORD>", bcrypt.gensalt(rounds=15)).decode("ascii"))'
  ````

- Make a `config` file 

  ````bash
  vim config.yml
  # TLS and basic authentication configuration example.
  #
  # Additionally, a certificate and a key file are needed.
  tls_server_config:
    cert_file: c:\ssl\node_exporter.crt
    key_file: c:\ssl\node_exporter.key
  
  # Usernames and passwords required to connect.
  # Passwords are hashed with bcrypt: https://github.com/prometheus/exporter-toolkit/blob/master/docs/web-configuration.md#about-bcrypt.
  basic_auth_users:
      admin: $2y$12$WLw2sYa.NYZoBVoCOE84qe3xNm7kbSoKVIBXP.PvqNDna60vnZhE
  ````

  - You can add another config and change IP and port. More info at https://github.com/prometheus-community/windows_exporter

- Install: Run MSI file in `cmd`  console with administrator privilege 

  ````bash
  msiexec /i c:\download\windows_exporter-0.18.1-amd64.msi
   EXTRA_FLAGS="--web.config.file=""c:\your-directory\config.yml"""
  ````

- Test connection:

  ````bash
  $> curl -Ik https://<WINDOWS-IP>:9182/metrics 
  HTTP/1.1 401 Unauthorized
  Content-Type: text/plain; charset=utf-8
  Www-Authenticate: Basic
  X-Content-Type-Options: nosniff
  Date: Wed, 27 May 2020 11:45:16 GMT
  Content-Length: 13
  ````

  ````bash
  $> curl -s  --cacert node_exporter.crt https://<WINDOWS-IP>:9182/metrics 
  HTTP/1.1 401 Unauthorized
  Content-Type: text/plain; charset=utf-8
  Www-Authenticate: Basic
  X-Content-Type-Options: nosniff
  Date: Wed, 27 May 2020 11:45:16 GMT
  Content-Length: 13
  ````

- You can use `14499` or `10467` as a Grafana dashboard ID.

- Connect to  Prometheus server and edit config

  ```` bash 
  $> vim /etc/prometheus/prometheus.yml 
  ## add new job 
    - job_name: node_windows
      scheme: https
      tls_config:
         #      ca_file: /etc/prometheus/win_client.crt
         insecure_skip_verify: true
      basic_auth:
        username: admin
        password: <YOUR_PASSWORD>
      static_configs:
        - targets: ['win1-client:9182','win2-client:9182']
  
  ````

- More info at https://developpaper.com/add-authentication-to-prometheus-node-exporter/

### Linux exporter

- Download latest version of node exporter from https://prometheus.io/download/#node_exporter

- In order to enable https, you need to certificate and private key file. For making self-signed certificate, you can use below command

  ````bash
  $> mkdir /etc/node_exporter
  $> cd /etc/node_exporter/
  # you can create certificate in another linux system
  $> openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 -keyout node_exporter.key -out node_exporter.crt -subj "/C=CN/IR=Tehran/L=Tehran/O=example.info/CN=localhost"  
  ````

- If you need to enable authentication, you must make a hash password (bcrypt format) with below command

  ````bash
  $> htpasswd -nBC 12 '' | tr -d ':\n'       
  New password:
  Re-type new password:                                              
  $2y$12$WLw2sYa.NYZoBVoCOE84qe3xNm7kbSoKVIBXP.PvqNDna60vnZhEW
  ````

- You can also use python library to produce hash password

  ````bash
  python -c 'import bcrypt; print(bcrypt.hashpw(b"<YOUR-PASSWORD>", bcrypt.gensalt(rounds=15)).decode("ascii"))'
  ````

- Make a `config` file 

  ````bash
  $> cd /etc/node_exporter
  $> vim config.yml
  # TLS and basic authentication configuration example.
  #
  # Additionally, a certificate and a key file are needed.
  tls_server_config:
    cert_file: /etc/node_exporter/node_exporter.crt
    key_file: /etc/node_exporter/node_exporter.key
  
  # Usernames and passwords required to connect.
  # Passwords are hashed with bcrypt: https://github.com/prometheus/exporter-toolkit/blob/master/docs/web-configuration.md#about-bcrypt.
  basic_auth_users:
      admin: $2y$12$WLw2sYa.NYZoBVoCOE84qe3xNm7kbSoKVIBXP.PvqNDna60vnZhE
  
  ````

  - You can add another config and change IP and port. More info at https://github.com/prometheus/node_exporter

- Install : 

  ````bash
  $> tar xvfz node_exporter-1.3.1.linux-amd64.tar.gz -C /opt
  $> cp /opt/node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/
  ````

- Make a user and add service file

  ````bash
  $> useradd -r  -d /usr/share/node_exporter -s /sbin/nologin     -c "node exporter user" node_exporter
  
  $> vim /etc/systemd/system/node_exporter.service
  [Unit]
  Description=Node Exporter
  Wants=network-online.target
  After=network-online.target
  
  [Service]
  User=node_exporter
  Group=node_exporter
  Type=simple
  ExecStart=/usr/local/bin/node_exporter --web.config=/etc/node_exporter/config.yml
  
  [Install]
  WantedBy=multi-user.target
  
  ````

- Change ownership

  ````bash
  $> chown node_exporter:node_exporter /etc/node_exporter/  /usr/local/bin/node_exporter -R 
  ````

- Start service

  ````bash
  $> systemctl daemon reload
  $> systemctl enable node_exporter --now
  ````

- You can use `1860`  as a Grafana dashboard ID.

- Connect to  Prometheus server and edit config

  ````bash
  vim /etc/prometheus/prometheus.yml 
  ## add new job 
    - job_name: node_linux
      scheme: https
      tls_config:
         #      ca_file: /etc/prometheus/win_client.crt
         insecure_skip_verify: true
      basic_auth:
        username: admin
        password: <YOUR_PASSWORD>
      static_configs:
        - targets: ['linux1-client:9100','linux2-client:9100']
  ````

### SNMP exporter

- SNMP exporter is a open source project. You can download it from https://github.com/prometheus/snmp_exporter/releases

- Install:

  ````bash
  $> tar xvfz snmp-exporter.tgz 
  $> cp snmp-exporter/snmp_exporter.linux-amd64/snmp_exporter /usr/local/bin/
  $> mkdir /etc/snmp_exporter && cp snmp-exporter/snmp_exporter.linux-amd64/snmp.yml /etc/snmp|_exporter/ && rm ./snmp-exporter* -rf
  $> adduser  --shell=/bin/false --no-create-home snpm_exporter
  ````

- In order to enable https, you need to certificate and private key file. For making self-signed certificate, you can use below command

  ````bash
  $> cd /etc/snmp_exporter/
  $> openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 -keyout snmp_exporter.key -out snmp_exporter.crt -subj "/C=CN/IR=Tehran/L=Tehran/O=example.info/CN=localhost"
  ````

- If you need to enable authentication, you must make a hash password (bcrypt format) with below command

  ````bash
  $> htpasswd -nBC 12 '' | tr -d ':\n'       
  New password:
  Re-type new password:                                              
  $2y$12$WLw2sYa.NYZoBVoCOE84qe3xNm7kbSoKVIBXP.PvqNDna60vnZhEW
  ````

- You can also use python library to produce hash password

  ````bash
  python -c 'import bcrypt; print(bcrypt.hashpw(b"<YOUR-PASSWORD>", bcrypt.gensalt(rounds=15)).decode("ascii"))'
  ````

  ````bash
  $> vim /etc/snmp_exporter/config.yml
  # TLS and basic authentication configuration example.
  #
  # Additionally, a certificate and a key file are needed.
  tls_server_config:
    cert_file: /etc/snmp_exporter/snmp_exporter.crt
    key_file: /etc/snmp_exporter/snmp_exporter.key
  
  # Usernames and passwords required to connect.
  # Passwords are hashed with bcrypt: https://github.com/prometheus/exporter-toolkit/blob/master/docs/web-configuration.md#about-bcrypt.
  basic_auth_users:
      admin: $2y$12$WLw2sYa.NYZoBVoCOE84qe3xNm7kbSoKVIBXP.PvqNDna60vnZhE
  ````

  

- Config service file

  ````bash
  $> vim /etc/systemd/system/snmp_exporter.service 
  [Unit]
  Description=SNMP Exporter
  After=network-online.target
  
  # This assumes you are running snmp_exporter under the user "prometheus"
  
  [Service]
  User=snmp_exporter
  Restart=on-failure
  ExecStart=/usr/local/bin/snmp_exporter --web.listen-address="0.0.0.0:9116" --config.file='/etc/snmp_exporter/snmp.yml' --web.config.file='/etc/snmp_exporter/config.yml'
  
  [Install]
  WantedBy=multi-user.target
  
  ````

- In order to enable authentication for `mikrotik`,  you should define new community and set `md5` password  in `mikrotik` device and then change `snmp.yml`. More info at https://github.com/prometheus/snmp_exporter/tree/main/generator

  ````bash
  $> cd /etc/snmp_exporter
  $> cp snmp.yml snmp.yml.back
  $> vim smmp.yml # find mikrotik module and then add auth section like below
  mikrotik:
    walk:
    - 1.3.6.1.2.1.2
    - 1.3.6.1.2.1.25
    - 1.3.6.1.2.1.31
    - 1.3.6.1.4.1.14988
    - 1.3.6.1.4.1.2021.10.1.1
    - 1.3.6.1.4.1.2021.10.1.2
    get:
    - 1.3.6.1.2.1.1.1.0
    - 1.3.6.1.2.1.1.3.0
    version: 3
    auth:
      # Community string is used with SNMP v1 and v2. Defaults to "public".
      #community: my-snmp
  
      # v3 has different and more complex settings.
      # Which are required depends on the security_level.
      # The equivalent options on NetSNMP commands like snmpbulkwalk
      # and snmpget are also listed. See snmpcmd(1).
      username: my-snmp  # Required, no default. -u option to NetSNMP. in version 3, use community name for username field
      security_level: authNoPriv  # Defaults to noAuthNoPriv. -l option to NetSNMP.
                                    # Can be noAuthNoPriv, authNoPriv or authPriv.
      password: <CLEAR-YOUR-MD5Sum-PASSWORD>  # Has no default. Also known as authKey, -A option to NetSNMP.
                      # Required if security_level is authNoPriv or authPriv.
      auth_protocol: MD5  # MD5, SHA, SHA224, SHA256, SHA384, or SHA512. Defaults to MD5. -a option to NetSNMP.
                          # Used if security_level is authNoPriv or authPriv.
      priv_protocol: DES  # DES, AES, AES192, or AES256. Defaults to DES. -x option to NetSNMP.
                            # Used if security_level is authPriv.
    metrics:
  ...
  ...
  ...
  
  
  $> chown snmp_exporter:snmp_exporter /etc/snmp_exporter/ /usr/local/bin/snmp_exporter -R
  $> systemctl enable snmp_exporter --now
  ````

- You can add auth to another module

- Test snmp : https://robert.penz.name/820/how-to-configure-snmpv3-securely-on-mikrotik-routeros/

  `````bash
  snmpwalk -u my-snmp -A my-password -a MD5  -l authPriv 10.7.7.1 -v3
  `````

  

- Connect to  Prometheus server and edit config

  ````bash
  $> vim /etc/prometheus/prometheus.yml # add new job
   - job_name: snmap-monitor-mikrotik
     scheme: https
      tls_config:
              #      ca_file: /etc/prometheus/win_client.crt
         insecure_skip_verify: true
      basic_auth:
        username: admin
        password: <YOUR_PASSWORD>
  
      static_configs:
       - targets:
         -  172.19.0.2 # SNMP device.
            #- 172.21.0.4 # SNMP device.
    metrics_path: /snmp
      params:
        module: [mikrotik] # you can below module according to your device type
        # - apcups
        #  - arista_sw
        #  - cisco_wlc
        #  - ddwrt
        #  - if_mib
        #  - infrapower_pdu
        #  - keepalived
        #  - kemp_loadmaster
        #  - liebert_pdu
        #  - mikrotik
        #  - nec_ix
        #  - paloalto_fw
        #  - printer_mib
        #  - raritan
        #  - servertech_sentry3
        #  - servertech_sentry4
        #  - synology
        #  - ubiquiti_airfiber
        #  - ubiquiti_airmax
        #  - ubiquiti_unifi
        #  - wiener_mpod
      relabel_configs:
        - source_labels: [__address__]
          target_label: __param_target
        - source_labels: [__param_target]
          target_label: instance
        - target_label: __address__
          replacement: snmp-exporter.host:9116  # The SNMP exporter's real hostname:port
  
  
  $> systemctl restart prometheus
  ````

  
