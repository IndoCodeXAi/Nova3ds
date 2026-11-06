#!/usr/bin/env bash
# Zip tanpa folder .git tidak membawa submodule, jadi semua Externals di-clone manual
# berdasarkan isi .gitmodules. Qt dan FFmpeg-bin dilewati (hanya untuk Windows).
set -euo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

git config -f .gitmodules --get-regexp '\.path$' | while read -r key path; do
  name="${key#submodule.}"; name="${name%.path}"
  url="$(git config -f .gitmodules --get "submodule.${name}.url")"
  branch="$(git config -f .gitmodules --get "submodule.${name}.branch" || true)"
  case "$path" in
    Externals/Qt|Externals/FFmpeg-bin) echo "skip $path"; continue ;;
  esac
  if [ -n "$(ls -A "$path" 2>/dev/null)" ]; then echo "ada: $path"; continue; fi
  echo "clone $url -> $path ${branch:+($branch)}"
  rm -rf "$path"; mkdir -p "$(dirname "$path")"
  if [ -n "$branch" ]; then
    git clone --depth 1 --branch "$branch" "$url" "$path"
  else
    git clone --depth 1 "$url" "$path"
  fi
  rm -rf "$path/.git"
done
