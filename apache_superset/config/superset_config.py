# Apache Superset Configuration
# https://superset.apache.org/docs/installation/configuring-superset

import os
from datetime import timedelta
from celery.schedules import crontab

# --------------------------------------------------
# Database & Secret Key
# --------------------------------------------------
SQLALCHEMY_DATABASE_URI = os.environ.get("SQLALCHEMY_DATABASE_URI")
SECRET_KEY = os.environ.get("SUPERSET_SECRET_KEY")

# --------------------------------------------------
# Feature Flags
# --------------------------------------------------
FEATURE_FLAGS = {
    "ENABLE_TEMPLATE_PROCESSING": True,
    "DASHBOARD_NATIVE_FILTERS": True,
    "DASHBOARD_CROSS_FILTERS": True,
    "DASHBOARD_NATIVE_FILTERS_SET": True,
    "ALERT_REPORTS": True,
    "EMBEDDED_SUPERSET": True,
}

# --------------------------------------------------
# Cache Configuration
# --------------------------------------------------
CACHE_CONFIG = {
    "CACHE_TYPE": "RedisCache",
    "CACHE_DEFAULT_TIMEOUT": 300,
    "CACHE_KEY_PREFIX": "superset_",
    "CACHE_REDIS_HOST": os.environ.get("REDIS_HOST", "superset_redis"),
    "CACHE_REDIS_PORT": int(os.environ.get("REDIS_PORT", 6379)),
    "CACHE_REDIS_DB": 0,
}

DATA_CACHE_CONFIG = CACHE_CONFIG

FILTER_STATE_CACHE_CONFIG = {
    "CACHE_TYPE": "RedisCache",
    "CACHE_DEFAULT_TIMEOUT": 86400,
    "CACHE_KEY_PREFIX": "superset_filter_",
    "CACHE_REDIS_HOST": os.environ.get("REDIS_HOST", "superset_redis"),
    "CACHE_REDIS_PORT": int(os.environ.get("REDIS_PORT", 6379)),
    "CACHE_REDIS_DB": 0,
}

EXPLORE_FORM_DATA_CACHE_CONFIG = {
    "CACHE_TYPE": "RedisCache",
    "CACHE_DEFAULT_TIMEOUT": 86400,
    "CACHE_KEY_PREFIX": "superset_explore_",
    "CACHE_REDIS_HOST": os.environ.get("REDIS_HOST", "superset_redis"),
    "CACHE_REDIS_PORT": int(os.environ.get("REDIS_PORT", 6379)),
    "CACHE_REDIS_DB": 0,
}

# --------------------------------------------------
# Celery Configuration
# --------------------------------------------------
class CeleryConfig:
    broker_url = os.environ.get("CELERY_BROKER_URL", "redis://superset_redis:6379/1")
    imports = ("superset.sql_lab", "superset.tasks.scheduler")
    result_backend = os.environ.get("CELERY_RESULT_BACKEND", "redis://superset_redis:6379/2")
    worker_prefetch_multiplier = 1
    task_acks_late = True
    beat_schedule = {
        "reports.scheduler": {
            "task": "reports.scheduler",
            "schedule": crontab(minute="*", hour="*"),
        },
        "reports.prune_log": {
            "task": "reports.prune_log",
            "schedule": crontab(minute=0, hour=0),
        },
    }

CELERY_CONFIG = CeleryConfig

# --------------------------------------------------
# SQL Lab Configuration
# --------------------------------------------------
SQLLAB_CTAS_NO_LIMIT = True
SQLLAB_ASYNC_TIME_LIMIT_SEC = 60 * 60 * 6
SQLLAB_TIMEOUT = 300

# --------------------------------------------------
# WebServer Configuration
# --------------------------------------------------
WEBSERVER_THREADS = 8
SUPERSET_WEBSERVER_PORT = 8088
SUPERSET_WEBSERVER_TIMEOUT = 60

# --------------------------------------------------
# Security Configuration
# --------------------------------------------------
# Row level security
ENABLE_ROW_LEVEL_SECURITY = True

# CSRF Configuration
WTF_CSRF_ENABLED = True
WTF_CSRF_EXEMPT_LIST = []
WTF_CSRF_TIME_LIMIT = 60 * 60 * 24 * 365

# Session Configuration
SESSION_COOKIE_SAMESITE = "Lax"
SESSION_COOKIE_SECURE = False
SESSION_COOKIE_HTTPONLY = True

# --------------------------------------------------
# Logging Configuration
# --------------------------------------------------
ENABLE_TIME_ROTATE = True
TIME_ROTATE_LOG_LEVEL = "DEBUG"
FILENAME = os.path.join("/app/superset_home/logs", "superset.log")
ROLLOVER = "midnight"
INTERVAL = 1
BACKUP_COUNT = 30

# --------------------------------------------------
# Alert/Report Configuration
# --------------------------------------------------
ALERT_REPORTS_NOTIFICATION_DRY_RUN = True
WEBDRIVER_BASEURL = "http://superset:8088/"

# --------------------------------------------------
# Misc
# --------------------------------------------------
# Default language
BABEL_DEFAULT_LOCALE = "ja"

# Available languages
LANGUAGES = {
    "en": {"flag": "us", "name": "English"},
    "ja": {"flag": "jp", "name": "Japanese"},
}

# Timezone
DEFAULT_TIMEZONE = "Asia/Tokyo"
