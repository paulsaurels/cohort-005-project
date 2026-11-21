# DevUI selector dismissal evidence

Screenshots use the local seeded app at `/courses`, 1280 × 577 viewport.
Images are cropped to the rightmost 360 pixels and JPEG-compressed; they are
not mockups or edited UI states.

| Interaction                                       | Before                                    | After                                             |
| ------------------------------------------------- | ----------------------------------------- | ------------------------------------------------- |
| Select Emma Wilson                                | [List remains open](before-selection.jpg) | [List closed, Emma selected](after-selection.jpg) |
| Click the Browse Courses heading outside the list | [List remains open](before-outside.jpg)   | [List dismissed](after-outside.jpg)               |

The two before screenshots look identical because the outside click did not
change the broken UI. The regression is also asserted against the DOM; screenshots
alone do not prove event handling.

## Repeat the browser checks

With the standard database seed, the dev server running, and `agent-browser`
plus its Chrome installation available:

```bash
npm run dev
# In another terminal:
npm run test:dev-ui-browser
```

Optional environment variables:

- `BASE_URL`: server address (default `http://localhost:5173`).
- `AGENT_BROWSER`: path to the browser executable.
- `BROWSER_SESSION`: isolated browser session name.
- `EVIDENCE_DIR`: output directory for uncropped after screenshots.

The script verifies selection/session update, outside click, Escape/focus return,
trigger toggling, minimize/restore, and the absence of browser errors. It switches
the local session through Alex Rivera and Emma Wilson; it does not modify course
data. The browser session is closed on exit.
