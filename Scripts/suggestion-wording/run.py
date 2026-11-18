#!/usr/bin/env python3
"""Write every sample suggestion card with the on-device model, all together.

Uses Apple's `fm` command-line tool, so nothing runs in Xcode.

    python3 Scripts/suggestion-wording/run.py        # all eight cases
    python3 Scripts/suggestion-wording/run.py 0 5    # only cases 0 and 5

The instructions, the action, detail and reason lines, and the sample cases are
read straight from the Swift files, so a change to the prompt in Swift is
picked up on the next run. The one copy kept here is `schema.json`: it
mirrors the guides in `SuggestionCopy.swift` and must be edited by hand
when those change.
"""

import json
import re
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
WRITING = HERE.parent.parent / "FitTap" / "Coaching" / "Writing"

prompt_source = (WRITING / "SuggestionPrompt.swift").read_text()
playground_source = (WRITING / "SuggestionWritingPlayground.swift").read_text()


def instructions() -> str:
    """The text of `SuggestionPrompt.instructions`, without its indentation."""
    body = re.search(r'static let instructions = """\n(.*?)\n        """', prompt_source, re.S).group(1)
    return "\n".join(line[8:] if line.startswith("        ") else line for line in body.split("\n"))


def lines_per_suggestion(function: str) -> dict:
    """The `case .x: "..."` lines of one of the prompt's switch functions."""
    body = prompt_source[prompt_source.index("func " + function):]
    body = body[: body.index("\n    }\n")]
    return dict(re.findall(r'case \.(\w+): "(.*)"', body))


actions = lines_per_suggestion("action")
details = lines_per_suggestion("detail")
reasons = lines_per_suggestion("reason")
samples = re.findall(r'\.init\(suggestion: \.(\w+), weight: "(.*)"\)', playground_source)
wanted = sys.argv[1:]

for index, (suggestion, weight) in enumerate(samples):
    if wanted and str(index) not in wanted:
        continue

    action = actions[suggestion].replace("\\(weight)", weight)
    prompt = f"Action: {action}\nDetail: {details[suggestion]}\nWhy: {reasons[suggestion]}"
    result = subprocess.run(
        ["fm", "respond", "--no-stream", "-i", instructions(), "--schema", str(HERE / "schema.json"), prompt],
        capture_output=True,
        text=True,
    )
    output = re.sub(r"\x1b\[[0-9;]*m", "", result.stdout + result.stderr).strip()

    print(f"{index} {suggestion}")
    try:
        copy = json.loads(output)
        print(f"   title:   {copy['title']}")
        print(f"   message: {copy['message']}")
    except (json.JSONDecodeError, KeyError):
        print(f"   FAILED:  {output[-300:]}")
    print()
