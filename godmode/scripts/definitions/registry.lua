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
    flying_pan = Isaac.GetItemIdByName("Flying Pan"),

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
        name = "[GODMODE] Burnt Page",
    },
    pair_of_cans = {
        name = "[GODMODE] Pair of Cans",
    },
    hush_cannon = {
        name = "[GODMODE] Hush Cannon",
    },
    chigger = {
        name = "[GODMODE] Chigger",
    },
    holy_chalice = {
        name = "[GODMODE] Holy Chalice",
    },
    diya = {
        name = "[GODMODE] Diya Candle",
    },
    ritual_familiar = {
        name = "[GODMODE] Ritual Candle (Familiar)",
    },
    fallen_guard_familiar = {
        name = "[GODMODE] Fallen Guard (Familiar)",
    },
    late_delivery = {
        name = "[GODMODE] Late Delivery",
    },
    fruit_fly = {
        name = "[GODMODE] Fruit Fly",
    },
    sign_flame = {
        name = "[GODMODE] The Sign's Flame",
    },
    deli_halo = {
        name = "[GODMODE] Delirious Halo",
    },
    deli_eye = {
        name = "[GODMODE] Delirious Eye",
    },
    vengeful_dagger = {
        name = "[GODMODE] Vengeful Dagger",
    },
    hellfiah_familiar = {
        name = "[GODMODE] Hellfiah",
    },
    cursed_snail = {
        name = "[GODMODE] Cursed Snail",
    },
    loded_sack = {
        name = "[GODMODE] Loded Sack",
    },
    flying_pan = {
        name = "[GODMODE] Flying Pan",
    },

    opia_soul = {
        name = "[GODMODE] Opia Soul",
    },
    hot_potato_tear = {
        name = "[GODMODE] Hot Potato Tear",
    },
    hot_potato_tear_chunk = {
        name = "[GODMODE] Hot Potato Tear Chunk",
    },


    nerve_cluster = {
        name = "[GODMODE] Nerve Cluster",
    },
    hostess_cluster = {
        name = "[GODMODE] Hostess Cluster",
        subtype = 1
    },
    guard_of_the_father = {
        name = "[GODMODE] Guard of the Father",
    },
    blind_spider = {
        name = "[GODMODE] Blind Spider",
    },
    dream = {
        name = "[GODMODE] Dream",
    },
    trailer = {
        name = "[GODMODE] Trailer",
    },
    grubby = {
        name = "[GODMODE] Grubby",
    },
    cluster = {
        name = "[GODMODE] Cluster",
    },
    harf = {
        name = "[GODMODE] Harf",
    },
    purple_heart = {
        name = "[GODMODE] Purple Heart",
    },
    fetal_baby = {
        name = "[GODMODE] Fetal Baby",
    },
    planter = {
        name = "[GODMODE] Planter",
    },
    slammer = {
        name = "[GODMODE] Slammer",
    },
    big_dipper = {
        name = "[GODMODE] Big Dipper",
    },
    barfer = {
        name = "[GODMODE] Barfer",
    },
    dial = {
        name = "[GODMODE] Dial",
    },
    guarded = {
        name = "[GODMODE] Guarded",
    },
    silent = {
        name = "[GODMODE] Silent",
    },
    teether = {
        name = "[GODMODE] Teether",
    },
    hover = {
        name = "[GODMODE] Hover",
    },
    spiked_host = {
        name = "[GODMODE] Spiked Host",
    },
    spiked_flesh_host = {
        name = "[GODMODE] Spiked Flesh Host",
    },
    chanter = {
        name = "[GODMODE] Chanter",
    },
    shade = {
        name = "[GODMODE] Shade Hand",
    },
    paracolony = {
        name = "[GODMODE] Paracolony",
    },
    blood_baby = {
        name = "[GODMODE] Blood Baby",
    },
    fallen_angelic_baby = {
        name = "[GODMODE] Fallen Angelic Baby",
    },
    queen_fly = {
        name = "[GODMODE] Queen Fly",
    },
    godleg = {
        name = "[GODMODE] Godleg",
    },
    marshall_pawn = {
        name = "[GODMODE] Marshall Pawn",
    },
    arch_bishop = {
        name = "[GODMODE] Arch Bishop",
    },
    pooglobin = {
        name = "[GODMODE] Pooglobin",
    },
    hexstar = {
        name = "[GODMODE] Hexstar",
    },
    mum = {
        name = "[GODMODE] Mum",
    },
    the_id = {
        name = "[GODMODE] The Id",
    },
    drifter = {
        name = "[GODMODE] Drifter",
    },
    parabit = {
        name = "[GODMODE] Para-Bit",
    },
    devil_lock = {
        name = "[GODMODE] Devil Lock",
    },
    stifled_gatekeeper = {
        name = "[GODMODE] Stifled Gatekeeper",
    },
    winged_spider = {
        name = "[GODMODE] Winged Spider",
    },
    delirious_pile = {
        name = "[GODMODE] Delirious Pile",
    },
    ludomini = {
        name = "[GODMODE] Ludomini",
    },
    ratty = {
        name = "[GODMODE] Ratty",
    },
    infested_membrain = {
        name = "[GODMODE] Infested MemBrain",
    },
    wrinkled_fatty = {
        name = "[GODMODE] Wrinkly Fatty",
    },
    vengeance = {
        name = "[GODMODE] Vengeance",
    },
    callen_skull = {
        name = "[GODMODE] Callen Skull",
    },
    biggest_star = {
        name = "[GODMODE] Biggest Star",
    },
    electrite = {
        name = "[GODMODE] Electrite",
    },
    hushed_horf = {
        name = "[GODMODE] Hushed Horf",
    },
    hushed_fatty = {
        name = "[GODMODE] Hushed Fatty",
    },
    chest_mimic = {
        name = "[GODMODE] Chest Infestor",
    },
    hushed_clotty = {
        name = "[GODMODE] Hushed Clotty",
    },
    hushed_freddy = {
        name = "[GODMODE] Hushed Freddy",
    },
    farddy  = {
        name = "[GODMODE] Farddy",
    },

    swarm_one_tooth = {
        name = "[GODMODE] One Tooth (Swarm)",
    },
    swarm_fat_bat = {
        name = "[GODMODE] Fat Bat (Swarm)",
    },

    ludomaw = {
        name = "[GODMODE] Ludomaw",
    },
    hostess = {
        name = "[GODMODE] Hostess",
    },
    market_man = {
        name = "[GODMODE] Market Man",
    },
    mimic_worm = {
        name = "[GODMODE] Mimic Worm",
    },
    call_of_the_void = {
        name = "[GODMODE] Call of the Void",
    },
    cotv_broken_orb = {
        name = "[GODMODE] Void Soul (Call of the Void Projectile)",
        subtype = 1
    },
    cotv_damage_orb = {
        name = "[GODMODE] Skeletal Soul (The Fallen Light Projectile)",
        subtype = 2
    },
    bubbly_plum = {
        name = "[GODMODE] Bubbly Plum",
    },
    bubbly_plum_bubble_l = {
        name = "[GODMODE] Bubbly Plum Bubble (Large)",
        subtype = 1
    },
    bubbly_plum_bubble_s = {
        name = "[GODMODE] Bubbly Plum Bubble (Small)",
        subtype = 2
    },
    toxic_bubble_l = {
        name = "[GODMODE] Toxic Bubble (Large)",
        subtype = 3
    },
    toxic_bubble_s = {
        name = "[GODMODE] Toxic Bubble (Small)",
        subtype = 4
    },
    mega_worm = {
        name = "[GODMODE] Mega Worm",
    },
    blightfly = {
        name = "[GODMODE] Blightfly",
    },
    bowl_play = {
        name = "[GODMODE] Bowl Play (Corny)",
    },
    outbreak = {
        name = "[GODMODE] Outbreak",
    },
    bulge_bat = {
        name = "[GODMODE] Bulge Bat",
    },
    brazier = {
        name = "[GODMODE] Brazier (Poky)",
    },
    error_boss = {
        name = "[GODMODE] Error Keeper (Boss)",
    },
    keepah_boss = {
        name = "[GODMODE] Keepah (Boss)",
    },
    keepah_boss_head_move = {
        name = "[GODMODE] Keepah Head (Move)",
        subtype=1,
    },
    keepah_boss_head_still = {
        name = "[GODMODE] Keepah Head (Still)",
        subtype=2,
    },
    keepah_boss_head_both = {
        name = "[GODMODE] Keepah Head (Both)",
        subtype=3,
    },
    keepah_boss_head_both_alt = {
        name = "[GODMODE] Keepah Head (Both Alt)",
        subtype=4,
    },
    keepah_boss_dead = {
        name = "[GODMODE] Keepah (Dead)",
        subtype=5,
    },
    godmode_famine = {
        name = "[GODMODE] Famine",
    },
    godmode_war = {
        name = "[GODMODE] War",
    },
    godmode_war_no_horse = {
        name = "[GODMODE] War without horse",
    },
    godmode_death_horse = {
        name = "[GODMODE] Death Horse",
    },
    godmode_death_no_horse = {
        name = "[GODMODE] Death without horse",
    },
    godmode_death = {
        name = "[GODMODE] Death",
    },
    the_ritual = {
        name = "[GODMODE] The Ritual",
    },
    ritual_candle = {
        name = "[GODMODE] The Ritual's Candle",
        subtype = 1
    },
    sacred_mind = {
        name = "[GODMODE] The Sacred Mind",
    },
    sacred_body = {
        name = "[GODMODE] The Sacred Body",
    },
    sacred_soul = {
        name = "[GODMODE] The Sacred Soul",
    },
    souleater = {
        name = "[GODMODE] Souleater",
    },
    furnace_guard = {
        name = "[GODMODE] Furnace Guard",
    },
    furnace_knight = {
        name = "[GODMODE] Furnace Knight",
        subtype = 1
    },
    furnace_knight_boss = {
        name = "[GODMODE] Furnace Knight (Boss)",
        subtype = 2
    },
    grand_marshall = {
        name = "[GODMODE] The Grand Marshall",
    },
    bloody_uriel = {
        name = "[GODMODE] Bloody Uriel",
    },
    bloody_gabriel = {
        name = "[GODMODE] Bloody Gabriel",
    },
    bathemo_swarm = {
        name = "[GODMODE] Bathemo Swarm",
    },
    bathemo = {
        name = "[GODMODE] Bathemo",
    },
    bathemo_devote = {
        name = "[GODMODE] Bathemo Devote",
        subtype = 1
    },
    the_collapsed = {
        name = "[GODMODE] The Collapsed",
    },
    the_collapsed_hand = {
        name = "[GODMODE] The Collapsed (Hand)",
        subtype = 1
    },
    the_collapsed_matter = {
        name = "[GODMODE] The Collapsed (Dark Matter)",
        subtype = 2
    },
    the_fallen_light = {
        name = "[GODMODE] The Fallen Light",
    },
    the_sign = {
        name = "[GODMODE] The Sign",
    },


    holy_order = {
        name = "[GODMODE] Holy Order",
    },
    shatter_coin = {
        name = "[GODMODE] Shatter Coin",
    },
    secret_light = {
        name = "[GODMODE] Secret Light",
    },
    red_coin = {
        name = "[GODMODE] Red Coin",
    },
    unholy_order = {
        name = "[GODMODE] Unholy Order",
    },
    crossbones_shield = {
        name = "[GODMODE] Crossbones Shield",
    },
    aztec_shield = {
        name = "[GODMODE] Aztec Shield",
        subtype = 1
    },
    snail_shield = {
        name = "[GODMODE] Snail Shield",
        subtype = 2
    },
    heart_container = {
        name = "[GODMODE] Heart Container (Pickup)",
    },
    unlock_pedestal = {
        name = "[GODMODE] Unlock Pedestal",
    },
    fruit = {
        name = "[GODMODE] Fruit (Pickup)",
    },
    fatal_attraction_station = {
        name = "[GODMODE] Fatal Attraction Helper",
    },
    gehazi_shrine = {
        name = "[GODMODE] Gehazi Shrine",
    },
    soft_serve = {
        name = "[GODMODE] Soft Serve Spawner",
    },
    tear_gas_can = {
        name = "[GODMODE] Tear Gas Can",
        subtype = 0
    },
    tear_gas_cloud = {
        name = "[GODMODE] Tear Gas Cloud",
        subtype = 1
    },
    player_trail_fx = {
        name = "[GODMODE] Player Trail FX",
    },
    crack_the_sky = {
        name = "[GODMODE] Crack The Sky (With Tell)",
    },
    celestial_swipe = {
        name = "[GODMODE] Celestial Swipe",
    },
    feather_dust = {
        name = "[GODMODE] Feather Dust",
        subtype = 1,
    },
    temp_broken_fx = {
        name = "[GODMODE] Temp Broken Removal",
        subtype = 3,
    },
    adramolechs_fuel = {
        name = "[GODMODE] Adramolech's Fuel",
    },
    adramolechs_fuel_charged = {
        name = "[GODMODE] Adramolech's Fuel (Charged)",
        subtype = 1,
    },
    delirious_energy = {
        name = "[GODMODE] Delirious Energy",
        subtype = 2,
    },
    fallen_light_crack = {
        name = "[GODMODE] Fallen Light Crack",
    },
    war_banner = {
        name = "[GODMODE] War Banner",
    },
    bomb_barrel = {
        name = "[GODMODE] Bomb Barrel",
    },
    papal_flame = {
        name = "[GODMODE] Papal Flame",
    },
    golden_scale = {
        name = "[GODMODE] Golden Scale",
    },
    silver_scale = {
        name = "[GODMODE] Silver Scale",
        subtype = 1,
    },
    elohims_throne = {
        name = "[GODMODE] Elohim's Throne",
        subtype = 0,
    },
    fake_god = {
        name = "[GODMODE] Fake God",
        subtype = 1,
    },
    fallen_light_lock = {
        name = "[GODMODE] Fallen Light Lock",
        subtype = 2,
    },
    ivory_torch = {
        name = "[GODMODE] Ivory Torch",
        subtype = 3,
    },
    masked_angel_statue = {
        name = "[GODMODE] Masked Angel Statue",
    },
    keepah = {
        name = "[GODMODE] Keepah (Shop Parrot)",
    },
    stone_beggar = {
        name = "[GODMODE] Stone Beggar",
    },
    palace_mural = {
        name = "[GODMODE] Lucifer's Palace Mural",
    },
    ivory_portal = {
        name = "[GODMODE] Ivory Portal",
    },
    correction_portal = {
        name = "[GODMODE] Correction Portal",
    },
    ooze_turret = {
        name = "[GODMODE] Ooze Turret",
    },
    door_hazard = {
        name = "[GODMODE] Door Hazard",
    },
    dynamite_rock = {
        name = "[GODMODE] Dynamite Rock (Brazier)",
    },
    observatory_fx = {
        name = "[GODMODE] Observatory FX",
    },
    correction_fx = {
        name = "[GODMODE] Correction FX",
    },
    correction_shrine = {
        name = "[GODMODE] Correction Shrine",
    },
    correction_hand = {
        name = "[GODMODE] Correction Hand",
        subtype = 2,
    },
    cotv_correct = {
        name = "[GODMODE] COTV (Correction Room)",
    },
    cotv_correct_cacklefade = {
        name = "[GODMODE] COTV (Correction Room)",
        subtype = 1,
    },
    pill_beggar = {
        name = "[GODMODE] Pill Beggar",
    },
    fruit_beggar = {
        name = "[GODMODE] Fruit Beggar",
    },
    closet_tchar = {
        name = "[GODMODE] Godmode Tainted Char",
    },
    fallen_light_bone = {
        name = "[GODMODE] Fallen Light Bone",
    },
    sugar_sparkle = {
        name = "[GODMODE] Sugar Sparkle",
        subtype = 4,
    },
    blue_womb_red_lock = {
        name = "[GODMODE] Blue Womb Red Door Block",
    },
}


-- flush all entity entries based on their XML name 
for id,ent in pairs(reg.entities) do 
    local type,var,sub = Isaac.GetEntityTypeByName(ent.name), Isaac.GetEntityVariantByName(ent.name), (GODMODE.validate_rgon() and Isaac.GetEntitySubTypeByName(ent.name) or (ent.subtype or 0))
    reg.entities[id].type = type
    reg.entities[id].variant = var
    reg.entities[id].subtype = sub
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

reg.t_sign_tearflag_blacklist_pre = {
    [TearFlags.TEAR_CHAIN] = true,
    [TearFlags.TEAR_SAD_BOMB] = true,
    [TearFlags.TEAR_BUTT_BOMB] = true,
    [TearFlags.TEAR_GLITTER_BOMB] = true,
    [TearFlags.TEAR_SCATTER_BOMB] = true,
    [TearFlags.TEAR_CROSS_BOMB] = true,
    [TearFlags.TEAR_GHOST_BOMB] = true,
    [TearFlags.TEAR_GOLDEN_BOMB] = true,
    [TearFlags.TEAR_FAST_BOMB] = true,
    [TearFlags.TEAR_GIGA_BOMB] = true,
    [TearFlags.TEAR_CHAIN] = true,
}

for flag,_ in pairs(reg.t_sign_tearflag_blacklist_pre) do 
    reg.t_sign_tearflag_blacklist = (reg.t_sign_tearflag_blacklist or flag) & flag 
end

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
    -- twinkles = Isaac.GetMusicIdByName("GODMODE Twinkles of a Last Thought"),
    ending_voiceover2 = Isaac.GetMusicIdByName("GODMODE_EndingVoiceover2"),
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
    -- ending_voiceover2 = Isaac.GetSoundIdByName("GODMODE.godmode_ending2"),
    regular_cough = Isaac.GetSoundIdByName("GODMODE.regular_cough"),
    correction_bell = Isaac.GetSoundIdByName("GODMODE.correction_bell"),
    child_blargh = Isaac.GetSoundIdByName("GODMODE.child_blargh"),
    tutorial_text = Isaac.GetSoundIdByName("GODMODE.tutorial_text"),
    meow = Isaac.GetSoundIdByName("GODMODE.meow"),
    flying_pan = Isaac.GetSoundIdByName("GODMODE.flying_pan"),
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

-- new door hazard system! each stage has a unique door hazard, a few have a couple hazards, the void has a unique one + ALL hazards! 

reg.door_hazard_variants = {
    ["DoorTears"] = {},
    ["DoorWebBlueFly"] = {},
    ["DoorFire"] = {},
    ["DoorWaterPipe"] = {},
    ["DoorVineGrapes"] = {},
    ["DoorVineSpikes"] = {},
    ["DoorVineRoots"] = {},
    ["DoorDust"] = {},
    ["DoorAlgae"] = {},
    ["DoorHammerTrap"] = {},
    ["DoorGhosts"] = {},
    ["DoorLantern"] = {},
    ["DoorTar"] = {},
    ["DoorBlood"] = {},
    ["DoorWeb"] = {},
    ["DoorWebEgg"] = {},
    ["DoorWombMouth"] = {},
    ["DoorWombTube"] = {},
    ["DoorWombSpikes"] = {},
    ["DoorWombScabs"] = {},
    ["DoorGasBag"] = {},
    ["DoorLight"] = {},
    ["DoorShadow"] = {},
    ["DoorCallen"] = {},
    ["DoorMagma"] = {},
    ["DoorShadowCOTV"] = {},
    ["DoorPortal"] = {},
}

reg.stage_door_hazard_lists = {
    ["1"..StageType.STAGETYPE_ORIGINAL] = {{weight=1,entry="DoorTears"},},
    ["1"..StageType.STAGETYPE_WOTL] = {{weight=1,entry="DoorWebBlueFly"},},
    ["1"..StageType.STAGETYPE_AFTERBIRTH] = {{weight=1,entry="DoorFire"},},
    ["1"..StageType.STAGETYPE_REPENTANCE] = {{weight=1,entry="DoorWaterPipe"},{weight=1,entry="DoorTears"},},
    ["FruitCellar"] = {{weight=1,entry="DoorVineGrapes"},{weight=1,entry="DoorVineSpikes"}},

    ["2"..StageType.STAGETYPE_ORIGINAL] = {{weight=1,entry="DoorVineRoots"},},
    ["2"..StageType.STAGETYPE_WOTL] = {{weight=1,entry="DoorDust"},},
    ["2"..StageType.STAGETYPE_AFTERBIRTH] = {{weight=1,entry="DoorAlgae"},},
    ["2"..StageType.STAGETYPE_REPENTANCE] = {{weight=1,entry="DoorHammerTrap"},{weight=3,entry="DoorAlgae"},},

    ["3"..StageType.STAGETYPE_ORIGINAL] = {{weight=1,entry="DoorGhosts"},},
    ["3"..StageType.STAGETYPE_WOTL] = {{weight=1,entry="DoorLantern"},},
    ["3"..StageType.STAGETYPE_AFTERBIRTH] = {{weight=1,entry="DoorTar"},},
    ["3"..StageType.STAGETYPE_REPENTANCE] = {{weight=1,entry="DoorBlood"},},
    ["TheNest"] = {
        {weight=0.5,entry="DoorWebBlueFly"},
        {weight=1,entry="DoorWeb"},
        {weight=0.25,entry="DoorWebEgg"},
    },

    ["4"..StageType.STAGETYPE_ORIGINAL] = {
        {weight=1,entry="DoorWombMouth"},
        {weight=0.5,entry="DoorWombTube"},
        {weight=0.25,entry="DoorWombSpikes"},
        {weight=0.25,entry="DoorWombScabs"},
    },
    ["4"..StageType.STAGETYPE_WOTL] = {
        {weight=1,entry="DoorWombSpikes"},
        {weight=0.5,entry="DoorWombScabs"},
        {weight=0.25,entry="DoorWombMouth"},
        {weight=0.25,entry="DoorWombTube"},
    },
    ["4"..StageType.STAGETYPE_AFTERBIRTH] = {
        {weight=1,entry="DoorWombScabs"},
        {weight=0.5,entry="DoorWombMouth"},
    },
    ["4"..StageType.STAGETYPE_REPENTANCE] = {{weight=1,entry="DoorGasBag"},{weight=1,entry="DoorWombScabs"},{weight=1,entry="DoorWombSpikes"},},
    ["Colon"] = {
        {weight=1,entry="DoorWombTube"},
        {weight=0.5,entry="DoorWombSpikes"},
        {weight=0.25,entry="DoorWombMouth"},
        {weight=0.25,entry="DoorWombScabs"},
    },

    ["5"..StageType.STAGETYPE_ORIGINAL] = {{weight=1,entry="DoorLight"},},
    ["5"..StageType.STAGETYPE_WOTL] = {{weight=1,entry="DoorShadow"},},

    ["6"..StageType.STAGETYPE_ORIGINAL] = {{weight=1,entry="DoorCallen"},},
    ["6"..StageType.STAGETYPE_WOTL] = {{weight=1,entry="DoorMagma"},},
    ["IvoryPalace"] = {{weight=1,entry="DoorShadowCOTV"},},

    ["7"..StageType.STAGETYPE_ORIGINAL] = {
        {weight=3,entry="DoorPortal"},
        {weight=1,entry="DoorShadowCOTV"},
        {weight=1,entry="DoorMagma"},
        {weight=0.75,entry="DoorCallen"},
        {weight=0.75,entry="DoorShadow"},
        {weight=1,entry="DoorLight"},
        {weight=0.75,entry="DoorWombTube"},
        {weight=0.75,entry="DoorWombSpikes"},
        {weight=0.75,entry="DoorWombMouth"},
        {weight=0.75,entry="DoorWombScabs"},
        {weight=1.25,entry="DoorWeb"},
        {weight=1,entry="DoorWebEgg"},
        {weight=0.75,entry="DoorBlood"},
        {weight=0.75,entry="DoorTar"},
        {weight=1,entry="DoorLantern"},
        {weight=0.75,entry="DoorGhosts"},
        {weight=0.75,entry="DoorHammerTrap"},
        {weight=1,entry="DoorAlgae"},
        {weight=0.75,entry="DoorDust"},
        {weight=0.75,entry="DoorVineRoots"},
        {weight=1,entry="DoorVineGrapes"},
        {weight=0.75,entry="DoorVineSpikes"},
        {weight=0.75,entry="DoorWaterPipe"},
        {weight=1,entry="DoorFire"},
        {weight=1,entry="DoorWebBlueFly"},
        {weight=0.75,entry="DoorTears"},
    },
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