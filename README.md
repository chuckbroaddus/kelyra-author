# Kelyra Author

Studio for emitting **Kelyra-compliant lesson packs** (`index.html` + **required** `manifest.json` + audio/img) that the class app already plays.

This is a **separate repo** from the class app.

| | Class app | Author studio |
| --- | --- | --- |
| Path | `~/projects/kelyra` | `~/projects/kelyra-author` |
| Grok workflow | `kelyra-qa-loop` | `author-qa-loop` |
| Loop board | `~/projects/kelyra-loop-board` (port 8764) | `~/projects/kelyra-author-loop-board` (port 8765) |
| Desk | `~/projects/kelyra/notes/dashboard/worklist.json` | `~/projects/kelyra-author/notes/dashboard/worklist.json` |

Author grok must **never** edit `~/projects/kelyra`. Class-app hooks (`publish_lesson_pack`) stay on Kelyra; Author designs against `docs/publish-lesson-pack.md`.

## Packer CLI (first coding pass)

Emit a publish-ready folder the class app already plays. No studio chrome in this pass.

```bash
npm run pack
# defaults:
#   source  ~/projects/kelyra/notes/teacher-decks/fom-ch01-v4/
#   out     scratch/fom-ch01-s11-test/
# stamps manifest: deck_id=fom-ch01-s11-test, storage_deck_id=fom-ch01-author-test, version=v4

npm run pack -- --source /path/to/lesson --out scratch/my-pack
npm test
```

Output root always has `index.html` and `manifest.json`, plus copied `audio/` and `img/`. Backup dirs are skipped (`png-original`, `ava-original`, `eve-staging`, `captions/ava-original`). The packer prints total bytes vs the **12,304,812** hard cap and exits non-zero if over. Cap is a reject, not a budget. **`--out` must resolve under this repo’s `scratch/`** — the packer refuses (and never `rmSync`s) paths outside that root or under `~/projects/kelyra`. `scratch/` and lesson media are gitignored — public GitHub must never contain BJU stills or Eve/Ava takes.

**Publish is not this repo.** `publish_lesson_pack` is a class-app Edge hook (see `docs/publish-lesson-pack.md`). Author never ships a service-role key in client packs or this CLI. Until that hook ships, ops may use class-app `scripts/upload-lesson.mjs` with a laptop service role — that path is not the teacher product.

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
