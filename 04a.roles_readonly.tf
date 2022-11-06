data "aws_iam_policy_document" "irsa_users_readonly-assume-role-policy" {
  for_each = var.irsa_users_readonly
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${each.value.eks_oidc_id}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${each.value.eks_oidc_id}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "${each.value.eks_oidc_id}:sub"
      values   = ["system:serviceaccount:${each.value.namespace}:${each.value.service_account}"]
    }
  }
}

resource "aws_iam_role" "irsa_users_readonly" {
  for_each = var.irsa_users_readonly

  name               = "MongoDBAtlas-irsa_read-${mongodbatlas_project.this.name}-${each.value.namespace}"
  assume_role_policy = data.aws_iam_policy_document.irsa_users_readonly-assume-role-policy[each.key].json
  tags               = merge({ "Name" = "MongoDBAtlas-irsa_users_readonlyServiceRole-${mongodbatlas_project.this.name}" }, var.tags)
}


 