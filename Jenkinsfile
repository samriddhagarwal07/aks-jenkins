pipeline {
    agent any

    environment {
        ACR_NAME = 'myacrsam'
        AZURE_CREDENTIALS_ID = 'jenkins-pipeline-sp'
        ACR_LOGIN_SERVER = "${ACR_NAME}.azurecr.io"
        IMAGE_NAME = 'mywebapi'
        IMAGE_TAG = 'latest'
        RESOURCE_GROUP = 'myResourceGroup'
        AKS_CLUSTER = 'myAKSCluster'
        TF_WORKING_DIR = 'terraform'
        TF_PATH = 'C:\\Users\\Samriddh\\Downloads\\terraform_1.11.3_windows_386\\terraform.exe'
        PATH = "$PATH;C:\\Users\\Samriddh\\Downloads\\terraform_1.11.3_windows_386"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/samriddhagarwal07/aks-jenkins.git'
            }
        }

        // stage('Build .NET App') {
        //     steps {
        //         bat """
        //         echo Checking .NET SDK version
        //         dotnet --version
        //         dotnet publish dotnet-aks/dotnet-aks.csproj -c Release --framework net8.0
        //         """
        //     }
        // }

        stage('Azure Login') {
            steps {
                withCredentials([azureServicePrincipal(
                    credentialsId: "${AZURE_CREDENTIALS_ID}",
                    subscriptionIdVariable: 'AZ_SUBSCRIPTION_ID',
                    clientIdVariable: 'AZ_CLIENT_ID',
                    clientSecretVariable: 'AZ_CLIENT_SECRET',
                    tenantIdVariable: 'AZ_TENANT_ID'
                )]) {
                    bat '''
                        az login --service-principal -u %AZ_CLIENT_ID% -p %AZ_CLIENT_SECRET% --tenant %AZ_TENANT_ID%
                        az account set --subscription %AZ_SUBSCRIPTION_ID%
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                bat "docker build -t %ACR_LOGIN_SERVER%/%IMAGE_NAME%:%IMAGE_TAG% -f dotnet-aks/Dockerfile ."
            }
        }

        // stage('Check Terraform Files') {
        //     steps {
        //         bat """
        //         echo Checking for Terraform files in %TF_WORKING_DIR%
        //         cd %TF_WORKING_DIR%
        //         dir *.tf
        //         """
        //     }
        // }

        // stage('Install Terraform') {
        //     steps {
        //         bat "%TF_PATH% -version"
        //     }
        // }

        // stage('Terraform Format') {
        //     steps {
        //         bat """
        //         cd %TF_WORKING_DIR%
        //         %TF_PATH% fmt
        //         """
        //     }
        // }

        stage('Terraform Init') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                    bat """
                    cd %TF_WORKING_DIR%
                    %TF_PATH% init
                    """
                }
            }
        }

        stage('Terraform Plan & Apply') {
           steps {
               
               bat '"%TERRAFORM_PATH%" -chdir=terraform plan -out=tfplan'
               bat '"%TERRAFORM_PATH%" -chdir=terraform apply -auto-approve tfplan'
           }
     }

        stage('Login to ACR') {
            steps {
                bat "az acr login --name %ACR_NAME%"
            }
        }

        stage('Push Docker Image to ACR') {
            steps {
                bat "docker push %ACR_LOGIN_SERVER%/%IMAGE_NAME%:%IMAGE_TAG%"
            }
        }

        stage('Get AKS Credentials') {
            steps {
                bat "az aks get-credentials --resource-group %RESOURCE_GROUP% --name %AKS_CLUSTER% --overwrite-existing"
            }
        }

        stage('Deploy to AKS') {
            steps {
                bat "kubectl apply -f deployment.yaml"
            }
        }
    }

    post {
        success {
            echo '✅ All stages completed successfully!'
        }
        failure {
            echo '❌ Build failed.'
        }
    }
}
