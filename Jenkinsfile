def dock = "jenkins-docker-${UUID.randomUUID().toString()}"
podTemplate(label: dock, containers: [
  containerTemplate(name: 'docker', image: 'docker', command: 'cat', ttyEnabled: true)
],
volumes: [
  hostPathVolume(mountPath: '/var/run/docker.sock', hostPath: '/var/run/docker.sock')
]) {

  node(dock) {
    stage('Create Docker images') {
      container('docker') {
          sh """
            docker pull ncomeau/demo
            """
        }
      }
  } 
 node {
     stage('Cbctl Image Scan') {
         try{
         sh 'git clone https://github.com/slackapi/python-slack-sdk.git'
         }
         catch(exists){
             echo 'already exists'
         }
     sh '/var/jenkins_home/app/cbctl image scan ncomeau/demo -o json > ncomeau_image_scan.json'
         sh 'python3 /var/jenkins_home/app/image_scan_slack.py ncomeau_image_scan.json'
     }

     
     stage('Cbctl Image Validate') {
         try{
     sh '/var/jenkins_home/app/cbctl image validate ncomeau/demo -o json > ncomeau_image_validate.json'
         }
         catch(err){
            
            echo 'Finished with violations'
              sh 'python3 /var/jenkins_home/app/image_validate_slack.py ncomeau_image_validate.json'

         }
     }

 node { 
     stage('Cloning desired yamls from Github Registry') {
         
         try {
         sh 'git clone https://github.com/ncomeau/k8-yamls.git /yamls'
         }
         catch(err2){
             echo "Repo already exists!"
         }
     }
     
     stage('Cbctl yaml Validate') {
         try{
     sh '/var/jenkins_home/app/cbctl k8s-object validate -f /yamls/bad.yaml -o json > ncomeau_k8s_validate.json'
              sh 'python3 /var/jenkins_home/app/k8s_validate_slack.py ncomeau_k8s_validate.json'

     }
     catch(err3){
                echo " STILL exist, idiot"
                sh '/var/jenkins_home/app/cbctl k8s-object validate -f /yamls/good.yaml'

         }
     }
     
 }
}
def k8 = "jenkins-k8-${UUID.randomUUID().toString()}"
podTemplate(label: k8, containers: [
containerTemplate(name: 'kubectl', image: 'lachlanevenson/k8s-kubectl:v1.8.8', command: 'cat', ttyEnabled: true)
])
{
node (k8) {
        stage ('Create Yaml') {
            container('kubectl') {
    writeFile file: 'good.yaml', text: """
apiVersion: v1
kind: Pod
metadata:
  name: static-site
  labels:
    app: static-site
spec:
  containers:
    - name: static-site
      image: ncomeau/demo
      resources:
        requests:
          memory: "64Mi"
          cpu: "250m"
        limits:
          memory: "128Mi"
          cpu: "500m"      
      ports:
      - containerPort: 80
        hostPort: 80
        name: static-site

---
# https://kubernetes.io/docs/concepts/services-networking/service/#defining-a-service
kind: Service
apiVersion: v1
metadata:
  name: static-service
spec:
  selector:
    app: static-site
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
    nodePort: 31000
  type: NodePort"""
    sh 'ls -l nick.yaml'
    sh 'pwd'
}   
}
    stage ('deploy yaml') {
            container('kubectl') {
                    sh "kubectl apply -f good.yaml -n feline --validate=false"
                    sh "kubectl get all -n feline"
            }
}
}
}
}
