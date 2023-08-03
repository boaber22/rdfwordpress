#This section of the code provides the resources used to create an s3 bucket, polices and and IAM user/policy
#that will allow a Wordpress plugin to manage the S3 bucket to cache media. 


#Create an S3 bucket that will be the repository for the Wordpress site media
resource "aws_s3_bucket" "rdf_S3_bucket" {
  bucket = "robertdoesfishing-wordpress"

  tags = {
    Project = var.ProjectName
  }
}

#Disable block public access setting on bucket
resource "aws_s3_bucket_public_access_block" "rdf_S3_public" {
  bucket              = aws_s3_bucket.rdf_S3_bucket.id
  block_public_acls   = false
  block_public_policy = false
}

#Create a bucket policy that will make objects in the bucket readable to public
resource "aws_s3_bucket_policy" "rdf_public_read_access" {
  bucket = aws_s3_bucket.rdf_S3_bucket.id
  policy = <<EOF
{  
"Statement": [
{
"Effect": "Allow",
"Principal": "*",
"Action": ["s3:GetObject" ],
"Resource": [
"${aws_s3_bucket.rdf_S3_bucket.arn}",
"${aws_s3_bucket.rdf_S3_bucket.arn}/*"
]
}
]
}
EOF
}


#Create an IAM user with programmatic access that will be used by Wordpress plugin for caching media on S3 
resource "aws_iam_user" "rdf_wp_s3_user" {
  name = "rdf_wp_s3_bucket"
  path = "/"
}

#Create Access keys for the new IAM user to have programmatic access
resource "aws_iam_access_key" "rdf_wp_s3_ak_" {
  user = aws_iam_user.rdf_wp_s3_user.name
}

#Create IAM policy for the account granting the necessary S3 permissions required by the Wordpress plugin
resource "aws_iam_user_policy" "rdf_s3_wp_iampol" {
  name   = "rdf_wp_s3_policy"
  user   = aws_iam_user.rdf_wp_s3_user.id
  policy = <<EOF
{  
"Statement": [
{
"Effect": "Allow",
"Action": [
"s3:CreateBucket",
"s3:DeleteObject",
"s3:Put*",
"s3:Get*",
"s3:List*" 
],
"Resource": [
"${aws_s3_bucket.rdf_S3_bucket.arn}",
"${aws_s3_bucket.rdf_S3_bucket.arn}/*"
]
}
]
}
EOF
}



