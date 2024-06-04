
variable "SCW_ACCESS_KEY" {
  type = string
}

variable "SCW_SECRET_KEY" {
  type = string
}

variable "SCW_DEFAULT_PROJECT_ID" {
  type = string
}

variable "SCW_DEFAULT_ORGANISATION_ID" {
  type = string
}

variable "TAGS" {
  type = list(string)
  default = [
    "terraform-managed",
    "teleport-demo"
  ]
}

variable "TELEPORT_EDITION" {
  type    = string
  default = "enterprise"
}

variable "TELEPORT_VERSION" {
  type    = string
  default = "15.3.6"
}

variable "SSH_KEYFILE" {
  type    = string
  default = "~/.ssh/id_ed25519"
}