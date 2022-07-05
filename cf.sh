#!/usr/bin/env bash
echo "开始读取配置"
LOCAL_IP=local_ip
#配置文件位置
IP_POOL=./ip_pool.txt
TG_BOT_TOKEN=5xxxxxxxeb5gyryswoZxv0
TG_CHATID=56255xxxxxxxxxx8393
CFKEY=619d0xxxxxxxxxxxxdd734c
CFUSER=cxxxxxxxz@xx.com
CFZONE_NAME=xxx.com
CFRECORD_NAME=x.xxx.com
CFRECORD_TYPE=A
CFTTL=120

# 获取 zone_id
CFZONE_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$CFZONE_NAME" \
-H "X-Auth-Email: $CFUSER" \
-H "X-Auth-Key: $CFKEY" \
-H "Content-Type: application/json" | grep -Po '(?<="id":")[^"]*' | head -1 )
echo $CFZONE_ID

#获取解析记录IP池存到文件
curl -X GET "https://api.cloudflare.com/client/v4/zones/$CFZONE_ID/dns_records?type=A&name=$CFRECORD_NAME&proxied=false&page=1&per_page=100&order=type&direction=desc&match=all" \
      -H "X-Auth-Email: $CFUSER" \
      -H "X-Auth-Key: $CFKEY" \
      -H "Content-Type: application/json" | grep -Po '(?<="content":")[^"]*' > ./ip_records.txt

#判断地址池连通性
for line in $(cat $IP_POOL)
do
echo $(cat $IP_POOL)
  

# 地址池更新
if ping -c 1 $line >/dev/null 
then
  if [ "$(echo $(cat ./ip_records.txt) | grep $line)" != "" ]; then
    echo "IP：$line已在解析记录中，退出"
    continue
  fi
  echo "添加一条新的$CFRECORD_TYPE类型解析记录 $CFRECORD_NAME:$line"
  RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$CFZONE_ID/dns_records" \
  -H "X-Auth-Email: $CFUSER" \
  -H "X-Auth-Key: $CFKEY" \
  -H "Content-Type: application/json" \
  --data "{\"id\":\"$CFZONE_ID\",\"type\":\"$CFRECORD_TYPE\",\"name\":\"$CFRECORD_NAME\",\"content\":\"$line\", \"ttl\":$CFTTL,\"proxied\":false}")  
  curl -s "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage?chat_id=添加一条新的$CFRECORD_TYPE类型解析记录 $CFRECORD_NAME:$line"
else
#删除失联IP
  echo "删除失联IP:$line"
  echo $CFZONE_ID
  echo $CFRECORD_NAME
  echo $line
  RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/96ad77e8f34c99b55fcce6fd44ac63ba/dns_records?name=azhk.abcdccaatt.com&content=2.2.2.2" \
  -H "X-Auth-Email: $CFUSER" \
  -H "X-Auth-Key: $CFKEY" \
  -H "Content-Type: application/json" | grep -Po '(?<="id":")[^"]*' | head -1)
  echo $RECORD_ID
  RESPONSE=$(curl -s -X DELETE "https://api.cloudflare.com/client/v4/zones/$CFZONE_ID/dns_records/$RECORD_ID" \
  -H "X-Auth-Email: $CFUSER" \
  -H "X-Auth-Key: $CFKEY" \
  -H "Content-Type: application/json")
  echo $RESPONSE
  curl -s "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage?chat_id=删除了失联的解析IP:$line"
fi
if [ "$RESPONSE" != "${RESPONSE%success*}" ] && [ "$(echo $RESPONSE | grep "\"success\":true")" != "" ]; then

  echo "成功"
else

  echo 
  echo "错误信息: $RESPONSE"
fi
done
