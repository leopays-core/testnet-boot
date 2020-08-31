

### Создать и прописать ключи в файле `.environment`
### прописать ключи из генезис блока в файл `config/leopays_node/config.ini`
### добавить публичные ноды в файле `config/leopays_node/config.ini`
p2p-peer-address = 


### Порядок запуска в docker-compose
**В начале загружаем ноду**
```bash
./docker-compose up
```

**Потом запускаем скрипт загрузки (инициализации) системы**
```bash
./docker_bios_boot.sh
```

**Потом прилинковываем аккаунт leopays к leopaysrobot**
```bash
./docker_link_account_to_leopaysrobot.sh leopays
```

### Порядок запуска в cli
**В начале загружаем ноду** в двух окнах
Первое окно
```bash
./start-cli-node.sh
```
Второе окно
```bash
./start-cli-wallet.sh
```

**Потом запускаем скрипт загрузки (инициализации) системы**
третье окно
```bash
./cli_bios_boot.sh
```

**Потом прилинковываем аккаунт leopays к leopaysrobot**
третье окно
```bash
./cli_link_account_to_leopaysrobot.sh leopays
```


### 1) Создать новый ключ для генезис блока 
Это можно сделать онлайн на сайте [eosauthority.com](https://eosauthority.com/generate_eos_private_key).
  - Заменить префикс `EOS` на `LPC`.
это будет owner и active от аккаунтов lpc и leopays
  - PubKey - в генезис блок в шаге 2
  - PrivKey - в config.ini в шаге 4


### 2) заменить в генезис блоке (genesis.json) два поля
```
initial_timestamp - текущая дата - время по UTC
initial_key - PubKey из шага 1
```


### 3) Поднять на публичном сервере не производящую публичную ноду с этим genesis.json
Она просто ждет новые блоки и отдает данные эксплореру и другим нодам
Лучше 2-3 ноды на разных серверах чтобы их можно было перезагружать по очереди и сеть не падала
нужно запомнить host и port этой ноды


### 4) Поднять локальную ноду для инициализации блокчейна и с производителем из генезис блока
скормить этот genesis.json и в config.init указать ключ из шага 1
указать адреса серверов из шага 3
В config.ini указать
```
signature-provider = PubKey=KEY:PrivKey
producer-name = leopays
p2p-peer-address = host:port
```
Запустить ноду через docker или через исполняемый файл


### 5) Загрузка системы
Здесь создаютя системные акаунты и загружаются контракты
запустить скрипт
```
```

### 6) Создание аккаунта робота
#### 6.1) Создать ключи для робота
- Создать 3 ключа для робота. Это можно сделать онлайн на сайте [eosauthority.com](https://eosauthority.com/generate_eos_private_key).
  - Заменить префикс `EOS` на `LPC`.
- Распределить 3 ключа на permission: `owner`, `active` и `leopaysrobot`. 
- Сохранить ключи.
- Отредактировать скрипт
- Запустить скрипт

### 7) Линковка акаунта leopays к роботу

### 8) Запуск робота







Загрузили блокчейн.
Прилинковали leopays к leopaysrobot.
отправили leopaysrobot монеты для создания аккаунтов.
Можно создавать аккаунты.

```bash
sudo systemctl enable leopays-node
sudo systemctl daemon-reload
sudo systemctl start leopays-node
sudo systemctl stop leopays-node
sudo systemctl restart leopays-node
sudo systemctl status leopays-node

sudo systemctl start mongod
sudo systemctl stop mongod
sudo systemctl restart mongod
sudo systemctl status mongod

pm2 stop leopaysrobot
pm2 restart leopaysrobot
```