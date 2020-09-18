# free_ssl
acme lets encrypt ssl tool wrapper
> 基于acme.sh项目再封装 阿里云dns 授权服务器

下载`enca.tar`

解压 `tar -xvf enca.tar`

进入enca

`cd enca`

`./install.sh`

输入域名
输入nginx路径
输入阿里云AccesskeyId
输入阿里云AccessKeySecret

等待安装完成

查看版本
`enca -v`

生成证书

`enca --issue --dns dns_ali -d ${domain} -d *.${domain}`

替换nginx证书

`enca --install-cert -d ${domain} --key-file ${nginx_cert_path}/key.pem --fullchain-file ${nginx_cert_path}/cert.pem --reloadcmd "service nginx force-reload"`

卸载
`enca uninstall`
