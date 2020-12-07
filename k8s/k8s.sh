#!/bin/bash
##############################setting#####################################

green="\e[32m";white="\e[0m";red="\e[31m";blue="\e[34m";yellow="\e[33m"
nowtime=`date "+%F %T"`
starttime=`date +'%Y-%m-%d %H:%M:%S'`

##############################setting#####################################

echo -e "${yellow}－－－－－以下說明－－－－－${white}"
echo -e "${yellow}執行$0 Kubernetes 系統安裝${white}"
echo -e "${yellow}適用於master node1 node2${white}"
echo -e "${yellow}由於會寫入檔案該腳本${white}${red}僅限執行一次${white}"
echo -e "${yellow}時間：$nowtime${white}" | tee -a log.txt
echo -e "${yellow}腳本將在十秒後開始．．．．．${white}"
sleep 10

##############################setting#####################################

var=`expr $var + 1`;num=`expr $num + 1`;
yum install wget net-tools vim bc bash-completion -y 
if [ "$?" = "0" ];then 
echo -e "${blue}${num} _ [ 安裝必要插件 ]${white} ${green}安裝成功${white}" | tee -a log.txt
else 
echo -e "${blue}${num} _ [ 安裝必要插件 ]${white} ${red}安裝失敗${white}" | tee -a log.txt
fi

var=`expr $var + 1`;num=`expr $num + 1`;
echo $1.$2 master | tee -a /etc/hosts ;echo $1.`echo "$2+1" | bc` node1 | tee -a /etc/hosts ;echo $1.`echo "$2+2" | bc` node2 | tee -a /etc/hosts
if [ "$?" = "0" ];then 
echo -e "${blue}${num} _ [ 設定主機名稱 ]${white} ${green}設定成功${white}" | tee -a log.txt
else 
echo -e "${blue}${num} _ [ 設定主機名稱 ]${white} ${red}設定失敗${white}" | tee -a log.txt
fi

var=`expr $var + 1`;num=`expr $num + 1`;
setenforce 0 ; sed -i 's@SELINUX=enforcing@SELINUX=disabled@' /etc/sysconfig/selinux
if [ "$?" = "0" ];then 
echo -e "${blue}${num} _ [ 設定禁用Selinux ]${white} ${green}設定成功${white}" | tee -a log.txt
else 
echo -e "${blue}${num} _ [ 設定禁用Selinux ]${white} ${red}設定失敗${white}" | tee -a log.txt
fi

var=`expr $var + 1`;num=`expr $num + 1`;
swapoff -a 
sed -i '$c #/dev/mapper/centos-swap swap                    swap    defaults        0 0' /etc/fstab
if [ "$?" = "0" ];then 
echo -e "${blue}${num} _ [ 設定禁用Swap ]${white} ${green}設定成功${white}" | tee -a log.txt
else 
echo -e "${blue}${num} _ [ 設定禁用Swap ]${white} ${red}設定失敗${white}" | tee -a log.txt
fi

var=`expr $var + 1`;num=`expr $num + 1`;
systemctl disable firewalld && systemctl stop firewalld
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-iptables = 1" >> /etc/sysctl.conf
modprobe br_netfilter
echo "br_netfilter" > /etc/modules-load.d/br_netfilter.conf
sysctl -p
lsmod | grep br_netfilter
if [ "$?" = "0" ];then 
echo -e "${blue}${num} _ [ 設定啟動／停用 iptables ]${white} ${green}設定成功${white}" | tee -a log.txt
else 
echo -e "${blue}${num} _ [ 設定啟動／停用 iptables ]${white} ${red}設定失敗${white}" | tee -a log.txt
fi


var=`expr $var + 1`;num=`expr $num + 1`;
yum install -y yum-utils device-mapper-persistent-data lvm2 1>/dev/null
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
cat << "EOF" > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
yum clean all && yum repolist -y
if [ "$?" = "0" ];then 
echo -e "${blue}${num} _ [ 添加docker-ce;k8s 來源 ]${white} ${green}添加成功${white}" | tee -a log.txt
else 
echo -e "${blue}${num} _ [ 添加docker-ce;k8s 來源 ]${white} ${red}添加失敗${white}" | tee -a log.txt
fi

var=`expr $var + 1`;num=`expr $num + 1`;
yum install docker-ce-18.09.8 --nogpgcheck -y 
systemctl enable docker && systemctl start docker
yum install kubelet-1.15.2 kubectl-1.15.2 kubeadm-1.15.2 --nogpgcheck --disableexcludes=kubernetes -y
systemctl enable kubelet.service
if [ "$?" = "0" ];then 
echo -e "${blue}${num} _ [ 安裝docker-ce;k8s 服務 ]${white} ${green}安裝成功${white}" | tee -a log.txt
else 
echo -e "${blue}${num} _ [ 安裝docker-ce;k8s 服務 ]${white} ${red}安裝失敗${white}" | tee -a log.txt
fi


endtime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);
echo -e "${green}執行時間：" $((end_seconds-start_seconds))"s${white}" | tee -a log.txt
echo -e "${green}將執行log檔案輸出至log.txt${white}"
