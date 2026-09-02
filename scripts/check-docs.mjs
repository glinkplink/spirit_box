#!/usr/bin/env node
// Documentation integrity check for the Spirit Box repository.
//
// The repository is currently a documentation/planning repo (no application
// code yet). Its value is a set of heavily cross-linked Markdown documents, so
// the one thing worth validating is that those documents stay coherent:
//   1. the canonical source-of-truth document exists;
//   2. every internal (relative) Markdown link resolves to a real file/dir.
//
// Zero dependencies: uses only the Node standard library.

import { readdirSync, statSync, readFileSync, existsSync } from "node:fs";
import { join, dirname, resolve, relative } from "node:path";
import { fileURLToPath } from "node:url";

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");

const CANONICAL_DOC = "docs/00_SPIRIT_BOX_PRODUCT_SOURCE_OF_TRUTH.md";

function listMarkdownFiles(dir) {
  const out = [];
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    if (entry.name === ".git" || entry.name === "node_modules") continue;
    const full = join(dir, entry.name);
    if (entry.isDirectory()) out.push(...listMarkdownFiles(full));
    else if (entry.name.endsWith(".md")) out.push(full);
  }
  return out;
}

// Matches Markdown inline links: [text](target)
const LINK_RE = /\[[^\]]*\]\(([^)]+)\)/g;

function isInternal(target) {
  if (/^[a-z][a-z0-9+.-]*:/i.test(target)) return false; // http:, mailto:, etc.
  if (target.startsWith("#")) return false; // in-page anchor
  return true;
}

const errors = [];

if (!existsSync(join(repoRoot, CANONICAL_DOC))) {
  errors.push(`Missing canonical source of truth: ${CANONICAL_DOC}`);
}

const mdFiles = listMarkdownFiles(repoRoot);
let checkedLinks = 0;

for (const file of mdFiles) {
  const text = readFileSync(file, "utf8");
  for (const match of text.matchAll(LINK_RE)) {
    const target = match[1].trim();
    if (!isInternal(target)) continue;
    const path = target.split("#")[0]; // strip anchor fragment
    if (path === "") continue;
    checkedLinks++;
    const resolved = resolve(dirname(file), path);
    if (!existsSync(resolved)) {
      errors.push(`${relative(repoRoot, file)} → broken link: ${target}`);
    }
  }
}

console.log(
  `Checked ${mdFiles.length} Markdown files and ${checkedLinks} internal links.`,
);

if (errors.length > 0) {
  console.error(`\nFAILED with ${errors.length} issue(s):`);
  for (const e of errors) console.error(`  - ${e}`);
  process.exit(1);
}

console.log("Documentation integrity OK.");
