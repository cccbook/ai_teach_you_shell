#!/usr/bin/env bash
#
# Build the "Let AI teach you shell" e-book into a static HTML site and
# per-language EPUB files, using pandoc.
#
# Output layout (all under ./dist):
#   dist/index.html            landing page linking every language
#   dist/<lang>/index.html     single-page HTML book for that language
#   dist/<lang>/book.epub      EPUB for that language
#   dist/epub/<title>.epub     copies of every EPUB, for easy release upload
#   dist/style.css             shared stylesheet
#
# Requirements: bash, pandoc (>= 2.9)
#
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_DIR="$ROOT_DIR/scripts"
DIST="$ROOT_DIR/dist"
AUTHOR="cccbook (https://github.com/cccbook/ai_teach_you_shell)"

command -v pandoc >/dev/null 2>&1 || { echo "error: pandoc is required" >&2; exit 1; }

echo "==> Cleaning $DIST"
rm -rf "$DIST"
mkdir -p "$DIST/epub"
cp "$SCRIPT_DIR/style.css" "$DIST/style.css"

# Collect landing-page rows here.
LANDING_ROWS=""

# Read language metadata (skip comment/blank lines).
while IFS=$'\t' read -r code display epublang native; do
  [ -z "${code:-}" ] && continue
  case "$code" in \#*) continue ;; esac

  SRC="$ROOT_DIR/$code"
  [ -d "$SRC" ] || { echo "warn: skipping missing dir $code" >&2; continue; }

  # Book title = first H1 of the language README.
  title="$(head -n 1 "$SRC/README.md" | sed 's/^#\{1,6\}[[:space:]]*//')"

  # Ordered chapter list: numbered files only (README is the TOC, excluded).
  mapfile -t chapters < <(find "$SRC" -maxdepth 1 -name '[0-9]*.md' | sort)
  [ "${#chapters[@]}" -gt 0 ] || { echo "warn: no chapters in $code" >&2; continue; }

  echo "==> Building [$code] $title (${#chapters[@]} chapters)"
  outdir="$DIST/$code"
  mkdir -p "$outdir"

  # --- HTML (single page, self-contained navigation) ---
  pandoc "${chapters[@]}" \
    --from=gfm \
    --to=html5 \
    --standalone \
    --toc --toc-depth=2 \
    --css="../style.css" \
    --metadata title="$title" \
    --metadata lang="$epublang" \
    --highlight-style=tango \
    -V "document-css=false" \
    --include-before-body=<(cat <<HTML
<nav class="book-nav"><a href="../index.html">&larr; All languages</a> &nbsp;|&nbsp; <a href="book.epub">Download EPUB</a></nav>
HTML
) \
    -o "$outdir/index.html"

  # --- EPUB ---
  # gfm does not parse YAML metadata blocks, so pass metadata via flags.
  pandoc "${chapters[@]}" \
    --from=gfm \
    --to=epub3 \
    --toc --toc-depth=2 \
    --metadata title="$title" \
    --metadata lang="$epublang" \
    --metadata creator="$AUTHOR" \
    --metadata publisher="cccbook" \
    --metadata rights="See repository LICENSE" \
    -o "$outdir/book.epub"

  # Copy EPUB under a friendly name for release assets.
  cp "$outdir/book.epub" "$DIST/epub/ai_teach_you_shell-$code.epub"

  LANDING_ROWS+="<tr><td><strong>$native</strong><br><span class=\"muted\">$display</span></td>"
  LANDING_ROWS+="<td>$title</td>"
  LANDING_ROWS+="<td><a href=\"$code/index.html\">Read online</a></td>"
  LANDING_ROWS+="<td><a href=\"$code/book.epub\">EPUB</a></td></tr>"$'\n'
done < "$SCRIPT_DIR/languages.tsv"

# --- Landing page ---
echo "==> Writing landing page"
cat > "$DIST/index.html" <<HTML
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Let AI teach you shell</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
<h1>Let AI teach you shell</h1>
<blockquote>A book for human programmers &mdash; read online or download as EPUB.</blockquote>
<p>Source: <a href="https://github.com/cccbook/ai_teach_you_shell">github.com/cccbook/ai_teach_you_shell</a></p>
<table>
<thead><tr><th>Language</th><th>Title</th><th>Web</th><th>E-book</th></tr></thead>
<tbody>
$LANDING_ROWS
</tbody>
</table>
<p class="muted" style="margin-top:2rem">Generated with pandoc. Rebuilt automatically on every push.</p>
</body>
</html>
HTML

# .nojekyll so GitHub Pages serves files verbatim.
touch "$DIST/.nojekyll"

echo "==> Done. Output in: $DIST"
ls -la "$DIST"
