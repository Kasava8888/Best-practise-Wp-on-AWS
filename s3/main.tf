resource "aws_s3_bucket" "s3" {
  bucket = "haidang-24-08-2024"
  tags = {
    Name = "${var.project_name}-s3"
  }
}