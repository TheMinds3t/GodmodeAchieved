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
    -- celestial_hairball = Isaac.GetItemIdByName("Celestial Hairball"),
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
    eggnog = Isaac.GetItemIdByName("Cup O' Nog"),
    key_ring = Isaac.GetItemIdByName("Dad's Key Ring"),
    red_juice = Isaac.GetItemIdByName("Red Juice"),
    hellfiah = Isaac.GetItemIdByName("Hellfiah Saus"),
    fallen_skull = Isaac.GetItemIdByName("Fallen Skull"),
    tear_gas = Isaac.GetItemIdByName("Tear Gas"),
    three_leaf_clover = Isaac.GetItemIdByName("Three Leaf Clover"),
    door_rift = Isaac.GetItemIdByName("Door Rift"),
    curse_of_the_snail = Isaac.GetItemIdByName("Curse of the Snail"),
    loded_sack = Isaac.GetItemIdByName("Loded Sack"),

    reclusive_tendencies = Isaac.GetItemIdByName("Reclusive Tendencies"),
    golden_stopwatch = Isaac.GetItemIdByName("Golden Stopwatch"),
    moms_wish = Isaac.GetItemIdByName("Mom's Wish"),
    adramolechs_fury = Isaac.GetItemIdByName("Adramolech's Fury"),
    deli_delusion = Isaac.GetItemIdByName("Delusion"),
    deli_oblivion = Isaac.GetItemIdByName("Oblivion"),
    vengeful_dagger = Isaac.GetItemIdByName("Vengeful Dagger"),
    reflect = Isaac.GetItemIdByName("Reflect"),
    
    -- questrock_1 = Isaac.GetItemIdByName("Rock Fragment"),
    -- questrock_2 = Isaac.GetItemIdByName("Holy Stone"),
    -- questrock_3 = Isaac.GetItemIdByName("Tablet Fragment"),
    -- questrock_4 = Isaac.GetItemIdByName("Final Slate"),
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
    bone_feather = Isaac.GetTrinketIdByName("Bone Feather"),
}

reg.entities = {
    burnt_page = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Burnt Page"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Burnt Page"),
    },
    pair_of_cans = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Pair of Cans"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Pair of Cans"),
    },
    hush_cannon = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Hush Cannon"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Hush Cannon"),
    },
    chigger = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Chigger"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Chigger"),
    },
    holy_chalice = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Holy Chalice"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Holy Chalice"),
    },
    diya = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Diya Candle"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Diya Candle"),
    },
    ritual_familiar = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Ritual Candle (Familiar)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Ritual Candle (Familiar)"),
    },
    fallen_guard_familiar = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Fallen Guard (Familiar)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Fallen Guard (Familiar)"),
    },
    late_delivery = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Late Delivery"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Late Delivery"),
    },
    fruit_fly = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Fruit Fly"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Fruit Fly"),
    },
    sign_flame = {
        type = Isaac.GetEntityTypeByName("[GODMODE] The Sign's Flame"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] The Sign's Flame"),
    },
    deli_halo = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Delirious Halo"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Delirious Halo"),
    },
    deli_eye = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Delirious Eye"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Delirious Eye"),
    },
    vengeful_dagger = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Vengeful Dagger"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Vengeful Dagger"),
    },
    hellfiah_familiar = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Hellfiah"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Hellfiah"),
    },
    cursed_snail = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Cursed Snail"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Cursed Snail"),
    },
    loded_sack = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Loded Sack"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Loded Sack"),
    },

    opia_soul = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Opia Soul"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Opia Soul"),
    },
    hot_potato_tear = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Hot Potato Tear"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Hot Potato Tear"),
    },
    hot_potato_tear_chunk = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Hot Potato Tear Chunk"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Hot Potato Tear Chunk"),
    },


    nerve_cluster = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Nerve Cluster"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Nerve Cluster"),
    },
    hostess_cluster = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Hostess Cluster"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Hostess Cluster"),
        subtype = 1
    },
    guard_of_the_father = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Guard of the Father"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Guard of the Father")
    },
    blind_spider = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Blind Spider"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Blind Spider")
    },
    dream = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Dream"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Dream")
    },
    trailer = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Trailer"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Trailer")
    },
    grubby = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Grubby"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Grubby")
    },
    cluster = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Cluster"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Cluster")
    },
    harf = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Harf"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Harf")
    },
    purple_heart = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Purple Heart"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Purple Heart")
    },
    fetal_baby = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Fetal Baby"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Fetal Baby")
    },
    planter = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Planter"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Planter")
    },
    slammer = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Slammer"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Slammer")
    },
    big_dipper = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Big Dipper"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Big Dipper")
    },
    barfer = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Barfer"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Barfer")
    },
    dial = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Dial"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Dial")
    },
    guarded = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Guarded"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Guarded")
    },
    silent = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Silent"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Silent")
    },
    teether = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Teether"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Teether")
    },
    hover = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Hover"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Hover")
    },
    spiked_host = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Spiked Host"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Spiked Host")
    },
    spiked_flesh_host = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Spiked Flesh Host"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Spiked Flesh Host")
    },
    chanter = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Chanter"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Chanter")
    },
    shade = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Shade Hand"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Shade Hand")
    },
    paracolony = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Paracolony"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Paracolony")
    },
    blood_baby = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Blood Baby"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Blood Baby")
    },
    fallen_angelic_baby = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Fallen Angelic Baby"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Fallen Angelic Baby")
    },
    queen_fly = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Queen Fly"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Queen Fly")
    },
    godleg = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Godleg"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Godleg")
    },
    marshall_pawn = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Marshall Pawn"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Marshall Pawn")
    },
    arch_bishop = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Arch Bishop"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Arch Bishop")
    },
    pooglobin = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Pooglobin"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Pooglobin")
    },
    hexstar = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Hexstar"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Hexstar")
    },
    mum = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Mum"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Mum")
    },
    the_id = {
        type = Isaac.GetEntityTypeByName("[GODMODE] The Id"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] The Id")
    },
    drifter = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Drifter"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Drifter")
    },
    parabit = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Para-Bit"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Para-Bit")
    },
    devil_lock = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Devil Lock"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Devil Lock")
    },
    stifled_gatekeeper = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Stifled Gatekeeper"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Stifled Gatekeeper")
    },
    winged_spider = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Winged Spider"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Winged Spider")
    },
    delirious_pile = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Delirious Pile"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Delirious Pile")
    },
    ludomini = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Ludomini"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Ludomini")
    },
    ratty = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Ratty"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Ratty")
    },
    infested_membrain = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Infested MemBrain"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Infested MemBrain")
    },
    wrinkled_fatty = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Wrinkly Fatty"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Wrinkly Fatty")
    },
    vengeance = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Vengeance"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Vengeance")
    },
    callen_skull = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Callen Skull"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Callen Skull")
    },
    electrite = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Electrite"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Electrite")
    },
    hushed_horf = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Hushed Horf"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Hushed Horf")
    },
    hushed_fatty = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Hushed Fatty"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Hushed Fatty")
    },
    chest_mimic = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Chest Infestor"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Chest Infestor")
    },
    hushed_clotty = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Hushed Clotty"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Hushed Clotty")
    },
    hushed_freddy = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Hushed Freddy"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Hushed Freddy")
    },
    farddy  = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Farddy"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Farddy")
    },

    swarm_one_tooth = {
        type = Isaac.GetEntityTypeByName("[GODMODE] One Tooth (Swarm)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] One Tooth (Swarm)")
    },
    swarm_fat_bat = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Fat Bat (Swarm)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Fat Bat (Swarm)")
    },

    ludomaw = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Ludomaw"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Ludomaw")
    },
    hostess = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Hostess"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Hostess")
    },
    market_man = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Market Man"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Market Man")
    },
    mimic_worm = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Mimic Worm"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Mimic Worm")
    },
    call_of_the_void = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Call of the Void"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Call of the Void")
    },
    cotv_broken_orb = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Void Soul (Call of the Void Projectile)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Void Soul (Call of the Void Projectile)"),
        subtype = 1
    },
    cotv_damage_orb = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Skeletal Soul (The Fallen Light Projectile)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Skeletal Soul (The Fallen Light Projectile)"),
        subtype = 2
    },
    bubbly_plum = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Bubbly Plum"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Bubbly Plum")
    },
    bubbly_plum_bubble_l = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Bubbly Plum Bubble (Large)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Bubbly Plum Bubble (Large)"),
        subtype = 1
    },
    bubbly_plum_bubble_s = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Bubbly Plum Bubble (Small)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Bubbly Plum Bubble (Small)"),
        subtype = 2
    },
    toxic_bubble_l = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Toxic Bubble (Large)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Toxic Bubble (Large)"),
        subtype = 3
    },
    toxic_bubble_s = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Toxic Bubble (Small)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Toxic Bubble (Small)"),
        subtype = 4
    },
    mega_worm = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Mega Worm"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Mega Worm")
    },
    blightfly = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Blightfly"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Blightfly")
    },
    bowl_play = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Bowl Play (Corny)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Bowl Play (Corny)")
    },
    outbreak = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Outbreak"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Outbreak")
    },
    bulge_bat = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Bulge Bat"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Bulge Bat")
    },
    brazier = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Brazier (Poky)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Brazier (Poky)")
    },
    error_boss = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Error Keeper (Boss)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Error Keeper (Boss)")
    },
    keepah_boss = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Keepah (Boss)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Keepah (Boss)"),
    },
    keepah_boss_head_move = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Keepah Head (Move)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Keepah Head (Move)"),
        subtype=1,
    },
    keepah_boss_head_still = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Keepah Head (Still)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Keepah Head (Still)"),
        subtype=2,
    },
    keepah_boss_head_both = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Keepah Head (Both)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Keepah Head (Both)"),
        subtype=3,
    },
    keepah_boss_head_both_alt = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Keepah Head (Both Alt)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Keepah Head (Both Alt)"),
        subtype=4,
    },
    keepah_boss_dead = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Keepah (Dead)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Keepah (Dead)"),
        subtype=5,
    },
    godmode_famine = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Famine"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Famine")
    },
    godmode_war = {
        type = Isaac.GetEntityTypeByName("[GODMODE] War"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] War")
    },
    godmode_war_no_horse = {
        type = Isaac.GetEntityTypeByName("[GODMODE] War without horse"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] War without horse")
    },
    godmode_death_horse = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Death Horse"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Death Horse")
    },
    godmode_death_no_horse = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Death without horse"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Death without horse")
    },
    godmode_death = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Death"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Death")
    },
    the_ritual = {
        type = Isaac.GetEntityTypeByName("[GODMODE] The Ritual"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] The Ritual")
    },
    ritual_candle = {
        type = Isaac.GetEntityTypeByName("[GODMODE] The Ritual's Candle"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] The Ritual's Candle"),
        subtype = 1
    },
    sacred_mind = {
        type = Isaac.GetEntityTypeByName("[GODMODE] The Sacred Mind"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] The Sacred Mind")
    },
    sacred_body = {
        type = Isaac.GetEntityTypeByName("[GODMODE] The Sacred Body"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] The Sacred Body")
    },
    sacred_soul = {
        type = Isaac.GetEntityTypeByName("[GODMODE] The Sacred Soul"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] The Sacred Soul")
    },
    souleater = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Souleater"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Souleater")
    },
    furnace_guard = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Furnace Guard"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Furnace Guard")
    },
    furnace_knight = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Furnace Knight"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Furnace Knight"),
        subtype = 1
    },
    furnace_knight_boss = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Furnace Knight (Boss)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Furnace Knight (Boss)"),
        subtype = 2
    },
    grand_marshall = {
        type = Isaac.GetEntityTypeByName("[GODMODE] The Grand Marshall"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] The Grand Marshall")
    },
    bloody_uriel = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Bloody Uriel"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Bloody Uriel")
    },
    bloody_gabriel = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Bloody Gabriel"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Bloody Gabriel")
    },
    bathemo_swarm = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Bathemo Swarm"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Bathemo Swarm")
    },
    bathemo = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Bathemo"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Bathemo")
    },
    bathemo_devote = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Bathemo Devote"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Bathemo Devote"),
        subtype = GODMODE.validate_rgon() and Isaac.GetEntitySubTypeByName("Bathemo Devote") or 1
    },
    the_collapsed = {
        type = Isaac.GetEntityTypeByName("[GODMODE] The Collapsed"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] The Collapsed")
    },
    the_collapsed_hand = {
        type = Isaac.GetEntityTypeByName("[GODMODE] The Collapsed (Hand)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] The Collapsed (Hand)"),
        subtype = 1
    },
    the_collapsed_matter = {
        type = Isaac.GetEntityTypeByName("[GODMODE] The Collapsed (Dark Matter)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] The Collapsed (Dark Matter)"),
        subtype = 2
    },
    the_fallen_light = {
        type = Isaac.GetEntityTypeByName("[GODMODE] The Fallen Light"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] The Fallen Light")
    },
    the_sign = {
        type = Isaac.GetEntityTypeByName("[GODMODE] The Sign"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] The Sign")
    },


    holy_order = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Holy Order"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Holy Order")
    },
    shatter_coin = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Shatter Coin"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Shatter Coin")
    },
    secret_light = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Secret Light"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Secret Light")
    },
    red_coin = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Red Coin"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Red Coin")
    },
    unholy_order = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Unholy Order"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Unholy Order")
    },
    crossbones_shield = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Crossbones Shield"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Crossbones Shield")
    },
    aztec_shield = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Aztec Shield"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Aztec Shield"),
        subtype = 1
    },
    snail_shield = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Snail Shield"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Snail Shield"),
        subtype = 2
    },
    heart_container = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Heart Container (Pickup)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Heart Container (Pickup)")
    },
    unlock_pedestal = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Unlock Pedestal"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Unlock Pedestal")
    },
    fruit = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Fruit (Pickup)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Fruit (Pickup)")
    },
    fatal_attraction_station = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Fatal Attraction Helper"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Fatal Attraction Helper")
    },
    gehazi_shrine = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Gehazi Shrine"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Gehazi Shrine")
    },
    soft_serve = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Soft Serve Spawner"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Soft Serve Spawner")
    },
    tear_gas_can = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Tear Gas Can"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Tear Gas Can"),
        subtype = 0
    },
    tear_gas_cloud = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Tear Gas Cloud"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Tear Gas Cloud"),
        subtype = 1
    },
    player_trail_fx = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Player Trail FX"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Player Trail FX")
    },
    crack_the_sky = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Crack The Sky (With Tell)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Crack The Sky (With Tell)")
    },
    celestial_swipe = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Celestial Swipe"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Celestial Swipe")
    },
    feather_dust = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Feather Dust"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Feather Dust"),
        subtype = 1,
    },
    temp_broken_fx = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Temp Broken Removal"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Temp Broken Removal"),
        subtype = 3,
    },
    adramolechs_fuel = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Adramolech's Fuel"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Adramolech's Fuel")
    },
    adramolechs_fuel_charged = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Adramolech's Fuel (Charged)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Adramolech's Fuel (Charged)"),
        subtype = 1,
    },
    delirious_energy = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Delirious Energy"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Delirious Energy"),
        subtype = 2,
    },
    fallen_light_crack = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Fallen Light Crack"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Fallen Light Crack"),
    },
    war_banner = {
        type = Isaac.GetEntityTypeByName("[GODMODE] War Banner"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] War Banner"),
    },
    bomb_barrel = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Bomb Barrel"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Bomb Barrel"),
    },
    papal_flame = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Papal Flame"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Papal Flame"),
    },
    golden_scale = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Golden Scale"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Golden Scale"),
    },
    silver_scale = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Silver Scale"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Silver Scale"),
        subtype = 1,
    },
    elohims_throne = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Elohim's Throne"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Elohim's Throne"),
        subtype = 0,
    },
    fake_god = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Fake God"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Fake God"),
        subtype = 1,
    },
    fallen_light_lock = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Fallen Light Lock"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Fallen Light Lock"),
        subtype = 2,
    },
    ivory_torch = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Ivory Torch"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Ivory Torch"),
        subtype = 3,
    },
    masked_angel_statue = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Masked Angel Statue"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Masked Angel Statue"),
    },
    keepah = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Keepah (Shop Parrot)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Keepah (Shop Parrot)"),
    },
    stone_beggar = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Stone Beggar"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Stone Beggar"),
    },
    palace_mural = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Lucifer's Palace Mural"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Lucifer's Palace Mural"),
    },
    ivory_portal = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Ivory Portal"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Ivory Portal"),
    },
    correction_portal = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Correction Portal"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Correction Portal"),
    },
    ooze_turret = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Ooze Turret"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Ooze Turret"),
    },
    door_hazard = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Door Hazard"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Door Hazard"),
    },
    dynamite_rock = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Dynamite Rock (Brazier)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Dynamite Rock (Brazier)"),
    },
    observatory_fx = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Observatory FX"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Observatory FX"),
    },
    correction_fx = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Correction FX"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Correction FX"),
    },
    correction_shrine = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Correction Shrine"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Correction Shrine"),
    },
    correction_hand = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Correction Hand"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Correction Hand"),
        subtype = 2,
    },
    cotv_correct = {
        type = Isaac.GetEntityTypeByName("[GODMODE] COTV (Correction Room)"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] COTV (Correction Room)"),
    },
    pill_beggar = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Pill Beggar"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Pill Beggar")
    },
    fruit_beggar = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Fruit Beggar"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Fruit Beggar")
    },
    closet_tchar = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Godmode Tainted Char"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Godmode Tainted Char")
    },
    fallen_light_bone = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Fallen Light Bone"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Fallen Light Bone")
    },
    sugar_sparkle = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Sugar Sparkle"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Sugar Sparkle"),
        subtype = 4,
    },
    blue_womb_red_lock = {
        type = Isaac.GetEntityTypeByName("[GODMODE] Blue Womb Red Door Block"),
        variant = Isaac.GetEntityVariantByName("[GODMODE] Blue Womb Red Door Block"),
    },
}

-- make sure all entities have a subtype entry
for id,ent in pairs(reg.entities) do 
    reg.entities[id].subtype = reg.entities[id].subtype or 0
end

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
    arac_head = Isaac.GetCostumeIdByPath("godmode/gfx/costumes/arac_head.anm2"),
    t_arac_head = Isaac.GetCostumeIdByPath("godmode/gfx/costumes/tainted_arac_head.anm2"),
    xaphan_head = Isaac.GetCostumeIdByPath("godmode/gfx/costumes/xaphan_head.anm2"),
    t_xaphan_head = Isaac.GetCostumeIdByPath("godmode/gfx/costumes/xaphan_head_tainted.anm2"),
    t_xaphan_eyes_0 = Isaac.GetCostumeIdByPath("godmode/gfx/costumes/xaphan_eyes_0.anm2"),
    t_xaphan_eyes = {
        Isaac.GetCostumeIdByPath("godmode/gfx/costumes/xaphan_eyes_0.anm2"),
        Isaac.GetCostumeIdByPath("godmode/gfx/costumes/xaphan_eyes_1.anm2"),
        Isaac.GetCostumeIdByPath("godmode/gfx/costumes/xaphan_eyes_2.anm2"),
        Isaac.GetCostumeIdByPath("godmode/gfx/costumes/xaphan_eyes_3.anm2"),
    },
    
    t_xaphan_body = Isaac.GetCostumeIdByPath("godmode/gfx/costumes/xaphan_body_tainted.anm2"),
    elohim_beard = Isaac.GetCostumeIdByPath("godmode/gfx/costumes/elohim_beard.anm2"),
    t_elohim_beard = Isaac.GetCostumeIdByPath("godmode/gfx/costumes/tainted_elohim_beard.anm2"),
    t_gehazi_eyes = Isaac.GetCostumeIdByPath("godmode/gfx/costumes/t_gehazi_eyes.anm2"),
    t_deli_eyes = Isaac.GetCostumeIdByPath("godmode/gfx/costumes/t_deli_eyes.anm2"),
    
    the_sign_wings = Isaac.GetCostumeIdByPath("godmode/gfx/costumes/sign_wings.anm2"),
    t_sign_body = Isaac.GetCostumeIdByPath("godmode/gfx/costumes/sign_body_t.anm2"),
    
    edible_soul = Isaac.GetCostumeIdByPath("godmode/gfx/costumes/edible_soul_bodiless.anm2"),
    maxs_head = {
        Isaac.GetCostumeIdByPath("godmode/gfx/costumes/maxs_head_1.anm2"),
        Isaac.GetCostumeIdByPath("godmode/gfx/costumes/maxs_head_2.anm2"),
        Isaac.GetCostumeIdByPath("godmode/gfx/costumes/maxs_head_3.anm2"),
        Isaac.GetCostumeIdByPath("godmode/gfx/costumes/maxs_head_4.anm2"),
        Isaac.GetCostumeIdByPath("godmode/gfx/costumes/maxs_head_5.anm2"),
    },
    wings_of_betrayal = Isaac.GetCostumeIdByPath("godmode/gfx/costumes/luc_wings.anm2"),

    celeste = Isaac.GetCostumeIdByPath("godmode/gfx/costumes/celeste.anm2"),
    celeste_guppy = Isaac.GetCostumeIdByPath("godmode/gfx/costumes/celeste_guppy.anm2"),
    cyborg = Isaac.GetCostumeIdByPath("godmode/gfx/costumes/cyborg.anm2"),
}

reg.challenges = {
    secrets = Isaac.GetChallengeIdByName("[GOD] Secrets"),
    out_of_time = Isaac.GetChallengeIdByName("[GOD] Out Of Time"),
    sugar_rush = Isaac.GetChallengeIdByName("[GOD] Sugar Rush!"),
    the_galactic_approach = Isaac.GetChallengeIdByName("[GOD] The Galactic Approach"),
    t_sign_preview = Isaac.GetChallengeIdByName("[GOD] Tainted Sign Preview!"),
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
    t_sign = Isaac.GetPlayerTypeByName("The Tainted Sign",true),   
}

reg.cards = {
    torn_page = Isaac.GetCardIdByName("Torn Page"),
    pok_8 = Isaac.GetCardIdByName("Key Cluster (8)"),
    pok_7 = Isaac.GetCardIdByName("Key Cluster (7)"),
    pok_6 = Isaac.GetCardIdByName("Key Cluster (6)"),
    pok_5 = Isaac.GetCardIdByName("Key Cluster (5)"),
    pok_4 = Isaac.GetCardIdByName("Key Cluster (4)"),
    pok_3 = Isaac.GetCardIdByName("Key Cluster (3)"),
    pok_2 = Isaac.GetCardIdByName("Key Cluster (2)"),
    soc = Isaac.GetCardIdByName("Stream of Consciousness"),
}

reg.pills = {
    opiate = Isaac.GetPillEffectByName("Opipill"),
    gild_pilled = Isaac.GetPillEffectByName("Gild Pilled!"),
    multivitamin = Isaac.GetPillEffectByName("Multivitamin!"),
    somethings_changed = Isaac.GetPillEffectByName("Something's Changed!"),
    void_calling = Isaac.GetPillEffectByName("The Void is Calling"),
}


-- used to hide godmode heart ui 
reg.hidden_heart_players = {
    [PlayerType.PLAYER_THELOST] = true,
    [PlayerType.PLAYER_THELOST_B] = true,
    [PlayerType.PLAYER_THEFORGOTTEN_B] = true,
}

reg.t_sign_familiar_tears = {
    [FamiliarVariant.INCUBUS] = true,
    [FamiliarVariant.TWISTED_BABY] = true,
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
    sacred_1 = Isaac.GetSoundIdByName("GODMODE.sacred_1"),
    sacred_2 = Isaac.GetSoundIdByName("GODMODE.sacred_2"),
    sacred_3 = Isaac.GetSoundIdByName("GODMODE.sacred_3"),
    sacred_appear = Isaac.GetSoundIdByName("GODMODE.sacred_appear"),
    red_coin = Isaac.GetSoundIdByName("GODMODE.red_coin"),
    red_coin_complete = Isaac.GetSoundIdByName("GODMODE.red_coin_complete"),
    keepah = Isaac.GetSoundIdByName("GODMODE.keepah_chirp"),
    keepah_panic = Isaac.GetSoundIdByName("GODMODE.keepah_panic"),
    ending_voiceover2 = Isaac.GetSoundIdByName("GODMODE.godmode_ending2"),
    regular_cough = Isaac.GetSoundIdByName("GODMODE.regular_cough"),
    correction_bell = Isaac.GetSoundIdByName("GODMODE.correction_bell"),
    child_blargh = Isaac.GetSoundIdByName("GODMODE.child_blargh"),
    tutorial_text = Isaac.GetSoundIdByName("GODMODE.tutorial_text"),
    meow = Isaac.GetSoundIdByName("GODMODE.meow"),
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

reg.t_deli_heart_variants = {
    [PickupVariant.PICKUP_HEART] = true,
}

reg.t_deli_delirious_heart_rates = {
    [HeartSubType.HEART_FULL] = 0.1,
    [HeartSubType.HEART_HALF] = 0.05,
    [HeartSubType.HEART_SOUL] = 0.25,
    [HeartSubType.HEART_ETERNAL] = 0.0,
    [HeartSubType.HEART_DOUBLEPACK] = 0.2,
    [HeartSubType.HEART_BLACK] = 0.5,
    [HeartSubType.HEART_GOLDEN] = 0.0,
    [HeartSubType.HEART_HALF_SOUL] = 0.125,
    [HeartSubType.HEART_SCARED] = 0.1,
    [HeartSubType.HEART_BLENDED] = 0.175,
    [HeartSubType.HEART_BONE] = 0.0,
    [HeartSubType.HEART_ROTTEN] = 0.025,
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
        t_sign = Isaac.GetAchievementIdByName("GODMODE_TSign"),

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
            char_sprite = "godmode/gfx/characters/arac_tainted/arac_black.png",
            unlock = reg.players.t_recluse,
            achievement = reg.achievements.t_recluse,
            as = reg.players.recluse,
        },
        [reg.players.xaphan] = {
            char_sprite = "godmode/gfx/characters/xaphan_tainted/xaphan_grey.png",
            unlock = reg.players.t_xaphan,
            achievement = reg.achievements.t_xaphan,
            as = reg.players.xaphan,
        },
        [reg.players.deli] = {
            char_sprite = "godmode/gfx/characters/deli_tainted/deli_white.png",
            unlock = reg.players.t_deli,
            achievement = reg.achievements.t_deli,
            as = reg.players.deli,
        },
        [reg.players.elohim] = {
            char_sprite = "godmode/gfx/characters/elohim_tainted/elohim.png",
            unlock = reg.players.t_elohim,
            achievement = reg.achievements.t_elohim,
            as = reg.players.elohim,
        },
        [reg.players.gehazi] = {
            char_sprite = "godmode/gfx/characters/gehazi_tainted/gideon_green.png",
            unlock = reg.players.t_gehazi,
            achievement = reg.achievements.t_gehazi,
            as = reg.players.gehazi,
        },
    }
end

return reg