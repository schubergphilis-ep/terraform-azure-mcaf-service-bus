locals {
  identity_system_assigned_user_assigned = (var.system_assigned_identity_enabled && length(var.user_assigned_identities) > 0) ? {
    this = {
      type                       = "SystemAssigned, UserAssigned"
      user_assigned_resource_ids = var.user_assigned_identities
    }
  } : null

  identity_system_assigned = (var.system_assigned_identity_enabled && length(var.user_assigned_identities) == 0) ? {
    this = {
      type                       = "SystemAssigned"
      user_assigned_resource_ids = null
    }
  } : null

  identity_user_assigned = (!var.system_assigned_identity_enabled && length(var.user_assigned_identities) > 0) ? {
    this = {
      type                       = "UserAssigned"
      user_assigned_resource_ids = var.user_assigned_identities
    }
  } : null

  subscriptions = {
    for item in flatten([
      for topic_key, topic in var.topics : [
        for sub_key, sub in topic.subscriptions : {
          topic_key = topic_key
          sub_key   = sub_key
          config    = sub
        }
      ]
    ]) : "${item.topic_key}/${item.sub_key}" => item
  }

  subscription_rules = {
    for item in flatten([
      for topic_key, topic in var.topics : [
        for sub_key, sub in topic.subscriptions : [
          for rule_key, rule in sub.rules : {
            topic_key = topic_key
            sub_key   = sub_key
            rule_key  = rule_key
            config    = rule
          }
        ]
      ]
    ]) : "${item.topic_key}/${item.sub_key}/${item.rule_key}" => item
  }
}
