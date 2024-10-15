#!/bin/bash
currentPath=`pwd`
path=$HOME/nimble
sudo apt update && apt install git -y

# If you want to run as another user, please modify \$UID to be owned by this user
if [[ "$UID" -ne '0' ]]; then
  echo "Error: You must run this script as root!"; exit 1
fi

uninstall_package() {
  systemctl stop nim
  systemctl disable nim
  rm -rf /etc/nimbleservice/nimbleservice.conf
  rm -f /etc/systemd/system/nim.service
  rm -rf /root/nim.sh
  rm -rf $path
}
systemctl is-active --quiet nim && uninstall_package
#install
cat << EOF > /root/nim.sh
#!/bin/sh
cd /root/nimble/nimble-miner-public
screen -S "miners" -dm bash -c "./nimbleminer"
EOF
chmod +x /root/nim.sh
 
[ ! -d "$HOME/nimble" ] && mkdir -p $path
cd $path
git clone https://github.com/nimble-technology/nimble-miner-public.git

NIMBLE_PUBKEY=$1
mkdir -p /etc/nimbleservice/
if [ ! -f /etc/nimbleservice/nimbleservice.conf ]; then
cat << EOF > /etc/nimbleservice/nimbleservice.conf
NIMBLE_PUBKEY=$1
EOF
fi

chmod +x $path/nimble-miner-public/nimbleminer

cat << EOF > /etc/systemd/system/nim.service
[Unit]
Description=Nim Service
After=network-online.target
Wants=network-online.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
StandardOutput=file:/var/log/nim.log
ExecStart=/root/nim.sh
Restart=on-failure
RestartPreventExitStatus=23
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

systemctl enable nim
systemctl start nim
cd $currentPath
[ -f "nim_setup.sh" ] && rm nim_setup.sh
