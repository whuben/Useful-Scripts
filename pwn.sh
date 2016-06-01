#!/bin/bash
#shell scripts for implementing pwn subjects in a CTF
#
#written by ben 
#2016/05/31
#
#basic setting
xinetd_path="/etc/xinetd.d"   #the configure directory of xinetd by default 
services_path="/etc/services" #the path of services by default
pwn_base_dir="/home/xxx/pwn" #setting your own pwn directory

#global vars
binary_path=""
port=0
flag=""
temp_user=""
pwn_name=""

#version infomation
version(){
	echo "pwn v1.0, BenChang,https://github.com/whuben, may 2016"
	echo
}

#helpinfo information
helpinfo(){
	echo "Usage: pwn [-h|-v|-l <pwn-name>|-d <pwn-name>|-u <pwn-name>|-s] [--bianry <binary>] [--port <server-port>] [--flag <string-flag>]"
	echo 
	echo "Options:"
	echo "  -h,--help"
	echo "  -v,--version"
	echo "  -l  <pwn-name>     #loading a pwn server"
	echo "  -d  <pwn-name>     #delete a pwn server"
	echo "  -u  <pwn-name>     #unload a pwn server"
	echo "  -s,--start                    #start a pwn server, more args should be given"
	echo "  --binary <executable-file>  #pwn server"
	echo "  --flag   <string-flag>       #pwn flag"
	echo "  --port   <port-number>       #less than 65535"
}

#generate a temp user
GenerateTempusr(){
	temp_user="ctf_user$RANDOM"
	while id -u $temp_user >/dev/null 2>&1
	do 
		temp_user="ctf_user$RANDOM"
	done
}

#setting a specific privilege to the pwn directory
setprivilege(){
	# args: $1: pwn-path; $2:flag-path
	echo "[*]Change the user group of the pwn binary:\"$1\""
	sudo chgrp $temp_user $1
	echo "[*]Change the previlige of the pwn binary:\"$1\""
	sudo chmod 755 $1
	echo "[*]Change the user group of the flag file:\"$2\""
	sudo chgrp $temp_user $2
	echo "[*]Change the previlige of the flag file:\"$2\""
	sudo chmod 640 $2
}

isDFexist(){
	if [ -z $1 ] ; then
    		printf "\033[31mError: pwn name should be given.\033[m\n\n"
    		exit 1
    	fi
    	pwn_name=$1
	pwn_dir=${pwn_base_dir}"/"${pwn_name}
	if [ ! -d $pwn_dir ] ;then
		printf "\033[31mError: The directory: $pwn_dir does not exist.\033[m\n\n"
		exit 1
	fi
	pwn_path=${pwn_dir}"/"${pwn_name}
	if [ ! -f $pwn_path ] ; then
		printf "\033[31mError: The pwn binary: $pwn_path does not exist.\033[m\n\n"
		exit 1
	fi
}

#load a pwn server on xinetd
startpwn(){
	pwn_name=${binary_path##*/}
	pwn_dir=${pwn_base_dir}"/"${pwn_name}
	pwn_path=${pwn_dir}"/"${pwn_name}
	flag_path=${pwn_dir}"/flag"
	echo "[*]Creating the directory:\"$pwn_dir\""
	mkdir $pwn_dir
	echo "[*]Copy the pwn binary from \"$path\" to \"$pwn_dir\""
	sudo cp $binary_path $pwn_dir
	echo "[*]Creating a flag file:\"$flag_path\" for storing the flag"
	echo $flag > $flag_path
	GenerateTempusr   #generate a random name for temp user 
	echo "[*]Creating a temp user:$temp_user for the pwn server"
	sudo useradd $temp_user
	setprivilege $pwn_path $flag_path
	echo "[*]Register a server on xinetd"
	echo "---------------------------------"
	echo "Creating the configure file: \"$xinetd_path/ctf_$pwn_name\""
	printf 'service ctf_%s\n
{
	disable     = no\n
	socket_type = stream\n
	protocol    = tcp\n
	user        = %s\n
	server      = %s\n
	wait        = no\n
}\n' $pwn_name $temp_user $pwn_path | sudo tee -a $xinetd_path/ctf_$pwn_name
	echo "[*]Register a port for the pwn server"
	printf "ctf_%-12s%s/tcp%48s\n" $pwn_name $port "#add the ctf server port" | sudo tee -a $services_path
	#restart the xinetd
	echo "[*]Restart the xinetd service"
	sudo /etc/init.d/xinetd restart
	echo "[*]Complete: try to connect:127.0.0.1:$port"

}

#load a exist pwn server which was unloaded last time
loadpwn(){
	pattern=$(printf 's/#ctf_%s/ctf_%s/' $1 $1)
	echo "[*]Recovery the registered service"
	sudo sed -i $pattern $services_path
	echo "[*]Restart the xinetd service"
	sudo /etc/init.d/xinetd restart
	echo "[*]Complete!"
}

#unload a pwn server on xinetd
unloadpwn(){
    #just need to comment out the registered service line related to the pwn server
	pattern=$(printf 's/ctf_%s/#ctf_%s/' $1 $1)
	echo "[*]Comment out the registered service"
	sudo sed -i $pattern $services_path
	echo "[*]Restart the xinetd service"
	sudo /etc/init.d/xinetd restart
	echo "[*]Complete!"
}

#delete a pwn server
deletepwn(){
	pwn_dir=${pwn_base_dir}"/"${pwn_name}
	pwn_path=${pwn_dir}"/"${pwn_name}
	temp_user=`ls -l $pwn_path | awk '{print $4}'`  #get the tempuser 
	echo "[*]Deleting the tempuser:$temp_user related to the pwn:$pwn_name"
	sudo userdel $temp_user
	echo "[*]Deleting the pwn directory $pwn_dir"
	rm -rf $pwn_dir
	echo "[*]Deleting the register declared in $services_path"
	sudo sed -i '/^ctf_$pwn_name.*/d' $services_path
	echo "[*]Deleting the $pwn_name configure file in xinetd"
	sudo rm $xinetd_path/ctf_$pwn_name
	echo "[*]Deleting the registered services line in $services_path"
	pattern=$(printf '/^ctf_%s.*/d' $1)
	sudo sed -i $pattern $services_path >/dev/null
	echo "[*]Restart the xinetd service"
	sudo /etc/init.d/xinetd restart
	echo "[*]Complete!"
}

isnumeric() {
    echo "$@" | grep -q -v "[^0-9]"
}

#the main code
case "$1" in
	-v|--version)
    version
    exit 0
    ;;

    -h|--help)
    helpinfo
    exit0
    ;;

    -s|--start)
    while [ $# -gt 1 ] ; do
	    case "$2" in
	    	    --flag)
			shift
			if [ -z "$2" ] ; then
				printf "\033[31mError: Please provide a flag string.\033[m\n\n" 
				exit 1
	         fi
	         flag=$2
	         shift
	         ;;

	         --port)
			shift
			if !(isnumeric "$2") ; then
				printf "\033[31mError: Please provide a valid port.\033[m\n\n"
				exit 1
			fi
			port=$2
			shift
			;;

			--binary)
			shift
			if [ -z "$2" ] ; then
				printf "\033[31mError: Please provide a valid binary.\033[m\n\n"
				exit 1
			fi
			if [ ! -x $2 ] ; then
				printf "\033[31mError: The binary '$2' does not exist.\033[m\n\n"
				exit 1
			fi
			binary_path=$2
			shift
			;;
			
			*)	
			printf "\033[31mError: Unkown option '$2'.\033[m\n\n"
			exit 1
			;; 
		esac
	done
	
	
	
	if [ -z "$binary_path" ] || [ -z "$flag" ] || [ -z "$port" ] ; then
		printf "\033[31mError: More Args needed.\033[m\n\n"
		helpinfo
		exit 1
	fi
	if [ $port -ge 65535 ] ; then
		printf "\033[31mError: The port number must be less than 65535.\033[m\n\n"
		exit 1
	fi
	startpwn
	exit 0
    ;;
    
    -l)
	isDFexist $2
	loadpwn $pwn_name
	exit 0
	;;

    -u)
	isDFexist $2
	unloadpwn $pwn_name
	exit 0
    ;;

    -d)
	isDFexist $2
	deletepwn
	exit 0
	;;
    
    *)
    if [ "$#" != "0" ] ; then
    	    printf "\033[31mError: Unkown option '$1'.\033[m\n\n"
    		echo "test"
    	fi
    	helpinfo
    	exit 1
    	;;
esac

    
