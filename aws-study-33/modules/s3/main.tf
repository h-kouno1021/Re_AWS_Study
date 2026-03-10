resource "random_id" "s3_bucket" {
  byte_length = 4
}

resource "aws_s3_bucket" "main" {
  bucket = "${var.name_prefix}-s3-${random_id.s3_bucket.hex}"

  tags = {
    "Name" = "${var.name_prefix}-s3-${random_id.s3_bucket.hex}"
  }
}

resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}
