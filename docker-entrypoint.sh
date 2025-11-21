#!/bin/sh
set -e

# Run database migrations by default to keep dev environments in sync.
python manage.py migrate --noinput

# Optional: load fixture data once by setting LOAD_FIXTURE_ON_START=1
if [ "$LOAD_FIXTURE_ON_START" = "1" ] && [ -f data.json ]; then
  python manage.py loaddata data.json || true
fi

exec "$@"
