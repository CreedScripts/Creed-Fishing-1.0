Config = {}

-- List of possible items for normal fishing
Config.NormalFishingItems = {
    { item = "salmon", chance = 15 },
    { item = "tailor", chance = 30 },
    { item = "flathead", chance = 40 },
    { item = "bream", chance = 30 },
    { item = "whiting", chance = 20 },
    { item = "snapper", chance = 15 },
    { item = "mullet", chance = 20 }
}

-- List of possible items for deep sea fishing
Config.DeepSeaFishingItems = {
    { item = "shark", chance = 25 },         
    { item = "viperfish", chance = 20 },     
    { item = "squid", chance = 40 },         
    { item = "lanternfish", chance = 10 },   
    { item = "hatchetfish", chance = 20 },   
    { item = "message_in_a_bottle", chance = 5 } 
}


Config.FishingAnimation = {
    dict = 'amb@world_human_stand_fishing@base',
    anim = 'base',
    flag = 49
}

-- Sell prices for fish items
Config.SellPrices = {
    { item = "salmon", price = 200 },
    { item = "tailor", price = 100 },
    { item = "flathead", price = 75 },
    { item = "bream", price = 100 },
    { item = "whiting", price = 150 },
    { item = "snapper", price = 200 },
    { item = "mullet", price = 150 },
    { item = "shark", price = 300 },
    { item = "viperfish", price = 400 },
    { item = "squid", price = 250 },
    { item = "lanternfish", price = 700 },
    { item = "hatchetfish", price = 400 }
}

Config.TreasureRewards = {
    { item = "money", amount = 100000 } -- Reward for digging up treasure
}

-- Treasure locations
Config.TreasureLocations = {
    vector3(-2613.7690, -194.4871, 5.3213), 
    vector3(-3245.18, 881.14, 2.04), 
    vector3(-2759.48, 2532.45, 2.65)  
}





