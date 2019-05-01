#!/usr/bin/env bash
# Provision WordPress Stable


DOMAIN=`get_primary_host "${VVV_SITE_NAME}".local`
DOMAINS=`get_hosts "${DOMAIN}"`
SITE_TITLE=`get_config_value 'site_title' "${DOMAIN}"`
WP_VERSION=`get_config_value 'wp_version' 'latest'`
WP_TYPE=`get_config_value 'wp_type' "single"`
DB_NAME=`get_config_value 'db_name' "${VVV_SITE_NAME}"`
DB_NAME=${DB_NAME//[\\\/\.\<\>\:\"\'\|\?\!\*-]/}
ACF_PRO_KEY=`get_config_value 'acf_pro_key' "xyz"`


# Clone the WP Starter config repo
if [[ ! -d "${VVV_PATH_TO_SITE}/wpstarter" ]]; then
    echo "Cloning WP Starter config..."
	noroot git clone https://github.com/soderlind/wpstarter-config "${VVV_PATH_TO_SITE}/wpstarter"

	echo "Configure .env"

	sed -i "s#site_name_here#${DOMAIN}#" "${VVV_PATH_TO_SITE}/wpstarter/.env-sample"
	sed -i "s#db_name_here#${DB_NAME}#" "${VVV_PATH_TO_SITE}/wpstarter/.env-sample"
	sed -i "s#db_username_here#wp#" "${VVV_PATH_TO_SITE}/wpstarter/.env-sample"
	sed -i "s#db_password_here#wp#" "${VVV_PATH_TO_SITE}/.env-sample"
	sed -i "s#acf_pro_key_here#${ACF_PRO_KEY}#" "${VVV_PATH_TO_SITE}/wpstarter/.env-sample"

	noroot mv "${VVV_PATH_TO_SITE}/wpstarter/.env-sample" "${VVV_PATH_TO_SITE}/vwpstarter/.env"
else
	cd ${VVV_PATH_TO_SITE}
	noroot git pull
fi


# Make a database, if we don't already have one
echo -e "\nCreating database '${DB_NAME}' (if it's not already there)"
mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME}"
mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO wp@localhost IDENTIFIED BY 'wp';"
echo -e "\n DB operations done.\n\n"

# Nginx Logs
mkdir -p ${VVV_PATH_TO_SITE}/log
touch ${VVV_PATH_TO_SITE}/log/error.log
touch ${VVV_PATH_TO_SITE}/log/access.log


# Composer
ssh-keyscan -H github.com >> ~/.ssh/known_hosts ssh -Ts git@github.com
cd ${VVV_PATH_TO_SITE}/wpstarter
if [[ ! -d "${VVV_PATH_TO_SITE}/wpstarter/vendor" ]]; then
	echo "Running composer install"
	noroot composer install
else
	echo "Running composer update"
	noroot composer update
fi

#
# nginx
#

cp -f "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf.tmpl" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"

if [ -n "$(type -t is_utility_installed)" ] && [ "$(type -t is_utility_installed)" = function ] && `is_utility_installed core tls-ca`; then
    sed -i "s#{{TLS_CERT}}#ssl_certificate /vagrant/certificates/${VVV_SITE_NAME}/dev.crt;#" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"
    sed -i "s#{{TLS_KEY}}#ssl_certificate_key /vagrant/certificates/${VVV_SITE_NAME}/dev.key;#" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"
else
    sed -i "s#{{TLS_CERT}}##" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"
    sed -i "s#{{TLS_KEY}}##" "${VVV_PATH_TO_SITE}/provision/vvv-nginx.conf"
fi