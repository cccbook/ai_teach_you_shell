# Build tooling

This directory builds the Markdown sources into a static **HTML site** and
per-language **EPUB** files using [pandoc](https://pandoc.org/).

## Files

| File | Purpose |
|------|---------|
| `build.sh` | Main build script → outputs everything to `../dist/` |
| `languages.tsv` | Language metadata (code, name, EPUB language code, native label) |
| `style.css` | Shared stylesheet for the generated HTML pages |

## Build locally

Requires `bash` and `pandoc` (>= 2.9):

```bash
# macOS:  brew install pandoc
# Ubuntu: sudo apt-get install -y pandoc

bash scripts/build.sh
```

Output (all under `dist/`, which is git-ignored):

```
dist/index.html          landing page linking every language
dist/<lang>/index.html   single-page HTML book per language
dist/<lang>/book.epub    EPUB per language
dist/epub/*.epub         all EPUBs (friendly names, for release assets)
```

Preview the site:

```bash
python3 -m http.server -d dist 8000   # then open http://localhost:8000
```

## Automated publishing

`.github/workflows/build.yml` rebuilds on every push to `main`/`master`:

- deploys the HTML site to **GitHub Pages**
- uploads the EPUBs as **workflow artifacts**

To enable it, in the repository settings turn on **Settings → Pages →
Build and deployment → Source: GitHub Actions**.

## Adding a language

1. Create a `<code>/` folder with a `README.md` (table of contents, first
   `# H1` line is used as the book title) and numbered chapters `NN-*.md`.
2. Add a row to `languages.tsv`.

That's it — the build discovers chapters automatically by sorting the
numbered files.
