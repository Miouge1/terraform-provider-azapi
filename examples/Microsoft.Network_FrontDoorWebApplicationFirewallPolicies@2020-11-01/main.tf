terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
  }
}

provider "azapi" {
  skip_provider_registration = false
}

variable "resource_name" {
  type    = string
  default = "acctest0001"
}

variable "location" {
  type    = string
  default = "westeurope"
}

resource "azapi_resource" "resourceGroup" {
  type                      = "Microsoft.Resources/resourceGroups@2020-06-01"
  name                      = var.resource_name
  location                  = var.location
}

resource "azapi_resource" "FrontDoorWebApplicationFirewallPolicy" {
  type      = "Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2020-11-01"
  parent_id = azapi_resource.resourceGroup.id
  name      = var.resource_name
  location  = "global"
  body = {
    properties = {
      customRules = {
        rules = [
          {
            action       = "Block"
            enabledState = "Enabled"
            matchConditions = [
              {
                matchValue = [
                  "192.168.1.0/24",
                  "10.0.0.0/24",
                ]
                matchVariable   = "RemoteAddr"
                negateCondition = false
                operator        = "IPMatch"
              },
            ]
            name                       = "Rule1"
            priority                   = 1
            rateLimitDurationInMinutes = 1
            rateLimitThreshold         = 10
            ruleType                   = "MatchRule"
          },
        ]
      }
      managedRules = {
        managedRuleSets = [
          {
            ruleGroupOverrides = [
              {
                ruleGroupName = "PHP"
                rules = [
                  {
                    action       = "Block"
                    enabledState = "Disabled"
                    ruleId       = "933111"
                  },
                ]
              },
            ]
            ruleSetAction  = "Block"
            ruleSetType    = "DefaultRuleSet"
            ruleSetVersion = "preview-0.1"
          },
          {
            ruleSetAction  = "Block"
            ruleSetType    = "BotProtection"
            ruleSetVersion = "preview-0.1"
          },
        ]
      }
      policySettings = {
        customBlockResponseBody       = "PGh0bWw+CjxoZWFkZXI+PHRpdGxlPkhlbGxvPC90aXRsZT48L2hlYWRlcj4KPGJvZHk+CkhlbGxvIHdvcmxkCjwvYm9keT4KPC9odG1sPg=="
        customBlockResponseStatusCode = 403
        enabledState                  = "Enabled"
        mode                          = "Prevention"
        redirectUrl                   = "https://www.fabrikam.com"
      }
    }
    sku = {
      name = "Premium_AzureFrontDoor"
    }
  }
  schema_validation_enabled = false
  response_export_values    = ["*"]
}

