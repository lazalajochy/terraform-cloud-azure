# provides configuration details for terraform

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}



# provides configuration details for the azure terraform provider

provider "azurerm" {
  features {}
  subscription_id = "147d994b-4b52-4afe-b06f-1465aba9d63e"
}




# provides the resource group to logically contain resources

resource "azurerm_resource_group" "rg" {
  name     = "terraform-cloud-test"
  location = "eastus"
  tags = {
    environment = "cloud-test"
    source      = "terraform"
    owner       = "jochy"
    cloud       = "Yes"
    provider    = "terraform cloud"

  }
}

#    # Imagen en el ACR (debes subirla manualmente o luego automatizar con CI/CD)

# 🐳 Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "acrjochy"
  resource_group_name = "terraform-cloud-test"
  location            = "eastus"
  sku                 = "Basic" # puedes usar Standard o Premium si es para producción
  admin_enabled       = true    # habilita usuario/contraseña para el pipeline

  tags = {
    environment = "test"
    source      = "terraform"
    owner       = "jochy"
  }
}


# 🧩 Azure Container Instance (para desplegar el backend)
resource "azurerm_container_group" "nestjs_container" {
  name                = "nestjs-container"
  location            = "eastus"
  resource_group_name = "terraform-cloud-test"
  os_type             = "Linux"

  container {
    name   = "nestjs-app"
    image  = "${azurerm_container_registry.acr.login_server}/common" # o el tag que usaste en el push
    cpu    = 1
    memory = 1.5
    ports {
      port     = 3000
      protocol = "TCP"
    }

    environment_variables = {
      NODE_ENV = "production"
      PORT     = "3000"
    }
  }

  image_registry_credential {
    server   = azurerm_container_registry.acr.login_server
    username = azurerm_container_registry.acr.admin_username
    password = azurerm_container_registry.acr.admin_password
  }

  ip_address_type = "Public"
  dns_name_label  = "nestjscloud-${random_integer.suffix.result}" # genera un subdominio único
}

# genera un número aleatorio para evitar conflicto con otros dns_name_label
resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}
