#!/bin/bash

HOME_DIR=$HOME/VM
SCRIPT_DIR=$(cd $(dirname $0); pwd)
COMMON=$SCRIPT_DIR/Common
DEV=$SCRIPT_DIR/Development
PROVISION=$HOME_DIR/$DIR_NAME/provision.sh

DIR_NAME=$1
ENV_TYPE=$2

DATE=`date "+[%m/%d %H:%M:%S]"`

HOST_NAME="sudo sed -i -e 's/localhost.localdomain/$ENV_TYPE/g' /etc/hostname"
array=("dev")

function count_dir() {
	COUNT=`ls -l | grep ^d | wc -l`
	return $COUNT
}

function get_errormessages() {
	case "$ERROR_NUM" in
		1)echo "すでにあるディレクトリです。";;

		2)echo "ディレクトリ名を第一引数に入れてください";;
		3)echo "Vagrantfileがありません。";;

		4)echo "構築したい環境名を第二引数に入力してください。";;

		5)echo "その環境はありません。"
			echo "現在利用できる環境名は"
			for ((i = 0; i < ${#array[@]}; i++)) {
				echo "${array[i]}"
			}
			echo "です。";;

		6)echo "provision.shがありません。";;
	esac
}

function create_dir() {
	cd $HOME_DIR
	if [ -n "$DIR_NAME" ]; then
		if [ ! -d "$DIR_NAME" ]; then
			mkdir $HOME_DIR/$DIR_NAME
		else
			ERROR_NUM=1
			get_errormessages
			exit
		fi
	else
		ERROR_NUM=2
		get_errormessages
		exit
	fi
}

function create_box() {
	cd $HOME_DIR
	count_dir

	cd $HOME_DIR/$DIR_NAME
	vagrant init bento/centos-7.5

	if [ -f Vagrantfile ]; then
		sed -i '31a \  config.vm.network "forwarded_port" ,guest: 80, host: 8080, host_ip: "127.0.0.1"' Vagrantfile
		sed -i '35a \  config.vm.network "private_network", ip: "192.168.33.10"\n  config.vm.network :public_network, ip: "192.168.33.'$((100+$COUNT))'", bridged: "en1: Wi-Fi(AirPort)"' Vagrantfile
		sed -i '69a \  config.vm.provision "shell", :path => "provision.sh", :privileged => false' Vagrantfile
	else
		ERROR_NUM=3
		get_errormessages
		exit
	fi
}

function setup_vm() {
	cd $HOME_DIR/$DIR_NAME

	if [ -n "$2" ]; then
		ERROR_NUM=4
		get_errormessages
		exit
	
	case "$ENV_TYPE" in
		"dev") cp -p $DEV/development.sh provision.sh.org ;;
		*) ERROR_NUM=5
			get_errormessages
			exit ;;
	esac

	if [ -f provision.sh.org ]; then
		cp -p $COMMON/common.sh common.sh
		cp -p $COMMON/end.sh end.sh
		cat common.sh provision.sh.org end.sh > provision.sh
		rm common.sh provision.sh.org end.sh

		echo -e 'vagrant up' >> $HOME_DIR/$DIR_NAME/up.bat
		echo 'vagrant halt' >> $HOME_DIR/$DIR_NAME/halt.bat
		echo 'vagrant reload' >> $HOME_DIR/$DIR_NAME/reload.bat

		vagrant up
	else
		ERROR_NUM=6
		get_errormessages
		exit
	fi
}

#######################################################
#                 Start                               #
#######################################################
if [ ! -d "$HOME_DIR" ]; then
	mkdir -p $HOME/VM
fi

create_dir && create_box && setup_vm
exit 0
