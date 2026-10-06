# Active Projects Architecture Landscape

Summary of Hunter's primary software projects and their active architectural focus areas as of late 2026.

---

## 1. Pi Learn Expansion (`Documents/Pi Learn Expansion`)
- **Core Concept**: Educational coding harness based on `pi` coding-agent, expanding from MCQ-only quizzes to conversational open-ended reasoning, code execution verification, and spaced retrieval.
- **Architectural Junction**:
  - **Agent State Machine**: Inter-agent communication spec for `teach` loop, `code-grader` subagent, `researcher`, and `visual-makers`.
  - **Code Grader**: Sandboxed execution testing (`agents/code-grader.md`) using `safe_bash` returning diagnostic pass/fail (no arbitrary numerical marks/scores).
  - **Context Integration**: Single-fetch Supermemory knowledge profile at session start; transient `session_struggles.md` scratchpad cleared at session end.
  - **Pedagogy**: Predict-First loop, hint ladder (`Guiding Question` -> `Concept` -> `Strategy` -> `Snippet` -> `Solution`), and "ship mode" overrides.

---

## 2. SIH 2026: Satellite SAR Oil-Spill & AIS Attribution Pipeline (`Documents/SIH/PLAN_SIH26143.md`)
- **Core Concept**: NTRO problem statement for automated satellite oil-spill detection, Lagrangian drift back-tracking/forward-prediction, and culprit vessel attribution via spatio-temporal AIS data.
- **Architectural Junction**:
  - **Module A (Detection)**: PyTorch U-Net segmentation on Sentinel-1 SAR imagery (2048x2048 GeoTIFF).
  - **Module B (Drift Engine)**: Custom Runge-Kutta 4 Lagrangian particle tracker ($dX/dt = U_{\text{current}} + \alpha \cdot U_{\text{wind10m}}$ with $\alpha \approx 0.03$).
  - **Module C (Attribution Engine)**: Spatial-temporal filtering over MarineCadastre AIS trajectories; suspicion score calculation based on track-slick overlap, proximity, speed anomaly, and loitering.
  - **Module D (Investigator UI)**: React + Vite + MapLibre GL JS frontend with FastAPI backend.
