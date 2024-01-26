battlePassLevelExperience = {
    [1]  = 10, [2]  = 40, [3]  = 70, [4]  = 100, [5]  = 130, [6]  = 160, [7]  = 190, [8]  = 220, [9]  = 250, [10] = 280,
    [11] = 310, [12] = 340, [13] = 370, [14] = 400, [15] = 430, [16] = 460, [17] = 490, [18] = 520, [19] = 550, [20] = 580,
    [21] = 610, [22] = 640, [23] = 670, [24] = 700, [25] = 730, [26] = 760, [27] = 790, [28] = 820, [29] = 850, [30] = 880,
}
local choice = {
    soul = {"item_forest_soul","item_village_soul","item_mines_soul","item_dust_soul","item_cemetery_soul","item_swamp_soul","item_snow_soul","item_divine_soul"},
    item_scroll1 = {"scroll_13","scroll_14","scroll_15"},
    item_scroll2 = {"scroll_1","scroll_2","scroll_3","scroll_4","scroll_5","scroll_6","scroll_13","scroll_14","scroll_15"},
    hero_access = {"hero_silencer_trial","hero_marci_trial"},
    treasury = {"treasurie1","treasurie2","treasurie3"},
    pet_access150 = {"pet_1","pet_2","pet_3","pet_4","pet_10","pet_11","pet_12"},
    pet_access250 = {"pet_16","pet_17","pet_18","pet_19","pet_20","pet_21","pet_22","pet_23","pet_24","pet_25"},
    experience_choice = {"experience_common","experience_golden"},
    boss_summon_ticket = {"scroll_12","scroll_11"},
}
battlePassRewards = {
    free = {
        [1] = { reward_type = "boost_experience", rarity = "common", data = { value = 1.25, display_value = "x1.25", game_count = 5}} ,
        [2] = { reward_type = "boost_rp", rarity = "common", data = { value = 1.25, display_value = "x1.25", game_count = 5 }} ,
        [3] = { reward_type = "gems", rarity = "common", data = { value = 2500, display_value = "+2500" }},
        [4] = { reward_type = "experience_common", rarity = "common", data = { value = 2500, display_value = "+2500" }},
        [5] = { reward_type = "hero_access", rarity = "rare", data = { game_count = 1, display_value = "1", choice = choice.hero_access, choice_count = 1 }},
        [6] = { reward_type = "treasury", rarity = "common", data = { value = 1, display_value = "2", choice = choice.treasury, choice_count = 2 }},
        [7] = { reward_type = "rp", rarity = "common", data = { value = 250, display_value = "+250" }},
        [8] = { reward_type = "pet_access150", rarity = "common", data = { price = 150, display_value = "10", choice = choice.pet_access150, choice_count = 1, value = 13501, game_count = 10 }},
        [9] = { reward_type = "effect", rarity = "common", data = { display_value = "" } },
        [10] = { reward_type = "item_scroll1", rarity = "rare", data = { value = 1, display_value = "2", choice = choice.item_scroll1, choice_count = 2 } },
        [11] = { reward_type = "boost_experience", rarity = "common", data = { value = 1.5, display_value = "x1.5", game_count = 5 }},
        [12] = { reward_type = "boost_rp", rarity = "uncommon", data = { value = 1.5, display_value = "x1.5", game_count = 5 }},
        [13] = { reward_type = "gems", rarity = "uncommon", data = { value = 5000, display_value = "+5000" }},
        [14] = { reward_type = "experience_common", rarity = "uncommon", data = { value = 5000, display_value = "+5000" }},
        [15] = { reward_type = "hero_access", rarity = "rare", data = { game_count = 3, display_value = "3", choice = choice.hero_access, choice_count = 1 }},
        [16] = { reward_type = "treasury", rarity = "common", data = { value = 2, display_value = "4", choice = choice.treasury, choice_count = 2 }},
        [17] = { reward_type = "coins", rarity = "uncommon", data = { value = 2, display_value = "+2" }},
        [18] = { reward_type = "pet_access150", rarity = "common", data = { price = 150, display_value = "10", choice = choice.pet_access150, choice_count = 1, value = 13501, game_count = 10 }},
        [19] = { reward_type = "effect", rarity = "uncommon", data = { display_value = "" } },
        [20] = { reward_type = "item_scroll1", rarity = "uncommon", data = { value = 1, display_value = "2", choice = choice.item_scroll1, choice_count = 2 } },
        [21] = { reward_type = "boost_experience", rarity = "common", data = { value = 1.75, display_value = "x1.75", game_count = 5 }},
        [22] = { reward_type = "boost_rp", rarity = "common", data = { value = 1.75, display_value = "x1.75", game_count = 5 }},
        [23] = { reward_type = "gems", rarity = "uncommon", data = { value = 8000, display_value = "+8000" }},
        [24] = { reward_type = "experience_common", rarity = "common", data = { value = 18000, display_value = "+18000" }},
        [25] = { reward_type = "hero_access", rarity = "rare", data = { game_count = 5, display_value = "5", choice = choice.hero_access, choice_count = 1 }},
        [26] = { reward_type = "treasury", rarity = "common", data = { value = 2, display_value = "6", choice = choice.treasury, choice_count = 3 }},
        [27] = { reward_type = "coins", rarity = "uncommon", data = { value = 3, display_value = "+3" }},
        [28] = { reward_type = "pet_access150", rarity = "common", data = { price = 150, display_value = "10", choice = choice.pet_access150, choice_count = 1, value = 13501, game_count = 10 }},
        [29] = { reward_type = "effect", rarity = "uncommon", data = { display_value = "" } },
        [30] = { reward_type = "golden_branch", rarity = "uncommon", data = {duration_in_days = 5,display_value = "5", days_count = 5} },
    },
    premium = {
        [1] = { reward_type = "boost_experience", rarity = "uncommon", data = {value = 2.0, display_value = "x2.0", game_count = 5} },
        [2] = { reward_type = "boost_rp", rarity = "uncommon", data = {value = 2.0, display_value = "x2.0", game_count = 5} },
        [3] = { reward_type = "gems", rarity = "common", data = {value = 5000, display_value = "+5000"} },
        [4] = { reward_type = "experience_choice", rarity = "common", data = {value = 5000,display_value = "+5000",choice = choice.experience_choice, choice_count = 2 } }, --{, { reward_type = "experience_golden", rarity = "common", data = {value = 5000,display_value = "+5000"} }},
        [5] = { reward_type = "item_scroll2", rarity = "common", data = { value = 1, display_value = "3", choice = choice.item_scroll2, choice_count = 3 } },
        [6] = { reward_type = "soul", rarity = "common", data = { display_value = "1",  choice = choice.soul, choice_count = 1, days_count = 10 } },
        [7] = { reward_type = "rp", rarity = "common", data = {value = 500, display_value = "+500"} },
        [8] = { reward_type = "pet_access250", rarity = "common", data = { price = 250, display_value = "10", choice = choice.pet_access250, choice_count = 1, value = 13501, game_count = 10 } },
        [9] = { reward_type = "effect", rarity = "common", data = { display_value = "" } },
        [10] = { reward_type = "hero_buff", rarity = "common", data = { display_value = "" } },
        [11] = { reward_type = "boost_experience", rarity = "common", data = { value = 2.25, display_value = "x2.25", game_count = 5 }},
        [12] = { reward_type = "boost_rp", rarity = "common", data = { value = 2.25, display_value = "x2.25", game_count = 5 }},
        [13] = { reward_type = "gems", rarity = "common", data = {value = 10000, display_value = "+10000"} },
        [14] = { reward_type = "experience_choice", rarity = "common", data = {value = 18000,display_value = "+18000",choice = choice.experience_choice, choice_count = 2 } }, --{, { reward_type = "experience_golden", rarity = "common", data = {value = 18000,display_value = "+18000"} }},
        [15] = { reward_type = "item_forever_ward", rarity = "uncommon", data = { value = 1,display_value = "1", name = 'other_49' }},
        [16] = { reward_type = "soul", rarity = "common", data = { value = 1, display_value = "1", choice = choice.soul, choice_count = 1, days_count = 15 } },
        [17] = { reward_type = "item_scroll2", rarity = "common", data = { value = 1, display_value = "2", choice = choice.item_scroll2, choice_count = 2 } },
        [18] = { reward_type = "pet_access250", rarity = "common", data = { price = 250, display_value = "10", choice = choice.pet_access250, choice_count = 1, value = 13501, game_count = 10 } },
        [19] = { reward_type = "effect", rarity = "common", data = { display_value = "" } },
        [20] = { reward_type = "hero_buff", rarity = "common", data = { display_value = "" } },
        [21] = { reward_type = "boost_experience", rarity = "common", data = { value = 2.5, display_value = "x2.5", game_count = 5 }},
        [22] = { reward_type = "boost_rp", rarity = "common", data = { value = 2.5, display_value = "x2.5", game_count = 5 }},
        [23] = { reward_type = "gems", rarity = "common", data = {value = 15000, display_value = "+15000"} },
        [24] = { reward_type = "experience_choice", rarity = "common", data = {value = 18000,display_value = "+18000",choice = choice.experience_choice, choice_count = 2 } }, --{, { reward_type = "experience_golden", rarity = "common", data = {value = 18000,display_value = "+18000"} }},
        [25] = { reward_type = "boss_summon_ticket", rarity = "common", data = { value = 3,display_value = "3/10", choice = choice.boss_summon_ticket, choice_count = 2 }}, --{,{ reward_type = "item_ticket", rarity = "common", data = { value = 10,display_value = "10",item_name = "item_ticket" }}},
        [26] = { reward_type = "soul", rarity = "legendary", data = { value = 1, display_value = "1", choice = choice.soul, choice_count = 1, days_count = 20 } },
        [27] = { reward_type = "effect", rarity = "common", data = { display_value = "" } },
        [28] = { reward_type = "pet_access250", rarity = "common", data = { price = 250, display_value = "10", choice = choice.pet_access250, choice_count = 1, value = 13501, game_count = 10 } },
        [29] = { reward_type = "pet_exclusive", rarity = "uncommon", data = { amount = 1, display_value = "1" }},
        [30] = { reward_type = "hero_buff", rarity = "common", data = { display_value = "" } },
    }
}