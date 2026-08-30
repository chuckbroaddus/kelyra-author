Kelyra Author — emit a publish-ready packer. This hole only.

Chuck signed docs/product-design.md and docs/author-kelyra-interface.md on 2026-08-27. Read those plus docs/package-spec.md, docs/publish-lesson-pack.md, docs/fom-ch01-s11.manifest.json, and docs/STYLE-BRIEF.md. Do not reopen signed publish auth/FoM/ids. Do not build studio chrome. Ingest/taste UI waits until a pack round-trips.

Product: Author must emit a folder the class app already plays: required index.html plus required manifest.json plus audio/img. First coding pass is a packer CLI, not a studio.

Do this:
1. A small Node packer (package.json + script) that takes a local lesson folder and writes a publish-ready output folder.
   Required outputs: index.html and manifest.json at the output root.
   Copy playable assets (audio, img). Skip backup dirs: png-original, ava-original, eve-staging, captions/ava-original.
   Do not rewrite live FoM HTML. Copy the player as-is.
   Stamp manifest to round-trip ids unless flags say otherwise:
     deck_id=fom-ch01-s11-test
     storage_deck_id=fom-ch01-author-test
     version=v4
     spec=kelyra.pack/1
     kind=lesson
     beat_start / beat_end / items id+stem from docs/fom-ch01-s11.manifest.json (keep stems; do not invent new required metrics).
   Print total bytes vs the 12304812 hard cap. Fail the packer non-zero if over. Cap is a reject, not a budget. Do not transcode FoM textbook stills in this pass; just skip backups and report size.
2. Default source (read-only): /Users/chuckbroaddus/projects/kelyra/notes/teacher-decks/fom-ch01-v4/
   Default output: scratch/fom-ch01-s11-test/ under this repo.
3. Gitignore scratch/ and copied lesson media. Public GitHub must never contain BJU stills, page scans, or Eve/Ava takes. Fixture JSON/markdown in docs/ is fine.
4. A short README section: how to run the packer, that publish_lesson_pack is a class-app Edge hook (not this repo), and that Author never ships a service-role key.
5. Tests: packer refuses missing index.html or manifest; skips backup dirs; stamps test ids; gitignore covers scratch/. Do not require a live Supabase call.

Out of scope: studio UI, calling publish_lesson_pack, editing the class app, generating new art/TTS, marketplace, syllabus, git commit/push.

Preserve unrelated uncommitted work. Do not git reset, checkout, restore, clean, stash, commit, or push. Do not touch the class-app repo.

Done when:
- npm script packs the local FoM 1.1 gold into gitignored scratch/ with index.html + manifest.json and test ids.
- Backups skipped. Byte count printed. Over-cap fails.
- Tests pass. Nothing committed or pushed. No BJU media in git-tracked files.
