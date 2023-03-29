# Ansible-1
  1. Выполните ansible  app  -m  command  -a  'rm  -rf  ~/reddit'
и проверьте еще раз выполнение плейбука. Что изменилось и почему?

Ответ - Команда удалит директорию и вложенные файлы репозитория приложения. После запуска ansible-playbook clone.yaml репозиторий будет заново клонирован что видим в статусе выполнения плейбука.
2. Создан файл для inventory.json.  
   {
    "all": {
        "children": {
            "app": {
                "hosts": {
                    "appserver": {
                        "ansible_host": "158.160.51.184"
                    }
                }
            },
            "db": {
                "hosts": {
                    "dbserver": {
                        "ansible_host": "158.160.54.223"
                    }
                }
            }
        }
    }
}
3. Для работы динамического инвентори нужно вернуть список хостов и блок _meta, в котором указаны переменные хостов. Создадим файл источник для скрипта динамического инвентори inventory-source.json:
  {
    "app": {
        "hosts": ["appserver"]
    },
    "db": {
        "hosts": ["dbserver"]
    },
    "_meta": {
        "hostvars": {
            "appserver": {
                "ansible_host": "158.160.51.184"
            },
            "dbserver": {
                "ansible_host": "158.160.54.223"
            }
        }
    }
}  
Далее создаем скрипт , который будет передавать ansible сформированный файл. Содержимое скрипта inventory-script.sh:  
    #!/bin/sh

    cat inventory-source.json 
Проверяем работу "динамического" инвентори:  
ansible -i ./inventory-script.sh all -m ping
dbserver | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
appserver | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
В файле ancible.cfg меняем путь inventory = ./inventory-script.sh и проверяем работу.
ansible all -m ping                             
dbserver | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
appserver | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}