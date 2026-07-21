# HillDave Agency Funnel — Handoff / Resume Notes

_Last updated: 2026-07-21_

## TL;DR
The landing page is **built, deployed, and live**. All 5 jobs are done. The form works end-to-end (submit → HubSpot scheduler → booking creates the contact). **One thing is still blocking the full-data capture:** HubSpot is spam-blocking the form submissions because the site domain isn't registered in HubSpot yet. **Your one action to finish:** register `production.hilldavelabs.com` in HubSpot's tracking settings (details below), then submit one test.

---

## Where it lives

| Thing | Value |
|---|---|
| **Live page** | https://production.hilldavelabs.com/agency-funnel/ |
| **GitHub** | https://github.com/scottjamesw/hilldave-agency-funnel (public — for Diego) · branches `main` + `agency-funnel`, folder `agency-funnel/` |
| **Local repo** | `~/hilldave-agency-funnel/` |
| **Droplet** | `root@192.34.59.130` (key `~/.ssh/hilldave_do`) · webroot `/var/www/hilldave-agency-funnel/` · served at the `/agency-funnel/` path via a symlink from the `production.hilldavelabs.com` webroot |
| **HubSpot portal** | `50739084` (region `na1`) |
| **HubSpot form GUID** | `a60dae9a-38f3-4a92-874b-4e20bc74bb81` |
| **Scheduler** | https://meetings.hubspot.com/scott-weitz/hilldave-first-meet |

---

## The 5 jobs — all done ✅
1. **Extracted inline assets** — base64 logos + video posters pulled out to `assets/logos/` and `assets/posters/`. Page went from **442 KB → ~24 KB**.
2. **Wired the marquee videos** — 4 ad videos transcoded + compressed (**168 MB → 15 MB**) into `assets/videos/`, added to all 8 marquee tiles.
   - `driver.mp4` = desert drive · `mom.mp4` = Baby Ktan (portrait) · `redcarpet.mp4` = red carpet · `cards.mp4` = card game (the concert/funeral/trailer-park video `vr24la`)
   - Sources are in Desktop folder `Content for Landing Page/`.
   - Hero video (top-right of hero) intentionally left as a **static poster** (`mom.jpg`).
3. **Form** — kept the custom-styled form (pixel-perfect), wired it to **submit all 7 fields to the HubSpot Forms API AND redirect to the scheduler** with name/email/brand prefilled.
4. **"Book a meeting" buttons** — verified they scroll to the form (`#book`). No change needed.
5. **Deployed** — live on DigitalOcean + pushed to GitHub.

---

## ⛔ The one remaining blocker — HubSpot "Unregistered Site Domain"

**Symptom:** Form submissions return HTTP 200 but **don't create/update the contact's fields**. HubSpot's **Spam Submissions** log shows them flagged as **"Unregistered Site Domain."**

**Cause:** HubSpot auto-flags submissions from any domain not registered in its analytics/tracking settings. `production.hilldavelabs.com` isn't registered.

**What currently works despite this:** name + email + the meeting booking (booking a slot creates/updates the contact and logs the "Meetings Link" conversion). **What's missing:** the 5 qualifying fields (brand, website, competitors, benefit, ad spend) — which is the data you need to prep client work.

### ▶ Resume steps (do these in order)
1. **Register the domain in HubSpot:**
   - HubSpot → **Marketing → Forms** → click **"Review site domains"** in the yellow *"Unknown Domains…"* banner
   - _(or)_ **Settings ⚙️ → Tracking & Analytics → Tracking Code → Domains**
   - Add **`production.hilldavelabs.com`** → **Save**
2. **Hard-refresh** the landing page (Cmd+Shift+R) and **submit the form once more** (old submissions won't retro-unblock).
3. **Verify:** ask Claude to check the contact via the HubSpot API for all 7 fields, or open the contact in HubSpot. If brand/website/competitors/benefit/ad-spend are populated → **done.**
4. **Turn on the submission-notification email** (so you're emailed each intake): HubSpot → Marketing → Forms → your form → **Automation / Options** → add `scott.weitz@hilldave.com` as a notification recipient. (Note: the "Send email → Send Unknown Email" node in Automation is a *follow-up email to the submitter* — not this; leave it.)

---

## Field mapping (page → HubSpot property)
| Form label | HubSpot property | Scheduler prefill |
|---|---|---|
| Name | `firstname` | `firstName` + `lastName` (split on first space) |
| Brand | `company` | `company` |
| Website | `website` | — |
| What does your brand do?… | `what_does_your_brand_do__what_is_the_benefit_` | — |
| Your top three competitors | `your_top_three_competitors_` | — |
| Email | `email` | `email` |
| Monthly ad spend | `monthly_ad_spend` | — |

`monthly_ad_spend` property now has all 5 tiers (the `$5,000 – $15,000` one was missing and you added it).

---

## Fixes made along the way
- **Website field** was `type="url"` and rejected bare domains (`www.hilldave.com`) → changed to `type="text"` so users aren't blocked.
- **Added the HubSpot tracking script** (`//js.hs-scripts.com/50739084.js`) — sets the `hubspotutk` cookie so submissions are identified (the one tracking-script exception you approved).

## Optional / later
- **Custom subdomain** (e.g. `agency.hilldavelabs.com`): needs a DNS A record → `192.34.59.130`, then a dedicated nginx block + certbot. **Also add that subdomain to HubSpot site domains** when you do.
- **Redeploy after edits:** `scp` the file to `/var/www/hilldave-agency-funnel/index.html` on the droplet + push to GitHub (Claude knows the exact commands).
- 3 test spam submissions (~6:26–6:32 AM) + 1 real (~14:10) sit in HubSpot's spam log — harmless, auto-delete in 90 days.

---

## How to resume with Claude Code
Point Claude at this file: _"Read `~/hilldave-agency-funnel/HANDOFF.md` — I've registered the domain in HubSpot, let's verify the form captures all 7 fields."_
