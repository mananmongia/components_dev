#!/bin/bash

set -eu

if [[ -d ~/config ]]
then
	if [[ -d ~/config/ip_vol ]]
	then
		echo "ip_vol exists"
	else
		mkdir ~/config/ip_vol
	fi
	if [[ -d ~/config/defect_dojo ]]
	then
		echo "defect_dojo exits"
	else
		mkdir ~/config/defect_dojo
	fi
else
	mkdir -p ~/config/ip_vol &&
	mkdir ~/config/defect_dojo
fi

# Has to be altered if the various pipelines will have various configurations
if [[ ! -e ~/config/Config.yaml ]]
then
	touch ~/config/Config.yaml
else
	echo "Pipeline Config exists"
fi
if [[ ! -e ~/config/defect_dojo/dd_conf.yaml ]]
then
	touch ~/config/defect_dojo/dd_conf.yaml
else
	echo "defect-dojo config exists"
fi

# $kubeconfig is env variable passed from git secrets
if [[ -d ~/kubeconfig ]]
then
	if [[ -e ~/kubeconfig/config ]]
	then
		echo "file exists"
	else
		touch ~/kubeconfig/config
	fi
else
	mkdir ~/kubeconfig &&
	touch ~/kubeconfig/config
fi

if [[ -d ~/nginx ]]
then
	echo " "
else
	mkdir ~/nginx
fi

gpg --quiet --batch --yes --decrypt --passphrase="$EXKEY" --output ~/trigger/secrets ~/trigger/secrets.gpg &&

tar -xf ~/trigger/secrets -C ~/trigger/ &&

# mv ~/trigger/nginx ~/nginx &&
if [[ -d ~/django-DefectDojo ]]
then
	cd ~/django-DefectDojo &&
	git pull
else
	git clone https://github.com/DefectDojo/django-DefectDojo.git
fi
curl https://raw.githubusercontent.com/devsecopscloset/components/master/dev/nginx.conf -o ~/nginx/nginx.conf &&
mv ~/trigger/config ~/kubeconfig/ &&
mv ~/trigger/Config.yaml ~/config/ &&
mv ~/trigger/dd_conf.yaml ~/config/defect_dojo/
# curl https://raw.githubusercontent.com/devsecopscloset/components/master/dev/docker-compose.yml -o ~/docker-compose.yml
