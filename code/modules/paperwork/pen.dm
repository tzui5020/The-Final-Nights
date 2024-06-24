/*	Pens!
 *	Contains:
 *		Pens
 *		Sleepy Pens
 *		Parapens
 *		Edaggers
 */


/*
 * Pens
 */
/obj/item/pen
	desc = "It's a normal black ink pen."
	name = "pen"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	inhand_icon_state = "pen"
	worn_icon_state = "pen"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_EARS
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=10)
	grind_results = list(/datum/reagent/iron = 2, /datum/reagent/iodine = 1)
	var/colour = "black"	//what colour the ink is!
	var/degrees = 0
	var/font = PEN_FONT
	embedding = list()
	sharpness = SHARP_POINTY
	var/dart_insert_icon = 'icons/obj/weapons/guns/toy.dmi'
	var/dart_insert_casing_icon_state = "overlay_pen"
	var/dart_insert_projectile_icon_state = "overlay_pen_proj"
	/// If this pen can be clicked in order to retract it
	var/can_click = TRUE

/obj/item/pen/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/dart_insert, \
		dart_insert_icon, \
		dart_insert_casing_icon_state, \
		dart_insert_icon, \
		dart_insert_projectile_icon_state, \
		CALLBACK(src, PROC_REF(get_dart_var_modifiers))\
	)
	AddElement(/datum/element/tool_renaming)
	RegisterSignal(src, COMSIG_DART_INSERT_ADDED, PROC_REF(on_inserted_into_dart))
	RegisterSignal(src, COMSIG_DART_INSERT_REMOVED, PROC_REF(on_removed_from_dart))
	if (!can_click)
		return
	create_transform_component()
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/// Proc that child classes can override to have custom transforms, like edaggers or pendrivers
/obj/item/pen/proc/create_transform_component()
	AddComponent( \
		/datum/component/transforming, \
		sharpness_on = NONE, \
		inhand_icon_change = FALSE, \
	)

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Clicks the pen to make an annoying sound. Clickity clickery click!
 */
/obj/item/pen/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	if(user)
		balloon_alert(user, "clicked")
	playsound(src, 'sound/machines/click.ogg', 30, TRUE, -3)
	icon_state = initial(icon_state) + (active ? "_retracted" : "")
	update_appearance(UPDATE_ICON)

	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/pen/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is scribbling numbers all over [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit sudoku...</span>")
	return(BRUTELOSS)

/obj/item/pen/blue
	desc = "It's a normal blue ink pen."
	icon_state = "pen_blue"
	colour = "blue"

/obj/item/pen/red
	desc = "It's a normal red ink pen."
	icon_state = "pen_red"
	colour = "red"
	throw_speed = 4 // red ones go faster (in this case, fast enough to embed!)

/obj/item/pen/invisible
	desc = "It's an invisible pen marker."
	icon_state = "pen"
	colour = "white"

/obj/item/pen/fourcolor
	desc = "It's a fancy four-color ink pen, set to black."
	name = "four-color pen"
	icon_state = "pen_4color"
	colour = COLOR_BLACK
	can_click = FALSE

/obj/item/pen/fourcolor/attack_self(mob/living/carbon/user)
	switch(colour)
		if("black")
			colour = "red"
			throw_speed++
		if("red")
			colour = "green"
			throw_speed = initial(throw_speed)
		if("green")
			colour = "blue"
		else
			colour = COLOR_BLACK
	to_chat(user, span_notice("\The [src] will now write in [chosen_color]."))
	desc = "It's a fancy four-color ink pen, set to [chosen_color]."
	balloon_alert(user, "clicked")
	playsound(src, 'sound/machines/click.ogg', 30, TRUE, -3)

/obj/item/pen/fountain
	name = "fountain pen"
	desc = "It's a common fountain pen, with a faux wood body."
	icon_state = "pen-fountain"
	font = FOUNTAIN_PEN_FONT
	requires_gravity = FALSE // fancy spess pens
	dart_insert_casing_icon_state = "overlay_fountainpen"
	dart_insert_projectile_icon_state = "overlay_fountainpen_proj"
	can_click = FALSE

/obj/item/pen/charcoal
	name = "charcoal stylus"
	desc = "It's just a wooden stick with some compressed ash on the end. At least it can write."
	icon_state = "pen-charcoal"
	colour = "dimgray"
	font = CHARCOAL_FONT
	custom_materials = null
	grind_results = list(/datum/reagent/ash = 5, /datum/reagent/cellulose = 10)
	requires_gravity = FALSE // this is technically a pencil
	can_click = FALSE

/datum/crafting_recipe/charcoal_stylus
	name = "Charcoal Stylus"
	result = /obj/item/pen/charcoal
	reqs = list(/obj/item/stack/sheet/mineral/wood = 1, /datum/reagent/ash = 30)
	time = 30
	category = CAT_PRIMAL

/obj/item/pen/fountain/captain
	name = "captain's fountain pen"
	desc = "It's an expensive Oak fountain pen. The nib is quite sharp."
	icon_state = "pen-fountain-o"
	force = 5
	throwforce = 5
	throw_speed = 4
	colour = "crimson"
	custom_materials = list(/datum/material/gold = 750)
	sharpness = SHARP_EDGED
	resistance_flags = FIRE_PROOF
	unique_reskin = list("Oak" = "pen-fountain-o",
						"Gold" = "pen-fountain-g",
						"Rosewood" = "pen-fountain-r",
						"Black and Silver" = "pen-fountain-b",
						"Command Blue" = "pen-fountain-cb"
						)
	embedding = list("embed_chance" = 75)

/obj/item/pen/fountain/captain/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 200, 115) //the pen is mightier than the sword

/obj/item/pen/fountain/captain/reskin_obj(mob/M)
	..()
	if(current_skin)
		desc = "It's an expensive [current_skin] fountain pen. The nib is quite sharp."


/obj/item/pen/fountain/captain/proc/reskin_dart_insert(datum/component/dart_insert/insert_comp)
	if(!istype(insert_comp)) //You really shouldn't be sending this signal from anything other than a dart_insert component
		return
	insert_comp.casing_overlay_icon_state = overlay_reskin[current_skin]
	insert_comp.projectile_overlay_icon_state = "[overlay_reskin[current_skin]]_proj"

/obj/item/pen/item_ctrl_click(mob/living/carbon/user)
	if(loc != user)
		to_chat(user, span_warning("You must be holding the pen to continue!"))
		return CLICK_ACTION_BLOCKING
	var/deg = tgui_input_number(user, "What angle would you like to rotate the pen head to? (0-360)", "Rotate Pen Head", max_value = 360)
	if(isnull(deg) || QDELETED(user) || QDELETED(src) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH) || loc != user)
		return CLICK_ACTION_BLOCKING
	degrees = deg
	to_chat(user, span_notice("You rotate the top of the pen to [deg] degrees."))
	SEND_SIGNAL(src, COMSIG_PEN_ROTATED, deg, user)
	return CLICK_ACTION_SUCCESS

/obj/item/pen/attack(mob/living/M, mob/user, params)
	if(force) // If the pen has a force value, call the normal attack procs. Used for e-daggers and captain's pen mostly.
		return ..()
	if(!M.try_inject(user, injection_flags = INJECT_TRY_SHOW_ERROR_MESSAGE))
		return FALSE
	to_chat(user, span_warning("You stab [M] with the pen."))
	to_chat(M, span_danger("You feel a tiny prick!"))
	log_combat(user, M, "stabbed", src)
	return TRUE

/obj/item/pen/get_writing_implement_details()
	if (HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		return null
	return list(
		interaction_mode = MODE_WRITING,
		font = font,
		color = colour,
		use_bold = FALSE,
	)


/obj/item/pen/afterattack(obj/O, mob/living/user, proximity)
	. = ..()
	//Changing name/description of items. Only works if they have the UNIQUE_RENAME object flag set
	if(isobj(O) && proximity && (O.obj_flags & UNIQUE_RENAME))
		var/penchoice = input(user, "What would you like to edit?", "Rename, change description or reset both?") as null|anything in list("Rename","Change description","Reset")
		if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
			return
		if(penchoice == "Rename")
			var/input = stripped_input(user,"What do you want to name [O]?", ,"[O.name]", MAX_NAME_LEN)
			var/oldname = O.name
			if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
				return
			if(oldname == input || input == "")
				to_chat(user, "<span class='notice'>You changed [O] to... well... [O].</span>")
			else
				O.name = input
				var/datum/component/label/label = O.GetComponent(/datum/component/label)
				if(label)
					label.remove_label()
					label.apply_label()
				to_chat(user, "<span class='notice'>You have successfully renamed \the [oldname] to [O].</span>")
				O.renamedByPlayer = TRUE

		if(penchoice == "Change description")
			var/input = stripped_input(user,"Describe [O] here:", ,"[O.desc]", 140)
			var/olddesc = O.desc
			if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
				return
			if(olddesc == input || input == "")
				to_chat(user, "<span class='notice'>You decide against changing [O]'s description.</span>")
			else
				O.desc = input
				to_chat(user, "<span class='notice'>You have successfully changed [O]'s description.</span>")
				O.renamedByPlayer = TRUE

		if(penchoice == "Reset")
			if(QDELETED(O) || !user.canUseTopic(O, BE_CLOSE))
				return
			O.desc = initial(O.desc)
			O.name = initial(O.name)
			var/datum/component/label/label = O.GetComponent(/datum/component/label)
			if(label)
				label.remove_label()
				label.apply_label()
			to_chat(user, "<span class='notice'>You have successfully reset [O]'s name and description.</span>")
			O.renamedByPlayer = FALSE

/*
 * Sleepypens
 */

/obj/item/pen/sleepy/attack(mob/living/M, mob/user)
	if(!istype(M))
		return

	if(..())
		if(reagents.total_volume)
			if(M.reagents)

				reagents.trans_to(M, reagents.total_volume, transfered_by = user, methods = INJECT)


/obj/item/pen/sleepy/Initialize()
	. = ..()
	create_reagents(45, OPENCONTAINER)
	reagents.add_reagent(/datum/reagent/toxin/chloralhydrate, 20)
	reagents.add_reagent(/datum/reagent/toxin/mutetoxin, 15)
	reagents.add_reagent(/datum/reagent/toxin/staminatoxin, 10)

/*
 * (Alan) Edaggers
 */
/obj/item/pen/edagger
	attack_verb_continuous = list("slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts") //these won't show up if the pen is off
	attack_verb_simple = list("slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	sharpness = SHARP_POINTY
	armour_penetration = 20
	bare_wound_bonus = 10
	item_flags = NO_BLOOD_ON_ITEM
	light_system = OVERLAY_LIGHT
	light_range = 1.5
	light_power = 1.3
	light_color = "#FA8282"
	light_on = FALSE
	dart_insert_projectile_icon_state = "overlay_edagger"
	/// The real name of our item when extended.
	var/hidden_name = "energy dagger"
	/// The real desc of our item when extended.
	var/hidden_desc = "It's a normal black ink pe- Wait. That's a thing used to stab people!"
	/// The real icons used when extended.
	var/hidden_icon = "edagger"

/obj/item/pen/edagger/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
	speed = 6 SECONDS, \
	butcher_sound = 'sound/weapons/blade1.ogg', \
	)
	RegisterSignal(src, COMSIG_DETECTIVE_SCANNED, PROC_REF(on_scan))

/obj/item/pen/edagger/create_transform_component()
	AddComponent( \
		/datum/component/transforming, \
		force_on = 18, \
		throwforce_on = 35, \
		throw_speed_on = 4, \
		sharpness_on = SHARP_EDGED, \
		w_class_on = WEIGHT_CLASS_NORMAL, \
		inhand_icon_change = FALSE, \
	)

/obj/item/pen/edagger/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/butchering, 60, 100, 0, 'sound/weapons/blade1.ogg')
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/pen/edagger/get_sharpness()
	return on * sharpness

/obj/item/pen/edagger/suicide_act(mob/user)
	. = BRUTELOSS
	if(on)
		user.visible_message("<span class='suicide'>[user] forcefully rams the pen into their mouth!</span>")
	else
		user.visible_message("<span class='suicide'>[user] is holding a pen up to their mouth! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		attack_self(user)

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Handles swapping their icon files to edagger related icon files -
 * as they're supposed to look like a normal pen.
 */
/obj/item/pen/edagger/on_transform(obj/item/source, mob/user, active)
	if(active)
		name = hidden_name
		desc = hidden_desc
		icon_state = hidden_icon
		inhand_icon_state = hidden_icon
		lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
		righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	else
		icon_state = initial(icon_state) //looks like a normal pen when off.
		inhand_icon_state = initial(inhand_icon_state)
		lefthand_file = initial(lefthand_file)
		righthand_file = initial(righthand_file)

/obj/item/pen/survival
	name = "survival pen"
	desc = "The latest in portable survival technology, this pen was designed as a miniature diamond pickaxe. Watchers find them very desirable for their diamond exterior."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "digging_pen"
	inhand_icon_state = "pen"
	worn_icon_state = "pen"
	force = 3
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/iron=10, /datum/material/diamond=100, /datum/material/titanium = 10)
	grind_results = list(/datum/reagent/iron = 2, /datum/reagent/iodine = 1)
	tool_behaviour = TOOL_MINING //For the classic "digging out of prison with a spoon but you're in space so this analogy doesn't work" situation.
	toolspeed = 10 //You will never willingly choose to use one of these over a shovel.
	font = FOUNTAIN_PEN_FONT
	colour = COLOR_BLUE
	dart_insert_casing_icon_state = "overlay_survivalpen"
	dart_insert_projectile_icon_state = "overlay_survivalpen_proj"
	can_click = FALSE

/obj/item/pen/survival/on_inserted_into_dart(datum/source, obj/item/ammo_casing/dart, mob/user)
	. = ..()
	RegisterSignal(dart.loaded_projectile, COMSIG_PROJECTILE_SELF_ON_HIT, PROC_REF(on_dart_hit))

/obj/item/pen/survival/on_removed_from_dart(datum/source, obj/item/ammo_casing/dart, obj/projectile/proj, mob/user)
	. = ..()
	if(istype(proj))
		UnregisterSignal(proj, COMSIG_PROJECTILE_SELF_ON_HIT)

/obj/item/pen/survival/proc/on_dart_hit(obj/projectile/source, atom/movable/firer, atom/target)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		target_turf = get_turf(src)
	if(ismineralturf(target_turf))
		var/turf/closed/mineral/mineral_turf = target_turf
		mineral_turf.gets_drilled(firer, TRUE)

/obj/item/pen/destroyer
	name = "Fine Tipped Pen"
	desc = "A pen with an infinitly sharpened tip. Capable of striking the weakest point of a strucutre or robot and annihilating it instantly. Good at putting holes in people too."
	force = 5
	wound_bonus = 100
	demolition_mod = 9000

// screwdriver pen!

/obj/item/pen/screwdriver
	desc = "A pen with an extendable screwdriver tip. This one has a yellow cap."
	icon_state = "pendriver"
	toolspeed = 1.2  // gotta have some downside
	dart_insert_projectile_icon_state = "overlay_pendriver"

/obj/item/pen/screwdriver/get_all_tool_behaviours()
	return list(TOOL_SCREWDRIVER)

/obj/item/pen/screwdriver/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/pen/screwdriver/create_transform_component()
	AddComponent( \
		/datum/component/transforming, \
		throwforce_on = 5, \
		w_class_on = WEIGHT_CLASS_SMALL, \
		sharpness_on = TRUE, \
		inhand_icon_change = FALSE, \
	)

/obj/item/pen/screwdriver/on_transform(obj/item/source, mob/user, active)
	if(user)
		balloon_alert(user, active ? "extended" : "retracted")
	playsound(src, 'sound/weapons/batonextend.ogg', 50, TRUE)

	if(!active)
		tool_behaviour = initial(tool_behaviour)
		RemoveElement(/datum/element/eyestab)
	else
		tool_behaviour = TOOL_SCREWDRIVER
		AddElement(/datum/element/eyestab)

	update_appearance(UPDATE_ICON)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/pen/screwdriver/update_icon_state()
	. = ..()
	icon_state = "[initial(icon_state)][HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE) ? "_out" : null]"
	inhand_icon_state = initial(inhand_icon_state) //since transforming component switches the icon.

//The Security holopen
/obj/item/pen/red/security
	name = "security pen"
	desc = "This is a red ink pen exclusively provided to members of the Security Department. Its opposite end features a built-in holographic projector designed for issuing arrest prompts to individuals."
	icon_state = "pen_sec"
	COOLDOWN_DECLARE(holosign_cooldown)

/obj/item/pen/red/security/examine(mob/user)
	. = ..()
	. += span_notice("To initiate the surrender prompt, simply click on an individual within your proximity.")

//Code from the medical penlight
/obj/item/pen/red/security/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!COOLDOWN_FINISHED(src, holosign_cooldown))
		balloon_alert(user, "not ready!")
		return ITEM_INTERACT_BLOCKING

	var/turf/target_turf = get_turf(interacting_with)
	var/mob/living/living_target = locate(/mob/living) in target_turf

	if(!living_target || (living_target == user))
		return ITEM_INTERACT_BLOCKING

	living_target.apply_status_effect(/datum/status_effect/surrender_timed)
	to_chat(living_target, span_userdanger("[user] requests your immediate surrender! You are given 30 seconds to comply!"))
	new /obj/effect/temp_visual/security_holosign(target_turf, user) //produce a holographic glow
	COOLDOWN_START(src, holosign_cooldown, 30 SECONDS)
	return ITEM_INTERACT_SUCCESS

/obj/effect/temp_visual/security_holosign
	name = "security holosign"
	desc = "A small holographic glow that indicates you're under arrest."
	icon_state = "sec_holo"
	duration = 60

/obj/effect/temp_visual/security_holosign/Initialize(mapload, creator)
	. = ..()
	playsound(loc, 'sound/machines/chime.ogg', 50, FALSE) //make some noise!
	if(creator)
		visible_message(span_danger("[creator] created a security hologram!"))
