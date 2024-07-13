

variable "git_repo_url" {
  description = "The URL of the Git repository containing the project code"
  default     = "https://github.com/meghanakoturi/TERRAFORM-POC.git" # Update with your repository URL
}


variable "public_key_path" {
  description = "The path to your public key file"
  default     = "~/.ssh/id_rsa.pub" # Update with the path to your public key file
}


variable "instance_type" {
  description = "The instance type to use for the EC2 instance"
  type        = string
  default     = "t3.medium"
}
