#!/bin/bash
source info.sh 



#-4.上传服务器------------------------------------------------------------------------------------------------------------------------------
# 请提前copy sshid 到服务器 （ssh-copy-id）
echo "开始cp到服务器"

echo "正在上传到服务器"
echo "请稍等。。。"

scp $local_ipa_path $server_path


echo "cp到服务器成功"