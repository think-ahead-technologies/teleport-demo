
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

variable "GITHUB_ACCESS_TOKEN" {
    type = string
}

variable "GITHUB_ORG" {
    type = string
    default = "think-ahead-technologies"
}

variable "GITHUB_REPO" {
    type = string
    default = "state"
}