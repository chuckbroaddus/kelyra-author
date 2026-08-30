#!/usr/bin/env node
/**
 * Pack a local lesson folder into a publish-ready output:
 * index.html + manifest.json + audio/ + img/ (backup dirs skipped).
 *
 * Does not call publish_lesson_pack. Does not ship a service-role key.
 *
 *   npm run pack
 *   npm run pack -- --source /path/to/lesson --out scratch/my-pack
 */

import {
  copyFileSync,
  existsSync,
  mkdirSync,
  readFileSync,
  readdirSync,
  realpathSync,
  rmSync,
  statSync,
  writeFileSync,
} from 'node:fs';
import {
  basename,
  dirname,
  isAbsolute,
  join,
  relative,
  resolve,
  sep,
} from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
export const REPO_ROOT = resolve(__dirname, '..');

export const BYTE_CAP = 12_304_812;

/** Pack output must stay under this root (rmSync allowlist). */
export const SCRATCH_ROOT = join(REPO_ROOT, 'scratch');

/** Never rmSync / write pack output into the class-app tree. */
export const CLASS_APP_ROOT = resolve(
  '/Users/chuckbroaddus/projects/kelyra',
);

export const DEFAULT_SOURCE =
  '/Users/chuckbroaddus/projects/kelyra/notes/teacher-decks/fom-ch01-v4';

export const DEFAULT_OUT = join(SCRATCH_ROOT, 'fom-ch01-s11-test');

export const DEFAULT_MANIFEST = join(
  REPO_ROOT,
  'docs',
  'fom-ch01-s11.manifest.json',
);

export const DEFAULT_STAMP = {
  deck_id: 'fom-ch01-s11-test',
  storage_deck_id: 'fom-ch01-author-test',
  version: 'v4',
  spec: 'kelyra.pack/1',
  kind: 'lesson',
};

/** Backup dirs never ship (publish contract). */
export const SKIP_DIR_NAMES = new Set([
  'png-original',
  'ava-original',
  'eve-staging',
]);

export function parseArgs(argv) {
  const out = {};
  for (let i = 0; i < argv.length; i++) {
    const token = argv[i];
    if (!token.startsWith('--')) continue;
    const name = token.slice(2);
    const next = argv[i + 1];
    if (!next || next.startsWith('--')) {
      out[name] = true;
    } else {
      out[name] = next;
      i++;
    }
  }
  return out;
}

/** True when target is a path strictly inside root (not root itself). */
export function isStrictlyInside(root, target) {
  const rootR = resolve(root);
  const targetR = resolve(target);
  if (targetR === rootR) return false;
  const rel = relative(rootR, targetR);
  return rel !== '' && !rel.startsWith(`..${sep}`) && rel !== '..' && !isAbsolute(rel);
}

/**
 * Realpath the nearest existing ancestor, then append missing segments.
 * Catches --out that is lexically under scratch/ but reaches class-app via symlink.
 */
export function canonicalizePath(inputPath) {
  const resolved = resolve(inputPath);
  const suffix = [];
  let probe = resolved;
  while (!existsSync(probe)) {
    const parent = dirname(probe);
    if (parent === probe) {
      return resolved;
    }
    suffix.unshift(basename(probe));
    probe = parent;
  }
  let real;
  try {
    real = realpathSync(probe);
  } catch {
    throw new Error(`cannot realpath --out ancestor: ${probe}`);
  }
  return suffix.length ? join(real, ...suffix) : real;
}

/**
 * Refuse --out outside the allowlisted root (default: repo scratch/)
 * and refuse any path in the class-app tree. Call before rmSync/write.
 * Paths are canonicalized (realpath) so symlinks under scratch/ cannot escape.
 */
export function assertSafeOutDir(
  outDir,
  { outRoot = SCRATCH_ROOT, classAppRoot = CLASS_APP_ROOT } = {},
) {
  const resolved = canonicalizePath(outDir);
  const root = canonicalizePath(outRoot);
  const classRoot = canonicalizePath(classAppRoot);

  if (root === classRoot || isStrictlyInside(classRoot, root)) {
    throw new Error(`out root refuses class-app path: ${root}`);
  }

  if (resolved === classRoot || isStrictlyInside(classRoot, resolved)) {
    throw new Error(
      `--out refuses class-app path (never delete/write under ${classRoot}): ${resolved}`,
    );
  }

  if (!isStrictlyInside(root, resolved)) {
    throw new Error(
      `--out must be a directory under ${root} (got ${resolved})`,
    );
  }

  return resolved;
}

export function isSkippedRel(rel) {
  const norm = rel.split('\\').join('/');
  if (norm.startsWith('.') || norm.includes('/.')) return true;
  const parts = norm.split('/');
  for (const part of parts) {
    if (SKIP_DIR_NAMES.has(part)) return true;
  }
  // captions/ava-original covered by SKIP_DIR_NAMES; keep explicit for clarity
  if (norm === 'captions/ava-original' || norm.startsWith('captions/ava-original/')) {
    return true;
  }
  return false;
}

export function walkFiles(root) {
  const out = [];
  function walk(dir) {
    let entries;
    try {
      entries = readdirSync(dir, { withFileTypes: true });
    } catch {
      return;
    }
    for (const entry of entries) {
      const abs = join(dir, entry.name);
      const rel = relative(root, abs).split('\\').join('/');
      if (entry.name.startsWith('.')) continue;
      if (entry.isDirectory()) {
        if (SKIP_DIR_NAMES.has(entry.name)) continue;
        walk(abs);
      } else if (entry.isFile()) {
        if (isSkippedRel(rel)) continue;
        out.push({ abs, rel });
      }
    }
  }
  walk(root);
  return out;
}

export function resolveManifestPath({ source, manifestFlag, defaultManifest }) {
  if (manifestFlag) return resolve(manifestFlag);
  const inSource = join(source, 'manifest.json');
  if (existsSync(inSource)) return inSource;
  if (defaultManifest && existsSync(defaultManifest)) return defaultManifest;
  return null;
}

export function stampManifest(base, stamp = DEFAULT_STAMP) {
  if (!base || typeof base !== 'object') {
    throw new Error('manifest must be a JSON object');
  }
  const items = Array.isArray(base.items)
    ? base.items.map((item) => {
        if (!item || typeof item !== 'object') return item;
        const next = { ...item };
        if (item.id != null) next.id = item.id;
        if (item.stem != null) next.stem = item.stem;
        return next;
      })
    : [];

  return {
    ...base,
    spec: stamp.spec ?? base.spec ?? DEFAULT_STAMP.spec,
    kind: stamp.kind ?? base.kind ?? DEFAULT_STAMP.kind,
    deck_id: stamp.deck_id ?? base.deck_id,
    storage_deck_id: stamp.storage_deck_id ?? base.storage_deck_id,
    version: stamp.version ?? base.version,
    beat_start: base.beat_start,
    beat_end: base.beat_end,
    items,
  };
}

export function totalBytes(root) {
  let sum = 0;
  for (const { abs } of walkFiles(root)) {
    sum += statSync(abs).size;
  }
  return sum;
}

/**
 * Pack source → outDir.
 * @returns {{ bytes: number, files: number, manifestPath: string, outDir: string }}
 */
export function packLesson(options = {}) {
  const source = resolve(options.source ?? DEFAULT_SOURCE);
  const outRoot = options.outRoot ?? SCRATCH_ROOT;
  const classAppRoot = options.classAppRoot ?? CLASS_APP_ROOT;
  // Validate --out before any rmSync/write (allowlist: scratch/ by default).
  const outDir = assertSafeOutDir(resolve(options.out ?? DEFAULT_OUT), {
    outRoot,
    classAppRoot,
  });
  const cap = Number(options.cap ?? BYTE_CAP);
  const stamp = {
    ...DEFAULT_STAMP,
    ...(options.deck_id ? { deck_id: options.deck_id } : {}),
    ...(options.storage_deck_id
      ? { storage_deck_id: options.storage_deck_id }
      : {}),
    ...(options.version ? { version: options.version } : {}),
    ...(options.spec ? { spec: options.spec } : {}),
    ...(options.kind ? { kind: options.kind } : {}),
  };
  const defaultManifest = options.defaultManifest ?? DEFAULT_MANIFEST;

  const indexSrc = join(source, 'index.html');
  if (!existsSync(indexSrc) || !statSync(indexSrc).isFile()) {
    throw new Error(`missing index.html in source: ${source}`);
  }

  const manifestSrc = resolveManifestPath({
    source,
    manifestFlag: options.manifest,
    defaultManifest,
  });
  if (!manifestSrc || !existsSync(manifestSrc)) {
    throw new Error(
      'missing manifest: provide --manifest, source/manifest.json, or docs/fom-ch01-s11.manifest.json',
    );
  }

  let baseManifest;
  try {
    baseManifest = JSON.parse(readFileSync(manifestSrc, 'utf8'));
  } catch (err) {
    throw new Error(`invalid manifest JSON: ${manifestSrc}: ${err.message}`);
  }

  if (options.stamp === false) {
    // keep ids from source/fixture as-is
  }
  const stamped =
    options.stamp === false ? baseManifest : stampManifest(baseManifest, stamp);

  if (!stamped.beat_start || !stamped.beat_end) {
    throw new Error('manifest missing beat_start / beat_end');
  }
  if (!Array.isArray(stamped.items) || stamped.items.length === 0) {
    throw new Error('manifest missing items');
  }
  for (const item of stamped.items) {
    if (!item?.id || item.stem == null || item.stem === '') {
      throw new Error('manifest items require id and stem');
    }
  }

  mkdirSync(dirname(outDir), { recursive: true });
  if (existsSync(outDir)) {
    rmSync(outDir, { recursive: true, force: true });
  }
  mkdirSync(outDir, { recursive: true });

  // Player as-is — do not rewrite FoM HTML.
  copyFileSync(indexSrc, join(outDir, 'index.html'));

  for (const name of ['audio', 'img']) {
    const from = join(source, name);
    if (!existsSync(from) || !statSync(from).isDirectory()) continue;
    copyTreeSkippingBackups(from, join(outDir, name));
  }

  const manifestOut = join(outDir, 'manifest.json');
  writeFileSync(manifestOut, `${JSON.stringify(stamped, null, 2)}\n`, 'utf8');

  const files = walkFiles(outDir);
  const bytes = files.reduce((sum, f) => sum + statSync(f.abs).size, 0);

  return {
    bytes,
    files: files.length,
    manifestPath: manifestOut,
    outDir,
    source,
    cap,
    stamped,
  };
}

function copyTreeSkippingBackups(fromDir, toDir) {
  mkdirSync(toDir, { recursive: true });
  for (const entry of readdirSync(fromDir, { withFileTypes: true })) {
    if (entry.name.startsWith('.')) continue;
    const src = join(fromDir, entry.name);
    const dest = join(toDir, entry.name);
    if (entry.isDirectory()) {
      if (SKIP_DIR_NAMES.has(entry.name)) continue;
      copyTreeSkippingBackups(src, dest);
    } else if (entry.isFile()) {
      mkdirSync(dirname(dest), { recursive: true });
      copyFileSync(src, dest);
    }
  }
}

export function formatPackReport(result) {
  const miB = (result.bytes / (1024 * 1024)).toFixed(2);
  const capMiB = (result.cap / (1024 * 1024)).toFixed(2);
  const lines = [
    `packed ${result.files} files → ${result.outDir}`,
    `bytes ${result.bytes} / cap ${result.cap} (${miB} MiB / ${capMiB} MiB)`,
    `deck_id=${result.stamped.deck_id} storage_deck_id=${result.stamped.storage_deck_id} version=${result.stamped.version}`,
  ];
  if (result.bytes > result.cap) {
    lines.push(`REJECT: over hard cap ${result.cap} (not a budget)`);
  } else {
    lines.push('under cap');
  }
  return lines.join('\n');
}

function main(argv = process.argv.slice(2)) {
  const args = parseArgs(argv);
  try {
    const result = packLesson({
      source: args.source ?? args.dir,
      out: args.out ?? args.output,
      manifest: args.manifest,
      deck_id: args['deck-id'],
      storage_deck_id: args['storage-deck-id'],
      version: args.version,
      spec: args.spec,
      kind: args.kind,
      cap: args.cap != null ? Number(args.cap) : undefined,
      stamp: args['no-stamp'] ? false : undefined,
      defaultManifest: args['default-manifest'],
    });
    console.log(formatPackReport(result));
    if (result.bytes > result.cap) {
      process.exitCode = 1;
      return;
    }
  } catch (err) {
    console.error(err.message || err);
    process.exitCode = 1;
  }
}

const isMain =
  process.argv[1] &&
  resolve(process.argv[1]) === fileURLToPath(import.meta.url);

if (isMain) {
  main();
}
