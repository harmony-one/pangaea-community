echo "Installing version monitoring dependencies ..."

do_apt_install() {
    sudo apt-get install supervisor python-pip
}

do_yum_install() {
    sudo yum install supervisor python-pip
}

do_apt_install

sudo pip install -r `pwd`/pangaea_version_monitor/conf/requirements.txt

echo "Installing configuration files ..."
mkdir `pwd`/logs

rm `pwd`/pangaea_version_monitor/local_settings.py
echo "from settings import *">> `pwd`/pangaea_version_monitor/local_settings.py
echo "BASE_DIR = '`pwd`'" >> `pwd`/pangaea_version_monitor/local_settings.py
sudo sed 's?BASE_PATH?'`pwd`'?' "`pwd`/pangaea_version_monitor/conf/pangaea_version_monitor.conf" > /etc/supervisor/conf.d/pangaea_version_monitor.conf
sudo sed 's?BASE_PATH?'`pwd`'?' "`pwd`/pangaea_version_monitor/conf/pangaea_node.conf" > /etc/supervisor/conf.d/pangaea_node.conf

sudo supervisorctl reload

echo "All done!"