# AI video generation — state as of 2026-11-06 (for the video-3d-production skill)

Research date 2026-11-06. Read-only: no logins, no paid API calls, no scraping behind
logins. Tags: **V**=VERIFIED (I read it on a public official page), **R**=REPORTED
(secondhand: reviews/aggregators/news), **I**=INFERRED (my reasoning, not sourced).
Full source list with URLs + access dates is in **References** at the end; inline
citations are `[n]`. All access dates are 2026-11-06 unless noted.

## 0. Why this document exists

The user has a Blender/Cycles cinematic (504 frames, 4.13h render on an M4, 29s/frame,
flaws in the prostrate figure and in crystal/fire) and a Three.js interactive console
(36 min build, 82s capture for 16s) — both measured on one real project, "The Wheels of
Ezekiel" (write-up: https://renanspatin.com/en/blog/ofanim-ezequiel; see `evidence/` in this
skill for the underlying metrics). They never ran an
AI video model: they chose not to spend on one for that project. Their Gemini API key
does list video-capable models (`gemini-omni-1.1-flash` and `gemini-omni-1.2-flash`, both with
`generateContent`; checked 2026-11-06), but the skill author never called them, so whether they
work on that key (billing, free tier) is untested. Section 6 explains how to check.

## 1. Model landscape, Nov 2026

**Big 2026 change:** Google retired the Veo 3.1 preview endpoints (`veo-3.1-generate-preview`,
`-fast-`, `-lite-`) from the **Gemini API** on **2026-10-22**, replacing them with a
different model/contract, `gemini-omni-1.1-flash` [1][2] (V, official docs). So an old
`veo-*` id will not appear in the models list any more; look for the `gemini-omni-*` ids instead — V (confirmed directly
against `aistudio.google.com/docs/video`, access 2026-11-06). Veo 3.1 itself is reported
to remain GA on Vertex AI / the Gemini Enterprise Agent Platform, a separate product [2][22] (R).
Also in 2026: **Sora 2's app shut down 2026-04-26 and its API shut down 2026-09-24** — OpenAI
is exiting consumer video generation entirely [7][12] (R, multiple aggregators agree, not
confirmed on OpenAI's own page which returned no fetchable result). **Wan 2.5** broke
Alibaba's open-weights tradition — no public weights [11] (R). **Kling 2.6** added Kling's
first native audio [5] (R).

| Model (Nov 2026) | Max clip | Resolution | Aspect ratios | Image→video | Native audio | API / endpoint | Price (per sec, approx.) | Free tier | Commercial use | Provenance |
|---|---|---|---|---|---|---|---|---|---|---|
| **Gemini Omni Flash** (`gemini-omni-1.1-flash`, replaces Veo 3.1 in Gemini API) | 3–15s (10s for edit/extend input) [1] | 360p/720p/1080p/4K, 24fps [1] | not stated in docs — **gap** | yes, text+image, up to 6 reference images for character consistency [1] | yes, native [1] | Gemini API, Interactions API, multi-turn edit [1] | not published in official docs — **gap**; third parties ~$0.10/s at 720p [22] (R) | not stated — **gap** | governed by Google AI Prohibited-Use Policy; no video-specific clause found [22] (R) | not stated — **gap** |
| Veo 3.1 (Vertex AI / Enterprise Agent Platform, separate from Gemini API) | ~8s typical | up to 1080p claimed, one source claims 4K (disputed) [4] | 16:9, 9:16 confirmed; 4:5 not found anywhere [4] | first-frame; some reference-image flows | yes, dialogue/ambience/SFX synced [4] | Vertex AI / Gemini Enterprise | $0.05–$0.40/s (Lite→Standard), 720p/1080p/4K tiers; archived Gemini API rate card, may not reflect current Vertex pricing [see refs below] | none found for video [see refs below] | governed by Google AU/Prohibited-Use policy; blanket reports of blocking all photorealistic humans in some regions [22] (R) | SynthID frame-level watermark; Gemini app can check for it [12] (R) |
| **Kling 2.5 / 2.6** (Kuaishou) | 5 or 10s per gen; chain via "extend" [1-source] | 1080p (Pro/Turbo Pro) | 16:9, 9:16, 1:1 [confirmed both 2.5 and 2.6] | first-frame AND first+last-frame ("anchors") | 2.5: no; **2.6: yes, first Kling model with audio** | Kling API (official) + many resellers (kie.ai, PiAPI, fal.ai) | ~$0.04–$0.06/s via resellers (5s clip $0.21–$0.32); no single official per-sec rate found | none confirmed | **disputed**: one reading says commercial use needs a paid membership; another says users own IP + grant Kuaishou a training license; free-tier commercial use is contested — verify current ToS | not found |
| **Runway Gen-4.5 + Aleph 2.0** | Gen-4.5: standard gen length; Aleph 2.0: edits clips up to 30s / 16MB, up to 5 keyframes, output = input length | Aleph 2.0 out: 1080p | not confirmed in sources found | Gen-4.5 image-to-video; Aleph is video-to-video (restyle/edit, not gen-from-image) | not found | **Runway Dev API**, pay-as-you-go, $10 min purchase; separate from app subscriptions | Gen-4.5: ~$0.12/s (12 credits); Aleph 2.0: ~$0.28/s with 56-credit minimum (figures disagree across sources, $0.15–$0.32/s range) | none for API | Runway's ToS disclaims ownership of outputs, no commercial restriction on any tier, but grants Runway broad perpetual rights to train on inputs/outputs (Enterprise opts out) | not found |
| **Luma Ray3.2** | 5 or 10s (Ray3.2 gen); Modify/video-to-video source clips up to ~18–20s (sources disagree) | 360p/540p/720p(default)/1080p | not confirmed | first-frame; Modify = video-to-video restyle | not found | Luma API, separate billing from app plans ($30+/mo) | $0.15 (540p)–$1.20 (1080p) per 5s SDR clip; HDR 2×, HDR+EXR 3× | none for API | not researched — **gap** | not found |
| **Sora 2 / 2 Pro (OpenAI)** | **DISCONTINUED.** API: 4/8/12s (guide also mentions 16/20s, Pro to 25s — sources disagree) | Sora 2: 720p only; Pro: up to 1080p | not confirmed | not confirmed | not confirmed | **API and app both shut down** (app 4/26/26, API 9/24/26) [7] | historical: $0.10/s (720p), Pro $0.30–$0.70/s by resolution; batch ~half price | none | n/a — service discontinued | visible moving logo + C2PA metadata in file; logo removable for paying users, C2PA metadata reportedly stays; no confirmed SynthID-style pixel mark [12] (R) |
| **Hailuo 2.3 / H3 (MiniMax)** | 6 or 10s clips, 24fps | 768p or 1080p | not confirmed | first-frame | not confirmed for 2.3; not researched for H3 | MiniMax API (pay-per-clip) | 2.3: $0.28 (768p/6s) to $0.56 (768p/10s); 2.3 Fast: $0.19–$0.33; **H3** (released 2026-07-31, now current) ~$0.08/s at 768p — 2.3 moved to "legacy" | not found | not researched — **gap** | not found |
| **Seedance 1.5 Pro / 2.5 (ByteDance/BytePlus)** | up to 15s with native audio (one listing) | 480p/720p/1080p/2K/4K tiers | not confirmed | first-frame | **yes, "Video with audio" is a distinct billed mode** | BytePlus API; one source says 1.5 Pro retired on official API (disputed) | $0.023–$0.47/s depending on res and audio on/off; 2.5 roughly $0.10 (480p)–$0.57 (1080p)/s | not found | not researched — **gap** | not found |
| **Wan 2.1 / 2.2** (open weights, local) | model/config-dependent | model-dependent | model-dependent | yes, via VACE / Fun-Control | model-dependent | **no API** — run locally via ComfyUI; Wan 2.1 small model needs ~8GB VRAM, Wan 2.2 5B needs ≥24GB | n/a — local compute only, zero marginal cost once hardware owned | Apache 2.0 (open weights) [11] | own hardware, no ToS to violate |
| **Wan 2.5 / 3.0** | not researched (closed) | not researched | not researched | not researched | reported to include audio (Venice.ai preview name "Wan 2.5 Preview — Open AI Video with Audio" is misleading per [11]) | proprietary API only, **no open weights despite "Preview" branding** [11] | not researched — **gap** | n/a | proprietary, closed | not found |

**Data gaps flagged in the table above, repeated here:** no official per-second Gemini
Omni Flash price found; no confirmed 4:5 aspect-ratio support anywhere; no confirmed
seed/reproducibility controls on any commercial API; free tiers for Kling/Luma/Hailuo/
Seedance not confirmed from official pages (only third-party aggregator claims, several
conflicting) — before budgeting anything, check the vendor's own current pricing page.

## 2. What AI video is good/bad at for this kind of work

| Dimension | Finding | Evidence |
|---|---|---|
| Counting / exact geometry ("wheel within a wheel full of eyes") | Weak. CountVideoBench (2,600 synthetic videos, counts 5–50): **no video-language model exceeds 27.6% exact-match** on counting [13] (R, this is a VLM-judging benchmark, not a generator benchmark — proxy evidence, not direct). VBench-2.0's own authors note object-counting/3D-understanding failures are a recognized blind spot across training data [13] (R). | Thin but consistent; no benchmark tests "generate N eyes on an object" directly — **gap**. |
| 3D/geometric consistency across frames | Weak-to-moderate, improving. VBench-2.0 added a dedicated Geometry dimension for exactly this; GeoT2V-Bench (2026) and GeoCon-Bench use fixed seeds/prompts to isolate camera-motion and rigidity errors [13] (R). | New 2026 benchmarks exist precisely because this was unmeasured before — treat current numbers as early. |
| Consistency across shots/cuts | Moderate, model-dependent. Gemini Omni Flash explicitly supports "character consistency across up to 6 reference images" [1] (V). Kling's first+last-frame "anchors" exist partly to fight drift [vendor]. | Reference-image-driven consistency is the documented mitigation, not a solved problem. |
| Camera control | Weak precision. One Feb-2026 model roundup: a model handles lens/DOF better than dolly/crane/orbit, and "dolly forward" vs "push in" can yield near-identical results [15] (R). Multiple vendor guides report prompted camera moves not followed reliably. | Vendor-adjacent sources; no independent quantitative camera-control benchmark found — **gap**. |
| Physics | Weak, and now measured. **Physion-Eval**: 83.3% of exocentric and 93.5% of egocentric clips across 5 current text/image-to-video models had at least one human-identifiable physics glitch [15] (R, cited via a secondary blog, not the paper itself — treat as R not V). T2VPhysBench separately reports recurring gravity/conservation errors [15] (R). | This is the strongest single number in this section — still secondhand of the underlying papers. |
| Human faces/hands/prostrate or unusual poses | Weak. Hands carry over the same structural failures as image models (extra fingers, wrong joints); faces/hands "in close frame are not reliably stable" [15] (R, vendor creator guide). Nothing specifically tested on prostrate/foreshortened human figures — the user's own Blender weak point — **gap, likely at least as bad in AI video**. | |
| Text in frame | Not researched — **gap**. | |
| Reproducibility / seeds | Not confirmed on any commercial API examined (Gemini Omni Flash, Kling, Runway, Luma, Hailuo, Seedance docs reviewed did not surface a seed parameter) — **gap, likely absent on most hosted APIs; INFERRED** (I). | |
| Iteration cost / rejection rates | Not quantified with real data anywhere found. Anecdotal: Veo/Vertex users report photorealistic-human prompts getting blocked outright by safety filters before rendering [22] (R) — a rejection, not a quality failure, but it burns iteration budget on religious/human-figure subjects specifically. | **Gap**: no rejection-rate statistics found for any model. |

**Bottom line for this project (I):** AI video is evidence-weak exactly where the project's
hardest content lives — exact counts of eyes/wheels, a correctly-posed prostrate human
figure, convincing fire/crystal materials in motion. It is comparatively better suited to
atmosphere, texture, and "plausible generic motion" shots where exactness doesn't matter.

## 3. Hybrid pipelines that actually exist and are documented

| Pipeline | When it works | When it breaks | Cost/time | Tools | Concrete example |
|---|---|---|---|---|---|
| **(a) 3D still as first (or first+last) frame for image-to-video** | Best-documented hybrid. Kling and Runway both have a native "first+last frame" mode built for exactly this [18] (R). | Letting the model infer the ending from a single first frame causes flicker/warped geometry per one vendor guide (R, vendor-interested source) — using first+last reduces this. | Minutes per clip once renders exist; API cost per table in §1. | Kling web/API "First & Last Frame"; WaveSpeed-hosted Kling V3 Turbo Standard (first-frame API, ≤15s output); ComfyUI `RunwayFirstLastFrameNode` [18] (R) | Render frame 1 and final frame of a Blender shot, upload both to Kling I2V with First&Last enabled, let AI fill the in-between motion. |
| **(b) Video-to-video restyle of a 3D render** | Runway Aleph 2.0: reads up to 30s/16MB source, up to 5 keyframe edits, preserves camera move/timing while changing look; reconstructs scene depth/normals from 2D footage [17] (R). Wan VACE (ComfyUI, local): depth maps (Depth Anything v2) + pose drive a target video while a reference image sets identity/style [16] (R). | Stacking multiple style changes in one pass causes drift — do one transformation per render, chain renders [17] (R). VACE frame-count math is strict: `length − 1` divisible by 4, dimensions divisible by 16, or frames get cut off [16] (R, GitHub discussion). | Aleph: reported 2–4 min per pass, stretches at peak hours [17] (R). VACE: free/local but needs a capable GPU and ComfyUI setup. | Runway Aleph (API or DaVinci Resolve plugin); Wan 2.1/2.2 + VACE in ComfyUI | Render a Blender crystal/fire shot flat and under-lit (faster), restyle lighting/material look with Aleph in one pass rather than re-rendering Cycles. |
| **(c) AI-generated plates (sky/fire/water) composited behind/around 3D** | **Documentary evidence is thin.** Only vendor guidance found: prompt for pure sky with no ground/horizon, specify sun direction to match the plate, expect banding on smooth gradients (add grain/haze) [vendor, R]. | Lightning/sudden events smear in a single AI-generated take — generate several short takes and pick the cleanest [vendor, R]. | Not quantified. | No Blender-compositor- or ffmpeg-specific documented workflow found for this. | **Data gap — no concrete documented Blender/ffmpeg compositing workflow found.** This would need to be built and tested, not assumed from AI-video vendor docs alone. |
| **(d) 3D as camera/layout/previs for AI video** | No dedicated documented workflow found distinct from (a)/(b) — i.e., using a 3D scene purely as a camera/blocking reference (not a literal first frame) for an AI shot. | — | — | — | **Data gap.** The closest documented analogue is VACE's depth/pose control (c) above, repurposed with depth/pose rendered out of Blender instead of extracted from real footage — plausible by extension of (b)'s mechanics, but **not found as a described workflow; mark this specific combination INFERRED (I), unverified.** |
| **(e) AI upscaling/interpolation to cut Blender render time** | Render fewer frames at lower resolution, then interpolate + upscale. One documented case (3ds Max, not Blender, via Topaz): full-HD-vs-4K render is ~4× faster, and the presenter estimates ~6% of full-res cost combining 4× interpolation + 2× upscale; interpolating every 2nd frame "looked fine," every 4th/8th was less reliable; scenes with slow camera moves held up even at every 16th frame [19] (R). | **Fast rotation is explicitly a failure mode**: RIFE (flow-based) is documented to struggle with large motion and disocclusion — both present in fast rotation — producing artifacts in revealed/occluded regions [20] (R, arXiv-sourced claim via secondary source). Busy, fast-moving regions need to be rendered in full, not interpolated [19] (R). Forum anecdotes report quality regressions between RIFE point versions (4.15/4.16 vs 4.17), i.e. this is a moving target, not a fixed guarantee [20] (R, forum anecdote, weak). | Potentially the biggest time win of any hybrid here (up to ~16×), but untested on Blender/Cycles specifically and untested on the user's own crystal/fire/wheel-rotation content. | Topaz Video AI (upscale+interpolation), RIFE / FILM (open interpolation models) | Render the project's own wheel-rotation shot at every 4th frame and 1080p instead of every frame at full res, then RIFE-interpolate and Topaz-upscale — **but test the wheel's fast rotation specifically first**, since that is the documented weak case. |

## 4. Decision guide

Three.js measured on the project (see `evidence/threejs-partA-METRICS.md`): 36 min build + 82s capture for a 16s clip, exact/
controllable. Blender measured on the project (see `evidence/blender-v7-METRICS.md`): 504 frames, 4.13h render, 29s/frame avg,
8.6h naive estimate vs ~3.8h with tricks; two renders at once hang both; a 9GB swap
stalled a chunk. These are **(measured on one real project, see `evidence/`)** throughout.

| Job type | First pick | Why | Fallback |
|---|---|---|---|
| Explain a mechanism (exact, labeled, controllable camera) | **Three.js** | Exact geometry and camera, cheap iteration (36min build amortizes), reproducible — AI video is documented-weak on exact geometry/counting (§2) (I) | Blender if the mechanism needs physically-based light/materials Three.js can't fake |
| Cinematic hero shot, exact spec | **Blender** | Physically-based rendering hits an exact spec; AI video can't guarantee geometry/counting correctness (§2) (I) | Hybrid (e): render fewer frames + interpolate/upscale to cut the 4.13h measured cost, if fast-rotating/complex areas are tested first and rendered in full |
| Organic/human/animal motion | **Depends on fidelity need.** If anatomical correctness matters (a prostrate figure, hands): Blender, manually corrected, despite being the project's own documented weak point (I). If only plausible secondary motion in a background role is needed: AI image-to-video off a Blender still (hybrid a) | AI video models are trained on real human motion and may out-perform hand-keyframed rigs for *plausible* motion, but are documented-weak on hands/faces/unusual poses (§2) — this is a real trade-off, not a clean win either way (I) | Motion capture, or stylize the figure to reduce anatomical scrutiny |
| Atmospheric B-roll (sky, fire, smoke, water) | **AI video** | This is close to AI video's best-evidenced strength (continuous, texture-rich, non-exact motion) vs. the user's own documented Blender weakness in crystal/fire materials (I) | Blender volumetrics/Mantaflow if the plate must cast correct shadows/reflections onto 3D geometry (compositing a flat AI plate behind 3D breaks lighting integration — §3c is a documented gap) |
| Product/brand shot (exact geometry/logo) | **Blender** for the asset; **hybrid (b)** Aleph restyle for fast look variations once one correct render exists | Exact geometry/material fidelity matters, and AI video is documented-weak on precise, text-faithful designs (§2); restyle keeps structure fixed while iterating on look | Three.js if the product is simple enough to model/render in real time |
| Fast social post under a deadline | **Reuse an existing Three.js scene** if one exists (82s capture once built); otherwise **AI video** image-to-video off a quick still | Marginal cost after a build is nearly free; AI video's main edge is raw speed-to-first-draft when nothing exists yet | Blender only if there's genuinely no deadline pressure |
| No-budget constraint | **Three.js and Blender** — both free, local, no per-second billing | Every commercial AI video API in §1 bills per second/credit; the only $0 AI option is open-weights **Wan 2.1/2.2** run locally via ComfyUI (Apache 2.0, needs 8–24GB+ VRAM) [11] (V, license) | If local GPU is insufficient for Wan, there is no free hosted AI-video option found — **gap, no free tier confirmed for any hosted model** |

Operational notes carried over from the user's own measurements: don't run two Blender
renders at once on this hardware (both hang) and watch memory/swap on large scenes
(a 9GB swap stalled a chunk) — relevant to any hybrid plan that assumes parallel renders.

## 5. Disclosure and ethics

**Platform labeling, Nov 2026 (R unless noted):**
- TikTok requires a visible label on video using AI to generate/significantly alter
  realistic depictions of people, places, or events; can auto-label; undisclosed AI in
  ads gets rejected/restricted [23].
- YouTube moved from voluntary-only disclosure to **automatically detecting and labeling**
  videos with significant photorealistic AI content, in addition to the creator's manual
  "altered content" checkbox [23].
- Meta/Instagram labels via C2PA signals plus a creator "AI info" toggle; from
  2026-08-31, profiles featuring an AI-generated person need an "AI-generated profile"
  label or lose recommendation eligibility [23].
- EU AI Act transparency obligations (machine-readable marking) became applicable
  2026-08-02 [23].
- Provenance support in the models themselves: Veo uses SynthID (frame-level, detectable
  in the Gemini app) [12]; Sora 2 used a visible logo (removable for paying users) plus
  C2PA metadata (reportedly persists) [12]; no SynthID/C2PA information found for Kling,
  Runway, Luma, Hailuo, or Seedance — **gap**.

**Religious/sacred imagery** (source: a private research document, not included in this repo and not
re-derived here). The first two points below were re-checked on 2026-11-06 against public news
(PhillyVoice, 2026-10-02, on the papal post; Meduza, 2026-10-13, on the Belarus blessing of an
AI-generated icon on 2026-10-11): VERIFIED that both happened, REPORTED for reach and reactions. The
third is a recommendation, INFERRED:
- Climate is reported as "strongly negative, with papal backing": Pope Leo XIV's 2026-10-02 post
  called AI output not art ("ontological difference... algorithms lack the spark of humanity")
  (that document: VERIFIED text, REPORTED reach numbers).
- The single strongest documented backlash pattern reported is AI imagery entering **veneration or
  liturgy** (the Belarus AI icon).
- The recommended framing, directly applicable to any skill output: **never** call AI-assisted
  output "art," "icon," "sacred art," or anything for prayer/veneration; disclose the AI role
  **concretely** (what was AI vs. human-made, not vague "AI-assisted" language, which reads as
  evasive); state the human-made parts precisely (geometry modeled by hand, motion coded by hand,
  etc.).

## 6. How to check what you can use — and a hard rule

**List the models your Gemini API key actually unlocks** (V, endpoint confirmed by fetching
`aistudio.google.com/api-reference/models/list-models` [3], header form confirmed as the
current standard by the official Gemini API reference's own authentication guidance [25]):

```sh
curl "https://generativelanguage.googleapis.com/v1beta/models" \
  -H "x-goog-api-key: $GEMINI_API_KEY"
```

(Equivalent legacy form, also documented: `?key=$GEMINI_API_KEY` as a query parameter [3] —
kept only for backward compatibility per the official guidance [25].) Read the response's
model list for a video-capable entry — as of 2026-11-06 that means looking for
`gemini-omni-1.1-flash` rather than any `veo-*` id, since Veo 3.1 preview was retired from
this exact endpoint on 2026-10-22 [1][2] (V). On the user's own key, on 2026-11-06, the list
shows `gemini-omni-1.1-flash` and `gemini-omni-1.2-flash` (V, checked by the author; a filter
on 'veo|imagen|image|video' alone MISSES them: always filter on 'omni' too). Whether they are
usable without billing is untested.

**Hard rule for this skill: never call a paid generation endpoint (Veo/Omni, Kling, Runway,
Luma, Hailuo, Seedance, or any other billed-per-second/credit API) without the user's
explicit, specific approval of the expected cost first.** This is a process rule for the
skill, not a researched fact.

## References

Access date 2026-11-06 for all unless stated otherwise.

1. aistudio.google.com/docs/video — official Google, fetched directly (V)
2. the-decoder.com/openai-sets-two-stage-sora-shutdown... and agentpedia.codes/blog/gemini-omni-flash-rollout-guide — Veo 3.1 Gemini API retirement reporting (R)
3. aistudio.google.com/api-reference/models/list-models — official Google, fetched directly (V)
4. flowith.io/blog/veo-faq-commercial-rights-watermarks, vercel.com/ai-gateway/models/veo-3.1-generate-001.md, hedra.com/models/video/google/veo-31, picsart.com/compare-models (R, aggregated)
5. costgoat.com/pricing/kling, piapi.ai/kling-2-5, docs.krea.ai/api-reference/video/kling-26.md, fal.ai/learn/devs/kling-2-6-pro-vs-kling-2-5-turbo-pro (R)
6. (reserved)
7. the-decoder.com/openai-sets-two-stage-sora-shutdown-with-app-closing-april-2026-and-api-following-in-september, en.wikipedia.org/wiki/Sora_(text-to-video_model) (R)
8. renderahouse.com/blog/luma-ai-pricing, atlascloud.ai/blog/tips/luma-modify-video, magichour.ai/blog/luma-dream-machine-review (R)
9. openrouter.ai/minimax/hailuo-2.3, agentgid.com/assets/minimax-hailuo (R)
10. openrouter.ai/bytedance/seedance-1-5-pro, framesurfer.com/blogs/seedance-2-0-pricing, atlascloud.ai/blog/case-studies/seedance-2.0-pricing-full-cost-breakdown-2026 (R)
11. x.com/ArtificialAnlys/status/1977910656566489143, runpod.io/articles/guides/wan-2-7-runpod, wan27.org/blog/wan-2-5-open-source-guide (R)
12. layer3labs.io/comparisons/which-ai-models-watermark-their-output, layer3labs.io/guides/sora-watermark, en.wikipedia.org/wiki/Sora_(text-to-video_model) (R)
13. arxiv.org/pdf/2503.21755 (VBench-2.0), arxiv.org/html/2610.28356v2 (CountVideoBench), arxiv.org/pdf/2606.24829 (GeoT2V-Bench) — abstracts/snippets only, not full papers read (R)
14. (reserved)
15. medium.com/@cliprise/the-state-of-ai-video-generation-in-february-2026, capcut.com/create/ai-video-physics-realism-whats-fixed-and-whats-broken, capcut.com/create/ai-video-limitations-2026, vidu.com/blog/photorealistic-ai-video (R)
16. comfy.org/workflows (Wan VACE first-last-frame, pose-driven), docs.comfy.org/tutorials/video/wan/vace, github.com/comfyanonymous/ComfyUI/discussions/8293 (R)
17. help.scenario.com/articles/6499445829-runway-aleph-the-essentials, martini.art/en/how-to/edit-existing-video/runway-aleph, pixeldojo.ai/video-transform (R)
18. wavespeed.ai (Kling V3 Turbo image-to-video), comfy.org/workflows/api_runway_first_last_frame (R)
19. trancy.org/.../youtube/kee7JK_i4Y8 — transcript of a 3ds Max (not Blender) Topaz workflow video, undated (R, weak — not Blender-specific)
20. arxiv.org/pdf/2512.18241v1, svp-team.com/forum (RIFE large-motion/disocclusion weakness; forum anecdotes) (R)
21. terms.law/ai-output-rights/runway, adtestbench.com/tools/kling, journal.everypixel.com/ai-video-commercial-use, hackernoon.com/can-you-use-ai-generated-video-commercially (R)
22. docs.cloud.google.com/gemini-enterprise-agent-platform/models/video/responsible-ai-and-usage-guidelines, discuss.ai.google.dev forum threads (R, forum reports are anecdotal)
23. storrito.com/resources/tiktoks-2026-ai-labeling-rules, thenextweb.com/news/youtube-will-now-automatically-label-ai-generated-videos, billo.app/blog/ai-labeling (R)
24. a private research document (not included in this repo), own tags preserved, access date 2026-11-05 (mixed V/R/I per that document); the three bullet points in §5 sourced to it are carried over, not re-verified, and should be treated as unverified
25. Gemini API official authentication reference, as surfaced via search snippet quoting "all requests to the Gemini API must include an x-goog-api-key header" — not independently fetched in full (R, but the `?key=` query-param form was independently V-confirmed via ref 3)
