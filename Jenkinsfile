pipeline {
    agent none

    options {
        timestamps()
        timeout(time: 20, unit: 'MINUTES')
    }

    environment {
        DOCKERHUB_USER = 'saketwagh'
        IMAGE_NAME     = "${DOCKERHUB_USER}/lab6-app"
        IMAGE_TAG      = "${BUILD_NUMBER}"
    }

    stages {
        stage('Build and push image') {
            agent { label 'linux && docker' }
            steps {
                sh 'docker build --build-arg BUILD=${IMAGE_TAG} -t ${IMAGE_NAME}:${IMAGE_TAG} .'
                withCredentials([usernamePassword(credentialsId: 'dockerhub',
                        usernameVariable: 'DH_USER', passwordVariable: 'DH_PASS')]) {
                    sh '''
                        echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        docker logout
                    '''
                }
            }
        }
        stage('Deploy to Kubernetes') {
            agent {
                kubernetes {
                    cloud 'kind'
                    yaml '''
apiVersion: v1
kind: Pod
spec:
  serviceAccountName: jenkins-deployer
  containers:
  - name: kubectl
    image: alpine:3.20
    command: ["cat"]
    tty: true
'''
                    defaultContainer 'kubectl'
                }
            }
            steps {
                sh '''
                    apk add --no-cache kubectl
                    sed -i "s|IMAGE_PLACEHOLDER|${IMAGE_NAME}:${IMAGE_TAG}|" k8s/deployment.yaml
                    kubectl apply -f k8s/ -n demo
                    kubectl rollout status deployment/hello-jenkins -n demo --timeout=120s
                    kubectl get pods,svc -n demo
                '''
            }
        }
    }
}
