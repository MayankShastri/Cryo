---
name: academic-publishing
description: Workflow for finding 0-APC Scopus/SCI journals and drafting research papers according to specific guidelines.
---

# Academic Publishing Workflow

This skill governs the process of finding, selecting, and drafting research papers for Scopus/SCI-indexed journals.

## Workflow

1.  **Selection:** Search for venues ensuring 0-APC (Article Processing Charge). Prioritize Diamond Open Access or Subscription-based (Hybrid) journals over paid Open Access.
2.  **Verification:** Always confirm Scopus/SCI indexing status via official channels.
3.  **Template Acquisition:** Find and download the journal's official template *before* drafting. If none exists, use the standard IEEE manuscript template.
4.  **Drafting & Revisions:** Structure content according to the selected template, ensuring formal tone, mathematical precision, and technical rigor.
5.  **Multi-Format Versioning:** When revising, humanizing, or converting drafts across formats (.md, .docx, .tex), output new distinct files (e.g. `*_Humanized.docx`, `*_VoiceCalibrated.md`) rather than overwriting existing working drafts unless the user explicitly requested an in-place overwrite. This preserves baseline comparison and allows easy rollback.
6.  **AI Detector Resistance, Voice Calibration & Wikipedia Grounding:** Standard academic prose often flags as AI-generated due to its rigid passive cadence. When calibrating manuscripts for AI detector resistance, analyze author writing samples to embed natural sentence rhythm and/or ground sentence structures in real Wikipedia technical article syntax (leveraging high perplexity and asymmetrical sentence-length burstiness) while maintaining strict technical accuracy (equations, registers, benchmarks, citations). See [references/ai-detector-bypass.md](references/ai-detector-bypass.md).

## Pitfalls

*   **Overwriting Base Drafts:** Do not clobber original or intermediate drafts when generating humanized or reformatted versions. Always create a new file with clear suffixing.
*   **APC Traps:** Many journals list as "Open Access" but charge significant APCs. Always verify the fee structure.
*   **Sister Journal Fee Divergence:** Associations and university presses often run multiple sister transactions under similar names where one charges fees and another is 0-APC (e.g. ECTI-EEC vs ECTI-CIT). Verify the exact ISSN and journal code.
*   **Inaccurate Templates:** Never assume a template. Always check the journal's specific "Instructions for Authors" page or institutional repository.
*   **Platform Navigation Quirks:** ASPX portals often require `/Public/` paths, while OJS stores style bundles in `/public/journals/<id>/styles/`.
*   **Predatory Journals:** Verify indexing directly; do not rely on publisher lists alone.

## References

*   [APC Strategies](references/APC-types.md)
*   [Journal Platform Navigation](references/journal-platforms.md)
*   [AI Detector Resistance & Voice Calibration](references/ai-detector-bypass.md)
*   [Gesture HID & Hysteresis Research Phrasing](references/gesture-hid-research.md)
*   [Hardware Architecture & Sensing Research Phrasing](references/hardware-sensing-research.md)

## Scripts

*   [Journal Verification Script](scripts/verify_journal_status.py)

## Templates

*   [Standard Manuscript Scaffold](templates/manuscript-scaffold.md)
