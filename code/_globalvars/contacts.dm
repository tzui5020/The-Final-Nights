// Important Contacts

GLOBAL_LIST_INIT(important_contacts, list())

// Contact Networks

GLOBAL_LIST_INIT(millenium_tower_network, list())
GLOBAL_LIST_INIT(lasombra_network, list())
GLOBAL_LIST_INIT(tremere_network, list())
GLOBAL_LIST_INIT(giovanni_network, list())
GLOBAL_LIST_INIT(tzmisce_network, list())
GLOBAL_LIST_INIT(anarch_network, list())
GLOBAL_LIST_INIT(warehouse_network, list())
GLOBAL_LIST_INIT(triads_network, list())
GLOBAL_LIST_INIT(vampire_leader_network, list())
GLOBAL_LIST_INIT(endron_network, list())


#define MILLENIUM_TOWER_NETWORK 1
#define LASOMBRA_NETWORK 2
#define TREMERE_NETWORK 3
#define GIOVANNI_NETWORK 4
#define TZMISCE_NETWORK 5
#define ANARCH_NETWORK 6
#define WAREHOUSE_NETWORK 7
#define TRIADS_NETWORK 8
#define VAMPIRE_LEADER_NETWORK 9
#define ENDRON_NETWORK 10


/proc/contact_network_from_define(network_id)
    switch(network_id)
        if(MILLENIUM_TOWER_NETWORK)
            return GLOB.millenium_tower_network
        if(LASOMBRA_NETWORK)
            return GLOB.lasombra_network
        if(TREMERE_NETWORK)
            return GLOB.tremere_network
        if(GIOVANNI_NETWORK)
            return GLOB.giovanni_network
        if(TZMISCE_NETWORK)
            return GLOB.tzmisce_network
        if(ANARCH_NETWORK)
            return GLOB.anarch_network
        if(WAREHOUSE_NETWORK)
            return GLOB.warehouse_network
        if(TRIADS_NETWORK)
            return GLOB.triads_network
        if(VAMPIRE_LEADER_NETWORK)
            return GLOB.vampire_leader_network
        if(ENDRON_NETWORK)
            return GLOB.endron_network
    CRASH("contact_network_from_define() called with invalid network_id: [isnull(network_id) ? "(null)" : network_id]")
