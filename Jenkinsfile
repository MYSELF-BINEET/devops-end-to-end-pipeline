pipeline {
    agent {label "pipeline_node"}
    environment {
        // Automatically maps the Jenkins secret text to your Terraform variable: var.public_key_material
        TF_VAR_public_key_material = credentials('ec2-public-key') 
    }
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
        stage("Setup Terraform") {
            steps {
                script {
                    // CHANGED: Upgraded from 1.6.0 to 1.9.0 to resolve the expired GPG key issue
                    if (!fileExists('terraform_1.9.0_linux_amd64.zip')) {
                        sh 'wget https://releases.hashicorp.com/terraform/1.9.0/terraform_1.9.0_linux_amd64.zip'
                        sh 'unzip -o terraform_1.9.0_linux_amd64.zip'
                        sh 'sudo mv terraform /usr/local/bin/'
                    } else {
                        echo 'Terraform zip file already exists. Skipping download.'
                    }
                }

                sh 'terraform --version'
            }
        }

        stage("Configure AWS Credentials") {
            steps {
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
                        aws configure set default.region ap-south-1

                        aws sts get-caller-identity
                    '''
                }
            }
        }
        stage("Create Infrastructure for PROD"){
            steps{
            sh "terraform init --upgrade"
            // script {
            //         // Safe Import Method: Catches the error if the key is already imported, preventing a pipeline crash
            //         try {
            //             sh 'terraform import aws_key_pair.jenkins_key jenkins-imported-key'
            //         } catch (Exception e) {
            //             echo "Key pair 'jenkins-imported-key' already exists in the state file. Skipping import."
            //         }
            //     }
            sh "terraform apply --auto-approve"
            sh "sleep 30" //giving some time for infrastructure to be up and running..
            echo "Infrastructure is up and running.."
            }
        }
        stage("Configure k8s cluster on the created infrastructure") {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'nothing',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    sh '''
                        chmod 400 $SSH_KEY

                        ansible-playbook \
                            -i inventory \
                            -u ec2-user \
                            --private-key=$SSH_KEY \
                            k8s_cluster.yml
                    '''
                }

                echo "K8s minikube cluster configured successfully!"
            }
        }

        stage("Configure Monitoring Tool") {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'nothing',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    sh '''
                        chmod 400 $SSH_KEY

                        ansible-playbook \
                            -i inventory \
                            -u ec2-user \
                            --private-key=$SSH_KEY \
                            prometheus-grafana.yml
                    '''
                }

                echo "Monitoring tool configured successfully!"
            }
        }

        stage("Deploy the Webserver") {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'nothing',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    sh '''
                        chmod 400 $SSH_KEY

                        ansible-playbook \
                            -i inventory \
                            -u ec2-user \
                            --private-key=$SSH_KEY \
                            deployDeployment.yml
                    '''
                }

                sh "chmod +x startservers.sh"

                echo "Create a Socat to connect to our webserver from the Internet (from outside the EC2 instance)"

                sh "./startservers.sh"
            }
        }
    }
}
