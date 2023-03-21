# terraform {
#   required_version = "~> 0.12"
#   required_providers {
#     yandex = {
#       source  = "yandex-cloud/yandex"
#       version = "~> 0.35"
#     }
#   }
# }
provider "yandex" {
  service_account_key_file = var.service_account_key_file
  token                    = var.ycloud_token
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
}
resource "yandex_compute_instance" "app" {
  name  = "reddit-app-${count.index}"
  count = var.count_app
  zone  = var.zone
  resources {
    cores  = 2
    memory = 2
  }
  boot_disk {
    initialize_params {
      # Указать id образа созданного в предыдущем домашем задании
      image_id = var.image_id
    }
  }
  network_interface {
    # Указан id подсети default-ru-central1-a
    subnet_id = var.subnet_id
    nat       = true
  }
  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }
  connection {
    type  = "ssh"
    host  = self.network_interface.0.nat_ip_address
    user  = "ubuntu"
    agent = false
    # путь до приватного ключа
    private_key = file(var.private_key)
  }
  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }
  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }

}
# resource "yandex_compute_instance" "app2" {
#   name = "reddit-app2"
#   #count = var.count_app
#   resources {
#     cores  = 2
#     memory = 2
#   }
#   boot_disk {
#     initialize_params {
#       # Указать id образа созданного в предыдущем домашем задании
#       image_id = var.image_id
#     }
#   }
#   network_interface {
#     # Указан id подсети default-ru-central1-a
#     subnet_id = var.subnet_id
#     nat       = true
#   }
#   metadata = {
#     ssh-keys = "ubuntu:${file(var.public_key_path)}"
#   }
#   connection {
#     type  = "ssh"
#     host  = yandex_compute_instance.app2.network_interface.0.nat_ip_address
#     user  = "ubuntu"
#     agent = false
#     # путь до приватного ключа
#     private_key = file(var.private_key)
#   }
#   provisioner "file" {
#     source      = "files/puma.service"
#     destination = "/tmp/puma.service"
#   }
#   provisioner "remote-exec" {
#     script = "files/deploy.sh"
#   }
#}