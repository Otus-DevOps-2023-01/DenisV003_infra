terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}
provider "yandex" {
  token     = ""
  cloud_id  = "b1g07pq5lr9osan6ff9e"
  folder_id = "b1ggnsla1tt7rgor1vsq"
  zone      = "ru-central1-a"
}
resource "yandex_compute_instance" "app" {
  name = "reddit-app"
  resources {
    cores  = 2
    memory = 2
    }
  boot_disk {
     initialize_params {
      # Указать id образа созданного в предыдущем домашем задании
      image_id = "fd8vfbci6kikkq615kn3"
        }
      }
  network_interface {
    # Указан id подсети default-ru-central1-a
    subnet_id = "e9baugga0kt6rc1sbhr5"
    nat       = true
      }
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
      }
  connection {
    type = "ssh"
    host = yandex_compute_instance.app.network_interface.0.nat_ip_address
    user = "ubuntu"
    agent = true
    # путь до приватного ключа
    private_key = file("~/.ssh/id_ed25519")
        }
  provisioner "file" {
    source = "files/puma.service"
    destination = "/tmp/puma.service"
    }

    provisioner "remote-exec" {
    script = "files/deploy.sh"
    }

}