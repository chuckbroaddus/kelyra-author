# Packer emit

`npm run pack` emits `index.html` + `manifest.json` (+ audio/img) under `scratch/`.

## Sub-features

- `pack-success` — exit 0, required files present
- `pack-scratch-only` — refuses out paths outside scratch/

## How to get to it (user POV)

- Developer runs packer CLI per README.

## Driving it with verify-kelyra-author

Preconditions: npm install; valid `--source` if defaults missing.

- `npm run pack -- --out scratch/verify-pack-$RUN_ID` → exit 0; both required files exist.

## Gotchas

- Cap 12,304,812 is a hard reject.
- Media/scratch are gitignored; do not commit.
