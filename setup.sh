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
apt-get -y install default-jre
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
echo "Your initial Jenkins admin password = $(docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword)"
echo "admin:$(docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword)" > creds

echo 'Creating feline namespace for testing'
microk8s.kubectl create namespace feline
echo '----------------------------------------------------------'

echo 'Getting Jenkins CLI jar File"
wget http://0.0.0.0:8080/jnlpJars/jenkins-cli.jar
echo '----------------------------------------------------------'

echo 'Downloading needed plugins'
java -jar jenkins-cli.jar -s http://0.0.0.0:8080/ -auth @creds install-plugin docker-plugin
java -jar jenkins-cli.jar -s http://0.0.0.0:8080/ -auth @creds install-plugin kubernetes
java -jar jenkins-cli.jar -s http://0.0.0.0:8080/ -auth @creds install-plugin slack

echo '----------------------------------------------------------'

echo 'Restarting Jenkins'
java -jar jenkins-cli.jar -s http://0.0.0.0:8080/ -auth @creds safe-restart
echo '----------------------------------------------------------'


echo '----------------------------------------------------------'
echo 'RUN THE FOLLOWING COMMAND: and see demo doc for next steps:'
echo 'source  ~/.bashrc'
echo '----------------------------------------------------------'
echo 'Once you have run the above command, see demo doc for next steps'
