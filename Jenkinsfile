pipeline {
    agent any

    environment {
        AZURE_SP = credentials('AZURE_SP_CREDENTIAL')

        ARM_CLIENT_ID       = "${AZURE_SP_USR}"
        ARM_CLIENT_SECRET   = "${AZURE_SP_PSW}"
        ARM_TENANT_ID       = "dbd6664d-4eb9-46eb-99d8-5c43ba153c61"
        ARM_SUBSCRIPTION_ID = "f4042894-a707-4691-a7c5-9c34c95bbc87"
    }

    stages {

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }
    }
}
