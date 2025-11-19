pipeline {
  agent any
  environment {
    ARM_CLIENT_ID     = credentials('AZURE_SP_CREDENTIAL')
    ARM_CLIENT_SECRET = credentials('AZURE_SP_CREDENTIAL')
    ARM_TENANT_ID     = '<TENANT_ID>'
    ARM_SUBSCRIPTION_ID = '<SUBSCRIPTION_ID>'
  }

  stages {
    stage('Terraform Init') {
      steps { bat 'terraform init' }
    }

    stage('Terraform Plan') {
      steps { bat 'terraform plan -out=tfplan' }
    }

    stage('Terraform Apply') {
      steps { bat 'terraform apply -auto-approve tfplan' }
    }

    stage('Generate Inventory') {
      steps {
        bat '''
        for /f "delims=" %%i in ('az vm list-ip-addresses -g rg-tp-devops -n vm-tp --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv') do set PUBIP=%%i
        copy inventory.ini.template inventory.ini
        powershell -Command "(Get-Content inventory.ini) -replace '<IP_DE_LA_VM>', '%PUBIP%' | Set-Content inventory.ini"
        '''
      }
    }

    stage('Deploy Docker with Ansible') {
      steps {
        bat 'ansible-playbook -i inventory.ini playbook.yml'
      }
    }
  }
}
