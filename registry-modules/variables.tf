variable "server_port" {
  description = "Application port"
  default = 8080
}

variable "public_key_path" {
  description = "Public key path"
  default = "~/.ssh/id_rsa.pub"
}
