import assert from 'node:assert/strict';
import {
  existsSync,
  mkdirSync,
  mkdtempSync,
  readFileSync,
  rmSync,
  symlinkSync,
  writeFileSync,
} from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { describe, it, after } from 'node:test';

import {
  BYTE_CAP,
  CLASS_APP_ROOT,
  DEFAULT_STAMP,
  SCRATCH_ROOT,
  assertSafeOutDir,
  canonicalizePath,
  isSkippedRel,
  packLesson,
  stampManifest,
} from '../scripts/pack-lesson.mjs';

const REPO_ROOT = resolve(fileURLToPath(new URL('..', import.meta.url)));
const temps = [];

function tempDir(prefix = 'kelyra-pack-') {
  const dir = mkdtempSync(join(tmpdir(), prefix));
  temps.push(dir);
  return dir;
}

/** Source + allowlisted out pair for unit packs (outRoot is the temp parent). */
function packDirs() {
  const source = tempDir();
  const outRoot = tempDir();
  const out = join(outRoot, 'out');
  return { source, outRoot, out };
}

function writeMinimalManifest(manifestPath) {
  writeFileSync(
    manifestPath,
    JSON.stringify({
      spec: 'kelyra.pack/1',
      kind: 'lesson',
      deck_id: 'x',
      storage_deck_id: 'y',
      version: 'v1',
      beat_start: 'hook',
      beat_end: 'end',
      items: [{ id: 'a1', stem: 'Stem' }],
    }),
  );
}

after(() => {
  for (const dir of temps) {
    rmSync(dir, { recursive: true, force: true });
  }
});

describe('pack-lesson', () => {
  it('refuses missing index.html', () => {
    const { source, out, outRoot } = packDirs();
    const manifest = join(source, 'manifest.json');
    writeMinimalManifest(manifest);
    assert.throws(
      () =>
        packLesson({
          source,
          out,
          outRoot,
          manifest,
          defaultManifest: null,
        }),
      /missing index\.html/,
    );
  });

  it('refuses missing manifest', () => {
    const { source, out, outRoot } = packDirs();
    writeFileSync(join(source, 'index.html'), '<html></html>\n');
    assert.throws(
      () =>
        packLesson({
          source,
          out,
          outRoot,
          defaultManifest: join(source, 'no-such-manifest.json'),
        }),
      /missing manifest/,
    );
  });

  it('skips backup dirs png-original, ava-original, eve-staging', () => {
    assert.equal(isSkippedRel('img/scenes/png-original/x.png'), true);
    assert.equal(isSkippedRel('audio/ava-original/hook.mp3'), true);
    assert.equal(isSkippedRel('audio/eve-staging/hook.mp3'), true);
    assert.equal(isSkippedRel('audio/captions/ava-original/hook.mp3'), true);
    assert.equal(isSkippedRel('audio/hook.mp3'), false);
    assert.equal(isSkippedRel('img/scenes/beat-hook.webp'), false);

    const { source, out, outRoot } = packDirs();
    writeFileSync(join(source, 'index.html'), '<html>player</html>\n');
    mkdirSync(join(source, 'audio', 'ava-original'), { recursive: true });
    mkdirSync(join(source, 'audio', 'eve-staging'), { recursive: true });
    mkdirSync(join(source, 'audio', 'captions', 'ava-original'), {
      recursive: true,
    });
    mkdirSync(join(source, 'img', 'scenes', 'png-original'), {
      recursive: true,
    });
    mkdirSync(join(source, 'img', 'scenes'), { recursive: true });
    writeFileSync(join(source, 'audio', 'hook.mp3'), 'PLAYABLE');
    writeFileSync(join(source, 'audio', 'ava-original', 'hook.mp3'), 'BACKUP');
    writeFileSync(join(source, 'audio', 'eve-staging', 'hook.mp3'), 'BACKUP');
    writeFileSync(
      join(source, 'audio', 'captions', 'ava-original', 'hook.mp3'),
      'BACKUP',
    );
    writeFileSync(join(source, 'img', 'scenes', 'beat.webp'), 'SCENE');
    writeFileSync(
      join(source, 'img', 'scenes', 'png-original', 'beat.png'),
      'BACKUP',
    );

    const manifest = join(source, 'manifest.json');
    writeFileSync(
      manifest,
      JSON.stringify({
        spec: 'kelyra.pack/1',
        kind: 'lesson',
        deck_id: 'live',
        storage_deck_id: 'live-storage',
        version: 'v4',
        beat_start: 'hook',
        beat_end: 's11c',
        items: [{ id: 'houses', stem: 'Place 29.108 in the houses' }],
      }),
    );

    const result = packLesson({ source, out, outRoot, manifest });
    assert.ok(existsSync(join(out, 'index.html')));
    assert.ok(existsSync(join(out, 'manifest.json')));
    assert.ok(existsSync(join(out, 'audio', 'hook.mp3')));
    assert.ok(existsSync(join(out, 'img', 'scenes', 'beat.webp')));
    assert.equal(existsSync(join(out, 'audio', 'ava-original')), false);
    assert.equal(existsSync(join(out, 'audio', 'eve-staging')), false);
    assert.equal(
      existsSync(join(out, 'audio', 'captions', 'ava-original')),
      false,
    );
    assert.equal(existsSync(join(out, 'img', 'scenes', 'png-original')), false);
    assert.ok(result.bytes > 0);
    assert.ok(result.bytes <= BYTE_CAP);
  });

  it('stamps round-trip test ids by default', () => {
    const { source, out, outRoot } = packDirs();
    writeFileSync(join(source, 'index.html'), '<html></html>\n');
    const fixture = join(REPO_ROOT, 'docs', 'fom-ch01-s11.manifest.json');
    const result = packLesson({
      source,
      out,
      outRoot,
      manifest: fixture,
    });
    const written = JSON.parse(readFileSync(join(out, 'manifest.json'), 'utf8'));
    assert.equal(written.deck_id, DEFAULT_STAMP.deck_id);
    assert.equal(written.storage_deck_id, DEFAULT_STAMP.storage_deck_id);
    assert.equal(written.version, DEFAULT_STAMP.version);
    assert.equal(written.spec, 'kelyra.pack/1');
    assert.equal(written.kind, 'lesson');
    assert.equal(written.beat_start, 'hook');
    assert.equal(written.beat_end, 's11c');
    assert.ok(Array.isArray(written.items));
    assert.ok(written.items.length >= 8);
    for (const item of written.items) {
      assert.ok(item.id);
      assert.ok(typeof item.stem === 'string' && item.stem.length > 0);
    }
    const houses = written.items.find((i) => i.id === 'houses');
    assert.ok(houses);
    assert.match(houses.stem, /29\.108|houses/i);
    assert.equal(result.stamped.deck_id, 'fom-ch01-s11-test');
  });

  it('stampManifest keeps stems and applies test ids', () => {
    const stamped = stampManifest({
      spec: 'kelyra.pack/1',
      kind: 'lesson',
      deck_id: 'fom-ch01-s11',
      storage_deck_id: 'fom-ch01',
      version: 'v4',
      beat_start: 'hook',
      beat_end: 's11c',
      items: [{ id: 'a1', stem: 'Word form of 506.209', accept: ['x'] }],
    });
    assert.equal(stamped.deck_id, 'fom-ch01-s11-test');
    assert.equal(stamped.storage_deck_id, 'fom-ch01-author-test');
    assert.equal(stamped.items[0].stem, 'Word form of 506.209');
    assert.deepEqual(stamped.items[0].accept, ['x']);
  });

  it('fails non-zero path when over hard byte cap', () => {
    const { source, out, outRoot } = packDirs();
    writeFileSync(join(source, 'index.html'), 'x'.repeat(200));
    mkdirSync(join(source, 'audio'), { recursive: true });
    writeFileSync(join(source, 'audio', 'big.mp3'), 'y'.repeat(500));
    const manifest = join(source, 'manifest.json');
    writeMinimalManifest(manifest);
    const result = packLesson({ source, out, outRoot, manifest, cap: 100 });
    assert.ok(result.bytes > 100);
    assert.ok(result.bytes > result.cap);
  });

  it('refuses --out outside scratch/ without deleting', () => {
    const { source } = packDirs();
    writeFileSync(join(source, 'index.html'), '<html></html>\n');
    const manifest = join(source, 'manifest.json');
    writeMinimalManifest(manifest);

    const victimRoot = tempDir();
    const marker = join(victimRoot, 'do-not-delete.txt');
    writeFileSync(marker, 'safe\n');

    assert.throws(
      () =>
        packLesson({
          source,
          out: join(victimRoot, 'escaped-out'),
          manifest,
          // default outRoot = SCRATCH_ROOT — victim is outside it
        }),
      /--out must be a directory under/,
    );
    assert.equal(readFileSync(marker, 'utf8'), 'safe\n');
    assert.equal(existsSync(join(victimRoot, 'escaped-out')), false);

    assert.throws(
      () => assertSafeOutDir(join(victimRoot, 'escaped-out')),
      /--out must be a directory under/,
    );
    assert.equal(resolve(SCRATCH_ROOT), resolve(REPO_ROOT, 'scratch'));
  });

  it('refuses --out under class-app tree without deleting', () => {
    const { source } = packDirs();
    writeFileSync(join(source, 'index.html'), '<html></html>\n');
    const manifest = join(source, 'manifest.json');
    writeMinimalManifest(manifest);

    const fom = join(
      CLASS_APP_ROOT,
      'notes',
      'teacher-decks',
      'fom-ch01-v4',
    );
    const indexPath = join(fom, 'index.html');
    assert.ok(
      existsSync(indexPath),
      `expected live FoM at ${indexPath} for delete-safety regression`,
    );
    const before = readFileSync(indexPath, 'utf8').slice(0, 64);

    assert.throws(
      () =>
        packLesson({
          source,
          out: fom,
          manifest,
        }),
      /class-app path|--out must be a directory under/,
    );
    assert.equal(readFileSync(indexPath, 'utf8').slice(0, 64), before);

    // Even if outRoot were wrongly pointed at class-app, refuse.
    assert.throws(
      () =>
        assertSafeOutDir(join(CLASS_APP_ROOT, 'wipe-me'), {
          outRoot: CLASS_APP_ROOT,
        }),
      /class-app path/,
    );
  });

  it('refuses --out through symlink under outRoot without deleting', () => {
    const { source } = packDirs();
    writeFileSync(join(source, 'index.html'), '<html></html>\n');
    const manifest = join(source, 'manifest.json');
    writeMinimalManifest(manifest);

    const outRoot = tempDir();
    const standInClassApp = tempDir();
    const gold = join(standInClassApp, 'fom-ch01-v4');
    mkdirSync(gold, { recursive: true });
    const marker = join(gold, 'KEEP.txt');
    writeFileSync(marker, 'GOLD\n');
    writeFileSync(join(gold, 'index.html'), 'LIVE PLAYER\n');

    // Lexically under outRoot, but parent symlink lands in stand-in class-app.
    const link = join(outRoot, 'decks');
    symlinkSync(standInClassApp, link);

    const sneakyOut = join(outRoot, 'decks', 'fom-ch01-v4');
    assert.equal(
      canonicalizePath(sneakyOut),
      canonicalizePath(gold),
      'canonicalize must follow symlink parent',
    );

    assert.throws(
      () =>
        packLesson({
          source,
          out: sneakyOut,
          outRoot,
          classAppRoot: standInClassApp,
          manifest,
        }),
      /class-app path|--out must be a directory under/,
    );

    assert.equal(readFileSync(marker, 'utf8'), 'GOLD\n');
    assert.equal(readFileSync(join(gold, 'index.html'), 'utf8'), 'LIVE PLAYER\n');
    assert.equal(existsSync(join(gold, 'manifest.json')), false);

    assert.throws(
      () =>
        assertSafeOutDir(sneakyOut, {
          outRoot,
          classAppRoot: standInClassApp,
        }),
      /class-app path|--out must be a directory under/,
    );
  });

  it('gitignore covers scratch/', () => {
    const gi = readFileSync(join(REPO_ROOT, '.gitignore'), 'utf8');
    assert.match(gi, /^scratch\/?$/m);
  });
});
