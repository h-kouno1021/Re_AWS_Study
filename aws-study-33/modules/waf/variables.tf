variable "name_prefix" {
  type = string
  description = "Resourses name prefix"
}

variable "web_acl_association_resource_arn" {
  type = string
	description = "The ARN of the resource to associate with the WebACL"
}
