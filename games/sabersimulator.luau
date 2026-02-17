--/ wait for game load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

--/ global environments
getgenv().AutoSwing = false
getgenv().AutoSell = false
getgenv().AutoCrowns = false
getgenv().AutoHearts = false
getgenv().AutoBoss = false
getgenv().AutoBuySaber = false
getgenv().AutoBuyDNA = false
getgenv().AutoBuyClass = false
getgenv().AutoBuyBossDamage = false
getgenv().AutoBuyAura = false
getgenv().AutoBuyPetAura = false
getgenv().AutoOpenEgg = false

--/ locals
local LocalPlayer = Players.LocalPlayer
local UIAction = ReplicatedStorage:WaitForChild("Events"):WaitForChild("UIAction")
local ClientDataManager = require(LocalPlayer.PlayerScripts.MainClient.ClientDataManager)
local PetInfo = require(ReplicatedStorage.Modules.PetsInfo.Pets)
---/ configuration
local Configuration = {
    AutoSwing = false,
    AutoSwingDelay = 0.01,
    AutoSell = false,
    AutoSellDelay = 0.01,
    AutoCrowns = false,
    AutoHearts = false,
    AutoBossEnabled = false,
    AutoBuySaber = false,
    AutoBuyDNA = false,
    AutoBuyClass = false,
    AutoBuyBossDamage = false,
    AutoBuyAura = false,
    AutoBuyPetAura = false,
    AutoOpenEgg = false,
    SelectedEgg = nil,
    FarmingMethodWalk = false,
    FarmingMethodTP = false,
    FarmFireElementsNormal = false,
    FarmFireElementsLevel30 = false,
    FarmFireElementsMaxLevel = false,
    FarmWaterElementsNormal = false,
    FarmWaterElementsLevel30 = false,
    FarmWaterElementsMaxLevel = false,
    FarmEarthElementsNormal = false,
    FarmEarthElementsLevel30 = false,
    FarmEarthElementsMaxLevel = false,
    FarmPlasmaElementsNormal = false,
    FarmPlasmaElementsLevel30 = false,
    FarmPlasmaElementsMaxLevel = false,
}

-- UI
local Modal = loadstring(game:HttpGet("https://github.com/BloxCrypto/Modal/releases/download/v1.0-beta/main.lua"))()
local Window =
    Modal:CreateWindow(
    {
        Title = "hidden",
        SubTitle = "Saber Simulator",
        Size = UDim2.fromOffset(600, 415),
        MinimumSize = Vector2.new(600, 415),
        Transparency = 0,
        Icon = "rbxassetid://72099040646274"
    }
)

local Valentines = Window:AddTab("Valentines")

Valentines:New("Title")(
    {
        Title = "Hearts"
    }
)

Valentines:New("Toggle")(   
    {
        Title = "Auto Hearts",
        Description = "Automatically collect Hearts",
        Callback = function(value)
            getgenv().AutoHearts = value
            Configuration.AutoHearts = value

            if value then
                task.spawn(
                    function()
                        while getgenv().AutoHearts do
                            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                            local root = character:FindFirstChild("HumanoidRootPart")

                            if root and workspace:FindFirstChild("Gameplay") then
                                local holder = workspace.Gameplay:FindFirstChild("CurrencyPickup")
                                holder = holder and holder:FindFirstChild("CurrencyHolder")

                                if holder then
                                    for _, heart in ipairs(holder:GetChildren()) do
                                        if heart.Name == "Heart" and heart.Transparency == 0 then
                                            heart.CFrame = root.CFrame
                                        end
                                    end
                                end
                            end

                            task.wait(0.01)
                        end
                    end
                )
            end
        end
    }
)

-- Automation Tab
local Automation = Window:AddTab("Automation")

Automation:New("Title")(
    {
        Title = "Automation"
    }
)

Automation:New("Toggle")(
    {
        Title = "Auto Swing",
        Description = "Automatically swings the tool",
        Callback = function(value)
            getgenv().AutoSwing = value
            Configuration.AutoSwing = value

            if value then
                local ClientTool = LocalPlayer.PlayerScripts.MainClient:WaitForChild("ClientTool")
                local Tool = require(ClientTool)

                task.spawn(
                    function()
                        while getgenv().AutoSwing do
                            local character = LocalPlayer.Character
                            local humanoid = character and character:FindFirstChild("Humanoid")

                            if character and humanoid and humanoid.Health > 0 then
                                local equippedTool = character:FindFirstChildOfClass("Tool")
                                if not equippedTool then
                                    local backpackTool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                                    if backpackTool then
                                        humanoid:EquipTool(backpackTool)
                                        equippedTool = backpackTool
                                    end
                                end
                                if equippedTool and equippedTool:FindFirstChild("RemoteClick") then
                                    Tool:Swing()
                                end
                            end
                            task.wait(Configuration.AutoSwingDelay)
                        end
                    end
                )
            end
        end
    }
)
Automation:New("Toggle")(
    {
        Title = "Auto Sell",
        Description = "Automatically sell DNA",
        Callback = function(value)
            getgenv().AutoSell = value
            Configuration.AutoSell = value

            if value then
                task.spawn(
                    function()
                        while getgenv().AutoSell do
                            ReplicatedStorage.Events.SellStrength:FireServer()
                            task.wait(Configuration.AutoSellDelay)
                        end
                    end
                )
            end
        end
    }
)
Automation:New("Toggle")(   
    {
        Title = "Auto Crown",
        Description = "Automatically collect Crowns",
        Callback = function(value)
            getgenv().AutoCrowns = value
            Configuration.AutoCrowns = value

            if value then
                task.spawn(
                    function()
                        while getgenv().AutoCrowns do
                            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                            local root = character:FindFirstChild("HumanoidRootPart")

                            if root and workspace:FindFirstChild("Gameplay") then
                                local holder = workspace.Gameplay:FindFirstChild("CurrencyPickup")
                                holder = holder and holder:FindFirstChild("CurrencyHolder")

                                if holder then
                                    for _, crown in ipairs(holder:GetChildren()) do
                                        if crown.Name == "Crown" and crown.Transparency == 0 then
                                            crown.CFrame = root.CFrame
                                            crown.Anchored = true
                                        end
                                    end
                                end
                            end

                            task.wait(0.01)
                        end
                    end
                )
            end
        end
    }
)
Automation:New("Toggle")(
    {
        Title = "Auto Boss",
        Description = "Automatically attacks the Boss",
        Callback = function(value)
            getgenv().AutoBoss = value
            Configuration.AutoBossEnabled = value

            if value then
                task.spawn(
                    function()
                        local bossBasePart = nil

                        while getgenv().AutoBoss and task.wait() do
                            pcall(
                                function()
                                    local localPlayer = game.Players.LocalPlayer
                                    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
                                    local playerRoot = character:WaitForChild("HumanoidRootPart")
                                    local humanoid = character:WaitForChild("Humanoid")
                                    local iterator, bossDescendants, lastIndex =
                                        pairs(workspace.Gameplay.Boss.BossHolder:GetDescendants())

                                    while true do
                                        local currentObject

                                        lastIndex, currentObject = iterator(bossDescendants, lastIndex)

                                        if lastIndex == nil then
                                            break
                                        end

                                        if currentObject.Name == "HumanoidRootPart" then
                                            bossBasePart = currentObject.Parent.Parent.Parent.Base

                                            local safeYPosition =
                                                currentObject.Position.Y - currentObject.Size.Y / 2 + humanoid.HipHeight +
                                                playerRoot.Size.Y / 2 +
                                                0.1

                                            playerRoot.CFrame =
                                                CFrame.new(
                                                currentObject.Position.X,
                                                safeYPosition,
                                                currentObject.Position.Z
                                            )

                                            humanoid:MoveTo(currentObject.Position)
                                            break
                                        end
                                    end
                                end
                            )
                        end
                    end
                )
            end
        end
    }
)
Automation:New("Title")(
    {
        Title = "Settings"
    }
)
Automation:New("Slider")(
    {
        Title = "Auto Swing Delay",
        Description = "Change the delay of Auto Swing",
        Default = 0.015,
        Minimum = 0.015,
        Maximum = 1,
        DecimalCount = 99,
        Callback = function(Amount)
            Configuration.AutoSwingDelay = Amount
        end
    }
)
Automation:New("Slider")(
    {
        Title = "Auto Sell Delay",
        Description = "Change the delay of Auto Sell",
        Default = 0.015,
        Minimum = 0.015,
        Maximum = 1,
        DecimalCount = 99,
        Callback = function(Amount)
            Configuration.AutoSellDelay = Amount
        end
    }
)

local Upgrades = Window:AddTab("Upgrades")
Upgrades:New("Toggle")(
    {
        Title = "Auto Buy Saber",
        Description = "Automatically buys all Sabers",
        Callback = function(value)
            getgenv().AutoBuySaber = value
            Configuration.AutoBuySaber = value

            if value then
                spawn(
                    function()
                        while getgenv().AutoBuySaber do
                            task.wait(1)
                            pcall(
                                function()
                                    UIAction:FireServer("BuyAllWeapons")
                                end
                            )
                        end
                    end
                )
            end
        end
    }
)
Upgrades:New("Toggle")(
    {
        Title = "Auto Buy DNA",
        Description = "Automatically buys all DNAs",
        Callback = function(value)
            getgenv().AutoBuyDNA = value
            Configuration.AutoBuyDNA = value

            if value then
                spawn(
                    function()
                        while getgenv().AutoBuyDNA do
                            task.wait(1)
                            pcall(
                                function()
                                    UIAction:FireServer("BuyAllDNAs")
                                end
                            )
                        end
                    end
                )
            end
        end
    }
)
Upgrades:New("Toggle")(
    {
        Title = "Auto Buy Class",
        Description = "Automatically buys next Class",
        Callback = function(value)
            getgenv().AutoBuyClass = value
            Configuration.AutoBuyClass = value

            if value then
                task.spawn(
                    function()
                        local ItemInfo = require(ReplicatedStorage.Modules.ItemInfo)

                        while getgenv().AutoBuyClass do
                            task.wait(1)

                            pcall(
                                function()
                                    local data = ClientDataManager.Data
                                    if not data or not data.Best_Class_Index then
                                        return
                                    end

                                    local nextClassIndex = data.Best_Class_Index + 1

                                    if nextClassIndex > #ItemInfo.Classes_Order then
                                        return
                                    end

                                    local nextClassName = ItemInfo.Classes_Order[nextClassIndex]

                                    if nextClassName then
                                        UIAction:FireServer("BuyClass", nextClassName)
                                    end
                                end
                            )
                        end
                    end
                )
            end
        end
    }
)
Upgrades:New("Toggle")(
    {
        Title = "Auto Buy Boss Damage",
        Description = "Automatically buys all Boss Damage Upgrades",
        Callback = function(value)
            getgenv().AutoBuyBossDamage = value
            Configuration.AutoBuyBossDamage = value

            if value then
                spawn(
                    function()
                        while getgenv().AutoBuyBossDamage do
                            task.wait(1)
                            pcall(
                                function()
                                    UIAction:FireServer("BuyAllBossBoosts")
                                end
                            )
                        end
                    end
                )
            end
        end
    }
)
Upgrades:New("Toggle")(
    {
        Title = "Auto Buy Aura",
        Description = "Automatically buys all Auras",
        Callback = function(value)
            getgenv().AutoBuyAura = value
            Configuration.AutoBuyAura = value

            if value then
                spawn(
                    function()
                        while getgenv().AutoBuyAura do
                            task.wait(1)
                            pcall(
                                function()
                                    UIAction:FireServer("BuyAllAuras")
                                end
                            )
                        end
                    end
                )
            end
        end
    }
)
Upgrades:New("Toggle")(
    {
        Title = "Auto Buy Pet Aura",
        Description = "Automatically buys all Pet Auras",
        Callback = function(value)
            getgenv().AutoBuyPetAura = value
            Configuration.AutoBuyPetAura = value

            if value then
                spawn(
                    function()
                        while getgenv().AutoBuyPetAura do
                            task.wait(1)
                            pcall(
                                function()
                                    UIAction:FireServer("BuyAllPetAuras")
                                end
                            )
                        end
                    end
                )
            end
        end
    }
)

local Eggs = Window:AddTab("Eggs")
Eggs:New("Title")(
    {
        Title = "Eggs"
    }
)
local petShopInfo = require(game:GetService("ReplicatedStorage").Modules.PetsInfo.PetShopInfo)
local eggNames = {}

for _, eggData in pairs(petShopInfo) do
    if type(eggData) == "table" and eggData.EggName then
        table.insert(eggNames, eggData.EggName)
    end
end

local selectedEgg = Configuration.SelectedEgg or eggNames[1]

Eggs:New("Toggle")(
    {
        Title = "Auto Open Egg",
        Description = "Automatically opens the Selected Egg",
        Callback = function(value)
            getgenv().AutoOpenEgg = value
            Configuration.AutoOpenEgg = value

            if value then
                spawn(
                    function()
                        while getgenv().AutoOpenEgg do
                            wait(0.1)

                            if selectedEgg then
                                pcall(
                                    function()
                                        local egg = {
                                            "BuyEgg",
                                            selectedEgg
                                        }
                                        game:GetService("ReplicatedStorage").Events.UIAction:FireServer(unpack(egg))
                                    end
                                )
                            end
                        end
                    end
                )
            end
        end
    }
)
Eggs:New("Dropdown")(
    {
        Title = "Select Egg",
        Description = "Select the egg to open",
        Options = eggNames,
        Default = selectedEgg,
        Callback = function(value)
            selectedEgg = value
            Configuration.SelectedEgg = value
        end
    }
)
Eggs:New("Title")(
    {
        Title = "Auto Delete Pets"
    }
)

local nextPair, petDataTable, lastKey = pairs(PetInfo)
local rarityLookup = {}

while true do
    local petInfo

    lastKey, petInfo = nextPair(petDataTable, lastKey)

    if lastKey == nil then
        break
    end

    if petInfo.Rarity then
        rarityLookup[lastKey] = petInfo.Rarity
    end
end

local function getRarityFromType(petType)
    return rarityLookup[petType]
end

local function deletePetsByRarity(allowedRarities)
    local playerData = ClientDataManager.Data
    local nextPet, petList, lastPetKey = pairs(playerData.Pets)
    local petsToDelete = {}

    while true do
        local petInfo

        lastPetKey, petInfo = nextPet(petList, lastPetKey)

        if lastPetKey == nil then
            break
        end

        if not (table.find(playerData.PetsEquipped, lastPetKey) or petInfo.Locked) then
            local rarity = getRarityFromType(petInfo.Type)

            if rarity and table.find(allowedRarities, rarity) then
                table.insert(petsToDelete, lastPetKey)
            end
        end
    end

    if #petsToDelete <= 0 then
        return 0
    end

    UIAction:FireServer("DeletePets", petsToDelete)

    return #petsToDelete
end
local Globals = getgenv()

Globals.selectedRarities = Globals.selectedRarities or {}
Globals.autoDeleteEnabled = Globals.autoDeleteEnabled or false
Globals.autoDeleteThread = Globals.autoDeleteThread or nil

local autoDeleteOptions = {
    {Name = "Delete the 1 Star Rarity", Flag = "delete_1_star", Rarity = 1},
    {Name = "Delete the 2 Star Rarity", Flag = "delete_2_star", Rarity = 2},
    {Name = "Delete the 3 Star Rarity", Flag = "delete_3_star", Rarity = 3},
    {Name = "Delete the 4 Star Rarity", Flag = "delete_4_star", Rarity = 4},
    {Name = "Delete the 5 Star Rarity", Flag = "delete_5_star", Rarity = 5},
    {Name = "Delete the 1 Moon Rarity", Flag = "delete_1_moon", Rarity = 6},
    {Name = "Delete the 2 Moon Rarity", Flag = "delete_2_moon", Rarity = 7},
    {Name = "Delete the 3 Moon Rarity", Flag = "delete_3_moon", Rarity = 8},
    {Name = "Delete Secrets", Flag = "delete_1_secret", Rarity = 9}
}

local function StartAutoDeleteLoop()
    if Globals.autoDeleteThread then
        return
    end

    Globals.autoDeleteThread =
        task.spawn(
        function()
            while true do
                if Globals.autoDeleteEnabled and #Globals.selectedRarities > 0 then
                    local success, deletedCount =
                        pcall(
                        function()
                            return deletePetsByRarity(Globals.selectedRarities)
                        end
                    )

                    if success and deletedCount and deletedCount > 0 then
                    end
                end

                task.wait(2)
            end
        end
    )
end

for _, option in ipairs(autoDeleteOptions) do
    Eggs:New("Toggle")(
        {
            Title = option.Name,
            Description = "Automatically delete pets of this rarity",
            Callback = function(isEnabled)
                if isEnabled then
                    if not table.find(Globals.selectedRarities, option.Rarity) then
                        table.insert(Globals.selectedRarities, option.Rarity)
                    end
                else
                    local index = table.find(Globals.selectedRarities, option.Rarity)

                    if index then
                        table.remove(Globals.selectedRarities, index)
                    end
                end

                Globals.autoDeleteEnabled = (#Globals.selectedRarities > 0)

                StartAutoDeleteLoop()

                if isEnabled then
                    local deletedCount = deletePetsByRarity({option.Rarity})

                    if deletedCount > 0 then
                    end
                end
            end
        }
    )
end

local Elements = Window:AddTab("Elements")
Elements:New("Title")(
    {
        Title = "Method"
    }
)
getgenv().FarmingMethodWalk = Configuration.FarmingMethodWalk or false
Elements:New("Toggle")(
    {
        Title = "Farming Method ( Walk )",
        Description = "Walks to the selected Element Farm",
        Callback = function(value)
            getgenv().FarmingMethodWalk = value
            Configuration.FarmingMethodWalk = value
        end
    }
)

getgenv().FarmingMethodTP = Configuration.FarmingMethodTP or false
Elements:New("Toggle")(
    {
        Title = "Farming Method ( Teleport )",
        Description = "Teleports to the selected Element Farm",
        Callback = function(value)
            getgenv().FarmingMethodTP = value
            Configuration.FarmingMethodTP = value
        end
    }
)

Elements:New("Title")(
    {
        Title = "Fire"
    }
)

getgenv().FarmFireElementsNormal = Configuration.FarmFireElementsNormal or false
getgenv().FarmFireElementsLevel30 = Configuration.FarmFireElementsLevel30 or false
getgenv().FarmFireElementsMaxLevel = Configuration.FarmFireElementsMaxLevel or false

local function getCharacterParts()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()

    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")

    return character, humanoid, root
end

local function moveToTarget(targetPart, humanoid, root)
    local targetY = targetPart.Position.Y - targetPart.Size.Y / 2 + humanoid.HipHeight + root.Size.Y / 2 + 0.1

    if getgenv().FarmingMethodTP then
        root.CFrame = CFrame.new(targetPart.Position.X, targetY, targetPart.Position.Z)
    elseif getgenv().FarmingMethodWalk then
        humanoid:MoveTo(targetPart.Position)
    end
end

local function farmFireArea(getFolderFunction, toggleName)
    task.spawn(
        function()
            while getgenv()[toggleName] and task.wait() do
                pcall(
                    function()
                        local _, humanoid, root = getCharacterParts()
                        local folder = getFolderFunction()

                        if not folder then
                            return
                        end

                        for _, fireZone in pairs(folder:GetChildren()) do
                            if fireZone.Name:find("Fire") then
                                local targetPart = fireZone:FindFirstChild("HumanoidRootPart", true)

                                if targetPart then
                                    moveToTarget(targetPart, humanoid, root)
                                    break
                                end
                            end
                        end
                    end
                )
            end
        end
    )
end

Elements:New("Toggle")(
    {
        Title = "Farms Fire Element ( Level 0 )",
        Description = "Farms the Level 0 Fire Element Area",
        Callback = function(enabled)
            getgenv().FarmFireElementsNormal = enabled
            Configuration.FarmFireElementsNormal = enabled

            if enabled then
                farmFireArea(
                    function()
                        return workspace.Gameplay.Map.ElementZones.Fire.Fire
                    end,
                    "FarmFireElementsNormal"
                )
            end
        end
    }
)

Elements:New("Toggle")(
    {
        Title = "Farms Fire Element ( Level 30 )",
        Description = "Farms the Level 30 Fire Element Area",
        Callback = function(enabled)
            getgenv().FarmFireElementsLevel30 = enabled
            Configuration.FarmFireElementsLevel30 = enabled

            if enabled then
                farmFireArea(
                    function()
                        return workspace.Gameplay.RegionsLoaded.AdvancedFireArea.Important.Fire
                    end,
                    "FarmFireElementsLevel30"
                )
            end
        end
    }
)

Elements:New("Toggle")(
    {
        Title = "Farms Fire Element ( Level 100 )",
        Description = "Farms the Level 100 Fire Element Area",
        Callback = function(enabled)
            getgenv().FarmFireElementsMaxLevel = enabled
            Configuration.FarmFireElementsMaxLevel = enabled

            if enabled then
                farmFireArea(
                    function()
                        return workspace.Gameplay.RegionsLoaded.MasterFireArea.Important.Fire
                    end,
                    "FarmFireElementsMaxLevel"
                )
            end
        end
    }
)

Elements:New("Title")(
    {
        Title = "Water"
    }
)

getgenv().FarmWaterElementsNormal = Configuration.FarmWaterElementsNormal or false
getgenv().FarmWaterElementsLevel30 = Configuration.FarmWaterElementsLevel30 or false
getgenv().FarmWaterElementsMaxLevel = Configuration.FarmWaterElementsMaxLevel or false

local function getCharacterParts()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()

    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")

    return character, humanoid, root
end

local function moveToTarget(targetPart, humanoid, root)
    local targetY = targetPart.Position.Y - targetPart.Size.Y / 2 + humanoid.HipHeight + root.Size.Y / 2 + 0.1

    if getgenv().FarmingMethodTP then
        root.CFrame = CFrame.new(targetPart.Position.X, targetY, targetPart.Position.Z)
    elseif getgenv().FarmingMethodWalk then
        humanoid:MoveTo(targetPart.Position)
    end
end

local function farmWaterArea(getFolderFunction, toggleName)
    spawn(
        function()
            while getgenv()[toggleName] and task.wait() do
                pcall(
                    function()
                        local character, humanoid, root = getCharacterParts()
                        local folder = getFolderFunction()

                        if not folder then
                            return
                        end

                        for _, waterZone in pairs(folder:GetChildren()) do
                            if waterZone.Name:find("Water") then
                                for _, obj in pairs(waterZone:GetChildren()) do
                                    if obj:IsA("BasePart") and obj.Name == "HumanoidRootPart" then
                                        moveToTarget(obj, humanoid, root)
                                        break
                                    end
                                end
                            end
                        end
                    end
                )
            end
        end
    )
end

Elements:New("Toggle")(
    {
        Title = "Farms Water Element ( Level 0 )",
        Description = "Farms the Level 0 Water Element Area",
        Callback = function(enabled)
            getgenv().FarmWaterElementsNormal = enabled
            Configuration.FarmWaterElementsNormal = enabled

            if enabled then
                farmWaterArea(
                    function()
                        return workspace.Gameplay.Map.ElementZones.Water.Water
                    end,
                    "FarmWaterElementsNormal"
                )
            end
        end
    }
)

Elements:New("Toggle")(
    {
        Title = "Farms Water Element ( Level 30 )",
        Description = "Farms the Level 30 Water Element Area",
        Callback = function(enabled)
            getgenv().FarmWaterElementsLevel30 = enabled
            Configuration.FarmWaterElementsLevel30 = enabled

            if enabled then
                farmWaterArea(
                    function()
                        return workspace.Gameplay.RegionsLoaded.AdvancedWaterArea.Important.Water
                    end,
                    "FarmWaterElementsLevel30"
                )
            end
        end
    }
)

Elements:New("Toggle")(
    {
        Title = "Farms Water Element ( Level 100 )",
        Description = "Farms the Level 100 Water Element Area",
        Callback = function(enabled)
            getgenv().FarmWaterElementsMaxLevel = enabled
            Configuration.FarmWaterElementsMaxLevel = enabled

            if enabled then
                farmWaterArea(
                    function()
                        return workspace.Gameplay.RegionsLoaded.MasterWaterArea.Important.Water
                    end,
                    "FarmWaterElementsMaxLevel"
                )
            end
        end
    }
)

Elements:New("Title")(
    {
        Title = "Earth"
    }
)

getgenv().FarmEarthElementsNormal = Configuration.FarmEarthElementsNormal or false
getgenv().FarmEarthElementsLevel30 = Configuration.FarmEarthElementsLevel30 or false
getgenv().FarmEarthElementsMaxLevel = Configuration.FarmEarthElementsMaxLevel or false

local function getCharacterParts()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()

    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")

    return character, humanoid, root
end

local function moveToTarget(targetPart, humanoid, root)
    local targetY = targetPart.Position.Y - targetPart.Size.Y / 2 + humanoid.HipHeight + root.Size.Y / 2 + 0.1

    if getgenv().FarmingMethodTP then
        root.CFrame = CFrame.new(targetPart.Position.X, targetY, targetPart.Position.Z)
    elseif getgenv().FarmingMethodWalk then
        humanoid:MoveTo(targetPart.Position)
    end
end

local function farmEarthArea(getFolderFunction, toggleName)
    task.spawn(
        function()
            while getgenv()[toggleName] and task.wait() do
                pcall(
                    function()
                        local _, humanoid, root = getCharacterParts()
                        local folder = getFolderFunction()

                        if not folder then
                            return
                        end

                        for _, earthZone in pairs(folder:GetChildren()) do
                            if earthZone.Name:find("Earth") then
                                local targetPart = earthZone:FindFirstChild("HumanoidRootPart", true)

                                if targetPart then
                                    moveToTarget(targetPart, humanoid, root)
                                    break
                                end
                            end
                        end
                    end
                )
            end
        end
    )
end

Elements:New("Toggle")(
    {
        Title = "Farms Earth Element ( Level 0 )",
        Description = "Farms the Level 0 Earth Element Area",
        Callback = function(enabled)
            getgenv().FarmEarthElementsNormal = enabled
            Configuration.FarmEarthElementsNormal = enabled

            if enabled then
                farmEarthArea(
                    function()
                        return workspace.Gameplay.Map.ElementZones.Earth.Model.Earth
                    end,
                    "FarmEarthElementsNormal"
                )
            end
        end
    }
)

Elements:New("Toggle")(
    {
        Title = "Farms Earth Element ( Level 30 )",
        Description = "Farms the Level 30 Earth Element Area",
        Callback = function(enabled)
            getgenv().FarmEarthElementsLevel30 = enabled
            Configuration.FarmEarthElementsLevel30 = enabled

            if enabled then
                farmEarthArea(
                    function()
                        return workspace.Gameplay.RegionsLoaded.AdvancedEarthArea.Important.Earth
                    end,
                    "FarmEarthElementsLevel30"
                )
            end
        end
    }
)

Elements:New("Toggle")(
    {
        Title = "Farms Earth Element ( Level 100 )",
        Description = "Farms the Level 100 Earth Element Area",
        Callback = function(enabled)
            getgenv().FarmEarthElementsMaxLevel = enabled
            Configuration.FarmEarthElementsMaxLevel = enabled

            if enabled then
                farmEarthArea(
                    function()
                        return workspace.Gameplay.RegionsLoaded.MasterEarthArea.Important.Earth
                    end,
                    "FarmEarthElementsMaxLevel"
                )
            end
        end
    }
)
Elements:New("Title")(
    {
        Title = "Plasma"
    }
)

getgenv().FarmPlasmaElementsLevel30  = Configuration.FarmPlasmaElementsLevel30  or false
getgenv().FarmPlasmaElementsMaxLevel = Configuration.FarmPlasmaElementsMaxLevel or false

local function getCharacterParts()

    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()

    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")

    return character, humanoid, root
end


local function moveToTarget(targetPart, humanoid, root)

    local targetY =
        targetPart.Position.Y
        - targetPart.Size.Y / 2
        + humanoid.HipHeight
        + root.Size.Y / 2
        + 0.1

    if getgenv().FarmingMethodTP then

        root.CFrame = CFrame.new(
            targetPart.Position.X,
            targetY,
            targetPart.Position.Z
        )

    elseif getgenv().FarmingMethodWalk then

        humanoid:MoveTo(targetPart.Position)

    end
end

local function farmPlasmaArea(getFolderFunction, toggleName, advancedFilter)

    task.spawn(function()

        while getgenv()[toggleName] and task.wait() do

            pcall(function()

                local _, humanoid, root = getCharacterParts()
                local folder = getFolderFunction()

                if not folder then return end

                for _, plasmaGroup in pairs(folder:GetChildren()) do

                    if plasmaGroup.Name == "Plasma" or plasmaGroup.Name:find("Plasma") then

                        for _, plasmaZone in pairs(plasmaGroup:GetChildren()) do

                            if advancedFilter then
                                if plasmaZone.Name:find("Advanced") then
                                end
                            end

                            if plasmaZone.Name:find("Plasma") then

                                local targetPart =
                                    plasmaZone:FindFirstChild("HumanoidRootPart", true)

                                if targetPart then

                                    moveToTarget(targetPart, humanoid, root)
                                    break

                                end
                            end
                        end
                    end
                end

            end)

        end

    end)
end

-- 2062.17407, -10.0772333, 171.607925

Elements:New("Button")({
    Title = "Teleport to Plasma Area",
    Description = "Teleports you to the Plasma Area",
    Callback = function()

        local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

        character:PivotTo(
            CFrame.new(2062.17407, -10.0772333, 171.607925)
        )

    end,
})

Elements:New("Toggle")({

    Title = "Farm Plasma Element ( Level 30 )",
    Description = "Farms the Level 30 Plasma Element Area",

    Callback = function(enabled)

        getgenv().FarmPlasmaElementsLevel30 = enabled
        Configuration.FarmPlasmaElementsLevel30 = enabled

        if enabled then

            farmPlasmaArea(
                function()
                    return workspace.Gameplay.RegionsLoaded.AdvancedPlasmaArea.Important
                end,
                "FarmPlasmaElementsLevel30",
                true
            )

        end
    end
})


Elements:New("Toggle")({

    Title = "Farm Plasma Element ( Level 100 )",
    Description = "Farms the Level 100 Plasma Element Area",

    Callback = function(enabled)

        getgenv().FarmPlasmaElementsMaxLevel = enabled
        Configuration.FarmPlasmaElementsMaxLevel = enabled

        if enabled then

            farmPlasmaArea(
                function()
                    return workspace.Gameplay.RegionsLoaded.MasterPlasmaArea.Important.Plasma
                end,
                "FarmPlasmaElementsMaxLevel",
                false
            )

        end
    end
})

-- Settings
local Settings = Window:AddTab("Settings")

Settings:New("Title")(
    {
        Title = "Themes"
    }
)

Settings:New("Dropdown")(
    {
        Title = "Theme",
        Description = "Default theme options",
        Options = {"Light", "Dark", "Midnight", "Rose", "Emerald"},
        Callback = function(Theme)
            Window:SetTheme(Theme)
        end
    }
)

Settings:New("Button")(
    {
        Title = "Set Custom GUI",
        Description = "This is to showcase how custom themes work (without the default ones)",
        Callback = function()
            local CustomTheme = {
                Mode = "Dark",
                Accent = Color3.fromRGB(255, 170, 70),
                Background = {
                    Rotation = 120,
                    Color = ColorSequence.new(
                        {
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 18, 14)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 8, 6))
                        }
                    ),
                    Line = {
                        Color = Color3.fromRGB(255, 200, 120),
                        Transparency = 0.9
                    },
                    OuterOutline = {
                        Transparency = 0,
                        Color = Color3.fromRGB(5, 4, 3),
                        Rotation = 0
                    },
                    InnerOutline = {
                        Transparency = 0.78,
                        Color = Color3.fromRGB(170, 130, 90),
                        Rotation = 0
                    }
                },
                Text = {
                    Title = {
                        Color = Color3.fromRGB(255, 245, 230)
                    },
                    Description = {
                        Color = Color3.fromRGB(205, 190, 170)
                    }
                },
                Icons = {
                    ActionButtons = {
                        Color = Color3.fromRGB(255, 215, 160),
                        Transparency = 0.18
                    }
                },
                Content = {
                    Color = ColorSequence.new(
                        {
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 20, 16)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 13, 10))
                        }
                    ),
                    Rotation = 240,
                    ScrollBarColor = Color3.fromRGB(200, 160, 110),
                    InnerOutline = {
                        Transparency = 0.92,
                        Color = Color3.fromRGB(160, 125, 85),
                        Rotation = 0
                    },
                    OuterOutline = {
                        Transparency = 0,
                        Color = Color3.fromRGB(6, 5, 4),
                        Rotation = 0
                    }
                },
                Component = {
                    Color = Color3.fromRGB(26, 22, 18),
                    Rotation = 0
                },
                Controls = {
                    Color = Color3.fromRGB(36, 30, 24),
                    Outline = Color3.fromRGB(48, 40, 32)
                }
            }
            Window:SetTheme(CustomTheme)
        end
    }
)

Settings:New("Button")(
    {
        Title = "Destroy GUI",
        Description = "Click to get rid of the UI",
        Callback = function()
            Window:Destroy()
        end
    }
)

Window:SetTab("Automation")
Window:SetTheme("Dark")
