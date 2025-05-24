/mob/living/carbon/werewolf/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	. = ..()
	if(message)
//		if(istype(loc, /obj/effect/dummy/chameleon))
//			var/obj/effect/dummy/chameleon/C = loc
//			C.say("[message]")
//			return
		if(length(GLOB.auspex_list))
			for(var/mob/living/carbon/human/H in GLOB.auspex_list)
				if(H)
					to_chat(H, "<span class='scream_away'><b>[name]</b> says, \"[message]\"</span>")
//		var/ending = copytext_char(message, -1)
//		var/list/message_mods = list()
//		message = get_message_mods(message, message_mods)
//		if(message_mods[WHISPER_MODE] != MODE_WHISPER)
//			if(ending == "?")
//				playsound(get_turf(src), 'code/modules/wod13/sounds/wolf_ask.ogg', 75, TRUE)
//			else if(ending == "!")
//				playsound(get_turf(src), 'code/modules/wod13/sounds/wolf_yell.ogg', 100, TRUE)
//			else
//				playsound(get_turf(src), 'code/modules/wod13/sounds/wolf_speak.ogg', 75, TRUE)

/mob/living/carbon/werewolf
	name = "werewolf"
	icon = 'code/modules/wod13/werewolf.dmi'
	gender = MALE
	dna = null
	faction = list("Gaia")
	ventcrawler = VENTCRAWLER_NONE
	pass_flags = 0
//	sight = SEE_MOBS
	see_in_dark = 2
	verb_say = "woofs"
	rotate_on_lying = 0
	initial_language_holder = /datum/language_holder/werewolf_transformed

	movement_type = GROUND // [ChillRaccoon] - fucking flying werewolfes is a meme

	bloodpool = 20
	maxbloodpool = 20

	var/move_delay_add = 0 // movement delay to add

	status_flags = CANUNCONSCIOUS|CANPUSH

	heat_protection = 0.5 // minor heat insulation

	var/leaping = FALSE
	gib_type = /obj/effect/decal/cleanable/blood/gibs
	unique_name = FALSE
	var/environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	melee_damage_lower = 20
	melee_damage_upper = 20
	butcher_results = list(/obj/item/food/meat/slab = 5)
	layer = LARGE_MOB_LAYER
	var/obj_damage = 30
	var/wound_bonus = 20
	var/bare_wound_bonus = 25
	var/sharpness = 50
	var/armour_penetration = 100
	var/melee_damage_type = BRUTE
	var/list/damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
	var/attack_verb_continuous = "attacks"
	var/attack_verb_simple = "attack"
	var/friendly_verb_continuous = "nuzzles"
	var/friendly_verb_simple = "nuzzle"
	var/attack_sound = 'code/modules/wod13/sounds/werewolf_bite.ogg'

	var/sprite_color = "black"
	var/sprite_scar = 0
	var/sprite_hair = 0
	var/sprite_hair_color = "#000000"
	var/sprite_eye_color = "#FFFFFF"
	var/sprite_apparel = 0

	var/step_variable = 0

	var/wyrm_tainted = 0
	var/werewolf_armor = 0

	var/assigned_quirks = FALSE

/mob/living/carbon/werewolf/corax // the Corax variety of werewolves, also refers to the Crinos form in a roundabout way, not exactly clean.
	name = "Corax"
	icon = 'code/modules/wod13/corax_crinos.dmi'
	verb_say = "caws"
	verb_exclaim = "squawks"
	verb_yell = "shrieks"



/mob/living/carbon/werewolf/update_resting()
	if(resting)
		ADD_TRAIT(src, TRAIT_IMMOBILIZED, RESTING_TRAIT)
	else
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, RESTING_TRAIT)
	return ..()

/mob/living/carbon/werewolf/crinos/Move(NewLoc, direct)
	if(isturf(loc))
		step_variable = step_variable+1
		if(step_variable == 2)
			step_variable = 0
			playsound(get_turf(src), 'code/modules/wod13/sounds/werewolf_step.ogg', 50, FALSE)
	..()

/mob/living/carbon/proc/epic_fall(apply_stun_self = TRUE, apply_stun_others = TRUE) //This proc is only called for Potence jumps. I have no idea why its stored here.
	playsound(get_turf(src), 'code/modules/wod13/sounds/werewolf_fall.ogg', 100, FALSE)
	new /obj/effect/temp_visual/dir_setting/crack_effect(get_turf(src))
	new /obj/effect/temp_visual/dir_setting/fall_effect(get_turf(src))
	for(var/mob/living/carbon/C in range(3, src))
		if(apply_stun_others)
			C.Knockdown(20)
		shake_camera(C, (6-get_dist(C, src))+1, (6-get_dist(C, src)))
	if(apply_stun_self)
		Immobilize(20)
	shake_camera(src, 5, 4)

/mob/living/carbon/werewolf/Initialize()
	var/datum/action/gift/rage_heal/GH = new()
	GH.Grant(src)
	var/datum/action/gift/howling/howl = new()
	howl.Grant(src)

	add_verb(src, /mob/living/proc/mob_sleep)
	add_verb(src, /mob/living/proc/toggle_resting)

	create_bodyparts() //initialize bodyparts

	create_internal_organs()

	ADD_TRAIT(src, TRAIT_NEVER_WOUNDED, ROUNDSTART_TRAIT)

	. = ..()

/mob/living/carbon/werewolf/create_internal_organs()
	internal_organs += new /obj/item/organ/brain
	internal_organs += new /obj/item/organ/tongue
	internal_organs += new /obj/item/organ/eyes/night_vision
	internal_organs += new /obj/item/organ/liver
	internal_organs += new /obj/item/organ/stomach
	internal_organs += new /obj/item/organ/heart
	internal_organs += new /obj/item/organ/lungs
	internal_organs += new /obj/item/organ/ears
	..()

/mob/living/carbon/werewolf/assess_threat(judgement_criteria, lasercolor = "", datum/callback/weaponcheck=null) // beepsky won't hunt aliums
	return -10

/mob/living/carbon/werewolf/reagent_check(datum/reagent/R) //can metabolize all reagents
	return 0

/mob/living/carbon/werewolf/get_status_tab_items()
	. = ..()
	. += "Intent: [a_intent]"

/mob/living/carbon/werewolf/getTrail()
	return pick (list("trails_1", "trails2"))

/mob/living/carbon/werewolf/canBeHandcuffed()
	return FALSE

/mob/living/carbon/werewolf/can_hold_items(obj/item/I)
	return (I && (I.item_flags & WEREWOLF_HOLDABLE || ISADVANCEDTOOLUSER(src)) && ..())

/mob/living/carbon/werewolf/on_lying_down(new_lying_angle)
	. = ..()
	update_icons()

/mob/living/carbon/werewolf/on_standing_up()
	. = ..()
	update_icons()

/mob/living/carbon/werewolf/crinos
	name = "werewolf"
	icon_state = "black"
	mob_size = MOB_SIZE_HUGE
	butcher_results = list(/obj/item/food/meat/slab = 5)
	possible_a_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB, INTENT_HARM)
	limb_destroyer = 1
	hud_type = /datum/hud/werewolf
	melee_damage_lower = 65
	melee_damage_upper = 65
	health = 250
	maxHealth = 250
//	speed = -1  doesn't work on carbons
	var/obj/item/r_store = null
	var/obj/item/l_store = null
	var/pounce_cooldown = 0
	var/pounce_cooldown_time = 30
	pixel_w = -8
//	deathsound = 'sound/voice/hiss6.ogg'
	bodyparts = list(
		/obj/item/bodypart/chest/crinos,
		/obj/item/bodypart/head/crinos,
		/obj/item/bodypart/l_arm/crinos,
		/obj/item/bodypart/r_arm/crinos,
		/obj/item/bodypart/r_leg/crinos,
		/obj/item/bodypart/l_leg/crinos,
		)

	werewolf_armor = 30

/mob/living/carbon/werewolf/corax/corax_crinos // The specific stats for the Corax variation of Crinos
	name = "corax"
	icon_state = "black"
	mob_size = MOB_SIZE_HUGE
	butcher_results = list(/obj/item/food/meat/slab = 5)
	possible_a_intents = list(INTENT_HELP, INTENT_DISARM, INTENT_GRAB, INTENT_HARM)
	limb_destroyer = 1

	hud_type = /datum/hud/werewolf
	melee_damage_lower = 45 // more reliable damage because I believe that's also a change staged for normal werewolves, also screw RNG
	melee_damage_upper = 50 // less damage for were-ravens
	health = 200 // a lot less HP
	maxHealth = 200
//	speed = -1  doesn't work on carbons
	var/obj/item/r_store = null
	var/obj/item/l_store = null
	var/pounce_cooldown = 0
	var/pounce_cooldown_time = 30
	pixel_w = -8
//	deathsound = 'sound/voice/hiss6.ogg'
	bodyparts = list(
		/obj/item/bodypart/chest/crinos,
		/obj/item/bodypart/head/crinos,
		/obj/item/bodypart/l_arm/crinos,
		/obj/item/bodypart/r_arm/crinos,
		/obj/item/bodypart/r_leg/crinos,
		/obj/item/bodypart/l_leg/crinos,
		)



/datum/movespeed_modifier/crinosform
	multiplicative_slowdown = -0.2

/datum/movespeed_modifier/silver_slowdown
	multiplicative_slowdown = 0.3

/mob/living/carbon/werewolf/crinos/Initialize()
	. = ..()
	var/datum/action/change_apparel/A = new()
	A.Grant(src)

//	AddComponent(/datum/component/footstep, FOOTSTEP_MOB_CLAW, 0.5, -11)

/mob/living/carbon/werewolf/lupus/Initialize()
	. = ..()
	AddComponent(/datum/component/footstep, FOOTSTEP_MOB_CLAW, 0.5, -11)
	if(!iscorvid(src))
		var/datum/action/gift/hispo/hispo = new()
		hispo.Grant(src)



/mob/living/carbon/werewolf/crinos/show_inv(mob/user)
	user.set_machine(src)
	var/list/dat = list()
	dat += "<table>"
	for(var/i in 1 to held_items.len)
		var/obj/item/I = get_item_for_held_index(i)
		dat += "<tr><td><B>[get_held_index_name(i)]:</B></td><td><A href='byond://?src=[REF(src)];item=[ITEM_SLOT_HANDS];hand_index=[i]'>[(I && !(I.item_flags & ABSTRACT)) ? I : "<font color=grey>Empty</font>"]</a></td></tr>"
	dat += "</td></tr><tr><td>&nbsp;</td></tr>"
	dat += "<tr><td><A href='byond://?src=[REF(src)];pouches=1'>Empty Pouches</A></td></tr>"

	dat += {"</table>
	<A href='byond://?src=[REF(user)];mach_close=mob[REF(src)]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob[REF(src)]", "[src]", 440, 510)
	popup.set_content(dat.Join())
	popup.open()


/mob/living/carbon/werewolf/crinos/can_hold_items(obj/item/I)
	return TRUE



/mob/living/carbon/werewolf/crinos/Topic(href, href_list)
	//strip panel
	if(href_list["pouches"] && usr.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		visible_message("<span class='danger'>[usr] tries to empty [src]'s pouches.</span>", \
						"<span class='userdanger'>[usr] tries to empty your pouches.</span>")
		if(do_mob(usr, src, POCKET_STRIP_DELAY * 0.5))
			dropItemToGround(r_store)
			dropItemToGround(l_store)

	..()

/mob/living/carbon/werewolf/crinos/resist_grab(moving_resist)
	if(pulledby.grab_state)
		visible_message("<span class='danger'>[src] breaks free of [pulledby]'s grip!</span>", \
						"<span class='danger'>You break free of [pulledby]'s grip!</span>")
	pulledby.stop_pulling()
	. = 0

/mob/living/carbon/werewolf/crinos/get_permeability_protection(list/target_zones)
	return 0.8

/mob/living/carbon/werewolf/corax/corax_crinos/show_inv(mob/user)
	user.set_machine(src)
	var/list/dat = list()
	dat += "<table>"
	for(var/i in 1 to held_items.len)
		var/obj/item/I = get_item_for_held_index(i)
		dat += "<tr><td><B>[get_held_index_name(i)]:</B></td><td><A href='byond://?src=[REF(src)];item=[ITEM_SLOT_HANDS];hand_index=[i]'>[(I && !(I.item_flags & ABSTRACT)) ? I : "<font color=grey>Empty</font>"]</a></td></tr>"
	dat += "</td></tr><tr><td>&nbsp;</td></tr>"
	dat += "<tr><td><A href='byond://?src=[REF(src)];pouches=1'>Empty Pouches</A></td></tr>"

	dat += {"</table>
	<A href='byond://?src=[REF(user)];mach_close=mob[REF(src)]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob[REF(src)]", "[src]", 440, 510)
	popup.set_content(dat.Join())
	popup.open()


/mob/living/carbon/werewolf/corax/corax_crinos/can_hold_items(obj/item/I)
	return TRUE

/mob/living/carbon/werewolf/corax/corax_crinos/Topic(href, href_list)
	//strip panel
	if(href_list["pouches"] && usr.canUseTopic(src, BE_CLOSE, NO_DEXTERITY))
		visible_message("<span class='danger'>[usr] tries to empty [src]'s pouches.</span>", \
						"<span class='userdanger'>[usr] tries to empty your pouches.</span>")
		if(do_mob(usr, src, POCKET_STRIP_DELAY * 0.5))
			dropItemToGround(r_store)
			dropItemToGround(l_store)

	..()

/mob/living/carbon/werewolf/corax/corax_crinos/resist_grab(moving_resist)
	if(pulledby.grab_state)
		visible_message("<span class='danger'>[src] breaks free of [pulledby]'s grip!</span>", \
						"<span class='danger'>You break free of [pulledby]'s grip!</span>")
	pulledby.stop_pulling()
	. = 0

/mob/living/carbon/werewolf/corax/corax_crinos/get_permeability_protection(list/target_zones)
	return 0.8

/mob/living/carbon/werewolf/corax/corax_crinos/Move(NewLoc, direct)
	if(isturf(loc))
		step_variable = step_variable+1
		if(step_variable == 2)
			step_variable = 0
			playsound(get_turf(src), 'code/modules/wod13/sounds/werewolf_step.ogg', 50, FALSE) // feel free to change the noise to something more avian later.
	..()
