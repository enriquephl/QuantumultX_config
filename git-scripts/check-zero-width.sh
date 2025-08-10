#!/usr/bin/env bash
# Purpose: Fast zero-width char scan for GitHub Actions
# Target: ubuntu-latest runner (GNU coreutils, GNU grep)
# Chars: U+200B (ZWSP), U+200C (ZWNJ), U+200D (ZWJ), U+FEFF (BOM)
set -euo pipefail

# -------- Config (tunable via env) --------
: "${MAX_SIZE_BYTES:=5242880}"   # 5 MiB per file upper bound
# Whitelist common text/code extensions (lowercased compare)
EXT_WHITELIST=(
  txt md markdown rst
  json ndjson csv tsv ini conf cfg toml yaml yml
  xml html htm css scss less
  js mjs cjs ts tsx jsx
  py pyi
  c h cc cpp cxx hpp hh
  go rs rb php pl lua sh bash zsh fish ps1 psd1 psm1
  swift kt kts m mm cs
  java sql tf dockerfile makefile mk gradle bazel bzl
  env sample example properties snippet list
)

# Pattern for grep -P
PATTERN=$'\u200B|\u200C|\u200D|\uFEFF'

# -------- Helpers --------
lower() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

is_whitelisted_ext() {
  local fbase ext lf
  lf="$(lower "$1")"
  # special basenames w/o ext
  case "$lf" in
    makefile|dockerfile|.editorconfig|.gitattributes|.gitignore) return 0;;
  esac
  # extract extension
  fbase="${lf##*/}"
  ext="${fbase##*.}"
  [[ "$ext" != "$fbase" ]] || return 1  # no dot -> not whitelisted
  for e in "${EXT_WHITELIST[@]}"; do
    [[ "$ext" == "$e" ]] && return 0
  done
  return 1
}

# GNU stat byte size
filesize() {
  stat -c '%s' -- "$1"
}

# Collect changed files into array CHANGED[]
collect_changed_files() {
  local mode="${1:-}"
  shift || true
  local range_a range_b

  case "$mode" in
    --range)
      if [[ $# -ge 1 ]]; then
        if [[ "$1" == *..* ]]; then
          mapfile -d '' CHANGED < <(git diff --name-only -z "$1")
        else
          range_a="${1:-HEAD~1}"; range_b="${2:-HEAD}"
          mapfile -d '' CHANGED < <(git diff --name-only -z -- "$range_a" "$range_b")
        fi
      else
        mapfile -d '' CHANGED < <(git diff --name-only -z -- HEAD~1 HEAD)
      fi
      ;;
    --all)
      mapfile -d '' CHANGED < <(git ls-files -z --)
      ;;
    *)
      # Default fallback: HEAD~1..HEAD
      mapfile -d '' CHANGED < <(git diff --name-only -z -- HEAD~1 HEAD)
      ;;
  esac
}

# -------- Main --------
# 1) Collect candidates
declare -a CHANGED=()
collect_changed_files "${1:-}" "${2:-}" "${3:-}"

# 2) Filter by ext + size (performance)
declare -a CANDS=()
for f in "${CHANGED[@]}"; do
  [[ -f "$f" ]] || continue
  is_whitelisted_ext "$f" || continue
  # size guard
  sz=$(filesize "$f" || echo 0)
  (( sz <= MAX_SIZE_BYTES )) || continue
  CANDS+=("$f")
done

# No candidates -> success
((${#CANDS[@]} > 0)) || exit 0

# 3) Fast pass: grep across all candidates to detect any hits and list files
#    -I / --binary-files=without-match: skip binary
#    Use two greps:
#      a) -l to get file list (fast)
#      b) if any, pretty print with perl (exact lines)
declare -a HITFILES=()
if grep -P -I --binary-files=without-match -l "$PATTERN" -- "${CANDS[@]}" >/dev/null 2>&1; then
  # collect file list
  while IFS= read -r line; do
    HITFILES+=("$line")
  done < <(grep -P -I --binary-files=without-match -l "$PATTERN" -- "${CANDS[@]}")

  printf "\n\033[31mZero-width characters detected in %d file(s):\033[0m\n" "${#HITFILES[@]}"
  for f in "${HITFILES[@]}"; do
    printf "\033[31m- %s\033[0m\n" "$f"
  done

  # Pretty-print offending lines with visible markers
  echo
  for f in "${HITFILES[@]}"; do
    echo ">> $f"
    perl -C -ne '
      my $line = $_;
      $line =~ s/\x{200B}/⟦ZWSP⟧/g;
      $line =~ s/\x{200C}/⟦ZWNJ⟧/g;
      $line =~ s/\x{200D}/⟦ZWJ⟧/g;
      $line =~ s/\x{FEFF}/⟦BOM⟧/g;
      if ($line =~ /⟦ZWSP⟧|⟦ZWNJ⟧|⟦ZWJ⟧|⟦BOM⟧/) {
        print $. . ":" . $line;
      }
    ' -- "$f" || true
    echo
  done
  exit 1
fi

# 4) No hits
exit 0