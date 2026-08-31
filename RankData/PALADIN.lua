-- RankData/PALADIN.lua -- GENERATED, do not hand-edit.
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
TalentStage_RankData["PALADIN"] = {
	[1] = {
		[1] = {
			[2] = { n = "Divine Strength", r = 5, d = { "Increases your Strength by 2%.", "Increases your Strength by 4%.", "Increases your Strength by 6%.", "Increases your Strength by 8%.", "Increases your Strength by 10%." } },
			[3] = { n = "Divine Intellect", r = 5, d = { "Increases your total Intellect by 2%.", "Increases your total Intellect by 4%.", "Increases your total Intellect by 6%.", "Increases your total Intellect by 8%.", "Increases your total Intellect by 10%." } },
		},
		[2] = {
			[1] = { n = "Holy Judgement", r = 3, d = { "Casting Judgement reduces the casting time of your next Holy Light by 0.3 sec.", "Casting Judgement reduces the casting time of your next Holy Light by 0.6 sec.", "Casting Judgement reduces the casting time of your next Holy Light by 1 sec." } },
			[2] = { n = "Spiritual Focus", r = 2, d = { "Gives your Flash of Light and Holy Light spells a 35% chance to not lose casting time when you take damage.", "Gives your Flash of Light and Holy Light spells a 70% chance to not lose casting time when you take damage." } },
			[3] = { n = "Improved Seal of Righteousness", r = 5, d = { "Increases the damage done by your Seal of Righteousness and Judgement of Righteousness by 2%.", "Increases the damage done by your Seal of Righteousness and Judgement of Righteousness by 4%.", "Increases the damage done by your Seal of Righteousness and Judgement of Righteousness by 6%.", "Increases the damage done by your Seal of Righteousness and Judgement of Righteousness by 8%.", "Increases the damage done by your Seal of Righteousness and Judgement of Righteousness by 10%." } },
		},
		[3] = {
			[1] = { n = "Healing Light", r = 3, d = { "Increases the amount healed by your Holy Light, Flash of Light and Holy Shock spells by 4%.", "Increases the amount healed by your Holy Light, Flash of Light and Holy Shock spells by 8%.", "Increases the amount healed by your Holy Light, Flash of Light and Holy Shock spells by 12%." } },
			[2] = { n = "Sanctity Aura", r = 1, d = { "Increases Holy damage done by party members within 30 yards by 10%.  Players may only have one Aura on them per Paladin at any one time." } },
			[3] = { n = "Improved Lay on Hands", r = 2, d = { "Gives the target of your Lay on Hands spell a 15% bonus to their armor value from items for 2 min.  In addition, the cooldown for your Lay on Hands spell is reduced by 10 min.", "Gives the target of your Lay on Hands spell a 30% bonus to their armor value from items for 2 min.  In addition, the cooldown for your Lay on Hands spell is reduced by 20 min." } },
			[4] = { n = "Unyielding Faith", r = 2, d = { "Increases your chance to resist Fear and Disorient effects by an additional 5%.", "Increases your chance to resist Fear and Disorient effects by an additional 10%." } },
		},
		[4] = {
			[1] = { n = "Improved Concentration Aura", r = 3, d = { "Increases the effect of your Concentration Aura by an additional 5% and gives all group members affected by the aura an additional 5% chance to resist Silence and Interrupt effects.", "Increases the effect of your Concentration Aura by an additional 10% and gives all group members affected by the aura an additional 10% chance to resist Silence and Interrupt effects.", "Increases the effect of your Concentration Aura by an additional 15% and gives all group members affected by the aura an additional 15% chance to resist Silence and Interrupt effects." } },
			[2] = { n = "Illumination", r = 5, d = { "After getting a critical effect from your Flash of Light, Holy Light, or Holy Shock heal spell, you regain Mana equal to 12% of the base cost of the spell.", "After getting a critical effect from your Flash of Light, Holy Light, or Holy Shock heal spell, you regain Mana equal to 24% of the base cost of the spell.", "After getting a critical effect from your Flash of Light, Holy Light, or Holy Shock heal spell, you regain Mana equal to 36% of the base cost of the spell.", "After getting a critical effect from your Flash of Light, Holy Light, or Holy Shock heal spell, you regain Mana equal to 48% of the base cost of the spell.", "After getting a critical effect from your Flash of Light, Holy Light, or Holy Shock heal spell, you regain Mana equal to 60% of the base cost of the spell." } },
			[3] = { n = "Ironclad", r = 2, d = { "Increases healing done by spells and effects by up to 1% of your Armor from items.", "Increases healing done by spells and effects by up to 2% of your Armor from items." } },
		},
		[5] = {
			[1] = { n = "Divine Favor", r = 5, d = { "Improves your chance to get a critical strike with Holy Shock by 10%.", "Improves your chance to get a critical strike with Holy Shock by 20%.", "Improves your chance to get a critical strike with Holy Shock by 30%.", "Improves your chance to get a critical strike with Holy Shock by 40%.", "Improves your chance to get a critical strike with Holy Shock by 50%." } },
			[2] = { n = "Holy Shock", r = 1, d = { "Blasts the target with Holy energy, causing 104 Holy damage to an enemy, or 320 healing to an ally. Casting Holy Shock has a chance to have no cooldown for its next cast." } },
		},
		[6] = {
			[1] = { n = "Holy Power", r = 3, d = { "Increases the critical effect chance of your Holy Light and Flash of Light by 2%.", "Increases the critical effect chance of your Holy Light and Flash of Light by 4%.", "Increases the critical effect chance of your Holy Light and Flash of Light by 6%." } },
			[3] = { n = "Blessed Strikes", r = 5, d = { "Crusader Strike has a 20% chance to reset the cooldown of your Holy Shock.  In addition, the healing effect of your Holy Strike is increased by 20% and benefits from an additional 5% of your healing power.", "Crusader Strike has a 40% chance to reset the cooldown of your Holy Shock.  In addition, the healing effect of your Holy Strike is increased by 40% and benefits from an additional 10% of your healing power.", "Crusader Strike has a 60% chance to reset the cooldown of your Holy Shock.  In addition, the healing effect of your Holy Strike is increased by 60% and benefits from an additional 15% of your healing power.", "Crusader Strike has a 80% chance to reset the cooldown of your Holy Shock.  In addition, the healing effect of your Holy Strike is increased by 80% and benefits from an additional 20% of your healing power.", "Crusader Strike has a 100% chance to reset the cooldown of your Holy Shock.  In addition, the healing effect of your Holy Strike is increased by 100% and benefits from an additional 25% of your healing power." } },
		},
		[7] = {
			[2] = { n = "Daybreak", r = 1, d = { "Critically healing an ally applies Daybreak for 30 sec. When the ally takes damage, Daybreak is consumed to heal them for 289." } },
		},
	},
	[2] = {
		[1] = {
			[2] = { n = "Improved Devotion Aura", r = 5, d = { "Increases the armor bonus of your Devotion Aura by 5%.", "Increases the armor bonus of your Devotion Aura by 10%.", "Increases the armor bonus of your Devotion Aura by 15%.", "Increases the armor bonus of your Devotion Aura by 20%.", "Increases the armor bonus of your Devotion Aura by 25%." } },
			[3] = { n = "Redoubt", r = 5, d = { "Successful melee and ranged attacks against you have a 2% chance to increase your chance to block by 3%. Lasts 10 sec or 5 blocks.", "Successful melee and ranged attacks against you have a 4% chance to increase your chance to block by 6%. Lasts 10 sec or 5 blocks.", "Successful melee and ranged attacks against you have a 6% chance to increase your chance to block by 9%. Lasts 10 sec or 5 blocks.", "Successful melee and ranged attacks against you have a 8% chance to increase your chance to block by 12%. Lasts 10 sec or 5 blocks.", "Successful melee and ranged attacks against you have a 10% chance to increase your chance to block by 15%. Lasts 10 sec or 5 blocks." } },
		},
		[2] = {
			[1] = { n = "Precision", r = 3, d = { "Increases your chance to hit with melee attacks and spells by 1%.", "Increases your chance to hit with melee attacks and spells by 2%.", "Increases your chance to hit with melee attacks and spells by 3%." } },
			[2] = { n = "Guardian's Favor", r = 2, d = { "Reduces the cooldown of your Hand of Protection by 60 sec and increases the duration of your Hand of Freedom by 3 sec.", "Reduces the cooldown of your Hand of Protection by 120 sec and increases the duration of your Hand of Freedom by 6 sec." } },
			[4] = { n = "Toughness", r = 5, d = { "Increases your armor value from items by 2%.", "Increases your armor value from items by 4%.", "Increases your armor value from items by 6%.", "Increases your armor value from items by 8%.", "Increases your armor value from items by 10%." } },
		},
		[3] = {
			[1] = { n = "Improved Righteous Fury", r = 3, d = { "Increases the amount of threat generated by your Righteous Fury spell by 25%.", "Increases the amount of threat generated by your Righteous Fury spell by 50%.", "Increases the amount of threat generated by your Righteous Fury spell by 75%." } },
			[2] = { n = "Blessing of Sanctuary", r = 1, d = { "Places a Blessing on the friendly target, reducing damage taken from all sources by up to 10 for 10 min.  In addition, when the target blocks a melee attack, the attacker takes 14 Holy damage.  Players may only have one Blessing on them per Paladin at any one time." } },
			[3] = { n = "Shield Specialization", r = 3, d = { "Increases the amount of damage absorbed by your shield by 10% and has a 33% chance to restore 2% of maximum mana when a block occurs. This effect cannot occur more than once every 5 sec.", "Increases the amount of damage absorbed by your shield by 20% and has a 66% chance to restore 2% of maximum mana when a block occurs. This effect cannot occur more than once every 5 sec.", "Increases the amount of damage absorbed by your shield by 30% and has a 100% chance to restore 2% of maximum mana when a block occurs. This effect cannot occur more than once every 5 sec." } },
			[4] = { n = "Anticipation", r = 3, d = { "Increases your Defense skill by 7.", "Increases your Defense skill by 14.", "Increases your Defense skill by 20." } },
		},
		[4] = {
			[2] = { n = "Improved Hand of Reckoning", r = 2, d = { "Improves your chance to hit with Hand of Reckoning by 4%.", "Improves your chance to hit with Hand of Reckoning by 8%." } },
			[3] = { n = "Improved Hammer of Justice", r = 3, d = { "Decreases the cooldown of your Hammer of Justice spell by 5 sec.", "Decreases the cooldown of your Hammer of Justice spell by 10 sec.", "Decreases the cooldown of your Hammer of Justice spell by 15 sec." } },
		},
		[5] = {
			[1] = { n = "Righteous Defense", r = 3, d = { "While Righteous Fury is active, your damage taken is reduced by 3%.", "While Righteous Fury is active, your damage taken is reduced by 6%.", "While Righteous Fury is active, your damage taken is reduced by 10%." } },
			[2] = { n = "Holy Shield", r = 1, d = { "Increases chance to block by 45% for 10 sec. While active, each blocked attack deals 35 Holy damage to the attacker.  Damage caused by Holy Shield generates 50% additional threat.  Each block expends a charge.  4 charges." } },
			[3] = { n = "Reckoning", r = 5, d = { "Gives you a 10% chance after blocking an attack to generate an additional attack.", "Gives you a 20% chance after blocking an attack to generate an additional attack.", "Gives you a 30% chance after blocking an attack to generate an additional attack.", "Gives you a 40% chance after blocking an attack to generate an additional attack.", "Gives you a 50% chance after blocking an attack to generate an additional attack." } },
		},
		[6] = {
			[3] = { n = "Righteous Strikes", r = 5, d = { "Increases the threat generated by your Holy Strike by 5% and its damage by 5%. In addition, Crusader Strike grants Zealous Defense, causing the next successful block to prevent an additional 6% of the attack's damage.", "Increases the threat generated by your Holy Strike by 10% and its damage by 10%. In addition, Crusader Strike grants Zealous Defense, causing the next successful block to prevent an additional 12% of the attack's damage.", "Increases the threat generated by your Holy Strike by 15% and its damage by 15%. In addition, Crusader Strike grants Zealous Defense, causing the next successful block to prevent an additional 18% of the attack's damage.", "Increases the threat generated by your Holy Strike by 20% and its damage by 20%. In addition, Crusader Strike grants Zealous Defense, causing the next successful block to prevent an additional 24% of the attack's damage.", "Increases the threat generated by your Holy Strike by 25% and its damage by 25%. In addition, Crusader Strike grants Zealous Defense, causing the next successful block to prevent an additional 30% of the attack's damage." } },
		},
		[7] = {
			[2] = { n = "Bulwark of the Righteous", r = 1, d = { "Bash the target with your shield, dealing 301 Holy damage and reducing the damage you take by 30% for 12 sec." } },
		},
	},
	[3] = {
		[1] = {
			[2] = { n = "Improved Blessings", r = 5, d = { "Increases the effectiveness your Blessing of Might and Wisdom by 4%.", "Increases the effectiveness your Blessing of Might and Wisdom by 8%.", "Increases the effectiveness your Blessing of Might and Wisdom by 12%.", "Increases the effectiveness your Blessing of Might and Wisdom by 16%.", "Increases the effectiveness your Blessing of Might and Wisdom by 20%." } },
			[3] = { n = "Benediction", r = 5, d = { "Reduces the Mana cost of your Judgement and Seal spells by 3%.", "Reduces the Mana cost of your Judgement and Seal spells by 6%.", "Reduces the Mana cost of your Judgement and Seal spells by 9%.", "Reduces the Mana cost of your Judgement and Seal spells by 12%.", "Reduces the Mana cost of your Judgement and Seal spells by 15%." } },
		},
		[2] = {
			[1] = { n = "Improved Judgement", r = 2, d = { "Decreases the cooldown of your Judgement spell by 1 sec.", "Decreases the cooldown of your Judgement spell by 2 sec." } },
			[2] = { n = "Improved Seal of the Crusader", r = 3, d = { "Increases the melee attack power bonus of your Seal of the Crusader and the Holy damage increase of your Judgement of the Crusader by 5%.", "Increases the melee attack power bonus of your Seal of the Crusader and the Holy damage increase of your Judgement of the Crusader by 10%.", "Increases the melee attack power bonus of your Seal of the Crusader and the Holy damage increase of your Judgement of the Crusader by 15%." } },
			[3] = { n = "Deflection", r = 5, d = { "Increases your Parry chance by 1%.", "Increases your Parry chance by 2%.", "Increases your Parry chance by 3%.", "Increases your Parry chance by 4%.", "Increases your Parry chance by 5%." } },
		},
		[3] = {
			[1] = { n = "Improved Retribution Aura", r = 2, d = { "Increases the damage done by your Retribution Aura by 25%.", "Increases the damage done by your Retribution Aura by 50%." } },
			[2] = { n = "Conviction", r = 5, d = { "Increases your chance to get a critical strike with melee weapons by 1%.", "Increases your chance to get a critical strike with melee weapons by 2%.", "Increases your chance to get a critical strike with melee weapons by 3%.", "Increases your chance to get a critical strike with melee weapons by 4%.", "Increases your chance to get a critical strike with melee weapons by 5%." } },
			[3] = { n = "Blessing of Kings", r = 1, d = { "Places a Blessing on the friendly target, increasing total stats by 10% for 10 min.  Players may only have one Blessing on them per Paladin at any one time." } },
			[4] = { n = "Pursuit of Justice", r = 2, d = { "Increases movement and mounted movement speed by 4%.  This does not stack with other movement speed increasing effects.", "Increases movement and mounted movement speed by 8%.  This does not stack with other movement speed increasing effects." } },
		},
		[4] = {
			[1] = { n = "Two-Handed Weapon Specialization", r = 3, d = { "Increases the damage you deal with two-handed melee weapons by 2%, and your weapon skill with two-handed swords, maces and axes by 1.", "Increases the damage you deal with two-handed melee weapons by 4%, and your weapon skill with two-handed swords, maces and axes by 2.", "Increases the damage you deal with two-handed melee weapons by 6%, and your weapon skill with two-handed swords, maces and axes by 3." } },
			[3] = { n = "Vindication", r = 3, d = { "Gives the Paladin's damaging melee attacks a chance to reduce the target's damage dealt by 3% for 10 sec. Only affects targets of level 62 or lower.", "Gives the Paladin's damaging melee attacks a chance to reduce the target's damage dealt by 6% for 10 sec. Only affects targets of level 62 or lower.", "Gives the Paladin's damaging melee attacks a chance to reduce the target's damage dealt by 9% for 10 sec. Only affects targets of level 62 or lower." } },
		},
		[5] = {
			[1] = { n = "Eye for an Eye", r = 2, d = { "All spell criticals against you cause 15% of the damage taken to the caster as well.  The damage caused by Eye for an Eye will not exceed 50% of the Paladin's total health.", "All spell criticals against you cause 30% of the damage taken to the caster as well.  The damage caused by Eye for an Eye will not exceed 50% of the Paladin's total health." } },
			[2] = { n = "Vengeance", r = 5, d = { "Gives you a 1% bonus to all damage you deal and decreases threat you generate by 2% for 30 sec after dealing a critical strike from a weapon swing, spell, or ability. This effect stacks up to 3 times. Threat reduction does not apply if the Paladin is under the effect of Righteous Fury.", "Gives you a 2% bonus to all damage you deal and decreases threat you generate by 4% for 30 sec after dealing a critical strike from a weapon swing, spell, or ability. This effect stacks up to 3 times. Threat reduction does not apply if the Paladin is under the effect of Righteous Fury.", "Gives you a 3% bonus to all damage you deal and decreases threat you generate by 6% for 30 sec after dealing a critical strike from a weapon swing, spell, or ability. This effect stacks up to 3 times. Threat reduction does not apply if the Paladin is under the effect of Righteous Fury.", "Gives you a 4% bonus to all damage you deal and decreases threat you generate by 8% for 30 sec after dealing a critical strike from a weapon swing, spell, or ability. This effect stacks up to 3 times. Threat reduction does not apply if the Paladin is under the effect of Righteous Fury.", "Gives you a 5% bonus to all damage you deal and decreases threat you generate by 10% for 30 sec after dealing a critical strike from a weapon swing, spell, or ability. This effect stacks up to 3 times. Threat reduction does not apply if the Paladin is under the effect of Righteous Fury." } },
			[3] = { n = "Seal of Command", r = 1, d = { { t = "Gives the Paladin a chance to deal additional Holy damage equal to 70% of melee damage.  Only one Seal can be active on the Paladin at any one time.  Lasts 30 sec.\n\nUnleashing this Seal's energy will judge an enemy, instantly causing  Holy damage,  if the target is stunned or incapacitated. This damage is increased by 15% of your attack power.", s = { { b = 101, p = 5.6, bl = 20, ml = 28, sl = 20, op = "/", n = 2 }, { b = 101, p = 5.6, bl = 20, ml = 28, sl = 20 } } } } },
		},
		[6] = {
			[2] = { n = "Vengeful Strikes", r = 5, d = { "Crusader Strike deals an additional 2% damage and Zeal increases your attack and casting speed by an additional 2% per stack.\nHoly Strike infuses you with Holy Might, increasing your Strength by 4% for 20 sec.", "Crusader Strike deals an additional 4% damage and Zeal increases your attack and casting speed by an additional 2% per stack.\nHoly Strike infuses you with Holy Might, increasing your Strength by 8% for 20 sec.", "Crusader Strike deals an additional 6% damage and Zeal increases your attack and casting speed by an additional 2% per stack.\nHoly Strike infuses you with Holy Might, increasing your Strength by 12% for 20 sec.", "Crusader Strike deals an additional 8% damage and Zeal increases your attack and casting speed by an additional 2% per stack.\nHoly Strike infuses you with Holy Might, increasing your Strength by 16% for 20 sec.", "Crusader Strike deals an additional 10% damage and Zeal increases your attack and casting speed by an additional 2% per stack.\nHoly Strike infuses you with Holy Might, increasing your Strength by 20% for 20 sec." } },
		},
		[7] = {
			[2] = { n = "Repentance", r = 1, d = { "Puts the enemy target in a state of meditation, incapacitating them for up to 6 sec.  Any damage caused will awaken the target.\n\nIf the target is immune to the effect, they repent for their sins, taking 80 Holy damage each time they perform a melee attack for 20 sec." } },
		},
	},
}
