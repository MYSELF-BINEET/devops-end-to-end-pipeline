pipeline {
    agent {label "pipeline_node"}
    stages {
        stage('Git') {
            steps {
                echo 'Downoading..'
                git 'https://github.com/MYSELF-BINEET/devops-end-to-end-pipeline.git'
                echo "Code Downloaded Succesfully!"
            }
        }
        stage("Setup Ansible"){
            steps{
                echo "Testing was already done succesfully via Github Workflows"
                sh "yum install ansible -y"
                echo "Ansible Installed"
        }
        }
        stage("Setup Terraform"){
            steps{
                script {
                    if (!fileExists('terraform_1.6.0_linux_amd64.zip')) {
                        sh 'wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip'
                        sh "unzip terraform_1.6.0_linux_amd64.zip"
                        sh "mv terraform /usr/local/bin/"
                    } else {
                        echo 'Terraform zip file already exists. Skipping download.'
                    }
                }
            sh "terraform --version"
            withCredentials([
                    usernamePassword(
                        credentialsId: 'aws-access-key-id',
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    sh '''
                        aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                        aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                    '''
                }
            }
        }
        stage("Create Infrastructure for PROD"){
            steps{
            sh "terraform init"
            sh "terraform apply --auto-approve"
            sh "sleep 30" //giving some time for infrastructure to be up and running..
            echo "Infrastructure is up and running.."
            }
        }
        stage("Configure k8s cluster on the created infrastructure "){
            steps{
                withCredentials([file(credentialsId: 'nothing', variable: 'SSH_KEY')]) {
                sh '''
                    chmod 400 $SSH_KEY
                    ls -l $SSH_KEY
                '''
            }
                sh "ansible-playbook k8s_cluster.yml"
                echo "K8s minikube cluster configured succesfully!"
            }
        }
        stage("Configure Monitoring Tool"){
            steps{
                sh "ansible-playbook prometheus-grafana.yml"
                echo "Monitoring tool configured succesfully!"
            }
        }
        stage("Deploy the Webserver"){
            steps{
                sh "ansible-playbook deployDeployment.yml"
                sh "chmod +x startservers.sh"
                echo "Create a Socat to connect to our webserver from the Internet(from the outside of ec2 Instance)"
                sh "./startservers.sh"
            }
        }
    }
}
