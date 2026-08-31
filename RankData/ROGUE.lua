-- RankData/ROGUE.lua -- GENERATED, do not hand-edit.
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
TalentStage_RankData["ROGUE"] = {
	[1] = {
		[1] = {
			[1] = { n = "Improved Eviscerate", r = 3, d = { "Increases the damage done by your Eviscerate ability by 5%.", "Increases the damage done by your Eviscerate ability by 10%.", "Increases the damage done by your Eviscerate ability by 15%." } },
			[2] = { n = "Remorseless Attacks", r = 2, d = { "After killing an opponent that yields experience or honor, gives you a 20% increased critical strike chance on your next Combo Point generating ability.  Lasts 40 sec.", "After killing an opponent that yields experience or honor, gives you a 40% increased critical strike chance on your next Combo Point generating ability.  Lasts 40 sec." } },
			[3] = { n = "Malice", r = 5, d = { "Increases your critical strike chance by 1%.", "Increases your critical strike chance by 2%.", "Increases your critical strike chance by 3%.", "Increases your critical strike chance by 4%.", "Increases your critical strike chance by 5%." } },
		},
		[2] = {
			[1] = { n = "Ruthlessness", r = 3, d = { "Gives your finishing moves a 33% chance to add a combo point to your target.", "Gives your finishing moves a 66% chance to add a combo point to your target.", "Gives your finishing moves a 100% chance to add a combo point to your target." } },
			[2] = { n = "Murder", r = 2, d = { "Increases all damage caused against Humanoid, Giant, Beast and Dragonkin targets by 1%.", "Increases all damage caused against Humanoid, Giant, Beast and Dragonkin targets by 2%." } },
			[4] = { n = "Improved Blade Tactics", r = 3, d = { "Increases the duration of your Slice and Dice and Flourish abilities by 15%.", "Increases the duration of your Slice and Dice and Flourish abilities by 30%.", "Increases the duration of your Slice and Dice and Flourish abilities by 45%." } },
		},
		[3] = {
			[1] = { n = "Relentless Strikes", r = 1, d = { "Your finishing moves have a 20% chance per combo point to restore 20 energy and increase the damage of your finishing moves by 5% for 30 sec.  Stacks up to 5 times." } },
			[2] = { n = "Throwing Weapon Specialization", r = 2, d = { "Increases the range of Throw and Deadly Throw by 3 yards and gives your Deadly Throw a 50% chance to apply your off-hand weapon poison.", "Increases the range of Throw and Deadly Throw by 6 yards and gives your Deadly Throw a 100% chance to apply your off-hand weapon poison." } },
			[3] = { n = "Lethality", r = 5, d = { "Increases the critical strike damage bonus of your combo point generating abilities by 6%.", "Increases the critical strike damage bonus of your combo point generating abilities by 12%.", "Increases the critical strike damage bonus of your combo point generating abilities by 18%.", "Increases the critical strike damage bonus of your combo point generating abilities by 24%.", "Increases the critical strike damage bonus of your combo point generating abilities by 30%." } },
		},
		[4] = {
			[1] = { n = "Taste for Blood", r = 2, d = { "Increases the duration of your Rupture by 4 sec. Each time you use Rupture, your melee damage is increased by 1% per combo point for its full duration, regardless of successful application.", "Increases the duration of your Rupture by 6 sec. Each time you use Rupture, your melee damage is increased by 2% per combo point for its full duration, regardless of successful application." } },
			[2] = { n = "Vile Poisons", r = 3, d = { "Increases the damage dealt by your poisons by 10% and gives your poisons an additional 14% chance to resist dispel effects.", "Increases the damage dealt by your poisons by 20% and gives your poisons an additional 27% chance to resist dispel effects.", "Increases the damage dealt by your poisons by 30% and gives your poisons an additional 40% chance to resist dispel effects." } },
			[3] = { n = "Improved Poisons", r = 3, d = { "Increases the chance to apply poisons to your target by 3%.", "Increases the chance to apply poisons to your target by 6%.", "Increases the chance to apply poisons to your target by 10%." } },
		},
		[5] = {
			[1] = { n = "Efficient Poisons", r = 3, d = { "Reduces the chance your poisons will be resisted by 4% and gives your poison applications a 15% chance to not consume a charge.", "Reduces the chance your poisons will be resisted by 8% and gives your poison applications a 30% chance to not consume a charge.", "Reduces the chance your poisons will be resisted by 12% and gives your poison applications a 45% chance to not consume a charge." } },
			[2] = { n = "Envenom", r = 1, d = { "Finishing move that increases the effectiveness and the chance to apply poisons to your target by 30%.  Lasts longer per combo point:\n   1 point  : 12 seconds\n   2 points: 16 seconds\n   3 points: 20 seconds\n   4 points: 24 seconds\n   5 points: 28 seconds" } },
			[3] = { n = "Cold Blood", r = 1, d = { "When activated, increases the critical strike chance of your next Sinister Strike, Backstab, Ambush, Noxious Assault, or Eviscerate by 100%." } },
		},
		[6] = {
			[1] = { n = "Vigor", r = 2, d = { "Increases your maximum Energy by 5.  Each time you apply poison to your target, you have a 50% chance to gain 2 Energy.", "Increases your maximum Energy by 10.  Each time you apply poison to your target, you have a 100% chance to gain 2 Energy." } },
			[3] = { n = "Seal Fate", r = 5, d = { "Your critical strikes from abilities that add combo points have a 20% chance to add an additional combo point.", "Your critical strikes from abilities that add combo points have a 40% chance to add an additional combo point.", "Your critical strikes from abilities that add combo points have a 60% chance to add an additional combo point.", "Your critical strikes from abilities that add combo points have a 80% chance to add an additional combo point.", "Your critical strikes from abilities that add combo points have a 100% chance to add an additional combo point." } },
		},
		[7] = {
			[2] = { n = "Noxious Assault", r = 1, d = { "Strikes with both weapons, dealing 30 damage plus 30% of your Attack Power and applies poisons from both weapons. Awards 1 combo point." } },
		},
	},
	[2] = {
		[1] = {
			[2] = { n = "Opportunity", r = 5, d = { "Increases the damage dealt when striking from behind with your Backstab, Garrote, or Ambush abilities by 3%.", "Increases the damage dealt when striking from behind with your Backstab, Garrote, or Ambush abilities by 6%.", "Increases the damage dealt when striking from behind with your Backstab, Garrote, or Ambush abilities by 9%.", "Increases the damage dealt when striking from behind with your Backstab, Garrote, or Ambush abilities by 12%.", "Increases the damage dealt when striking from behind with your Backstab, Garrote, or Ambush abilities by 15%." } },
			[3] = { n = "Lightning Reflexes", r = 5, d = { "Increases your Dodge chance by 1%.", "Increases your Dodge chance by 2%.", "Increases your Dodge chance by 3%.", "Increases your Dodge chance by 4%.", "Increases your Dodge chance by 5%." } },
		},
		[2] = {
			[1] = { n = "Deflection", r = 5, d = { "Increases your Parry chance by 1%.", "Increases your Parry chance by 2%.", "Increases your Parry chance by 3%.", "Increases your Parry chance by 4%.", "Increases your Parry chance by 5%." } },
			[2] = { n = "Improved Backstab", r = 3, d = { "Increases the critical strike chance of your Backstab ability by 10% and gives your Backstab a 15% chance to award an additional combo point.", "Increases the critical strike chance of your Backstab ability by 20% and gives your Backstab a 30% chance to award an additional combo point.", "Increases the critical strike chance of your Backstab ability by 30% and gives your Backstab a 45% chance to award an additional combo point." } },
			[3] = { n = "Precision", r = 5, d = { "Increases your chance to hit with melee weapons by 1%.", "Increases your chance to hit with melee weapons by 2%.", "Increases your chance to hit with melee weapons by 3%.", "Increases your chance to hit with melee weapons by 4%.", "Increases your chance to hit with melee weapons by 5%." } },
		},
		[3] = {
			[1] = { n = "Riposte", r = 1, d = { "A strike that becomes active after parrying an opponent's attack.  This attack deals 150% weapon damage and disarms the target for 6 sec." } },
			[2] = { n = "Improved Sprint", r = 2, d = { "Gives a 50% chance to remove all movement impairing effects when you activate your Sprint ability.", "Gives a 100% chance to remove all movement impairing effects when you activate your Sprint ability." } },
			[4] = { n = "Setup", r = 3, d = { "Gives you a 15% chance to add a combo point to your target after dodging their attack or fully resisting one of their spells.", "Gives you a 30% chance to add a combo point to your target after dodging their attack or fully resisting one of their spells.", "Gives you a 45% chance to add a combo point to your target after dodging their attack or fully resisting one of their spells." } },
		},
		[4] = {
			[1] = { n = "Improved Kick", r = 2, d = { "Gives your Kick ability a 50% chance to silence the target for 2 sec.", "Gives your Kick ability a 100% chance to silence the target for 2 sec." } },
			[2] = { n = "Concussive Blows", r = 5, d = { "Gives you a 1% chance to stun your target for 3 sec with a mace.", "Gives you a 2% chance to stun your target for 3 sec with a mace.", "Gives you a 3% chance to stun your target for 3 sec with a mace.", "Gives you a 4% chance to stun your target for 3 sec with a mace.", "Gives you a 6% chance to stun your target for 3 sec with a mace." } },
			[3] = { n = "Dual Wield Specialization", r = 5, d = { "Increases the damage done by your offhand weapon by 10%.", "Increases the damage done by your offhand weapon by 20%.", "Increases the damage done by your offhand weapon by 30%.", "Increases the damage done by your offhand weapon by 40%.", "Increases the damage done by your offhand weapon by 50%." } },
		},
		[5] = {
			[1] = { n = "Close Quarters Combat", r = 2, d = { "Increases your chance to get a critical strike with Maces, Daggers and Fist Weapons by 2%.", "Increases your chance to get a critical strike with Maces, Daggers and Fist Weapons by 5%." } },
			[2] = { n = "Surprise Attack", r = 1, d = { "A surprise strike that deals 25% of your Attack Power as damage.\nOnly useable after the target dodges and cannot be blocked, dodged or parried by the target.  Awards 1 combo point." } },
			[3] = { n = "Hack and Slash", r = 2, d = { "Gives you a 2% chance to get an extra attack on the same target after dealing damage with your Axe or Sword.", "Gives you a 5% chance to get an extra attack on the same target after dealing damage with your Axe or Sword." } },
			[4] = { n = "Weapon Expertise", r = 2, d = { "Increases your skill with Axe, Dagger, Fist, Mace and Sword weapons by 3.", "Increases your skill with Axe, Dagger, Fist, Mace and Sword weapons by 5." } },
		},
		[6] = {
			[2] = { n = "Blade Rush", r = 2, d = { "Increases your melee attack speed by 2% and reduces the time between your Energy regeneration ticks by an amount equal to your Agility.", "Increases your melee attack speed by 5% and reduces the time between your Energy regeneration ticks by an amount equal to your Agility. More effective than Blade Rush (Rank 1)." } },
			[3] = { n = "Aggression", r = 3, d = { "Increases the damage of your Sinister Strike, Eviscerate, Riposte and Surprise Attack abilities by 3%.", "Increases the damage of your Sinister Strike, Eviscerate, Riposte and Surprise Attack abilities by 6%.", "Increases the damage of your Sinister Strike, Eviscerate, Riposte and Surprise Attack abilities by 10%." } },
		},
		[7] = {
			[2] = { n = "Adrenaline Rush", r = 1, d = { "Increases your Energy regeneration rate by 100% for 15 sec." } },
		},
	},
	[3] = {
		[1] = {
			[2] = { n = "Camouflage", r = 5, d = { "Increases your speed while stealthed by 3% and reduces the cooldown of your Stealth ability by 1 sec. In addition, reduces the chance enemies have to detect you while in Stealth mode.", "Increases your speed while stealthed by 6% and reduces the cooldown of your Stealth ability by 2 sec. In addition, reduces the chance enemies have to detect you while in Stealth mode. More effective than Camouflage (Rank 1).", "Increases your speed while stealthed by 9% and reduces the cooldown of your Stealth ability by 3 sec. In addition, reduces the chance enemies have to detect you while in Stealth mode. More effective than Camouflage (Rank 2).", "Increases your speed while stealthed by 12% and reduces the cooldown of your Stealth ability by 4 sec. In addition, reduces the chance enemies have to detect you while in Stealth mode. More effective than Camouflage (Rank 3).", "Increases your speed while stealthed by 15% and reduces the cooldown of your Stealth ability by 5 sec. In addition, reduces the chance enemies have to detect you while in Stealth mode. More effective than Camouflage (Rank 4)." } },
			[3] = { n = "Improved Expose Armor", r = 2, d = { "Increases the armor reduced by your Expose Armor ability by 25%.", "Increases the armor reduced by your Expose Armor ability by 50%." } },
			[4] = { n = "Improved Gouge", r = 3, d = { "Increases the effect duration of your Gouge ability by 0.5 sec.", "Increases the effect duration of your Gouge ability by 1 sec.", "Increases the effect duration of your Gouge ability by 1.5 sec." } },
		},
		[2] = {
			[1] = { n = "Improved Ambush", r = 3, d = { "Increases the critical strike chance of your Ambush ability by 15%.  Your Ambush will refund 5 Energy if it does not result in a critical strike.", "Increases the critical strike chance of your Ambush ability by 30%.  Your Ambush will refund 10 Energy if it does not result in a critical strike.", "Increases the critical strike chance of your Ambush ability by 45%.  Your Ambush will refund 15 Energy if it does not result in a critical strike." } },
			[2] = { n = "Elusiveness", r = 2, d = { "Reduces the cooldown of your Vanish and Blind abilities by 45 sec.", "Reduces the cooldown of your Vanish and Blind abilities by 1.5 min." } },
			[3] = { n = "Serrated Blades", r = 3, d = { { t = "Increases the damage dealt by your Rupture and Garrote abilities by 10% and causes your attacks to ignore  of your target's Armor.", s = { { b = 0, p = -1.67 } } }, { t = "Increases the damage dealt by your Rupture and Garrote abilities by 20% and causes your attacks to ignore  of your target's Armor.", s = { { b = 0, p = -3.34 } } }, { t = "Increases the damage dealt by your Rupture and Garrote abilities by 30% and causes your attacks to ignore  of your target's Armor.", s = { { b = 0, p = -5 } } } } },
		},
		[3] = {
			[1] = { n = "Initiative", r = 3, d = { "Gives you a 33% chance to add an additional combo point to your target when using your Ambush, Garrote, or Cheap Shot ability.", "Gives you a 66% chance to add an additional combo point to your target when using your Ambush, Garrote, or Cheap Shot ability.", "Gives you a 100% chance to add an additional combo point to your target when using your Ambush, Garrote, or Cheap Shot ability." } },
			[2] = { n = "Improved Ghostly Strike", r = 3, d = { "Your Ghostly Strike increases your movement speed by 5% and increases your party members' movement speed by 2% within 30 yards for 5 sec. In addition, reduces the Energy cost of your Ghostly Strike by 3.", "Your Ghostly Strike increases your movement speed by 10% and increases your party members' movement speed by 4% within 30 yards for 5 sec. In addition, reduces the Energy cost of your Ghostly Strike by 6.", "Your Ghostly Strike increases your movement speed by 15% and increases your party members' movement speed by 6% within 30 yards for 5 sec. In addition, reduces the Energy cost of your Ghostly Strike by 10." } },
			[3] = { n = "Smoke Bomb", r = 1, d = { "Creates a cloud of thick smoke in 8 yards around you for 8 sec. All targets inside the smoke have a 20% reduced chance of being hit by attacks and spells for the duration." } },
			[4] = { n = "Hemorrhage", r = 1, d = { "An instant strike that deals 110% weapon damage and causes the target to hemorrhage, increasing any Physical damage dealt to the target by 2%.  Lasts 50 charges or 15 sec.  Awards 1 combo point." } },
		},
		[4] = {
			[1] = { n = "Cloaked in Shadows", r = 2, d = { "Whenever you Vanish, you and nearby party members within 20 yards are cloaked in shadows, gaining a barrier that absorbs up to 6% of your maximum health for 20 sec.", "Whenever you Vanish, you and nearby party members within 20 yards are cloaked in shadows, gaining a barrier that absorbs up to 12% of your maximum health for 20 sec." } },
			[2] = { n = "Blackjack", r = 2, d = { "Your Sap and Blind abilities reduce the target's damage dealt by 5% for 8 sec when their effect ends or fails to apply. In addition, you have a 50% chance to return to stealth after using your Sap ability.", "Your Sap and Blind abilities reduce the target's damage dealt by 10% for 8 sec when their effect ends or fails to apply. In addition, you have a 100% chance to return to stealth after using your Sap ability." } },
			[3] = { n = "Blinding Haze", r = 3, d = { "Reduces the Energy cost of your Distract by 5. In addition, targets hit by your Distract have their chance to hit reduced by 2% for 6 sec. This effect is guaranteed to be applied.", "Reduces the Energy cost of your Distract by 10. In addition, targets hit by your Distract have their chance to hit reduced by 4% for 6 sec. This effect is guaranteed to be applied.", "Reduces the Energy cost of your Distract by 15. In addition, targets hit by your Distract have their chance to hit reduced by 6% for 6 sec. This effect is guaranteed to be applied." } },
		},
		[5] = {
			[1] = { n = "Dirty Deeds", r = 2, d = { "Reduces the Energy cost of your Cheap Shot and Garrote abilities by 10.", "Reduces the Energy cost of your Cheap Shot and Garrote abilities by 20." } },
			[2] = { n = "Preparation", r = 1, d = { "When activated, this ability immediately finishes the cooldown on your other Rogue abilities." } },
			[3] = { n = "Shadow of Death", r = 1, d = { "A finishing move that etches a sigil onto the target for 6 sec. The sigil accumulates damage equal to a percentage of all damage the target takes during its duration, up to a percentage of your Attack Power. When the maximum capacity is reached or the sigil expires, the stored damage is unleashed as Physical damage. Both values increase with each combo point:\n   1 point : 10% of damage accumulated, up to 50% of Attack Power\n   2 points: 20% of damage accumulated, up to 100% of Attack Power\n   3 points: 30% of damage accumulated, up to 150% of Attack Power\n   4 points: 40% of damage accumulated, up to 200% of Attack Power\n   5 points: 50% of damage accumulated, up to 250% of Attack Power" } },
			[4] = { n = "Bloody Mess", r = 2, d = { "Reduces the Energy cost of your Hemorrhage by 2 and increases the Physical damage dealt bonus of your Hemorrhage by 50%.", "Reduces the Energy cost of your Hemorrhage by 5 and increases the Physical damage dealt bonus of your Hemorrhage by 100%." } },
		},
		[6] = {
			[1] = { n = "Honor Among Thieves", r = 2, d = { "Physical critical strikes by you or party members within 20 yards grant you 2 Energy.", "Physical critical strikes by you or party members within 20 yards grant you 5 Energy." } },
			[3] = { n = "Tricks of the Trade", r = 5, d = { "Your opening moves have a 20% chance and your finishing moves have a 4% chance per combo point to increase your party members' critical strike chance by 2% for 12 sec. This effect stacks up to 2 times.", "Your opening moves have a 40% chance and your finishing moves have a 8% chance per combo point to increase your party members' critical strike chance by 2% for 12 sec. This effect stacks up to 2 times.", "Your opening moves have a 60% chance and your finishing moves have a 12% chance per combo point to increase your party members' critical strike chance by 2% for 12 sec. This effect stacks up to 2 times.", "Your opening moves have a 80% chance and your finishing moves have a 16% chance per combo point to increase your party members' critical strike chance by 2% for 12 sec. This effect stacks up to 2 times.", "Your opening moves have a 100% chance and your finishing moves have a 20% chance per combo point to increase your party members' critical strike chance by 2% for 12 sec. This effect stacks up to 2 times." } },
		},
		[7] = {
			[2] = { n = "Mark for Death", r = 1, d = { "A marking strike that deals 135% weapon damage and reveals the target's vulnerabilities, increasing your party members' Attack Power by 30% and damage done by magical spells and effects up to 18% of your melee Attack Power for 8 sec. Cannot be blocked, dodged or parried by the target. Awards 2 combo points." } },
		},
	},
}
