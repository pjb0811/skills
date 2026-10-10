#!/usr/bin/env bash
# Link every skill in this repository into ~/.claude/skills.
# A real directory already at the target is moved to ~/.claude/skills-backup/<timestamp>/ first,
# outside the skills directory so Claude Code doesn't load it as a duplicate skill.
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target_dir="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
backup_dir="${CLAUDE_SKILLS_BACKUP_DIR:-$HOME/.claude/skills-backup}/$(date +%Y%m%d%H%M%S)"

mkdir -p "$target_dir"

for skill in "$repo_dir"/*/; do
  skill="${skill%/}"
  name="$(basename "$skill")"

  if [[ ! -f "$skill/SKILL.md" ]]; then
    continue
  fi

  link="$target_dir/$name"

  if [[ -L "$link" ]]; then
    if [[ "$(readlink "$link")" == "$skill" ]]; then
      echo "ok      $name"
      continue
    fi

    rm "$link"
  elif [[ -e "$link" ]]; then
    mkdir -p "$backup_dir"
    mv "$link" "$backup_dir/$name"
    echo "backup  $name -> $backup_dir/$name"
  fi

  ln -s "$skill" "$link"
  echo "linked  $name"
done
