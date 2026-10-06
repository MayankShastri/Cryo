# Cursor AI Pricing & Plans (as of September 2026)

## Overview
Cursor uses a tier-based subscription model with two usage concepts:
- **Fast requests:** Priority access to state-of-the-art models with low latency.
- **Slow requests:** Rate-throttled queue that kicks in after the fast allowance is exhausted.

## Plans (Monthly USD)

| Plan | Price/mo | Key Details |
| :--- | :--- | :--- |
| **Hobby** | $0 | Free tier, limited fast requests, community support |
| **Pro** | $20 | Standard individual plan; standard fast request quota + slow requests fallback |
| **Pro+** | $60 | Power-user individual tier; expanded fast request quota |
| **Ultra** | $200 | Heavy developer / extreme usage tier; highest priority fast request pool |
| **Teams** | $40/user | Organization-managed tier with central billing, privacy controls, and admin features |

## Models Supported (as of 2026)
- **Anthropic:** Claude 3.5 Sonnet, Claude Opus 5.5, Claude Fable 5.1, Claude Sonnet 5
- **OpenAI:** GPT-4o, o1, o3, GPT-5.6 Luna / Sol / Terra
- **Google:** Gemini 3.1 Pro, Gemini 3.8 Flash
- **xAI:** Grok 4.5, 4.6, 4.7
- **Native/Custom:** Composer 2.5, Muse Spark 1.3

All paid tiers provide access to the same leading-edge models. The distinction is the **volume of fast (priority) requests**, not model availability.

## Fast vs Slow Requests: Power User Strategy
- When fast requests run out, queries switch to "slow mode."
- **Slow mode is practically unlimited for interactive personal use.** Requests are queued behind fast requests, which can introduce slight latency during peak global traffic hours, but does not hard-block daily workflows.
- **Heavy coding pattern (~450M tokens/month):** Use Pro+ ($60) or Ultra ($200) to ensure adequate priority quota for interactive development, while letting background tasks, refactors, and automated codebase indexing flow through the slow pool.
- Users report that slow mode is robust enough to sustain heavy full-time daily coding without subscribing to Ultra, making Pro or Pro+ the typical sweet spot.
