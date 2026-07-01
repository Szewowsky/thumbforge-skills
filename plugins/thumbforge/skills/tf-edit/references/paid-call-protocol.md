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
pnpm cli edit \
  --session <sessionId> \
  --image <imageId> \
  --instruction "<instruction>"
```

Real run shape after explicit approval:

```bash
THUMBFORGE_ALLOW_PAID_CALLS=1 pnpm cli edit \
  --session <sessionId> \
  --image <imageId> \
  --instruction "<instruction>" \
  --guide <annotation-doc.json> \
  --out "$HOME/Downloads/<edit-slug>" \
  --confirm
```

If the CLI cannot resolve the session, image, guide document, output directory,
API key, or cost estimate, stop before asking for paid consent.
