FILE=/etc/systemd/system/cicd.service

cat <<EOF >$FILE
[Unit]
Description=CICD
After=network.target

[Service]
Type=simple
WorkingDirectory=${PWD}
ExecStart=${PWD}/cicd
Restart=on-failure
RestartSec=15s
StandardOutput=file:${PWD}/main.log

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable cicd.service
systemctl start cicd.service