# DenisV003_infra
DenisV003 Infra repository
bastion_IP = 158.160.34.18
someinternalhost_IP = 10.128.0.35
Способ подключения в одну команду к хосту someinternalhost c помощью ключа -J 
ssh -i ~/.ssh/denisv003 -J denisv003@158.160.47.2 denisv003@10.128.0.35
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

