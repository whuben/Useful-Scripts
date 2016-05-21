#!/bin/bash
#add a server for ctf pwn on xinetd
#
#written by ben 
#2016/05/20
#
if [ $# != 3 ]
then
	echo "Usage: $addpwn.sh [pwn_path] [port] [flag]"
	echo "   eg: $addpwn.sh /home/test/example.bin 40001 flag{test}" 
	exit 0
fi
path=$1
port=$2
flag=$3
pwn_base_dir="/home/test/pwn"  #need to be configured
services_path="/etc/services"  #the path of services by default
xinetd_path="/etc/xinetd.d"    #the configure directory of xinetd by default
if [ ! -f $path ]
then 
    echo "File: \"$path\" does not exist!"
    exit 0
fi
pwn_name=${path##*/}
if [ -z $pwn_name ];then
	echo "File name is null!"
	exit
fi
pwn_dir=${pwn_base_dir}"/"${pwn_name}
pwn_path=${pwn_dir}"/"${pwn_name}
echo "[*]Creating the directory:\"$pwn_dir\""
mkdir $pwn_dir
echo "[*]Copy the pwn binary from \"$path\" to \"$pwn_dir\""
sudo cp $path $pwn_dir
temp_user="ctf_user$RANDOM"
while id -u $temp_user >/dev/null 2>&1
do 
   temp_user="ctf_user$RANDOM"
done
echo "[*]Creating a new temp user \"$temp_user\" for executing the pwn binary"
sudo useradd $temp_user
echo "[*]Change the user group of the pwn file:\"$pwn_path\""
sudo chgrp $temp_user $pwn_path
echo "[*]Change the previlige of the pwn file:\"$pwn_path\""
sudo chmod 755 $pwn_path
flag_path=${pwn_dir}"/flag"
echo "[*]Creating a flag file:\"$flag_path\" for storing the flag"
echo $flag > $flag_path
echo "[*]Change the user group of the flag file:\"$flag_path\""
sudo chgrp $temp_user $flag_path
echo "[*]Change the previlige of the flag file:\"$flag_path\""
sudo chmod 640 $flag_path
echo "[*]Register a server on xinetd"
echo "---------------------------------"
echo "Creating the configure file: \"$xinetd_path/$pwn_name\""
config_xinetd_str=""
printf 'service %s\n{
    disable     = no\n
    socket_type = stream\n
    protocol    = tcp\n
    user        = %s\n
    server      = %s\n
    wait        = no\n
}\n' $pwn_name $temp_user $pwn_path | sudo tee -a $xinetd_path/$pwn_name 
echo "[*]Register a port for the pwn server"
printf "%-16s%s/tcp%48s\n" $pwn_name $port "#add the ctf server port"| sudo tee -a $services_path
#restart the xinetd
echo "[*]Restart the xinetd service"
sudo /etc/init.d/xinetd restart
echo "[*]Complete: try to connect:127.0.0.1:$port"

