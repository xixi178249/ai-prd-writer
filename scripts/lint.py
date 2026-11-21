#!/usr/bin/env python3
"""ai-prd-writer 的结构检查。CI 与本地都跑这一份。

检查项（失败即非零退出）：
  1. SKILL.md 有合法 frontmatter，且 name 与目录名一致
  2. description 非空且 ≤1024 字符（多数 harness 会截断）
  3. SKILL.md 正文 ≤120 行（入口要能一眼读完）
  4. SKILL.md 引用的 references/ 文件真实存在
  5. README 与文档里的相对链接能打开
  6. evals/trigger-cases.jsonl 每行合法、字段齐全、正反例都够
  7. examples/ 每份都带"演示样例|虚构"声明
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
errors: list[str] = []
warnings: list[str] = []


def read(p: Path) -> str:
    return p.read_text(encoding="utf-8")


def check_frontmatter() -> dict[str, str]:
    skill = ROOT / "SKILL.md"
    if not skill.is_file():
        errors.append("SKILL.md 不存在")
        return {}
    text = read(skill)
    if not text.startswith("---"):
        errors.append("SKILL.md 未以 frontmatter (---) 开头")
        return {}

    parts = text.split("---", 2)
    if len(parts) < 3:
        errors.append("SKILL.md frontmatter 未闭合")
        return {}
    fm_raw, body = parts[1], parts[2]

    meta: dict[str, str] = {}
    current = None
    for line in fm_raw.splitlines():
        if not line.strip():
            continue
        if not line.startswith((" ", "\t")) and ":" in line:
            key, _, value = line.partition(":")
            current = key.strip()
            meta[current] = value.strip()
        elif current:
            meta[current] = (meta[current] + " " + line.strip()).strip()

    for required in ("name", "description", "license"):
        if not meta.get(required) or meta[required] in (">", "|"):
            errors.append(f"frontmatter 缺少 {required}")

    name = meta.get("name", "")
    if name and name != ROOT.name:
        errors.append(f"frontmatter name={name} 与目录名 {ROOT.name} 不一致（harness 按 name 索引）")

    desc = meta.get("description", "")
    desc_clean = desc.strip("> ").strip()
    if len(desc_clean) < 40:
        errors.append(f"description 太短（{len(desc_clean)} 字符），无法判断触发时机")
    if len(desc_clean) > 1024:
        errors.append(f"description 超过 1024 字符（{len(desc_clean)}）")

    body_lines = len(body.strip().splitlines())
    if body_lines > 120:
        errors.append(f"SKILL.md 正文 {body_lines} 行，超过 120 行上限")

    return meta


def check_reference_links() -> None:
    skill = read(ROOT / "SKILL.md")
    for m in re.finditer(r"`(references/[^`]+\.md)`", skill):
        target = ROOT / m.group(1)
        if not target.is_file():
            errors.append(f"SKILL.md 引用了不存在的文件：{m.group(1)}")


def check_markdown_links() -> None:
    for doc in sorted(ROOT.glob("*.md")):
        text = read(doc)
        for m in re.finditer(r"\[[^\]]*\]\(([^)#]+)(?:#[^)]*)?\)", text):
            link = m.group(1).strip()
            if link.startswith(("http://", "https://", "mailto:")):
                continue
            if not (ROOT / link).exists():
                errors.append(f"{doc.name} 的链接打不开：{link}")


def check_evals() -> None:
    path = ROOT / "evals" / "trigger-cases.jsonl"
    if not path.is_file():
        errors.append("evals/trigger-cases.jsonl 不存在")
        return
    pos = neg = 0
    for i, line in enumerate(read(path).splitlines(), 1):
        if not line.strip():
            continue
        try:
            row = json.loads(line)
        except json.JSONDecodeError as exc:
            errors.append(f"trigger-cases.jsonl 第 {i} 行不是合法 JSON：{exc}")
            continue
        for key in ("id", "text", "should_trigger", "why"):
            if key not in row:
                errors.append(f"trigger-cases.jsonl 第 {i} 行缺少字段 {key}")
        if row.get("should_trigger") is True:
            pos += 1
        elif row.get("should_trigger") is False:
            neg += 1
        else:
            errors.append(f"trigger-cases.jsonl 第 {i} 行 should_trigger 必须是布尔值")
    if pos < 10:
        errors.append(f"该触发用例只有 {pos} 条，至少要 10 条")
    if neg < 6:
        errors.append(f"不该触发用例只有 {neg} 条，至少要 6 条")


def check_examples() -> None:
    files = sorted((ROOT / "examples").glob("*.md"))
    if len(files) < 2:
        errors.append("examples/ 至少要两份完整样例")
    for f in files:
        head = "\n".join(read(f).splitlines()[:5])
        if "虚构" not in head and "演示样例" not in head:
            errors.append(f"{f.name} 前 5 行缺少「演示样例 / 数字虚构」声明")
        body = read(f)
        for section in ("## 1 ", "## 3 ", "## 3a ", "## 3b ", "## 4 ", "## 6 ", "## 9 "):
            if section not in body:
                errors.append(f"{f.name} 缺少章节：{section.strip()}")


def main() -> int:
    check_frontmatter()
    check_reference_links()
    check_markdown_links()
    check_evals()
    check_examples()

    for w in warnings:
        print(f"WARN {w}")
    for e in errors:
        print(f"FAIL {e}")

    if errors:
        print(f"\n{len(errors)} 项未通过")
        return 1

    print("OK 全部检查通过")
    return 0


if __name__ == "__main__":
    sys.exit(main())
