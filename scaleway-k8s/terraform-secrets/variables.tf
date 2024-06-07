
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

variable "SCW_REGION" {
  type    = string
  default = "fr-par"
}

variable "GITHUB_ORG" {
  type    = string
  default = "think-ahead-technologies"
}

variable "GITHUB_REPO" {
  type    = string
  default = "teleport-demo"
}