# Changelog

## 0.1.0 (2026-06-11)


### 🚀 Features

* add azurerm_servicebus_subscription_rule resource ([57ec713](https://github.com/schubergphilis-ep/terraform-azure-mcaf-service-bus/commit/57ec713cf2493ddf2093caa12ad06db8779f730a))
* add complete example with queues, topics, private endpoint, and RBAC ([bef7fab](https://github.com/schubergphilis-ep/terraform-azure-mcaf-service-bus/commit/bef7fabfaf0bc9c7c1ea5c47020d159ec1646f8f))
* add core namespace resource with secure defaults ([8e5c761](https://github.com/schubergphilis-ep/terraform-azure-mcaf-service-bus/commit/8e5c761c1642df2c41e4f07eef8574f733ada77a))
* add customer-managed key encryption support ([37ca41b](https://github.com/schubergphilis-ep/terraform-azure-mcaf-service-bus/commit/37ca41b57a171f9dd08d9a2ad7ad3e0da2cd1c09))
* add managed identity support with system-assigned default ([ba04e0b](https://github.com/schubergphilis-ep/terraform-azure-mcaf-service-bus/commit/ba04e0be9ba196f2bb2cdfe76967184a1ce28d33))
* add module outputs for namespace, queues, topics, and subscriptions ([3db4c10](https://github.com/schubergphilis-ep/terraform-azure-mcaf-service-bus/commit/3db4c102de0e85e64d873cb64e66cb1b7450e4e1))
* add network rule set with deny-by-default ([c783944](https://github.com/schubergphilis-ep/terraform-azure-mcaf-service-bus/commit/c78394401fdb15a88d4c742458da4282ab8506cc))
* add optional private endpoint support ([0009865](https://github.com/schubergphilis-ep/terraform-azure-mcaf-service-bus/commit/0009865a0b9900049aa3440b436e0fbe5153677b))
* add queue support with dead-lettering defaults ([ae75796](https://github.com/schubergphilis-ep/terraform-azure-mcaf-service-bus/commit/ae757963ad2a9a3e979d47461e7e2be4b13736eb))
* add RBAC role assignment support ([483cfef](https://github.com/schubergphilis-ep/terraform-azure-mcaf-service-bus/commit/483cfef813c2c294f31ab18e89cb2e81efdd98d0))
* add rules type definition to topics subscriptions variable ([48c13f8](https://github.com/schubergphilis-ep/terraform-azure-mcaf-service-bus/commit/48c13f896462a7e866378fc3610e5245eb4ded7a))
* add subscription_rule_ids output ([c61d4f5](https://github.com/schubergphilis-ep/terraform-azure-mcaf-service-bus/commit/c61d4f5ab4c86c9b1a9cedb1478f6f6d9dc723d9))
* add subscription_rules local flattening topic/subscription/rule hierarchy ([3c546f8](https://github.com/schubergphilis-ep/terraform-azure-mcaf-service-bus/commit/3c546f81413c86ea784d5db67e30b13f50ae9e96))
* add topic and subscription support with dead-lettering defaults ([2edd13d](https://github.com/schubergphilis-ep/terraform-azure-mcaf-service-bus/commit/2edd13dfbfbcf08a128247d575eef0a057a6621a))
* scaffold terraform-azure-mcaf-servicebus module ([c5fb6e0](https://github.com/schubergphilis-ep/terraform-azure-mcaf-service-bus/commit/c5fb6e03cf8749e33b965468be2a9d0d1cceac66))


### 🐛 Fixes

* add depends_on to subscription_rule for explicit ordering ([d3b89e0](https://github.com/schubergphilis-ep/terraform-azure-mcaf-service-bus/commit/d3b89e0552dbf6ee028c95d7935351b91ba0e603))
* add depends_on to subscriptions so queue forward_to references are always resolvable ([f7b550c](https://github.com/schubergphilis-ep/terraform-azure-mcaf-service-bus/commit/f7b550c0f0251c7b7d579dfa28dc1fc3da8ce7c2))
* add lifecycle precondition to guard CMK against missing identity ([1c13054](https://github.com/schubergphilis-ep/terraform-azure-mcaf-service-bus/commit/1c13054d0929ff0bb6a981db96d8b46a6abbe275))
* add user_assigned_identity_ids output, document private endpoint naming constraints ([8639405](https://github.com/schubergphilis-ep/terraform-azure-mcaf-service-bus/commit/863940516a68c9a424552ecd532340f73b5eb09d))
* align correlation_filter field and add filter_type validation ([f7bac76](https://github.com/schubergphilis-ep/terraform-azure-mcaf-service-bus/commit/f7bac76c6f3f061ba396b80d8bc8f6b7ca65ef5b))
* align scaffold files with MCAF managed templates ([076caa5](https://github.com/schubergphilis-ep/terraform-azure-mcaf-service-bus/commit/076caa51b37672f50f88a31044d84d0b6dc1e053))
* guard subscriptions local against missing key, add topics description, remove redundant tomap ([89dcbf5](https://github.com/schubergphilis-ep/terraform-azure-mcaf-service-bus/commit/89dcbf5e75c4e1cfa1ac08b22dde9f04b6bf1a47))
* remove duplicate public_network_access_enabled from network_rule_set block, add nullable guard and vnet test ([49df25e](https://github.com/schubergphilis-ep/terraform-azure-mcaf-service-bus/commit/49df25e9bd9d09700747c781f7895b15664ec34a))
* simplify subscriptions local now that topics is typed, add batched_operations_enabled test ([377d56b](https://github.com/schubergphilis-ep/terraform-azure-mcaf-service-bus/commit/377d56b7b8e752e8e653990bed228659285b9e58))
* use null for non-Premium partitions, add missing partition and validation tests ([11cb653](https://github.com/schubergphilis-ep/terraform-azure-mcaf-service-bus/commit/11cb65339ed2fecd24ab87434dc3b1319e343000))

## Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---
