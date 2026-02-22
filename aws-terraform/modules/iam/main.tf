## iam role

resource "aws_iam_role" "this" {
  name = var.role_name

  assume_role_policy = var.assume_role_policy
  tags               = var.tags
}

resource "aws_iam_policy" "this" {
  name   = "${var.role_name}-policy"
  policy = var.policy_json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_instance_profile" "this" {
  name = var.role_name
  role = aws_iam_role.this.name
}