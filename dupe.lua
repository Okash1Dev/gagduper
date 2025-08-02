-- Load WindUI Library
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/Source.lua"))()

-- Services
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Variables
local player = Players.LocalPlayer

-- Sound for messages
local messageSound = Instance.new("Sound")
messageSound.SoundId = "rbxassetid://911882909"
messageSound.Volume = 0.4
messageSound.Parent = SoundService

-- Create WindUI Window
local Window = WindUI:CreateWindow({
    Title = "Terfi Script",
    Author = "terfiscript",
    Size = UDim2.fromOffset(600, 400),
    Theme = "Dark",
    SynelizeTitle = false
})

-- Enhanced Message System
local function createMessage(text, messageType)
    Window:Notify({
        Title = messageType == "error" and "Ошибка" or "Успех",
        Content = text,
        Duration = 3.5,
        Image = messageType == "error" and "rbxassetid://4484362115" or "rbxassetid://4484362458"
    })
    messageSound:Play()
end

-- Format number with commas
local function formatNumberWithCommas(number)
    local formatted = tostring(number)
    local result = ""
    local count = 0
    
    for i = #formatted, 1, -1 do
        result = formatted:sub(i, i) .. result
        count = count + 1
        if count == 3 and i > 1 then
            result = "," .. result
            count = 0
        end
    end
    
    return result .. "¢"
end

-- Update Sheckles function
local function updateSheckles(amount)
    local shecklesUI = player.PlayerGui:FindFirstChild("Sheckles_UI")
    if shecklesUI and shecklesUI:FindFirstChild("TextLabel") then
        local textLabel = shecklesUI.TextLabel
        local currentText = textLabel.Text
        local currenta = currentText:gsub("[,%s¢c]", "")
        local current = tonumber(currenta) or 0
        local newAmount = current + amount
        textLabel.Text = formatNumberWithCommas(newAmount)
    end
end

-- Remove duplicates function
local function removeDuplicates(itemName)
    local backpack = player.Backpack
    local removedCount = 0
    for _, item in pairs(backpack:GetChildren()) do
        if item:IsA("Tool") and item.Name == itemName then
            item:Destroy()
            removedCount = removedCount + 1
        end
    end
    return removedCount
end

-- Dupe function
local function dupeItem()
    local character = player.Character
    if not character then
        createMessage("Ошибка: персонаж не загружен", "error")
        return
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        createMessage("Ошибка: Хуманоид не найден", "error")
        return
    end

    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        local success, err = pcall(function()
            local clone = tool:Clone()
            clone.Parent = player.Backpack
            -- Monitor original item for sale
            tool:GetPropertyChangedSignal("Parent"):Connect(function()
                if tool.Parent ~= player.Character and tool.Parent ~= player.Backpack then
                    local removedCount = removeDuplicates(tool.Name)
                    local shecklesEarned = 10 * (removedCount + 1)
                    updateSheckles(shecklesEarned)
                end
            end)
        end)
        
        if success then
            createMessage("✓ Предмет успешно дюпнут!", "success")
        else
            createMessage("Ошибка при дюплицировании", "error")
        end
    else
        createMessage("Держи предмет в руках!", "error")
    end
end

-- Monitor Talk_UI for sheckles updates
local lastRewardText = ""

local function monitorTalkUIText()
    local canCheck = true
    
    while true do
        local steven = workspace:FindFirstChild("NPCS") and workspace.NPCS:FindFirstChild("Steven")
        local head = steven and steven:FindFirstChild("Head")
        local talkUI = head and head:FindFirstChild("Talk_UI")
        local textLabel = talkUI and talkUI:FindFirstChild("TextLabel")
        
        if textLabel and canCheck then
            local text = textLabel.Text
            
            if text:find("Here is") and text ~= lastRewardText then
                local amountStr = text:match("<font color='#FFFF00'>([%d,%.]+[¢c])</font>") or text:match("(%d+[%d,%.]*[¢c])")
                
                if amountStr then
                    local cleanAmountStr = amountStr:gsub("[,%s¢c]", "")
                    local amount = tonumber(cleanAmountStr)
                    
                    if amount then
                        lastRewardText = text
                        wait(2)
                        updateSheckles(amount)
                        
                        canCheck = false
                        spawn(function()
                            wait(2.2)
                            canCheck = true
                        end)
                    end
                end
            end
        end
        wait(0.2)
    end
end

-- Start monitoring in separate thread
spawn(monitorTalkUIText)

-- Create Tabs
local DupeTab = Window:CreateTab({
    Name = "Dupe",
    Image = "rbxassetid://4483362458"
})

local ShopTab = Window:CreateTab({
    Name = "Shop",
    Image = "rbxassetid://4483362458"
})

local InfoTab = Window:CreateTab({
    Name = "Инфо",
    Image = "rbxassetid://4483362458"
})

-- Dupe Tab Content
local DupeSection = DupeTab:CreateSection("Дюп предметов")

DupeSection:CreateButton({
    Name = "Dupe Item",
    Description = "Дюплицирует предмет в руках",
    Callback = dupeItem
})

DupeSection:CreateParagraph({
    Title = "Как пользоваться дюпом:",
    Content = "1. Возьми предмет в руки\n2. Нажми кнопку 'Dupe item' или клавишу F\n3. Предмет будет скопирован в рюкзак"
})

-- Shop Tab Content
local ShopSection = ShopTab:CreateSection("Магазины")

ShopSection:CreateButton({
    Name = "Seeds Shop",
    Description = "Открыть магазин семян",
    Callback = function()
        local seedShop = player.PlayerGui:FindFirstChild("Seed_Shop")
        if seedShop then
            seedShop.Enabled = not seedShop.Enabled
            createMessage("Магазин семян " .. (seedShop.Enabled and "открыт" or "закрыт"), "success")
        else
            createMessage("Магазин семян не найден", "error")
        end
    end
})

ShopSection:CreateButton({
    Name = "Gear Shop",
    Description = "Открыть магазин инструментов",
    Callback = function()
        local gearShop = player.PlayerGui:FindFirstChild("Gear_Shop")
        if gearShop then
            gearShop.Enabled = not gearShop.Enabled
            createMessage("Магазин инструментов " .. (gearShop.Enabled and "открыт" or "закрыт"), "success")
        else
            createMessage("Магазин инструментов не найден", "error")
        end
    end
})

ShopSection:CreateButton({
    Name = "Event Shop",
    Description = "Открыть магазин ивентов",
    Callback = function()
        local eventShop = player.PlayerGui:FindFirstChild("EventShop_UI")
        if eventShop then
            eventShop.Enabled = not eventShop.Enabled
            createMessage("Магазин ивентов " .. (eventShop.Enabled and "открыт" or "закрыт"), "success")
        else
            createMessage("Магазин ивентов не найден", "error")
        end
    end
})

ShopSection:CreateButton({
    Name = "Daily Quests",
    Description = "Открыть ежедневные задания",
    Callback = function()
        local questsShop = player.PlayerGui:FindFirstChild("DailyQuests_UI")
        if questsShop then
            questsShop.Enabled = not questsShop.Enabled
            createMessage("Ежедневные задания " .. (questsShop.Enabled and "открыты" or "закрыты"), "success")
        else
            createMessage("Ежедневные задания не найдены", "error")
        end
    end
})

ShopSection:CreateButton({
    Name = "Cosmetic Shop",
    Description = "Открыть магазин косметики",
    Callback = function()
        local cosmeticShop = player.PlayerGui:FindFirstChild("CosmeticShop_UI")
        if cosmeticShop then
            cosmeticShop.Enabled = not cosmeticShop.Enabled
            createMessage("Магазин косметики " .. (cosmeticShop.Enabled and "открыт" or "закрыт"), "success")
        else
            createMessage("Магазин косметики не найден", "error")
        end
    end
})

-- Info Tab Content
local InfoSection = InfoTab:CreateSection("Информация о скрипте")

InfoSection:CreateParagraph({
    Title = "Создатель:",
    Content = "Terfi Script"
})

InfoSection:CreateParagraph({
    Title = "Скрипт создан:",
    Content = "02.07.2025"
})

InfoSection:CreateParagraph({
    Title = "Игра:",
    Content = "Grow a Garden"
})

InfoSection:CreateParagraph({
    Title = "Telegram канал:",
    Content = "terfiscript"
})

InfoSection:CreateButton({
    Name = "Копировать Telegram",
    Description = "Скопировать ссылку на Telegram канал",
    Callback = function()
        setclipboard("https://t.me/terfiscript")
        createMessage("Ссылка скопирована в буфер обмена!", "success")
    end
})

-- Keyboard shortcuts
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.LeftControl then
        Window:Toggle()
    elseif input.KeyCode == Enum.KeyCode.F then
        dupeItem()
    end
end)

-- Key System (Optional - can be removed if not needed)
local KeySystem = Window:CreateKeySystem({
    Title = "Terfi Script Key System",
    Note = "Получите ключ в нашем Telegram канале: terfiscript",
    FileName = "TerfiScriptKey",
    GrabKeyFromSite = false,
    Key = "TerfiScript2024"
})

KeySystem.Finished = function()
    createMessage("Скрипт загружен! Left Ctrl - скрыть/показать", "success")
end

-- Initialize the window
Window:Init()
