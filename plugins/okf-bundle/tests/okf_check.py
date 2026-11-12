"""Test-only OKF v0.2 checks for the example bundle. Not shipped as skill tooling.

Usage: python3 okf_check.py <conformance|footnotes> <bundle-dir>
Prints one line per problem and exits 1 if any are found.
"""

import re
import sys
from datetime import date
from pathlib import Path

import yaml

LINK_ENTRY = re.compile(r"^[*-] \[[^\]]+\]\([^)]+\)")
HEADING = re.compile(r"^#{1,6} \S")
DATE_HEADING = re.compile(r"^## (\d{4}-\d{2}-\d{2})$")


def split_frontmatter(text):
    """Return (frontmatter, body). frontmatter is None if absent; raises if unclosed."""
    lines = text.split("\n")
    if lines[0] != "---":
        return None, text
    for i, line in enumerate(lines[1:], start=1):
        if line == "---":
            return "\n".join(lines[1:i]), "\n".join(lines[i + 1 :])
    raise ValueError("frontmatter block not closed")


def check_index(path, root, problems):
    fm, body = split_frontmatter(path.read_text())
    if fm is not None:
        data = yaml.safe_load(fm)
        if path.parent != root or not isinstance(data, dict) or set(data) != {"okf_version"}:
            problems.append(f"{path}: index frontmatter other than root okf_version")
    lines = [line for line in body.split("\n") if line.strip()]
    if not lines or not HEADING.match(lines[0]):
        problems.append(f"{path}: index does not start with a section heading")
    for line in lines:
        if not (HEADING.match(line) or LINK_ENTRY.match(line)):
            problems.append(f"{path}: index line is not a heading or link entry: {line}")

    # The skill treats an incomplete index as a warning; the shipped example must be complete.
    listed = set()
    for target in re.findall(r"^[*-] \[[^\]]+\]\(([^)]+)\)", body, re.M):
        resolved = (path.parent / target).resolve()
        listed.add(resolved.parent if resolved.name == "index.md" else resolved)
    for child in sorted(path.parent.iterdir()):
        is_concept = child.suffix == ".md" and child.name not in ("index.md", "log.md")
        is_subdir = child.is_dir() and any(child.rglob("*.md"))
        if (is_concept or is_subdir) and child.resolve() not in listed:
            problems.append(f"{path}: index omits {child.name}")


def check_log(path, problems):
    text = path.read_text()
    if text.startswith("---\n"):
        problems.append(f"{path}: log has frontmatter")
    dates = []
    seen_title = False
    for line in text.split("\n"):
        if line.startswith("## "):
            match = DATE_HEADING.match(line)
            try:
                dates.append(date.fromisoformat(match.group(1)).isoformat())
            except (AttributeError, ValueError):
                problems.append(f"{path}: non-ISO date heading: {line}")
        elif line.startswith("# ") and not seen_title and not dates:
            seen_title = True
        elif line.startswith("# "):
            problems.append(f"{path}: heading breaks the flat date groups: {line}")
        elif not dates and line.strip():
            problems.append(f"{path}: entry outside a date group: {line}")
    if not dates:
        problems.append(f"{path}: log has no date groups")
    if dates != sorted(set(dates), reverse=True):
        problems.append(f"{path}: date groups are not unique and newest first")


def check_concept(path, problems):
    try:
        fm, _ = split_frontmatter(path.read_text())
        data = yaml.safe_load(fm) if fm is not None else None
    except (ValueError, yaml.YAMLError) as err:
        problems.append(f"{path}: unparseable frontmatter: {err}")
        return
    if not isinstance(data, dict):
        problems.append(f"{path}: missing frontmatter")
        return
    value = data.get("type")
    if not isinstance(value, str) or not value.strip():
        problems.append(f"{path}: missing or empty type")


def conformance(root):
    problems = []
    for path in sorted(root.rglob("*.md")):
        if path.name == "index.md":
            check_index(path, root, problems)
        elif path.name == "log.md":
            check_log(path, problems)
        else:
            check_concept(path, problems)
    return problems


def footnotes(root):
    problems = []
    for path in sorted(root.rglob("*.md")):
        if path.name in ("index.md", "log.md"):
            continue
        fm, body = split_frontmatter(path.read_text())
        data = yaml.safe_load(fm) or {}
        ids = {s.get("id") for s in data.get("sources") or [] if isinstance(s, dict)}
        definition = re.compile(r"^\[\^([^\]]+)\]:.*$", re.M)
        defined = set(definition.findall(body))
        cited = set(re.findall(r"\[\^([^\]]+)\]", definition.sub("", body)))
        for label in sorted(cited - defined):
            problems.append(f"{path}: footnote [^{label}] has no definition")
        for label in sorted((cited | defined) - ids):
            problems.append(f"{path}: footnote [^{label}] matches no sources id")
    return problems


if __name__ == "__main__":
    check = {"conformance": conformance, "footnotes": footnotes}[sys.argv[1]]
    found = check(Path(sys.argv[2]).resolve())
    print("\n".join(found))
    sys.exit(1 if found else 0)
