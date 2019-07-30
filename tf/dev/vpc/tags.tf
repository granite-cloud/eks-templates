######
# Assign Common Tags to Resources
######
locals {
  common_tags = {
    Cluster       = var.cluster
    Environment   = var.environment
    Project       = var.project
    Owner         = var.owner
  }
  # Allow for other tags that can be assigned by the caller and merged with required tags
  extra_tags = var.tags
}
