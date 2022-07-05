# cf-dns-switch
基于 [BlueSkyXN](https://github.com/BlueSkyXN/DNS-AUTO-Switch)的修改自用版

该脚本功能：当主IP挂掉时将对应域名的DNS记录更新到备用IP，主IP恢复时切换回主IP，采用tcping检测，每次运行检测5次可按需更改。
可配置TGbot通知

# 配置说明

该脚本需要在/root目录下运行可以按需更改脚本中`/root/temp`和`$HOME`部分即可

1.在备用服务器上安装docker运行go-torch作为tcp检测
```shell
#外部端口可以随意，下方配置文件中需一起更改
docker run -d --name go-torch -p 8080:8080 neverbehave/go-torch
```

2.获取脚本
```shell 
wget https://github.com/olperson/cf-dns-switch/raw/main/cf.sh
```

3.修改脚本配置替换成你自己的，如果docker映射了非8080端口`PING_API`改成相应端口
```shell
PING_API=http://主IP:8080/ping
# Original IP 主IP
ORG_IP=x.x.x.x
# Failure IP  失败后IP
FAIL_IP=x.x.x.x1
# Telegram Bot Token
TG_BOT_TOKEN=5309775795:***********ryswoZxv0
# Telegram Chat ID
TG_CHATID=562******
# API key, see https://www.cloudflare.com/a/account/my-account,
# incorrect api-key results in E_UNAUTH error
CFKEY=6************add734c
# Username, eg: user@example.com
CFUSER=user@example.com
# Zone name, eg: example.com
CFZONE_NAME=example.com
# Hostname to update, eg: www.example.com
CFRECORD_NAME=www.example.com
# Record type, A(IPv4)|AAAA(IPv6), default IPv4
CFRECORD_TYPE=A
# Cloudflare TTL for record, between 120 and 86400 seconds
CFTTL=120
```
使用crontab定时执行即可
