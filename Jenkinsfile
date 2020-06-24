pipeline {
  agent any
  
  stages {

	  stage('Create Image') {
       steps {
           sh '/usr/local/bin/packer validate packer.json'
	   sh '/usr/local/bin/packer build packer.json'
       	      }
     			}
	  
	    stage('creando imagen... ') {
       steps {
           sleep 15 //seconds
       	      }
     			}
	  
        stage('TF Plan') {
       steps {
           sh '/usr/local/bin/terraform init -input=false'
	   sh '/usr/local/bin/terraform state list'
	   sh '/usr/local/bin/terraform state rm data.azurerm_client_config.current'
           sh '/usr/local/bin/terraform state rm azurerm_key_vault.main'
           sh '/usr/local/bin/terraform state rm azurerm_key_vault_certificate.main'
	   sh '/usr/local/bin/terraform state rm azurerm_network_interface.main'
   	   sh '/usr/local/bin/terraform state rm azurerm_network_interface_security_group_association.main'
           sh '/usr/local/bin/terraform state rm azurerm_network_security_group.main'
           sh '/usr/local/bin/terraform state rm azurerm_public_ip.main'
           sh '/usr/local/bin/terraform state rm azurerm_resource_group.main'
           sh '/usr/local/bin/terraform state rm azurerm_subnet.internal'
           sh '/usr/local/bin/terraform state rm azurerm_virtual_machine.main'
           sh '/usr/local/bin/terraform state rm azurerm_virtual_network.main' 
           sh '/usr/local/bin/terraform state list'
	   sh '/usr/local/bin/terraform refresh'
           sh '/usr/local/bin/terraform plan -out=myplan -input=false'
       	      }
     			}
	 stage('Validacion') {
      	steps {
           sh '/usr/local/bin/terraform validate'
	}
	 }
	  
	 stage('Approval-Apply') {
        steps {
        script {
          def userInput = input(id: 'confirm', message: 'Apply Terraform?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
        }
          sh '/usr/local/bin/terraform apply -input=false myplan'
        }
      } 

         }
 }
