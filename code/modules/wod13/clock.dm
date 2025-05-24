//Generic starting inventory items.

/obj/item/cockclock
	name = "\improper wrist watch"
	desc = "A portable device to check time."
	icon = 'code/modules/wod13/clock.dmi'
	worn_icon = 'code/modules/wod13/worn.dmi'
	icon_state = "watch"
	worn_icon_state = "watch"
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	slot_flags = ITEM_SLOT_GLOVES | ITEM_SLOT_ID
	onflooricon = 'code/modules/wod13/onfloor.dmi'
	cost = 50

/obj/item/cockclock/examine(mob/user)
	. = ..()
	to_chat(user, "<b>[SScity_time.timeofnight]</b>")

/obj/item/passport
	name = "\improper passport"
	desc = "A book with someone's license, photo, and identifying information. Don't lose it!"
	icon = 'code/modules/wod13/items.dmi'
	worn_icon = 'code/modules/wod13/worn.dmi'
	icon_state = "passport1"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_ID
	onflooricon = 'code/modules/wod13/onfloor.dmi'
	var/closed = TRUE
	var/owner = ""
	var/fake = FALSE


/obj/item/passport/Initialize()
	. = ..()
	var/mob/living/carbon/human/user = null
	if(ishuman(loc)) // In pockets
		user = loc
	else if(ishuman(loc?.loc)) // In backpack
		user = loc
	if(!isnull(user))
		owner = user.real_name


/obj/item/passport/examine(mob/user)
	. = ..()
	if(!closed && owner)
		. += span_notice("It reads as belonging to [owner].")
		if(fake)
			. += span_notice("It looks like a crude counterfeit.")


/obj/item/passport/attack_self(mob/user)
	. = ..()
	if(closed)
		closed = FALSE
		icon_state = "passport0"
		to_chat(user, "<span class='notice'>You open [src].</span>")
	else
		closed = TRUE
		icon_state = "passport1"
		to_chat(user, "<span class='notice'>You close [src].</span>")
