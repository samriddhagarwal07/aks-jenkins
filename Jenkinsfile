pipeline {
    agent any

    environment {
        TERRAFORM_PATH = 'C:\\Users\\Samriddh\\Downloads\\terraform_1.11.3_windows_386\\terraform.exe'
        TF_VAR_client_id = credentials('AZURE_CLIENT_ID')
        TF_VAR_client_secret = credentials('AZURE_CLIENT_SECRET')
        TF_VAR_tenant_id = credentials('AZURE_TENANT_ID')
        TF_VAR_subscription_id = credentials('AZURE_SUBSCRIPTION_ID')
        ACR_NAME = "myacrsam"
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/samriddhagarwal07/aks-jenkins.git'
            }
        }

        stage('Build .NET App') {
            steps {
                bat 'echo Checking .NET SDK version'
                bat 'dotnet --version'
                bat 'dotnet publish dotnet-aks/dotnet-aks.csproj -c Release --framework net8.0'
            }
        }

        stage('Build Docker Image') {
            steps {
                bat 'docker build -t myacrsam.azurecr.io/mywebapi:latest -f dotnet-aks/Dockerfile .'
            }
        }

        stage('Check Terraform Files') {
            steps {
                bat 'echo Checking for Terraform files in terraform'
                bat 'cd terraform && dir *.tf'
            }
        }

        stage('Install Terraform') {
            steps {
                bat "${TERRAFORM_PATH} -version"
            }
        }

        stage('Terraform Format') {
            steps {
                bat "cd terraform && ${TERRAFORM_PATH} fmt"
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([
                    string(credentialsId: 'AZURE_CLIENT_ID', variable: 'ARM_CLIENT_ID'),
                    string(credentialsId: 'AZURE_CLIENT_SECRET', variable: 'ARM_CLIENT_SECRET'),
                    string(credentialsId: 'AZURE_SUBSCRIPTION_ID', variable: 'ARM_SUBSCRIPTION_ID'),
                    string(credentialsId: 'AZURE_TENANT_ID', variable: 'ARM_TENANT_ID')
                ]) {
                    bat "cd terraform && ${TERRAFORM_PATH} init"
                }
            }
        }

        stage('Terraform Import Existing Resources') {
            steps {
                withCredentials([
                    string(credentialsId: 'AZURE_CLIENT_ID', variable: 'ARM_CLIENT_ID'),
                    string(credentialsId: 'AZURE_CLIENT_SECRET', variable: 'ARM_CLIENT_SECRET'),
                    string(credentialsId: 'AZURE_SUBSCRIPTION_ID', variable: 'ARM_SUBSCRIPTION_ID'),
                    string(credentialsId: 'AZURE_TENANT_ID', variable: 'ARM_TENANT_ID')
                ]) {
                    bat """
                        cd terraform
                        ${TERRAFORM_PATH} state list | findstr azurerm_resource_group.rg > nul
                        if %errorlevel% neq 0 (
                            echo Importing resource group...
                            ${TERRAFORM_PATH} import azurerm_resource_group.rg /subscriptions/%ARM_SUBSCRIPTION_ID%/resourceGroups/myResourceGroup
                        ) else (
                            echo Resource group already managed by Terraform. Skipping import.
                        )
                    """
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                bat "cd terraform && ${TERRAFORM_PATH} plan"
            }
        }

        stage('Terraform Apply') {
            steps {
                bat "cd terraform && ${TERRAFORM_PATH} apply -auto-approve"
            }
        }

        stage('Login to ACR') {
            steps {
                bat "az acr login --name ${env.ACR_NAME}"
            }
        }

        stage('Push Docker Image to ACR') {
            steps {
                bat "docker push ${env.ACR_NAME}.azurecr.io/mywebapi:latest"
            }
        }

        stage('Get AKS Credentials') {
            steps {
                bat 'az aks get-credentials --resource-group myResourceGroup --name myAKSCluster'
            }
        }

        stage('Deploy to AKS') {
            steps {
                bat 'kubectl apply -f manifests/deployment.yaml'
                bat 'kubectl apply -f manifests/service.yaml'
            }
        }
    }

    post {
        failure {
            echo "❌ Build failed."
        }
        success {
            echo "✅ Build succeeded!"
        }
    }
}
