#!/usr/bin/env bash

[[ -z "$1" ]] && echo "USAGE: $0 NOTES_DIRECTORY" && exit 0

function _render {
	echo "rendering $1"
	pandoc\
		--toc\
		--standalone\
		-t html\
		--template /opt/gen_notes/templates/article.html\
		-o "$(dirname "$1")/index.html"\
		"$1"\
		--mathjax
}

function _renderindex {
	echo "rendering $1"
	pandoc\
		-t html\
		--template /opt/gen_notes/templates/index.html\
		-o index.html\
		"$1"
}

function _addtolist {
	echo "adding $1 to list of notes"
	pandoc\
		-t html\
		-V "filepath=$(dirname "$1")"\
		--template /opt/gen_notes/templates/listitem.html\
		"$1"\
		>> index.md
}

export -f _render
export -f _addtolist

#render each markdown file

for var in "$@"
do
	find "$var" -name '*.md' -exec bash -c "_render '{}'" \;
done

# create an intermediate markdown file of links to each article
echo "---
title: alv's notes
---" > index.md

for var in "$@"
do
	echo "<h1>$var notes</h1>" >> index.md
	find "$var" -name '*.md' -exec bash -c "_addtolist '{}'" \;
done

_renderindex index.md

echo "copying styles.css to current directory"
cp /opt/gen_notes/styles.css .
