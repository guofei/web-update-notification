## README

### Deploy API

```
set .env

docker-compose build

docker-compose up -d
```

### Deploy Worker

```
set .env

docker-compose -f docker-compose-worker.yml build

docker-compose -f docker-compose-worker.yml up -d
```
