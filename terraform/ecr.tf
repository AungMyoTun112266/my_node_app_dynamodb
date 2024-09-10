resource "aws_ecr_repository" "my-node-app" {
  name                 = local.image_name
  image_tag_mutability = "MUTABLE"
}
