"""Split the combined Material search index into one file per language.

mkdocs-static-i18n emits a single `search/search_index.json` containing every
language's documents (default language with no path prefix, others under
`de/`, `fr/`, ... — this requires `reconfigure_search: false` so the fallback
pages are indexed under each prefix). Material loads that one index for every
page, so search returns hits in all languages.

This post-build hook writes `search/search_index.<lang>.json` for each language,
each holding only that language's docs. `docs/javascripts/i18n-search.js` then
rewrites Material's index request to the file matching the current page's
language, so each language only searches its own content.
"""

import json
import os

from mkdocs.plugins import event_priority

# Non-default language folders (default language lives at the root, unprefixed).
PREFIXES = ["de", "fr", "es", "zh", "ru"]
DEFAULT = "en"


def _language_of(location):
    segment = location.split("/", 1)[0]
    return segment if segment in PREFIXES else DEFAULT


@event_priority(-100)  # run after the search plugin has written the index
def on_post_build(config, **kwargs):
    index_path = os.path.join(config["site_dir"], "search", "search_index.json")
    if not os.path.exists(index_path):
        return

    with open(index_path, encoding="utf-8") as fh:
        data = json.load(fh)

    base_config = data.get("config", {})
    buckets = {lang: [] for lang in [DEFAULT] + PREFIXES}
    for doc in data.get("docs", []):
        buckets[_language_of(doc.get("location", ""))].append(doc)

    for lang, docs in buckets.items():
        out_path = os.path.join(
            config["site_dir"], "search", "search_index.%s.json" % lang
        )
        with open(out_path, "w", encoding="utf-8") as fh:
            json.dump({"config": base_config, "docs": docs}, fh, ensure_ascii=False)
