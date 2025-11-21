# Сайт доставки еды Star Burger

Учебный проект сети ресторанов Star Burger. Публичный сайт для оформления заказов, менеджерская панель для распределения заказов между ресторанами и админка для управления меню.

## Запуск локально через Docker Compose

Репозиторий содержит `docker-compose.yml`, который поднимает три контейнера: `backend` (Django), `frontend` (Parcel watch) и `db` (PostgreSQL). Медиа-каталог монтируется с хоста, поэтому изображения не теряются между перезапусками.

### Требования
- Установленный Docker (Docker Desktop или Docker Engine).
- Свободные порты `8000` (backend), `1234` (Parcel dev-сервер) и `5432` (PostgreSQL).

### Шаги
1. Подготовьте переменные окружения в `star_burger/.env`. Минимальный пример:
   ```
   SECRET_KEY=dev-secret-key
   DEBUG=True
   ALLOWED_HOSTS=127.0.0.1,localhost,0.0.0.0
   DATABASE_URL=postgres://star_burger_user:Malina96@db:5432/star_burger_prod
   YANDEX_GEOCODER_API_KEY=your_yandex_api_key
   ```
2. Соберите и запустите стек:
   ```bash
   docker compose up --build
   ```
   - Бэкенд: `http://127.0.0.1:8000/`
   - Менеджерская панель: `http://127.0.0.1:8000/manager/`
   - Админка: `http://127.0.0.1:8000/admin/`
   - Parcel dev-сервер: `http://127.0.0.1:1234/`
3. Для остановки:
   ```bash
   docker compose down
   ```
   Добавьте `-v`, если нужно сбросить тома (`postgres_data`, `node_modules`, `static_volume`) и пересоздать БД с нуля.

### Данные и каталоги
- База данных `db` инициализируется из `db_dump.sql` при первом запуске, затем хранится в томе `postgres_data`.
- Каталог `media/` смонтирован в контейнер, поэтому файлы медиа сохраняются на диске хоста между перезапусками.
- Собранные бандлы лежат в `bundles/` и раздаются Django.

### Полезные команды
- Создать суперпользователя:
  ```bash
  docker compose exec backend python manage.py createsuperuser
  ```
- Просмотреть логи сервиса:
  ```bash
  docker compose logs -f backend
  docker compose logs -f frontend
  ```

## Цели проекта

Код написан в учебных целях — это урок в курсе по Python и веб-разработке на сайте [Devman](https://dvmn.org). За основу взят проект [FoodCart](https://github.com/Saibharath79/FoodCart).
