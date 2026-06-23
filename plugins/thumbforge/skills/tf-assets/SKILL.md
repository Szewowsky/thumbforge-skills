---
name: tf-assets
description: >-
  Manage the thumbforge reference-image library — list what's there and add new
  assets. Use when Robert wants to see or grow the pool of reference images that
  the other skills compose into thumbnails: "/tf-assets", "pokaż moje
  referencje/assety", "jakie mam ikony/refy", "dodaj ikonę/logo do thumbforge",
  "wgraj moją twarz", "dodaj referencję z tego pliku", "ściągnij to logo i dodaj
  jako ref". It lists refs grouped by category (with a visual preview on request)
  and adds new ones from a local file or a URL. This is FREE — no model call, no
  paid lock. NOT for generating thumbnails (tf-generate), cloning a competitor's
  thumbnail into a preset (tf-reverse), or turning a scenario into slots
  (tf-scenario) — but it pairs with them: the refs you add here are exactly what
  those skills feed to the image model.
argument-hint: "[list | add <file-or-url>] [--category <c>] [--name <label>]"
allowed-tools: Bash, Read
---

# tf-assets

The reference library (`public/references/<category>/<id>.png`) is the pool of
images the generator composes into thumbnails: the host's face, a guest face,
logos/app icons, screenshots, inspiration thumbnails. This skill lists and adds
them. Both operations are **free** — `list-refs` reads disk, `upload-ref` writes
a file; neither calls a model or touches an API key. No dry-run / `--confirm` /
env needed.

## Step 0 — Bootstrap

```bash
cd "/Users/robert/Windsurf Projekty/thumbforge"
thumbforge --help            # CLI reachable? (free)
```

No `THUMBFORGE_SECRET`, no `THUMBFORGE_ALLOW_PAID_CALLS`, no `--confirm` — these
commands cost nothing. If you ever reach for a paid command, you're in the wrong
skill (see Routing in the `thumbforge` umbrella).

## Categories

| category | what goes here |
|---|---|
| `character-primary` | the host's face (this account's primary on-camera person) |
| `character-secondary` | a guest / persona face (second subject in two-subject presets) |
| `icon` | logos, app icons, mascots |
| `screen` | screenshots, UI captures |
| `inspiration` | style/layout references — **not** for facial identity |
| `other` | anything else (default) |

What you list here is exactly the per-account reference inventory that the other
`tf-*` skills must discover (via `list-refs`) before proposing — see
`../thumbforge/references/discovery-contract.md`.

Custom categories are allowed if they match `^[a-z][a-z0-9-]{0,31}$`, but prefer
the known ones — the resolver and presets key off them (faces → `character`,
logos → `icon`). Pick the category from intent: a face → `character-primary`
(host) or `character-secondary` (guest); a logo/app → `icon`; a screenshot →
`screen`; a competitor thumbnail kept for style → `inspiration`.

## Workflow — list

```bash
thumbforge list-refs                      # everything, grouped by category
thumbforge list-refs --category icon      # one category
pnpm cli refs:rethumb --category character-primary  # repo/dev-only: rebuild display thumbs
pnpm cli refs:contact-sheet --category character-primary --out /tmp/thumbforge-ref-sheets  # repo/dev-only: visual sheet
```

Output is `category · count` then `id  path  · name`. Summarize for the user
grouped by category (name + what it's for); don't dump raw ULIDs as a wall.

**Visual preview (on request):** thumbnails live next to each ref as
`<id>_thumb.png`. In thin-client mode, use `thumbforge list-refs` as the index
and inspect candidate thumbs directly. In repo/dev only, run `refs:contact-sheet`
and inspect the written PNG. If face thumbnails look stale or center-cropped, run
`pnpm cli refs:rethumb --category character-primary` (repo/dev-only; or
`character-secondary`) to rebuild only `_thumb.png` with the current face-aware
crop. The original `<id>.png` paths stay untouched.

## Workflow — add

**From a local file:**

```bash
thumbforge upload-ref --file "/ABS/path/to/image.png" --category icon --name "ChatGPT logo"
```

**From a URL** (download first — `upload-ref` only takes a local `--file`):

```bash
curl -fsSL "<image-url>" -o /tmp/tf-new-ref.png
file /tmp/tf-new-ref.png            # sanity-check it's actually an image
thumbforge upload-ref --file /tmp/tf-new-ref.png --category icon --name "<label>"
```

`upload-ref` accepts PNG/JPEG/WebP and prints `✓ ref <id> (<category>) → <path>`.
Deliver that path + a one-line note; the ref is immediately usable — pass the
printed `/references/...` path to `--refs` in `tf-generate`.

## Load-bearing notes

- **Paths are immutable forever.** Sessions store the exact `/references/<cat>/<id>.png`
  path; renaming or moving the file on disk breaks session retry. To relabel, use
  the display `--name` (a companion meta file) — never move the PNG.
- **`refs:rethumb` is display-only.** It regenerates `_thumb.png` previews for the
  library/contact-sheet flow and never changes the original reference image.
- **`refs:contact-sheet` is display-only.** It composes existing `_thumb.png`
  previews into a labeled PNG for visual choice; it never changes refs.
- **`character-primary` = the host.** In two-subject presets (`collab-duo`,
  `host-plus-persona`) the host is the first ref; the guest is `character-secondary`.
- **`inspiration` is style only** — never facial identity. Don't add a face there.
- Adding a ref makes it available to `tf-generate` / `tf-reverse` immediately; no
  rebuild needed.

## Errors

- `invalid category` → must match `^[a-z][a-z0-9-]{0,31}$`; use a known category.
- `file not found` → give `upload-ref` an absolute path.
- not an image → `upload-ref` wants PNG/JPEG/WebP; re-check the download.

## Cienki klient (tester) i tryb dev

Komendy w tym skillu wołają **`thumbforge`** — cienki klient HTTP. U testera z samą
aplikacją (.dmg, bez repo) `thumbforge` jest wbudowany w apkę (instalacja: ikona w
tray → „Zainstaluj CLI"). W repozytorium (dev) `thumbforge` to launcher do
bezpośredniego CLI — raz wykonaj `pnpm link --global` (albo używaj równoważnego
`pnpm cli <komenda>`).

Cienki klient wspiera: `list-presets`, `list-refs`, `list-styles`, `inventory`, `cost-estimate`, `generate`, `reverse`, `analyze-transcript`, `preset:create`, `preset:show`, `preset:edit`, `style:create`, `style:edit`, `style:delete`, `upload-ref`, `grid`.
Modele sprawdzaj przez `thumbforge inventory` zamiast repo/dev-only `list-models`.
Komendy `edit`, `retry`, `eval`, `list-models`, `refs:contact-sheet`, `refs:rethumb`, `preset:preview`, `preset:slots`, `preset:delete`
są **repo/dev-only** (`pnpm cli <komenda>`) — cienki klient zwraca fail-fast
„dostępne tylko w trybie repo (dev)".
