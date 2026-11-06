---
name: video-3d-production
description: Produce video and 3D visuals (explainers, cinematic scenes, social cuts) by choosing between Three.js (interactive, exact), Blender/Cycles (cinematic, spec-accurate, slow), AI video models (fast, atmospheric, imprecise) or a hybrid, then building, rendering, assembling and verifying them. Use when someone asks for a 3D animation, a cinematic render, a "realistic" video, a visual study of a text or mechanism, "should I use Blender or AI video", how to combine AI video with 3D, or to resume a long Blender render. Not for UI/web design (use premium-site / frontend-design) or for platform posting strategy.
---

# Video + 3D production

One job, four ways to do it. This skill picks the way, then gives the working recipe, the cost gate and the checks.
Everything marked *measured* comes from one real project, built two ways (a Three.js console and a Blender/Cycles
film of the same subject, Nov 2026; see `evidence/` and the write-up at
https://renanspatin.com/en/blog/ofanim-ezequiel): Three.js console 36 min build + 82 s capture for a 16 s film
(`evidence/threejs-partA-METRICS.md`); Blender 504 frames, 4.13 h of render on an Apple M4, 29 s/frame average
(`evidence/blender-v7-METRICS.md`). **The AI-video column is research, not experience**: the author never ran a
video model (see `references/ai-video.md`, §0 and §6).

## 1. Brief (answer in writing before choosing)
- **Job:** explain a mechanism, cinematic hero/encounter, organic/human motion, atmospheric B-roll, product shot, quick social cut.
- **Fidelity to a spec:** must the geometry/count/text match a source exactly? (A text-faithful design, a counted object, a logo.)
- **Interactive output needed?** (a page people can orbit and drive) → only Three.js gives that.
- **Budget and deadline:** local-only/free, or may paid generation be used? Who approves spend? (Default: no spend.)
- **Audience trust:** will it be judged on honesty about AI use? (Religious, journalistic, educational: say what was AI, say what was built by hand.)

## 2. Pick the track
| Need | First pick | Why | Details |
|---|---|---|---|
| Explain a mechanism, exact, labeled, interactive | **Three.js (teardown skill)** | one model drives film, live page and every number; cheap to iterate | `references/threejs-teardown.md` |
| Cinematic shot that must match a spec | **Blender (Cycles)** | physically based light, exact geometry; costs hours of render | `references/blender-headless.md` |
| Atmospheric plates (sky, fire, smoke), plausible motion, fast first draft | **AI video** (only with approved cost) | strongest on continuous, texture-rich, non-exact motion | `references/ai-video.md` §2–4 |
| Organic/human pose that must be anatomically right | **Blender, with a posed body under the cloth** | a draped-cloth proxy read as "a sheet" in our project | `blender-headless.md` (prostrate figure) |
| Fast social post, deadline | reuse an existing Three.js scene; else AI image-to-video off a still | marginal cost after a build is near zero | `ai-video.md` §4 |
| No budget | **Three.js + Blender** (local, free) | every hosted AI video API bills per second/credit; local open weights (Wan) need a strong GPU | `ai-video.md` §1, §4 |

Rules of thumb: AI video is documented-weak on exact geometry, counting, text in frame and unusual human poses
(evidence in `ai-video.md` §2); Blender is weak on organic motion and some materials (crystal/fire read painted);
Three.js is cheap and exact but looks like a game/console, not film.

## 3. Hybrids (what exists, ranked by how well documented it is)
1. **Console explains + cinema convinces** (done and measured here): Part A in Three.js, Part B in Blender, assembled with
   cards and captions. `references/assembly.md`.
2. **3D stills/frames as first (or first+last) frame for AI image-to-video:** keeps the design locked. Untested by us.
3. **AI video-to-video restyle of a 3D render with structure control (depth/pose):** keeps structure, changes look. Untested by us.
4. **AI plates composited behind 3D:** thin evidence, lighting integration is the risk. Untested.
5. **Render fewer frames / lower res, then interpolate/upscale to cut Blender time:** documented to fail on large
   fast motion (fast rotation); test first, render those shots in full. Untested by us.
Any hybrid step that calls a paid service needs the cost gate below.

## 4. Cost gate (hard rules)
- **Never call a paid generation endpoint** (Veo/Omni, Kling, Runway, Luma, Hailuo, Seedance, image-to-video, anything billed
  per second or credit) **without the user's explicit approval of the expected cost.** Listing models is free; generating is not.
- To see what an API key unlocks: `curl -s "https://generativelanguage.googleapis.com/v1beta/models?pageSize=200" -H "x-goog-api-key: $GEMINI_API_KEY"`
  and filter for `omni|veo|imagen|image|video|lyria` (a narrower filter once missed `gemini-omni-*`).
- Blender: **one process at a time**, always. Two at once hang both.

## 5. Build
- **Blender:** `references/blender-headless.md` and `templates/render_chunks.sh` (resumable 8-frame chunks, stall watchdog,
  refuses to start if another Blender runs). Estimate by rendering 3 test frames, then multiply; check `uptime` and
  `sysctl vm.swapusage` and heavy apps (Chrome) first.
- **Three.js:** invoke the `teardown` skill; notes in `references/threejs-teardown.md`.
- **AI video:** `references/ai-video.md`, only after the cost gate.

## 6. Assemble and verify
- Captions as transparent PNGs (Playwright) composited with ffmpeg; hard cuts between shots; keep text bands clear of
  subjects (mask test); hook/end-card variants rebuilt text-only; two-pass `loudnorm` to -14 LUFS. `references/assembly.md`
  and `templates/assemble_overlay_example.sh`.
- Verify by looking: Read first/middle/last frame of every shot, 100% crops, consecutive frames for flicker, frames at every cut.
- Log with `references/metrics-and-honesty.md`: wall-clock times, iterations, seconds/frame by shot, rejected attempts, an honest
  "what looks wrong" list. Numbers shown anywhere are sourced to a file; use "not logged" instead of guessing; comparisons are
  not controlled experiments unless they are.

## 7. Delegation
Heavy work goes to subagents with explicit tiers (see the global CLAUDE.md). A long render is one detached process with a log,
not an agent babysitting it; resume the agent with SendMessage after usage-limit pauses. Read the agent's frames yourself before
telling the user it is done.
