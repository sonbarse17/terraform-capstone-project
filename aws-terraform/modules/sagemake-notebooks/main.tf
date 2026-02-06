resource "aws_sagemaker_notebook_instance" "this" {
  name = var.notebook_name
  instance_type = var.instance_type
  role_arn = var.role_arn
  subnet_id = var.subnet_id
  security_groups = var.security_group_ids
  direct_internet_access = "Disabled"

  tags = var.tags
}