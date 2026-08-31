-- RankData/DRUID.lua -- GENERATED, do not hand-edit.
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
TalentStage_RankData["DRUID"] = {
	[1] = {
		[1] = {
			[1] = { n = "Improved Wrath", r = 5, d = { "Reduces the cast time and global cooldown of your Wrath spell by 0.1 sec.", "Reduces the cast time and global cooldown of your Wrath spell by 0.2 sec.", "Reduces the cast time and global cooldown of your Wrath spell by 0.3 sec.", "Reduces the cast time and global cooldown of your Wrath spell by 0.4 sec.", "Reduces the cast time and global cooldown of your Wrath spell by 0.5 sec." } },
			[2] = { n = "Nature's Grasp", r = 1, d = { "While active, any time an enemy strikes the caster they have a 35% chance to become afflicted by Entangling Roots (Rank 1).  Only useable outdoors.  1 charge.  Lasts 45 sec." } },
			[3] = { n = "Improved Nature's Grasp", r = 4, d = { "Increases the chance for your Nature's Grasp to entangle an enemy by 15%.", "Increases the chance for your Nature's Grasp to entangle an enemy by 30%.", "Increases the chance for your Nature's Grasp to entangle an enemy by 45%.", "Increases the chance for your Nature's Grasp to entangle an enemy by 65%." } },
			[4] = { n = "Sylvan Blessing", r = 2, d = { "Gives you a 50% chance after killing a target that yields experience or honor to allow your Mana to regenerate at a 100% rate while casting.  Lasts 15 sec.", "Gives you a 100% chance after killing a target that yields experience or honor to allow your Mana to regenerate at a 100% rate while casting.  Lasts 15 sec." } },
		},
		[2] = {
			[1] = { n = "Guidance of the Dream", r = 3, d = { "Gives you a 23% chance to avoid interruption caused by damage while casting your Balance spells.", "Gives you a 46% chance to avoid interruption caused by damage while casting your Balance spells.", "Gives you a 70% chance to avoid interruption caused by damage while casting your Balance spells." } },
			[2] = { n = "Improved Moonfire", r = 2, d = { "Increases the damage and critical strike chance of your Moonfire spell by 5%.", "Increases the damage and critical strike chance of your Moonfire spell by 10%." } },
			[3] = { n = "Natural Weapons", r = 3, d = { "Increases the damage you deal with physical attacks in all forms by 3%. Also increases chance to hit with melee attacks and spells by 1%.", "Increases the damage you deal with physical attacks in all forms by 6%. Also increases chance to hit with melee attacks and spells by 2%.", "Increases the damage you deal with physical attacks in all forms by 10%. Also increases chance to hit with melee attacks and spells by 3%." } },
			[4] = { n = "Natural Shapeshifter", r = 3, d = { "Reduces the mana cost of all shapeshifting by 10%.", "Reduces the mana cost of all shapeshifting by 20%.", "Reduces the mana cost of all shapeshifting by 30%." } },
		},
		[3] = {
			[1] = { n = "Moonfury", r = 3, d = { "Increases the damage of your Starfire, Moonfire, Hurricane, Insect Swarm, and Wrath spells by 4%.", "Increases the damage of your Starfire, Moonfire, Hurricane, Insect Swarm, and Wrath spells by 8%.", "Increases the damage of your Starfire, Moonfire, Hurricane, Insect Swarm, and Wrath spells by 12%." } },
			[3] = { n = "Omen of Clarity", r = 1, d = { "Imbues the Druid with natural energy.  Each of the Druid's melee attacks or offensive spell casts has a chance of causing the caster to enter a Clearcasting state.  The Clearcasting state reduces the Mana, Rage or Energy cost of your next damage or healing spell or offensive ability by 100%." } },
			[4] = { n = "Nature's Reach", r = 2, d = { "Increases the range of your Wrath, Entangling Roots, Faerie Fire, Moonfire, Starfire, Insect Swarm, Hurricane, Remove Curse, Abolish Poison, and Cure Poison spells by 10%.", "Increases the range of your Wrath, Entangling Roots, Faerie Fire, Moonfire, Starfire, Insect Swarm, Hurricane, Remove Curse, Abolish Poison, and Cure Poison spells by 20%." } },
		},
		[4] = {
			[2] = { n = "Vengeance", r = 5, d = { "Increases the critical strike damage bonus of your Starfire, Moonfire, and Wrath spells by 20%.", "Increases the critical strike damage bonus of your Starfire, Moonfire, and Wrath spells by 40%.", "Increases the critical strike damage bonus of your Starfire, Moonfire, and Wrath spells by 60%.", "Increases the critical strike damage bonus of your Starfire, Moonfire, and Wrath spells by 80%.", "Increases the critical strike damage bonus of your Starfire, Moonfire, and Wrath spells by 100%." } },
			[3] = { n = "Moonglow", r = 3, d = { "Reduces the Mana cost of your Moonfire, Starfire, Wrath, Hurricane, Insect Swarm, Healing Touch, Regrowth and Rejuvenation spells by 3%.", "Reduces the Mana cost of your Moonfire, Starfire, Wrath, Hurricane, Insect Swarm, Healing Touch, Regrowth and Rejuvenation spells by 6%.", "Reduces the Mana cost of your Moonfire, Starfire, Wrath, Hurricane, Insect Swarm, Healing Touch, Regrowth and Rejuvenation spells by 9%." } },
		},
		[5] = {
			[1] = { n = "Owlkin Frenzy", r = 3, d = { "Damage taken while in Moonkin Form has a 10% chance to enrage you, granting a 30% chance to avoid interruption caused by damage while casting and regenerating 1% of your maximum mana per second for 10 sec. This effect can only trigger once every 30 seconds.", "Damage taken while in Moonkin Form has a 10% chance to enrage you, granting a 30% chance to avoid interruption caused by damage while casting and regenerating 1% of your maximum mana per second for 10 sec. This effect can only trigger once every 25 seconds.", "Damage taken while in Moonkin Form has a 10% chance to enrage you, granting a 30% chance to avoid interruption caused by damage while casting and regenerating 1% of your maximum mana per second for 10 sec. This effect can only trigger once every 20 seconds." } },
			[2] = { n = "Moonkin Form", r = 1, d = { "Transforms the Druid into Moonkin Form. While in this form the armor contribution from items is increased by 180%, the Mana cost of your Balance spells is reduced by 20%, and all party members within 30 yards have their spell critical chance increased by 3%. The Moonkin can only cast Balance spells, Innervate, and Remove Curse while shapeshifted. The act of shapeshifting frees the caster of Polymorph and Movement Impairing effects." } },
			[3] = { n = "Nature's Grace", r = 1, d = { "All spell criticals grace you with a blessing of nature, reducing the casting time of your next spell by 0.5 sec." } },
			[4] = { n = "Improved Starfire", r = 3, d = { "Reduces the cast time of Starfire by 0.17 sec and gives it a 5% chance to stun the target for 3 sec.", "Reduces the cast time of Starfire by 0.34 sec and gives it a 10% chance to stun the target for 3 sec.", "Reduces the cast time of Starfire by 0.5 sec and gives it a 15% chance to stun the target for 3 sec." } },
		},
		[6] = {
			[2] = { n = "Balance of All Things", r = 3, d = { "Damaging a target afflicted by Insect Swarm with Wrath refunds 10% of its mana cost.\n\nStarfire has a 3% increased chance to critically strike against targets affected by Moonfire.", "Damaging a target afflicted by Insect Swarm with Wrath refunds 20% of its mana cost.\n\nStarfire has a 6% increased chance to critically strike against targets affected by Moonfire.", "Damaging a target afflicted by Insect Swarm with Wrath refunds 30% of its mana cost.\n\nStarfire has a 9% increased chance to critically strike against targets affected by Moonfire." } },
			[3] = { n = "Gale Winds", r = 2, d = { "Reduces the mana cost of Hurricane by 10% and causes it to reduce the attack speed of affected enemies by 12%.", "Reduces the mana cost of Hurricane by 20% and causes it to reduce the attack speed of affected enemies by 25%." } },
		},
		[7] = {
			[2] = { n = "Eclipse", r = 1, d = { "Aligns natural and astral energies. Damage from Wrath has a 40% chance to grant Arcane Eclipse, increasing Arcane damage dealt. Damage from Starfire has a 60% chance to grant Nature Eclipse, increasing Nature damage dealt.\n\nThe damage bonus is 10% plus 60% of your spell critical strike chance. Each effect lasts 15 sec and has its own 30 sec cooldown. Only one Eclipse can be active at a time." } },
		},
	},
	[2] = {
		[1] = {
			[2] = { n = "Ferocity", r = 5, d = { "Reduces the cost of your Maul, Swipe, Savage Bite, Claw, and Rake abilities by 1 Rage or Energy.", "Reduces the cost of your Maul, Swipe, Savage Bite, Claw, and Rake abilities by 2 Rage or Energy.", "Reduces the cost of your Maul, Swipe, Savage Bite, Claw, and Rake abilities by 3 Rage or Energy.", "Reduces the cost of your Maul, Swipe, Savage Bite, Claw, and Rake abilities by 4 Rage or Energy.", "Reduces the cost of your Maul, Swipe, Savage Bite, Claw, and Rake abilities by 5 Rage or Energy." } },
			[3] = { n = "Feral Aggression", r = 5, d = { "Increases the Attack Power reduction of your Demoralizing Roar by 8% and the damage caused by your Ferocious Bite by 3%.", "Increases the Attack Power reduction of your Demoralizing Roar by 16% and the damage caused by your Ferocious Bite by 6%.", "Increases the Attack Power reduction of your Demoralizing Roar by 24% and the damage caused by your Ferocious Bite by 9%.", "Increases the Attack Power reduction of your Demoralizing Roar by 32% and the damage caused by your Ferocious Bite by 12%.", "Increases the Attack Power reduction of your Demoralizing Roar by 40% and the damage caused by your Ferocious Bite by 15%." } },
		},
		[2] = {
			[1] = { n = "Feral Instinct", r = 3, d = { "Increases threat caused in Bear and Dire Bear Form by 5% and reduces the chance enemies have to detect you while Prowling.", "Increases threat caused in Bear and Dire Bear Form by 10% and reduces the chance enemies have to detect you while Prowling.", "Increases threat caused in Bear and Dire Bear Form by 15% and reduces the chance enemies have to detect you while Prowling." } },
			[2] = { n = "Brutal Impact", r = 2, d = { "Increases the stun duration of your Bash and Pounce abilities by 0.5 sec.", "Increases the stun duration of your Bash and Pounce abilities by 1 sec." } },
			[3] = { n = "Thick Hide", r = 3, d = { "Increases your Armor contribution from items by 3%.", "Increases your Armor contribution from items by 6%.", "Increases your Armor contribution from items by 10%." } },
			[4] = { n = "Open Wounds", r = 3, d = { "Increases the damage of Rip by 5%. In addition, increases the damage of Claw by 10% for each of your active Bleed effects on the target.", "Increases the damage of Rip by 10%. In addition, increases the damage of Claw by 20% for each of your active Bleed effects on the target.", "Increases the damage of Rip by 15%. In addition, increases the damage of Claw by 30% for each of your active Bleed effects on the target." } },
		},
		[3] = {
			[1] = { n = "Feral Swiftness", r = 2, d = { "Increases your movement speed by 15% while outdoors in Cat Form and increases your chance to dodge while in Bear, Dire Bear and Cat Form by 2%.", "Increases your movement speed by 30% while outdoors in Cat Form and increases your chance to dodge while in Bear, Dire Bear and Cat Form by 4%." } },
			[2] = { n = "Feral Charge", r = 1, d = { "Causes you to charge an enemy, immobilizing and interrupting any spell being cast for 4 sec." } },
			[3] = { n = "Sharpened Claws", r = 3, d = { "Increases your critical strike chance while in Bear, Dire Bear or Cat Form by 2%.", "Increases your critical strike chance while in Bear, Dire Bear or Cat Form by 4%.", "Increases your critical strike chance while in Bear, Dire Bear or Cat Form by 6%." } },
			[4] = { n = "Primal Fury", r = 2, d = { "Gives you a 50% chance to gain an additional 5 Rage anytime you get a critical strike while in Bear and Dire Bear Form and your critical strikes from Cat Form abilities that add combo points have a chance to add an additional combo point.", "Gives you a 100% chance to gain an additional 5 Rage anytime you get a critical strike while in Bear and Dire Bear Form and your critical strikes from Cat Form abilities that add combo points have a chance to add an additional combo point." } },
		},
		[4] = {
			[2] = { n = "Predatory Strikes", r = 3, d = { "Increases your melee attack power in Cat, Bear, and Dire Bear Forms by 3%. In addition, increases the damage caused by your Claw, Rake, Maul, Swipe, and Savage Bite abilities by 7%.", "Increases your melee attack power in Cat, Bear, and Dire Bear Forms by 6%. In addition, increases the damage caused by your Claw, Rake, Maul, Swipe, and Savage Bite abilities by 14%.", "Increases your melee attack power in Cat, Bear, and Dire Bear Forms by 10%. In addition, increases the damage caused by your Claw, Rake, Maul, Swipe, and Savage Bite abilities by 20%." } },
			[3] = { n = "Blood Frenzy", r = 2, d = { "Increases the duration of Tiger's Fury by 6 sec, and causes Enrage to instantly generate 5 Rage. In addition, Tiger's Fury and Enrage increase your attack speed by 10% for 9 sec.", "Increases the duration of Tiger's Fury by 12 sec, and causes Enrage to instantly generate 10 Rage. In addition, Tiger's Fury and Enrage increase your attack speed by 20% for 18 sec." } },
			[4] = { n = "Improved Shred", r = 2, d = { "Increases the damage of Shred by 5% and reduces its Energy cost by 6.", "Increases the damage of Shred by 10% and reduces its Energy cost by 12." } },
		},
		[5] = {
			[1] = { n = "Ancient Brutality", r = 2, d = { "Dodging an attack while in Bear or Dire Bear Form imbues you with the spirit of the Ancients, generating 2 Rage per second for 5 sec. This effect can only occur once every 9 seconds.  While in Cat Form, periodic ticks of your Bleed effects restore 3 Energy.", "Dodging an attack while in Bear or Dire Bear Form imbues you with the spirit of the Ancients, generating 4 Rage per second for 5 sec. This effect can only occur once every 9 seconds.  While in Cat Form, periodic ticks of your Bleed effects restore 5 Energy." } },
			[3] = { n = "Berserk", r = 1, d = { "Removes all Fear effects and increases your energy regeneration rate by 100% while in Cat form, and increases your total health by 20% while in Bear form. After the effect ends, the health is lost. Effect lasts 20 seconds." } },
		},
		[6] = {
			[2] = { n = "Heart of the Wild", r = 5, d = { "Increases your Intellect by 4%.  In addition, while in Bear or Dire Bear Form your Stamina is increased by 4% and while in Cat Form your Strength is increased by 4%.", "Increases your Intellect by 8%.  In addition, while in Bear or Dire Bear Form your Stamina is increased by 8% and while in Cat Form your Strength is increased by 8%.", "Increases your Intellect by 12%.  In addition, while in Bear or Dire Bear Form your Stamina is increased by 12% and while in Cat Form your Strength is increased by 12%.", "Increases your Intellect by 16%.  In addition, while in Bear or Dire Bear Form your Stamina is increased by 16% and while in Cat Form your Strength is increased by 16%.", "Increases your Intellect by 20%.  In addition, while in Bear or Dire Bear Form your Stamina is increased by 20% and while in Cat Form your Strength is increased by 20%." } },
			[3] = { n = "Carnage", r = 2, d = { "Your Maul, Swipe, and Savage Bite abilities return 5% of their damage as healing to you. In addition, gives your Ferocious Bite a 10% chance per combo point spent to refresh your active Rake and Rip effects and to add an additional combo point.", "Your Maul, Swipe, and Savage Bite abilities return 10% of their damage as healing to you. In addition, gives your Ferocious Bite a 20% chance per combo point spent to refresh your active Rake and Rip effects and to add an additional combo point." } },
		},
		[7] = {
			[2] = { n = "Leader of the Pack", r = 1, d = { "While in Cat, Bear or Dire Bear Form, the Leader of the Pack increases ranged and melee critical chance of all party members within 45 yards by 3%." } },
		},
	},
	[3] = {
		[1] = {
			[2] = { n = "Improved Mark of the Wild", r = 5, d = { "Increases the effects of your Mark of the Wild and Gift of the Wild spells by 7%.", "Increases the effects of your Mark of the Wild and Gift of the Wild spells by 14%.", "Increases the effects of your Mark of the Wild and Gift of the Wild spells by 21%.", "Increases the effects of your Mark of the Wild and Gift of the Wild spells by 28%.", "Increases the effects of your Mark of the Wild and Gift of the Wild spells by 35%." } },
			[3] = { n = "Furor", r = 5, d = { "Gives you 20% chance to gain 10 Rage when you shapeshift into Bear and Dire Bear Form or 40 Energy when you shapeshift into Cat Form.", "Gives you 40% chance to gain 10 Rage when you shapeshift into Bear and Dire Bear Form or 40 Energy when you shapeshift into Cat Form.", "Gives you 60% chance to gain 10 Rage when you shapeshift into Bear and Dire Bear Form or 40 Energy when you shapeshift into Cat Form.", "Gives you 80% chance to gain 10 Rage when you shapeshift into Bear and Dire Bear Form or 40 Energy when you shapeshift into Cat Form.", "Gives you 100% chance to gain 10 Rage when you shapeshift into Bear and Dire Bear Form or 40 Energy when you shapeshift into Cat Form." } },
		},
		[2] = {
			[1] = { n = "Improved Healing Touch", r = 5, d = { "Reduces the cast time of your Healing Touch spell by 0.1 sec.", "Reduces the cast time of your Healing Touch spell by 0.2 sec.", "Reduces the cast time of your Healing Touch spell by 0.3 sec.", "Reduces the cast time of your Healing Touch spell by 0.4 sec.", "Reduces the cast time of your Healing Touch spell by 0.5 sec." } },
			[2] = { n = "Nature's Focus", r = 5, d = { "Gives you a 14% chance to avoid interruption caused by damage while casting the Healing Touch, Regrowth, and Tranquility spells.", "Gives you a 28% chance to avoid interruption caused by damage while casting the Healing Touch, Regrowth, and Tranquility spells.", "Gives you a 42% chance to avoid interruption caused by damage while casting the Healing Touch, Regrowth, and Tranquility spells.", "Gives you a 56% chance to avoid interruption caused by damage while casting the Healing Touch, Regrowth, and Tranquility spells.", "Gives you a 70% chance to avoid interruption caused by damage while casting the Healing Touch, Regrowth, and Tranquility spells." } },
			[3] = { n = "Subtlety", r = 5, d = { "Reduces the threat generated by your spells by 4%.", "Reduces the threat generated by your spells by 8%.", "Reduces the threat generated by your spells by 12%.", "Reduces the threat generated by your spells by 16%.", "Reduces the threat generated by your spells by 20%." } },
		},
		[3] = {
			[2] = { n = "Swiftmend", r = 1, d = { "Consumes a Rejuvenation or Regrowth effect on a friendly target to instantly heal them an amount equal to 12 sec. of Rejuvenation or 18 sec. of Regrowth." } },
			[3] = { n = "Genesis", r = 3, d = { "Increases the damage and healing of your periodic magical spells and effects by 5%.", "Increases the damage and healing of your periodic magical spells and effects by 10%.", "Increases the damage and healing of your periodic magical spells and effects by 15%." } },
			[4] = { n = "Reflection", r = 3, d = { "Allows 5% of your Mana regeneration to continue while casting.", "Allows 10% of your Mana regeneration to continue while casting.", "Allows 15% of your Mana regeneration to continue while casting." } },
		},
		[4] = {
			[2] = { n = "Gift of Nature", r = 5, d = { "Increases the effectiveness of all healing spells by 2%.", "Increases the effectiveness of all healing spells by 4%.", "Increases the effectiveness of all healing spells by 6%.", "Increases the effectiveness of all healing spells by 8%.", "Increases the effectiveness of all healing spells by 10%." } },
			[4] = { n = "Tranquil Spirit", r = 5, d = { "Reduces the mana cost of your Healing Touch, Regrowth and Tranquility spells by 2%.", "Reduces the mana cost of your Healing Touch, Regrowth and Tranquility spells by 4%.", "Reduces the mana cost of your Healing Touch, Regrowth and Tranquility spells by 6%.", "Reduces the mana cost of your Healing Touch, Regrowth and Tranquility spells by 8%.", "Reduces the mana cost of your Healing Touch, Regrowth and Tranquility spells by 10%." } },
		},
		[5] = {
			[1] = { n = "Aessina's Bloom", r = 2, d = { "Healing a target affected by Regrowth or Rejuvenation with your Healing Touch spells reduces the casting time of your next Healing Touch spell by 0.15 sec and refunds 5% of its mana cost within 20 sec.", "Healing a target affected by Regrowth or Rejuvenation with your Healing Touch spells reduces the casting time of your next Healing Touch spell by 0.30 sec and refunds 10% of its mana cost within 20 sec." } },
			[3] = { n = "Nature's Swiftness", r = 1, d = { "When activated, your next Nature spell becomes an instant cast spell." } },
			[4] = { n = "Preservation", r = 3, d = { "Increases the periodic healing of Regrowth by 10% if the friendly target is affected by Rejuvenation.", "Increases the periodic healing of Regrowth by 20% if the friendly target is affected by Rejuvenation.", "Increases the periodic healing of Regrowth by 30% if the friendly target is affected by Rejuvenation." } },
		},
		[6] = {
			[2] = { n = "Improved Regrowth", r = 5, d = { "Increases the critical effect chance of your Regrowth spell by 10%.", "Increases the critical effect chance of your Regrowth spell by 20%.", "Increases the critical effect chance of your Regrowth spell by 30%.", "Increases the critical effect chance of your Regrowth spell by 40%.", "Increases the critical effect chance of your Regrowth spell by 50%." } },
			[3] = { n = "Improved Tranquility", r = 2, d = { "Increases the healing done by your Tranquility spell by 20%.", "Increases the healing done by your Tranquility spell by 40%." } },
		},
		[7] = {
			[2] = { n = "Tree of Life Form", r = 1, d = { "Shapeshift into the Tree of Life.  While in this form armor contribution from items is inreased by 180%, the healing power of nearby party members is increased by an amount equal to 20% of your spirit, your movement speed is reduced by 20%, and you cannot cast damaging spells or Healing Touch, but the mana cost of heal over time spells is reduced by 20%.\n\nThe act of shapeshifting frees the caster of Polymorph and Movement Impairing effects." } },
		},
	},
}
