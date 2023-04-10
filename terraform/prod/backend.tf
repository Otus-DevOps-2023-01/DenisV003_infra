
terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "terraform-2-storage-bucket"
    region     = "ru-central1"
    key        = "stage.tfstate"
    access_key = "YCAJEpcmLx81tOidKrDQcRXBE"
    secret_key = "YCMlAf-cP2ANDSD0QOWq26T8Bcz04AJtQqd_WcMh"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}