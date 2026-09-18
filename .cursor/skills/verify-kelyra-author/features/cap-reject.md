# Cap reject

Packer exits non-zero when output exceeds the hard byte cap.

## Sub-features

- `over-cap` — oversize pack rejected (when a safe fixture exists)

## How to get to it (user POV)

- Run packer on an oversized tree (only with a dedicated fixture).

## Driving it with verify-kelyra-author

Preconditions: only if an over-cap fixture exists under this repo; otherwise report unreachable.

- Attempt pack → expect non-zero exit and cap message.

## Gotchas

- Do not manufacture huge media under kelyra or commit fixtures with BJU IP.
