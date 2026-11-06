# video-3d-skill

A [Claude Code](https://claude.com/claude-code) skill that routes a video/3D production job between
Three.js, Blender/Cycles, AI video models, or a hybrid of them, then gives the working recipes,
resilience rules, and verification checks for each path.

## What it is

`skill/` is the installable skill, named `video-3d-production` in its own frontmatter. It helps an
agent (or a person) answer "how should I actually build this" for a video/3D deliverable — an
explainer, a cinematic shot, a social cut — and then carries that choice through to a finished,
verified file:

- **Three.js**, when the job needs an interactive page and a film from the same model, with every
  number on screen guaranteed to match the motion.
- **Blender/Cycles**, when the job needs physically based light and exact geometry, with the
  resilience rules (chunking, resume, a stall watchdog) a multi-hour unattended render needs on a
  single machine.
- **AI video models**, when the job needs atmospheric, texture-rich motion that doesn't need to be
  exact — gated behind an explicit cost approval, never called automatically.
- **Hybrids** of the above, ranked by how well each one is actually documented to work.

Supporting references cover assembling heterogeneous pieces (Three.js + Blender + captions + audio)
into one final file, and the metrics/honesty discipline used throughout: log wall-clock time, log
what failed, say "not logged" instead of guessing.

## Who it's for

Anyone using Claude Code (or adapting the same instructions for another agent) who needs to decide
between Three.js, Blender, and AI video for a concrete deliverable, and wants working recipes rather
than a product comparison.

## Install

```bash
git clone <this-repo-url> video-3d-skill
ln -s "$PWD/video-3d-skill/skill" ~/.claude/skills/video-3d-production
```

The skill's own name (in `skill/SKILL.md`'s frontmatter) is `video-3d-production`; the symlink name
must match that for Claude Code to pick it up by name.

## Honest scope

This skill is explicit, throughout, about what's measured versus what's research:

- The **Three.js and Blender** guidance is measured on **one** real project — "The Wheels of Ezekiel"
  (Three.js console + a Blender/Cycles film of the same subject). Write-up:
  https://renanspatin.com/en/blog/ofanim-ezequiel. The underlying numbers are copied into
  `evidence/` (see below) so claims can be checked against a real file, not just trusted.
- The **AI video** guidance (`skill/references/ai-video.md`) is **research, dated 2026-11-06, and was
  never executed by the author** — no paid generation call was ever made for this or any project.
  Treat it as a literature review, not field experience. The model landscape in this space moves
  fast; expect it to be stale soon after the research date.
- Prices quoted for AI video models mostly come from resellers and aggregators, not each vendor's own
  current pricing page, and drift quickly. Verify current pricing before budgeting anything.
- **Hard cost rule:** never call a paid generation endpoint (Veo/Omni, Kling, Runway, Luma, Hailuo,
  Seedance, or any other API billed per second or credit) without the user's explicit, specific
  approval of the expected cost first. This rule is enforced in the skill's own instructions, not just
  stated here.
- A single Blender process at a time, always — running two at once is documented here to hang both.

## Contents

### `skill/references/`

| File | Covers |
|---|---|
| `threejs-teardown.md` | Building an interactive explainer + film from one Three.js model; capture pipeline; caption/wheel collision checks; honest limits |
| `blender-headless.md` | Running Blender headless on Apple Silicon; Cycles/Metal + denoising setup; resilience rules for multi-hour unattended renders; measured cost levers; recipes that worked and failed |
| `ai-video.md` | AI video model landscape as of 2026-11-06; what AI video is good/bad at; documented hybrid pipelines; disclosure/ethics notes; the cost-gate check command |
| `assembly.md` | Assembling Three.js + Blender + captions + audio into one final muxed video; the `-loop 1` caption bug; hard cuts vs. dissolves; two-pass loudness normalization |
| `metrics-and-honesty.md` | The discipline behind every number in the other reference files: wall-clock logging, honest flaws lists, "not logged" over a guess |

### `skill/templates/`

| File | Covers |
|---|---|
| `render_chunks.sh` | Generic resumable, chunked Blender headless render wrapper with a stalled-chunk watchdog and a "one Blender at a time" guard. Verify with `bash -n` only — do not run it as part of reviewing this skill. |
| `assemble_overlay_example.sh` | Generic alpha-fade caption overlay (with the `-loop 1` fix) + two-pass `loudnorm` mastering skeleton. Verify with `bash -n`. |

### `evidence/`

Copies of the original project's own metrics, notes, and fidelity documents, scrubbed of local paths
and personal details, that the claims in `skill/references/` are sourced against. Where a claim's
original source wasn't copied here (an earlier look-dev round, or a private project script), the
reference file says so explicitly and gives a description or excerpt instead of a path.

## Credits and licensing

- This skill refers to the [`teardown`](https://github.com/elvarofficial/teardown) skill by
  elvarofficial (MIT licensed) for the Three.js build pipeline; `teardown` itself is not included in
  this repository.
- Poly Haven assets used in the source project are CC0 1.0 (no attribution required).
- Blender is GPL-licensed; no Blender code or add-ons are redistributed here, only instructions for
  invoking the `Blender` binary.
- Scripture quoted anywhere in `evidence/` is the Douay-Rheims translation, public domain.
- This repository itself is MIT licensed — see `LICENSE`.
