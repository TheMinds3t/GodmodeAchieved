local reg = {}

reg.items = {
    morphine = Isaac.GetItemIdByName("Morphine"),
    wings_of_betrayal = Isaac.GetItemIdByName("Wings of Betrayal"),
    tramp_of_babylon = Isaac.GetItemIdByName("Tramp of Babylon"),
    dads_balloon = Isaac.GetItemIdByName("Dad's Balloon"),
    divine_approval = Isaac.GetItemIdByName("Divine Approval"),
    adramolechs_blessing = Isaac.GetItemIdByName("Adramolech's Blessing"),
    fuzzy_dice = Isaac.GetItemIdByName("Fuzzy Dice"),
    pair_of_cans = Isaac.GetItemIdByName("Pair of Cans"),
    heart_arrest = Isaac.GetItemIdByName("Heart Arrest"),
    burnt_diary = Isaac.GetItemIdByName("Burnt Diary"),
    blood_pudding = Isaac.GetItemIdByName("Blood Pudding"),
    sugar = Isaac.GetItemIdByName("Sugar!"),
    angry_apple_juice = Isaac.GetItemIdByName("Angry Apple Juice"),
    larval_therapy = Isaac.GetItemIdByName("Larval Therapy"),
    marshall_scarf = Isaac.GetItemIdByName("Marshall Scarf"),
    taenia = Isaac.GetItemIdByName("Taenia"),
    anguish_jar = Isaac.GetItemIdByName("Anguish Jar"),
    holy_chalice = Isaac.GetItemIdByName("Holy Chalice"),
    abrahams_map = Isaac.GetItemIdByName("Abraham's Map"),
    orb_of_radiance = Isaac.GetItemIdByName("Orb of Radiance"),
    maxs_head = Isaac.GetItemIdByName("Blaze's Head"),
    baptismal_cross = Isaac.GetItemIdByName("Baptismal Cross"),
    uncommon_cough = Isaac.GetItemIdByName("The Uncommon Cough"),
    the_ladle = Isaac.GetItemIdByName("The Ladle"),
    nosebleed = Isaac.GetItemIdByName("Nosebleed"),
    childs_trophy = Isaac.GetItemIdByName("Child's Trophy"),
    the_carrot = Isaac.GetItemIdByName("The Carrot"),
    crown_of_gold = Isaac.GetItemIdByName("Crown of Gold"),
    gold_plated_battery = Isaac.GetItemIdByName("Gold Plated Battery"),
    four_leaf_clover = Isaac.GetItemIdByName("Four Leaf Clover"),
    late_delivery = Isaac.GetItemIdByName("Late Delivery"),
    black_mushroom = Isaac.GetItemIdByName("Black Mushroom"),
    sharing_is_caring = Isaac.GetItemIdByName("Sharing is Caring"),
    cloth_on_a_string = Isaac.GetItemIdByName("Cloth on a String"),
    cloth_of_gold = Isaac.GetItemIdByName("Cloth of Gold"),
    papal_cross_unholy = Isaac.GetItemIdByName("Papal Cross"),
    papal_cross_holy = Isaac.GetItemIdByName(" Papal Cross "),
    forbidden_knowledge = Isaac.GetItemIdByName("Forbidden Knowledge"),
    arcade_ticket = Isaac.GetItemIdByName("Arcade Ticket"),
    crossbones = Isaac.GetItemIdByName("Crossbones"),
    opia = Isaac.GetItemIdByName("Opia"),
    gangrene = Isaac.GetItemIdByName("Gangrene"),
    soul_food = Isaac.GetItemIdByName("Soul Food"),
    devils_food = Isaac.GetItemIdByName("Devil's Food"),
    angel_food = Isaac.GetItemIdByName("Angel Food"),
    book_of_saints = Isaac.GetItemIdByName("Book of Saints"),
    jack_of_all_trades = Isaac.GetItemIdByName("Jack-of-all-Trades"),
    tecpatl = Isaac.GetItemIdByName("Tecpatl"),
    impending_doom = Isaac.GetItemIdByName("Impending Doom"),
    ghanta = Isaac.GetItemIdByName("Ghanta"),
    vajra = Isaac.GetItemIdByName("Vajra"),
    quran = Isaac.GetItemIdByName("Qur'an"),
    prayer_mat = Isaac.GetItemIdByName("Prayer Mat"),
    diya = Isaac.GetItemIdByName("Diya"),
    nirvana = Isaac.GetItemIdByName("Nirvana"),
    brass_cross = Isaac.GetItemIdByName("Brass Cross"),
    celestial_tail = Isaac.GetItemIdByName("Celestial Tail"),
    celestial_paw = Isaac.GetItemIdByName("Celestial Paw"),
    celestial_collar = Isaac.GetItemIdByName("Celestial Collar"),
    soft_serve = Isaac.GetItemIdByName("Soft Serve"),
    portable_confessional = Isaac.GetItemIdByName("Portable Confessional"),
    a_second_thought = Isaac.GetItemIdByName("A Second Thought"),
    war_banner = Isaac.GetItemIdByName("War Banner"),
    seraphim_warhorn = Isaac.GetItemIdByName("Seraphim Warhorn"),
    edible_soul = Isaac.GetItemIdByName("Edible Soul"),
    fallen_guardian = Isaac.GetItemIdByName("Fallen Guardian"),
    bubble_wand = Isaac.GetItemIdByName("Bubble Wand"),
    feather_duster = Isaac.GetItemIdByName("Feather Duster"),
    fruit_salad = Isaac.GetItemIdByName("Fruit Salad"),
    dragon_fruit = Isaac.GetItemIdByName("Dragon Fruit"),
    fruit_flies = Isaac.GetItemIdByName("Fruit Flies"),
    fatal_attraction = Isaac.GetItemIdByName("Fatal Attraction"),
    divine_wrath = Isaac.GetItemIdByName("Divine Wrath"),
    hysteria = Isaac.GetItemIdByName("Hysteria"),
    greedy_glance = Isaac.GetItemIdByName("Greedy Glance"),
    odd_dice = Isaac.GetItemIdByName("Odd Dice"),
    cash_dice = Isaac.GetItemIdByName("Cash Dice"),
    crimson_solution = Isaac.GetItemIdByName("Crimson Solution"),
    foreign_treatment = Isaac.GetItemIdByName("Foreign Treatment"),
    hot_potato = Isaac.GetItemIdByName("Hot Potato"),
    birthday_slice = Isaac.GetItemIdByName("Birthday Slice"),
    party_hat = Isaac.GetItemIdByName("Party Hat"),
    fractal_key = Isaac.GetItemIdByName("Fractal Key"),
    fractal_key_inverse = Isaac.GetItemIdByName("Inverse Key"),

    reclusive_tendencies = Isaac.GetItemIdByName("Reclusive Tendencies"),
    golden_stopwatch = Isaac.GetItemIdByName("Golden Stopwatch"),
    moms_wish = Isaac.GetItemIdByName("Mom's Wish"),
    adramolechs_fury = Isaac.GetItemIdByName("Adramolech's Fury"),
    deli_delusion = Isaac.GetItemIdByName("Delusion"),
    deli_oblivion = Isaac.GetItemIdByName("Oblivion"),
    vengeful_dagger = Isaac.GetItemIdByName("Vengeful Dagger"),
    
    questrock_1 = Isaac.GetItemIdByName("Rock Fragment"),
    questrock_2 = Isaac.GetItemIdByName("Holy Stone"),
    questrock_3 = Isaac.GetItemIdByName("Tablet Fragment"),
    questrock_4 = Isaac.GetItemIdByName("Final Slate"),
    blood_key = Isaac.GetItemIdByName("Blood Key"),
    vessel_of_purity_1 = Isaac.GetItemIdByName("Vessel of Purity"),
    vessel_of_purity_2 = Isaac.GetItemIdByName("Cracked Vessel of Purity"),
    vessel_of_purity_3 = Isaac.GetItemIdByName("Bloodied Vessel of Purity"),
}

reg.trinkets = {
    gesture_of_the_deep = Isaac.GetTrinketIdByName("Gesture of the Deep"),
    snapped_cross = Isaac.GetTrinketIdByName("Snapped Cross"),
    bobs_tongue = Isaac.GetTrinketIdByName("Bob's Tongue"),
    cake_pop = Isaac.GetTrinketIdByName("Marble Cake Pop"),
    bombshell = Isaac.GetTrinketIdByName("Bombshell"),
    godmode = Isaac.GetTrinketIdByName("Godmode"),
    mood_ring_blue = Isaac.GetTrinketIdByName("Mood Ring (Blue)"),
    mood_ring_yellow = Isaac.GetTrinketIdByName("Mood Ring (Yellow)"),
    mood_ring_green = Isaac.GetTrinketIdByName("Mood Ring (Green)"),
    mood_ring_black = Isaac.GetTrinketIdByName("Mood Ring (Black)"),
    snack_lock = Isaac.GetTrinketIdByName("Snack Lock"),
    keepah_card = Isaac.GetTrinketIdByName("Keepah Card"),
    trickle_key = Isaac.GetTrinketIdByName("Trickle Key"),
    glitched_penny = Isaac.GetTrinketIdByName("Glitched Penny"),

    cursed_pendant = Isaac.GetTrinketIdByName("Cursed Pendant"),
    shattered_moonrock = Isaac.GetTrinketIdByName("Shattered Moonrock"),
    cracked_nazar = Isaac.GetTrinketIdByName("Cracked Nazar"),
    white_candle = Isaac.GetTrinketIdByName("White Candle"),
}

reg.entities = {
    burnt_page = {
        type = Isaac.GetEntityTypeByName("Burnt Page"),
        variant = Isaac.GetEntityVariantByName("Burnt Page"),
    },
    pair_of_cans = {
        type = Isaac.GetEntityTypeByName("Pair of Cans"),
        variant = Isaac.GetEntityVariantByName("Pair of Cans"),
    },
    hush_cannon = {
        type = Isaac.GetEntityTypeByName("Hush Cannon"),
        variant = Isaac.GetEntityVariantByName("Hush Cannon"),
    },
    chigger = {
        type = Isaac.GetEntityTypeByName("Chigger"),
        variant = Isaac.GetEntityVariantByName("Chigger"),
    },
    holy_chalice = {
        type = Isaac.GetEntityTypeByName("Holy Chalice"),
        variant = Isaac.GetEntityVariantByName("Holy Chalice"),
    },
    diya = {
        type = Isaac.GetEntityTypeByName("Diya Candle"),
        variant = Isaac.GetEntityVariantByName("Diya Candle"),
    },
    ritual_familiar = {
        type = Isaac.GetEntityTypeByName("Ritual Candle (Familiar)"),
        variant = Isaac.GetEntityVariantByName("Ritual Candle (Familiar)"),
    },
    fallen_guard_familiar = {
        type = Isaac.GetEntityTypeByName("Fallen Guard (Familiar)"),
        variant = Isaac.GetEntityVariantByName("Fallen Guard (Familiar)"),
    },
    late_delivery = {
        type = Isaac.GetEntityTypeByName("Late Delivery"),
        variant = Isaac.GetEntityVariantByName("Late Delivery"),
    },
    fruit_fly = {
        type = Isaac.GetEntityTypeByName("Fruit Fly"),
        variant = Isaac.GetEntityVariantByName("Fruit Fly"),
    },
    sign_flame = {
        type = Isaac.GetEntityTypeByName("The Sign's Flame"),
        variant = Isaac.GetEntityVariantByName("The Sign's Flame"),
    },
    deli_halo = {
        type = Isaac.GetEntityTypeByName("Delirious Halo"),
        variant = Isaac.GetEntityVariantByName("Delirious Halo"),
    },
    deli_eye = {
        type = Isaac.GetEntityTypeByName("Delirious Eye"),
        variant = Isaac.GetEntityVariantByName("Delirious Eye"),
    },
    vengeful_dagger = {
        type = Isaac.GetEntityTypeByName("Vengeful Dagger"),
        variant = Isaac.GetEntityVariantByName("Vengeful Dagger"),
    },

    opia_tear = {
        type = Isaac.GetEntityTypeByName("Opia Soul"),
        variant = Isaac.GetEntityVariantByName("Opia Soul"),
    },
    hot_potato_tear = {
        type = Isaac.GetEntityTypeByName("Hot Potato Tear"),
        variant = Isaac.GetEntityVariantByName("Hot Potato Tear"),
    },
    hot_potato_tear_chunk = {
        type = Isaac.GetEntityTypeByName("Hot Potato Tear Chunk"),
        variant = Isaac.GetEntityVariantByName("Hot Potato Tear Chunk"),
    },


    nerve_cluster = {
        type = Isaac.GetEntityTypeByName("Nerve Cluster"),
        variant = Isaac.GetEntityVariantByName("Nerve Cluster"),
    },
    hostess_cluster = {
        type = Isaac.GetEntityTypeByName("Hostess Cluster"),
        variant = Isaac.GetEntityVariantByName("Hostess Cluster"),
        subtype = 1
    },
    guard_of_the_father = {
        type = Isaac.GetEntityTypeByName("Guard of the Father"),
        variant = Isaac.GetEntityVariantByName("Guard of the Father")
    },
    blind_spider = {
        type = Isaac.GetEntityTypeByName("Blind Spider"),
        variant = Isaac.GetEntityVariantByName("Blind Spider")
    },
    dream = {
        type = Isaac.GetEntityTypeByName("Dream"),
        variant = Isaac.GetEntityVariantByName("Dream")
    },
    trailer = {
        type = Isaac.GetEntityTypeByName("Trailer"),
        variant = Isaac.GetEntityVariantByName("Trailer")
    },
    grubby = {
        type = Isaac.GetEntityTypeByName("Grubby"),
        variant = Isaac.GetEntityVariantByName("Grubby")
    },
    cluster = {
        type = Isaac.GetEntityTypeByName("Cluster"),
        variant = Isaac.GetEntityVariantByName("Cluster")
    },
    harf = {
        type = Isaac.GetEntityTypeByName("Harf"),
        variant = Isaac.GetEntityVariantByName("Harf")
    },
    purple_heart = {
        type = Isaac.GetEntityTypeByName("Purple Heart"),
        variant = Isaac.GetEntityVariantByName("Purple Heart")
    },
    fetal_baby = {
        type = Isaac.GetEntityTypeByName("Fetal Baby"),
        variant = Isaac.GetEntityVariantByName("Fetal Baby")
    },
    planter = {
        type = Isaac.GetEntityTypeByName("Planter"),
        variant = Isaac.GetEntityVariantByName("Planter")
    },
    slammer = {
        type = Isaac.GetEntityTypeByName("Slammer"),
        variant = Isaac.GetEntityVariantByName("Slammer")
    },
    big_dipper = {
        type = Isaac.GetEntityTypeByName("Big Dipper"),
        variant = Isaac.GetEntityVariantByName("Big Dipper")
    },
    barfer = {
        type = Isaac.GetEntityTypeByName("Barfer"),
        variant = Isaac.GetEntityVariantByName("Barfer")
    },
    dial = {
        type = Isaac.GetEntityTypeByName("Dial"),
        variant = Isaac.GetEntityVariantByName("Dial")
    },
    guarded = {
        type = Isaac.GetEntityTypeByName("Guarded"),
        variant = Isaac.GetEntityVariantByName("Guarded")
    },
    silent = {
        type = Isaac.GetEntityTypeByName("Silent"),
        variant = Isaac.GetEntityVariantByName("Silent")
    },
    teether = {
        type = Isaac.GetEntityTypeByName("Teether"),
        variant = Isaac.GetEntityVariantByName("Teether")
    },
    hover = {
        type = Isaac.GetEntityTypeByName("Hover"),
        variant = Isaac.GetEntityVariantByName("Hover")
    },
    spiked_host = {
        type = Isaac.GetEntityTypeByName("Spiked Host"),
        variant = Isaac.GetEntityVariantByName("Spiked Host")
    },
    spiked_flesh_host = {
        type = Isaac.GetEntityTypeByName("Spiked Flesh Host"),
        variant = Isaac.GetEntityVariantByName("Spiked Flesh Host")
    },
    chanter = {
        type = Isaac.GetEntityTypeByName("Chanter"),
        variant = Isaac.GetEntityVariantByName("Chanter")
    },
    shade = {
        type = Isaac.GetEntityTypeByName("Shade Hand"),
        variant = Isaac.GetEntityVariantByName("Shade Hand")
    },
    paracolony = {
        type = Isaac.GetEntityTypeByName("Paracolony"),
        variant = Isaac.GetEntityVariantByName("Paracolony")
    },
    blood_baby = {
        type = Isaac.GetEntityTypeByName("Blood Baby"),
        variant = Isaac.GetEntityVariantByName("Blood Baby")
    },
    fallen_angelic_baby = {
        type = Isaac.GetEntityTypeByName("Fallen Angelic Baby"),
        variant = Isaac.GetEntityVariantByName("Fallen Angelic Baby")
    },
    queen_fly = {
        type = Isaac.GetEntityTypeByName("Queen Fly"),
        variant = Isaac.GetEntityVariantByName("Queen Fly")
    },
    godleg = {
        type = Isaac.GetEntityTypeByName("Godleg"),
        variant = Isaac.GetEntityVariantByName("Godleg")
    },
    marshall_pawn = {
        type = Isaac.GetEntityTypeByName("Marshall Pawn"),
        variant = Isaac.GetEntityVariantByName("Marshall Pawn")
    },
    arch_bishop = {
        type = Isaac.GetEntityTypeByName("Arch Bishop"),
        variant = Isaac.GetEntityVariantByName("Arch Bishop")
    },
    pooglobin = {
        type = Isaac.GetEntityTypeByName("Pooglobin"),
        variant = Isaac.GetEntityVariantByName("Pooglobin")
    },
    hexstar = {
        type = Isaac.GetEntityTypeByName("Hexstar"),
        variant = Isaac.GetEntityVariantByName("Hexstar")
    },
    mum = {
        type = Isaac.GetEntityTypeByName("Mum"),
        variant = Isaac.GetEntityVariantByName("Mum")
    },
    the_id = {
        type = Isaac.GetEntityTypeByName("The Id"),
        variant = Isaac.GetEntityVariantByName("The Id")
    },
    drifter = {
        type = Isaac.GetEntityTypeByName("Drifter"),
        variant = Isaac.GetEntityVariantByName("Drifter")
    },
    parabit = {
        type = Isaac.GetEntityTypeByName("Para-Bit"),
        variant = Isaac.GetEntityVariantByName("Para-Bit")
    },
    devil_lock = {
        type = Isaac.GetEntityTypeByName("Devil Lock"),
        variant = Isaac.GetEntityVariantByName("Devil Lock")
    },
    stifled_gatekeeper = {
        type = Isaac.GetEntityTypeByName("Stifled Gatekeeper"),
        variant = Isaac.GetEntityVariantByName("Stifled Gatekeeper")
    },
    winged_spider = {
        type = Isaac.GetEntityTypeByName("Winged Spider"),
        variant = Isaac.GetEntityVariantByName("Winged Spider")
    },
    delirious_pile = {
        type = Isaac.GetEntityTypeByName("Delirious Pile"),
        variant = Isaac.GetEntityVariantByName("Delirious Pile")
    },
    ludomini = {
        type = Isaac.GetEntityTypeByName("Ludomini"),
        variant = Isaac.GetEntityVariantByName("Ludomini")
    },
    ratty = {
        type = Isaac.GetEntityTypeByName("Ratty"),
        variant = Isaac.GetEntityVariantByName("Ratty")
    },
    infested_membrain = {
        type = Isaac.GetEntityTypeByName("Infested MemBrain"),
        variant = Isaac.GetEntityVariantByName("Infested MemBrain")
    },
    wrinkled_fatty = {
        type = Isaac.GetEntityTypeByName("Wrinkly Fatty"),
        variant = Isaac.GetEntityVariantByName("Wrinkly Fatty")
    },
    vengeance = {
        type = Isaac.GetEntityTypeByName("Vengeance"),
        variant = Isaac.GetEntityVariantByName("Vengeance")
    },
    callen_skull = {
        type = Isaac.GetEntityTypeByName("Callen Skull"),
        variant = Isaac.GetEntityVariantByName("Callen Skull")
    },
    electrite = {
        type = Isaac.GetEntityTypeByName("Electrite"),
        variant = Isaac.GetEntityVariantByName("Electrite")
    },
    hushed_horf = {
        type = Isaac.GetEntityTypeByName("Hushed Horf"),
        variant = Isaac.GetEntityVariantByName("Hushed Horf")
    },
    hushed_fatty = {
        type = Isaac.GetEntityTypeByName("Hushed Fatty"),
        variant = Isaac.GetEntityVariantByName("Hushed Fatty")
    },
    chest_mimic = {
        type = Isaac.GetEntityTypeByName("Chest Infestor"),
        variant = Isaac.GetEntityVariantByName("Chest Infestor")
    },
    swarm_one_tooth = {
        type = Isaac.GetEntityTypeByName("One Tooth (Swarm)"),
        variant = Isaac.GetEntityVariantByName("One Tooth (Swarm)")
    },
    swarm_fat_bat = {
        type = Isaac.GetEntityTypeByName("Fat Bat (Swarm)"),
        variant = Isaac.GetEntityVariantByName("Fat Bat (Swarm)")
    },

    ludomaw = {
        type = Isaac.GetEntityTypeByName("Ludomaw"),
        variant = Isaac.GetEntityVariantByName("Ludomaw")
    },
    hostess = {
        type = Isaac.GetEntityTypeByName("Hostess"),
        variant = Isaac.GetEntityVariantByName("Hostess")
    },
    market_man = {
        type = Isaac.GetEntityTypeByName("Market Man"),
        variant = Isaac.GetEntityVariantByName("Market Man")
    },
    mimic_worm = {
        type = Isaac.GetEntityTypeByName("Mimic Worm"),
        variant = Isaac.GetEntityVariantByName("Mimic Worm")
    },
    call_of_the_void = {
        type = Isaac.GetEntityTypeByName("Call of the Void"),
        variant = Isaac.GetEntityVariantByName("Call of the Void")
    },
    cotv_broken_orb = {
        type = Isaac.GetEntityTypeByName("Void Soul (Call of the Void Projectile)"),
        variant = Isaac.GetEntityVariantByName("Void Soul (Call of the Void Projectile)"),
        subtype = 1
    },
    cotv_damage_orb = {
        type = Isaac.GetEntityTypeByName("Skeletal Soul (The Fallen Light Projectile)"),
        variant = Isaac.GetEntityVariantByName("Skeletal Soul (The Fallen Light Projectile)"),
        subtype = 2
    },
    bubbly_plum = {
        type = Isaac.GetEntityTypeByName("Bubbly Plum"),
        variant = Isaac.GetEntityVariantByName("Bubbly Plum")
    },
    bubbly_plum_bubble_l = {
        type = Isaac.GetEntityTypeByName("Bubbly Plum Bubble (Large)"),
        variant = Isaac.GetEntityVariantByName("Bubbly Plum Bubble (Large)"),
        subtype = 1
    },
    bubbly_plum_bubble_s = {
        type = Isaac.GetEntityTypeByName("Bubbly Plum Bubble (Small)"),
        variant = Isaac.GetEntityVariantByName("Bubbly Plum Bubble (Small)"),
        subtype = 2
    },
    toxic_bubble_l = {
        type = Isaac.GetEntityTypeByName("Toxic Bubble (Large)"),
        variant = Isaac.GetEntityVariantByName("Toxic Bubble (Large)"),
        subtype = 3
    },
    toxic_bubble_s = {
        type = Isaac.GetEntityTypeByName("Toxic Bubble (Small)"),
        variant = Isaac.GetEntityVariantByName("Toxic Bubble (Small)"),
        subtype = 4
    },
    mega_worm = {
        type = Isaac.GetEntityTypeByName("Mega Worm"),
        variant = Isaac.GetEntityVariantByName("Mega Worm")
    },
    blightfly = {
        type = Isaac.GetEntityTypeByName("Blightfly"),
        variant = Isaac.GetEntityVariantByName("Blightfly")
    },
    bowl_play = {
        type = Isaac.GetEntityTypeByName("Bowl Play (Corny)"),
        variant = Isaac.GetEntityVariantByName("Bowl Play (Corny)")
    },
    outbreak = {
        type = Isaac.GetEntityTypeByName("Outbreak"),
        variant = Isaac.GetEntityVariantByName("Outbreak")
    },
    bulge_bat = {
        type = Isaac.GetEntityTypeByName("Bulge Bat"),
        variant = Isaac.GetEntityVariantByName("Bulge Bat")
    },
    brazier = {
        type = Isaac.GetEntityTypeByName("Brazier (Poky)"),
        variant = Isaac.GetEntityVariantByName("Brazier (Poky)")
    },
    error_boss = {
        type = Isaac.GetEntityTypeByName("Error Keeper (Boss)"),
        variant = Isaac.GetEntityVariantByName("Error Keeper (Boss)")
    },
    godmode_famine = {
        type = Isaac.GetEntityTypeByName("(GODMODE) Famine"),
        variant = Isaac.GetEntityVariantByName("(GODMODE) Famine")
    },
    godmode_war = {
        type = Isaac.GetEntityTypeByName("(GODMODE) War"),
        variant = Isaac.GetEntityVariantByName("(GODMODE) War")
    },
    godmode_war_no_horse = {
        type = Isaac.GetEntityTypeByName("(GODMODE) War without horse"),
        variant = Isaac.GetEntityVariantByName("(GODMODE) War without horse")
    },
    godmode_death_horse = {
        type = Isaac.GetEntityTypeByName("(GODMODE) Death Horse"),
        variant = Isaac.GetEntityVariantByName("(GODMODE) Death Horse")
    },
    godmode_death_no_horse = {
        type = Isaac.GetEntityTypeByName("(GODMODE) Death without horse"),
        variant = Isaac.GetEntityVariantByName("(GODMODE) Death without horse")
    },
    godmode_death = {
        type = Isaac.GetEntityTypeByName("(GODMODE) Death"),
        variant = Isaac.GetEntityVariantByName("(GODMODE) Death")
    },
    the_ritual = {
        type = Isaac.GetEntityTypeByName("The Ritual"),
        variant = Isaac.GetEntityVariantByName("The Ritual")
    },
    ritual_candle = {
        type = Isaac.GetEntityTypeByName("The Ritual's Candle"),
        variant = Isaac.GetEntityVariantByName("The Ritual's Candle"),
        subtype = 1
    },
    sacred_mind = {
        type = Isaac.GetEntityTypeByName("The Sacred Mind"),
        variant = Isaac.GetEntityVariantByName("The Sacred Mind")
    },
    sacred_body = {
        type = Isaac.GetEntityTypeByName("The Sacred Body"),
        variant = Isaac.GetEntityVariantByName("The Sacred Body")
    },
    sacred_soul = {
        type = Isaac.GetEntityTypeByName("The Sacred Soul"),
        variant = Isaac.GetEntityVariantByName("The Sacred Soul")
    },
    souleater = {
        type = Isaac.GetEntityTypeByName("Souleater"),
        variant = Isaac.GetEntityVariantByName("Souleater")
    },
    furnace_guard = {
        type = Isaac.GetEntityTypeByName("Furnace Guard"),
        variant = Isaac.GetEntityVariantByName("Furnace Guard")
    },
    furnace_knight = {
        type = Isaac.GetEntityTypeByName("Furnace Knight"),
        variant = Isaac.GetEntityVariantByName("Furnace Knight"),
        subtype = 1
    },
    furnace_knight_boss = {
        type = Isaac.GetEntityTypeByName("Furnace Knight (Boss)"),
        variant = Isaac.GetEntityVariantByName("Furnace Knight (Boss)"),
        subtype = 2
    },
    grand_marshall = {
        type = Isaac.GetEntityTypeByName("The Grand Marshall"),
        variant = Isaac.GetEntityVariantByName("The Grand Marshall")
    },
    bloody_uriel = {
        type = Isaac.GetEntityTypeByName("Bloody Uriel"),
        variant = Isaac.GetEntityVariantByName("Bloody Uriel")
    },
    bloody_gabriel = {
        type = Isaac.GetEntityTypeByName("Bloody Gabriel"),
        variant = Isaac.GetEntityVariantByName("Bloody Gabriel")
    },
    bathemo_swarm = {
        type = Isaac.GetEntityTypeByName("Bathemo Swarm"),
        variant = Isaac.GetEntityVariantByName("Bathemo Swarm")
    },
    bathemo = {
        type = Isaac.GetEntityTypeByName("Bathemo"),
        variant = Isaac.GetEntityVariantByName("Bathemo")
    },
    bathemo_devote = {
        type = Isaac.GetEntityTypeByName("Bathemo Devote"),
        variant = Isaac.GetEntityVariantByName("Bathemo Devote"),
        subtype = GODMODE.validate_rgon() and Isaac.GetEntitySubTypeByName("Bathemo Devote") or 1
    },
    the_fallen_light = {
        type = Isaac.GetEntityTypeByName("The Fallen Light"),
        variant = Isaac.GetEntityVariantByName("The Fallen Light")
    },
    the_sign = {
        type = Isaac.GetEntityTypeByName("The Sign"),
        variant = Isaac.GetEntityVariantByName("The Sign")
    },


    holy_order = {
        type = Isaac.GetEntityTypeByName("Holy Order"),
        variant = Isaac.GetEntityVariantByName("Holy Order")
    },
    shatter_coin = {
        type = Isaac.GetEntityTypeByName("Shatter Coin"),
        variant = Isaac.GetEntityVariantByName("Shatter Coin")
    },
    secret_light = {
        type = Isaac.GetEntityTypeByName("Secret Light"),
        variant = Isaac.GetEntityVariantByName("Secret Light")
    },
    red_coin = {
        type = Isaac.GetEntityTypeByName("Red Coin"),
        variant = Isaac.GetEntityVariantByName("Red Coin")
    },
    unholy_order = {
        type = Isaac.GetEntityTypeByName("Unholy Order"),
        variant = Isaac.GetEntityVariantByName("Unholy Order")
    },
    crossbones_shield = {
        type = Isaac.GetEntityTypeByName("Crossbones Shield"),
        variant = Isaac.GetEntityVariantByName("Crossbones Shield")
    },
    aztec_shield = {
        type = Isaac.GetEntityTypeByName("Aztec Shield"),
        variant = Isaac.GetEntityVariantByName("Aztec Shield"),
        subtype = 1
    },
    heart_container = {
        type = Isaac.GetEntityTypeByName("Heart Container (Pickup)"),
        variant = Isaac.GetEntityVariantByName("Heart Container (Pickup)")
    },
    unlock_pedestal = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Unlock Pedestal"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Unlock Pedestal")
    },
    fruit = {
        type = Isaac.GetEntityTypeByName("Fruit (Pickup)"),
        variant = Isaac.GetEntityVariantByName("Fruit (Pickup)")
    },
    fatal_attraction_station = {
        type = Isaac.GetEntityTypeByName("Fatal Attraction Helper"),
        variant = Isaac.GetEntityVariantByName("Fatal Attraction Helper")
    },
    gehazi_shrine = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Gehazi Shrine"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Gehazi Shrine")
    },
    soft_serve = {
        type = Isaac.GetEntityTypeByName("Soft Serve Spawner"),
        variant = Isaac.GetEntityVariantByName("Soft Serve Spawner")
    },
    player_trail_fx = {
        type = Isaac.GetEntityTypeByName("Player Trail FX"),
        variant = Isaac.GetEntityVariantByName("Player Trail FX")
    },
    crack_the_sky = {
        type = Isaac.GetEntityTypeByName("Crack The Sky (With Tell)"),
        variant = Isaac.GetEntityVariantByName("Crack The Sky (With Tell)")
    },
    celestial_swipe = {
        type = Isaac.GetEntityTypeByName("Celestial Swipe"),
        variant = Isaac.GetEntityVariantByName("Celestial Swipe")
    },
    feather_dust = {
        type = Isaac.GetEntityTypeByName("Feather Dust"),
        variant = Isaac.GetEntityVariantByName("Feather Dust"),
        subtype = 1,
    },
    temp_broken_fx = {
        type = Isaac.GetEntityTypeByName("Temp Broken Removal"),
        variant = Isaac.GetEntityVariantByName("Temp Broken Removal"),
        subtype = 3,
    },
    adramolechs_fuel = {
        type = Isaac.GetEntityTypeByName("Adramolech's Fuel"),
        variant = Isaac.GetEntityVariantByName("Adramolech's Fuel")
    },
    adramolechs_fuel_charged = {
        type = Isaac.GetEntityTypeByName("Adramolech's Fuel (Charged)"),
        variant = Isaac.GetEntityVariantByName("Adramolech's Fuel (Charged)"),
        subtype = 1,
    },
    delirious_energy = {
        type = Isaac.GetEntityTypeByName("Delirious Energy"),
        variant = Isaac.GetEntityVariantByName("Delirious Energy"),
        subtype = 2,
    },
    fallen_light_crack = {
        type = Isaac.GetEntityTypeByName("Fallen Light Crack"),
        variant = Isaac.GetEntityVariantByName("Fallen Light Crack"),
    },
    war_banner = {
        type = Isaac.GetEntityTypeByName("War Banner"),
        variant = Isaac.GetEntityVariantByName("War Banner"),
    },
    bomb_barrel = {
        type = Isaac.GetEntityTypeByName("Bomb Barrel"),
        variant = Isaac.GetEntityVariantByName("Bomb Barrel"),
    },
    papal_flame = {
        type = Isaac.GetEntityTypeByName("Papal Flame"),
        variant = Isaac.GetEntityVariantByName("Papal Flame"),
    },
    golden_scale = {
        type = Isaac.GetEntityTypeByName("Golden Scale"),
        variant = Isaac.GetEntityVariantByName("Golden Scale"),
    },
    silver_scale = {
        type = Isaac.GetEntityTypeByName("Silver Scale"),
        variant = Isaac.GetEntityVariantByName("Silver Scale"),
        subtype = 1,
    },
    elohims_throne = {
        type = Isaac.GetEntityTypeByName("Elohim's Throne"),
        variant = Isaac.GetEntityVariantByName("Elohim's Throne"),
    },
    masked_angel_statue = {
        type = Isaac.GetEntityTypeByName("Masked Angel Statue"),
        variant = Isaac.GetEntityVariantByName("Masked Angel Statue"),
    },
    keepah = {
        type = Isaac.GetEntityTypeByName("Keepah (Shop Parrot)"),
        variant = Isaac.GetEntityVariantByName("Keepah (Shop Parrot)"),
    },
    stone_beggar = {
        type = Isaac.GetEntityTypeByName("Stone Beggar"),
        variant = Isaac.GetEntityVariantByName("Stone Beggar"),
    },
    palace_mural = {
        type = Isaac.GetEntityTypeByName("Lucifer's Palace Mural"),
        variant = Isaac.GetEntityVariantByName("Lucifer's Palace Mural"),
    },
    ivory_portal = {
        type = Isaac.GetEntityTypeByName("Ivory Portal"),
        variant = Isaac.GetEntityVariantByName("Ivory Portal"),
    },
    ooze_turret = {
        type = Isaac.GetEntityTypeByName("Ooze Turret"),
        variant = Isaac.GetEntityVariantByName("Ooze Turret"),
    },
    door_hazard = {
        type = Isaac.GetEntityTypeByName("Door Hazard"),
        variant = Isaac.GetEntityVariantByName("Door Hazard"),
    },
    dynamite_rock = {
        type = Isaac.GetEntityTypeByName("Dynamite Rock (Brazier)"),
        variant = Isaac.GetEntityVariantByName("Dynamite Rock (Brazier)"),
    },
    observatory_fx = {
        type = Isaac.GetEntityTypeByName("Observatory FX"),
        variant = Isaac.GetEntityVariantByName("Observatory FX"),
    },
    correction_fx = {
        type = Isaac.GetEntityTypeByName("Correction FX"),
        variant = Isaac.GetEntityVariantByName("Correction FX"),
    },
    correction_shrine = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Correction Shrine"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Correction Shrine"),
    },
    correction_hand = {
        type = Isaac.GetEntityTypeByName("Correction Hand"),
        variant = Isaac.GetEntityVariantByName("Correction Hand"),
        subtype = 2,
    },
    cotv_correct = {
        type = Isaac.GetEntityTypeByName("COTV (Correction Room)"),
        variant = Isaac.GetEntityVariantByName("COTV (Correction Room)"),
    },
    pill_beggar = {
        type = Isaac.GetEntityTypeByName("Pill Beggar"),
        variant = Isaac.GetEntityVariantByName("Pill Beggar")
    },
    closet_tchar = {
        type = Isaac.GetEntityTypeByName("Godmode Tainted Char"),
        variant = Isaac.GetEntityVariantByName("Godmode Tainted Char")
    },
    fallen_light_bone = {
        type = Isaac.GetEntityTypeByName("Fallen Light Bone"),
        variant = Isaac.GetEntityVariantByName("Fallen Light Bone")
    },
    sugar_sparkle = {
        type = Isaac.GetEntityTypeByName("Sugar Sparkle"),
        variant = Isaac.GetEntityVariantByName("Sugar Sparkle"),
        subtype = 4,
    },
}

reg.blessings = {
    faith = Isaac.GetCurseIdByName("Blessing of Faith!"),
    charity = Isaac.GetCurseIdByName("Blessing of Charity!"),
    fortitude = Isaac.GetCurseIdByName("Blessing of Fortitude!"),
    justice = Isaac.GetCurseIdByName("Blessing of Justice!"),
    patience = Isaac.GetCurseIdByName("Blessing of Patience!"),
    kindness = Isaac.GetCurseIdByName("Blessing of Kindness!"),
    opportunity = Isaac.GetCurseIdByName("Blessing of Opportunity!"),
}

reg.blessing_keys = {
    "faith", "charity", "fortitude", "justice", "patience", "kindness", "opportunity"
}

reg.costumes = {
    arac_head = Isaac.GetCostumeIdByPath("gfx/costumes/arac_head.anm2"),
    t_arac_head = Isaac.GetCostumeIdByPath("gfx/costumes/tainted_arac_head.anm2"),
    xaphan_head = Isaac.GetCostumeIdByPath("gfx/costumes/xaphan_head.anm2"),
    t_xaphan_head = Isaac.GetCostumeIdByPath("gfx/costumes/xaphan_head_tainted.anm2"),
    t_xaphan_eyes_0 = Isaac.GetCostumeIdByPath("gfx/costumes/xaphan_eyes_0.anm2"),
    t_xaphan_eyes = {
        Isaac.GetCostumeIdByPath("gfx/costumes/xaphan_eyes_0.anm2"),
        Isaac.GetCostumeIdByPath("gfx/costumes/xaphan_eyes_1.anm2"),
        Isaac.GetCostumeIdByPath("gfx/costumes/xaphan_eyes_2.anm2"),
        Isaac.GetCostumeIdByPath("gfx/costumes/xaphan_eyes_3.anm2"),
    },
    
    t_xaphan_body = Isaac.GetCostumeIdByPath("gfx/costumes/xaphan_body_tainted.anm2"),
    elohim_beard = Isaac.GetCostumeIdByPath("gfx/costumes/elohim_beard.anm2"),
    t_elohim_beard = Isaac.GetCostumeIdByPath("gfx/costumes/tainted_elohim_beard.anm2"),
    t_gehazi_eyes = Isaac.GetCostumeIdByPath("gfx/costumes/t_gehazi_eyes.anm2"),
    t_deli_eyes = Isaac.GetCostumeIdByPath("gfx/costumes/t_deli_eyes.anm2"),
    
    the_sign_wings = Isaac.GetCostumeIdByPath("gfx/costumes/sign_wings.anm2"),
    
    edible_soul = Isaac.GetCostumeIdByPath("gfx/costumes/edible_soul_bodiless.anm2"),
    maxs_head = {
        Isaac.GetCostumeIdByPath("gfx/costumes/maxs_head_1.anm2"),
        Isaac.GetCostumeIdByPath("gfx/costumes/maxs_head_2.anm2"),
        Isaac.GetCostumeIdByPath("gfx/costumes/maxs_head_3.anm2"),
        Isaac.GetCostumeIdByPath("gfx/costumes/maxs_head_4.anm2"),
        Isaac.GetCostumeIdByPath("gfx/costumes/maxs_head_5.anm2"),
    },
    wings_of_betrayal = Isaac.GetCostumeIdByPath("gfx/costumes/luc_wings.anm2"),

    celeste = Isaac.GetCostumeIdByPath("gfx/costumes/celeste.anm2"),
    cyborg = Isaac.GetCostumeIdByPath("gfx/costumes/cyborg.anm2"),
}

reg.challenges = {
    secrets = Isaac.GetChallengeIdByName("[GOD] Secrets"),
    out_of_time = Isaac.GetChallengeIdByName("[GOD] Out Of Time"),
    sugar_rush = Isaac.GetChallengeIdByName("[GOD] Sugar Rush!"),
    the_galactic_approach = Isaac.GetChallengeIdByName("[GOD] The Galactic Approach"),
    dystopia = Isaac.GetChallengeIdByName("[GOD] Dystopia"),
}

reg.players = {
    recluse = Isaac.GetPlayerTypeByName("Recluse",false),
    t_recluse = Isaac.GetPlayerTypeByName("Tainted Recluse",true),
    xaphan = Isaac.GetPlayerTypeByName("Xaphan",false),
    t_xaphan = Isaac.GetPlayerTypeByName("Tainted Xaphan",true),
    elohim = Isaac.GetPlayerTypeByName("Elohim",false),
    t_elohim = Isaac.GetPlayerTypeByName("Tainted Elohim",true),
    deli = Isaac.GetPlayerTypeByName("Deli",false),
    t_deli = Isaac.GetPlayerTypeByName("Tainted Deli",true),
    gehazi = Isaac.GetPlayerTypeByName("Gehazi",false),
    t_gehazi = Isaac.GetPlayerTypeByName("Tainted Gehazi",true),
    the_sign = Isaac.GetPlayerTypeByName("The Sign",false),   
}

reg.music = {
    a_blackened_light = Isaac.GetMusicIdByName("GODMODE A Blackened Light"),
    experiencing_revelation = Isaac.GetMusicIdByName("GODMODE Experiencing Revelation"),
    peripheral_visions = Isaac.GetMusicIdByName("GODMODE Peripheral Visions"),
    shellstepping = Isaac.GetMusicIdByName("GODMODE Shellstepping"),
    pulsations = Isaac.GetMusicIdByName("GODMODE Pulsations"),
    the_stars_gaze_back = Isaac.GetMusicIdByName("GODMODE The Stars Gaze Back"),
    a_song_from_a_broken_soul = Isaac.GetMusicIdByName("GODMODE Cathedral"),
    the_path_to_enlightenment = Isaac.GetMusicIdByName("GODMODE Boss (Cathedral - Isaac)"),
    misfortunate = Isaac.GetMusicIdByName("GODMODE Misfortunate"),
    twinkles = Isaac.GetMusicIdByName("GODMODE Twinkles of a Last Thought"),
    persuasions = Isaac.GetMusicIdByName("GODMODE Shop Room"),
}

reg.sounds = {
    sacred_1 = Isaac.GetSoundIdByName("sacred_1"),
    sacred_2 = Isaac.GetSoundIdByName("sacred_2"),
    sacred_3 = Isaac.GetSoundIdByName("sacred_3"),
    sacred_appear = Isaac.GetSoundIdByName("sacred_appear"),
    red_coin = Isaac.GetSoundIdByName("red_coin"),
    red_coin_complete = Isaac.GetSoundIdByName("red_coin_complete"),
    keepah = Isaac.GetSoundIdByName("keepah_chirp"),
    keepah_panic = Isaac.GetSoundIdByName("keepah_panic"),
    ending_voiceover = Isaac.GetSoundIdByName("godmode_ending"),
    ending_voiceover_joke = Isaac.GetSoundIdByName("godmode_ending_joke"),
    regular_cough = Isaac.GetSoundIdByName("regular_cough"),
}

reg.transformations = {
    celeste = "Celeste",
    cyborg = "Cyborg",
    cultist = "Cultist"
}

reg.hearts = {
    faithless = 1,
    delirious = 2,
    toxic = 3,
}

reg.mimic_chests = {
    [PickupVariant.PICKUP_CHEST] = {null_pos_off=Vector(0,0),eye_pos_off=Vector(0,-2),unlock=true,death_unlock = false,
    attack=function(ent,data,sprite) 
        data:fire_ring(ent,10,7.5+(GODMODE.game.Difficulty % 2) * 2,ent:GetDropRNG():RandomFloat() * 36.0,1.25,ProjectileFlags.DECELERATE)
    end},

    [PickupVariant.PICKUP_BOMBCHEST] = {null_pos_off=Vector(0,0),eye_pos_off=Vector(0,-2),unlock=false,death_unlock = false,
    attack=function(ent,data,sprite) 
        data:fire_ring(ent,6,7+(GODMODE.game.Difficulty % 2) * 3,ent:GetDropRNG():RandomFloat() * 60.0,2,ProjectileFlags.EXPLODE)
    end},

    [PickupVariant.PICKUP_SPIKEDCHEST] = {null_pos_off=Vector(0,-6),eye_pos_off=Vector(0,-2),unlock=true,death_unlock = false,
    attack=function(ent,data,sprite) 
        local off = ent:GetDropRNG():RandomFloat() * 60.0
        data:fire_ring(ent,6,7.5+(GODMODE.game.Difficulty % 2) * 2,off,1.0)
        data:fire_ring(ent,12,3+(GODMODE.game.Difficulty % 2),off + 30.0,1.25)
    end},

    [PickupVariant.PICKUP_ETERNALCHEST] = {null_pos_off=Vector(0,0),eye_pos_off=Vector(0,-2),unlock=false,death_unlock = true,
    attack=function(ent,data,sprite) 
        data:fire_ring(ent,16,1+(GODMODE.game.Difficulty % 2) * 1,ent:GetDropRNG():RandomFloat() * 360.0/16.0,1.0,ProjectileFlags.GHOST | ProjectileFlags.ACCELERATE)
        data:fire_ring(ent,12,2.5+(GODMODE.game.Difficulty % 2) * 2,ent:GetDropRNG():RandomFloat() * 360.0/12.0,1.0,ProjectileFlags.CURVE_RIGHT | ProjectileFlags.GHOST)
        data:fire_ring(ent,8,5+(GODMODE.game.Difficulty % 2) * 3,ent:GetDropRNG():RandomFloat() * 360.0/8.0,1.0,ProjectileFlags.CURVE_LEFT | ProjectileFlags.GHOST)
    end},

    [PickupVariant.PICKUP_OLDCHEST] = {null_pos_off=Vector(0,0),eye_pos_off=Vector(0,-2),unlock=false,death_unlock = true,
    attack=function(ent,data,sprite) 
        data:fire_ring(ent,4,5+(GODMODE.game.Difficulty % 2) * 3,ent:GetDropRNG():RandomFloat() * 90,1.5,ProjectileFlags.BURST | ProjectileFlags.BOOMERANG)
    end},

    [PickupVariant.PICKUP_WOODENCHEST] = {null_pos_off=Vector(0,0),eye_pos_off=Vector(0,-2),unlock=true,death_unlock = false,
    attack=function(ent,data,sprite) 
        data:fire_ring(ent,10,7.5+(GODMODE.game.Difficulty % 2) * 2,ent:GetDropRNG():RandomFloat() * 36.0,1.25,ProjectileFlags.DECELERATE)
    end, 
    atk_update = function(ent,data,sprite) 
        if ent:IsFrame(5,1) and ent.Velocity:Length() > 1 then 
            data:fire_bullet(ent,ent.Velocity:GetAngleDegrees()-90,3,1.1)
        end
    end},

    [PickupVariant.PICKUP_LOCKEDCHEST] = {null_pos_off=Vector(0,0),eye_pos_off=Vector(0,-2),unlock=false,death_unlock = true,
    attack=function(ent,data,sprite) 
        data:fire_ring(ent,20,3+(GODMODE.game.Difficulty % 2) * 3,ent:GetDropRNG():RandomFloat() * 18.0,1.25,ProjectileFlags.ACCELERATE)
    end},

    [PickupVariant.PICKUP_REDCHEST] = {null_pos_off=Vector(0,0),eye_pos_off=Vector(0,-2),unlock=true,death_unlock = false,
    attack=function(ent,data,sprite) 
        data:fire_ring(ent,4,7+(GODMODE.game.Difficulty % 2) * 3,ent:GetDropRNG():RandomFloat() * 18.0,1.6,ProjectileFlags.DECELERATE | ProjectileFlags.RED_CREEP)
    end},
}

if GODMODE.validate_rgon() then 
    reg.cutscenes = {
        ending = Isaac.GetCutsceneIdByName ("GODMODE_Ending") 
    }

    -- any entries here that are the same name as the pools in itempools.lua will replace the Godmode system with built-in system
    reg.itempools = {
        pill_beggar = Isaac.GetPoolIdByName("GODMODE_pillBeggar"),
        fruit_beggar = Isaac.GetPoolIdByName("GODMODE_fruitBeggar"),
        sugar_pill = Isaac.GetPoolIdByName("GODMODE_sugarPills"),
        observatory_items = Isaac.GetPoolIdByName("GODMODE_observatoryItems"),
    }

    reg.achievements = {
        -- fallen light unlocks
        fl_isaac = Isaac.GetAchievementIdByName("GODMODE_FL_Isaac"),
        fl_tisaac = Isaac.GetAchievementIdByName("GODMODE_FL_TIsaac"),
        fl_maggy = Isaac.GetAchievementIdByName("GODMODE_FL_Magdalene"),
        fl_tmaggy = Isaac.GetAchievementIdByName("GODMODE_FL_TMagdalene"),
        fl_cain = Isaac.GetAchievementIdByName("GODMODE_FL_Cain"),
        fl_tcain = Isaac.GetAchievementIdByName("GODMODE_FL_TCain"),
        fl_judas = Isaac.GetAchievementIdByName("GODMODE_FL_Judas"),
        fl_tjudas = Isaac.GetAchievementIdByName("GODMODE_FL_TJudas"),
        fl_xxx = Isaac.GetAchievementIdByName("GODMODE_FL_XXX"),
        fl_txxx = Isaac.GetAchievementIdByName("GODMODE_FL_TXXX"),
        fl_eve = Isaac.GetAchievementIdByName("GODMODE_FL_Eve"),
        fl_samson = Isaac.GetAchievementIdByName("GODMODE_FL_Samson"),
        fl_azazel = Isaac.GetAchievementIdByName("GODMODE_FL_Azazel"),
        fl_lazarus = Isaac.GetAchievementIdByName("GODMODE_FL_Lazarus"),
        fl_eden = Isaac.GetAchievementIdByName("GODMODE_FL_Eden"),
        fl_thelost = Isaac.GetAchievementIdByName("GODMODE_FL_TheLost"),
        fl_lilith = Isaac.GetAchievementIdByName("GODMODE_FL_Lilith"),
        fl_keeper = Isaac.GetAchievementIdByName("GODMODE_FL_Keeper"),
        fl_apollyon = Isaac.GetAchievementIdByName("GODMODE_FL_Apollyon"),
        fl_forgotten = Isaac.GetAchievementIdByName("GODMODE_FL_TheForgotten"),
        fl_bethany = Isaac.GetAchievementIdByName("GODMODE_FL_Bethany"),
        fl_jacobesau = Isaac.GetAchievementIdByName("GODMODE_FL_JacobEsau"),
        
        fl_recluse = Isaac.GetAchievementIdByName("GODMODE_FL_Recluse"),
        fl_trecluse = Isaac.GetAchievementIdByName("GODMODE_FL_TRecluse"),
        fl_xaphan = Isaac.GetAchievementIdByName("GODMODE_FL_Xaphan"),
        fl_txaphan = Isaac.GetAchievementIdByName("GODMODE_FL_TXaphan"),
        fl_elohim = Isaac.GetAchievementIdByName("GODMODE_FL_Elohim"),
        fl_telohim = Isaac.GetAchievementIdByName("GODMODE_FL_TElohim"),
        fl_deli = Isaac.GetAchievementIdByName("GODMODE_FL_Deli"),
        fl_tdeli = Isaac.GetAchievementIdByName("GODMODE_FL_TDeli"),
        fl_gehazi = Isaac.GetAchievementIdByName("GODMODE_FL_Gehazi"),
        fl_tgehazi = Isaac.GetAchievementIdByName("GODMODE_FL_TGehazi"),
        fl_thesign = Isaac.GetAchievementIdByName("GODMODE_FL_TheSign"),

        -- tainted char unlocks
        t_recluse = Isaac.GetAchievementIdByName("GODMODE_TRecluse"),
        t_xaphan = Isaac.GetAchievementIdByName("GODMODE_TXaphan"),
        t_deli = Isaac.GetAchievementIdByName("GODMODE_TDeli"),
        t_elohim = Isaac.GetAchievementIdByName("GODMODE_TElohim"),
        t_gehazi = Isaac.GetAchievementIdByName("GODMODE_TGehazi"),

        -- regular char unlocks
        the_sign = Isaac.GetAchievementIdByName("GODMODE_TheSign"),
        recluse = Isaac.GetAchievementIdByName("GODMODE_Recluse"),
        elohim = Isaac.GetAchievementIdByName("GODMODE_Elohim"),
        deli = Isaac.GetAchievementIdByName("GODMODE_Deli"),

        -- upgrades for the sign
        thesign1 = Isaac.GetAchievementIdByName("GODMODE_TheSign1"),
        thesign2 = Isaac.GetAchievementIdByName("GODMODE_TheSign2"),
        thesign3 = Isaac.GetAchievementIdByName("GODMODE_TheSign3"),
        thesign4 = Isaac.GetAchievementIdByName("GODMODE_TheSign4"),
        thesign_complete = Isaac.GetAchievementIdByName("GODMODE_TheSignComplete"),

        -- item unlocks
        impending_doom = Isaac.GetAchievementIdByName("GODMODE_ImpendingDoom"),
        vajra = Isaac.GetAchievementIdByName("GODMODE_Vajra"),
        prayer_mat = Isaac.GetAchievementIdByName("GODMODE_PrayerMat"),

        -- challenge unlocks
        sugar_rush = Isaac.GetAchievementIdByName("GODMODE_SugarRush"),
        celestial_approach = Isaac.GetAchievementIdByName("GODMODE_CelestialApproach"),
        out_of_time = Isaac.GetAchievementIdByName("GODMODE_OutOfTime"),
    }

    reg.closet_chars = {
        [reg.players.recluse] = {
            char_sprite = "gfx/characters/arac_tainted/arac_black.png",
            unlock = reg.players.t_recluse,
            achievement = reg.achievements.t_recluse,
            as = reg.players.recluse,
        },
        [reg.players.xaphan] = {
            char_sprite = "gfx/characters/xaphan_tainted/xaphan_grey.png",
            unlock = reg.players.t_xaphan,
            achievement = reg.achievements.t_xaphan,
            as = reg.players.xaphan,
        },
        [reg.players.deli] = {
            char_sprite = "gfx/characters/deli_tainted/deli_white.png",
            unlock = reg.players.t_deli,
            achievement = reg.achievements.t_deli,
            as = reg.players.deli,
        },
        [reg.players.elohim] = {
            char_sprite = "gfx/characters/elohim_tainted/elohim.png",
            unlock = reg.players.t_elohim,
            achievement = reg.achievements.t_elohim,
            as = reg.players.elohim,
        },
        [reg.players.gehazi] = {
            char_sprite = "gfx/characters/gehazi_tainted/gideon_green.png",
            unlock = reg.players.t_gehazi,
            achievement = reg.achievements.t_gehazi,
            as = reg.players.gehazi,
        },
    }
end

return reg