/datum/vampireclane/nagaraja
	name = CLAN_NAGARAJA
	desc = "The Nagaraja are a mysterious bloodline, created through a ritual rather than having any Antediluvian to call their own. They are feared and reviled for both their expertise in the arts of necromancy, and their hunger for flesh."
	curse = "Instead of consuming blood like most kindred, the Nagaraja are only able to subsist off of the flesh and viscera of their prey, earning the nickname of 'Flesh-Eaters' among their bretheren."
	clane_disciplines = list(
		/datum/discipline/auspex,
		/datum/discipline/dominate,
		/datum/discipline/necromancy
	)
	male_clothes = /obj/item/clothing/under/vampire/emo
	female_clothes = /obj/item/clothing/under/vampire/emo
	whitelisted = FALSE

/datum/vampireclane/nagaraja/on_gain(mob/living/carbon/human/H)
	. = ..()
	H.add_quirk(/datum/quirk/organovore)
