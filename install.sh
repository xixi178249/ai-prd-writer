#!/usr/bin/env bash
# ai-prd-writer installer — idempotent, safe to re-run.
set -euo pipefail

SKILL_NAME="ai-prd-writer"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PAYLOAD=(SKILL.md references examples evals)
TARGET=""

usage() {
  cat <<'EOF'
用法: ./install.sh [--target <skills 目录>]

不带参数时自动探测并安装到所有已存在的技能目录：
  ~/.dsh/skills      DeepSeek Harness 及兼容 harness
  ~/.claude/skills   Claude Code

  --target DIR   只装到指定目录（目录不存在会自动创建）
  -h, --help     显示本帮助
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="${2:-}"; shift 2 ;;
    --target=*) TARGET="${1#*=}"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "未知参数: $1" >&2; usage >&2; exit 1 ;;
  esac
done

# 源目录自检：缺文件就直接失败，不要装一个残废技能
for f in "${PAYLOAD[@]}"; do
  [[ -e "$SRC_DIR/$f" ]] || { echo "✗ 源目录缺少 $f，请确认在仓库根目录执行" >&2; exit 1; }
done
grep -q '^name:' "$SRC_DIR/SKILL.md" || { echo "✗ SKILL.md 缺少 name 字段" >&2; exit 1; }
grep -q '^description:' "$SRC_DIR/SKILL.md" || { echo "✗ SKILL.md 缺少 description 字段" >&2; exit 1; }

install_into() {
  local dest_root="$1"
  local dest="$dest_root/$SKILL_NAME"
  mkdir -p "$dest"
  for f in "${PAYLOAD[@]}"; do
    cp -R "$SRC_DIR/$f" "$dest/"
  done
  echo "✓ 已安装 → $dest"
  INSTALLED+=("$dest")
}

INSTALLED=()

if [[ -n "$TARGET" ]]; then
  install_into "$TARGET"
else
  found=0
  for root in "$HOME/.dsh/skills" "$HOME/.claude/skills"; do
    if [[ -d "$root" ]]; then
      install_into "$root"
      found=1
    fi
  done
  if [[ $found -eq 0 ]]; then
    echo "· 未找到现有技能目录，默认创建 ~/.dsh/skills"
    install_into "$HOME/.dsh/skills"
  fi
fi

cat <<EOF

装好了，共 ${#INSTALLED[@]} 处。
下一步：重启你的编码助手会话（技能目录在会话启动时扫描，改完必须重启才生效）。
验证：跟它说「写 PRD：给客服做个工单分类助手」，看它是否开始一次只问一个问题。

想卸载：删掉上面列出的目录即可，无其他残留。
EOF
