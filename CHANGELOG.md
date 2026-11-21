# 变更记录

格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)。
**章节编号与标题属于兼容性契约**：改动它们等于让别人的历史 PRD 无法对照，必须进「破坏性变更」。

## [1.0.0] - 2026-11-21

首个可发布版本。

### 新增
- `README.md` / `README.en.md`：30 秒安装、效果示例、四阶段说明、适用范围
- `LICENSE`（MIT）
- `install.sh` / `install.ps1`：幂等安装，自动探测 `~/.dsh/skills` 与 `~/.claude/skills`
- `references/examples.md`：6 组「填好 vs 没填好」对照（指标口径、及格线、失败模式、rubric、成本、排期）
- `examples/01-ai-feature.md`：AI 功能类完整样例（虚构数据）
- `examples/02-non-ai-process.md`：非 AI 流程类完整样例，演示 `【不适用】` 处理
- `evals/trigger-cases.jsonl`：20 条触发用例（12 该触发 / 8 不该触发）
- `scripts/lint.py` + `.github/workflows/lint.yml`：frontmatter、行数、相对链接、用例完整性检查
- `SKILL.md` 增加「何时用 / 何时不用」表格，明确排除润色、架构、竞品、排期四类请求
- `SKILL.md` frontmatter 增加 `license` 字段与英文触发词

### 变更
- P0 INTAKE 明确材料处理动作：抽 fact card 且 ≥3 条才动笔
- 反模式清单增加一条：「用户答'不知道'后仍追问同一件事」

### 未变（兼容性契约）
- 12 节骨架：`1 / 2 / 3 / 3a / 3b / 4 / 4a / 5 / 6 / 7 / 8 / 9`
- 事实账本四标记：U / M / A / P
- 六条铁律

## [0.1.0] - 2026-11-20

内部初版：`SKILL.md` + `references/template.md` / `question-bank.md` / `checklist.md`，共 295 行。
