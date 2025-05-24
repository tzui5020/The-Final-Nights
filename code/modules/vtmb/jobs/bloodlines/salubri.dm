/datum/job/vamp/salubri
	title = "Veterinarian"
	faction = "Vampire"
	total_positions = 12
	spawn_positions = 12
	supervisors = "the Traditions"
	selection_color = "#df7058"
	access = list()			//See /datum/job/assistant/get_access()
	minimal_access = list()	//See /datum/job/assistant/get_access()
	outfit = /datum/outfit/job/salubri
	antag_rep = 7
	paycheck = PAYCHECK_ASSISTANT // Get a job. Job reassignment changes your paycheck now. Get over it.

	access = list(ACCESS_MAINT_TUNNELS)
	liver_traits = list(TRAIT_GREYTIDE_METABOLISM)

	paycheck_department = ACCOUNT_CIV
	display_order = JOB_DISPLAY_ORDER_SALUBRI

	allowed_species = list("Vampire", "Ghoul", "Human")
	species_slots = list("Vampire" = 6)

	v_duty = "One of the few Healer Salubri left within the city, maybe even in the world! You operate the Vet for any diseased or sick animals. You may have been an escaped member of The Seven or not. Regardless, you must hide and lay low."
	duty = "You work in the local privately owned Veterinary Clinic, in the old ghetto. You might notice some oddities with the other workers, but they help people and are generally nice, right? Either way, you don't care enough to out them."
	minimal_masquerade = 0
	allowed_bloodlines = list("Salubri")

/datum/outfit/job/salubri
	name = "salubri"
	jobtype = /datum/job/vamp/salubri
	l_pocket = /obj/item/vamp/phone
	id = /obj/item/cockclock
	backpack_contents = list(
		/obj/item/passport=1,
		/obj/item/flashlight=1,
		/obj/item/vamp/creditcard=1,
	)

/datum/outfit/job/salubri/pre_equip(mob/living/carbon/human/H)
	..()
	if(H.clane)
		if(H.gender == MALE)
			shoes = /obj/item/clothing/shoes/vampire
			if(H.clane.male_clothes)
				uniform = H.clane.male_clothes
		else
			shoes = /obj/item/clothing/shoes/vampire/heels
			if(H.clane.female_clothes)
				uniform = H.clane.female_clothes
	else
		uniform = /obj/item/clothing/under/vampire/emo
		if(H.gender == MALE)
			shoes = /obj/item/clothing/shoes/vampire
		else
			shoes = /obj/item/clothing/shoes/vampire/heels

/obj/effect/landmark/start/salubri
	name = "Veterinarian"
	icon_state = "Assistant"
