##################
# These are instructions to deploy DefectDojo test environment using Docker Compose.
# This assumes that you run AWS EC2 Ubuntu 22.04 instance with Docker and Docker Compose installed.
# Ingress/ALB or other proxy is not included in this script.
##################


mkdir -p ~/defectdojo && cd ~/defectdojo

# Generoi salainen avain
SECRET=$(openssl rand -hex 32)

cat > .env <<EOF
#############################################
# DefectDojo Environment Configuration (.env)
#############################################

# --- DATABASE ---
POSTGRES_DB=defectdojo
POSTGRES_USER=dojo
POSTGRES_PASSWORD=<YOUR_DB_PASSWORD_HERE>

# --- REDIS ---
DD_CELERY_BROKER_URL=redis://redis:6379/0
DD_CELERY_RESULT_BACKEND=redis://redis:6379/1

# --- DJANGO / DEFECTDOJO CORE ---
DD_ALLOWED_HOSTS=admin@your-domain.com,localhost,127.0.0.1,20.0.1.138,dojo-alb-381491979.eu-north-1.elb.amazonaws.com
DD_DEBUG=False
DD_SECRET_KEY=<SECRET_HERE>
DD_DATABASE_URL=postgresql://dojo:<SECRET_HERE>@postgres:5432/defectdojo

# --- DJANGO ADMIN ---
DD_ADMIN_USER=admin
DD_ADMIN_PASSWORD=<YOUR_DJANGO_PASSWORD_HERE>
DD_ADMIN_MAIL=admin@your-domain.com

# --- SERVER SETTINGS ---
DD_TIME_ZONE=Europe/Helsinki
DD_CELERY_LOG_LEVEL=INFO
DD_UWSGI_NUM_OF_PROCESSES=2
DD_UWSGI_NUM_OF_THREADS=2

# --- HTTPS/PROXY ---
DD_SECURE_PROXY_SSL_HEADER=HTTP_X_FORWARDED_PROTO,https
DD_CSRF_TRUSTED_ORIGINS=https://admin@your-domain.com,https://dojo-alb-381491979.eu-north-1.elb.amazonaws.com

# --- EMAIL (optional) ---
DD_EMAIL_URL=smtp://localhost:25/?_default_from_email=dojo@admin@your-domain.com

# --- LOGGING ---
LOG_LEVEL=INFO

#############################################
# END OF FILE
#############################################
EOF


# Luodaan custom py asetusfile uwsgi imagelle
cat > custom_settings.py <<'EOF'
import os

ALLOWED_HOSTS = os.getenv('DJANGO_ALLOWED_HOSTS', 'localhost').split(',')
EOF


# luo docker-compose.yml
cat > docker-compose.yml <<'EOF'
services:
  postgres:
    image: postgres:17.0-alpine
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL","pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 10

  redis:
    image: redis:7.2.5-alpine
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5

  initializer:
    image: defectdojo/defectdojo-django:2.41.0-alpine
    depends_on:
      postgres: { condition: service_healthy }
      redis:    { condition: service_healthy }
    env_file: .env
    environment:
      DD_INITIALIZE: "true"
    entrypoint: ["/entrypoint-initializer.sh"]
    volumes:
      - media:/app/media
    restart: "no"

  uwsgi:
    image: defectdojo/defectdojo-django:2.41.0-alpine
    restart: unless-stopped
    depends_on:
      initializer: { condition: service_completed_successfully }
      postgres:    { condition: service_healthy }
      redis:       { condition: service_healthy }
    env_file: .env
    volumes:
      - media:/app/media
    healthcheck:
      test: ["CMD-SHELL","wget --no-verbose --tries=1 -O /dev/null http://127.0.0.1:8081/login || exit 1"]
      interval: 15s
      timeout: 10s
      retries: 10
      start_period: 90s

  celeryworker:
    image: defectdojo/defectdojo-django:2.41.0-alpine
    restart: unless-stopped
    depends_on:
      initializer: { condition: service_completed_successfully }
      postgres:    { condition: service_healthy }
      redis:       { condition: service_healthy }
    env_file: .env
    environment:
      DD_CELERY_WORKER_POOL_TYPE: solo
    entrypoint: ["/entrypoint-celery-worker.sh"]
    volumes:
      - media:/app/media

  celerybeat:
    image: defectdojo/defectdojo-django:2.41.0-alpine
    restart: unless-stopped
    depends_on:
      initializer: { condition: service_completed_successfully }
      postgres:    { condition: service_healthy }
      redis:       { condition: service_healthy }
    env_file: .env
    entrypoint: ["/entrypoint-celery-beat.sh"]
    volumes:
      - media:/app/media

  nginx:
    image: defectdojo/defectdojo-nginx:2.41.0-alpine
    restart: unless-stopped
    depends_on:
      uwsgi: { condition: service_healthy }
    ports:
      - "8080:8080"
    volumes:
      - media:/usr/share/nginx/html/media

volumes:
  pgdata:
  media:
EOF

# Käynnistä DefectDojo
cd ~/defectdojo
sudo docker compose down # -v jos haluat poistaa volumet ja datan
sudo docker compose up -d
sudo docker compose logs -f initializer   # odota että valmistuu OK
sudo docker compose logs -f uwsgi
sudo docker compose logs -f nginx

## muuta
sudo docker compose restart nginx
sudo docker compose up -d --force-recreate uwsgi nginx


