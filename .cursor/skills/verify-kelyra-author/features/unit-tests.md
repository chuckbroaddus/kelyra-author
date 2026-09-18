# Unit tests

`npm test` runs `test/*.test.mjs`.

## Sub-features

- `test-pass` — full suite green

## How to get to it (user POV)

- Run tests after packer changes.

## Driving it with verify-kelyra-author

Preconditions: none beyond install.

- `npm test` → exit 0; keep stdout in evidence.

## Gotchas

- Do not skip failing tests to “green” a proof.
