# Сайт доставки еды Star Burger

Это сайт сети ресторанов Star Burger. Здесь можно заказать превосходные бургеры с доставкой на дом.

![скриншот сайта](https://dvmn.org/filer/canonical/1594651635/686/)

Сеть Star Burger объединяет несколько ресторанов, действующих под единой франшизой. У всех ресторанов одинаковое меню и одинаковые цены. Просто выберите блюдо и укажите адрес доставки — мы найдём ближайший ресторан.

На сайте три интерфейса:
- Публичный: оформить заказ без регистрации.
- Панель менеджера: подтвердить заказ, выбрать ближайший ресторан.
- Админка: управление меню и данными.

## Локальный запуск (Docker Compose)

`docker-compose.yml` поднимает три контейнера: backend (Django), frontend (Parcel) и db (PostgreSQL). Медиа монтируются с хоста, БД в именованном томе.

### Требования
- Docker (Desktop/Engine).
- Свободные порты: `8000` (backend), `1234` (Parcel), `5433` (Postgres на хосте).

### Шаги
1. Клонируйте репозиторий:
   ```bash
   git clone https://github.com/Evst404/Starburger-docker.git
   cd Starburger-docker
   ```
2. Создайте `star_burger/.env`, пример:
   ```
   SECRET_KEY=dev-secret-key
   DEBUG=True
   ALLOWED_HOSTS=127.0.0.1,localhost,0.0.0.0
   DATABASE_URL=postgres://star_burger_user:Malina96@db:5432/star_burger_prod
   YANDEX_GEOCODER_API_KEY=your_yandex_api_key
   ```
3. Запустите стек:
   ```bash
   docker compose up --build
   ```
   - Backend: `http://127.0.0.1:8000/`
   - Менеджер: `http://127.0.0.1:8000/manager/`
   - Админка: `http://127.0.0.1:8000/admin/`
   - Parcel dev: `http://127.0.0.1:1234/`
4. Остановить:
   ```bash
   docker compose down
   ```
   Добавьте `-v`, если нужно сбросить тома (`postgres_data`, `node_modules`).

### Данные и каталоги
- БД инициализируется из `db_dump.sql` при первом старте, затем живёт в томе `postgres_data`.
- `media/` примонтирован, файлы сохраняются на диске.
- Бандлы собирает Parcel в `bundles/`, Django раздаёт статику из `static/`.

### Полезные команды
```bash
docker compose exec backend python manage.py createsuperuser   # создать суперюзера
docker compose logs -f backend                                 # логи бэкенда
docker compose logs -f frontend                                # логи фронта
```

## Деплой на сервер (Docker Compose)

1. Установите Docker на сервере.
2. Склонируйте репозиторий в `/opt/star-burger-docker`:
   ```bash
   git clone https://github.com/Evst404/Starburger-docker.git /opt/star-burger-docker
   ```
   Положите прод `.env` в `star_burger/.env`, дамп БД в `db_dump.sql`, прод-медиа в `media/`.
3. Поднимите стек:
   ```bash
   cd /opt/star-burger-docker
   docker-compose up -d --build
   docker-compose exec -T backend python manage.py collectstatic --noinput
   docker-compose exec -T frontend sh -c './node_modules/.bin/parcel build bundles-src/index.js --dist-dir bundles --public-url=./'
   ```
   - Backend слушает `127.0.0.1:8000` (проксируется nginx).
   - Postgres на `127.0.0.1:5433`, том `postgres_data`.
4. Настройте nginx: прокси на `http://127.0.0.1:8000/`, alias для `static/`, `bundles/`, `media/` из `/opt/star-burger-docker`.
5. Обновление:
   ```bash
   git pull
   docker-compose up -d --build
   docker-compose exec -T backend python manage.py collectstatic --noinput
   docker-compose exec -T frontend sh -c './node_modules/.bin/parcel build bundles-src/index.js --dist-dir bundles --public-url=./'
   sudo nginx -t && sudo systemctl reload nginx
   ```

## Проверка работоспособности

- Открыть публичный сайт: `https://evst404.ru` (или `http://evst404.ru`). В обычном профиле браузера может кешироваться старый HTTPS — если не открывается, попробуйте инкогнито или очистку HSTS/кэша.
- Админка: `https://evst404.ru/admin/` (создайте суперюзера через `docker compose exec backend python manage.py createsuperuser`).
- Панель менеджера: `https://evst404.ru/manager/`.
- Проверка локально/на сервере напрямую:
  - HTML: `curl -H 'Host: evst404.ru' http://127.0.0.1:8000/`
  - Статика: `curl -I http://127.0.0.1/static/index.css`
  - Статус контейнеров: `docker compose ps`
- Проверка сохранности данных: `docker compose down && docker compose up -d --build` — заказы/медиа должны остаться (БД в томе `postgres_data`, медиа в каталоге `media/`).

## Цели проекта

Код написан в учебных целях — это урок в курсе по Python и веб-разработке на сайте [Devman](https://dvmn.org). За основу взят проект [FoodCart](https://github.com/Saibharath79/FoodCart).
