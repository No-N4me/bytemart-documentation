/*
 * Per-language search for mkdocs-static-i18n + Material for MkDocs.
 *
 * Material ships one combined search index and loads it for every page, so
 * search normally returns hits in all languages. A build hook
 * (hooks/i18n_search_split.py) writes one index per language next to it:
 *   search/search_index.en.json, search/search_index.de.json, ...
 *
 * Material requests the index with XMLHttpRequest (the search Web Worker is set
 * up with importScripts, so a window.fetch patch never sees it). We therefore
 * rewrite the request URL — for both XHR and fetch, to be safe — so the current
 * page loads only its own language's index. Swapping the URL (rather than
 * rewriting the response) keeps each index a plain, cacheable static file.
 *
 * Loaded as a blocking <head> script (overrides/main.html) so the patch is in
 * place before Material's bundle requests the index.
 */
(function () {
  var KNOWN = ["en", "de", "fr", "es", "zh", "ru"];
  var lang = (document.documentElement.lang || "en").split("-")[0];
  if (KNOWN.indexOf(lang) === -1) return; // unknown language: leave default behaviour

  var INDEX_RE = /\/search\/search_index\.json(\?|$)/;
  function rewrite(urlLike) {
    var url = urlLike && urlLike.toString ? urlLike.toString() : urlLike;
    if (typeof url === "string" && INDEX_RE.test(url)) {
      return url.replace("search_index.json", "search_index." + lang + ".json");
    }
    return null;
  }

  var open = XMLHttpRequest.prototype.open;
  XMLHttpRequest.prototype.open = function (method, url) {
    var swapped = rewrite(url);
    if (swapped !== null) arguments[1] = swapped;
    return open.apply(this, arguments);
  };

  if (window.fetch) {
    var nativeFetch = window.fetch;
    window.fetch = function (input, init) {
      var target = typeof input === "string" ? input : input && input.url;
      var swapped = rewrite(target);
      if (swapped !== null) return nativeFetch.call(this, swapped, init);
      return nativeFetch.call(this, input, init);
    };
  }
})();
