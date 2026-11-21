# ai-prd-writer

**Turn a vague "should we build this, and what exactly?" discussion into 8–15 multiple-choice questions and a review-ready PRD.**

An agent skill for coding assistants. Say `write a PRD: <one-line scenario>`, and it asks one question at a time, then hands you a 12-section PRD draft you can take straight into a review meeting.

The point: **asking you is the job, not a failure.** It will not invent user numbers, business metrics, model accuracy, dataset sizes, or delivery dates. When it doesn't know, it writes `[TO CONFIRM: what's missing / which section is blocked / who should supply it]`.

> The skill itself is written in Chinese, because its output language and its users are Chinese. This English README covers what it is and how to install it; the templates are maintained in one language only.

---

## Install in 30 seconds

**Windows (PowerShell)**

```powershell
git clone https://github.com/xixi178249/ai-prd-writer.git
cd ai-prd-writer
.\install.ps1
```

> If Windows refuses to run an unsigned script:
> `powershell -ExecutionPolicy Bypass -File .\install.ps1`

**macOS / Linux**

```bash
git clone https://github.com/xixi178249/ai-prd-writer.git
cd ai-prd-writer
./install.sh
```

The script looks for these directories and installs into whichever it finds:

| Directory | Used by |
|---|---|
| `~/.dsh/skills/` | DeepSeek Harness and compatible harnesses |
| `~/.claude/skills/` | Claude Code |

Manual install is one step: copy this folder into either `skills/` directory and restart your session.

---

## What you get

It asks 8–15 questions, one at a time, each with 3–4 options and a trailing "you decide for me" choice. Then it prints a confirmation summary (confirmed / I-decided / to-confirm) and waits for your "confirm" before writing.

The output has a fixed 12-section skeleton — no sections added, removed, or renamed:

```
1 Background & goals            2 User stories & interaction flow
3 Effect definition             3a Prompt spec
3b Eval spec                    4 Capability boundary & non-promises
4a Agent behaviour boundary     5 Data needs & feedback loop
6 Cost budget                   7 Fallbacks & risks
8 Rollout plan & canary         9 Iteration roadmap
+ Appendix: assumptions / to-confirm / conflicts / self-check
```

Two complete samples (numbers are fictional, for format only):

- [`examples/01-ai-feature.md`](examples/01-ai-feature.md) — an AI feature
- [`examples/02-non-ai-process.md`](examples/02-non-ai-process.md) — a non-AI process, showing how `[NOT APPLICABLE]` sections are handled

Every fact carries a provenance tag, which is how it avoids making things up:

| Tag | Meaning | In the document |
|---|---|---|
| U | Your words | written as-is |
| M | Source material | written as-is; if it contradicts your latest statement, yours wins and the conflict goes to the appendix |
| A | The agent decided (you said "you decide") | marked `[ASSUMPTION]`, listed in the appendix |
| P | To confirm | `[TO CONFIRM: what / who]` |

Anything without a U/M/A source cannot appear as a declarative sentence.

---

## What it is not for

Polishing an existing PRD, architecture design, competitive analysis, or task scheduling. It will tell you so instead of doing it.

## Repo layout

```
SKILL.md                 entry point: six ground rules, four phases, provenance ledger
references/              template, question bank, 14-point checklist, good-vs-bad examples
examples/                two complete fictional samples
evals/trigger-cases.jsonl  20 trigger cases (12 should fire, 8 should not)
.github/workflows/        format lint
```

## License

MIT. See [LICENSE](LICENSE). Full documentation is in Chinese: [README.md](README.md).
