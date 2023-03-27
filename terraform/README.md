  # Terraform 2
  Принципы организации инфраструктурного кода и работа над инфраструктурой в команде на примере Terraform  
   1. Создали ветку terraform-2
   2. Выполнил сборку образа для разных VM с созданием шаблона db.json и app.json
   3. Создал 2 VM
   4. Сделал разбитие конфигурации по файлам согласно ТЗ.
   5. Разбил файлы на модули.
   6. Для использование модулей загружаем их из указанного источника (source) коммандой terraform get
   7. Создал директории stage и prod. Скопировал файлы в каждую из директорий.
   8. Проверил конфигурацию
   9. Выполнил самостоятельные задания
  Задание со * .
  Создал файл backend.tf в каждой из директории stage/prod. Выполнил команды terraform init / terraform apply
  
    terraform {
    backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "terraform-2-storage-bucket"
    region     = "ru-central1"
    key        = "stage.tfstate"
    access_key = ""
    secret_key = ""

    skip_region_validation      = true
    skip_credentials_validation = true
    }
  }
   
  Возможно настроил чтото не так, но автотест прошел успешно. 

# Terraform 1
# Все задания выполнены согласно описанию в ТЗ
# Самостоятельные задания
  ## 1. Определите input переменную для приватного ключа,использующегося в определении подключения для провижинеров (connection)
    Переменная была добавлена в terraform.tfvars и добавлено описание в variables.tf, connection теперь выглядит так
   
    connection {
    type  = "ssh"
    host  = self.network_interface.0.nat_ip_address
    user  = "ubuntu"
    agent = false
    # путь до приватного ключа
    private_key = file(var.private_key) }
  
 ## 2.Определите input переменную для задания зоны в ресурсе "yandex_compute_instance" "app". У нее должно быть значение по умолчанию 
     Переменная была добавлена в terraform.tfvars и добавлено описание в variables.tf, resoutce теперь выглядит так:
   resource "yandex_compute_instance" "app" {
     name  = "reddit-app-${count.index}"
     count = var.count_app
     zone  = var.zone       
   }
 ## 3. Создан файл terraform.tfvars.example
    cloud_id                 = "bbbbbbbbbbbbbbbbbbe"
    folder_id                = "bwwwwwwwwwwbbbbbwwq"
    zone                     = "ru-central1-a"
    image_id                 = "fd8vfbci6kikkq615kn3"
    subnet_id                = "e9baugga0kt6rc1sbhr5"
    service_account_key_file = "./key.json"
    count_app                = "2"
    private_key_path         = "~/.ssh/ubuntu"
    public_key_path          = "~/.ssh/ubuntu.pub" 
 
   ## Задание со **
   Создан файл lb.tf с описанием когда балансировщика, направляющего трафик на reddit-app.  
    resource "yandex_lb_target_group" "loadbalancer" {  
    name = "lb-group"  
    dynamic "target" {  
    for_each = yandex_compute_instance.app.*.network_interface.0.ip_address  
    content {  
      address   = target.value  
      subnet_id = var.subnet_id  
    }  
    }  
    #target {
    # address   = yandex_compute_instance.app.network_interface.0.ip_address
    #subnet_id = var.subnet_id
    #}
    #target {
    #address   = yandex_compute_instance.app2.network_interface.0.ip_address
    # subnet_id = var.subnet_id
    #}# 
    }
    resource "yandex_lb_network_load_balancer" "external-lb-test" {
    name = "external-lb-test"
    type = "external"
    listener {
    name        = "my-listener"
    port        = 8080
    target_port = 9292
    external_address_spec {
      ip_version = "ipv4"
    }
    } 
    attached_target_group {
    target_group_id = yandex_lb_target_group.loadbalancer.id
    healthcheck {
      name = "http"
      http_options {
        port = 9292
      }
    }
    }
    }
    
  ## Добавление инстанса reddit-app2
    Добавил блок resource "yandex_compute_instance" "app2" в файле main.tf с описанием. Минусы такого подхода в создании для каждого инстанса своего ресурса, большого количества времени на написание.
     resource "yandex_compute_instance" "app2" {
      name = "reddit-app2"
      #count = var.count_app
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
     host  = yandex_compute_instance.app2.network_interface.0.nat_ip_address
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
      
Выходные переменные output.rf  
  output "external_ip_address_app" {
  value = yandex_compute_instance.app.*.network_interface.0.nat_ip_address
}
 output "external_ip_address_app2" {
   value = yandex_compute_instance.app2.network_interface.0.nat_ip_address
 } 
 
## Задание со **
  Удалите описание reddit-app2 и попробуйте подход с заданием
  количества инстансов через параметр ресурса count.
  Переменная count должна задаваться в параметрах и по
  умолчанию равна 1
  Убираем блок с описанием инстанса reddit-app в main.tf и output.tf. Добавляем новую переменную count_app
  ### variables.tf
   variable "count_app" {
  description = "count instances"
  default     = 1
  }
  
  ### terraform.tfvars 
    count_app = 2
  Изменяем файл main.tf (укажу только те строки, которые изменены)
   resource "yandex_compute_instance" "app" {
  name  = "reddit-app-${count.index}"
  count = var.count_app } -->
  Добавляем динамическую группу в lb.tf 
  resource "yandex_lb_target_group" "loadbalancer" {
  name = "lb-group"
  dynamic "target" {
    for_each = yandex_compute_instance.app.*.network_interface.0.ip_address
    content {
      address   = target.value
      subnet_id = var.subnet_id
    }
   
  ### output.tf
   output "yandex_lb_network_load_balancer" {
     value = yandex_lb_network_load_balancer.external-lb-test.listener.*.external_address_spec[0].*.address
     } 
  