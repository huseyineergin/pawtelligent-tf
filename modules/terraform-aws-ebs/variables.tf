variable "availability_zone" {
  description = "The AZ where the EBS volume will exist"
  type        = string
  default     = null
}

variable "encrypted" {
  description = "If true, the disk will be encrypted"
  type        = bool
  default     = false
}

variable "iops" {
  description = "The amount of IOPS to provision for the disk. Only valid for type of io1, io2 or gp3"
  type        = number
  default     = null
}

variable "size" {
  description = "The size of the drive in GiBs"
  type        = number
  default     = null
}

variable "type" {
  description = "The type of EBS volume. Can be standard, gp2, gp3, io1, io2, sc1 or st1 (Default: gp2)"
  type        = string
  default     = "gp2"
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "device_name" {
  description = "The device name to expose to the instance (for example, /dev/sdh or xvdh)"
  type        = string
  default     = null
}

variable "instance_id" {
  description = "ID of the Instance to attach to"
  type        = string
  default     = null
}