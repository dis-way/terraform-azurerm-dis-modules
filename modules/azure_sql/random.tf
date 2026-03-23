resource "random_string" "db_name_suffix" {
  length  = 6
  upper   = false
  lower   = true
  numeric = false
  special = false
}
