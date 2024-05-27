
resource "scaleway_object_bucket" "terraform-state" {
  name = "think-ahead-teleport-demo-terraform-state"
  tags = {
    control = "terraform-managed"
    project = "teleport-demo-setup"
  }
}

output "bucket-endpoint" {
  value = scaleway_object_bucket.terraform-state.api_endpoint
}

output "bucket-name" {
  value = scaleway_object_bucket.terraform-state.name
}