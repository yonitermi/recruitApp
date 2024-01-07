resource "aws_ecr_repository" "recruiters" {
    name                 = "recruiters"
    image_tag_mutability = "MUTABLE"

    image_scanning_configuration {
        scan_on_push = true
    }
}
