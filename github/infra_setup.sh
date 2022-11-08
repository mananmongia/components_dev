#!/bin/bash

if [ -f "~/infra_setup" ]; then
	if [ grep -q '1' '~/infra_setup' ]; then
		echo "Dashboards setup done already"
	else
		if [ -d "~/django-DefectDojo" ]; then
			infra_setup
		else
			cd ~ &&
			git clone https://github.com/DefectDojo/django-DefectDojo.git &&
			infra_setup
	fi
else
	touch ~/infra_setup &&
	infra_setup
fi		

infra_setup(){
	cd ~/django-DefectDojo &&
	[ -x dc-up-d.sh ] || chmod +x dc-up-d.sh
	/bin/bash dc-up-d.sh mysql-rabbitmq &&
	# rm -rf ~/django-DefectDojo &&

	if [ ! docker ps | grep `docker image | grep devsecopscloset/octant | awk '{print $1":"$2}'` | awk '{print $1}' ]
	then
		docker run -v $HOME/kubeconfig:/kubeconfig -p 7777:7777 --restart always -d devsecopscloset/octant:dev
	else
		echo "Octant Already Running"
	fi

	echo "1" > ~/infra_setup
}