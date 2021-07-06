#!/usr/bin/dash -e


echo 'Installing microk8s'
snap install microk8s --classic
echo '----------------------------------------------------------'

echo 'Altering ~/.vimrc editing controls'
echo 'set nocompatible' >> ~/.vimrc
echo 'set backspace=indent,eol,start' >> ~/.vimrc
echo '----------------------------------------------------------'

echo 'Adding kubectl alias to .bashrc...'
echo 'alias kubectl=microk8s.kubectl' >> ~/.bashrc
echo 'source <(microk8s.kubectl completion bash)' >> ~/.bashrc
echo '----------------------------------------------------------'

echo 'Installing docker.io and git...'
apt-get -y install docker.io git
echo '----------------------------------------------------------'

echo 'Installing java for Jenkins CLI...'
apt install default-jre
echo '----------------------------------------------------------'

echo 'Get Jenkins Image Repo...'
git clone https://github.com/JaBarosin/jenkins.git
echo '----------------------------------------------------------'


echo 'Building Jenkins Image...'
docker build jenkins/ -t cbc-jenkins
echo '----------------------------------------------------------'

echo 'Running Jenkins Container...'
docker run -d --name jenkins-server --publish 8080:8080  --publish 50000:50000 --volume /var/jenkins:/var/jenkins_home --volume /var/run/docker.sock:/var/run/docker.sock cbc-jenkins
echo '----------------------------------------------------------'

echo 'Running getting password'
docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword 

echo 'Creating feline namespace for testing'
microk8s.kubectl create namespace feline
echo '----------------------------------------------------------'

echo '----------------------------------------------------------'
echo 'RUN THE FOLLOWING COMMAND: and see demo doc for next steps:'
echo 'source  ~/.bashrc'
echo '----------------------------------------------------------'
echo 'Once you have run the above command, see demo doc for next steps'
