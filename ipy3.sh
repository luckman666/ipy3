#########python_version################################################################
#!/usr/bin/bash
#1.定义变量
soft_dir=/data/software
python_version=Python-$1
python_data_dir=/usr/local/python-$1
python_version_package=Python-"$1".tgz
python_download_link=https://www.python.org/ftp/python/$1/Python-"$1".tgz
array=(zlib zlib-devel bzip2 bzip2-devel ncurses ncurses-devel readline readline-devel  openssl openssl-devel openssl-static xz lzma xz-devel sqlite sqlite-devel gdbm gdbm-devel tk tk-devel db4-devel libpcap-devel libffi-devel epel-release )
		
#2.安装依赖
source /etc/init.d/functions
if [ $# -ne 1 ];then
	echo "/bin/sh $0 python_version_number"
	exit 1
fi

for info in ${array[*]}
do
	yum -y install $info;
	if [ $? -eq 0 ];then
		echo "$i is installed"; 
	else
		yum -y install $i  &>/dev/null;
		action "$i is installing"  /usr/bin/true;
	fi     
done

#3.下载Pyhton3安装包
if [ -d $soft_dir ];then
	cd $soft_dir && [ -f $python_version_package ] && echo "$python_version_package is Exist" || wget $python_download_link
else
	echo "$soft_dir not exist" && mkdir $soft_dir -p && cd $soft_dir && [ -f $python_version_package ] && echo "$python_version_package is Exist" || wget $python_download_link
fi

#4.解压安装包
[ -d /root/$python_version ] && rm -rf /root/$python_version || cd $soft_dir ; tar -zxvf $python_version_package -C /root

#5.创建python程序目录
[ -d $python_data_dir ] &&  rm -rf $python_data_dir || mkdir $python_data_dir

#6.生成Makefile文件
cd /root/$python_version && mkdir bld && cd bld && ../configure --prefix=$python_data_dir

#7.编译安装
make && make install

#8.做软连接
[ -L /usr/local/python3 ] && rm -rf /usr/local/python3 ;ln -s $python_data_dir /usr/local/python3 || ln -s $python_data_dir /usr/local/python3

#9.配置环境变量
echo 'export PATH=/usr/local/python3/bin:$PATH' > /etc/profile.d/python3.sh

source /etc/profile.d/python3.sh

#9.升级pip
pip3 install --upgrade pip
pip3_version=`pip3 -V |awk '{print $1" "$2}'`
[ $? -eq 0 ] && echo "$pip3_version is  Update Success" || echo "$pip3_version is  Update Failed"

#10.Python3安装完成    
cat << EOF
+-------------------------------------------------+
| `python3 -V` 已 经 安 装 完 毕 ，         |
| 请 尽 情 享 受 代 码 的 美 好 !                 |
+-------------------------------------------------+
EOF

sleep 5



