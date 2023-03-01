# DenisV003_infra
DenisV003 Infra repository

----HW cloudtest_app

testapp_IP = 84.201.131.10
testapp_port = 9292

Доп.задание: команда для запуска инстанса CLI.( не уверен в правильности написания файла startup.yaml)
yc compute instance create \
  --name reddit-app \
  --hostname reddit-app \
  --memory=4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  ----metadata-from-file user-data=startup.yaml \
  --metadata serial-port-enable=1 \

-----HW Cloud-Bastion

bastion_IP = 158.160.34.18
someinternalhost_IP = 10.128.0.35

Способ подключения в одну команду к хосту someinternalhost c помощью ключа -J
ssh -i ~/.ssh/denisv003 -J denisv003@158.160.34.18 denisv003@10.128.0.35

Дополнительное задание: подключение к хосту ssh someinternalhost
Подключение через alias, добавленный в файл .ssh/config

Host bastionhost
  Hostname 158.160.34.18
  User denisv003
  IdentityFile /home/voloshchik/.ssh/denisv003
  ForwardAgent yes

Host someinternalhost
  HostName 10.128.0.35
  User denisv003
  IdentityFile /home/voloshchik/.ssh/denisv003
  ForwardAgent yes
  ProxyJump bastionhost
