resource "aws_kms_key" "kiwi" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "kiwi" {
  bucket = "${var.tags["Environment"]}-${var.tags["AppName"]}-artifacts"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.kiwi.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

# Outputs
output "bucket_name" {
  value = "${aws_s3_bucket.kiwi.id}"
}