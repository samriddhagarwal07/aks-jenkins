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

        stage('Build .NET App') {
            steps {
                bat """
                echo Checking .NET SDK version
                dotnet --version
                dotnet publish dotnet-aks/dotnet-aks.csproj -c Release --framework net8.0
                """
            }
        }

        stage('Build Docker Image') {
            steps {
                bat "docker build -t %ACR_LOGIN_SERVER%/%IMAGE_NAME%:%IMAGE_TAG% -f dotnet-aks/Dockerfile ."
            }
        }

        stage('Check Terraform Files') {
            steps {
                bat """
                echo Checking for Terraform files in %TF_WORKING_DIR%
                cd %TF_WORKING_DIR%
                dir *.tf
                """
            }
        }

        stage('Install Terraform') {
            steps {
                bat "%TF_PATH% -version"
            }
        }

        stage('Terraform Format') {
            steps {
                bat """
                cd %TF_WORKING_DIR%
                %TF_PATH% fmt
                """
            }
        }

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

        stage('Terraform Import Existing Resources') {
            steps {
                withCredentials([azureServicePrincipal(
                    credentialsId: AZURE_CREDENTIALS_ID,
                    subscriptionIdVariable: 'AZURE_SUBSCRIPTION_ID',
                    clientIdVariable: 'AZURE_CLIENT_ID',
                    clientSecretVariable: 'AZURE_CLIENT_SECRET',
                    tenantIdVariable: 'AZURE_TENANT_ID'
                )]) {
                    script {
                        try {
                            bat """
                            cd %TF_WORKING_DIR%
                            set ARM_CLIENT_ID=%AZURE_CLIENT_ID%
                            set ARM_CLIENT_SECRET=%AZURE_CLIENT_SECRET%
                            set ARM_SUBSCRIPTION_ID=%AZURE_SUBSCRIPTION_ID%
                            set ARM_TENANT_ID=%AZURE_TENANT_ID%
                            %TF_PATH% import azurerm_resource_group.rg /subscriptions/%AZURE_SUBSCRIPTION_ID%/resourceGroups/%RESOURCE_GROUP%
                            """
                        } catch (Exception e) {
                            echo "Resource already managed by Terraform or other import issue, skipping import."
                        }
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: AZURE_CREDENTIALS_ID)]) {
                    bat """
                    cd %TF_WORKING_DIR%
                    %TF_PATH% plan -out=tfplan
                    """
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([azureServicePrincipal(
                    credentialsId: AZURE_CREDENTIALS_ID,
                    subscriptionIdVariable: 'AZURE_SUBSCRIPTION_ID',
                    clientIdVariable: 'AZURE_CLIENT_ID',
                    clientSecretVariable: 'AZURE_CLIENT_SECRET',
                    tenantIdVariable: 'AZURE_TENANT_ID'
                )]) {
                    bat """
                    cd %TF_WORKING_DIR%
                    set ARM_CLIENT_ID=%AZURE_CLIENT_ID%
                    set ARM_CLIENT_SECRET=%AZURE_CLIENT_SECRET%
                    set ARM_SUBSCRIPTION_ID=%AZURE_SUBSCRIPTION_ID%
                    set ARM_TENANT_ID=%AZURE_TENANT_ID%
                    %TF_PATH% apply -auto-approve tfplan
                    """
                }
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
