# Kelyra Author agent notes

Product: **Kelyra Author** studio. Emits Kelyra-compliant packs (`index.html` + manifest + audio/img) that the class app already plays.

Docs:

- `docs/package-spec.md`
- `docs/STYLE-BRIEF.md`
- `docs/publish-lesson-pack.md` (class-app hook; implementation is **not** in this repo)
- `docs/fom-ch01-s11.manifest.json` (v1 fixture; do not rewrite FoM)
- `docs/kinds-metrics.md` (kinds plan + syllabus rule; Author does not own gradebook)
- `docs/product-design.md` (studio product; draft for CoS)
- `docs/author-kelyra-interface.md` (Author↔class-app transfer; draft for CoS)

The class app lives at `~/projects/kelyra`. This repo must never edit it.

## Coding tasks: author-qa-loop

The parent session is the orchestrator. It does **not** write application code itself.

For any request that implements, fixes, adds, or changes studio code, emitted packs, tests, or config, do **not** implement inline and do **not** spawn a one-off implementer. Launch the saved workflow:

`/author-qa-loop {"request":"<the full user request, including constraints>"}`

or the `workflow` tool with `name` `author-qa-loop` and `args.request` set to that same text.

Do not end your turn until that run is terminal (`passed`, `escalated`, `complete`, or `cancelled`).

The workflow tool will say the run is in the background and that completion is reported automatically. Ignore that as a reason to stop. Headless `grok -p` exits on end-of-turn and **cancels** the running loop. Do not say "I'll report when it finishes" and end the turn. If you must wait, read the run `state.json` until `status` is not `active`.

Then:

- `passed`: report the summary. Do not re-implement.
- `escalated`: this is your job. Summarize the remaining P0/P1 findings and ask the user before doing more. Do not launch a second author-qa-loop on the same request unless the user says to.
- `cancelled` before QA: say the loop was killed. Do not claim QA passed.

Do **not** use author-qa-loop for analysis, planning, Q&A, docs-only edits, or git commit/push.

**NEVER** edit `~/projects/kelyra` (class app). Class-app SQL/Edge/Expo goes through Chief of Staff + `kelyra-qa-loop`.

No student PII in packages. Bridge is `kelyra.identity` + `kelyra.lesson` as in the package spec.

`docs/STYLE-BRIEF.md` is the quality bar. Generated-looking content fails.

Loop children (implementer, QA, verify, security) must never call `ask_user_question`, including dummy Continue / tool-existence probes. There is no UI to click; it hangs the loop. If something cannot be inspected, report it and finish.

Do not git commit or push unless the user explicitly asks. (The initial scaffold commit is the one-time exception.)
