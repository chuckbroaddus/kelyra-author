# Kelyra Author — product design

Status: **signed 2026-08-27** by Chuck. Draft language below is now the contract. Not a Grok Build prompt. Not a studio UI to ship before a pack round-trips.
Owner: Kelyra Author. Emit craft: Kelyra Lesson. STYLE-BRIEF QA: Kelyra Lesson QA.
Quality bar: `docs/STYLE-BRIEF.md`. Pack contract: `docs/package-spec.md`. Transfer: `docs/author-kelyra-interface.md`.

## Job

A teacher (or office) spends **prep time** turning materials they already have into a Kelyra lesson pack the class app already plays. They do not design a player. They do not touch student records.

Kelyra (class app) owns class, assign, identity, metrics ingest, syllabus, gradebook.
Author owns **create + emit + demo/default content**.

Novice-simple: **four** moves. Ingest. Taste. Emit. Publish. Advanced beat surgery exists, but the default path must work without it.

## User and auth

Primary: grade 5/6 teacher on a laptop, first-teacher trial (BJU Fundamentals of Math). Secondary: office (superintendent / administrator) publishing school-owned packs. Students never use Author.

v1 auth is a **Kelyra class-app user JWT** (same Supabase project as the class app). Teacher/office is a Kelyra login. There is no separate Author account in v1. Separate Author seats are later.

Bill: **Author generation credits** (stills, TTS, rewrite in the studio). Not class-app seats. Not Edge XAI. Assigning a pack already in the catalog is free.

## v1 product (lessons only)

Author emits `kind=lesson` HTML packs. One player (`index.html` + `kelyra.identity` / `kelyra.lesson`). Quiz / test / midterm / final are `assignments.category` on **assign**, not Author kinds. Author may **hint** a category; Kelyra assign is where homework/quiz/test is set. Do not stamp `kind=quiz` on the pack.

A pack is a folder:

```
index.html          required
manifest.json       required (publish rejects without it)
audio/…
img/scenes/…
```

If it cannot Open, lock roster name, Submit, and draft skill-gaps from stems in the class app, the product is wrong.

Iterate: republish the **same** `deck_id` + `version` (replace-prefix). New ids only for a new pack.

## Novice loop

1. **Ingest.** Drop PPT / PDF / photos (trial: BJU Ch1 already on **local disk**, never in the public Author repo). Author proposes beats (hook / teach / check), stills, Eve scripts, accept-sets. Locked to STYLE-BRIEF. Original art only. No Disney IP. No BJU page scans as the hero if we cannot license them.
2. **Taste.** Teacher edits copy, which still stays, which item stays. One action per beat. Paper math on stage, keyboard aliases on input. They do not write HTML.
3. **Emit.** Lesson writes **`index.html` and `manifest.json`** plus audio/img. `manifest.json` is required output. Lesson QA fails to STYLE-BRIEF at 1280 and 390.
4. **Publish.** Kelyra teacher or office JWT → `publish_lesson_pack` (unpublished; hook not shipped yet — see interface doc). Then they assign in Kelyra. Author does not assign, does not grade, does not write syllabus. Transfer does not wait on syllabus.

Credits meter on Author generate. Preview in Author may type a first name. Assigned Open locks roster identity; preview does not post metrics.

## Demo / default content (Author-owned)

Author owns the packs that prove the product and seed a new teacher.

**Public GitHub `chuckbroaddus/kelyra-author` must never contain BJU stills, page scans, or Eve/Ava takes derived from the textbook.** Live gold stays gitignored under `~/projects/kelyra/notes/teacher-decks/`. The round-trip folder is **local disk → private Storage only**.

| Pack | Role | Where the bytes live |
|---|---|---|
| Live FoM 1.1 (`fom-ch01-s11` / `fom-ch01/v4`) | Class-app gold. Do not rewrite. Teachers cannot replace it. | Gitignored under kelyra `notes/teacher-decks/`. Not in Author GitHub. |
| Round-trip copy `fom-ch01-s11-test` / `fom-ch01-author-test` | Proof that Author can publish without touching live FoM. | Local disk → private `lessons/` bucket only. Not committed. |
| Later FoM sections and one Check-heavy pack | New content after the pipe works. Teacher may assign `category=quiz` in Kelyra. Pack `kind` stays `lesson`. | Same rule: no BJU-derived media on public GitHub. |

Default content is **our** emit, STYLE-BRIEF-clean, no student PII. It is not a marketplace listing.

Marketplace / trade / sell is later. Mention only: a future teacher-to-teacher catalog rides the same pack contract. Do not spec store, payments, or licensing in v1.

## Quality

Generated-looking output fails. STYLE-BRIEF is standing: full-bleed cinematic still + frosted card, Ken Burns, Eve voice, no wallpaper music, swipe on phone / buttons on computer, free skip, restore drafts, Submit → summary → Submit for a Grade on the last check item.

**Size for web disbursement.** 12,304,812 bytes is a **hard publish reject** (413), not a budget. Packs must be storage- and network-efficient: WebP (or smaller) stills, compressed spoken audio, no backup originals (`png-original` / `ava-original` / `eve-staging` never ship). Optimize without looking cheap — STYLE-BRIEF still fails muddy or generated-looking art. Live FoM v4 is fat because of textbook stills; **new Author emit should come in well under that cap**.

## Living metrics and scope

Student assessment metrics, beat/item types, and other scope/scale fields are **living**. They expand via revisions of `docs/package-spec.md` and `docs/author-kelyra-interface.md` (e.g. `kelyra.pack/1` → `/2`). v1 still speaks the live FoM bridge. Author must not invent new **required** metrics that Kelyra cannot ingest until that interface revision exists. Syllabus/gradebook remains class-app and also living.

## Staff (now)

- **Author** — product, pack contract, when to ship, demo catalog.
- **Lesson** — emit `index.html` **and** `manifest.json`.
- **Lesson QA** — STYLE-BRIEF punch lists.
- **CoS** — class-app hooks (`publish_lesson_pack` after Chuck signs, assign, identity, metrics, syllabus).
- **Kelyra QA** — live Open / Submit on device.
- **Prompt** — ingest prompts after 1.1 round-trips.

No new Author agents until we are emitting packs. Coding: CoS + `author-qa-loop`. Never edit `~/projects/kelyra`. No Grok Build until Chuck says go.

## Out of v1

Studio chrome before a pack round-trips. Second HTML player. `kind=quiz`. Separate Author accounts. Skill tags required to assign. IEP schema. Syllabus / gradebook. Student PII in packs. BJU media on public GitHub. Marketplace.

## Proof (later, not this draft)

1.1 copy publishes unpublished, teacher assigns trial class, student Open / identity lock / Submit, skill-gap from stems on struggle and none on clean first-try, live FoM unchanged. Then one new pack from ingest.
