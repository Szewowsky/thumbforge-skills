# Paid-call protocol for tf-edit

`tf-edit` is paid only on the real edit step. The default command path is a
dry-run and must stay free.

The real edit needs all three locks at once:

1. `THUMBFORGE_ALLOW_PAID_CALLS=1` inline on the same command.
2. `--confirm`.
3. A prior dry-run that showed the edit plan and estimated cost.

Consent is per call. A failed edit, retry, or revised instruction needs a fresh
approval before another real run. Keep `THUMBFORGE_ALLOW_PAID_CALLS=1` inline;
do not export it or place it in persistent env files.

Dry-run shape:

```bash
thumbforge edit \
  --session <sessionId> \
  --image <imageId> \
  --instruction "<instruction>"
```

`thumbforge edit --help` discovers flags accepted by the thin client;
`thumbforge inventory` shows the client model catalog. Inventory alone does not
prove account access or edit support in an older app. The dry-run is the live
capability check and refuses an older app
before a positive plan or POST. Documentation recommendation: Sunburst for
precise edits, Flare for fast daily iterations.

Real run shape after explicit approval:

```bash
THUMBFORGE_ALLOW_PAID_CALLS=1 thumbforge edit \
  --session <sessionId> \
  --image <imageId> \
  --instruction "<instruction>" \
  --guide <annotation-doc.json> \
  --out "$HOME/Downloads/<slug>" --out-name <slug> \
  --confirm
```

`<slug>` to Slug odcinka z podsumowania dry-runu (ten sam, którego użyły
generacje odcinka), więc kopia edycji ląduje obok nich jako kolejny
`<slug>-<n>.png` i niczego nie nadpisuje.

If the CLI cannot resolve the session, image, guide document, output directory,
API key, or cost estimate, stop before asking for paid consent.
