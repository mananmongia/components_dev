#!/bin/bash

base_install() {
    sudo apt update -y >> /dev/null &&
    sudo apt upgrade -y >> /dev/null &&
    sudo apt install -y python3 python3-pip git curl >> /dev/null
}

kubectl_install () {
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" &&
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
}

docker_install () {
    curl -fsSL https://get.docker.com -o get-docker.sh &&
    chmod +x get-docker.sh &&
    sudo ./get-docker.sh
}

docker_compose_install () {
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4) &&
    curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > docker-compose &&
    chmod +x docker-compose &&
    sudo mv docker-compose /usr/bin/
}