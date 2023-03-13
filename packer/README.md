ДЗ Сборка образов VM при помощи Packer

1.Создал новую ветку packer-base

2.Перенес наработки в config-scripts 

3.Создал сервисный аккаунт

4.Даем права editor сервисному аккаунту.

5.Создаем service account key file

6.Создаем файл шаблона ubuntu16.json ( При создании шаблона необходимо добавить 2 параметра, которые не были указаны в файле с ДЗ "zone" и "subnet_id").

7.Выполняем проверку и запускаем образ.( При выполнении билда появлялась ошибка, добавил параметр pause_before : 60s)

8.Создаем ВМ с помощью подготовленного нами образа, проверка образа и установка приложения.Проверяем его работу через браузер.

9.Параметризируем шаблон ubuntu16.json. Добавялем блок variables с указанными переменными.  

Создаем файл variables.json с указанием значений. Добавляем файл в .gitignore. При билде указываем параметр -var-file :  packer build -var-file=variables.json ./ubuntu16.json

{
    "variables": {
        "fid": "",
        "source_image_fam": "",
        "service_account_key": "",
        "image_fam": "",
        "disk_size": ""
    },
    "builders": [
        {
            "type": "yandex",
            "service_account_key_file": "{{user `service_account_key`}}",
            "folder_id": "{{user `fid`}}",
            "zone": "ru-central1-a",
            "subnet_id": "e9baugga0kt6rc1sbhr5",
            "source_image_family": "{{user `source_image_fam`}}",
            "image_name": "reddit-base-{{timestamp}}",
            "image_family": "{{user `image_fam`}}",
            "use_ipv4_nat": "true",
            "ssh_username": "ubuntu",
            "disk_size_gb": "{{user `disk_size`}}",
            "platform_id": "standard-v1"
        }
    ],
    "provisioners": [
        {
            "type": "shell",
            "script": "scripts/install_ruby.sh",
            "execute_command": "sudo {{.Path}}",
            "pause_before" : "60s"
        },
        {
            "type": "shell",
            "script": "scripts/install_mongodb.sh",
            "execute_command": "sudo {{.Path}}",
            "pause_before" : "60s"
        }
    ]
}
