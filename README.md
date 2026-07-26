# Bytemart Documentation

Source for [docs.bytemart.net](https://docs.bytemart.net) — the documentation for
Bytemart's ARK: Survival Evolved server plugins.

Built with [MkDocs](https://www.mkdocs.org/) and
[Material for MkDocs](https://squidfunk.github.io/mkdocs-material/), and published
to GitHub Pages automatically on every push to `main`
(see [`.github/workflows/deploy-docs.yml`](.github/workflows/deploy-docs.yml)).

## Local development

```bash
pip install -r requirements.txt
mkdocs serve
```

The site is then available at <http://127.0.0.1:8000>. Run `mkdocs build --strict`
before pushing — that is what CI runs, and it fails on broken links.

## Layout

| Path | Purpose |
| ---- | ------- |
| `docs/` | Page content. `mkdocs.yml`'s `nav` controls what is published and in what order. |
| `docs/stylesheets/bytemart.css` | The Bytemart theme layered on top of Material. |
| `docs/javascripts/i18n-search.js` | Scopes site search to the current language. |
| `overrides/` | Template overrides — the "back to bytemart.net" header button, and the script tag for the search filter. |
| `hooks/i18n_search_split.py` | Build hook that splits the search index into one file per language. |

## Translations

Translations use [mkdocs-static-i18n](https://ultrabug.github.io/mkdocs-static-i18n/)
in **suffix** mode: a translation lives next to the original with a locale suffix, so
`plugins/index.md` is translated by `plugins/index.de.md`, `plugins/index.fr.md`, and
so on. Supported locales are `en` (default), `de`, `fr`, `es`, `zh`, and `ru`.

Pages with no translation fall back to the English version, so adding a new page in
English alone is safe — it will simply appear untranslated until a suffixed file is
added beside it.

Add a page by creating the English file and adding it to `nav` in `mkdocs.yml`.
Leave `nav` entries **without** an explicit title: the title is then taken from each
translation's own `# H1` rather than being pinned to English.
