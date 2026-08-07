# HillDave Agency Funnel — Handoff / Resume Notes

_Last updated: **2026-08-07** — page live at **position.hilldave.com**, email sequence built and ON, sending domain DKIM-verified. **One item left: click "Check again" on the SPF row in HubSpot.**_

---

## ▶ START HERE WHEN YOU COME BACK

**The only outstanding action is a single button click.**

1. Go to: HubSpot → **Settings → Domains & URLs → Domains → Email Sending**
   (or `https://app.hubspot.com/settings/50739084/domains/add-domain/HOSTING_SETUP/EMAIL/hilldave.com`)
2. Click **Check again**.

**Why it failed the first time:** nothing is wrong with your DNS. The SPF record is correct and live — verified directly against both the authoritative nameserver and four public resolvers. HubSpot had cached the *old* SPF value, and that record's TTL is **3600 seconds (1 hour)**. So it clears within an hour of when you saved it. This is the same cause as the DKIM row, which took ~5 minutes (that one was governed by the zone's 300-second negative-cache TTL — different mechanism, much shorter).

**If it still fails after an hour**, then something real is wrong. Re-run the verification commands at the bottom of this file first — do not start editing DNS on the assumption HubSpot is right.

⚠️ **Do NOT "fix" the SPF typo HubSpot displays.** Its table renders your record as `v=spf1 include:_spf.-google.com ~all` with a hyphen. That hyphen is a line-wrap artifact in HubSpot's UI, not in your DNS. The real record is correct. Editing it to match what that screen appears to show would break working SPF and take your Google Workspace mail with it.

---

## Current state — 2026-08-07

| Piece | State |
|---|---|
| Landing page | ✅ **LIVE** at https://position.hilldave.com/ (HTTP 200) |
| Form → HubSpot | ✅ Verified HTTP 200 with the live payload |
| Email #1 `position 1 of 3 - started` | ✅ Published, content verified clean |
| Email #2 `Position 2 of 3` | ✅ Published, content verified clean |
| Simple workflow | ✅ **ON** — form submit → #1 → 4hr delay → #2 |
| Sending domain DKIM | ✅ **Connected** |
| Sending domain SPF | ⏳ Record correct & live; **needs "Check again"** |
| DMARC | ✅ `v=DMARC1; p=none;` (monitor only) |

---

## 🔴 Three silent failures found and fixed on 2026-08-07

All three would have caused the funnel to fail with **no visible error anywhere**. Worth remembering the pattern: every one lived in a *seam between two systems*, and each system looked fine on its own.

### 1. Form definition didn't match the page (CRITICAL — was live)
Two fields were cut from the landing page (the "what does your brand do" essay was removed entirely; "top three competitors" became optional), but the **HubSpot form still had both marked Required**. The Forms API rejected every submission:

```
HTTP 400
REQUIRED_FIELD: 'your_top_three_competitors_' is missing
REQUIRED_FIELD: 'what_does_your_brand_do__what_is_the_benefit_' is missing
```

Invisible because the page's JS redirects to the scheduler regardless of whether the API call succeeds.

**Fix:** both fields set to not-Required on the HubSpot form. Verified 200.

**⚠️ ONGOING RULE:** the HubSpot form's field list must always match the `FIELDS` array in `hilldave-agency-funnel.html`.
- Adding a **required** field in HubSpot that the page doesn't send → 400 on every submission.
- **Deleting** a field from HubSpot that the page still sends → also 400.
- This is why you must not accept HubSpot's suggestions to "Add a data privacy field" or "Enable reCAPTCHA" on that form.

### 2. The workflow was OFF and its one action was broken
The July workflow existed but was switched off, and its single Send email step pointed at a deleted email ("Send Unknown Email" / "Changes needed"). Fixed and turned on.

### 3. Leftover template boilerplate in email #2
Unedited Plain Email 3 placeholder copy survived below the signature — *"Something Powerful / Tell The Reader More / Bullets are great / For spelling out benefits and / Turning visitors into leads."* Would have shipped to every lead. Deleted.

Related: a `NEXT_SLOTS_DATE_RANGE` placeholder was live **on the page itself**, inside a line that carried its own `<!-- DEPLOY BLOCKER -->` comment. Removed.

**Lesson:** placeholder copy is the recurring bug class here. Page, email, and form each verified fine in isolation. Nothing tested the seams.

---

## Landing page changes shipped 2026-08-07

1. **Removed the `NEXT_SLOTS_DATE_RANGE` placeholder.** Deliberately did *not* replace it with hardcoded dates — a static range goes stale silently and becomes the same bug. The scheduler shows real availability one click later. Capacity line now reads: *"We take twelve of these a month, because each one is real work."*
2. **Killed the price-comparison line.** "Less than a freelancer. A whole agency's judgment." → **"Re-priced by technology. Not by a lower standard."** Rule: nothing HillDave makes is ever framed by its cost. Note the `<h2>` above already says "Fortune 500 discipline," so don't reintroduce that phrase in the note.
3. **Form cut from 7 required to 5 required + 1 optional.** The essay field is gone (it contradicted "no questionnaire, no discovery call"). Competitors is optional, labelled *"Optional — we'll find them anyway."*
4. **UTM forwarding added.** The scheduler is on a different host and inherited nothing, so UTMs died at the hand-off. `ATTRIB` now forwards `utm_*`, `gclid`, `fbclid`, `li_fat_id`, `ttclid`, `msclkid` into the scheduler URL. Tested for full-UTM, organic (emits no empty keys), single-word name, and `&`/`=` encoding.

**Kept deliberately:** *"the team's work has shipped for"* above the logo wall — more defensible than implying HillDave Labs served Coca-Cola directly. Mirrored in the wall's `aria-label` too.

---

## Where everything lives

| Thing | Value |
|---|---|
| **Live page** | https://position.hilldave.com/ |
| **Source of truth** | `~/hilldave-agency-funnel/agency-funnel/hilldave-agency-funnel.html` |
| **Droplet webroot** | `/var/www/position.hilldave.com/index.html` |
| **nginx vhost** | `/etc/nginx/sites-available/position.hilldave.com` |
| **Droplet** | `root@192.34.59.130` (key `~/.ssh/hilldave_do`) |
| **Rollback (pre-2026-08-07)** | `/root/backups/position/index.html.2026-08-07-pre-copy-edits` |
| **HubSpot portal** | `50739084` (na1) — **Starter Customer Platform** |
| **HubSpot form** | "AdAgency Submission Form" · GUID `a60dae9a-38f3-4a92-874b-4e20bc74bb81` |
| **Scheduler** | https://meetings.hubspot.com/scott-weitz/hilldave-first-meet |
| **Email #1 object id** | `577592877086` |
| **Email #2 object id** | `577104098670` |
| **DNS** | Squarespace panel (domain migrated off Google Domains); nameservers still `ns-cloud-*.googledomains.com` |

### Deploy
```bash
scp -i ~/.ssh/hilldave_do \
  ~/hilldave-agency-funnel/agency-funnel/hilldave-agency-funnel.html \
  root@192.34.59.130:/var/www/position.hilldave.com/index.html
```
Static file — no service restart needed.

---

## HubSpot tier constraints (Starter Customer Platform)

Confirmed by HubSpot's own assistant and by the API (`CAMPAIGN` = `REQUIRES_ACCOUNT_MODIFICATION`; seats = `core`, `sales-starter`, `service-starter`).

- **Simple email automation only** — not full workflow automation.
- **Max 10 automated actions**, portal-wide. Current sequence uses 3.
- **Only ONE simple workflow per form.** "+ Add a new simple workflow" is padlocked. Anything else you want (e.g. an internal notification on each booking) must go inside the existing workflow.
- Available actions: Delay, Send another marketing email, Send internal email notification, Create task, Add/remove from static list, Add/remove from ads audience.
- **NOT available:** meeting-booked triggers, date-relative delays ("24h before the meeting"), if/then branching, Campaigns.
- Automation lives **inside the form editor** (Automation panel), *not* in a Workflows app. There is no Workflows app on this tier.

### Consequence for the email sequence
The original 4-message design assumed Pro features. What's actually built:

| Message | How it fires | Status |
|---|---|---|
| #1 Started | Simple workflow, form-submission trigger, immediate | ✅ built |
| #2 What you'll have | Same workflow, 4-hour delay | ✅ built |
| #3 "Tomorrow — your position is ready" | **HubSpot Meetings' own native reminder**, set on the scheduling page — works at every tier and fires off the real booking time | ❌ NOT SET UP |
| #4 Delivery of position + ads | **Manual send, by you.** Carries real deliverables and would otherwise go to no-shows | ❌ by design |

**#1 is worded for a form-submission trigger, not a booking** — it says *"Your details are in, and we've started… if you haven't picked a time yet, that's the one thing left"* with a `Choose your slot` link. Do not reword it to claim the meeting is confirmed; on this tier the trigger can't know that.

---

## Email settings that matter

- **From:** `scott.weitz@hilldave.com` · **Subscription type:** `One to One` (NOT Marketing Information — otherwise a marketing opt-out kills someone's own booking confirmation)
- **Email type:** `Automated` — **cannot be changed after creation.** Clone an existing one rather than building fresh.
- **`firstname` default = `there`** (portal-wide, Settings → Marketing → Email → Configuration → Personalization). Renders "Hello there," when the token is empty. Without a default, HubSpot blocks publish.
- **Footer** is portal-wide at Settings → Marketing → Email → Configuration → **Footer addresses**. Address is a **virtual office** (not Scott's home) — CAN-SPAM requires a physical address and it cannot be removed. Phone number cleared. A `7th Floot` → `7th Floor` typo was fixed here.
- **"Don't send to unengaged contacts" must stay OFF** — everyone submitting this form is a first-time contact.
- **"Set new contacts as marketing contacts" is ON** on the form. Required, because only marketing contacts can receive these emails. **Caveat:** it only applies to *new* contacts. An existing non-marketing contact who submits won't receive the sequence — so **test with an address not already in the CRM**, or you'll misdiagnose a contact-status issue as a broken workflow.

---

## Verification commands (use these before trusting any UI)

```bash
# Page live + placeholders gone
curl -s -o /dev/null -w "%{http_code}\n" https://position.hilldave.com/
curl -s https://position.hilldave.com/ | grep -c "NEXT_SLOTS_DATE_RANGE"   # want 0

# Does the live page's payload actually get accepted? (creates a test contact)
curl -s -X POST 'https://api.hsforms.com/submissions/v3/integration/submit/50739084/a60dae9a-38f3-4a92-874b-4e20bc74bb81' \
  -H 'Content-Type: application/json' \
  -d '{"fields":[
    {"objectTypeId":"0-1","name":"firstname","value":"ZZTest"},
    {"objectTypeId":"0-1","name":"company","value":"ZZ Test Co"},
    {"objectTypeId":"0-1","name":"website","value":"zztest.example.com"},
    {"objectTypeId":"0-1","name":"your_top_three_competitors_","value":""},
    {"objectTypeId":"0-1","name":"email","value":"zztest@example.com"},
    {"objectTypeId":"0-1","name":"monthly_ad_spend","value":"Under $2,500"}
  ],"context":{"pageUri":"https://position.hilldave.com/","pageName":"check"}}' \
  -w "\n---HTTP %{http_code}---\n"

# DKIM
dig +short @8.8.8.8 CNAME hs1-50739084._domainkey.hilldave.com   # -> hilldave-com.hs04a.dkim.hubspotemail.net.
dig +short @8.8.8.8 CNAME hs2-50739084._domainkey.hilldave.com   # -> hilldave-com.hs04b.dkim.hubspotemail.net.

# SPF — MUST return exactly 1
dig +short @8.8.8.8 TXT hilldave.com | grep -c "v=spf1"

# Google Workspace mail unharmed
dig +short @8.8.8.8 MX hilldave.com    # -> 1 smtp.google.com.
```

### Current correct DNS values
```
CNAME  hs1-50739084._domainkey  ->  hilldave-com.hs04a.dkim.hubspotemail.net.
CNAME  hs2-50739084._domainkey  ->  hilldave-com.hs04b.dkim.hubspotemail.net.
TXT    @                        ->  v=spf1 include:_spf.google.com include:50739084.spf03.hubspotemail.net ~all
```
**Exactly one SPF record. Two `v=spf1` records invalidate both and break Google Workspace mail too.**
In Squarespace, the NAME field takes the bare label (`hs1-50739084._domainkey`), never the FQDN — appending `.hilldave.com` yields `...hilldave.com.hilldave.com` and fails silently.

---

## Outstanding items

### 1. Click "Check again" on SPF ← the only blocker
See top of file.

### 2. Real end-to-end test — the actual completion criterion
Submitting the live form and confirming email #1 arrives. Nothing else proves it. Use an address **not already in HubSpot**. This exercises page → API → form → marketing-contact status → workflow → authenticated send. Every failure found today was in a seam like these, and none surfaced an error.

### 3. Turn on HubSpot Meetings' native reminder (covers message #3)
On the scheduling page settings. Free at this tier, and it fires off the real booking time — which the workflow tier cannot do.

### 4. Message #4 stays manual
Draft written; see the "Consequence for the email sequence" table above.

### 5. Delete the test contact
`ZZTest Deleteme` / `zztest-formcheck@example.com` — created by Claude verifying the 400 fix. Scott was asked and hadn't answered.

### 6. Minor / cosmetic
- **`#intake-form` shadow form.** HubSpot's tracking script auto-detected the raw `<form id="intake-form">` and logged it as a separate "Non-HubSpot form" with its own submission count. Harmless, but it means submission counts won't reconcile, and **automation attached to `AdAgency Submission Form` will not fire for anything captured under `#intake-form`.**
- **Stale thank-you panel** on the HubSpot-hosted form: *"Your intake is in. Your ad copy will be prepared before your meeting."* Landing-page visitors never see it (the custom JS redirects straight to the scheduler), and it says "ad copy" where the page promises position *and* ads. Either update or knowingly abandon.
- **Stale HTML comment** at line ~482 of the page: `add <source src="YOUR_VIDEO.mp4">`. Videos are already wired. Not user-visible.
- **Subject-line punctuation.** #1 is `We've started on your position.` and #2 is `What you'll have by the end of the call.` — both end with periods now. Keep them consistent.

### 7. Repo hygiene
`agency-funnel/hilldave-agency-funnel.html` has uncommitted changes, and two untracked assets (`assets/logos/mark.png`, `mark-dark.png`). **HEAD is older than what's live.** The droplet backup is the real rollback point until this is committed.

---

## Historical: what fixed the July "spam" problem
HubSpot marked every submission as spam, type **"Unregistered Site Domain."** Fix: **Settings → Tracking & Analytics → Tracking Code → Additional site domains → add the ROOT domain** (`hilldavelabs.com` at the time). Adding only the subdomain did not work.

**Now that the page lives on `position.hilldave.com`, confirm `hilldave.com` is also in that list.** Spam count currently reads 0 across 9 submissions, so it appears fine — but it was never explicitly checked after the domain move.

---

## Field mapping (page → HubSpot property)
| Form label | HubSpot property | Required on page? | Scheduler prefill |
|---|---|---|---|
| Name | `firstname` | yes | `firstName` + `lastName` (split on first space) |
| Brand | `company` | yes | `company` |
| Website | `website` | yes | — |
| Your top three competitors | `your_top_three_competitors_` | **no — optional** | — |
| Email | `email` | yes | `email` |
| Monthly ad spend | `monthly_ad_spend` | yes | — |
| ~~What does your brand do?~~ | ~~`what_does_your_brand_do__what_is_the_benefit_`~~ | **REMOVED from page** — property still exists, no longer populated | — |

---

## How to resume with Claude Code
> _"Read `~/hilldave-agency-funnel/HANDOFF.md`. The only thing left is clicking Check again on the HubSpot SPF row — verify my DNS is still correct first, then help me do the real end-to-end test."_
