variable "instanceType" {
  type    = string
  default = "t3.medium"
}

variable "x" {
  type    = string
  default = "hello"
}

variable "instanceTagName" {
  type    = string
  default = "GFGTerraform"
}

variable "amiID" {
  default = "ami-0a0f1259dd1c90938"
}

variable "sg_name" {
  # CHANGED: Updated default name to bypass the duplicate Security Group error
  default = "WebserverSgnew-v2" 
}

variable "public_key_material" {
  type        = string
  description = "The public key material supplied securely by Jenkins"
}