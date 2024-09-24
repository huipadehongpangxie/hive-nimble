#!/bin/bash
currentPath=`pwd`
path=$HOME/nimble/nimble-miner-public
package=nimble-miner-public.tar.xz

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
 
[ ! -d "$HOME/nimble/nimble-miner-public" ] && mkdir -p $path
cd $path
[ -f "$package" ] && rm $package
wget -4 -O $package http://47.242.170.46/$package
tar -xzvf $package -C $path --strip-components 1
rm $package

NIMBLE_PUBKEY=$1
mkdir -p /etc/nimbleservice/
if [ ! -f /etc/nimbleservice/nimbleservice.conf ]; then
cat << EOF > /etc/nimbleservice/nimbleservice.conf
NIMBLE_PUBKEY=$1
EOF
fi

chmod +x $path/nimbleminer

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
