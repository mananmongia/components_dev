#!/bin/bash

###### INSTALLATION FUNCTION ######

docker () {
    echo -e "\n\e[1;42m\e[1;31m********* INSTALLING DOCKER *********\e[1;0m"
    apt-get -qq install -y docker.io
}

dockercompose () {
    echo -e "\n\e[1;42m\e[1;31m********* INSTALLING DOCKER-COMPOSE *********\e[1;0m"
    apt-get -qq install -y docker-compose
}

dockeruser () {
    echo -e "\n\e[1;44m\e[1;31m********* ADDING $USERNAME TO DOCKER GROUP *********\e[1;0m"
    usermod -aG docker $USERNAME
}

kubectl () {
    echo -e "\n\e[1;42m\e[1;31m********* INSTALLING KUBECTL *********\e[1;0m" &&
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" &&
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
}

ddclient () {
    apt-get -qq install -y ddclient &&
    mkdir /etc/ddclient &&
    echo -e "\n\e[1;42m\e[1;31m********* DOWNLOADING CONFIG *********\e[1;0m" &&
    curl -s https://raw.githubusercontent.com/devsecopscloset/components/master/dev/ddclient.conf -o /etc/ddclient/ddclient.conf &&
    curl -s https://raw.githubusercontent.com/ddclient/ddclient/develop/sample-etc_rc.d_init.d_ddclient.ubuntu -o /etc/systemd/system/ddclient.service &&
    read -p 'Enter the username: ' username &&
    read -p 'Enter the password: ' password &&
    read -p 'Enter the domain names in comma separated values : ( example.com, example2.com ) ' domains &&
    echo -e '\n\e[1;42m\e[1;31m********* CREATING CONFIGURATION FOR DDCLIENT *********\e[1;0m' &&
    echo 'username= '$username >> /etc/ddclient/ddclient.conf &&
    echo 'password= '$password >> /etc/ddclient/ddclient.conf &&
    echo $domains >> /etc/ddclient/ddclient.conf &&
    echo -e "\n\e[1;42m\e[1;31m********* ENABLING DDCLIENT ON STARTUP *********\e[1;0m" &&
    systemctl enable ddclient.service &&
    echo -e "\n\e[1;42m\e[1;31m********* STARTING DDCLIENT SERVICE *********\e[1;0m"
    systemctl start ddclient.service
}

baseinstall () {
    echo -e '\nINSTALLING BASIC PACKAGES'
    apt-get -qq update &&
    apt-get -qq upgrade -y &&
    apt-get -qq install -y curl git make perl gcc openjdk-11-jdk
}



echo -e "\nPLEASE SELECT THE COMPONENTS TO BE INSTALLED"
echo -e "\n1. Docker Only (d)"
echo -e "\n2. Kubectl Install (k)"
echo -e "\n3. Docker Compose Install (dc)"
echo -e "\n4. Docker User Configuration (du)"
echo -e "\n5. DDCLIENT configuration (dd)"
echo -e "\n6. Basic packages install (bp)"
echo -e "\n7. All (a)\n"
echo -e "\e[1;31mEnter the option: (Enter mutiple options separated by space) \e[0m"
read OPTION

for i in $OPTION; do

    ###### DOCKER CONFIGURATION #######

    if [ "$i" = "d" ] || [ "$i" = "a" ]; then
        echo -e "\n\e[1;32m********* DOCKER SELECTED *********\e[0m"
        if [ -x "$(command -v docker)" ]; then
            echo -e "\n\e[1;42m\e[1;31m********* DOCKER IS INSTALLED *********\e[1;0m"
        else
            docker
        fi
    fi

    ###### BASIC PACKAGES #######

    if [ "$i" = "bp" ] || [ "$i" = "a" ]; then
        echo -e "\n\e[1;32m********* BASIC PACKAGES SELECTED *********\e[0m"
        baseinstall
    fi    
    
    ###### DOCKER USER GROUP CONFIGURATION #######

    if [ "$i" = "d" ] || [ "$i" = "a" ] || [ "$i" = "du" ]; then
        echo -e "\n\e[1;32m********* DOCKER USER CONFIG SELECTED *********\e[0m"
        echo -e "\e[1;31mENTER USERNAME: \e[0m"
        read USERNAME
        if ! (( $(grep '^docker' /etc/group | grep -c $USERNAME) == 0 )); then
            echo -e "\n\e[1;44m\e[1;31m********* USER IS ALREADY PART OF DOCKER GROUP *********\e[1;0m"
        else
            dockeruser
        fi
    fi

    ###### DOCKER-COMPOSE CONFIGURATION #######
    if [ "$i" = "dc" ] || [ "$i" = "a" ]; then
        echo -e "\n\e[1;32m********* DOCKER-COMPOSE SELECTED *********\e[0m"
        if [ -x "$(command -v docker-compose)" ]; then
            echo -e "\n\e[1;42m\e[1;31m********* DOCKER-COMPOSE IS INSTALLED *********\e[1;0m"
        else
            dockercompose
        fi
    fi

    ###### KUBECTL CONFIGURATION #######
    if [ "$i" = "k" ] || [ "$i" = "a" ]; then
        echo -e "\n\e[1;32m********* KUBECTL SELECTED *********\e[0m"
        if [ -x "$(command -v kubectl)" ]; then
            echo -e "\n\e[1;42m\e[1;31m********* KUBECTL IS INSTALLED *********\e[1;0m"
        else
            kubectl
        fi
    fi

    ###### DDCLIENT CONFIGURATION #######
    if [ "$i" = "dd" ] || [ "$i" = "a" ]; then
        echo -e "\n\e[1;32m********* DDCLIENT SELECTED *********\e[0m"
        if [ -x "$(command -v ddclient)" ]; then
            echo -e "\n\e[1;42m\e[1;31m********* DDCLIENT IS INSTALLED *********\e[1;0m"
        else
            ddclient
        fi
    fi

done

echo -e "\n\e[1;41m\e[1;32m********* FINISHED SETTING UP!! REBOOT THE MACHINE *********\e[1;0m"