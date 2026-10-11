data "aws_iam_policy_document" "assume_ec2" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ssm" {
  name               = "${var.name}-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.assume_ec2.json
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Optional SQS access limited to the given queues
data "aws_iam_policy_document" "sqs_access" {
  count = length(var.sqs_queue_arns) > 0 ? 1 : 0

  statement {
    sid = "UseQueues"
    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueUrl",
      "sqs:GetQueueAttributes",
    ]
    resources = var.sqs_queue_arns
  }
}

resource "aws_iam_role_policy" "sqs_access" {
  count = length(var.sqs_queue_arns) > 0 ? 1 : 0

  name   = "${var.name}-sqs-access"
  role   = aws_iam_role.ssm.id
  policy = data.aws_iam_policy_document.sqs_access[0].json
}

resource "aws_iam_instance_profile" "ssm" {
  name = "${var.name}-ssm-profile"
  role = aws_iam_role.ssm.name
}
