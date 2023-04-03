data "aws_iam_policy_document" "default" {
  count = var.enabled == "true" ? 1 : 0

  statement {
    actions   = var.s3_actions
    resources = var.s3_resources
    effect    = "Allow"
  }

  dynamic "statement" {
    for_each = (var.name == "zapier") ? [1] : []

    content {
      sid = "AllBucketPermissions"
      actions   = [
                    "s3:ListAllMyBuckets",
                    "s3:GetBucketLocation"
                  ]
      resources = ["arn:aws:s3:::*"]
      effect    = "Allow"
    }
  }
}


module "s3_user" {
  source        = "git::https://github.com/betterworks/terraform-aws-iam-system-user.git?ref=tf-upgrade"
  namespace     = var.namespace
  stage         = var.stage
  name          = var.name
  attributes    = var.attributes
  tags          = var.tags
  enabled       = var.enabled
  force_destroy = var.force_destroy
  path          = var.path
}

resource "aws_iam_user_policy" "default" {
  count  = var.enabled == "true" ? 1 : 0
  name   = module.s3_user.user_name
  user   = module.s3_user.user_name
  policy = join("", data.aws_iam_policy_document.default.*.json)
}

