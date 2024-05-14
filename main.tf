terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.28.0"
    }
  }
}

provider "google" {
  # Configuration options
  project      = "vocal-antler-416401"
  region       = "us-central1"
  zone         = "us-central-a"
  credentials  = "vocal-antler-416401-43589634bd2b.json"
}

resource "google_storage_bucket" "terraformguybucket1" {
  name          = "wecanterraform"
  location      = "EU"
  force_destroy = true

  uniform_bucket_level_access = false

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

# Bucket ACL to public read
resource "google_storage_bucket_acl" "bucket_acl" {
  bucket         = google_storage_bucket.terraformguybucket1.name
  predefined_acl = "publicRead"
}

# Uploading and setting public read access for HTML files
resource "google_storage_bucket_object" "upload_html1" {
  for_each     = fileset("${path.module}/", "*.html")
  bucket       = google_storage_bucket.terraformguybucket1.name
  name         = each.value
  source       = "${path.module}/${each.value}"
  content_type = "text/html"
}

# Public ACL for each HTML file
resource "google_storage_bucket_acl" "html_acl1" {
  for_each       = google_storage_bucket_object.upload_html1
  bucket         = google_storage_bucket_object.upload_html1[each.key].bucket
  #object         = google_storage_bucket_object.upload_html1[each.key].name
  predefined_acl = "publicRead"
}

# Uploading and setting public read access for image files
resource "google_storage_bucket_object" "upload_image1" {
  for_each     = fileset("${path.module}/", "*.jpg")
  bucket       = google_storage_bucket.terraformguybucket1.name
  name         = each.value
  source       = "${path.module}/${each.value}"
  content_type = "image/jpeg"
}

# Public ACL for each image file
resource "google_storage_bucket_acl" "image_acl1" {
  for_each       = google_storage_bucket_object.upload_image1
  bucket         = google_storage_bucket_object.upload_image1[each.key].bucket
  #object         = google_storage_bucket_object.upload_image1[each.key].name
  predefined_acl = "publicRead"
}

output "website_url" {
  value = "https://storage.googleapis.com/${google_storage_bucket.terraformguybucket1.name}/index.html"
}
