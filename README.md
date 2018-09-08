## README

### Deploy API

```
set .env

docker-compose build

docker-compose up -d

docker-compose run web rake db:migrate
```

### Deploy Worker

```
set .env

docker-compose -f docker-compose-worker.yml build

docker-compose -f docker-compose-worker.yml up -d
```

### Start

```
docker-compose run web rake jobs:init
```

### Test

```
curl -X POST http://localhost/pages \
-H 'Content-Type:application/json' \
-d '{"page":{"url": "https://www.yahoo.co.jp", "sec": 60, "push_channel": "xxx", "stop_fetch": false}}'
```
