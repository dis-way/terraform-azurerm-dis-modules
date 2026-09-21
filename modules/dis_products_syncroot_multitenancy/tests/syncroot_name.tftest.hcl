mock_provider "azurerm" {}
mock_provider "azapi" {}
mock_provider "random" {}

variables {
  product         = "access-management"
  environment     = "at22"
  aks_cluster_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test/providers/Microsoft.ContainerService/managedClusters/test"
  admin_group_id  = "11111111-1111-1111-1111-111111111111"
  reader_group_id = "22222222-2222-2222-2222-222222222222"
}

run "default_syncroot_uses_product_name" {
  command = plan

  assert {
    condition     = azapi_resource.syncroot.body.properties.ociRepository.url == "oci://altinncr.azurecr.io/access-management/syncroot"
    error_message = "Existing callers must keep using the product name for the syncroot URL."
  }
}

run "custom_syncroot_preserves_product_identity" {
  command = plan

  variables {
    syncroot_name = "accessmanagement"
  }

  assert {
    condition     = azapi_resource.syncroot.body.properties.ociRepository.url == "oci://altinncr.azurecr.io/accessmanagement/syncroot"
    error_message = "The syncroot URL must use the explicit registry prefix."
  }

  assert {
    condition = (
      azapi_resource.syncroot.body.properties.namespace == "product-access-management" &&
      toset(keys(azapi_resource.syncroot.body.properties.kustomizations)) == toset(["access-management"]) &&
      azapi_resource.syncroot.body.properties.ociRepository.repositoryRef.tag == "at22" &&
      azapi_resource.syncroot.body.properties.kustomizations["access-management"].path == "./at22"
    )
    error_message = "Overriding the syncroot name must preserve the product namespace, Kustomization key, environment tag, and path."
  }

  assert {
    condition = (
      azurerm_role_assignment.namespace_admin.scope == "${var.aks_cluster_id}/namespaces/product-access-management" &&
      azurerm_role_assignment.namespace_reader.scope == "${var.aks_cluster_id}/namespaces/product-access-management"
    )
    error_message = "Namespace access must remain scoped to the product name."
  }
}
