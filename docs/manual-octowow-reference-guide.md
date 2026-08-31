# Manually saving octowow.st as a cross-reference

octowow.st is currently behind a Blazingfast DDoS/JS challenge that blocks
automated fetching (confirmed 2026-08-31 — see CLAUDE.md's Opus research
pass). A real browser clears the challenge automatically, so you can save
a working local copy for manually eyeballing our generated tooltips
against theirs. This is NOT being used as a data source — just a reference
to sanity-check the DBC-generated text.

## Steps

1. For each class, visit `https://octowow.st/talents/<slug>/` in your
   normal browser, where `<slug>` is one of:
   `warrior, paladin, hunter, rogue, priest, shaman, mage, warlock, druid`
2. Wait for the page to fully load (all three trees visible, tooltips
   working on hover).
3. Save the page: `Ctrl+S` (or Cmd+S), choose **"Webpage, Complete"** (not
   "Webpage, HTML only" — this matters, though for our purposes we mostly
   just need the HTML file itself, not the associated assets folder).
4. Save each one with a clear name, e.g. `mage.html`, `rogue.html`, into
   one folder — doesn't matter where, just tell me the path when you're
   ready and I can also read them directly if useful for comparison.
5. Repeat for all 9 classes.

## What to check once saved

Hover a talent on the site, note what it shows at each rank (1 through
max), and compare against what TalentStage's tooltip shows for the same
talent when you stage up to that rank in-game. They should read the same
except for very minor wording differences (their site and our DBC-derived
text both come from the same underlying spell data, so should usually
match closely, though not always word-for-word since we render from the
raw description string ourselves).

If you spot a case where our tooltip's staged-rank text looks *wrong*
(not just "talent falls back to old behavior," but definitely wrong or
implausible), flag it — that would mean the generator's oracle guard
somehow missed something (per the safety analysis in CLAUDE.md, this
should never actually reach the player, since the runtime oracle rejects
any mismatch against the live game's own scrape before showing it — but a
wrong verified-value assumption slipping through the generator's own
`verify_known_values()` sanity check would still be worth knowing about).

## Not a data source

Per CLAUDE.md's established findings: the octowow.st scrape is a useful
cross-check but not primary. The addon's actual data is generated from the
client's own DBC files (`Talent.dbc`/`Spell.dbc`/`SpellDuration.dbc`/
`SpellRadius.dbc`), which is guaranteed byte-identical to what the stock
in-game tooltip shows, unlike a third-party site one step removed from the
real data.
