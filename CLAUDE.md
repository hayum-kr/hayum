# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Static company homepage for 주식회사 해윰 (HAYUM), served at https://www.hayum.kr via GitHub Pages (`CNAME`). **Pushing to `main` deploys.** There is no build, lint, or test tooling — just `index.html`, `style.css`, and `Notice/*.html` (announcement fragments loaded into a modal via `fetch` by `loadAndOpenModal`).

To preview locally: `python -m http.server` in the repo root (needed because of `fetch`).

## Architecture

- `index.html` is a single page holding all sections (Philosophy … Contact, Notice, Dividend) plus all JS inline in one `<script>` block at the bottom. No frameworks. (Dividend charts were removed pending review; recover `renderCharts`/`loadChartJs` from git history, commit 506c3c9 or earlier.)
- **Dividend section (05)** is a self-contained IIFE in `index.html`. Forecasts come from `data/plan.json` (holdings, per-weekday buy schedule, extra-buy events; `buildSeries` generates the daily series). Actual dividends come from one public Google Sheet tab, `배당내역` (gid 1679568385), fetched via the gviz CSV endpoint (`.../gviz/tq?tqx=out:csv&gid=`), refreshed every 60s; counters tick every second (KST-based). Clicking the panel opens a detail popup (bottom sheet on mobile).
  - `배당내역` columns are located by header name: `입금일자`, `종목명`, `배당금`, `배당계좌`. Rows with `배당금`>0 only. `배당계좌` = `A계좌` or `S계좌` (missing/other → A계좌). `fetchReceipts()` splits them: S rows feed the S계좌 actual (cumulative) and the S receipts section; A rows feed the A receipts section.
  - Scale of A계좌 is ~100x S계좌. The receipts sections are per account; the monthly totals/chart at the bottom show S+A summed (stacked), per the owner's request.
  - `data/plan.json` is public; its `strategy` block is notes only (not read by the page).
  - UI text uses only "S계좌"/"A계좌" labels.
- Gotcha: gviz returns the first tab (Dashboard) with no error if a sheet *name* doesn't exist, so the page uses `gid`. If the `배당내역` tab is deleted/recreated, update the gid in `RC_URL`.
- Sheet is public; making it private breaks the Dividend section.

## Conventions

- Bump the `style.css?v=` query string in `index.html` whenever CSS changes (cache busting).
- Communicate in Korean. Commit/push only when the user explicitly asks to deploy ("배포해주세요").
- Deploy via `commit.bat` (pull --rebase → add -A → commit → push; cleans Google Drive `desktop.ini` junk in `.git`). From PowerShell:
  `Set-Location C:\dev\hayum; cmd /c 'echo.| "C:\dev\hayum\commit.bat" "메시지"'` (bash `cmd //c` fails).
- `handoff.md` is a gitignored local notes file with detailed sheet/calculation context; read it for deeper dividend-logic background.
- The user does not want sessions shared: avoid Artifact and Remote Control.
