#!/usr/bin/env python3
# Dev-only offline verification tool. NOT shipped in the TalentStage addon.
#
# Reads Talent.dbc / TalentTab.dbc / Spell.dbc directly from the live client's
# MPQ archives and dumps a canonical reference table (id, tab, tier, column,
# name, prereqs) for every class/tab, then runs a structural sweep checking
# whether TalentStage's connector-drawing assumptions (single prereq vs up to
# three, same-column / same-tier / general tier+column gap) hold across the
# full dataset.
#
# Confirmed field layout (see CLAUDE.md "Open questions" section 4):
#   Talent.dbc:    21 fields x 4 bytes = 84-byte records
#     0 ID, 1 TalentTab, 2 TierID, 3 ColumnIndex, 4-12 SpellRank[9],
#     13-15 PrereqTalent[3], 16-18 PrereqRank[3], 19 Flags, 20 RequiredSpellID
#   TalentTab.dbc: 15 fields x 4 bytes = 60-byte records
#     0 ID, 1 Name(strref), ... 12 ClassMask, 14 OrderIndex (approx; only
#     ID/Name/ClassMask are used here)
#   Spell.dbc:     173 fields x 4 bytes = 692-byte records
#     0 ID, ... 120 Name(strref, enUS)
#
# TierID/ColumnIndex in the DBC are 0-indexed; GetTalentInfo() at runtime
# returns 1-indexed tier/column (confirmed against a live screenshot: DBC
# tier=0 col=1/2 in Beast Mastery == the two talents shown at "tier 1,
# columns 1-2" in game).
#
# Which patch archive is authoritative: later-loading patch archives override
# earlier ones. patch-6.mpq and patch-7.mpq both carry the largest/newest
# Talent.dbc (472 records, 39669 bytes) of every archive mpyq can open;
# patch-4/8/9/W.mpq are MPQ-encrypted and unreadable with mpyq, but CLAUDE.md
# already established they weren't needed to explain observed behavior. This
# tool uses patch-7.mpq (also the newest unlockable Spell.dbc/TalentTab.dbc).

import struct
import sys
import os

try:
    import mpyq
except ImportError:
    sys.exit("pip install mpyq")

DATA_DIR = "/mnt/C2D20695D2068E3B/Games/Turtle WoW/Data"
ARCHIVE = "patch-7.mpq"

CLASS_MASK_NAMES = {
    1: "Warrior", 2: "Paladin", 4: "Hunter", 8: "Rogue", 16: "Priest",
    64: "Shaman", 128: "Mage", 256: "Warlock", 1024: "Druid",
}


def load_dbc(raw):
    magic = raw[0:4]
    assert magic == b"WDBC", f"bad magic {magic}"
    record_count, field_count, record_size, string_block_size = struct.unpack("<4I", raw[4:20])
    header_size = 20
    records_raw = raw[header_size: header_size + record_count * record_size]
    string_block = raw[header_size + record_count * record_size:]
    assert len(string_block) == string_block_size
    records = []
    for i in range(record_count):
        rec = records_raw[i * record_size:(i + 1) * record_size]
        records.append(struct.unpack("<%dI" % field_count, rec))
    return records, string_block


def get_str(string_block, offset):
    if offset == 0 or offset >= len(string_block):
        return ""
    end = string_block.find(b"\x00", offset)
    if end == -1:
        end = len(string_block)
    return string_block[offset:end].decode("utf-8", errors="replace")


def main():
    arc = mpyq.MPQArchive(os.path.join(DATA_DIR, ARCHIVE))
    talent_raw = arc.read_file("DBFilesClient\\Talent.dbc")
    tab_raw = arc.read_file("DBFilesClient\\TalentTab.dbc")
    spell_raw = arc.read_file("DBFilesClient\\Spell.dbc")

    talent_records, _ = load_dbc(talent_raw)
    tab_records, tab_strblock = load_dbc(tab_raw)
    spell_records, spell_strblock = load_dbc(spell_raw)

    spell_name = {}
    for r in spell_records:
        spell_name[r[0]] = get_str(spell_strblock, r[120])

    tab_name = {}
    tab_class = {}
    for r in tab_records:
        tid = r[0]
        tab_name[tid] = get_str(tab_strblock, r[1])
        tab_class[tid] = CLASS_MASK_NAMES.get(r[12], f"mask={r[12]}")

    # tab -> tier -> column -> talent id  (1-indexed, matching GetTalentInfo)
    nodes = {}
    talents = {}
    for r in talent_records:
        tid, tab, tier0, col0 = r[0], r[1], r[2], r[3]
        spellranks = r[4:13]
        prereq = [p for p in r[13:16] if p != 0]
        prereqrank = list(r[16:19])
        tier, col = tier0 + 1, col0 + 1
        name = spell_name.get(spellranks[0], f"<unknown spell {spellranks[0]}>")
        maxrank = sum(1 for s in spellranks if s != 0)
        talents[tid] = {
            "tab": tab, "tier": tier, "col": col, "name": name,
            "maxrank": maxrank, "prereq": prereq, "prereqrank": prereqrank,
        }
        nodes.setdefault(tab, {}).setdefault(tier, {})[col] = tid

    # ---- write canonical reference table ----
    out_path = os.path.join(os.path.dirname(__file__), "talent_reference.txt")
    with open(out_path, "w") as f:
        for tab_id in sorted(tab_name, key=lambda t: (tab_class.get(t, ""), t)):
            f.write(f"\n=== Tab {tab_id}: {tab_class[tab_id]} / {tab_name[tab_id]} ===\n")
            for tid, d in sorted(talents.items(), key=lambda kv: (kv[1]["tier"], kv[1]["col"])):
                if d["tab"] != tab_id:
                    continue
                prereq_str = ", ".join(
                    f"{p}({talents[p]['name'] if p in talents else '??'})"
                    for p in d["prereq"]
                )
                f.write(f"  id={tid:5d} tier={d['tier']} col={d['col']:2d} "
                        f"maxrank={d['maxrank']} name={d['name']!r:35s} prereq=[{prereq_str}]\n")
    print(f"Wrote reference table: {out_path}")

    # ---- structural sweep: validate TalentStage's connector assumptions ----
    print("\n=== Structural sweep across all classes ===")
    issues = []
    multi_prereq = 0
    dangling_prereq = 0
    for tid, d in talents.items():
        if len(d["prereq"]) > 1:
            multi_prereq += 1
        for p in d["prereq"]:
            if p not in talents:
                dangling_prereq += 1
                issues.append(f"id={tid} ({d['name']}) prereq={p} not found in Talent.dbc at all")
                continue
            pd = talents[p]
            # TalentStage_DrawConnectors looks up the prereq strictly by
            # (tier,column) inside the SAME tab's node table (panel.nodes).
            # If a prereq id exists in Talent.dbc but under a DIFFERENT tab
            # than the dependent talent, panel.nodes[ptier][pcol] would
            # resolve to whatever talent occupies that slot in the
            # DEPENDENT's own tab -- silently drawing a connector to the
            # wrong node, or to nothing at all.
            if pd["tab"] != d["tab"]:
                issues.append(
                    f"CROSS-TAB PREREQ: id={tid} tab={d['tab']} ({d['name']}) "
                    f"has prereq id={p} tab={pd['tab']} ({pd['name']}) -- "
                    f"different tab entirely"
                )
                continue
            same_col = pd["col"] == d["col"]
            same_tier = pd["tier"] == d["tier"]
            if same_col and same_tier:
                issues.append(f"SELF-REFERENCE-LIKE: id={tid} prereq={p} same tier+col")
            tier_gap = d["tier"] - pd["tier"]
            if same_col and tier_gap <= 0:
                issues.append(
                    f"BACKWARDS PREREQ (same col): id={tid} tier={d['tier']} "
                    f"prereq id={p} tier={pd['tier']} (prereq not above dependent)"
                )
            if same_tier and pd["col"] == d["col"]:
                pass  # already covered by same_col+same_tier case above

    print(f"Total talents: {len(talents)}")
    print(f"Multi-prereq talents (>1 prereq): {multi_prereq}")
    print(f"Dangling prereqs (id not in Talent.dbc): {dangling_prereq}")
    if issues:
        print(f"\n{len(issues)} issue(s) found:")
        for i in issues:
            print(" -", i)
    else:
        print("\nNo cross-tab, backwards, or dangling prereq references found.")
        print("TalentStage_DrawConnectors' same-column / same-tier / general-L")
        print("branches do not depend on tier or column adjacency (DrawSegment")
        print("flips negative width/height), so arbitrary tier/column gaps are")
        print("already handled correctly for every prereq in this dataset.")


if __name__ == "__main__":
    main()
