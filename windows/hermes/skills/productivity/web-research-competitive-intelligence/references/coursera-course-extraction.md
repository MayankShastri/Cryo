# Coursera Course Data Extraction — Reference

## Why direct curl fails
Coursera course pages (`/learn/<slug>/`) are fully client-rendered SPAs. A plain `curl` returns only the shell HTML (fonts, Statsig experiment payloads, nav) — no course content.

## Extraction sequence (proven, no auth required)

### Step 1 — Course metadata via Coursera public API
```bash
curl -s "https://www.coursera.org/api/courses.v1?q=slug&slug=<SLUG>&fields=name,description,id,workload,partnerIds,instructorIds,courseStatus" \
  -H "Accept: application/json"
```
Returns: `id` (used as course UUID in subsequent API calls), `description`, `workload`, `name`, etc.

**Example for Interactive Computer Graphics (Takeo Igarashi / U Tokyo):**
- slug: `interactive-computer-graphics`
- course ID: `Qx-vkAocEeWAYyIACmGIdw`

### Step 2 — Full syllabus via JSON-LD in HTML
```bash
curl -s "https://www.coursera.org/learn/<SLUG>" \
  -L --max-time 20 \
  -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
| python3 -c "
import sys, re, json
html = sys.stdin.read()
ld_matches = re.findall(r'<script[^>]*type=\"application/ld\+json\"[^>]*>(.*?)</script>', html, re.S)
for m in ld_matches:
    try:
        d = json.loads(m)
        if 'syllabusSections' in d:
            print(json.dumps(d, indent=2))
    except:
        pass
"
```

The JSON-LD block with `@type: "Course"` contains:
- `name`, `description`, `educationalLevel`
- `teaches[]` — learning outcomes
- `about[]` — skill tags
- `syllabusSections[]` — **all modules with full descriptions and `timeRequired` (ISO 8601)**
- `hasCourseInstance[].instructor` — instructor name, affiliation, photo
- `aggregateRating`, `totalHistoricalEnrollment`

### Step 2b — Full lesson list via onDemandCourseMaterials API (no auth)
This API *does* work for fetching lesson/item-level detail (despite earlier notes — routing errors are endpoint-specific):
```bash
curl -s "https://www.coursera.org/api/onDemandCourseMaterials.v2/?q=slug&slug=<SLUG>&includes=modules,lessons,items"
```
Returns `linked.onDemandCourseMaterialModules.v1[]` (week-level) and `linked.onDemandCourseMaterialLessons.v1[]` (lesson-level with item IDs, names, slugs, time estimates). Useful when you need per-lecture granularity JSON-LD doesn't give you.

### What NOT to try
- Wayback Machine for freshness — live JSON-LD schema is kept more current than snapshots
- DuckDuckGo HTML scraping for specific course resources — DDG returns an anomaly/captcha challenge page when queries are too specific; returns empty content even when status is 200

---

## Academic Lab Site Mining (for MOOC resources)

When a Coursera course is taught by a researcher (not a course-specific instructor), the real study materials live on the **instructor's academic lab website**, not Coursera. Pattern:

### 1. Find the lab homepage
- Common patterns: `https://<dept>.is.<university>.ac.jp/~<name>/` or `https://<name>lab.<university>.edu/`
- Igarashi's page: `http://www-ui.is.s.u-tokyo.ac.jp/~takeo/`
- Look for a `course/` or `research/Projects.html` page (often Japanese, readable via browser translate)

### 2. Watch for UTF-16 encoded HTML
Japanese academic lab sites sometimes serve UTF-16 pages. Python's `response.read().decode('utf-8')` returns garbled null-filled output. Fix:
```python
resp_bytes = response.read()
for enc in ['utf-16', 'utf-8', 'latin-1', 'shift-jis']:
    try:
        text = resp_bytes.decode(enc)
        break
    except:
        continue
```

### 3. Map course topics → original papers
For research-based courses, each lecture topic is typically one published paper. Strategy:
1. Fetch the instructor's full publications page (e.g. `research/papers.html`)
2. Extract all PDF links with `re.findall(r'href="([^"]+\.pdf)"', text)`
3. Cross-reference against the course lesson names extracted from onDemandCourseMaterials API
4. Validate PDFs are live: send a HEAD request and check Content-Length > 0

### 4. GitHub demo repos
Search GitHub for both `"<InstructorName>" "<CourseName>"` and `site:<coursera_url>` patterns:
```python
# Via GitHub API (no auth needed for repo search)
url = 'https://api.github.com/search/repositories?q=interactive+computer+graphics+igarashi&per_page=10'
```
Look for repos whose README links directly back to the Coursera course URL.

---

## Interactive Computer Graphics — Module Summary (reference, Sep 2026)

| # | Module | Key Topics | Time |
|---|--------|-----------|------|
| 1 | Graphical User Interfaces | Scrolling, desktop icon management, large display pointing, digital inking, vocal interaction | 3h 19m |
| 2 | 2D Drawing & Animation | Diagram beautification, pen-and-ink texture synthesis, ARAP shape deformation, dynamic illustrations | 3h 14m |
| 3 | 3D Geometric Modeling | Suggestive interfaces, sketch-based Teddy modeling, curve-based control, flower/organic shapes | 3h 35m |
| 4 | Deformation & Animation | Clothing/fabric manipulation, spatial keyframing, procedural deformation, motion visualization | 4h 2m |
| 5 | Digital Fabrication | Plush toy pattern gen, beadwork, folded paper/chairs, 2D/3D packing | 3h 49m |
| 6 | Computer-Aided Design | Real-time physical simulation: cantilevers, instruments, garments, furniture, gliders | 3h 52m |
| 7 | Human-Robot Interaction | Command cards, style-by-demonstration, actuated puppets, robotic lighting/fur displays | 4h 24m |

**Total estimated workload**: ~26h 15m | **Rating**: 4.04/5 (318 reviews) | ~110,979 enrolled  
**Course URL**: https://www.coursera.org/learn/interactive-computer-graphics  
**Old slug**: https://www.coursera.org/course/interactivegraphics (both work)

---

## Interactive Computer Graphics — Source Papers by Topic

All PDFs live at `http://www-ui.is.s.u-tokyo.ac.jp/~takeo/papers/<filename>`.

| Course Topic | Paper PDF | Project Page |
|---|---|---|
| 1-1 Scrolling / Auto-Zoom | [uist2000.pdf](http://www-ui.is.s.u-tokyo.ac.jp/~takeo/papers/uist2000.pdf) | [autozoom](http://www-ui.is.s.u-tokyo.ac.jp/~takeo/research/autozoom/autozoom.htm) |
| 1-x Bubble Clusters / Pointing | [watanabe_uist2007_bubble.pdf](http://www-ui.is.s.u-tokyo.ac.jp/~takeo/papers/watanabe_uist2007_bubble.pdf) | [bubble](http://www-ui.is.s.u-tokyo.ac.jp/~takeo/research/bubble/index.html) |
| 1-5 Voice Interaction | [voice.pdf](http://www-ui.is.s.u-tokyo.ac.jp/~takeo/papers/voice.pdf) | [voice](http://www-ui.is.s.u-tokyo.ac.jp/~takeo/research/voice/voice.htm) |
| 2-3 ARAP Shape Manipulation | [rigid.pdf](http://www-ui.is.s.u-tokyo.ac.jp/~takeo/papers/rigid.pdf) | [rigid](http://www-ui.is.s.u-tokyo.ac.jp/~takeo/research/rigid/index.html) |
| 3-1 Suggestive Interface | [chateau.pdf](http://www-ui.is.s.u-tokyo.ac.jp/~takeo/papers/chateau.pdf) | [chateau](http://www-ui.is.s.u-tokyo.ac.jp/~takeo/research/chateau/chateau.htm) |
| 3-2 Teddy Sketch-based 3D | [siggraph99.pdf](http://www-ui.is.s.u-tokyo.ac.jp/~takeo/papers/siggraph99.pdf) | [teddy](http://www-ui.is.s.u-tokyo.ac.jp/~takeo/research/teddy/teddy.htm) |
| 3-3 Smooth Meshes (FiberMesh) | [i3dg2003.pdf](http://www-ui.is.s.u-tokyo.ac.jp/~takeo/papers/i3dg2003.pdf) | [smoothteddy](http://www-ui.is.s.u-tokyo.ac.jp/~takeo/research/smoothteddy/index.html) |
| 3-5 Interactive Texture Paint | [i3dg2001.pdf](http://www-ui.is.s.u-tokyo.ac.jp/~takeo/papers/i3dg2001.pdf) | [chameleon](http://www-ui.is.s.u-tokyo.ac.jp/~takeo/research/chameleon/chameleon.htm) |
| 4-1 Clothing Manipulation | [cloth.pdf](http://www-ui.is.s.u-tokyo.ac.jp/~takeo/papers/cloth.pdf) | [cloth](http://www-ui.is.s.u-tokyo.ac.jp/~takeo/research/cloth/index.html) |
| 4-2 Apparent Layer Operations | [layer.pdf](http://www-ui.is.s.u-tokyo.ac.jp/~takeo/papers/layer.pdf) | [layer](https://www.jst.go.jp/erato/igarashi/en/projects/layer/) |
| 4-3 Spatial Keyframing | [squirrel.pdf](http://www-ui.is.s.u-tokyo.ac.jp/~takeo/papers/squirrel.pdf) | [squirrel](http://www-ui.is.s.u-tokyo.ac.jp/~takeo/research/squirrel/index.html) |
| 5-1 Plushie / Fabrication | [Plushie System](http://www.geocities.jp/igarashi_lab/plushie/index-e.html) | — |
| 5-2 Beady Beadwork | — | [beady](https://www.is.ocha.ac.jp/~yuki/beady/index-e.html) |
| 5-5 Pteromys Glider CAD | — | [pteromys](http://www.nobuyuki-umetani.com/publication/2014_sigg_pteromys/2014_siggraph_GliderDesign.html) |
| 7-x Magic Cards Robot | — | [MagicCards](http://www.jst.go.jp/erato/igarashi/en/projects/MagicCards/index.html) |
| General survey | [cacm2010.pdf](http://www-ui.is.s.u-tokyo.ac.jp/~takeo/papers/cacm2010.pdf) | — |

**GitHub demo implementations**: https://github.com/nrox/interactive-computer-graphics  
**Live demos**: https://nrox.github.io/interactive-computer-graphics/src/01-automatic-zooming/auto-zoom.html
