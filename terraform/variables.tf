variable "project_id" {
  description = "The project ID to host the cluster in"
  default     = "cohere-development"
}

variable "region" {
  description = "The region to host the cluster in"
  default     = "us-central1"
}

variable "zones" {
  description = "The zone to host the cluster in (required if is a zonal cluster)"
  default     = ["us-central1-a"]
}

variable "network" {
  description = "The name of the network created to host the cluster"
  default = "aaron-benchmark"
}

variable "bucket" {
  description = "The name of the bucket to create for testing"
  default     = "cohere-gcp-benchmark"
}

variable "cluster" {
  description = "The name of the cluster"
  default     = "aaron-benchmark"
}

variable "vm_name" {
  description = "The name of the vm"
  default     = "aaron-benchmark"
}


variable "vm_user" {
  description = "The name of the user on the vm for ssh"
  default     = "aaron"
}
