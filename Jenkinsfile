pipeline {
    agent any

    environment {
        ARM_CLIENT_ID       = credentials('AZURE_SP_CREDENTIAL_USR')
        ARM_CLIENT_SECRET   = credentials('AZURE_SP_CREDENTIAL_PSW')
        ARM_SUBSCRIPTION_ID = 'f4042894-a707-4691-a7c5-9c34c95bbc87'
        ARM_TENANT_ID       = 'dbd6664d-4eb9-46eb-99d8-5c43ba153c61'
    }

    stages {
        stage('Terraform Init') {
            steps {
                bat 'terraform init'
            }
        }
        stage('Terraform Plan') {
            steps {
                bat """
                terraform plan \
                  -var "client_id=${ARM_CLIENT_ID}" \
                  -var "client_secret=${ARM_CLIENT_SECRET}" \
                  -var "tenant_id=${ARM_TENANT_ID}" \
                  -var "subscription_id=${ARM_SUBSCRIPTION_ID}" \
                  -out=tfplan
                """
            }
        }
        stage('Terraform Apply') {
            steps {
                bat 'terraform apply -auto-approve tfplan'
            }
        }
    }
}
