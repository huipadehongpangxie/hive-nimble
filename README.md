nimble ubuntu/hiveos 一键安装 命令
nimble 要做好翻墙 不然可能文件下载不下来
把下面命令中 nimblexxxxxxxxxxx 替换成自己的 钱包地址
wget https://raw.githubusercontent.com/huipadehongpangxie/hive-nimble/refs/heads/main/nim_setup.sh && chmod 777  nim_setup.sh && sudo ./nim_setup.sh nimblexxxxxxxxxxx

脚本已经设置自动开机启动 
因为现在新版nimnleminer 无法输出日志 所以 用了screen 查看运行情况
screen -r miners  查看运行情况
ctrl A+D 切出当前窗口 程序继续运行
ctrl +C 退出当前程序 

systemctl restart nim 重启挖矿程序
systenctl stop nim 退出挖矿程序
systemctl start nim 开始挖矿程序
systemctl disable nim 关闭开机启动
systemctl enable nim 开启开机启动
