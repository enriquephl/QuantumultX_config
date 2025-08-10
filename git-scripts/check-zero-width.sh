#!/usr/bin/env bash
set -euo pipefail

PATTERN=$'\u200B|\u200C|\u200D|\uFEFF'

red() { printf "\033[31m%s\033[0m\n" "$*"; }
yellow() { printf "\033[33m%s\033[0m\n" "$*"; }

is_text_file() {
  local f="$1"
  [[ -f "$f" ]] || return 1
  file -I "$f" 2>/dev/null | grep -qi 'charset=' || return 0
  file -I "$f" 2>/dev/null | grep -qiE 'charset=(us-ascii|utf-8|iso-8859-|utf-16|utf-32)' 
}

scan_files() {
  local found=0
  for f in "$@"; do
    if is_text_file "$f"; then
      if grep -P -n "$PATTERN" "$f" >/dev/null 2>&1; then
        red "❌ Zero-width characters found in: $f"
        perl -C -ne '
          s/\x{200B}/⟦ZWSP⟧/g;
          s/\x{200C}/⟦ZWNJ⟧/g;
          s/\x{200D}/⟦ZWJ⟧/g;
          s/\x{FEFF}/⟦BOM⟧/g;
          print $. . ":" . $_;
        ' "$f" | grep -nE 'ZWSP|ZWNJ|ZWJ|BOM' || true
        found=1
      fi
    fi
  done
  return $found
}

mode="${1:-}"
shift || true

case "$mode" in
  --staged)
    mapfile -t files < <(git diff --cached --name-only --diff-filter=ACM)
    ;;
  --last-commit)
    mapfile -t files < <(git diff --name-only HEAD~1 HEAD)
    ;;
  --range)
    if [[ $# -ge 1 ]]; then
      if [[ "$1" == *..* ]]; then
        mapfile -t files < <(git diff --name-only "$1")
      else
        a="${1:-HEAD~1}"; b="${2:-HEAD}"
        mapfile -t files < <(git diff --name-only "$a" "$b")
      fi
    else
      yellow "[check-zero-width] No range provided; defaulting to HEAD~1..HEAD"
      mapfile -t files < <(git diff --name-only HEAD~1 HEAD)
    fi
    ;;
  --all)
    mapfile -t files < <(git ls-files)
    ;;
  *)
    yellow "[check-zero-width] No mode specified; defaulting to --staged"
    mapfile -t files < <(git diff --cached --name-only --diff-filter=ACM)
    ;;
esac

((${#files[@]:-0} == 0)) && exit 0

if ! scan_files "${files[@]}"; then
  exit 1
fi