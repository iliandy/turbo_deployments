server_config="server {
    listen 80;
    server_name $ip_addr;
    passenger_enabled on;
    passenger_app_env development;
    root /var/www/$project_dir/public;
}"

proj_conf=/etc/nginx/sites-available/rails.conf

# update ubuntu instance
sudo apt-get -y update
sudo apt-get -y upgrade
# ruby and rails installation
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm requirements
rvmsudo /usr/bin/apt-get -y install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison subversion
# ruby
rvm install 2.3.1
rvm use 2.3.1 --default
rvm rubygems current --force
# rails
gem install rails -v 4.2.7 --no-ri --no-rdoc
# passenger
gem install passenger
# swap file
sudo apt-get -y install libcurl4-openssl-dev
sudo dd if=/dev/zero of=/swap bs=1M count=1024
sudo mkswap /swap
sudo swapon /swap
rvmsudo passenger-install-nginx-module --auto --prefix=/etc/nginx --auto-download --extra-configure-flags=none --languages ruby,nodejs
# postgresql
sudo apt-get -y install postgresql postgresql-contrib libpq-dev
sudo su postgres -c psql <<EOF
CREATE ROLE ubuntu SUPERUSER LOGIN;
EOF
# node.js and git
sudo apt-get -y install nodejs
sudo apt-get -y install git
cd /var
sudo mkdir www
cd www
# clone rails project
sudo git clone $url
sudo chown -R ubuntu $project_dir
cd $project_dir
bundle install
sudo touch log/development.log
sudo chmod 0666 /var/www/$project_dir/log/development.log
rake db:create:all
rake db:migrate
# nginx
sudo wget https://raw.github.com/JasonGiedymin/nginx-init-ubuntu/master/nginx -O /etc/init.d/nginx
sudo chmod +x /etc/init.d/nginx
cd /etc/init.d
sudo sed -i "21s/.*/# config:      \/etc\/nginx\/conf\/nginx.conf/" nginx
sudo sed -i "22s/.*/# pidfile:     \/etc\/nginx\/logs\/nginx.pid/" nginx
sudo sed -i "87s/.*/NGINXPATH=${NGINXPATH:-\/etc\/nginx}/" nginx
sudo systemctl -l enable nginx
sudo systemctl -l start nginx
cd /etc/nginx
sudo mkdir sites-available
sudo mkdir sites-enabled
cd conf
sudo sed -i "83a include \/etc\/nginx\/sites-enabled\/*;" nginx.conf
cd /etc/nginx/sites-available
sudo touch rails.conf
sudo sh -c "echo '$server_config' >> '$proj_conf'"
sudo ln -s /etc/nginx/sites-available/rails.conf /etc/nginx/sites-enabled/rails.conf
sudo service nginx restart
