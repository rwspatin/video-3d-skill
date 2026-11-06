# Metrics and honesty: the habit, not just the numbers

A habit used consistently across seven look-dev rounds, a teardown build, and a final assembly in one
real project, "The Wheels of Ezekiel" (write-up: https://renanspatin.com/en/blog/ofanim-ezequiel).
This file is about the *discipline*, not about any one project's specific figures — see
`blender-headless.md`, `threejs-teardown.md` and `assembly.md` for those, each sourced individually.
Only the final round's own docs and the cross-track comparison doc are copied into `evidence/` here;
earlier rounds are cited as private project documents, with a description instead of a path.

## Every build logs wall-clock start/end with `date`

Every `METRICS.md` in this project opens with a "Wall clock" table built from literal `date` output,
not an estimate: start time, phase boundaries, pauses (e.g. usage-limit pauses), end time (source:
`evidence/blender-v7-METRICS.md:7-14`, `evidence/threejs-partA-METRICS.md:7-14`; an earlier round's
own metrics table follows the same format). When a session was interrupted and resumed, the gap is
recorded as a gap, not folded silently into "active time" (source: private project document,
excerpt below — an earlier round's own metrics table states "Interrupted by usage limits / server
restarts ... Active working time | ~2 h 40 min over four sessions" — the four-sessions qualifier is
part of the number, not a footnote explaining it away).

## Iterations, seconds per frame by shot type, total render time

Each `METRICS.md` states, as tables: a per-still or per-shot render cost (seconds, with a min-max
range where available), a count of test renders and rejected attempts, and a total render time with
both "render" time and "wall" time kept separate when they differ (source:
`evidence/blender-v7-METRICS.md:31-40`, the seconds-per-frame table distinguishes render time from
wall-clock time, "4.13 h render, 5.3 h wall" — the gap is the ~50 min lost to a hung chunk, stated
explicitly rather than absorbed).

## File sizes, rejected attempts, an honest "what looks wrong" list

Every round's `METRICS.md` ends with two sections that are not optional: an **"Iterations" /
"Rejected / failed"** numbered list (what was tried, what broke, what fixed it — e.g. two earlier
rounds' own metrics files record "Rejected / failed (12)" and "Rejected / failed (v5)" with 7
numbered causes respectively — source: private project document, description only) and an **"Honest
flaws" / "What looks wrong"** section that states, per shot, what still doesn't read correctly — never
"looks good" without a caveat list (source: every round's own `METRICS.md`, final section — round 7's
is `evidence/blender-v7-METRICS.md`'s "Honest flaws" section). This is the same discipline the shared
project brief mandated up front: "number of things that failed and were rejected, and an honest list
of what looks wrong" (source: private project document, excerpt above — the shared brief's own
"Metrics both tracks must log" section states this requirement in those words).

## Comparisons must state they are not controlled experiments

`evidence/comparison-NUMBERS.md` is explicit that every number shown is a direct quote or a direct
measurement of a named file — and separately, that the comparison between the two tracks (Three.js
vs. Blender) is **not** a controlled experiment: "A Blender/Cycles render (another track) was running
on the same GPU for most of this build, so timings may be inflated" (source:
`evidence/threejs-partA-METRICS.md:4`, carried into the comparison). The comparison video also
explicitly declines to show aggregate look-dev timing across all five Blender rounds, because two of
the five rounds' `METRICS.md` files don't state a single comparable "active working time" figure the
way the others do — the fix is to say "not logged" for those rounds, not to sum or estimate a number
that isn't actually there (source: `evidence/comparison-NUMBERS.md:119-127`).

**Rule, generalized:** if two things being compared ran on shared hardware, under different session
conditions (usage-limit pauses, different machine load, different agents/operators), the comparison
output must say so next to the numbers — not in a methodology footnote nobody reads.

## Every number shown in a video or article is sourced to a file

`evidence/comparison-NUMBERS.md` is a complete audit trail for a 51-second video: every on-screen figure
(title card stats, per-pair stats, closing-card stats) is listed with the exact source file and line
or table row it came from, or marked as "measured directly" with the exact command run
(`ffprobe -show_entries format=duration ...`) (source: `evidence/comparison-NUMBERS.md`, entire file
structure — see the per-pair tables and the "Container" section). Two categories of number exist:

1. **Copied verbatim** from another file's own `METRICS.md`/`NOTES.md`/`FIDELITY.md` — cite the file
   and line/row.
2. **Measured directly** on a named output file with a named command (`ffprobe`, `ls`, `shasum`) —
   cite the command, not just "measured."

No third category ("estimated," "roughly," "should be about") appears on screen in this project's
numbers files. If a number can't be sourced either way, it doesn't go on screen.

## "Not logged" beats a guess

When a figure genuinely wasn't captured — e.g. two earlier rounds' own metrics files don't report a
single "active working time" total the way the surrounding rounds do (source: private project
document, description only) — the downstream document that would have used it says **"not logged"** explicitly rather than
estimating, averaging, or silently omitting the figure (source: `evidence/comparison-NUMBERS.md:123-127`).
This is the same posture as the per-shot "Honest flaws" sections: stating a gap in the data is treated
as part of doing the work correctly, not as an admission to be hidden.

## Checklist for applying this habit to a new project

1. Start every build/render session by printing `date`; log phase boundaries and pauses as they
   happen, not reconstructed afterward.
2. Keep render-time and wall-clock-time as separate numbers whenever a process could stall, be
   restarted, or share hardware with something else.
3. End every METRICS file with a numbered rejected/failed list and an honest flaws list, even when
   the deliverable "worked." Zero entries in either list is a red flag, not a clean pass.
4. Before putting a number in a video, slide, or article, write down which file and line it came
   from, or which exact command measured it. If you can't, don't show it.
5. When comparing two things that ran under different conditions (shared GPU, different session
   lengths, different operators), say so next to the comparison, not in a separate caveats section.
6. If a number wasn't captured, write "not logged." Never backfill it with an estimate dressed as a
   measurement.
