variable "tags" {
  type = map(string)
  default = {
    "Purpose"    = "Demo",
    "CostCenter" = "infra"
  }
}