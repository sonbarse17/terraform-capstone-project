output "notebook_name" {
  value = aws_sagemaker_notebook_instance.this.name

}

output "notebook_arn" {
  value = aws_sagemaker_notebook_instance.this.arn
}