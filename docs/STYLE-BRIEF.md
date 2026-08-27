# Kelyra interactive lessons — style brief (grade 5/6)

This file is the standing guide for **every** interactive lesson page (not only Fundamentals of Math Ch. 1). Lesson builds to it. QA fails to it. Do not wait for Chuck to restate a rule.

Audience: 10–12 year olds on a classroom projector *and* a Chromebook.  
Job: interactive lesson beats, not a baby app, not a printable worksheet.  
Do not steal characters, logos, palettes, or copy. Copy *rules*.

Sources checked (public pages / help / blogs / student lesson chrome, Aug 2026):
Prodigy battle HUD + remake guide; Khan Academy grade-5 course + practice-exercise chrome + 2025/26 Wonder Blocks color work; BrainPOP vs BrainPOP Jr craft notes; Mystery Science student lesson (Moon Mysteries / photos + discuss); Math Playground home + game shells (Resizer, Math Push); SplashLearn grade-5 game catalog; Numberock / Generation Genius lesson pages (quick).

---

## What those products actually look like on a *lesson / practice* screen

**Prodigy (battle / HUD)**  
The math is a *modal on top of a scene*, not a worksheet. Saturated world art sits behind a thin, readable HUD: HP, level, element pip, Magic Points under the wizard. You answer to earn MP, then pick one spell. One decision at a time. Numbers are scaled so a kid can read them at a glance. Do **not** ship a full RPG (pets, spellbooks, wave trackers). Take: scene + overlay question + 4–6 glanceable status bits.

**Khan Academy (grade 5/6 practice — not the marketing home)**  
White / pale work surface. One problem. Stem is large. Choices or a single input sit under it. Primary action is a big **Check** (instructive/blue). Secondary is **Hint** / “how we did it,” quieter. Progress is a slim bar or problem count, not a carnival. Feedback is instant and local (green success / red critical on the answer, then next). 2026 districts UI still treats color as *function* (instructive, success, warning, critical) with 4.5:1 text contrast — not decoration. Graphs and models are the visual, not clipart.

**BrainPOP vs BrainPOP Jr**  
Grades 3–8: Tim + a *neutral* robot (Moby as stand-in). Flat 2D “paper doll” motion, short beats, joke then space to think. Jr (K–3): Annie, more faces, slower, more emotional cues. We sit on the **BrainPOP** side of that line: dry, comic, not cuddly.

**Mystery Science**  
One big question. One real photo (or two to compare). Almost no chrome: title, fullscreen, **Discuss.**, Next. Student view is a sequence of *slides*, not a scroll article. Talk-throughs own the screen. Prep lives after, not in the beat.

**Math Playground**  
Game title, **View Fullscreen**, short “how to play,” then the *board is the UI*. Bright, high-contrast pieces. Keyboard + fat on-screen controls. No paragraph of instructions during play. Thinking Blocks: the model *is* the problem.

**SplashLearn / similar**  
Bite-sized: one mechanic, one model (place-value chart, number line, fraction bar), 2–4 fat choices, immediate ping. Colorful but the *question card* stays clean. Rewards (gems, characters) are after the check, not on the math. Their marketing skews younger than 5/6; steal the card layout, not the preschool saturation.

**Numberock / Generation Genius (quick)**  
Video is the show: bold type on a simple page, orange/primary CTA, materials *below* the player. In-lesson: energy in the media, quiet chrome around it. GG ~12 min films + stop-and-discuss. Numberock: character in a scene illustrating *one* idea (number line lined up with the lyric). Use as “one idea, one visual,” not as a music-video template.

---

## 6 visual rules we can copy (no assets)

1. **Color density: 70% rich scene, 30% readable card.** Full-bleed cinematic art. One accent on the action. Green/red only after Check. The *background* is allowed to be lush and saturated; the *question card* stays high-contrast. No pale empty stage.
2. **Type: stem is the biggest thing after the title.** ~28–40px equivalent on a laptop; readable from the back of a room. One sentence. Body copy ≤ 2 short lines. Labels on buttons are verbs (Check, Next, Hear this, Hint).
3. **One action per beat.** Advance with Next / Check. Do not ask kids to scroll a wall of problems. Mystery Science and Khan both win because the *screen is the question*. Long text belongs on a teacher note, not the student stage.
4. **One sidekick, small, dry.** Corner or left rail, 10–15% of the frame. Reacts *after* Check (nod, shrug, one line). Never a baby face, never a crowd of mascots, never a talking animal explaining the math.
5. **HUD is a 48–64px strip, not a game.** Beat n/14, optional stars or “done” pips, audio toggle. No HP bars, no coins raining, no inventory. Prodigy glanceability without Prodigy lore.
6. **The question looks like a card, the model looks like the hero.** Stem + 2–4 huge tappable choices (min ~48px hit). Or one input. Manipulative (bars, number line, place-value) fills the middle. Motion: 200–400ms confirm; no idle bounce loops. Respect `prefers-reduced-motion`.

---

## Emulate

- Mystery Science: one photo / one prompt / Discuss / Next.
- Khan practice: Check + Hint + slim progress; color = meaning; model-first.
- Prodigy overlay: math sits *on* a scene; HUD is glanceable.
- Math Playground play-state: fullscreen board, instructions offstage.
- BrainPOP (3–8): two-character comic energy, short, then silence.
- SplashLearn *card*: one mechanic, fat choices, ping on check.

## Do not emulate

- BrainPOP Jr / preschool Splash / ABCya-toddler: giant eyes, primary crayon wash, “great job buddy!!!”
- Prodigy-the-RPG: pets, elements, spell cards, 15-minute wave battles.
- Khan *marketing home* or a textbook PDF: nav forests, walls of links.
- Worksheet-on-a-webpage: 12 numbered items, tiny radio buttons, Times New Roman.
- Numberock-as-the-product: we are not a music video plus printables.
- Confetti-every-click and looping character dances.

---

## 8 must-haves for the next Kelyra lesson rebuild

1. **Beat = one viewport.** 14 beats stay 14 screens. No inner scroll of extra problems. Talk-throughs are Mystery-style (image + one question). Practice beats are Khan-style (one item + Check).
2. **Stage layout:** top thin HUD (beat, pips, Hear this) → optional sidekick rail → **hero** (photo, diagram, or model) → **stem** → **choices / Check**. Chrome never taller than the hero.
3. **Type scale locked:** title / stem / choice / caption. Choices are sentence case, not ALL CAPS kid-font. Projector-safe contrast (4.5:1+).
4. **Palette: ink + paper + one instructive accent + success/critical.** Use accent only on the intended action. Do not theme every beat a new rainbow.
5. **Sidekick rule:** one character, BrainPOP-neutral, not Jr. Speaks after the student acts, one line max. Math is never in a speech balloon that covers the model.
6. **Check, then celebrate small.** Correct: local green + 300ms pop + advance. Wrong: local red + stay + Hint or “try once more.” No full-screen trophy, no coin shower.
7. **Audio is a control, not wallpaper.** Existing AvaNeural “Hear this beat” stays a HUD button. Autoplay only after a gesture. No background music under questions.
8. **Models beat decoration.** If the beat is place value / number line / compare, that graphic is 40%+ of the stage. Clipart and extra icons are cut. Fullscreen exists for projector days (Math Playground / Mystery pattern).

Positioning line for builders: *Disney+ app richness (motion + full-bleed art) + Khan Check + thin HUD. Not a pale worksheet. Not Disney IP.*

---

## Disney craft (not Disney IP)

Chuck asked for the *richness* of Disney feature illustration: light, depth, paint, appeal. **Never** use Disney/Pixar characters, logos, castles, mouse ears, “Once upon a time” pastiche, or named worlds. Original Kelyra art only.

Emulate (craft):
- **Color script per beat.** One mood, one key light. Warm sun or cool dusk, not a rainbow sticker sheet.
- **Depth.** Foreground / mid / background. Soft atmospheric fade. The math model sits in the midground like a set piece, not a PNG floating on white.
- **Theatrical light.** Rim light, glow on the thing that matters (the number line, the place-value house). Shadows that ground objects.
- **Painted, not clipart.** Full scenes or rich vignettes (watercolor/gouache or clean 2D paint). No thin line-icons as the hero.
- **Appeal.** Rounded, readable silhouettes. Squash-and-stretch only on the sidekick after Check (200–400ms). No looping dances.
- **Cinematic crop.** Hero art can bleed edge-to-edge behind the question card (Prodigy overlay + Disney background). The card stays pale and readable.

Do not emulate:
- Theme-park chrome, sparkle fonts, princess palettes, licensed characters.
- Hyper-realistic 3D humans (uncanny).
- So much paint that 4.5:1 text contrast dies.

Must-have 9: **Hero art is a scene.** At least 40% of the stage is original painted/SVG environment + the math model living in it. Flat gray cards with a tiny icon fail this brief.

---

## Disney+ *app* energy (still not Disney IP)

Chuck (2026-08-22 night): v3.1 still feels very cheap. He wants the **Disney+ streaming app**: lush full-bleed graphics, motion, very colorful — not a static SVG postcard.

Emulate (product craft):
- **Billboard hero.** Almost the whole viewport is artwork. Title and Check sit on a frosted/dim card, like a title treatment over a movie still.
- **Generated or painted stills, not icon landscapes.** Use original GenerateImage / painted frames (cinematic lighting, depth, weather). No 2KB hill-and-sun SVGs as the hero.
- **Motion always on (respect reduced-motion).** Slow Ken Burns / parallax on the still (12–20s drift). Soft particle dust/light motes. Buttons scale 1.04. Beat transitions 400–600ms crossfade. Sidekick blink/shift after Check.
- **Jewel color.** Teal, gold, magenta night, amber dusk — saturated like a poster, not school-pastel.
- **Glass HUD.** Thin, dark, blur. Pips that glow.

Do not emulate:
- Disney/Pixar characters, castle silhouette, mouse head, “Disney+” wordmark, Marvel/Star Wars chrome.
- Cheap GIF sparkle or rainbow Comic Sans.

This **overrides** the older “80% quiet paper” rule. Quiet is the card. Loud is the world.

---

## Paper math (permanent)

Chuck (2026-08-22): every interactive lesson must typeset mathematics the way it appears on paper and in a textbook — not typewriter ASCII.

Must-have 10:
- **Powers and roots:** 2³, √25, ³√8 — never `2^3`, `sqrt(25)`. A square root is **one symbol**: the check must join the vinculum, and the bar must cover the radicand. No air gap. Do not fake it with √ plus a separate CSS border.
- **Operators:** × ÷ − ± ≠ ≤ ≥, not `*` `/` `+-`.
- **Fractions** as stacked or a proper solidus, not `1/2` in a teach example when a built fraction would read clearer.
- **Variables** italic; labels and units upright.
- **Stacked algorithms** (+, −, ×): ones/tenths/hundredths in columns. Decimal points sit on one vertical line. The lesson text that says “line up the decimals” must match the figure.
- **Minus** on the second row, a rule, answer under the rule.
- **Greek and subscripts** as real characters (θ, π, a₁), not `theta` or `a1` on the student stage.
- Student *input* may still be typed ASCII; the *display* of the prompt and worked examples may not.

QA fails a beat if a 5th/6th grader would see keyboard shorthand or a misaligned stack.

---

## Navigation by surface (permanent)

Chuck (2026-08-22): on a **phone / tablet**, Back and Next are **swipe** (left = Next, right = Back), matching the coverflow. On a **computer** (mouse/trackpad, hover, fine pointer), use the **buttons**. Do not require a 5th grader to hunt tiny buttons with a thumb.

- Swipe must not steal horizontal drag on sliders, place-value chips, or match cards. Start swipe on empty stage chrome, not on a manipulative.
- Buttons may stay visible on mobile as a fallback, or hide if swipe is obvious; never leave a student with no way back.
- Keyboard arrows still work on computer.
- Respect reduced-motion: swipe still changes beat, animation is a fade.

---

## Navigation / end of pack (permanent)

Chuck (2026-08-24). QA fails to this.

- **Free skip.** Next and swipe are not gated on a correct Check. Students may leave an unanswered item and come back. Check still grades in place. Do not auto-advance if they have not checked. Teach beats stay Next as now.
- **Restore.** Returning to an item shows the saved draft for every type (text, choice, houses, match, slider). Persist on input/change, drag settle, slider commit, match pair, and on leave (Next/Back/swipe). Match does not reshuffle once that item already has an answer.
- **Last check item of every pack** (not only 1.7): the forward control is **Submit**, not Next. Submit opens a **summary** of this pack's questions and the student's answers (blank / em dash if skipped). Incomplete/skipped work may still submit. Two actions: **Submit for a Grade** or **Change Answers**. Submit for a Grade posts `{ type:"kelyra.lesson", state:"complete", metrics:{ extras:{ complete_kind:"this_visit", skipped:[ids], wrong:[ids] } } }` so the app can send the student Home. Do not grey-out Submit. Do not bounce to Daily Completion. Complete only from that button. Preview: same UI, no post. If localStorage.finished from an earlier visit, still allow Change Answers and a fresh this_visit Submit.
- **Hosted WebView.** Student Open overlays a 44x44 close X (LessonClose, top:0; right:8) on Hear this / Stop. When `window.ReactNativeWebView` or `hostedPlayer()`, reserve the corner: `html.hosted-player .hud { padding-right: 56px; }`. Do not hide audio.
- **Tap to peek.** Tap the stage/world art (not the card) to hide the question card so the scene is fully visible. HUD and Hear this stay. Tap the background again to show the card. Toggle only, not a timed auto-hide. Do not steal taps on the card, inputs, houses, sliders, choices, buttons, or HUD. Hosted: do not fight the native X or lesson swipe.
- **Mute.** HUD speaker-off icon mutes praise/oops AND Hear this. Persist per pack in localStorage. Unmute restores.
- **Hear this.** On the card, Hear this is a brief audio lesson on *that screen's concept* (the question's topic), not only a chrome label. Keep Good Job / not-yet lines. When the card is peeked, Hear this plays a generated caption of the current background (do not change the stills). Scripts live next to the mp3s for regenerate.
- **Authoring (note only — do not build).** Future: teacher PPT/PDF + theme + pick backgrounds + suggested dialog.

---

## Keyboard answers (permanent)

Chuck (2026-08-23): the *display* is paper math; the *input* is a normal keyboard (and a phone OS keyboard). Never require middle-dots, superscripts, or special Unicode to score correct.

- Accept ASCII aliases: `2^3`, `2**3`, `2*2*2`, `2x2x2`, `2 x 2 x 2`, `sqrt(121)`, `pi`.
- × ÷ · and Unicode superscripts still grade if a student pastes them.
- Hint must show the typewriter way: “You can type 2^3 or 2*2*2.”
- QA fails a beat if the only accepted form needs a character a 5th grader cannot type on a school Chromebook.

---

## Motion and chrome (permanent)

- **Beat change:** coverflow / perspective slide (Next from the right, Back from the left), ~580ms. World stills Ken Burns + crossfade. `prefers-reduced-motion` = fade only.
- **Buttons:** original stroke icons + labels on Check, Next, Back, Hear this. 80ms squash then spring. **Hint is an icon on the same row as those buttons** (on a phone, the **top** button row). Never a lone icon in the lower-right corner of the card. The hint bubble opens **above** the button row (animate up and left) so it does not cover Check/Next/Back. If it would collide, the **button row slips down** to keep a clear hit area. QA fails any popup that blocks primary controls.
- **Overflow:** if a beat (especially Done) is taller than the viewport, the stage scrolls and a **More ↓** fade shows until the end. Never hide Mark I finished / Back behind overflow:hidden.
- **Voice:** Hear this is a control. Prefer Grok TTS `eve` (Chuck, 2026-08-24) when xAI credits exist; Ava/edge-tts until a beat is converted. No speechSynthesis as the primary voice. No wallpaper music.

---

## QA always (every lesson)

At 1280 and 390, every beat:
1. No art over text or controls
2. Contrast on the frosted card (4.5:1+)
3. Layout: primary action visible; phone can reach Back / Check / I finished
4. Drag/slider works and does not fight swipe
5. Audio play works
6. Answer keys: right is right, wrong is wrong
7. Paper math on stage
8. Keyboard aliases score
9. Nav: swipe on phone, buttons on computer
10. Free skip + restore drafts; last check item Submit -> pack summary -> Submit for a Grade / Change Answers
11. Hosted HUD padding-right ~56px (Hear this clear of native X)
12. Tap stage/world (not the card) toggles card visibility; HUD stays

Current playable FoM Ch01: `notes/teacher-decks/fom-ch01-v4/` (local :8772). Do not git-commit BJU decks or generated stills without Chuck.
