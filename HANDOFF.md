# HillDave Agency Funnel — Handoff / Resume Notes

_Last updated: 2026-07-21 — **WORKING END-TO-END.** Only optional follow-ups remain (email notification)._

## TL;DR
The landing page is **built, deployed, live, and fully working.** The form captures **all 7 fields into HubSpot** AND redirects to the scheduler. The long-running blocker (submissions marked spam) is **SOLVED**. The only thing left — and it's optional — is setting up an **email notification** so you get pinged on each submission. You can do that anytime.

---

## ✅ Confirmed working (2026-07-21)
A live test submission landed all fields on the contact:
| Field | Captured |
|---|---|
| Name | Scott |
| Brand → `company` | HillDave LLC |
| Website → `website` | http://www.hilldave.com |
| What your brand does → `what_does_your_brand_do__what_is_the_benefit_` | "We were an ad agency." |
| Top 3 competitors → `your_top_three_competitors_` | "This, that, this, that" |
| Monthly ad spend → `monthly_ad_spend` | $15,000 – $50,000 |
| Email | scott.weitz@hilldave.com |

**Flow:** form submit → all 7 fields POST to HubSpot Forms API → redirect to scheduler (name/email/brand prefilled) → booking creates/updates the contact.

---

## 🔑 What finally fixed the "spam" problem
HubSpot was marking every submission as spam, type **"Unregistered Site Domain."** The fix was adding the **root domain** to HubSpot's tracking settings:
- **Settings → Tracking & Analytics → Tracking Code → Additional site domains → added `hilldavelabs.com`** (External).
- Key lesson: HubSpot tracks at the **root-domain** level. Adding the subdomain (`production.hilldavelabs.com`) alone did NOT work — it needed the root `hilldavelabs.com`.
- **When you add a real subdomain later, add its root domain here too.**

---

## Where everything lives
| Thing | Value |
|---|---|
| **Live page** | https://production.hilldavelabs.com/agency-funnel/ |
| **GitHub** | https://github.com/scottjamesw/hilldave-agency-funnel (public) · branches `main` + `agency-funnel`, folder `agency-funnel/` |
| **Local repo** | `~/hilldave-agency-funnel/` |
| **Droplet** | `root@192.34.59.130` (key `~/.ssh/hilldave_do`) · webroot `/var/www/hilldave-agency-funnel/` |
| **HubSpot portal** | `50739084` (region `na1`) |
| **HubSpot form** | "AdAgency Submission Form" · GUID `a60dae9a-38f3-4a92-874b-4e20bc74bb81` |
| **Scheduler** | https://meetings.hubspot.com/scott-weitz/hilldave-first-meet |
| **Your contact record** | https://app.hubspot.com/contacts/50739084/record/0-1/178165856160 |

---

## The 5 jobs — all done ✅
1. **Extracted assets** — base64 logos/posters → `assets/logos/`, `assets/posters/` (442 KB → ~25 KB).
2. **Wired videos** — 4 ad clips transcoded/compressed (168 MB → 15 MB) → `assets/videos/`, on all 8 marquee tiles. Hero video left as a static poster on purpose. Sources: Desktop `Content for Landing Page/`.
3. **Form** — custom design kept; submits all 7 fields to the Forms API + redirects to scheduler with name/email/brand prefill.
4. **"Book a meeting" buttons** — scroll to the form (`#book`). No change needed.
5. **Deployed** — live on DigitalOcean + GitHub.

Also added along the way: HubSpot tracking script (`//js.hs-scripts.com/50739084.js`), and the Website field was changed from `type="url"` to `type="text"` so bare domains (`www.hilldave.com`) don't get rejected at submit.

---

## ▶ TO DO WHEN YOU COME BACK (all optional)

### 1. Email notification on each submission (the "so I know who booked" piece)
Set up a HubSpot **workflow**:
- **Automation → Workflows → Create** → **Contact-based**.
- Enrollment trigger: **"Form submission"** → the **"AdAgency Submission Form."**
- Action: **Send internal email / in-app notification** to `scott.weitz@hilldave.com` (include the contact's brand, website, competitors, benefit, ad-spend properties in the email body via personalization tokens).
- Turn it on.
- _(Ask Claude to walk through the exact clicks if the UI differs.)_

### 2. See all leads at a glance
Contacts list → **Edit columns** → add: Company, Website, Your top three competitors, What does your brand do, Monthly ad spend → save as a view "Agency Intake Leads." Every new lead then shows its full intake in the columns.

### 3. Clean your own record
Your contact currently holds the test values ("This, that, this, that," "We were an ad agency," etc.) — blank those out if you want your real record clean: https://app.hubspot.com/contacts/50739084/record/0-1/178165856160

### 4. Custom subdomain (when ready)
Set up e.g. `agency.hilldavelabs.com`: DNS A record → `192.34.59.130`, then dedicated nginx block + certbot on the droplet (Claude knows the steps). **Then add its root domain to HubSpot's Additional Site Domains** (same place as the fix above) so submissions keep working.

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
| Monthly ad spend | `monthly_ad_spend` (5 tiers) | — |

---

## Redeploy after edits
`scp` the file to `/var/www/hilldave-agency-funnel/index.html` on the droplet + `git push`. Claude knows the exact commands.

## How to resume with Claude Code
_"Read `~/hilldave-agency-funnel/HANDOFF.md` — the funnel is working; help me set up the HubSpot email notification workflow."_
