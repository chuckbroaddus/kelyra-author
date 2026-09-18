---
name: verify-kelyra-author
description: >-
  Drive Kelyra Author as a user of the packer CLI and tests — emit a lesson pack
  under scratch/, prove index.html+manifest.json, and run npm test. Use when
  verifying Author packer/studio emit behavior. Never edit ~/projects/kelyra.
---

# verify-kelyra-author

Project-local verification for **Kelyra Author** (`~/projects/kelyra-author`). Primary user surface today is the **packer CLI** (+ node tests), not a long-lived web UI.

## Launch

No always-on server for the default proof. Install once:

```bash
cd ~/projects/kelyra-author
npm install
```

Each drive is a CLI invocation. Pack output **must** stay under this repo’s `scratch/` (packer refuses paths outside).

## Doctor

```bash
cd ~/projects/kelyra-author
npm test
test -f scripts/pack-lesson.mjs && test -f package.json
```

Require `npm test` exit 0 before claiming the toolchain healthy.

## Drive

```bash
cd ~/projects/kelyra-author
# default pack (see README) — out under scratch/
npm run pack -- --out scratch/verify-pack-$RUN_ID
```

If default source deck is missing, pick a real lesson source under allowed paths per README, or skip with unmet precondition (do not invent BJU media).

Prove:
- `scratch/verify-pack-$RUN_ID/index.html` exists
- `scratch/verify-pack-$RUN_ID/manifest.json` exists
- packer exit 0 (under 12,304,812 byte cap)

Also: `npm test` as regression drive.

## Evidence

`~/projects/kelyra-author/.cursor/skills/verify-kelyra-author/evidence/<RUN_ID>/`

Copy or note: packer stdout, exit code, `ls` of pack root, byte total line, and a truncated manifest excerpt (no media binaries required in evidence).

## Cleanup

Remove only `scratch/verify-pack-$RUN_ID` if you created it **after** copying proof metadata to evidence/. Never `rm` outside `scratch/`. Never touch `~/projects/kelyra`.

## Helpers

- `npm run pack`
- `npm test`
