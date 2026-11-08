#!/usr/bin/env python3
"""Download Deezer cover images for the isolated screenshot fixture."""
import json
import pathlib
import sys
import urllib.parse
import urllib.request

QUERIES = [
    "Rumours Fleetwood Mac",
    "Abbey Road The Beatles",
    "Thriller Michael Jackson",
    "Heroes David Bowie",
    "Space Oddity David Bowie",
]

if len(sys.argv) != 2:
    raise SystemExit("Usage: python3 tool/fetch_screenshot_covers.py OUTPUT_DIR")

destination = pathlib.Path(sys.argv[1])
destination.mkdir(parents=True, exist_ok=True)
for index, query in enumerate(QUERIES):
    url = "https://api.deezer.com/search/album?" + urllib.parse.urlencode({"q": query})
    with urllib.request.urlopen(url, timeout=20) as response:
        results = json.load(response)["data"]
    if not results:
        raise RuntimeError(f"No Deezer album found for {query!r}")
    album = results[0]
    with urllib.request.urlopen(album["cover_big"], timeout=20) as response:
        image = response.read()
    (destination / f"{index}.jpg").write_bytes(image)
    print(f"{index}: {album['artist']['name']} — {album['title']}: {album['cover_big']}")
