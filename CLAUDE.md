# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Static company homepage for 주식회사 해윰 (HAYUM), served at https://www.hayum.kr via GitHub Pages (`CNAME`). **Pushing to `main` deploys.** There is no build, lint, or test tooling — just `index.html`, `style.css`, and `Notice/*.html` (announcement fragments loaded into a modal via `fetch` by `loadAndOpenModal`).

To preview locally: `python -m http.server` in the repo root (needed because of `fetch`).

## Architecture

- `index.html` is a single page holding all sections (Philosophy … Contact, Notice, Dividend) plus all JS inline in one `<script>` block at the bottom. No frameworks; Chart.js is lazy-loaded (`loadChartJs`) only when the dividend popup opens.
- **Dividend section (05)** is a self-contained IIFE in `index.html` that fetches public Google Sheet CSV via the gviz endpoint (`.../gviz/tq?tqx=out:csv&sheet=<name>` or `&gid=`), refreshes every 60s, and ticks counters every second (KST-based). Clicking the panel opens a detail popup (bottom sheet on mobile).
  - **S계좌** = sheet tab `ISA-일배당` (daily expected dividend + manually entered actual). Columns are located by header name (`일자`, `일배당`, `누적실배당`, `포트폴수량`, `월배당`).
  - **A계좌** = sheet tab `배당내역` (gid 1679568385), only rows with `배당금`>0; loaded by `loadReceipts()`. Scale is ~100x S계좌, so the two are **never summed**.
  - UI text uses only "S계좌"/"A계좌" labels.
- Gotcha: gviz returns the first tab (Dashboard) with no error if the sheet name doesn't exist. If a tab is renamed, update `SHEET_NAME` in `index.html`.
- Sheet is public; making it private breaks the Dividend section.

## Conventions

- Bump the `style.css?v=` query string in `index.html` whenever CSS changes (cache busting).
- Communicate in Korean. Commit/push only when the user explicitly asks to deploy ("배포해주세요").
- Deploy via `commit.bat` (pull --rebase → add -A → commit → push; cleans Google Drive `desktop.ini` junk in `.git`). From PowerShell:
  `Set-Location C:\dev\hayum; cmd /c 'echo.| "C:\dev\hayum\commit.bat" "메시지"'` (bash `cmd //c` fails).
- `handoff.md` is a gitignored local notes file with detailed sheet/calculation context; read it for deeper dividend-logic background.
- The user does not want sessions shared: avoid Artifact and Remote Control.
