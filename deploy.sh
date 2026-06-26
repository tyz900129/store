#!/bin/bash
# ============================================
# PawPatrol Store · 部署脚本
# 从 GitHub 拉取最新代码并触发 Tomcat 热重载
# ============================================

set -e

# 配置
STORE_DIR="/vol1/@appdata/1Panel/1panel/apps/tomcat/tomcat/data/webapps/store"
GIT_CONFIG="/vol1/@appdata/1Panel/1panel/apps/tomcat/tomcat/data/webapps/.gitconfig"
BRANCH="${1:-main}"
LOG_FILE="/vol1/@appdata/1Panel/1panel/apps/tomcat/tomcat/logs/deploy.log"

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
  echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

warn() {
  echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARN:${NC} $1" | tee -a "$LOG_FILE"
}

err() {
  echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1" | tee -a "$LOG_FILE"
  exit 1
}

# 检查目录
[ -d "$STORE_DIR" ] || err "Store 目录不存在: $STORE_DIR"

cd "$STORE_DIR" || err "无法进入 $STORE_DIR"
export GIT_CONFIG_GLOBAL="$GIT_CONFIG"

# 拉取最新代码
log "=========================================="
log "开始部署 PawPatrol Store"
log "=========================================="
log "拉取远端 $BRANCH 分支..."

# 获取当前 commit
LOCAL_COMMIT=$(git rev-parse HEAD 2>/dev/null || echo "none")
log "本地 commit: $LOCAL_COMMIT"

# 拉取
git fetch origin "$BRANCH" 2>&1 | tee -a "$LOG_FILE"
git pull --rebase --autostash origin "$BRANCH" 2>&1 | tee -a "$LOG_FILE" || err "拉取失败"

REMOTE_COMMIT=$(git rev-parse HEAD)
log "更新后 commit: $REMOTE_COMMIT"

if [ "$LOCAL_COMMIT" == "$REMOTE_COMMIT" ]; then
  log "无新提交，跳过部署"
  exit 0
fi

# 显示本次变更
log "本次变更："
git log --oneline "$LOCAL_COMMIT..$REMOTE_COMMIT" 2>&1 | tee -a "$LOG_FILE"

# Tomcat 自动重载（默认配置 reloadable=true）
log "Tomcat 将在数秒内自动重载..."
log "部署完成 ✓"
log "访问: https://www.apperload.com/store/"
exit 0
