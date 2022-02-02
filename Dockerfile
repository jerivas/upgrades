FROM oddbirds/pyjs:py3.10-node16

ARG BUILD_ENV=development
ARG PROD_ASSETS
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
RUN if [ "${BUILD_ENV}" = "production" ] || [ -n "${PROD_ASSETS}" ] ; then yarn prod ; else mkdir -p dist ; fi

RUN python manage.py collectstatic --noinput

CMD /app/start-server.sh
