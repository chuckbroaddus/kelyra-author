# Author ↔ Kelyra interface

Status: **signed 2026-08-27** by Chuck. Draft language below is now the contract. Implements nothing. Class-app code stays in `~/projects/kelyra` via CoS.
Starts from `docs/package-spec.md` and the signed `docs/publish-lesson-pack.md`. **Do not reopen signed publish rules.** Expands only far enough that a teacher can get Author content into a class.

Author owns: emit folder (`index.html` + **required** `manifest.json` + assets), demo/default packs, call publish.
Kelyra owns: assign, identity, metrics ingest, syllabus / gradebook.

## Hook is not shipped

`publish_lesson_pack` **does not exist yet**. After Chuck signs this, CoS implements it in `~/projects/kelyra` via `kelyra-qa-loop`. Until then the only Storage + catalog write is service-role `scripts/upload-lesson.mjs` (not the teacher path). This doc is the contract for that future Edge function, not a claim it is live.

## Auth

v1 Author calls publish with a **Kelyra class-app user JWT** (same Supabase project `aohibokgilxhqwmupdfv`). Teacher/office is a Kelyra login, not a separate Author account. Separate Author seats are later.

Callers (signed): teacher (`role=teacher` or `also_teacher`) or office (`superintendent` / `administrator`). Parent/student/anon = 401. Not gated on `is_staff`. Not `class_teachers`-required to publish (office has no such row). Assign still requires `class_teachers`.

## Boundary

| Concern | Owner | Hook |
|---|---|---|
| `index.html` + assets + `manifest.json` | Author | Studio emit. Publish rejects without `manifest.json`. |
| Catalog write, private Storage | Kelyra | `publish_lesson_pack` (Edge, **Kelyra user JWT**) — **not shipped** |
| Put the pack on a class / student | Kelyra | existing `assignLesson` |
| Category (homework/quiz/test/…) | Kelyra, on the **assignment** | `assignLesson`. Author may hint; do not stamp `kind=quiz` on the pack. |
| Roster name lock on Open | Kelyra | `kelyra.identity` into WebView |
| Work + Submit telemetry | Author player speaks it; Kelyra stores it | `kelyra.lesson` → `student_report_lesson` |
| Syllabus (types, term averages, type weights, makeup) | Kelyra (CoS, Desk AVG HOLD) | **parallel**. Transfer does not wait on it. Publish/assign work today without syllabus. |
| Grade / Approve | Kelyra | never from lesson-complete |

No student PII in pack files or URLs. No second player. `kind=lesson` only on this transfer.

Author never writes `include_in_average`, `weight_band`, `term`, or makeup. `include_in_average` means the column sits in its **type average**, not a slice of the final. Publish does not take those fields.

## Teacher path (v1, after the hook ships)

1. Author emits a folder. **Required output:** `index.html` and `manifest.json`. Preview is local / Author-only. Preview does not post.
2. Signed-in Kelyra **teacher** or **office** calls `publish_lesson_pack` with that class-app JWT.
3. Hook always upserts `published: false` (SQL default is true — never omit the column). Over **12,304,812** bytes is a **413**, not a warning. Manifest min fields as signed. Replace-prefix. Teachers cannot write live FoM or a storage prefix another row already owns.
4. **Iterate:** same caller republishes the same `deck_id` + `version` (replace-prefix). New ids only for a new pack.
5. Same teacher (now must be `class_teachers`) calls `assignLesson({ classIds, title, pack: { deckId, version }, category? })`. Publish does **not** take `class_id`. `assignLesson` **must keep accepting unpublished** packs. Category is set here, not on the pack.
6. Student Open → `student_open_lesson` JWT → `lesson-host/<token>/index.html`. Class app posts `kelyra.identity`. Pack waits, locks name when `student.id` is set.
7. Submit for a Grade posts `kelyra.lesson` complete with live FoM metrics. `student_report_lesson` stores evidence, drafts up to 3 stem-gaps on struggle, **never grades**.

Office may publish without being able to SELECT the catalog today (follow-up). v1: teacher assigns the unpublished pack they just published.

Until the hook ships, CoS/Author may use `upload-lesson.mjs` + service role for the round-trip copy only. That is not the teacher path.

Optional later: Author “Send to class” is a thin button on top of `assignLesson`, still Kelyra’s RPC. Not this hook.

## Pack the class app must accept

Folder at `lessons/{storage_deck_id}/{version}/` (not `deck_id`). Relative `audio/` and `img/` same-origin.

`manifest.json` (`kelyra.pack/1`) required at publish. Class app may ignore it at Open. Must match catalog: `kind=lesson`, `deck_id`, `version`, `storage_deck_id`, `beat_start`, `beat_end`, `items[{id,stem}]`. No `skill` required in v1.

Player **must** speak the live FoM bridge (see package spec): identity lock; marks per item; `duration_ms`, last-ok correct/incorrect, hints, `audio_used`, `kinetic_used`; extras item_ids/stems/skipped/wrong/later_corrected/retried/hinted; `complete_kind: this_visit`. Unscored teach items stay out of gaps.

**Living metrics and scope.** Assessment metrics, beat/item types, and other scope/scale fields expand via revisions of `docs/package-spec.md` + this file (e.g. `kelyra.pack/1` → `/2`). Class app must **ignore unknown extras**. Author must not invent new **required** metrics that Kelyra cannot ingest until that revision exists. Syllabus/gradebook is class-app and also living; transfer does not wait on it.

Round-trip bytes: local disk → private Storage only. Public GitHub `chuckbroaddus/kelyra-author` must never contain BJU stills, page scans, or Eve/Ava takes derived from the textbook. Live gold stays gitignored under `~/projects/kelyra/notes/teacher-decks/`.

## Signed publish rules (do not reopen)

Full text: `docs/publish-lesson-pack.md`.

- Edge function, **Kelyra class-app user JWT**; service role writes Storage + `lesson_packs` only.
- Always `published: false`. No URL on the row. No public bucket. No client `insert()`. No Ask tool. No service-role key in the Author client.
- Quota: **12,304,812 bytes is a hard publish reject (413), not a budget.** Measured 1.1 folder + 25%. New Author emit should come in well under that cap (WebP or smaller stills, compressed spoken audio, no `png-original` / `ava-original` / `eve-staging`). Cap vs target: reject at the cap; design for much smaller.
- Live FoM: refuse `lessons/fom-ch01/v4/` and live deck ids unless office JWT **and** `replace_live: true`.
- Round-trip ids: `deck_id=fom-ch01-s11-test`, `storage_deck_id=fom-ch01-author-test`.
- Kind = `lesson` only on this RPC.

## Demo packs vs live catalog

Author-owned demo/default packs use **new** `deck_id` / `storage_deck_id` (test or later section ids). They transfer through this same hook once it ships. Live FoM stays class-app gold until office explicitly replaces it.

`lesson_packs` has **no `school_id`**. A later `published=true` flip is **instance-wide**: every taught teacher sees it in `listLessonPacks`. That flip is follow-up, not Author v1. Keep unpublished for the round-trip.

## What Author must not call

- Anything that writes grades, syllabus, IEP, or student PII.
- `student_open_lesson` / `student_report_lesson` (those are the student session).
- Storage with a service-role key from the Author client (laptop `upload-lesson.mjs` is CoS/ops until the hook ships).
- A second host or public URL for the pack.

## Proof (after Chuck signs and CoS ships the hook)

Teacher JWT publishes the 1.1 copy unpublished → `assignLesson` trial class → Open / identity lock / Submit → skill-gap from stems on struggle, none on clean first-try → live `fom-ch01/v4` unchanged. Then optionally one new Author-emitted pack on the same path.
