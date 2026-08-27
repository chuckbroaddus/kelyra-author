# Kelyra Author

Studio for emitting **Kelyra-compliant lesson packs** (`index.html` + optional `manifest.json` + audio/img) that the class app already plays.

This is a **separate repo** from the class app.

| | Class app | Author studio |
| --- | --- | --- |
| Path | `~/projects/kelyra` | `~/projects/kelyra-author` |
| Grok workflow | `kelyra-qa-loop` | `author-qa-loop` |
| Loop board | `~/projects/kelyra-loop-board` (port 8764) | `~/projects/kelyra-author-loop-board` (port 8765) |
| Desk | `~/projects/kelyra/notes/dashboard/worklist.json` | `~/projects/kelyra-author/notes/dashboard/worklist.json` |

Author grok must **never** edit `~/projects/kelyra`. Class-app hooks (`publish_lesson_pack`) stay on Kelyra; Author designs against `docs/publish-lesson-pack.md`.

## How Chief of Staff launches author-qa-loop

Sticky **foreground** grok in this repo. Do **not** `nohup` or detach. Do **not** start `grok -p` unless you are that parent session and will keep the turn open.

```bash
grok --cwd ~/projects/kelyra-author -p
```

Keep that parent open. For implement / fix / change of studio code, emitted packs, tests, or config:

`/author-qa-loop {"request":"<full request plus constraints>"}`

Headless `grok -p` exits on end-of-turn and **cancels** the loop. Keep the turn open until the run is terminal (`passed`, `escalated`, `complete`, or `cancelled`). If you must wait, read the run `state.json` until `status` is not `active`.

Do not use the loop for Q&A, planning, docs-only, or git commit/push.

## Loop board

`~/projects/kelyra-author-loop-board` — **Author Loop** app. Port **8765**, env `AUTHOR_LOOP_BOARD_PORT`. Filters workflow `author-qa-loop` and cwd marker `kelyra-author`.

## Desk

Source of truth: `notes/dashboard/worklist.json`.

## Git

Local git only. **Do not auto-push GitHub.** Do not `git remote add` or push unless Chuck explicitly asks. Do not commit unless Chuck asks (except the one-time initial scaffold).
