#!/bin/bash

set -euo pipefail

MODULE=""

usage() {
  cat <<'EOF'
Usage:
  ./generate-docs.sh
  ./generate-docs.sh --all
  ./generate-docs.sh --module <module_name>

Notes:
  - Default behavior (no args) is to regenerate docs for all modules.
  - --all is an explicit alias for the default behavior.
EOF
}

generate_module_docs() {
  local module_dir="$1"

  if [[ ! -d "${module_dir}" ]]; then
    echo "Module directory not found: ${module_dir}"
    exit 1
  fi

  if [[ ! -f "${module_dir}/base.md" ]]; then
    echo "Missing required file: ${module_dir}/base.md"
    exit 1
  fi

  echo "Generating for ${module_dir}"
  pushd "${module_dir}" > /dev/null
  cat base.md > README.md
  terraform-docs markdown --hide-empty table . >> README.md
  popd > /dev/null
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --module)
      MODULE="${2:-}"
      shift
      shift
      ;;
    --all)
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    -*|--*)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
    *)
      echo "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ -n "${MODULE}" ]]; then
  generate_module_docs "modules/${MODULE}"
  exit 0
fi

echo "Generating docs for all modules"
for module_dir in modules/*; do
  if [[ -d "${module_dir}" ]]; then
    generate_module_docs "${module_dir}"
  fi
done
