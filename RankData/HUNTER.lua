-- RankData/HUNTER.lua -- GENERATED, do not hand-edit.
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
TalentStage_RankData["HUNTER"] = {
	[1] = {
		[1] = {
			[2] = { n = "Swift Aspects", r = 5, d = { "While Aspect of the Hawk is active, all normal ranged attacks have a 10% chance of increasing ranged attack speed by 3% for 12 sec.  While Aspect of the Wolf is active, all normal melee attacks have a 10% chance of increasing melee attack speed by 3% for 12 sec.", "While Aspect of the Hawk is active, all normal ranged attacks have a 10% chance of increasing ranged attack speed by 6% for 12 sec.  While Aspect of the Wolf is active, all normal melee attacks have a 10% chance of increasing melee attack speed by 6% for 12 sec.", "While Aspect of the Hawk is active, all normal ranged attacks have a 10% chance of increasing ranged attack speed by 9% for 12 sec.  While Aspect of the Wolf is active, all normal melee attacks have a 10% chance of increasing melee attack speed by 9% for 12 sec.", "While Aspect of the Hawk is active, all normal ranged attacks have a 10% chance of increasing ranged attack speed by 12% for 12 sec.  While Aspect of the Wolf is active, all normal melee attacks have a 10% chance of increasing melee attack speed by 12% for 12 sec.", "While Aspect of the Hawk is active, all normal ranged attacks have a 10% chance of increasing ranged attack speed by 15% for 12 sec.  While Aspect of the Wolf is active, all normal melee attacks have a 10% chance of increasing melee attack speed by 15% for 12 sec." } },
			[3] = { n = "Endurance Training", r = 5, d = { "Adds 6% of your Stamina to your pets' Stamina and increases their health by 2%.", "Adds 12% of your Stamina to your pets' Stamina and increases their health by 4%.", "Adds 18% of your Stamina to your pets' Stamina and increases their health by 6%.", "Adds 24% of your Stamina to your pets' Stamina and increases their health by 8%.", "Adds 30% of your Stamina to your pets' Stamina and increases their health by 10%." } },
		},
		[2] = {
			[1] = { n = "Improved Eyes of the Beast", r = 2, d = { "Increases the duration of your Eyes of the Beast by 30 sec.\n\nWhile channeling Eyes of the Beast, your pet deals 15% additional damage and gains 15% increased Focus regeneration.", "Increases the duration of your Eyes of the Beast by 60 sec.\n\nWhile channeling Eyes of the Beast, your pet deals 30% additional damage and gains 30% increased Focus regeneration." } },
			[2] = { n = "Improved Primal Aspects", r = 3, d = { "Increases the Dodge bonus of your Aspect of the Monkey by 2%. While Aspect of the Wolf is active, you're healed for 2% of your melee damage.", "Increases the Dodge bonus of your Aspect of the Monkey by 4%. While Aspect of the Wolf is active, you're healed for 4% of your melee damage.", "Increases the Dodge bonus of your Aspect of the Monkey by 6%. While Aspect of the Wolf is active, you're healed for 6% of your melee damage." } },
			[3] = { n = "Thick Hide", r = 3, d = { "Adds 12% of your armor value from items to the armor value of your pets and increases the armor value of your pets by 7%.", "Adds 24% of your armor value from items to the armor value of your pets and increases the armor value of your pets by 14%.", "Adds 36% of your armor value from items to the armor value of your pets and increases the armor value of your pets by 20%." } },
			[4] = { n = "Improved Revive Pet", r = 2, d = { "Revive Pet's casting time is reduced by 3 sec, mana cost is reduced by 20%, and increases the health your pet returns with by an additional 15%.", "Revive Pet's casting time is reduced by 6 sec, mana cost is reduced by 40%, and increases the health your pet returns with by an additional 30%." } },
		},
		[3] = {
			[1] = { n = "Pathfinding", r = 2, d = { "Increases the speed bonus of your Aspect of the Cheetah and Aspect of the Pack by 3% and increases your pet's movement speed by 15%. ", "Increases the speed bonus of your Aspect of the Cheetah and Aspect of the Pack by 6% and increases your pet's movement speed by 30%. " } },
			[2] = { n = "Coordinated Assault", r = 1, d = { "Hitting an enemy with Arcane Shot, Steady Shot, or Raptor Strike causes your pet's next attack within 6 sec to also strike for Physical damage equal to 20% of your Attack Power. This effect can only occur once every 3 sec." } },
			[3] = { n = "Unleashed Fury", r = 5, d = { "Increases the damage done by your pets by 4%.", "Increases the damage done by your pets by 8%.", "Increases the damage done by your pets by 12%.", "Increases the damage done by your pets by 16%.", "Increases the damage done by your pets by 20%." } },
		},
		[4] = {
			[1] = { n = "Bestial Discipline", r = 2, d = { "Increases the Focus regeneration of your pets by 2 each tick and reduces the cooldown of your pets' special ability by 10%.", "Increases the Focus regeneration of your pets by 5 each tick and reduces the cooldown of your pets' special ability by 20%." } },
			[2] = { n = "Improved Mend Pet", r = 2, d = { "Increases amount you heal your pet with Mend Pet by 20% and gives the spell a 15% chance of cleansing 1 Curse, Disease, Magic or Poison effect from the pet each tick.", "Increases amount you heal your pet with Mend Pet by 40% and gives the spell a 50% chance of cleansing 1 Curse, Disease, Magic or Poison effect from the pet each tick." } },
			[3] = { n = "Ferocity", r = 5, d = { "Increases the critical strike chance of your pets by 3%.", "Increases the critical strike chance of your pets by 6%.", "Increases the critical strike chance of your pets by 9%.", "Increases the critical strike chance of your pets by 12%.", "Increases the critical strike chance of your pets by 15%." } },
		},
		[5] = {
			[1] = { n = "Scent of Blood", r = 3, d = { "Your attacks have a 5% chance to send your pet into a rage, causing it to deal 40% additional damage for 8 sec.", "Your attacks have a 10% chance to send your pet into a rage, causing it to deal 40% additional damage for 8 sec.", "Your attacks have a 15% chance to send your pet into a rage, causing it to deal 40% additional damage for 8 sec." } },
			[2] = { n = "Bestial Wrath", r = 1, d = { "Sends your pet into a rage, granting it Scent of Blood for 18 sec. While enraged, the beast does not feel pity, remorse, or fear, and cannot be stopped except by death." } },
			[4] = { n = "Intimidation", r = 1, d = { "Command your pet to intimidate the target on the next successful melee attack, stunning the target for 3 sec, and increasing the pet's threat generation by 50% for 8 sec." } },
		},
		[6] = {
			[1] = { n = "Bestial Precision", r = 2, d = { "Increases the physical hit chance of your pets by 4% and the spell hit chance of your pets by 9%. In addition, increases the weapon skill of your pets by 5.", "Increases the physical hit chance of your pets by 8% and the spell hit chance of your pets by 18%. In addition, increases the weapon skill of your pets by 10." } },
			[2] = { n = "Spirit Bond", r = 2, d = { "Your pet gains melee attack power equal to 12% of your ranged attack power and spell power equal to 7% of your ranged attack power. While your pet is active, you and your pet will regenerate 1% of total health every 5 sec.", "Your pet gains melee attack power equal to 25% of your ranged attack power and spell power equal to 15% of your ranged attack power. While your pet is active, you and your pet will regenerate 2% of total health every 5 sec." } },
			[3] = { n = "Frenzy", r = 5, d = { "Gives your pet a 20% chance to gain a 30% attack speed increase for 8 sec after dealing a critical strike.", "Gives your pet a 40% chance to gain a 30% attack speed increase for 8 sec after dealing a critical strike.", "Gives your pet a 60% chance to gain a 30% attack speed increase for 8 sec after dealing a critical strike.", "Gives your pet a 80% chance to gain a 30% attack speed increase for 8 sec after dealing a critical strike.", "Gives your pet a 100% chance to gain a 30% attack speed increase for 8 sec after dealing a critical strike." } },
		},
		[7] = {
			[2] = { n = "Kill Command", r = 1, d = { "Commands your pet to instantly attack for 80% of its Attack Power. Can only be used after the Hunter lands a critical strike on the target." } },
		},
	},
	[2] = {
		[1] = {
			[2] = { n = "Improved Concussive Shot", r = 5, d = { "Gives your Concussive Shot a 4% chance to stun the target for 3 sec.", "Gives your Concussive Shot a 8% chance to stun the target for 3 sec.", "Gives your Concussive Shot a 12% chance to stun the target for 3 sec.", "Gives your Concussive Shot a 16% chance to stun the target for 3 sec.", "Gives your Concussive Shot a 20% chance to stun the target for 3 sec." } },
			[3] = { n = "Efficiency", r = 5, d = { "Reduces the Mana cost of your Shots and Stings by 2%.", "Reduces the Mana cost of your Shots and Stings by 4%.", "Reduces the Mana cost of your Shots and Stings by 6%.", "Reduces the Mana cost of your Shots and Stings by 8%.", "Reduces the Mana cost of your Shots and Stings by 10%." } },
		},
		[2] = {
			[2] = { n = "Improved Stings", r = 5, d = { "Increases the damage of Serpent Sting by 6%, increases the mana drained by Viper Sting by 1%, and causes Scorpid Sting to reduce attack speed by an additional 2%.", "Increases the damage of Serpent Sting by 12%, increases the mana drained by Viper Sting by 2%, and causes Scorpid Sting to reduce attack speed by an additional 4%.", "Increases the damage of Serpent Sting by 18%, increases the mana drained by Viper Sting by 3%, and causes Scorpid Sting to reduce attack speed by an additional 6%.", "Increases the damage of Serpent Sting by 24%, increases the mana drained by Viper Sting by 4%, and causes Scorpid Sting to reduce attack speed by an additional 8%.", "Increases the damage of Serpent Sting by 30%, increases the mana drained by Viper Sting by 5%, and causes Scorpid Sting to reduce attack speed by an additional 10%." } },
			[3] = { n = "Lethal Shots", r = 5, d = { "Increases your critical strike chance with ranged weapons by 1%.", "Increases your critical strike chance with ranged weapons by 2%.", "Increases your critical strike chance with ranged weapons by 3%.", "Increases your critical strike chance with ranged weapons by 4%.", "Increases your critical strike chance with ranged weapons by 5%." } },
		},
		[3] = {
			[1] = { n = "Hawk Eye", r = 2, d = { "Increases the range of your ranged weapons by 3 yards.", "Increases the range of your ranged weapons by 6 yards." } },
			[2] = { n = "Aimed Shot", r = 1, d = { "An aimed shot that increases ranged damage by 70." } },
			[4] = { n = "Swiftshot", r = 3, d = { "Reduces the cooldown of Arcane Shot by 0.5 sec and the cooldown of Aimed Shot by 2 sec.", "Reduces the cooldown of Arcane Shot by 1 sec and the cooldown of Aimed Shot by 4 sec.", "Reduces the cooldown of Arcane Shot by 1.5 sec and the cooldown of Aimed Shot by 6 sec." } },
		},
		[4] = {
			[1] = { n = "Endless Quiver", r = 2, d = { "Your Auto Shot, Arcane Shot, Steady Shot and Multi-Shot have a 3% chance to fire an additional normal ranged attack.  This additional shot does not spend ammo.", "Your Auto Shot, Arcane Shot, Steady Shot and Multi-Shot have a 6% chance to fire an additional normal ranged attack.  This additional shot does not spend ammo." } },
			[3] = { n = "Mortal Shots", r = 5, d = { "Increases your ranged weapon critical strike damage bonus by 6%.", "Increases your ranged weapon critical strike damage bonus by 12%.", "Increases your ranged weapon critical strike damage bonus by 18%.", "Increases your ranged weapon critical strike damage bonus by 24%.", "Increases your ranged weapon critical strike damage bonus by 30%." } },
		},
		[5] = {
			[1] = { n = "Scatter Shot", r = 1, d = { "A short-range shot that deals 50% weapon damage and disorients the target for 4 sec.  Any damage caused will remove the effect.  Turns off your attack when used." } },
			[2] = { n = "Experimental Ammunition", r = 1, d = { { t = "Your Aimed Shot deals an additional 5% of its damage as Fire, Arcane, or Nature damage, based on the active effect. Grants a further benefit depending on the element:\n- Explosive Ammunition: Your next Multi-Shot causes hits to explode, dealing 20% ranged weapon damage to enemies within 5 yards of the targets.\n- Poisonous Ammunition: Your next Serpent Sting deals 100% increased damage and applies a corrosive poison that reduces the target's armor by  for 15 sec.\n- Enchanted Ammunition: Your next Arcane Shot deals 100% increased damage and weakens the target's resistance to magic, increasing magic damage taken by 3% for 6 sec.", s = { { b = 0, p = -4 } } } } },
			[3] = { n = "Piercing Shots", r = 2, d = { "Your critical strikes from Multi-Shot, Steady Shot and Aimed Shot cause the target to bleed, dealing 15% of the damage over 8 sec.  This damage generates no threat.", "Your critical strikes from Multi-Shot, Steady Shot and Aimed Shot cause the target to bleed, dealing 30% of the damage over 8 sec.  This damage generates no threat." } },
			[4] = { n = "Barrage", r = 3, d = { "Increases the damage of Multi-Shot and Volley by 5% and reduces the cast time of Volley by 1 sec.", "Increases the damage of Multi-Shot and Volley by 10% and reduces the cast time of Volley by 1.5 sec.", "Increases the damage of Multi-Shot and Volley by 15% and reduces the cast time of Volley by 2 sec." } },
		},
		[6] = {
			[1] = { n = "Improved Marksmanship", r = 2, d = { "Increases the damage of Steady Shot and Aimed Shot by 5%.", "Increases the damage of Steady Shot and Aimed Shot by 10%." } },
			[3] = { n = "Ranged Weapon Specialization", r = 5, d = { "Increases the damage you deal with ranged weapons by 2%.", "Increases the damage you deal with ranged weapons by 4%.", "Increases the damage you deal with ranged weapons by 6%.", "Increases the damage you deal with ranged weapons by 8%.", "Increases the damage you deal with ranged weapons by 10%." } },
		},
		[7] = {
			[2] = { n = "Lock and Load", r = 1, d = { "Your Steady Shot, Aimed Shot, and Arcane Shot critical strikes have a 100% chance to reset the cooldown of Aimed Shot and trigger Lock and Load. Lock and Load reduces the cast time of Aimed Shot by 1 sec and causes Aimed Shot to hit all enemies between you and the target. Lasts 10 sec or until Aimed Shot is cast." } },
		},
	},
	[3] = {
		[1] = {
			[1] = { n = "Improved Slaying", r = 3, d = { "Increases all damage caused against Beasts, Giants, Dragonkin, and Humanoid targets by 1% and increases critical damage caused against Beasts, Giants, Dragonkin, and Humanoid targets by an additional 1%.", "Increases all damage caused against Beasts, Giants, Dragonkin, and Humanoid targets by 2% and increases critical damage caused against Beasts, Giants, Dragonkin, and Humanoid targets by an additional 2%.", "Increases all damage caused against Beasts, Giants, Dragonkin, and Humanoid targets by 3% and increases critical damage caused against Beasts, Giants, Dragonkin, and Humanoid targets by an additional 3%." } },
			[2] = { n = "Resourcefulness", r = 5, d = { "Reduces the Mana cost of all traps and melee abilities by 2%.", "Reduces the Mana cost of all traps and melee abilities by 4%.", "Reduces the Mana cost of all traps and melee abilities by 6%.", "Reduces the Mana cost of all traps and melee abilities by 8%.", "Reduces the Mana cost of all traps and melee abilities by 10%." } },
			[3] = { n = "Swift Reflexes", r = 2, d = { "Increases your Parry chance and attack speed by 1%.", "Increases your Parry chance and attack speed by 2%." } },
		},
		[2] = {
			[1] = { n = "Entrapment", r = 3, d = { "Gives your Immolation Trap, Frost Trap, and Explosive Trap a 8% chance to entrap the target, preventing them from moving for 5 sec.", "Gives your Immolation Trap, Frost Trap, and Explosive Trap a 16% chance to entrap the target, preventing them from moving for 5 sec.", "Gives your Immolation Trap, Frost Trap, and Explosive Trap a 25% chance to entrap the target, preventing them from moving for 5 sec." } },
			[2] = { n = "Savage Strikes", r = 2, d = { "Increases the damage done by your offhand weapon by 13% and the critical strike chance of your Lacerate, Raptor Strike, Mongoose Bite, Carve and Wing Clip abilities by 3%.", "Increases the damage done by your offhand weapon by 25% and the critical strike chance of your Lacerate, Raptor Strike, Mongoose Bite, Carve and Wing Clip abilities by 6%." } },
			[3] = { n = "Improved Wing Clip", r = 3, d = { "Gives your Wing Clip ability a 14% chance to immobilize the target for 5 sec.", "Gives your Wing Clip ability a 28% chance to immobilize the target for 5 sec.", "Gives your Wing Clip ability a 40% chance to immobilize the target for 5 sec." } },
			[4] = { n = "Alone Against the World", r = 2, d = { "While you have no pet under your control, all damage dealt is increased by 3%.", "While you have no pet under your control, all damage dealt is increased by 6%." } },
		},
		[3] = {
			[1] = { n = "Planning Ahead", r = 2, d = { "The duration of Freezing and Frost Trap effects and the damage of Immolation and Explosive Trap effects are increased by 13% if the traps are not triggered within the first 5 sec after being placed.", "The duration of Freezing and Frost Trap effects and the damage of Immolation and Explosive Trap effects are increased by 25% if the traps are not triggered within the first 5 sec after being placed." } },
			[2] = { n = "Survivalist", r = 5, d = { "Increases total health by 2%.", "Increases total health by 4%.", "Increases total health by 6%.", "Increases total health by 8%.", "Increases total health by 10%." } },
			[3] = { n = "Carve", r = 1, d = { "A sweeping attack that strikes up to 5 enemies in a 10 yard cone in front of you, dealing 60% weapon damage.\nThis ability shares a cooldown with Multi-Shot." } },
			[4] = { n = "Deterrence", r = 1, d = { "When activated, increases your Dodge and Parry chance by 25% for 10 sec." } },
		},
		[4] = {
			[1] = { n = "Stinging Nettle", r = 2, d = { "Your Mongoose Bite and triggered Fire traps now apply your highest rank of Serpent Sting for 20% of the duration. Serpent Stings applied this way ignore resistances and immunities.", "Your Mongoose Bite and triggered Fire traps now apply your highest rank of Serpent Sting for 40% of the duration. Serpent Stings applied this way ignore resistances and immunities." } },
			[2] = { n = "Surefooted", r = 3, d = { "Increases hit chance by 1%, and by an additional 1% while dual wielding.\nIn addition, increases the chance to resist movement impairing effects by 5%.", "Increases hit chance by 2%, and by an additional 2% while dual wielding.\nIn addition, increases the chance to resist movement impairing effects by 10%.", "Increases hit chance by 3%, and by an additional 3% while dual wielding.\nIn addition, increases the chance to resist movement impairing effects by 15%." } },
			[4] = { n = "Improved Feign Death", r = 2, d = { "Reduces the chance your Feign Death ability will be resisted by 4%.", "Reduces the chance your Feign Death ability will be resisted by 8%." } },
		},
		[5] = {
			[1] = { n = "Killer Instinct", r = 3, d = { "Increases your critical strike chance with all attacks by 1%, increases your melee critical strike damage bonus by 7%.", "Increases your critical strike chance with all attacks by 2%, increases your melee critical strike damage bonus by 14%.", "Increases your critical strike chance with all attacks by 3%, increases your melee critical strike damage bonus by 20%." } },
			[2] = { n = "Trap Mastery", r = 3, d = { "Increases the duration of Freezing and Frost Trap effects by 10% and the damage of Immolation and Explosive Trap effects by 10%.  In addition, reduces the chance that enemies will resist trap effects by 4%.", "Increases the duration of Freezing and Frost Trap effects by 20% and the damage of Immolation and Explosive Trap effects by 20%.  In addition, reduces the chance that enemies will resist trap effects by 7%.", "Increases the duration of Freezing and Frost Trap effects by 30% and the damage of Immolation and Explosive Trap effects by 30%.  In addition, reduces the chance that enemies will resist trap effects by 10%." } },
			[3] = { n = "Lacerate", r = 1, d = { "Deepens the target's open wound, dealing damage equal to 40% of melee Attack Power and causing the target to bleed for 20% of that damage over 8 sec. Can only be used after critically striking the target. Using this ability from the target's sides increases its damage by 15%." } },
		},
		[6] = {
			[1] = { n = "Vicious Strikes", r = 2, d = { "Reduces the cooldown of Raptor Strike and Mongoose Bite by 0.5 sec and increases the damage they deal by 5%.", "Reduces the cooldown of Raptor Strike and Mongoose Bite by 1 sec and increases the damage they deal by 10%." } },
			[3] = { n = "Lightning Reflexes", r = 5, d = { "Increases your Agility by 2% and increases your melee attack power by an amount equal to 20% of your Agility.", "Increases your Agility by 4% and increases your melee attack power by an amount equal to 40% of your Agility.", "Increases your Agility by 6% and increases your melee attack power by an amount equal to 60% of your Agility.", "Increases your Agility by 8% and increases your melee attack power by an amount equal to 80% of your Agility.", "Increases your Agility by 10% and increases your melee attack power by an amount equal to 100% of your Agility." } },
		},
		[7] = {
			[2] = { n = "Untamed Trapper", r = 1, d = { "Reduces the mana cost of your Immolation Trap and Explosive Trap effects by 20% and increases their damage based on your melee Attack Power. In addition, all traps can be placed while in combat." } },
		},
	},
}
