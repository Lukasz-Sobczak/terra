variable "table_name" {
  description = "Nazwa tabeli DynamoDB"
  type        = string
}

variable "hash_key" {
  description = "Klucz partycji tabeli DynamoDB"
  type        = string
}

variable "attributes" {
    description = "Atrybuty tabeli"
    type = list(object({
      name = string
      type = string
    }))
}