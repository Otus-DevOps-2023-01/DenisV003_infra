
terraform {
  backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "terraform-2-storage-bucket"
    region     = "ru-central1"
    key        = "stage.tfstate"
    access_key = "YCAJEL_Jc5jE5PEPgWPOuIm5I"
    secret_key = "YCODWiiWK3psyY2TBxQ7sTJywSOmcFBrBGzCNHK_"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}