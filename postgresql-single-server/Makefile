# ========================================
# PostgreSQL 18 Docker Makefile
# ========================================

.DEFAULT_GOAL := help

# ----------------------------------------
# Variables
# ----------------------------------------

COMPOSE_FILE := docker-compose.yml
ENV_FILE := .env
ENV_EXAMPLE := .env.example
SERVICE_NAME := local_postgres
BACKUP_DIR := ./backups

# Colors for output
GREEN  := \033[0;32m
YELLOW := \033[0;33m
RED    := \033[0;31m
BLUE   := \033[0;34m
NC     := \033[0m

# ----------------------------------------
# Help
# ----------------------------------------

.PHONY: help
help: ## ヘルプを表示
	@echo ""
	@echo "${BLUE}PostgreSQL 18 Docker Management${NC}"
	@echo ""
	@echo "${GREEN}Available commands:${NC}"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  ${GREEN}%-15s${NC} %s\n", $$1, $$2}'
	@echo ""

# ----------------------------------------
# Environment Setup
# ----------------------------------------

.PHONY: setup
setup: ## 初回セットアップ（.env作成 → ディレクトリ作成 → 起動）
	@echo "${BLUE}🚀 Starting initial setup...${NC}"
	@$(MAKE) check-env
	@$(MAKE) create-dirs
	@$(MAKE) up
	@$(MAKE) wait-db
	@echo "${GREEN}✅ Setup complete!${NC}"

.PHONY: check-env
check-env: ## .envファイルの存在確認（なければ.env.exampleからコピー）
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "${YELLOW}⚠️  .env not found. Copying from .env.example...${NC}"; \
		cp $(ENV_EXAMPLE) $(ENV_FILE); \
		echo "${GREEN}✅ .env created. Please edit it before running 'make up'${NC}"; \
		exit 1; \
	else \
		echo "${GREEN}✅ .env file exists${NC}"; \
	fi

.PHONY: create-dirs
create-dirs: ## 必要なディレクトリを作成
	@echo "${BLUE}📁 Creating directories...${NC}"
	@mkdir -p data/pgdata data/logs $(BACKUP_DIR)
	@echo "${GREEN}✅ Directories created${NC}"

# ----------------------------------------
# Container Management
# ----------------------------------------

.PHONY: up
up: check-env ## コンテナを起動（デタッチモード）
	@echo "${BLUE}🚀 Starting PostgreSQL container...${NC}"
	@docker compose up -d
	@echo "${GREEN}✅ Container started${NC}"

.PHONY: down
down: ## コンテナを停止
	@echo "${BLUE}🛑 Stopping PostgreSQL container...${NC}"
	@docker compose down
	@echo "${GREEN}✅ Container stopped${NC}"

.PHONY: restart
restart: ## コンテナを再起動
	@echo "${BLUE}🔄 Restarting PostgreSQL container...${NC}"
	@docker compose restart
	@echo "${GREEN}✅ Container restarted${NC}"

.PHONY: start
start: ## 停止中のコンテナを開始
	@echo "${BLUE}▶️  Starting container...${NC}"
	@docker compose start
	@echo "${GREEN}✅ Container started${NC}"

.PHONY: stop
stop: ## コンテナを停止（削除はしない）
	@echo "${BLUE}⏸️  Stopping container...${NC}"
	@docker compose stop
	@echo "${GREEN}✅ Container stopped${NC}"

.PHONY: recreate
recreate: ## コンテナを再作成（設定変更時に使用）
	@echo "${BLUE}🔄 Recreating container...${NC}"
	@docker compose up -d --force-recreate
	@echo "${GREEN}✅ Container recreated${NC}"

# ----------------------------------------
# Monitoring & Logs
# ----------------------------------------

.PHONY: ps
ps: ## コンテナの状態を表示
	@docker compose ps

.PHONY: logs
logs: ## ログをリアルタイム表示
	@docker compose logs -f $(SERVICE_NAME)

.PHONY: logs-tail
logs-tail: ## ログの最後100行を表示
	@docker compose logs --tail=100 $(SERVICE_NAME)

.PHONY: health
health: ## ヘルスチェック状態を確認
	@echo "${BLUE}🏥 Checking container health...${NC}"
	@docker compose ps $(SERVICE_NAME)
	@docker inspect --format='{{.State.Health.Status}}' $$(docker compose ps -q $(SERVICE_NAME)) 2>/dev/null || echo "No health status available"

.PHONY: stats
stats: ## コンテナのリソース使用状況を表示
	@docker stats $$(docker compose ps -q $(SERVICE_NAME)) --no-stream

# ----------------------------------------
# Database Operations
# ----------------------------------------

.PHONY: psql
psql: ## PostgreSQLシェルに接続
	@docker compose exec $(SERVICE_NAME) psql -U $$(grep POSTGRES_USER $(ENV_FILE) | cut -d '=' -f2) -d $$(grep POSTGRES_DB_NAME $(ENV_FILE) | cut -d '=' -f2)

.PHONY: shell
shell: ## コンテナ内のシェルに入る
	@docker compose exec $(SERVICE_NAME) bash

.PHONY: wait-db
wait-db: ## データベースの準備完了を待機
	@echo "${BLUE}⏳ Waiting for database to be ready...${NC}"
	@for i in $$(seq 1 60); do \
		if docker compose exec -T $(SERVICE_NAME) pg_isready -U $$(grep POSTGRES_USER $(ENV_FILE) | cut -d "=" -f2) > /dev/null 2>&1; then \
			echo "${GREEN}✅ Database is ready${NC}"; \
			exit 0; \
		fi; \
		sleep 1; \
	done; \
	echo "${RED}❌ Database failed to start within 60 seconds${NC}"; \
	exit 1

# ----------------------------------------
# Database Management
# ----------------------------------------

.PHONY: backup
backup: ## データベース全体をバックアップ
	@mkdir -p $(BACKUP_DIR)
	@echo "${BLUE}💾 Creating backup...${NC}"
	@docker compose exec -T $(SERVICE_NAME) pg_dumpall -U $$(grep POSTGRES_USER $(ENV_FILE) | cut -d '=' -f2) | \
		sed -E 's/^(CREATE|ALTER) ROLE/-- &/' > $(BACKUP_DIR)/backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "${GREEN}✅ Backup created in $(BACKUP_DIR)/${NC}"
	@ls -lh $(BACKUP_DIR) | tail -1

.PHONY: restore
restore: ## バックアップから復元（引数: FILE=backup.sql）
	@if [ -z "$(FILE)" ]; then \
		echo "${RED}❌ Error: Please specify FILE=path/to/backup.sql${NC}"; \
		echo "Example: make restore FILE=$(BACKUP_DIR)/backup_20250101_120000.sql"; \
		exit 1; \
	fi
	@echo "${YELLOW}⚠️  This will restore database from $(FILE)${NC}"
	@echo "${YELLOW}⚠️  Are you sure? [y/N]${NC}" && read ans && [ $${ans:-N} = y ]
	@echo "${BLUE}🔄 Restoring from backup...${NC}"
	@docker compose exec -T $(SERVICE_NAME) psql -U $$(grep POSTGRES_USER $(ENV_FILE) | cut -d '=' -f2) < $(FILE)
	@echo "${GREEN}✅ Restore complete${NC}"

.PHONY: list-backups
list-backups: ## バックアップファイル一覧を表示
	@echo "${BLUE}📋 Available backups:${NC}"
	@ls -lh $(BACKUP_DIR)/*.sql 2>/dev/null || echo "No backups found"

# ----------------------------------------
# Database Info
# ----------------------------------------

.PHONY: db-info
db-info: ## データベース情報を表示
	@echo "${BLUE}📊 Database Information:${NC}"
	@docker compose exec $(SERVICE_NAME) psql -U $$(grep POSTGRES_USER $(ENV_FILE) | cut -d '=' -f2) -c "\
		SELECT version();" | head -3
	@docker compose exec $(SERVICE_NAME) psql -U $$(grep POSTGRES_USER $(ENV_FILE) | cut -d '=' -f2) -c "\l"

.PHONY: db-size
db-size: ## データベースサイズを表示
	@echo "${BLUE}💾 Database Sizes:${NC}"
	@docker compose exec $(SERVICE_NAME) psql -U $$(grep POSTGRES_USER $(ENV_FILE) | cut -d '=' -f2) -c "\
		SELECT \
			datname AS database, \
			pg_size_pretty(pg_database_size(datname)) AS size \
		FROM pg_database \
		WHERE datname NOT IN ('template0', 'template1') \
		ORDER BY pg_database_size(datname) DESC;"

.PHONY: db-connections
db-connections: ## 現在の接続数を表示
	@echo "${BLUE}🔌 Active Connections:${NC}"
	@docker compose exec $(SERVICE_NAME) psql -U $$(grep POSTGRES_USER $(ENV_FILE) | cut -d '=' -f2) -c "\
		SELECT \
			datname, \
			count(*) as connections \
		FROM pg_stat_activity \
		WHERE datname IS NOT NULL \
		GROUP BY datname \
		ORDER BY connections DESC;"

# ----------------------------------------
# Configuration
# ----------------------------------------

.PHONY: config
config: ## PostgreSQL設定を表示
	@echo "${BLUE}⚙️  PostgreSQL Configuration:${NC}"
	@docker compose exec $(SERVICE_NAME) psql -U $$(grep POSTGRES_USER $(ENV_FILE) | cut -d '=' -f2) -c "\
		SELECT name, setting, unit, source \
		FROM pg_settings \
		WHERE source != 'default' \
		ORDER BY name;" | head -50

.PHONY: config-file
config-file: ## 使用中の設定ファイルパスを表示
	@docker compose exec $(SERVICE_NAME) psql -U $$(grep POSTGRES_USER $(ENV_FILE) | cut -d '=' -f2) -c "SHOW config_file;"

# ----------------------------------------
# Cleanup
# ----------------------------------------

.PHONY: clean
clean: ## データを削除（確認あり）
	@echo "${RED}⚠️  WARNING: This will DELETE all PostgreSQL data!${NC}"
	@echo "${YELLOW}Are you sure? [y/N]${NC}" && read ans && [ $${ans:-N} = y ]
	@echo "${BLUE}🧹 Cleaning up...${NC}"
	@$(MAKE) down
	@rm -rf data/pgdata/* data/logs/*
	@echo "${GREEN}✅ Data cleaned${NC}"

.PHONY: reset-db
reset-db: ## データベースをリセット（全データ削除→再作成→初期化スクリプト実行）
	@echo "${RED}⚠️  WARNING: This will RESET the database (all data will be lost)!${NC}"
	@echo "${YELLOW}Are you sure? [y/N]${NC}" && read ans && [ $${ans:-N} = y ]
	@echo "${BLUE}🔄 Resetting database...${NC}"
	@docker compose down -v
	@echo "${BLUE}🚀 Recreating container...${NC}"
	@docker compose up -d
	@$(MAKE) wait-db
	@echo "${GREEN}✅ Database reset complete! Initialization scripts have been executed.${NC}"

.PHONY: destroy
destroy: ## コンテナ・ボリューム・ネットワークを完全削除（確認あり）
	@echo "${RED}⚠️  WARNING: This will DESTROY everything (containers, volumes, networks)!${NC}"
	@echo "${YELLOW}Are you sure? [y/N]${NC}" && read ans && [ $${ans:-N} = y ]
	@echo "${BLUE}💣 Destroying...${NC}"
	@docker compose down -v
	@rm -rf data/pgdata/* data/logs/*
	@echo "${GREEN}✅ Everything destroyed${NC}"

# ----------------------------------------
# Development
# ----------------------------------------

.PHONY: validate
validate: ## docker-compose.ymlの構文チェック
	@echo "${BLUE}🔍 Validating docker-compose.yml...${NC}"
	@docker compose config > /dev/null && echo "${GREEN}✅ Configuration is valid${NC}"

.PHONY: pull
pull: ## 最新のPostgreSQLイメージを取得
	@echo "${BLUE}⬇️  Pulling latest PostgreSQL image...${NC}"
	@docker compose pull
	@echo "${GREEN}✅ Image pulled${NC}"

.PHONY: prune
prune: ## 未使用のDockerリソースを削除
	@echo "${YELLOW}This will remove unused Docker resources${NC}"
	@docker system prune -f
	@echo "${GREEN}✅ Pruned${NC}"
