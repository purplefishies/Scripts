#!/bin/bash

# Skip certain file types
case "$1" in
   *CMakeLists.txt|CMakePresets*)
       ;;
   *.csv|*.tsv|*.CSV|*.TSV|*.txt|*.TXT)
       cat "$1"
       exit 0
       ;;
esac

if command -v pygmentize >/dev/null; then
    if [[ -f "$1" && -r "$1" ]]; then
        # Default style options
        EXTRA=""
        [[ -n "${PYGMENTIZE_STYLE}" ]] && EXTRA="-O style=${PYGMENTIZE_STYLE}"

        # Default terminal format is terminal16m if not set
        : "${PYGMENTIZE_TERMINAL:=terminal16m}"

        pygmentize -f "$PYGMENTIZE_TERMINAL" $EXTRA -g "$1"
    fi
fi


