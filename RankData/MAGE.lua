-- RankData/MAGE.lua -- GENERATED, do not hand-edit.
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
TalentStage_RankData["MAGE"] = {
	[1] = {
		[1] = {
			[1] = { n = "Arcane Subtlety", r = 2, d = { "Reduces your target's resistance to all your spells by 5 and reduces the threat caused by your Arcane spells by 20%.", "Reduces your target's resistance to all your spells by 10 and reduces the threat caused by your Arcane spells by 40%." } },
			[2] = { n = "Magic Absorption", r = 3, d = { "Increases all resistances by 4 and whenever one of your spells is partially or fully resisted you restore 1% of your maximum mana.  This effect can occur once every 2 sec.", "Increases all resistances by 7 and whenever one of your spells is partially or fully resisted you restore 2% of your maximum mana.  This effect can occur once every 2 sec.", "Increases all resistances by 10 and whenever one of your spells is partially or fully resisted you restore 3% of your maximum mana.  This effect can occur once every 2 sec." } },
			[3] = { n = "Improved Arcane Missiles", r = 5, d = { "Gives you a 20% chance to avoid interruption caused by damage while channeling Arcane Missiles.", "Gives you a 40% chance to avoid interruption caused by damage while channeling Arcane Missiles.", "Gives you a 60% chance to avoid interruption caused by damage while channeling Arcane Missiles.", "Gives you a 80% chance to avoid interruption caused by damage while channeling Arcane Missiles.", "Gives you a 100% chance to avoid interruption caused by damage while channeling Arcane Missiles." } },
		},
		[2] = {
			[1] = { n = "Wand Specialization", r = 2, d = { { t = "Increases your damage and chance to hit with Wands by 13% and 5%, respectively.  Successful Wand attacks have a chance to restore  mana.", s = { { b = 0, p = 1.5 } } }, { t = "Increases your damage and chance to hit with Wands by 25% and 10%, respectively.  Successful Wand attacks have a chance to restore  mana.\nHigher chance to trigger than Wand Specialization (Rank 1).", s = { { b = 0, p = 1.5 } } } } },
			[2] = { n = "Arcane Focus", r = 5, d = { "Reduces the chance that the opponent can resist your Arcane spells by 2%.", "Reduces the chance that the opponent can resist your Arcane spells by 4%.", "Reduces the chance that the opponent can resist your Arcane spells by 6%.", "Reduces the chance that the opponent can resist your Arcane spells by 8%.", "Reduces the chance that the opponent can resist your Arcane spells by 10%." } },
			[3] = { n = "Arcane Concentration", r = 5, d = { "Gives you a 2% chance of entering a Clearcasting state after any damage spell hits a target.  The Clearcasting state reduces the mana cost of your next damage spell by 100%.  This effect can occur once every 8 sec.", "Gives you a 4% chance of entering a Clearcasting state after any damage spell hits a target.  The Clearcasting state reduces the mana cost of your next damage spell by 100%.  This effect can occur once every 8 sec.", "Gives you a 6% chance of entering a Clearcasting state after any damage spell hits a target.  The Clearcasting state reduces the mana cost of your next damage spell by 100%.  This effect can occur once every 8 sec.", "Gives you a 8% chance of entering a Clearcasting state after any damage spell hits a target.  The Clearcasting state reduces the mana cost of your next damage spell by 100%.  This effect can occur once every 8 sec.", "Gives you a 10% chance of entering a Clearcasting state after any damage spell hits a target.  The Clearcasting state reduces the mana cost of your next damage spell by 100%.  This effect can occur once every 8 sec." } },
		},
		[3] = {
			[1] = { n = "Magic Attunement", r = 1, d = { "Increases the effect of your Amplify Magic and Dampen Magic spells by 100% and allows them to be cast on enemies.  Only affects targets level 62 or lower." } },
			[2] = { n = "Arcane Impact", r = 3, d = { "Increases the critical strike chance of your Arcane spells by an additional 2%.", "Increases the critical strike chance of your Arcane spells by an additional 4%.", "Increases the critical strike chance of your Arcane spells by an additional 6%." } },
			[3] = { n = "Arcane Rupture", r = 1, d = { "Rupture your target with the force of concentrated arcane energy, dealing 114 Arcane damage and increasing the damage and mana cost of your Arcane Missiles spell by 20% for 8 sec." } },
		},
		[4] = {
			[1] = { n = "Improved Mana Shield", r = 2, d = { "Decreases the mana lost per point of damage taken when Mana Shield is active by 13%.", "Decreases the mana lost per point of damage taken when Mana Shield is active by 25%." } },
			[2] = { n = "Improved Counterspell", r = 2, d = { "Gives your Counterspell a 50% chance to silence the target for 4 sec.", "Gives your Counterspell a 100% chance to silence the target for 4 sec." } },
			[3] = { n = "Temporal Convergence", r = 3, d = { "Your Arcane Missiles have a chance of 5% to reset the cooldown of Arcane Rupture and cause it to return its base mana cost on its next cast.  This effect can occur once every 15 sec.", "Your Arcane Missiles have a chance of 10% to reset the cooldown of Arcane Rupture and cause it to return its base mana cost on its next cast.  This effect can occur once every 15 sec.", "Your Arcane Missiles have a chance of 15% to reset the cooldown of Arcane Rupture and cause it to return its base mana cost on its next cast.  This effect can occur once every 15 sec." } },
			[4] = { n = "Arcane Meditation", r = 3, d = { "Allows 7% of your Mana regeneration to continue while casting. This effect is tripled while below 35% total mana.", "Allows 14% of your Mana regeneration to continue while casting. This effect is tripled while below 35% total mana.", "Allows 20% of your Mana regeneration to continue while casting. This effect is tripled while below 35% total mana." } },
		},
		[5] = {
			[1] = { n = "Arcane Instability", r = 3, d = { "Your successful damaging Arcane spells have an 8% chance to uncontrollably erupt, consuming 2% of your base mana to deal 25% more damage.", "Your successful damaging Arcane spells have an 16% chance to uncontrollably erupt, consuming 2% of your base mana to deal 25% more damage.", "Your successful damaging Arcane spells have an 25% chance to uncontrollably erupt, consuming 2% of your base mana to deal 25% more damage." } },
			[2] = { n = "Presence of Mind", r = 1, d = { "When activated, your next Mage spell with a casting time less than 10 sec becomes an instant cast spell." } },
			[3] = { n = "Accelerated Arcana", r = 1, d = { "Increases the casting speed of your Arcane spells by 5%.  In addition, casting speed increase effects increase the cooldown recovery speed of your Arcane spells and the tick speed of your Arcane Missiles, reducing their duration." } },
			[4] = { n = "Arcane Potency", r = 2, d = { "Increases the critical strike damage bonus of your Arcane spells by 50%.", "Increases the critical strike damage bonus of your Arcane spells by 100%." } },
		},
		[6] = {
			[3] = { n = "Resonance Cascade", r = 5, d = { "Your successful damaging Arcane spells have a 4% chance to duplicate for 50% of the damage.  This effect can trigger off of itself and duplicated Arcane Missiles are channeled in tandem with the original cast.", "Your successful damaging Arcane spells have a 8% chance to duplicate for 50% of the damage.  This effect can trigger off of itself and duplicated Arcane Missiles are channeled in tandem with the original cast.", "Your successful damaging Arcane spells have a 12% chance to duplicate for 50% of the damage.  This effect can trigger off of itself and duplicated Arcane Missiles are channeled in tandem with the original cast.", "Your successful damaging Arcane spells have a 16% chance to duplicate for 50% of the damage.  This effect can trigger off of itself and duplicated Arcane Missiles are channeled in tandem with the original cast.", "Your successful damaging Arcane spells have a 20% chance to duplicate for 50% of the damage.  This effect can trigger off of itself and duplicated Arcane Missiles are channeled in tandem with the original cast." } },
		},
		[7] = {
			[2] = { n = "Arcane Power", r = 1, d = { "When activated, your casting speed is increased by 30% while draining 1% of your maximum mana every second and reducing all mana gain by 50%.\nFalling below 10% maximum mana causes you to violently combust from uncontrollable power, killing you instantly.  Lasts 20 sec and cannot be cancelled." } },
		},
	},
	[2] = {
		[1] = {
			[2] = { n = "Improved Fireball", r = 5, d = { "Reduces the casting time of your Fireball spell by 0.1 sec.", "Reduces the casting time of your Fireball spell by 0.2 sec.", "Reduces the casting time of your Fireball spell by 0.3 sec.", "Reduces the casting time of your Fireball spell by 0.4 sec.", "Reduces the casting time of your Fireball spell by 0.5 sec." } },
			[3] = { n = "Impact", r = 5, d = { "Gives your Fire spells a 2% chance to stun the target for 2 sec.", "Gives your Fire spells a 4% chance to stun the target for 2 sec.", "Gives your Fire spells a 6% chance to stun the target for 2 sec.", "Gives your Fire spells a 8% chance to stun the target for 2 sec.", "Gives your Fire spells a 10% chance to stun the target for 2 sec." } },
		},
		[2] = {
			[1] = { n = "Ignite", r = 5, d = { "Your critical strikes from Fire damage spells cause the target to burn for an additional 8% of your spell's damage over 4 sec.", "Your critical strikes from Fire damage spells cause the target to burn for an additional 16% of your spell's damage over 4 sec.", "Your critical strikes from Fire damage spells cause the target to burn for an additional 24% of your spell's damage over 4 sec.", "Your critical strikes from Fire damage spells cause the target to burn for an additional 32% of your spell's damage over 4 sec.", "Your critical strikes from Fire damage spells cause the target to burn for an additional 40% of your spell's damage over 4 sec." } },
			[2] = { n = "Flame Throwing", r = 2, d = { "Increases the range of your Fire spells by 3 yards and the radius of your Blast Wave by 10%.", "Increases the range of your Fire spells by 6 yards and the radius of your Blast Wave by 20%." } },
			[3] = { n = "Improved Fire Blast", r = 3, d = { "Reduces the cooldown of your Fire Blast spell by 0.5 sec and its global cooldown by 0.3 sec.", "Reduces the cooldown of your Fire Blast spell by 1 sec and its global cooldown by 0.6 sec.", "Reduces the cooldown of your Fire Blast spell by 1.5 sec and its global cooldown by 1 sec." } },
		},
		[3] = {
			[1] = { n = "Incinerate", r = 2, d = { "Increases the critical strike chance of your Fire Blast and Scorch spells by 2%.", "Increases the critical strike chance of your Fire Blast and Scorch spells by 4%." } },
			[2] = { n = "Improved Flamestrike", r = 3, d = { "Increases the critical strike chance of your Flamestrike spell by 5%.", "Increases the critical strike chance of your Flamestrike spell by 10%.", "Increases the critical strike chance of your Flamestrike spell by 15%." } },
			[3] = { n = "Pyroblast", r = 1, d = { { t = "Hurls an immense fiery boulder that causes  Fire damage and an additional 56 Fire damage over 12 sec.", s = { { b = 187, p = 1.9, bl = 20, ml = 24, sl = 20 } } } } },
			[4] = { n = "Burning Soul", r = 2, d = { "Gives your Fire spells a 35% chance to not lose casting time when you take damage and reduces the threat caused by your Fire spells by 15%.", "Gives your Fire spells a 70% chance to not lose casting time when you take damage and reduces the threat caused by your Fire spells by 30%." } },
		},
		[4] = {
			[1] = { n = "Fire Vulnerability", r = 3, d = { "Your Scorch and Fire Blast spells have a 33% chance to cause your target to be vulnerable to Fire damage.  This vulnerability increases the Fire damage dealt to your target by 3% and lasts 30 sec.  Stacks up to 5 times.", "Your Scorch and Fire Blast spells have a 66% chance to cause your target to be vulnerable to Fire damage.  This vulnerability increases the Fire damage dealt to your target by 3% and lasts 30 sec.  Stacks up to 5 times.", "Your Scorch and Fire Blast spells have a 100% chance to cause your target to be vulnerable to Fire damage.  This vulnerability increases the Fire damage dealt to your target by 3% and lasts 30 sec.  Stacks up to 5 times." } },
			[2] = { n = "Improved Fire Ward", r = 2, d = { "Causes your Fire Ward to have a 10% chance to reflect Fire spells while active.", "Causes your Fire Ward to have a 20% chance to reflect Fire spells while active." } },
			[4] = { n = "Master of Elements", r = 3, d = { "Your Fire and Frost spell criticals will refund 15% of their base mana cost.", "Your Fire and Frost spell criticals will refund 30% of their base mana cost.", "Your Fire and Frost spell criticals will refund 45% of their base mana cost." } },
		},
		[5] = {
			[1] = { n = "Blast Wave", r = 1, d = { { t = "A wave of flame radiates outward from the caster, damaging all enemies caught within the 10 yard blast for  Fire damage, and dazing them for 6 sec.", s = { { b = 186, p = 1, bl = 30, ml = 36, sl = 30 } } } } },
			[2] = { n = "Critical Mass", r = 3, d = { "Increases the critical strike chance of your Fire spells by 2%.", "Increases the critical strike chance of your Fire spells by 4%.", "Increases the critical strike chance of your Fire spells by 6%." } },
			[3] = { n = "Hot Streak", r = 2, d = { "Gives your Fireball and Fire Blast critical strikes a 50% chance to grant Hot Streak, reducing the cast time of your next Pyroblast by 1 sec per stack for 3 min. Stacks up to 5 times.", "Gives your Fireball and Fire Blast critical strikes a 100% chance to grant Hot Streak, reducing the cast time of your next Pyroblast by 1 sec per stack for 3 min. Stacks up to 5 times." } },
		},
		[6] = {
			[3] = { n = "Fire Power", r = 5, d = { "Increases the damage done by your Fire spells by 2%.", "Increases the damage done by your Fire spells by 4%.", "Increases the damage done by your Fire spells by 6%.", "Increases the damage done by your Fire spells by 8%.", "Increases the damage done by your Fire spells by 10%." } },
		},
		[7] = {
			[2] = { n = "Combustion", r = 1, d = { "When activated, this spell causes each of your Fire damage spell hits to increase your critical strike chance with Fire damage spells by 10%.  This effect lasts until you have caused 3 critical strikes with Fire spells." } },
		},
	},
	[3] = {
		[1] = {
			[1] = { n = "Frost Warding", r = 2, d = { "Increases the armor and resistances given by your Frost Armor and Ice Armor spells by 15%.  In addition, gives your Frost Ward a 10% chance to reflect Frost spells and effects while active.", "Increases the armor and resistances given by your Frost Armor and Ice Armor spells by 30%.  In addition, gives your Frost Ward a 20% chance to reflect Frost spells and effects while active." } },
			[2] = { n = "Improved Frostbolt", r = 5, d = { "Reduces the casting time of your Frostbolt spell by 0.1 sec.", "Reduces the casting time of your Frostbolt spell by 0.2 sec.", "Reduces the casting time of your Frostbolt spell by 0.3 sec.", "Reduces the casting time of your Frostbolt spell by 0.4 sec.", "Reduces the casting time of your Frostbolt spell by 0.5 sec." } },
			[3] = { n = "Elemental Precision", r = 3, d = { "Reduces the chance that the opponent can resist your Frost and Fire spells by 2%.", "Reduces the chance that the opponent can resist your Frost and Fire spells by 4%.", "Reduces the chance that the opponent can resist your Frost and Fire spells by 6%." } },
		},
		[2] = {
			[1] = { n = "Piercing Ice", r = 3, d = { "Increases the damage done by your Frost spells by 2%.", "Increases the damage done by your Frost spells by 4%.", "Increases the damage done by your Frost spells by 6%." } },
			[2] = { n = "Frostbite", r = 3, d = { "Gives your Chill effects a 5% chance to freeze the target for 5 sec.", "Gives your Chill effects a 10% chance to freeze the target for 5 sec.", "Gives your Chill effects a 15% chance to freeze the target for 5 sec." } },
			[3] = { n = "Improved Frost Nova", r = 2, d = { "Reduces the cooldown of your Frost Nova spell by 2 sec.", "Reduces the cooldown of your Frost Nova spell by 4 sec." } },
			[4] = { n = "Permafrost", r = 3, d = { "Increases the duration of your Chill effects by 1 sec and reduces the target's speed by an additional 4%.", "Increases the duration of your Chill effects by 2 secs and reduces the target's speed by an additional 7%.", "Increases the duration of your Chill effects by 3 secs and reduces the target's speed by an additional 10%." } },
		},
		[3] = {
			[1] = { n = "Ice Shards", r = 5, d = { "Increases the critical strike damage bonus of your Frost spells by 20%.", "Increases the critical strike damage bonus of your Frost spells by 40%.", "Increases the critical strike damage bonus of your Frost spells by 60%.", "Increases the critical strike damage bonus of your Frost spells by 80%.", "Increases the critical strike damage bonus of your Frost spells by 100%." } },
			[2] = { n = "Cold Snap", r = 1, d = { "When activated, this spell finishes the cooldown on all of your Frost spells." } },
			[4] = { n = "Improved Blizzard", r = 3, d = { "Adds a chill effect to your Blizzard spell.  This effect lowers the target's movement speed by 20%.  Lasts 1.5 sec.", "Adds a chill effect to your Blizzard spell.  This effect lowers the target's movement speed by 30%.  Lasts 1.5 sec.", "Adds a chill effect to your Blizzard spell.  This effect lowers the target's movement speed by 40%.  Lasts 1.5 sec." } },
		},
		[4] = {
			[1] = { n = "Arctic Reach", r = 2, d = { "Increases the range of your Frostbolt, Icicles and Blizzard spells and the radius of your Frost Nova and Cone of Cold spells by 10%.", "Increases the range of your Frostbolt, Icicles and Blizzard spells and the radius of your Frost Nova and Cone of Cold spells by 20%." } },
			[2] = { n = "Frost Channeling", r = 3, d = { "Reduces the mana cost of your Frost spells by 5% and reduces the threat caused by your Frost spells by 10%.", "Reduces the mana cost of your Frost spells by 10% and reduces the threat caused by your Frost spells by 20%.", "Reduces the mana cost of your Frost spells by 15% and reduces the threat caused by your Frost spells by 30%." } },
			[3] = { n = "Shatter", r = 5, d = { "Increases the critical strike chance of all your spells against frozen targets by 7%.", "Increases the critical strike chance of all your spells against frozen targets by 14%.", "Increases the critical strike chance of all your spells against frozen targets by 21%.", "Increases the critical strike chance of all your spells against frozen targets by 28%.", "Increases the critical strike chance of all your spells against frozen targets by 35%." } },
		},
		[5] = {
			[2] = { n = "Ice Block", r = 1, d = { "You become encased in a block of ice, protecting you from all physical attacks and spells for 10 sec, but during that time you cannot attack, move or cast spells." } },
			[3] = { n = "Icicles", r = 1, d = { "Draw upon frost leylines, becoming frozen in place, and launch icicles at the enemy, dealing 101 Frost damage every 1 sec for 5 sec.  Damage taken has a high chance to shatter your icy prison, dealing 30% of your base health as Frost damage to you.  Cancelling the effect early will not remove the freeze effect." } },
			[4] = { n = "Improved Cone of Cold", r = 3, d = { "Increases the damage dealt by your Cone of Cold spell by 15%.", "Increases the damage dealt by your Cone of Cold spell by 25%.", "Increases the damage dealt by your Cone of Cold spell by 35%." } },
		},
		[6] = {
			[1] = { n = "Winter's Chill", r = 5, d = { "Gives your Frost damage spells a 20% chance to apply the Winter's Chill effect, which increases the chance a Frost spell will critically hit the target by 2% for 15 sec.  Stacks up to 5 times.", "Gives your Frost damage spells a 40% chance to apply the Winter's Chill effect, which increases the chance a Frost spell will critically hit the target by 2% for 15 sec.  Stacks up to 5 times.", "Gives your Frost damage spells a 60% chance to apply the Winter's Chill effect, which increases the chance a Frost spell will critically hit the target by 2% for 15 sec.  Stacks up to 5 times.", "Gives your Frost damage spells a 80% chance to apply the Winter's Chill effect, which increases the chance a Frost spell will critically hit the target by 2% for 15 sec.  Stacks up to 5 times.", "Gives your Frost damage spells a 100% chance to apply the Winter's Chill effect, which increases the chance a Frost spell will critically hit the target by 2% for 15 sec.  Stacks up to 5 times." } },
			[3] = { n = "Flash Freeze", r = 2, d = { "If an effect that causes a target to freeze is not applied due to the target being permanently immune to freeze effects, you have a 50% chance to gain Flash Freeze instead. Flash Freeze resets the cooldown of Icicles and reduces the duration and the time between each Icicle by 80% for your next Icicles.", "If an effect that causes a target to freeze is not applied due to the target being permanently immune to freeze effects, you have a 100% chance to gain Flash Freeze instead. Flash Freeze resets the cooldown of Icicles and reduces the duration and the time between each Icicle by 80% for your next Icicles." } },
		},
		[7] = {
			[2] = { n = "Ice Barrier", r = 1, d = { { t = "Instantly shields you, absorbing  damage and increasing your Frost damage by 10% for 1 min. While the shield holds, spells will not be interrupted and Frost damage is increased by an additional 5%.", s = { { b = 438, p = 2.8, bl = 40, ml = 46, sl = 40 } } } } },
		},
	},
}
