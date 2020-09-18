#!/usr/bin/env bash 
      
# This script helps to install enca tool for generating free ssl certificate
# Author: TongQiao 
# Date: 2020/9/15 10:57 AM

echo "
                      
  ___ _ __   ___ __ _ 
 / _ \ '_ \ / __/ _' |
|  __/ | | | (_| (_| |  Author: TongQiao
 \___|_| |_|\___\__,_|  ScriptVersion: 0.0.1
   "

DIR=`pwd`


__INTERACTIVE=""
if [ -t 1 ]; then
  __INTERACTIVE="1"
fi

__green() {
  if [ "${__INTERACTIVE}${ACME_NO_COLOR:-0}" = "10" -o "${ACME_FORCE_COLOR}" = "1" ]; then
    printf '\33[1;32m%b\33[0m' "$1"
    return
  fi
  printf -- "%b" "$1"
}

__red() {
  if [ "${__INTERACTIVE}${ACME_NO_COLOR:-0}" = "10" -o "${ACME_FORCE_COLOR}" = "1" ]; then
    printf '\33[1;31m%b\33[0m' "$1"
    return
  fi
  printf -- "%b" "$1"
}

_printargs() {
  _exitstatus="$?"
  if [ -z "$NO_TIMESTAMP" ] || [ "$NO_TIMESTAMP" = "0" ]; then
    printf -- "%s" "[$(date)] "
  fi
  if [ -z "$2" ]; then
    printf -- "%s" "$1"
  else
    printf -- "%s" "$1='$2'"
  fi
  printf "\n"
  # return the saved exit status
  return "$_exitstatus"
}

_syslog() {
  _exitstatus="$?"
  if [ "${SYS_LOG:-$SYSLOG_LEVEL_NONE}" = "$SYSLOG_LEVEL_NONE" ]; then
    return
  fi
  _logclass="$1"
  shift
  if [ -z "$__logger_i" ]; then
    if _contains "$(logger --help 2>&1)" "-i"; then
      __logger_i="logger -i"
    else
      __logger_i="logger"
    fi
  fi
  $__logger_i -t "$PROJECT_NAME" -p "$_logclass" "$(_printargs "$@")" >/dev/null 2>&1
  return "$_exitstatus"
}

_info() {
  _printargs "$@"
}

function domain(){
	read -p "请输入生成ssl的域名: " domain
	if [[ $domain != "" ]]; then
		export domain=$domain
		echo "export domain=$domain" >> ~/.bashrc
	else
		__red "域名不能为空"
		echo ""
		domain
	fi
}

function path(){
	read -p "请输入证书路径: " path
	if [[ $path != "" ]]; then
		export nginx_path=$path
		echo "export nginx_path=$path" >> ~/.bashrc
	else
		__red "证书路径不能为空"
		echo ""
		domain
	fi
}

function alikey(){
    read -p "请输入阿里云AccessKeyId: " id
    if [[ $id == "" ]]; then
  	  	__red "AccessKeyId 不能为空"
  	  	echo ""
  	  	alikey
    fi
}

function alisecret(){
	read -p "请输入阿里云AccessKeySecret: " secret
	if [[ $secret == "" ]]; then
		__red "AccessKeySecret"
		echo ""
		alisecret
	fi
}


__green "enca installation is now starting ... ..."
echo ""

domain
path
alikey
alisecret

crontab -l > $DIR/crontab
echo "01 1 * * * /root/.acme.sh/acme.sh --install-cert -d ${domain} --key-file ${nginx_path}/key.pem --fullchain-file ${nginx_path}/cert.pem --reloadcmd \"service nginx force-reload\" > /dev/null" > $DIR/crontab
crontab $DIR/crontab

cat $DIR/enca.sh | INSTALLONLINE=1  sh

echo "export Ali_Key=\"$id\"" >> ~/.acme.sh/account.conf
echo "export Ali_Secret=\"$secret\"" >> ~/.acme.sh/account.conf
echo 'alias enca="/root/.acme.sh/acme.sh"' >>  ~/.bashrc
ln -sf /root/.acme.sh/acme.sh /usr/bin/enca

mv -f $DIR/enca.sh /root/.acme.sh/acme.sh

_info "卸载软件命令 uninstall: "
_info "enca uninstall"
_info "=================================="
_info "使用说明 usage: "
_info "使用以下命令 注意需要替换掉要生成的域名"
_info "1. 生成证书命令: "
_info "enca --issue --dns dns_ali -d 域名"
_info "2. 替换到nginx证书路径命令: 注意替换中文部分"
_info 'enca --install-cert -d 域名 --key-file 证书路径/key.pem --fullchain-file 证书路径/cert.pem --reloadcmd "service nginx force-reload"'
_info "==================================="
__green "installed successfully"
echo ""

rm -rf $DIR

enca --issue --dns dns_ali -d $domain -d *.$domain

enca --install-cert -d $domain --key-file $nginx_path/key.pem --fullchain-file $nginx_path/cert.pem --reloadcmd "service nginx force-reload"






