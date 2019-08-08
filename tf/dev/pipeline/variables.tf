variable "cluster" {
  description = "The name of the cluster"
  type        = string
}

variable "demand_kube_args" {
  description = "This string is passed directly to kubelet if set. Useful for adding labels or taints."
  type        = string
  default     = "--node-labels=ondemand=yes"
}

variable "demand_max_size" {
  description = "Max size of autoscale group"
  type        = number
  default     = 3
}
