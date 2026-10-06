---
name: web-research-competitive-intelligence
description: Techniques for fetching, scraping, and synthesizing pricing, feature, and policy information from live web sources — especially SPA-heavy sites that resist simple curl/grep approaches.
tags: [research, scraping, pricing, competitive-intelligence, web]
---

# Web Research & Competitive Intelligence

Use when asked to: look up current pricing, compare plans, check SLAs, verify feature availability, or summarize what a product/service offers across multiple tiers.

## Trigger conditions
- "What does X cost?"
- "Compare plan tiers for Y"
- "Do they have unlimited use?"
- "What models/features are included?"
- "Find the limits / caps / quotas"
- "Find the syllabus / modules / topics for this course"
- "Summarize what this MOOC covers"
- Fetching course metadata from Coursera, edX, NPTEL, or similar platforms

---

## Approach

### 1. Try direct structured sources first (fastest)
Before scraping HTML:
- Check `https://docs.<domain>/llms.txt` — some sites expose LLM-friendly flat content here (note: cursor.com returns HTML for this path despite the header hint, as of Sep 2026)
- Check `https://docs.<domain>/sitemap.xml` — lists all doc URLs
- Check `https://api.<domain>/pricing` or `https://<domain>/api/pricing` for JSON
- **Course / Education Platforms (Coursera, edX, etc.)**:
  - Coursera Course Metadata API: `https://www.coursera.org/api/courses.v1?fields=name,description,slug,partnerIds,instructorIds,workload&q=slug&slug=<course-slug>`
  - Look for `<script type="application/ld+json">` in raw HTML — Coursera embeds full `syllabusSections` containing all module names, full descriptions, and estimated completion times (`timeRequired`) in the schema JSON-LD block.
- Look for `__NEXT_DATA__` script tags in SSR pages — these often embed the full page data as JSON

### 2. For SPA / Next.js / React sites
Raw `curl` returns the *shell* HTML (nav, scripts, empty body). Content is client-rendered. Workarounds:
- Add `RSC: 1` and `Accept: text/x-component` headers — some Next.js apps respond with React Server Component data
- Look for `self.__next_f.push` payloads in the raw HTML — they contain serialized page props
- Use `grep -o '"name":"[^"]*","price":"[^"]*"'` style patterns to extract JSON fragments from embedded scripts
- The official structured data (`<script type="application/ld+json">`) often contains offer names and prices even in SPA pages — always scan for it

### 3. Search engine fallback
- DuckDuckGo HTML endpoint: POST to `https://html.duckduckgo.com/html/` with body `q=<query>` and scrape `result__snippet` class anchors
- Bing: GET `https://www.bing.com/search?q=<query>` with a Chrome UA and scrape `li.b_algo` elements
- Add `site:forum.<domain>.com` or `site:reddit.com` to find user-reported usage experience

### 4. Forum / community sources for usage reality
For questions like "can I really use it heavily?", "is slow mode actually unlimited?":
- Target `forum.<domain>.com`, subreddits, and HN threads
- Users report real-world rate limit behavior that official docs omit

---

## Pitfalls

- **DuckDuckGo HTML API often returns empty results** when the query is too specific or the user agent isn't recognized. Retry with a broader query or switch to Bing.
- **`result__url` / `result__snippet` class names on DDG HTML** — the snippet anchor has class `result__snippet`; use `.find('a', class_='result__snippet')` not `.find('p')`.
- **Bing returns unrelated "Cursor" results** when searching for "cursor ai" (conflicts with the cursor pointer/custom-cursor sites). Always include "coding" or "IDE" or `site:cursor.com` to disambiguate.
- **SPA pages served to curl often look like complete pages** but are actually just the shell — the main content div will be empty or contain only navigation. Don't stop at the first 200 lines of HTML; search specifically for the content area or structured data tags.
- **`uv pip install` fails without `--system` flag** on this machine when no venv is active. Use `uv pip install --system <packages>` or `uv run --with <packages> python -c "..."`.
- **Coursera course pages are fully client-rendered SPAs** — a raw `curl` returns only the empty shell. The reliable extraction path:
  1. Call the public metadata API: `https://www.coursera.org/api/courses.v1?q=slug&slug=<slug>&fields=name,description,workload,partnerIds,instructorIds` (returns course ID)
  2. Fetch the full HTML page and extract the `<script type="application/ld+json">` block containing `@type: "Course"` with `syllabusSections` array — this contains *all* module names, full descriptions, and ISO 8601 `timeRequired` durations.
  3. For per-lecture granularity, `onDemandCourseMaterials.v2?q=slug&slug=<slug>&includes=modules,lessons,items` **does** work (no auth) and returns all lesson names, lesson IDs, slugs, and time estimates. Earlier notes saying it errors were wrong — only certain sub-endpoints fail.
- **Wayback Machine for historical snapshots**: Use CDX API (`/cdx/search/cdx?url=<url>&matchType=prefix&output=json`) to find cached versions, but prefer live JSON-LD extraction since Coursera keeps schema current.
- **Wikipedia/Web API Rate Limiting**: High-frequency requests to public APIs can trigger HTTP 429 "Too Many Requests" errors. Always include a descriptive `User-Agent` (e.g., `ResearchBot/1.0`) in request headers, implement rate-limiting delays between requests, and prioritize local caching of fetched content to avoid re-fetching.

---

## References
- `references/cursor-ai-pricing-sep2026.md` — Cursor AI plan details as of September 2026
- `references/ai-coding-subscription-analysis-sep2026.md` — Comparative analysis of AI coding subscriptions (Poe, Augment, Abacus, Cursor, Phind, ChatGPT Pro) as of September 2026
- `references/coursera-course-extraction.md` — Proven Coursera API + JSON-LD extraction workflow; includes Interactive Computer Graphics (Igarashi/U Tokyo) module table as a worked example
- `references/wikipedia-scraping-tips.md` — Best practices for fetching and caching Wikipedia content to avoid rate-limiting (HTTP 429) errors.
