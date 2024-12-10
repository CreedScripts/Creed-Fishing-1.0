local fishing = false
local fishingRodProp = nil
local deepSeaFishingZone = vector3(-1480.15, 7049.49, -0.13)
local deepSeaFishingRadius = 200.0
local npcEntity = nil
local envelopeProp = nil
local treasureBlip = nil
local treasureLocation = nil
local digging = false

RegisterNetEvent('fishing:useMessageBottle', function()
    local randomIndex = math.random(#Config.TreasureLocations)
    treasureLocation = Config.TreasureLocations[randomIndex]

    if treasureBlip then
        RemoveBlip(treasureBlip)
    end

    treasureBlip = AddBlipForCoord(treasureLocation.x, treasureLocation.y, treasureLocation.z)
    SetBlipSprite(treasureBlip, 364)
    SetBlipDisplay(treasureBlip, 4)
    SetBlipScale(treasureBlip, 1.0)
    SetBlipColour(treasureBlip, 1)
    SetBlipAsShortRange(treasureBlip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Treasure Location")
    EndTextCommandSetBlipName(treasureBlip)

    Citizen.CreateThread(function()
        while treasureLocation do
            Wait(0)
            DrawMarker(1, treasureLocation.x, treasureLocation.y, treasureLocation.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 5.0, 0.5, 255, 0, 0, 100, false, false, 2, false, nil, nil, false)
        end
    end)

    TriggerEvent('fishing:showTreasureMap')
end)

RegisterNetEvent('fishing:showTreasureMap', function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "show" })
end)

RegisterNUICallback("close", function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "hide" })
    cb("ok")
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustPressed(0, 322) or IsControlJustPressed(0, 200) then
            SetNuiFocus(false, false)
            SendNUIMessage({ action = "hide" })
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if treasureLocation and not digging then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - treasureLocation)

            if distance <= 5.0 then
                DrawText3D(treasureLocation.x, treasureLocation.y, treasureLocation.z, "[E] Dig for Treasure")

                if IsControlJustPressed(0, 38) then
                    digging = true
                    TriggerEvent('fishing:startDigging')
                end
            end
        end
    end
end)

RegisterNetEvent('fishing:startDigging', function()
    local playerPed = PlayerPedId()

    RequestAnimDict("amb@world_human_gardener_plant@male@base")
    while not HasAnimDictLoaded("amb@world_human_gardener_plant@male@base") do
        Wait(10)
    end

    TaskPlayAnim(playerPed, "amb@world_human_gardener_plant@male@base", "base", 8.0, -8.0, 5000, 1, 0, false, false, false)

    local success = lib.progressBar({  
        duration = 5000,
        label = "Digging for treasure...",
        useWhileDead = false,
        canCancel = false,
        disable = {
            move = true,
            car = true,
            combat = true,
        },
    })
    
    if success then 

        Wait(0000)
        ClearPedTasks(playerPed)

        TriggerServerEvent('fishing:rewardTreasure')

        if treasureBlip then
            RemoveBlip(treasureBlip)
            treasureBlip = nil
        end

        treasureLocation = nil
        digging = false
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = #text / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
    end
end

-- Coordinates and model for the Fishing Vendor NPC
local fishingVendorLocation = vector4(-1713.63, -1121.22, 13.15, 56.8)
local fishingVendorModel = "cs_hunter"


local function hasItemsToSell()
    for _, itemConfig in pairs(Config.SellPrices) do
        local itemName = itemConfig.item
        local itemCount = exports.ox_inventory:Search("count", itemName)
        if itemCount and itemCount > 0 then
            return true
        end
    end
    return false
end


local function spawnFishingVendor()
    local npcModel = GetHashKey(fishingVendorModel)

    RequestModel(npcModel)
    while not HasModelLoaded(npcModel) do
        Wait(10)
    end

    npcEntity = CreatePed(4, npcModel, fishingVendorLocation.x, fishingVendorLocation.y, fishingVendorLocation.z - 1.0, fishingVendorLocation.w, false, true)
    SetEntityInvincible(npcEntity, true)
    SetBlockingOfNonTemporaryEvents(npcEntity, true)
    FreezeEntityPosition(npcEntity, true)

    exports['qb-target']:AddTargetEntity(npcEntity, {
        options = {
            {
                icon = "fas fa-fish",
                label = "Sell All Fish",
                action = function()
                    if hasItemsToSell() then
                        startHandshakeProcess()
                    else
                        TriggerEvent("ox_lib:notify", { type = "error", description = "You have no fish to sell!" })
                    end
                end
            }
        },
        distance = 1.5
    })

    local blip = AddBlipForCoord(fishingVendorLocation.x, fishingVendorLocation.y, fishingVendorLocation.z)
    SetBlipSprite(blip, 605)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 3)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Fishing Vendor")
    EndTextCommandSetBlipName(blip)
end

Citizen.CreateThread(function()
    spawnFishingVendor()
end)

local function positionPlayerForAnimation()
    local playerPed = PlayerPedId()
    local npcCoords = vector3(fishingVendorLocation.x, fishingVendorLocation.y, fishingVendorLocation.z)
    local npcHeading = fishingVendorLocation.w

    local targetCoords = GetOffsetFromEntityInWorldCoords(npcEntity, 0.0, 0.8, 0.0)
    local targetHeading = npcHeading + 180.0
    if targetHeading > 360.0 then
        targetHeading = targetHeading - 360.0
    end

    TaskGoStraightToCoord(playerPed, targetCoords.x, targetCoords.y, targetCoords.z, 1.0, 4000, targetHeading, 0.1)

    while #(GetEntityCoords(playerPed) - targetCoords) > 0.1 do
        Wait(100)
    end

    SetEntityHeading(playerPed, targetHeading)
end

local function attachEnvelopeToNPC()
    local propModel = GetHashKey("prop_cs_cashenvelope")

    RequestModel(propModel)
    while not HasModelLoaded(propModel) do
        Wait(10)
    end

    envelopeProp = CreateObject(propModel, 0, 0, 0, true, true, false)
    AttachEntityToEntity(
        envelopeProp,
        npcEntity,
        GetPedBoneIndex(npcEntity, 57005),
        0.1, 0.0, 0.0,
        0.0, 90.0, 0.0,
        true, true, false, true, 1, true
    )
end

local function transferEnvelopeToPlayer()
    if envelopeProp then
        DetachEntity(envelopeProp, true, false)
        local playerPed = PlayerPedId()
        AttachEntityToEntity(
            envelopeProp,
            playerPed,
            GetPedBoneIndex(playerPed, 57005),
            0.1, 0.0, 0.0,
            0.0, 90.0, 0.0,
            true, true, false, true, 1, true
        )
    end
end

local function detachAndDeleteEnvelope()
    if DoesEntityExist(envelopeProp) then
        DetachEntity(envelopeProp, true, false)
        DeleteObject(envelopeProp)
        envelopeProp = nil
    end
end

function startHandshakeProcess()
    local playerPed = PlayerPedId()
    positionPlayerForAnimation()

    RequestAnimDict("mp_ped_interaction")
    RequestAnimDict("mp_common")
    while not HasAnimDictLoaded("mp_ped_interaction") or not HasAnimDictLoaded("mp_common") do
        Wait(10)
    end

    TaskPlayAnim(playerPed, "mp_ped_interaction", "hugs_guy_a", 8.0, -8.0, 3400, 0, 0, false, false, false)
    TaskPlayAnim(npcEntity, "mp_ped_interaction", "hugs_guy_a", 8.0, -8.0, 3400, 0, 0, false, false, false)

    Citizen.Wait(3500)

    attachEnvelopeToNPC()
    TaskPlayAnim(npcEntity, "mp_common", "givetake1_a", 8.0, -8.0, 3000, 0, 0, false, false, false)
    TaskPlayAnim(playerPed, "mp_common", "givetake2_a", 8.0, -8.0, 3000, 0, 0, false, false, false)

    Citizen.Wait(1500)
    transferEnvelopeToPlayer()
    Citizen.Wait(1500)

    detachAndDeleteEnvelope()

    ClearPedTasks(playerPed)
    ClearPedTasks(npcEntity)

    TriggerServerEvent("fishing:sellAllFish")
end

local function isNearAndFacingWater(ped)
    local pedCoords = GetEntityCoords(ped)
    local forwardVector = GetEntityForwardVector(ped)
    local radius = 15.0
    local checkDistance = 5.0

    local isNearWater, waterHeight = GetWaterHeight(pedCoords.x, pedCoords.y, pedCoords.z)
    local nearbyWater = isNearWater or #(pedCoords - vector3(pedCoords.x, pedCoords.y, waterHeight or 0.0)) <= radius
    local checkPoint = pedCoords + (forwardVector * checkDistance)
    local isFacingWater, _ = GetWaterHeight(checkPoint.x, checkPoint.y, checkPoint.z)

    return nearbyWater and isFacingWater
end

local function isInDeepSeaFishingZone(pedCoords)
    return #(pedCoords - deepSeaFishingZone) <= deepSeaFishingRadius
end

RegisterNetEvent('fishing:start', function()
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)

    if fishing or not IsPedOnFoot(ped) then
        TriggerEvent('ox_lib:notify', { type = 'error', description = 'You need to be on foot to fish!' })
        return
    end

    local inDeepSeaZone = isInDeepSeaFishingZone(pedCoords)
    local requiredBait = inDeepSeaZone and 'deepseabait' or 'fishingbait'
    local baitCount = exports.ox_inventory:Search('count', requiredBait)

    if baitCount < 1 then
        TriggerEvent('ox_lib:notify', { type = 'error', description = 'You need ' .. requiredBait .. ' to fish!' })
        return
    end

    if not isNearAndFacingWater(ped) then
        TriggerEvent('ox_lib:notify', { type = 'error', description = 'You need to be near and facing water to fish!' })
        return
    end

    TriggerServerEvent('fishing:consumeBait', requiredBait)

    local rodModel = GetHashKey('prop_fishing_rod_01')
    RequestModel(rodModel)
    while not HasModelLoaded(rodModel) do
        Wait(10)
    end

    fishingRodProp = CreateObject(rodModel, 0, 0, 0, true, true, false)
    AttachEntityToEntity(
        fishingRodProp,
        ped,
        GetPedBoneIndex(ped, 60309),
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        true, true, false, true, 1, true
    )

    RequestAnimDict('amb@world_human_stand_fishing@base')
    while not HasAnimDictLoaded('amb@world_human_stand_fishing@base') do
        Wait(10)
    end

    TaskPlayAnim(ped, 'amb@world_human_stand_fishing@base', 'base', 8.0, -8.0, -1, 49, 0, false, false, false)

    fishing = true
    TriggerEvent('ox_lib:notify', { type = 'success', description = 'You cast your fishing rod!' })

    Citizen.CreateThread(function()
        while fishing do
            DisableControlAction(0, 30, true)
            DisableControlAction(0, 31, true)
            DisableControlAction(0, 21, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 73, true)
            DisableControlAction(0, 75, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 257, true)
            Wait(0)
        end
    end)

    local waitTime = math.random(5000, 10000)
    Citizen.Wait(waitTime)

    local success = exports['ox_lib']:skillCheck({'easy', 'easy', 'medium'}, {'e', 'e', 'e'})
    ClearPedTasks(ped)
    if fishingRodProp then
        DeleteObject(fishingRodProp)
        fishingRodProp = nil
    end

    if success then
        local inDeepSeaZone = isInDeepSeaFishingZone(GetEntityCoords(PlayerPedId()))
        TriggerServerEvent('fishing:catch', inDeepSeaZone)
    else
        TriggerEvent('ox_lib:notify', { type = 'error', description = 'You failed to catch anything!' })
    end

    fishing = false
end)

Citizen.CreateThread(function()
    local blip = AddBlipForCoord(deepSeaFishingZone.x, deepSeaFishingZone.y, deepSeaFishingZone.z)
    SetBlipSprite(blip, 68)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 9)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Deep Sea Fishing")
    EndTextCommandSetBlipName(blip)

    local fishingZone = AddBlipForRadius(deepSeaFishingZone.x, deepSeaFishingZone.y, deepSeaFishingZone.z, deepSeaFishingRadius)
    SetBlipAlpha(fishingZone, 100)
    SetBlipColour(fishingZone, 9)
end)


































