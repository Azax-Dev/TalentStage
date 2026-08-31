-- RankData/WARLOCK.lua -- GENERATED, do not hand-edit.
-- Source: this client's own Talent.dbc/Spell.dbc/SpellDuration.dbc
-- (see CLAUDE.md, "Rank data source" section -- NOT the octowow.st scrape).
-- Regenerate with: python3 tools/gen_rank_data.py
-- Generated: 2026-08-31
--
-- Keyed [tree][tier][column] (tree = the `tab` GetTalentInfo takes, 1-3,
-- ordered via TalentTab.dbc's OrderIndex field -- NOT raw tab id order,
-- which gets 7 of 9 classes wrong).
--   n = name (validated against live GetTalentInfo before use)
--   r = max rank
--   d = { [rank] = ... }, 1-indexed. Each entry is EITHER a plain
--       rendered string, OR (when the real value depends on the
--       player's live character level -- e.g. Serrated Blades'
--       armor-ignore, Ice Barrier's absorb -- see CLAUDE.md's
--       2026-08-31 level-scaling follow-up) a table
--       { t = template, s = { {b=,p=,bl=,ml=,sl=,op=,n=}, ... } }
--       where `t` contains one \2 byte per entry in `s`;
--       TalentStage_RenderRankText computes each slot live via
--       TalentStage_ComputeLevelScaled(UnitLevel("player"), ...).
--       The whole `d` entry is OMITTED (nil) whenever any rank's
--       text used a token this generator doesn't confidently
--       resolve at all -- TalentStage falls back to its normal
--       live-scrape tooltip for that talent.

TalentStage_RankData = TalentStage_RankData or {}
TalentStage_RankData["WARLOCK"] = {
	[1] = {
		[1] = {
			[2] = { n = "Suppression", r = 5, d = { "Reduces the chance for enemies to resist your Affliction spells by 2%.", "Reduces the chance for enemies to resist your Affliction spells by 4%.", "Reduces the chance for enemies to resist your Affliction spells by 6%.", "Reduces the chance for enemies to resist your Affliction spells by 8%.", "Reduces the chance for enemies to resist your Affliction spells by 10%." } },
			[3] = { n = "Improved Corruption", r = 5, d = { "Reduces the casting time of your Corruption spell by 0.3 sec.", "Reduces the casting time of your Corruption spell by 0.6 sec.", "Reduces the casting time of your Corruption spell by 0.9 sec.", "Reduces the casting time of your Corruption spell by 1.2 sec.", "Reduces the casting time of your Corruption spell by 1.5 sec." } },
		},
		[2] = {
			[1] = { n = "Improved Curse of Weakness", r = 2, d = { "Increases the attack speed reduction of your Curse of Weakness by 3%.", "Increases the attack speed reduction of your Curse of Weakness by 5%." } },
			[2] = { n = "Resilient Shadows", r = 3, d = { "Reduces the chance your Affliction spells will be dispelled by an additional 5%.", "Reduces the chance your Affliction spells will be dispelled by an additional 10%.", "Reduces the chance your Affliction spells will be dispelled by an additional 15%." } },
			[3] = { n = "Improved Life Tap", r = 2, d = { "Increases the amount of Mana awarded by your Life Tap spell by 10%.", "Increases the amount of Mana awarded by your Life Tap spell by 20%." } },
			[4] = { n = "Improved Drains", r = 2, d = { "Increases the effectiveness of your Drain Soul, Drain Life and Drain Mana by 5%.", "Increases the effectiveness of your Drain Soul, Drain Life and Drain Mana by 10%." } },
		},
		[3] = {
			[1] = { n = "Improved Curse of Agony", r = 3, d = { "Increases the damage done by your Curse of Agony by 3%.", "Increases the damage done by your Curse of Agony by 6%.", "Increases the damage done by your Curse of Agony by 10%." } },
			[2] = { n = "Fel Concentration", r = 2, d = { "Gives your Affliction spells a 35% chance to not lose casting time when you take damage.", "Gives your Affliction spells a 70% chance to not lose casting time when you take damage." } },
			[3] = { n = "Curse of Exhaustion", r = 1, d = { "Reduces the target's movement speed by 10% for 12 sec.  Only one Curse per Warlock can be active on any one target." } },
		},
		[4] = {
			[1] = { n = "Grim Reach", r = 2, d = { "Increases the range of your Affliction spells by 10%.", "Increases the range of your Affliction spells by 20%." } },
			[2] = { n = "Nightfall", r = 2, d = { "Gives your Corruption, Dark Harvest and Drain spells a 2% chance to cause you to enter a Shadow Trance state after damaging the opponent.  The Shadow Trance state reduces the casting time of your next Shadow Bolt spell by 100% and makes it guaranteed to land.", "Gives your Corruption, Dark Harvest and Drain spells a 4% chance to cause you to enter a Shadow Trance state after damaging the opponent.  The Shadow Trance state reduces the casting time of your next Shadow Bolt spell by 100% and makes it guaranteed to land." } },
			[4] = { n = "Soul Siphon", r = 3, d = { "Increases the damage of your Drain Soul, Dark Harvest and Death Coil by an additional 2% for each of your Affliction effects on the target, up to a maximum of 4 effects.", "Increases the damage of your Drain Soul, Dark Harvest and Death Coil by an additional 4% for each of your Affliction effects on the target, up to a maximum of 4 effects.", "Increases the damage of your Drain Soul, Dark Harvest and Death Coil by an additional 6% for each of your Affliction effects on the target, up to a maximum of 4 effects." } },
		},
		[5] = {
			[1] = { n = "Rapid Deterioration", r = 2, d = { "Increases the casting speed of your Affliction spells by 6%.  In addition, casting speed increase effects increase the tick speed of your damage over time and channeled Affliction spells with 50% efficiency, reducing their duration.", "Increases the casting speed of your Affliction spells by 6%.  In addition, casting speed increase effects increase the tick speed of your damage over time and channeled Affliction spells with 100% efficiency, reducing their duration." } },
			[2] = { n = "Siphon Life", r = 1, d = { "Transfers 150 Health from the target to the caster over 30 sec." } },
			[3] = { n = "Improved Curse of Exhaustion", r = 2, d = { "Increases the speed reduction of your Curse of Exhaustion by 15%.", "Increases the speed reduction of your Curse of Exhaustion by 30%." } },
			[4] = { n = "Malediction", r = 1, d = { "Your Curse of Agony can be used alongside your other curses, except Curse of Doom.\n\nApplying Curse of Recklessness, Curse of Shadows, or Curse of Elements also afflicts the target with the highest rank of your Curse of Agony." } },
		},
		[6] = {
			[2] = { n = "Shadow Mastery", r = 5, d = { "Increases the damage dealt or life drained by your Shadow spells by 2%.", "Increases the damage dealt or life drained by your Shadow spells by 4%.", "Increases the damage dealt or life drained by your Shadow spells by 6%.", "Increases the damage dealt or life drained by your Shadow spells by 8%.", "Increases the damage dealt or life drained by your Shadow spells by 10%." } },
		},
		[7] = {
			[2] = { n = "Dark Harvest", r = 1, d = { "Reaps the target's life, dealing 704 Shadow damage over 8 sec. While channeling, the time between periodic ticks of your Affliction spells on the target is reduced by 30%. If the target dies while channeling, the cooldown of Dark Harvest is reset." } },
		},
	},
	[2] = {
		[1] = {
			[2] = { n = "Sinister Pursuit", r = 2, d = { "Increases the movement speed of your demons by 5%.", "Increases the movement speed of your demons by 10%." } },
			[3] = { n = "Demonic Embrace", r = 5, d = { "Increases your total Stamina by 3% but reduces your total Spirit by 1%.", "Increases your total Stamina by 6% but reduces your total Spirit by 2%.", "Increases your total Stamina by 9% but reduces your total Spirit by 3%.", "Increases your total Stamina by 12% but reduces your total Spirit by 4%.", "Increases your total Stamina by 15% but reduces your total Spirit by 5%." } },
			[4] = { n = "Soul Entrapment", r = 3, d = { "While you have no demon under your control, all damage dealt is increased by 2%.", "While you have no demon under your control, all damage dealt is increased by 4%.", "While you have no demon under your control, all damage dealt is increased by 6%." } },
		},
		[2] = {
			[1] = { n = "Soul Funnel", r = 2, d = { "Increases the amount of Health transferred by your Health Funnel by 10% of your demon's missing Health and the Mana transferred by your Mana Funnel by 10% of your demon's missing Mana. This additional transfer drains 30% of that amount from you.", "Increases the amount of Health transferred by your Health Funnel by 20% of your demon's missing Health and the Mana transferred by your Mana Funnel by 20% of your demon's missing Mana. This additional transfer drains 30% of that amount from you." } },
			[2] = { n = "Demonic Aegis", r = 3, d = { "Increases the effectiveness of your Demon Armor spell by 20%.", "Increases the effectiveness of your Demon Armor spell by 40%.", "Increases the effectiveness of your Demon Armor spell by 60%." } },
			[3] = { n = "Fel Intellect", r = 3, d = { "Increases your demon's Intellect by 10% of your total Intellect and allows 5% of its Mana regeneration to continue while casting.", "Increases your demon's Intellect by 20% of your total Intellect and allows 10% of its Mana regeneration to continue while casting.", "Increases your demon's Intellect by 30% of your total Intellect and allows 15% of its Mana regeneration to continue while casting." } },
		},
		[3] = {
			[2] = { n = "Fel Domination", r = 1, d = { "Your next Common demon summoning spell has its casting time reduced by 4.5 sec and its Mana cost reduced by 40%." } },
			[3] = { n = "Fel Stamina", r = 5, d = { "Increases your demon's Stamina by 10% of your total Stamina and reduces its chance to be critically struck by 1%.", "Increases your demon's Stamina by 20% of your total Stamina and reduces its chance to be critically struck by 2%.", "Increases your demon's Stamina by 30% of your total Stamina and reduces its chance to be critically struck by 3%.", "Increases your demon's Stamina by 40% of your total Stamina and reduces its chance to be critically struck by 4%.", "Increases your demon's Stamina by 50% of your total Stamina and reduces its chance to be critically struck by 5%." } },
			[4] = { n = "Demonic Sacrifice", r = 1, d = { "When activated, sacrifices your summoned demon to grant you an effect. The effect is canceled if any demon is summoned or enslaved.\n\nImp: Increases spell damage done by 4%.\n\nVoidwalker: Restores 3% of total Health every 4 sec.\n\nSuccubus: Reduces threat generated by 10%.\n\nFelhunter: Restores 3% of total Mana every 4 sec." } },
		},
		[4] = {
			[1] = { n = "Improved Stones", r = 2, d = { "Increases the effectiveness of your Felstone, Wrathstone, Voidstone, and Spellstone by 25%, and increases the critical strike chance bonus of your Firestone by 50%.", "Increases the effectiveness of your Felstone, Wrathstone, Voidstone, and Spellstone by 50%, and increases the critical strike chance bonus of your Firestone by 100%." } },
			[2] = { n = "Master Summoner", r = 2, d = { "Reduces the casting time of your Imp, Voidwalker, Succubus, and Felhunter summoning spells by 2 sec and their mana cost by 30%. In addition, reduces the cooldown of Inferno, Ritual of Doom, and Demon Gate by 25%.", "Reduces the casting time of your Imp, Voidwalker, Succubus, and Felhunter summoning spells by 4 sec and their mana cost by 60%. In addition, reduces the cooldown of Inferno, Ritual of Doom, and Demon Gate by 50%." } },
			[3] = { n = "Nether Studies", r = 3, d = { "Increases the effect of your Succubus' Seduction, your Voidwalker's Torment, your Imp's Blood Pact, and your Felhunter's Tainted Blood spells by 15%.", "Increases the effect of your Succubus' Seduction, your Voidwalker's Torment, your Imp's Blood Pact, and your Felhunter's Tainted Blood spells by 30%.", "Increases the effect of your Succubus' Seduction, your Voidwalker's Torment, your Imp's Blood Pact, and your Felhunter's Tainted Blood spells by 45%." } },
			[4] = { n = "Unholy Power", r = 3, d = { "Increases the damage done by your demons by 5%.", "Increases the damage done by your demons by 10%.", "Increases the damage done by your demons by 15%." } },
		},
		[5] = {
			[2] = { n = "Power Overwhelming", r = 1, d = { "Channel energy into your demon, breaking all crowd control effects and increasing its damage dealt by 20% for 10 sec. The demon takes 40% of its base health as damage over the duration." } },
			[3] = { n = "Demonic Precision", r = 3, d = { "Your demons gain 1% increased chance to hit and critically strike, and they also inherit 30% of your spell hit and crit chance as melee and spell hit and crit chance, respectively.", "Your demons gain 2% increased chance to hit and critically strike, and they also inherit 60% of your spell hit and crit chance as melee and spell hit and crit chance, respectively.", "Your demons gain 3% increased chance to hit and critically strike, and they also inherit 90% of your spell hit and crit chance as melee and spell hit and crit chance, respectively." } },
		},
		[6] = {
			[2] = { n = "Master Demonologist", r = 5, d = { { t = "Grants both the Warlock and the summoned demon an effect as long as that demon is active.\n\nImp - Reduces spell costs by 3%.\n\nVoidwalker - Reduces physical damage taken by 2%.\n\nSuccubus - Increases all damage done by 2%.\n\nFelhunter - Increases all resistances by .\n\nGreater Demons - Increases spell critical strike chance by 2%.\n", s = { { b = 0, p = 0.2 } } }, { t = "Grants both the Warlock and the summoned demon an effect as long as that demon is active.\n\nImp - Reduces spell costs by 6%.\n\nVoidwalker - Reduces physical damage taken by 4%.\n\nSuccubus - Increases all damage done by 4%.\n\nFelhunter - Increases all resistances by .\n\nGreater Demons - Increases spell critical strike chance by 4%.\n", s = { { b = 0, p = 0.4 } } }, { t = "Grants both the Warlock and the summoned demon an effect as long as that demon is active.\n\nImp - Reduces spell costs by 9%.\n\nVoidwalker - Reduces physical damage taken by 6%.\n\nSuccubus - Increases all damage done by 6%.\n\nFelhunter - Increases all resistances by .\n\nGreater Demons - Increases spell critical strike chance by 6%.\n", s = { { b = 0, p = 0.6 } } }, { t = "Grants both the Warlock and the summoned demon an effect as long as that demon is active.\n\nImp - Reduces spell costs by 12%.\n\nVoidwalker - Reduces physical damage taken by 8%.\n\nSuccubus - Increases all damage done by 8%.\n\nFelhunter - Increases all resistances by .\n\nGreater Demons - Increases spell critical strike chance by 8%.\n", s = { { b = 0, p = 0.8 } } }, { t = "Grants both the Warlock and the summoned demon an effect as long as that demon is active.\n\nImp - Reduces spell costs by 15%.\n\nVoidwalker - Reduces physical damage taken by 10%.\n\nSuccubus - Increases all damage done by 10%.\n\nFelhunter - Increases all resistances by .\n\nGreater Demons - Increases spell critical strike chance by 10%.\n", s = { { b = 0, p = 1 } } } } },
			[3] = { n = "Unleashed Potential", r = 3, d = { "Your direct damage spell hits allow your demon to benefit from 5% of your Fire and Shadow spell bonus damage for 20 sec. Each tick of your funnel spells refreshes its duration. Stacks up to 3 times.", "Your direct damage spell hits allow your demon to benefit from 10% of your Fire and Shadow spell bonus damage for 20 sec. Each tick of your funnel spells refreshes its duration. Stacks up to 3 times.", "Your direct damage spell hits allow your demon to benefit from 15% of your Fire and Shadow spell bonus damage for 20 sec. Each tick of your funnel spells refreshes its duration. Stacks up to 3 times." } },
		},
		[7] = {
			[2] = { n = "Soul Link", r = 1, d = { "While a demon is under your control, the damage dealt by you and your demon is increased by 5%. In addition, 20% of all damage you take is taken by your demon.  Your Greater and Enslaved Demons can no longer break free from your control early." } },
		},
	},
	[3] = {
		[1] = {
			[2] = { n = "Shadow Vulnerability", r = 5, d = { "Your Shadow Bolt and Drain Soul have a 2% chance to increase Shadow damage dealt to the target by 20% for 10 sec, with a higher chance to trigger on critical hits.", "Your Shadow Bolt and Drain Soul have a 4% chance to increase Shadow damage dealt to the target by 20% for 10 sec, with a higher chance to trigger on critical hits.", "Your Shadow Bolt and Drain Soul have a 6% chance to increase Shadow damage dealt to the target by 20% for 10 sec, with a higher chance to trigger on critical hits.", "Your Shadow Bolt and Drain Soul have a 8% chance to increase Shadow damage dealt to the target by 20% for 10 sec, with a higher chance to trigger on critical hits.", "Your Shadow Bolt and Drain Soul have a 10% chance to increase Shadow damage dealt to the target by 20% for 10 sec, with a higher chance to trigger on critical hits." } },
			[3] = { n = "Cataclysm", r = 5, d = { "Reduces the Mana cost of your Destruction spells by 2%.", "Reduces the Mana cost of your Destruction spells by 4%.", "Reduces the Mana cost of your Destruction spells by 6%.", "Reduces the Mana cost of your Destruction spells by 8%.", "Reduces the Mana cost of your Destruction spells by 10%." } },
		},
		[2] = {
			[1] = { n = "Demonic Swiftness", r = 2, d = { "Reduces the casting time of your Imp's Firebolt spell by 0.25 sec and reduces the cooldown of your Succubus' Lash of Pain spell by 3 sec.", "Reduces the casting time of your Imp's Firebolt spell by 0.5 sec and reduces the cooldown of your Succubus' Lash of Pain spell by 6 sec." } },
			[2] = { n = "Bane", r = 5, d = { "Reduces the casting time of your Shadow Bolt, Searing Pain, and Immolate spells by 0.1 sec and your Soul Fire spell by 0.4 sec.", "Reduces the casting time of your Shadow Bolt, Searing Pain, and Immolate spells by 0.2 sec and your Soul Fire spell by 0.8 sec.", "Reduces the casting time of your Shadow Bolt, Searing Pain, and Immolate spells by 0.3 sec and your Soul Fire spell by 1.2 sec.", "Reduces the casting time of your Shadow Bolt, Searing Pain, and Immolate spells by 0.4 sec and your Soul Fire spell by 1.6 sec.", "Reduces the casting time of your Shadow Bolt, Searing Pain, and Immolate spells by 0.5 sec and your Soul Fire spell by 2 sec." } },
			[3] = { n = "Aftermath", r = 3, d = { "Increases the periodic damage of your Immolate spell by 2% and gives your Destruction spells a 4% chance to slow the target by 50% for 5 sec.", "Increases the periodic damage of your Immolate spell by 4% and gives your Destruction spells a 7% chance to slow the target by 50% for 5 sec.", "Increases the periodic damage of your Immolate spell by 6% and gives your Destruction spells a 10% chance to slow the target by 50% for 5 sec." } },
		},
		[3] = {
			[1] = { n = "Intensity", r = 2, d = { "Gives your Fire spells a 35% chance to not lose casting time when you take damage.", "Gives your Fire spells a 70% chance to not lose casting time when you take damage." } },
			[2] = { n = "Shadowburn", r = 1, d = { { t = "Instantly blasts the target for  Shadow damage.  If the target dies within 5 sec of Shadowburn, and yields experience or honor, the caster gains a Soul Shard.", s = { { b = 99, p = 1.2, bl = 20, ml = 24, sl = 20 } } } } },
			[3] = { n = "Devastation", r = 5, d = { "Increases the critical strike chance of your Destruction spells by 1%.", "Increases the critical strike chance of your Destruction spells by 2%.", "Increases the critical strike chance of your Destruction spells by 3%.", "Increases the critical strike chance of your Destruction spells by 4%.", "Increases the critical strike chance of your Destruction spells by 5%." } },
		},
		[4] = {
			[1] = { n = "Pyroclasm", r = 2, d = { "Gives your Rain of Fire, Hellfire, Conflagrate, and Soul Fire spells a 13% chance to stun the target for 3 sec.", "Gives your Rain of Fire, Hellfire, Conflagrate, and Soul Fire spells a 26% chance to stun the target for 3 sec." } },
			[2] = { n = "Destructive Reach", r = 2, d = { "Increases the range of your Destruction spells by 10% and the radius of your Hellfire by 10%.", "Increases the range of your Destruction spells by 20% and the radius of your Hellfire by 20%." } },
			[4] = { n = "Improved Searing Pain", r = 5, d = { "Increases the critical strike chance of your Searing Pain spell by 2%.", "Increases the critical strike chance of your Searing Pain spell by 4%.", "Increases the critical strike chance of your Searing Pain spell by 6%.", "Increases the critical strike chance of your Searing Pain spell by 8%.", "Increases the critical strike chance of your Searing Pain spell by 10%." } },
		},
		[5] = {
			[1] = { n = "Improved Soul Fire", r = 2, d = { "Your Soul Fire has a 50% chance to refund a Soul Shard and increase your Fire damage by 10% for 30 sec.", "Your Soul Fire has a 100% chance to refund a Soul Shard and increase your Fire damage by 10% for 30 sec." } },
			[2] = { n = "Improved Immolate", r = 5, d = { "Increases the damage of your Immolate spell by 4%.", "Increases the damage of your Immolate spell by 8%.", "Increases the damage of your Immolate spell by 12%.", "Increases the damage of your Immolate spell by 16%.", "Increases the damage of your Immolate spell by 20%." } },
			[3] = { n = "Ruin", r = 1, d = { "Increases the critical strike damage bonus of your Destruction spells by 100%." } },
		},
		[6] = {
			[3] = { n = "Emberstorm", r = 5, d = { "Increases the damage done by your Fire spells by 2%.", "Increases the damage done by your Fire spells by 4%.", "Increases the damage done by your Fire spells by 6%.", "Increases the damage done by your Fire spells by 8%.", "Increases the damage done by your Fire spells by 10%." } },
		},
		[7] = {
			[2] = { n = "Conflagrate", r = 1, d = { { t = "Ignites the target, dealing  Fire damage and consuming 3 sec of your Immolate spell to deal an amount of damage equal to it.", s = { { b = 306, p = 1.6, bl = 40, ml = 46, sl = 40 } } } } },
		},
	},
}
