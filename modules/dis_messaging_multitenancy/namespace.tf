locals {
  namespace_name = var.namespace_name != "" ? var.namespace_name : "${var.prefix}-${var.environment}-messaging"
  premium        = var.sku == "Premium"
}

resource "azurerm_servicebus_namespace" "messaging" {
  name                = local.namespace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  tags                = var.tags

  # Premium: one messaging unit at creation, scaled by the autoscale setting below.
  # Standard and Basic only accept 0 for both fields.
  capacity                     = local.premium ? 1 : 0
  premium_messaging_partitions = local.premium ? 1 : 0

  local_auth_enabled  = false # Entra ID is the only authentication
  minimum_tls_version = "1.2"

  network_rule_set {
    default_action           = "Deny"
    ip_rules                 = var.allowed_ipv4_prefixes
    trusted_services_allowed = local.premium # the bypass exists on the Premium tier only
  }

  lifecycle {
    # Deleting the namespace deletes every queue and message of the cluster. An Azure
    # CanNotDelete lock would be inherited by the queues and block the operator's deletes.
    prevent_destroy = true
    ignore_changes  = [capacity] # Azure autoscale changes the messaging units
    precondition {
      # Azure rules: 6-50 characters, letters, digits and hyphens, starts with a letter,
      # ends with a letter or digit, and must not end with -sb or -mgmt. Globally unique.
      condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{4,48}[a-zA-Z0-9]$", local.namespace_name)) && !endswith(local.namespace_name, "-sb") && !endswith(local.namespace_name, "-mgmt")
      error_message = "Namespace name \"${local.namespace_name}\" breaks the Azure Service Bus naming rules."
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "messaging" {
  name                           = "${local.namespace_name}-diagnostics"
  target_resource_id             = azurerm_servicebus_namespace.messaging.id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  log_analytics_destination_type = "Dedicated" # AZMSOperationalLogs and AZMSDiagnosticErrorLogs tables

  enabled_log {
    category = "OperationalLogs" # management operations: create, update and delete of queues and the namespace
  }
  enabled_log {
    category = "DiagnosticErrorLogs" # client, throttling and quota errors
  }
}

locals {
  # Azure's guidance for Premium namespaces: scale out on CPU above 75% or memory
  # above 60%, scale in below 25%, and keep the scale-in cooldown above 30 minutes.
  autoscale_rules = [
    { metric = "NamespaceCpuUsage", operator = "GreaterThan", threshold = 75, direction = "Increase", cooldown = "PT5M" },
    { metric = "NamespaceMemoryUsage", operator = "GreaterThan", threshold = 60, direction = "Increase", cooldown = "PT5M" },
    { metric = "NamespaceCpuUsage", operator = "LessThan", threshold = 25, direction = "Decrease", cooldown = "PT30M" },
    { metric = "NamespaceMemoryUsage", operator = "LessThan", threshold = 25, direction = "Decrease", cooldown = "PT30M" },
  ]
}

resource "azurerm_monitor_autoscale_setting" "messaging" {
  count               = local.premium ? 1 : 0
  name                = "${local.namespace_name}-autoscale"
  location            = var.location
  resource_group_name = var.resource_group_name
  target_resource_id  = azurerm_servicebus_namespace.messaging.id
  tags                = var.tags

  profile {
    name = "default"
    capacity {
      minimum = 1
      maximum = 2
      default = 1
    }

    dynamic "rule" {
      for_each = local.autoscale_rules
      content {
        metric_trigger {
          metric_name        = rule.value.metric
          metric_namespace   = "microsoft.servicebus/namespaces"
          metric_resource_id = azurerm_servicebus_namespace.messaging.id
          operator           = rule.value.operator
          threshold          = rule.value.threshold
          statistic          = "Average"
          time_aggregation   = "Average"
          time_grain         = "PT1M"
          time_window        = "PT10M"
        }
        scale_action {
          direction = rule.value.direction
          type      = "ServiceAllowedNextValue" # messaging units go 1, 2, 4, 8, 16
          value     = 1
          cooldown  = rule.value.cooldown
        }
      }
    }
  }
}
