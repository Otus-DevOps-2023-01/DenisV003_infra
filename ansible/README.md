# Ansible-2 
  1. Создаем плейбук для управления конфигурации и деплоя нашего приложения - reddit_app.yml  
    Добавляем сценарии для управления конфигурации хостов.  
    Сценарий для MongoDB из шаблона, делаем пробные прогоны.  
    Определяем переменные, добавляем Handlers, применяем плейбук.  
  2. Настроим инстанс приложения  
     Копируем Unit файл для сервиса puma.  
     Добавляем шаблон для приложения.      
     Задаем переменные
     mongo_bind_ip: 0.0.0.0
     db_host: 10.128.0.9
    И делаем пробный прогон.
  3. Делаем деплой приложения.  
    Добавляем еще несколько тасков в сценарий плейбука.  
    Используем модули git и bundle для клонирования последней
    версии кода нашего приложения и установки зависимых Ruby Gems через
    bundle  
  4. Один плейбук несколько сценариев.  
     Разобъем один сценарий на несколько сценариев, сценарий для MongoDB и сценарий для App  
     Пересоздадим инфраструктуру окружения stage и проверим работу сценариев.  
     Создаем сценарий для деплоя reddit_app2.yml
  5. Несколько плейбуков.  
     Создаем три плейбука app.yml (сценарий настройки хоста), db.yml (сценарий настройки БД), deploy.yml(сценарий деплоя).
     Создадим плейбук site.yml в котором опишем управление конфигурацией всей нашей инфраструктуры.
     Проверяем.
  6. Провижинг в Packer.
     Изменяем provision в Packer и заменим bash-скрипты на Ansible плейбуки. 
     Создаем два плейбука: 
      packer_app.yml 
      ---
      - name: Install Ruby && Bundler
      hosts: all
      become: true
      gather_facts: true
      tasks:
      - name: Update and upgrade apt packages
      apt:
      update_cache: yes
      - name: Install ruby and rubygems and required packages
      apt: "name={{ item }} state=present"
      with_items:
        - ruby-full
        - ruby-bundler
        - build-essential

      packer_db.yml  
   ---
   - name: Install MongoDB 3.2
   hosts: all
   become: true
   tasks:
    Добавим ключ репозитория для последующей работы с ним
    - name: Add APT key
    apt_key:
      keyserver: hkp://keyserver.ubuntu.com:80 
      id: D68FA50FEA312927
    - name: Add APT repository
    apt_repository:
      filename: '/etc/apt/sources.list.d/mongodb-org-3.2.list'
      repo: deb [ arch=amd64,arm64 ] http://mirror.yandex.ru/mirrors/repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse
      state: present
    - name: Update and upgrade apt packages
    apt:
      update_cache: yes
    - name: Install mongodb package
    apt:
      name: mongodb-org
      state: present
      update_cache: yes

    - name: Configure service supervisor
     systemd:
      name: mongod
      enabled: yes
   Проверяем блид образов с использованием новых провижионеров.
   На их основе запускаем stage окружение и проверяем запуск плейбука site.yml конфигурирование и деплой приложения.
   






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