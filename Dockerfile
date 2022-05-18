FROM ghcr.io/oddbird/pyjs:py3.10-node16

ARG BUILD_ENV=development
WORKDIR /app

# Env setup:
ENV PYTHONPATH /app
ENV DJANGO_SETTINGS_MODULE config.settings.production

# Python requirements:
COPY ./requirements requirements
RUN pip install --no-cache-dir --upgrade pip pip-tools \
    && pip install --no-cache-dir -r requirements/prod.txt
RUN if [ "${BUILD_ENV}" = "development" ] ; then \
    pip install --no-cache-dir -r requirements/dev.txt; \
    fi

# JS client setup:
COPY ./package.json package.json
COPY ./yarn.lock yarn.lock
RUN yarn install --check-files

COPY . /app

# Avoid building prod assets in development
RUN if [ "${BUILD_ENV}" = "production" ] ; then yarn prod ; else mkdir -p dist ; fi

# RUN DATABASE_URL="" \
#   DB_ENCRYPTION_KEY="" \
#   DJANGO_HASHID_SALT="" \
#   DJANGO_SECRET_KEY="sample secret key" \
#   python manage.py collectstatic --noinput
RUN pip install --no-cache-dir psycopg2-binary
RUN yarn add is-odd

CMD /app/start-server.sh
