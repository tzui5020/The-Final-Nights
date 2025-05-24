/datum/element/climbable
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH_ON_HOST_DESTROY
	argument_hash_start_idx = 2
	///Time it takes to climb onto the object
	var/climb_time = (2 SECONDS)
	///Stun duration for when you get onto the object
	var/climb_stun = (2 SECONDS)
	///Assoc list of object being climbed on - climbers.  This allows us to check who needs to be shoved off a climbable object when its clicked on.
	var/list/current_climbers

/datum/element/climbable/Attach(datum/target, climb_time, climb_stun)
	. = ..()

	if(!isatom(target) || isarea(target))
		return ELEMENT_INCOMPATIBLE
	if(climb_time)
		src.climb_time = climb_time
	if(climb_stun)
		src.climb_stun = climb_stun

	RegisterSignal(target, COMSIG_ATOM_ATTACK_HAND, PROC_REF(attack_hand))
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(target, COMSIG_MOUSEDROPPED_ONTO, PROC_REF(mousedrop_receive))
	RegisterSignal(target, COMSIG_ATOM_BUMPED, PROC_REF(try_speedrun))

/datum/element/climbable/Detach(datum/target, force)
	UnregisterSignal(target, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_PARENT_EXAMINE, COMSIG_MOUSEDROPPED_ONTO, COMSIG_ATOM_BUMPED))
	return ..()

/datum/element/climbable/proc/on_examine(atom/source, mob/user, list/examine_texts)
	SIGNAL_HANDLER

	if(can_climb(source, user))
		examine_texts += "<span class='notice'>[source] looks climbable</span>"

/datum/element/climbable/proc/can_climb(atom/source, mob/user)
	if(get_turf(user) == get_turf(source))
		to_chat(user, "<span class='warning'>You are already on \the [source]!</span>")
		return FALSE
	return TRUE

/datum/element/climbable/proc/attack_hand(atom/climbed_thing, mob/user)
	SIGNAL_HANDLER
	var/datum/weakref/climbed_thing_ref = WEAKREF(climbed_thing)
	var/list/climbers = LAZYACCESS(current_climbers, climbed_thing_ref)
	for(var/datum/weakref/user_ref as anything in climbers)
		var/mob/living/structure_climber = user_ref.resolve()
		if(isnull(structure_climber))
			climbers -= user_ref
			continue
		if(structure_climber == user)
			return
		user.changeNext_move(CLICK_CD_MELEE)
		user.do_attack_animation(climbed_thing)
		structure_climber.Paralyze(40)
		structure_climber.visible_message("<span class='warning'>[structure_climber] is knocked off [climbed_thing].</span>", "<span class='warning'>You're knocked off [climbed_thing]!</span>", "<span class='warning'>You see [structure_climber] get knocked off [climbed_thing].</span>")


/datum/element/climbable/proc/climb_structure(atom/climbed_thing, mob/living/user)
	if(!can_climb(climbed_thing, user))
		return
	climbed_thing.add_fingerprint(user)
	user.visible_message("<span class='warning'>[user] starts climbing onto [climbed_thing].</span>", \
								"<span class='notice'>You start climbing onto [climbed_thing]...</span>")
	var/adjusted_climb_time = climb_time
	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)) //climbing takes twice as long without help from the hands.
		adjusted_climb_time *= 2
	if(isalien(user))
		adjusted_climb_time *= 0.25 //aliens are terrifyingly fast
	if(HAS_TRAIT(user, TRAIT_FREERUNNING)) //do you have any idea how fast I am???
		adjusted_climb_time *= 0.8
	var/datum/weakref/climbed_thing_ref = WEAKREF(climbed_thing)
	var/datum/weakref/user_ref = WEAKREF(user)
	LAZYADDASSOCLIST(current_climbers, climbed_thing_ref, user_ref)
	if(!do_after(user, adjusted_climb_time, climbed_thing) || QDELETED(climbed_thing) || QDELETED(user) || HAS_TRAIT(user, TRAIT_LEANING))
		LAZYREMOVEASSOC(current_climbers, climbed_thing_ref, user_ref)
		return
	LAZYREMOVEASSOC(current_climbers, climbed_thing_ref, user_ref)
	if(!do_climb(climbed_thing, user))
		to_chat(user, span_warning("You fail to climb onto [climbed_thing]."))
		return
	user.visible_message(
		span_warning("[user] climbs onto [climbed_thing]."),
		span_notice("You climb onto [climbed_thing]."))
	log_combat(user, climbed_thing, "climbed onto")
	if(climb_stun)
		user.Stun(climb_stun)


/datum/element/climbable/proc/do_climb(atom/climbed_thing, mob/living/user)
	climbed_thing.density = FALSE
	//Switched from step() to Move() because it allows for diagonal movement
	//Switched from loc to get_turf() because it is possible to climb through low walls, whose loc variable is the area they're in
	user.Move(get_turf(climbed_thing))
	climbed_thing.density = TRUE
	if(get_turf(user) == get_turf(climbed_thing))
		return TRUE
	return FALSE

///Handles climbing onto the atom when you click-drag
/datum/element/climbable/proc/mousedrop_receive(atom/climbed_thing, atom/movable/dropped_atom, mob/user)
	SIGNAL_HANDLER
	if(user == dropped_atom && isliving(dropped_atom))
		var/mob/living/living_target = dropped_atom
		if(isanimal(living_target))
			var/mob/living/simple_animal/animal = dropped_atom
			if (!animal.dextrous)
				return
		if(living_target.mobility_flags & MOBILITY_MOVE)
			INVOKE_ASYNC(src, PROC_REF(climb_structure), climbed_thing, living_target)
			return

///Tries to climb onto the target if the forced movement of the mob allows it
/datum/element/climbable/proc/try_speedrun(datum/source, mob/bumpee)
	SIGNAL_HANDLER
	if(!istype(bumpee))
		return
	if(bumpee.force_moving?.allow_climbing)
		do_climb(source, bumpee)
