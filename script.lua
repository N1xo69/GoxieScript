-- Goxie Script Menu (ФИНАЛ: поля ввода + конфиги)
-- Нажмите Right Shift для открытия меню

local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
local frame = Instance.new("Frame")
local title = Instance.new("TextLabel")
local closeBtn = Instance.new("TextButton")

-- Вкладки
local tabsFrame = Instance.new("Frame")
local tabFOV = Instance.new("TextButton")
local tabResolution = Instance.new("TextButton")
local tabSkybox = Instance.new("TextButton")
local tabESP = Instance.new("TextButton")
local tabMisc = Instance.new("TextButton")
local tabSettings = Instance.new("TextButton")
local tabConfigs = Instance.new("TextButton")  -- новая вкладка

-- Контент
local contentContainer = Instance.new("ScrollingFrame")
local contentList = Instance.new("UIListLayout")

-- --- FOV ---
local fovToggleBtn = Instance.new("TextButton")
local fovStatus = Instance.new("TextLabel")
local fovInputBox = Instance.new("TextBox")

-- --- RESOLUTION ---
local resToggleBtn = Instance.new("TextButton")
local resStatus = Instance.new("TextLabel")

-- --- SKYBOX ---
local skyboxInput = Instance.new("TextBox")
local skyboxApplyBtn = Instance.new("TextButton")
local skyboxResetBtn = Instance.new("TextButton")
local skyboxStatus = Instance.new("TextLabel")

-- --- ESP ---
local espInput = Instance.new("TextBox")
local espRefreshBtn = Instance.new("TextButton")
local espAddBtn = Instance.new("TextButton")
local espRemoveAllBtn = Instance.new("TextButton")
local playersListBox = Instance.new("ScrollingFrame")
local espListBox = Instance.new("ScrollingFrame")
local espStatusLabel = Instance.new("TextLabel")

-- --- MISC ---
local teleportBtn = Instance.new("TextButton")
local teleportBindBtn = Instance.new("TextButton")
local teleportBindStatus = Instance.new("TextLabel")
local teleportKey = Enum.KeyCode.Z
local waitingForTeleportBind = false

-- --- SETTINGS ---
local menuBindBtn = Instance.new("TextButton")
local menuBindStatus = Instance.new("TextLabel")
local friendsStatusLabel = Instance.new("TextLabel")

-- --- НАСТРОЙКИ ВНЕШНЕГО ВИДА ---
local transparencyInput = Instance.new("TextBox")
local widthInput = Instance.new("TextBox")
local heightInput = Instance.new("TextBox")
local colorR = Instance.new("TextBox")
local colorG = Instance.new("TextBox")
local colorB = Instance.new("TextBox")
local colorApplyBtn = Instance.new("TextButton")
local colorPreview = Instance.new("Frame")

-- --- КОНФИГИ ---
local configListBox = Instance.new("ScrollingFrame")
local configNameInput = Instance.new("TextBox")
local saveConfigBtn = Instance.new("TextButton")
local loadConfigBtn = Instance.new("TextButton")
local deleteConfigBtn = Instance.new("TextButton")
local configStatus = Instance.new("TextLabel")

local fpsLabel = Instance.new("TextLabel")
local notificationContainer = Instance.new("Frame")
local loadingFrame = Instance.new("Frame")
local blurEffect = Instance.new("BlurEffect")
local loadingText = Instance.new("TextLabel")
local loadingSubText = Instance.new("TextLabel")

gui.Name = "GoxieScriptGUI"
gui.Parent = game.CoreGui
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- === НАЧАЛЬНЫЕ НАСТРОЙКИ МЕНЮ ===
local menuTransparency = 85
local menuWidth = 800
local menuHeight = 500
local menuColor = Color3.fromRGB(18, 18, 22)

-- === СИСТЕМА КОНФИГОВ ===
local configs = {}
local currentConfig = nil

local function loadConfigsFromStorage()
    local success, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile("GoxieConfigs.json"))
    end)
    if success and data then
        configs = data
    else
        configs = {}
    end
end

local function saveConfigsToStorage()
    local success, err = pcall(function()
        writefile("GoxieConfigs.json", game:GetService("HttpService"):JSONEncode(configs))
    end)
    if not success then
        warn("Не удалось сохранить конфиги: " .. tostring(err))
    end
end

local function saveCurrentConfig(name)
    local config = {
        name = name,
        menuTransparency = menuTransparency,
        menuWidth = menuWidth,
        menuHeight = menuHeight,
        menuColor = {R = menuColor.R * 255, G = menuColor.G * 255, B = menuColor.B * 255},
        currentBind = currentBind.Name,
        teleportKey = teleportKey.Name,
        lastFOV = currentFOV
    }
    configs[name] = config
    saveConfigsToStorage()
    updateConfigListDisplay()
    showNotification("💾 Конфиг '" .. name .. "' сохранён!", false)
    playNotifySound()
end

local function loadConfig(name)
    local config = configs[name]
    if not then
        showNotification("❌ Конфиг не найден", true)
        playNotifySound()
        return
    end
    
    menuTransparency = config.menuTransparency or 85
    menuWidth = config.menuWidth or 800
    menuHeight = config.menuHeight or 500
    if config.menuColor then
        menuColor = Color3.fromRGB(config.menuColor.R, config.menuColor.G, config.menuColor.B)
    end
    if config.currentBind then
        currentBind = Enum.KeyCode[config.currentBind] or Enum.KeyCode.RightShift
        updateBindDisplay()
    end
    if config.teleportKey then
        teleportKey = Enum.KeyCode[config.teleportKey] or Enum.KeyCode.Z
        updateTeleportBindDisplay()
    end
    if config.lastFOV then
        currentFOV = config.lastFOV
        fovInputBox.Text = tostring(currentFOV)
        if fovActive then camera.FieldOfView = currentFOV end
        updateSliderPosition(currentFOV)
    end
    
    updateMenuAppearance()
    updateTransparencyDisplay()
    updateWidthDisplay()
    updateHeightDisplay()
    updateColorPreview()
    
    showNotification("🔄 Конфиг '" .. name .. "' загружен!", false)
    playNotifySound()
end

local function deleteConfig(name)
    if configs[name] then
        configs[name] = nil
        saveConfigsToStorage()
        updateConfigListDisplay()
        showNotification("🗑️ Конфиг '" .. name .. "' удалён!", false)
        playNotifySound()
    end
end

local function updateConfigListDisplay()
    for _, child in ipairs(configListBox:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local y = 0
    for name, _ in pairs(configs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 25)
        btn.Position = UDim2.new(0, 5, 0, y)
        btn.Text = name
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        btn.BackgroundTransparency = 0.3
        btn.TextColor3 = Color3.fromRGB(200, 200, 210)
        btn.TextSize = 12
        btn.Font = Enum.Font.Gotham
        btn.BorderSizePixel = 0
        btn.Parent = configListBox
        
        local loadBtn = Instance.new("TextButton")
        loadBtn.Size = UDim2.new(0.2, 0, 0, 20)
        loadBtn.Position = UDim2.new(0.78, 0, 0, 2)
        loadBtn.Text = "ЗАГР"
        loadBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 40)
        loadBtn.TextColor3 = Color3.fromRGB(150, 200, 150)
        loadBtn.TextSize = 10
        loadBtn.Font = Enum.Font.GothamBold
        loadBtn.BorderSizePixel = 0
        loadBtn.Parent = btn
        loadBtn.MouseButton1Click:Connect(function()
            loadConfig(name)
        end)
        setupButtonHover(loadBtn)
        
        local delBtn = Instance.new("TextButton")
        delBtn.Size = UDim2.new(0.2, 0, 0, 20)
        delBtn.Position = UDim2.new(0.98, -50, 0, 2)
        delBtn.Text = "УДАЛ"
        delBtn.BackgroundColor3 = Color3.fromRGB(50, 40, 40)
        delBtn.TextColor3 = Color3.fromRGB(200, 150, 150)
        delBtn.TextSize = 10
        delBtn.Font = Enum.Font.GothamBold
        delBtn.BorderSizePixel = 0
        delBtn.Parent = btn
        delBtn.MouseButton1Click:Connect(function()
            deleteConfig(name)
        end)
        setupButtonHover(delBtn)
        
        setupButtonHover(btn)
        y = y + 30
    end
    configListBox.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

loadConfigsFromStorage()

-- === ЗВУК ===
local function playNotifySound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://82845990304289"
    sound.Volume = 0.4
    sound.Parent = gui
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 3)
end

-- === ЗАГРУЗОЧНЫЙ ЭКРАН ===
local lighting = game:GetService("Lighting")
blurEffect.Size = 0
blurEffect.Parent = lighting

loadingFrame.Size = UDim2.new(1, 0, 1, 0)
loadingFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
loadingFrame.BackgroundTransparency = 0.15
loadingFrame.Parent = gui

loadingText.Size = UDim2.new(0, 400, 0, 50)
loadingText.Position = UDim2.new(0.5, -200, 0.5, -60)
loadingText.BackgroundTransparency = 1
loadingText.Text = "GOXIE SCRIPT"
loadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingText.TextSize = 40
loadingText.Font = Enum.Font.GothamBold
loadingText.TextXAlignment = Enum.TextXAlignment.Center
loadingText.Parent = loadingFrame

loadingSubText.Size = UDim2.new(0, 300, 0, 30)
loadingSubText.Position = UDim2.new(0.5, -150, 0.5, -10)
loadingSubText.BackgroundTransparency = 1
loadingSubText.Text = "Представляет..."
loadingSubText.TextColor3 = Color3.fromRGB(200, 200, 200)
loadingSubText.TextSize = 20
loadingSubText.Font = Enum.Font.Gotham
loadingSubText.TextXAlignment = Enum.TextXAlignment.Center
loadingSubText.Parent = loadingFrame

playNotifySound()

for i = 0, 20 do blurEffect.Size = i wait(0.02) end
wait(1)
for i = 20, 0, -1 do blurEffect.Size = i wait(0.02) end
loadingFrame:Destroy()
blurEffect:Destroy()

frame.Visible = false

local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- === ФУНКЦИИ ОБНОВЛЕНИЯ МЕНЮ ===
local function updateMenuAppearance()
    frame.Size = UDim2.new(0, menuWidth, 0, menuHeight)
    frame.Position = UDim2.new(0.5, -menuWidth/2, 0.5, -menuHeight/2)
    frame.BackgroundTransparency = 1 - (menuTransparency / 100)
    frame.BackgroundColor3 = menuColor
    updateColorPreview()
end

local function updateTransparencyDisplay()
    transparencyInput.Text = tostring(menuTransparency)
end

local function updateWidthDisplay()
    widthInput.Text = tostring(menuWidth)
end

local function updateHeightDisplay()
    heightInput.Text = tostring(menuHeight)
end

local function updateColorPreview()
    colorPreview.BackgroundColor3 = menuColor
    colorR.Text = tostring(math.floor(menuColor.R * 255))
    colorG.Text = tostring(math.floor(menuColor.G * 255))
    colorB.Text = tostring(math.floor(menuColor.B * 255))
end

-- === ТЕЛЕПОРТ ===
local function teleportToMouse()
    local mouse = player:GetMouse()
    local hit = mouse.Hit
    if hit and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(hit.X, hit.Y + 3, hit.Z)
    end
end

local function updateTeleportBindDisplay()
    teleportBindBtn.Text = teleportKey.Name
    teleportBindStatus.Text = "Клавиша: " .. teleportKey.Name
end

local function setTeleportBind(key)
    teleportKey = key
    updateTeleportBindDisplay()
    showNotification("🔑 Телепорт на " .. key.Name, false)
    playNotifySound()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if waitingForTeleportBind then
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            setTeleportBind(input.KeyCode)
            waitingForTeleportBind = false
            teleportBindBtn.Text = teleportKey.Name
            teleportBindStatus.Text = "Клавиша: " .. teleportKey.Name
            wait(1)
            teleportBindStatus.Text = "Нажми для смены"
            teleportBindStatus.TextColor3 = Color3.fromRGB(140, 140, 155)
        end
        return
    end
    if input.KeyCode == teleportKey then
        teleportToMouse()
    end
end)

-- === ДРУЗЬЯ ===
local friends = {}
local friendStatus = {}

local function updateFriendsList()
    friends = {}
    friendStatus = {}
    local success, result = pcall(function()
        return game:GetService("FriendsService"):GetFriendsAsync(player.UserId):GetCurrentPage()
    end)
    if success and result then
        for _, friendData in ipairs(result) do
            friends[friendData.Id] = friendData.Username
            friendStatus[friendData.Id] = false
        end
    end
    friendsStatusLabel.Text = "Друзей: " .. (#friends)
end

local function checkFriendsInGame()
    local playersList_local = game.Players:GetPlayers()
    local onlineFriends = {}
    for _, plr in ipairs(playersList_local) do
        for id, name in pairs(friends) do
            if plr.UserId == id then
                onlineFriends[id] = true
                if not friendStatus[id] then
                    friendStatus[id] = true
                    showNotification("🟢 Друг " .. name .. " зашёл в игру!", false)
                    playNotifySound()
                end
            end
        end
    end
    for id, wasOnline in pairs(friendStatus) do
        if wasOnline and not onlineFriends[id] then
            friendStatus[id] = false
            showNotification("🔴 Друг " .. friends[id] .. " вышел из игры", true)
            playNotifySound()
        end
    end
end

updateFriendsList()
checkFriendsInGame()

spawn(function()
    while true do
        wait(5)
        updateFriendsList()
        checkFriendsInGame()
    end
end)

game.Players.PlayerAdded:Connect(function(plr)
    for id, name in pairs(friends) do
        if plr.UserId == id and not friendStatus[id] then
            friendStatus[id] = true
            showNotification("🟢 Друг " .. name .. " зашёл в игру!", false)
            playNotifySound()
        end
    end
end)

game.Players.PlayerRemoving:Connect(function(plr)
    for id, name in pairs(friends) do
        if plr.UserId == id and friendStatus[id] then
            friendStatus[id] = false
            showNotification("🔴 Друг " .. name .. " вышел из игры", true)
            playNotifySound()
        end
    end
end)

-- === SKYBOX ===
local originalSkybox = nil

local function saveOriginalSkybox()
    local sky = lighting:FindFirstChildWhichIsA("Sky")
    if not sky then
        sky = Instance.new("Sky")
        sky.Parent = lighting
    end
    originalSkybox = {
        SkyboxBk = sky.SkyboxBk,
        SkyboxDn = sky.SkyboxDn,
        SkyboxFt = sky.SkyboxFt,
        SkyboxLf = sky.SkyboxLf,
        SkyboxRt = sky.SkyboxRt,
        SkyboxUp = sky.SkyboxUp
    }
end

local function applySkybox(id)
    local assetId = tonumber(id)
    if not assetId then
        skyboxStatus.Text = "Ошибка"
        skyboxStatus.TextColor3 = Color3.fromRGB(200, 120, 120)
        return
    end
    if not originalSkybox then saveOriginalSkybox() end
    local sky = lighting:FindFirstChildWhichIsA("Sky")
    if not sky then sky = Instance.new("Sky") sky.Parent = lighting end
    local url = "rbxassetid://" .. assetId
    sky.SkyboxBk = url
    sky.SkyboxDn = url
    sky.SkyboxFt = url
    sky.SkyboxLf = url
    sky.SkyboxRt = url
    sky.SkyboxUp = url
    skyboxStatus.Text = "Готово: " .. assetId
    skyboxStatus.TextColor3 = Color3.fromRGB(120, 200, 120)
    showNotification("🌤️ Небо изменено", false)
    playNotifySound()
end

local function resetSkybox()
    if originalSkybox then
        local sky = lighting:FindFirstChildWhichIsA("Sky")
        if not sky then sky = Instance.new("Sky") sky.Parent = lighting end
        sky.SkyboxBk = originalSkybox.SkyboxBk
        sky.SkyboxDn = originalSkybox.SkyboxDn
        sky.SkyboxFt = originalSkybox.SkyboxFt
        sky.SkyboxLf = originalSkybox.SkyboxLf
        sky.SkyboxRt = originalSkybox.SkyboxRt
        sky.SkyboxUp = originalSkybox.SkyboxUp
        skyboxStatus.Text = "Сброшено"
        skyboxStatus.TextColor3 = Color3.fromRGB(140, 140, 155)
        showNotification("🔄 Небо сброшено", false)
        playNotifySound()
    end
end

-- === ESP ===
local espListData = {}

local function createNametag(character, name)
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 250, 0, 40)
    billboard.Adornee = character:FindFirstChild("Head") or character
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = character
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Text = name
    label.TextSize = 16
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0.3
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Parent = billboard
    return billboard
end

local function addESP(target)
    if espListData[target] then return false end
    if target == player then return false end
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(0, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
    highlight.FillTransparency = 0.5
    
    local nametag = nil
    if target.Character then
        highlight.Parent = target.Character
        nametag = createNametag(target.Character, target.Name)
    end
    
    local charAdded = target.CharacterAdded:Connect(function(character)
        highlight.Parent = character
        if nametag then nametag:Destroy() end
        nametag = createNametag(character, target.Name)
    end)
    
    local charRemoving = target.CharacterRemoving:Connect(function()
        highlight.Parent = nil
        if nametag then nametag:Destroy() end
        nametag = nil
    end)
    
    espListData[target] = {
        highlight = highlight,
        nametag = nametag,
        added = charAdded,
        removing = charRemoving
    }
    updateESPDisplay()
    return true
end

local function removeESP(target)
    local data = espListData[target]
    if not data then return end
    data.highlight:Destroy()
    if data.nametag then data.nametag:Destroy() end
    data.added:Disconnect()
    data.removing:Disconnect()
    espListData[target] = nil
    updateESPDisplay()
end

local function removeAllESP()
    for plr, _ in pairs(espListData) do
        removeESP(plr)
    end
end

local function updateESPDisplay()
    for _, child in ipairs(espListBox:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local y = 0
    for plr, _ in pairs(espListData) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 22)
        btn.Position = UDim2.new(0, 5, 0, y)
        btn.Text = plr.Name .. " ✖"
        btn.BackgroundColor3 = Color3.fromRGB(30, 20, 20)
        btn.BackgroundTransparency = 0.3
        btn.TextColor3 = Color3.fromRGB(255, 150, 150)
        btn.TextSize = 12
        btn.Font = Enum.Font.Gotham
        btn.BorderSizePixel = 0
        btn.Parent = espListBox
        btn.MouseButton1Click:Connect(function()
            removeESP(plr)
            showNotification("❌ ESP выключен для " .. plr.Name, false)
            playNotifySound()
            local count = 0 for _ in pairs(espListData) do count = count + 1 end
            espStatusLabel.Text = count > 0 and "Активно: " .. count or "Нет активных"
        end)
        setupButtonHover(btn)
        y = y + 27
    end
    espListBox.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

local function updatePlayersList()
    for _, child in ipairs(playersListBox:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local players = game.Players:GetPlayers()
    local y = 0
    for _, plr in ipairs(players) do
        if plr ~= player then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 22)
            btn.Position = UDim2.new(0, 5, 0, y)
            btn.Text = plr.Name
            btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
            btn.BackgroundTransparency = 0.3
            btn.TextColor3 = Color3.fromRGB(200, 200, 210)
            btn.TextSize = 12
            btn.Font = Enum.Font.Gotham
            btn.BorderSizePixel = 0
            btn.Parent = playersListBox
            btn.MouseButton1Click:Connect(function()
                espInput.Text = plr.Name
            end)
            setupButtonHover(btn)
            y = y + 27
        end
    end
    playersListBox.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

-- === НАСТРОЙКА БИНДА МЕНЮ ===
local currentBind = Enum.KeyCode.RightShift
local waitingForBind = false

local function updateBindDisplay()
    menuBindBtn.Text = currentBind.Name
    menuBindStatus.Text = "Бинд: " .. currentBind.Name
end

local function setBind(key)
    currentBind = key
    updateBindDisplay()
    showNotification("🔑 Бинд меню: " .. key.Name, false)
    playNotifySound()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if waitingForBind then
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            setBind(input.KeyCode)
            waitingForBind = false
            menuBindBtn.Text = currentBind.Name
            menuBindStatus.Text = "Бинд: " .. currentBind.Name
            wait(1)
            menuBindStatus.Text = "Нажми для смены"
            menuBindStatus.TextColor3 = Color3.fromRGB(140, 140, 155)
        end
        return
    end
    if input.KeyCode == currentBind then
        frame.Visible = not frame.Visible
    end
end)

-- === ПОДСВЕТКА ===
function setupButtonHover(button)
    local origColor = button.BackgroundColor3
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = origColor
    end)
end

-- === УВЕДОМЛЕНИЯ ===
notificationContainer.Size = UDim2.new(0, 320, 0, 200)
notificationContainer.Position = UDim2.new(1, -330, 0, 10)
notificationContainer.BackgroundTransparency = 1
notificationContainer.Parent = gui

function showNotification(msg, isError)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, -10, 0, 35)
    notif.Position = UDim2.new(0, 5, 0, 0)
    notif.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    notif.BackgroundTransparency = 0.15
    notif.BorderSizePixel = 0
    notif.Parent = notificationContainer
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = msg
    text.TextColor3 = isError and Color3.fromRGB(255, 120, 120) or Color3.fromRGB(120, 255, 120)
    text.TextSize = 13
    text.Font = Enum.Font.Gotham
    text.TextXAlignment = Enum.TextXAlignment.Center
    text.Parent = notif
    notif.Position = UDim2.new(0, 5, 0, -50)
    for i = 1, 5 do
        notif.Position = UDim2.new(0, 5, 0, notif.Position.Y.Offset + 10)
        wait(0.02)
    end
    local y = 0
    for _, child in ipairs(notificationContainer:GetChildren()) do
        if child:IsA("Frame") and child ~= notif then
            child.Position = UDim2.new(0, 5, 0, y)
            y = y + 40
        end
    end
    notif.Position = UDim2.new(0, 5, 0, y)
    game:GetService("Debris"):AddItem(notif, 2.5)
    wait(2.3)
    for i = 1, 5 do
        notif.BackgroundTransparency = notif.BackgroundTransparency + 0.2
        wait(0.02)
    end
    notif:Destroy()
    local y2 = 0
    for _, child in ipairs(notificationContainer:GetChildren()) do
        if child:IsA("Frame") then
            child.Position = UDim2.new(0, 5, 0, y2)
            y2 = y2 + 40
        end
    end
end

-- === ОСНОВНОЕ ОКНО ===
frame.Size = UDim2.new(0, menuWidth, 0, menuHeight)
frame.Position = UDim2.new(0.5, -menuWidth/2, 0.5, -menuHeight/2)
frame.BackgroundColor3 = menuColor
frame.BackgroundTransparency = 1 - (menuTransparency / 100)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- ЗАГОЛОВОК
title.Size = UDim2.new(1, 0, 0, 45)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
title.BackgroundTransparency = 0.2
title.Text = "GOXIE SCRIPT"
title.TextColor3 = Color3.fromRGB(220, 220, 230)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = frame

-- КНОПКА ЗАКРЫТИЯ
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 8)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
closeBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
closeBtn.BackgroundTransparency = 0
closeBtn.BorderSizePixel = 0
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function() frame.Visible = false end)
setupButtonHover(closeBtn)

-- ВКЛАДКИ
tabsFrame.Size = UDim2.new(1, 0, 0, 35)
tabsFrame.Position = UDim2.new(0, 0, 0, 45)
tabsFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
tabsFrame.BackgroundTransparency = 0.2
tabsFrame.Parent = frame

local tabs = {tabFOV, tabResolution, tabSkybox, tabESP, tabMisc, tabSettings, tabConfigs}
local tabNames = {"FOV", "RES", "SKYBOX", "ESP", "MISC", "SET", "CONFIGS"}
local tabContents = {}

for i, tab in ipairs(tabs) do
    tab.Size = UDim2.new(0.142, 0, 1, 0)
    tab.Position = UDim2.new((i-1) * 0.142, 0, 0, 0)
    tab.Text = tabNames[i]
    tab.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    tab.BackgroundTransparency = 0.2
    tab.TextColor3 = Color3.fromRGB(160, 160, 170)
    tab.TextSize = 12
    tab.Font = Enum.Font.GothamBold
    tab.BorderSizePixel = 0
    tab.Parent = tabsFrame
    tab.MouseButton1Click:Connect(function()
        for j, t in ipairs(tabs) do
            t.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
            t.TextColor3 = Color3.fromRGB(160, 160, 170)
            if tabContents[j] then tabContents[j].Visible = false end
        end
        tab.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        tab.TextColor3 = Color3.fromRGB(255, 255, 255)
        if tabContents[i] then tabContents[i].Visible = true end
    end)
    setupButtonHover(tab)
end

-- КОНТЕЙНЕР КОНТЕНТА
contentContainer.Size = UDim2.new(1, -20, 1, -85)
contentContainer.Position = UDim2.new(0, 10, 0, 85)
contentContainer.BackgroundTransparency = 1
contentContainer.BorderSizePixel = 0
contentContainer.ScrollBarThickness = 4
contentContainer.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 60)
contentContainer.Parent = frame

contentList.SortOrder = Enum.SortOrder.LayoutOrder
contentList.Padding = UDim.new(0, 12)
contentList.Parent = contentContainer

-- === FOV КОНТЕНТ ===
local fovContent = Instance.new("Frame")
fovContent.Size = UDim2.new(1, 0, 0, 150)
fovContent.BackgroundTransparency = 1
fovContent.Parent = contentContainer
table.insert(tabContents, fovContent)

local fovTitle = Instance.new("TextLabel")
fovTitle.Size = UDim2.new(1, 0, 0, 25)
fovTitle.BackgroundTransparency = 1
fovTitle.Text = "FOV LOCK"
fovTitle.TextColor3 = Color3.fromRGB(200, 200, 210)
fovTitle.TextSize = 14
fovTitle.Font = Enum.Font.GothamBold
fovTitle.TextXAlignment = Enum.TextXAlignment.Left
fovTitle.Parent = fovContent

fovToggleBtn.Size = UDim2.new(1, 0, 0, 32)
fovToggleBtn.Position = UDim2.new(0, 0, 0, 30)
fovToggleBtn.Text = "ВЫКЛ"
fovToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
fovToggleBtn.BackgroundTransparency = 0.3
fovToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
fovToggleBtn.TextSize = 12
fovToggleBtn.Font = Enum.Font.GothamBold
fovToggleBtn.BorderSizePixel = 0
fovToggleBtn.Parent = fovContent
setupButtonHover(fovToggleBtn)

local fovInputLabel = Instance.new("TextLabel")
fovInputLabel.Size = UDim2.new(0.5, 0, 0, 20)
fovInputLabel.Position = UDim2.new(0, 0, 0, 72)
fovInputLabel.BackgroundTransparency = 1
fovInputLabel.Text = "ЗНАЧЕНИЕ FOV (80-140):"
fovInputLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
fovInputLabel.TextSize = 11
fovInputLabel.Font = Enum.Font.Gotham
fovInputLabel.TextXAlignment = Enum.TextXAlignment.Left
fovInputLabel.Parent = fovContent

fovInputBox.Size = UDim2.new(0.3, 0, 0, 30)
fovInputBox.Position = UDim2.new(0.55, 0, 0, 68)
fovInputBox.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
fovInputBox.BackgroundTransparency = 0.3
fovInputBox.TextColor3 = Color3.fromRGB(210, 210, 220)
fovInputBox.TextSize = 14
fovInputBox.Font = Enum.Font.Gotham
fovInputBox.BorderSizePixel = 0
fovInputBox.Text = "85"
fovInputBox.PlaceholderText = "85"
fovInputBox.ClearTextOnFocus = true
fovInputBox.Parent = fovContent

fovStatus.Size = UDim2.new(1, 0, 0, 20)
fovStatus.Position = UDim2.new(0, 0, 0, 110)
fovStatus.BackgroundTransparency = 1
fovStatus.Text = "STATUS: OFF"
fovStatus.TextColor3 = Color3.fromRGB(140, 140, 155)
fovStatus.TextSize = 10
fovStatus.Font = Enum.Font.Gotham
fovStatus.TextXAlignment = Enum.TextXAlignment.Left
fovStatus.Parent = fovContent

-- === FOV ЛОГИКА ===
local fovActive = false
local fovConn = nil
local currentFOV = 85
local minFOV = 80
local maxFOV = 140

local function updateFOVFromInput()
    local v = tonumber(fovInputBox.Text)
    if v and v >= minFOV and v <= maxFOV then
        currentFOV = v
        if fovActive then camera.FieldOfView = currentFOV end
        showNotification("✅ FOV установлен на " .. currentFOV, false)
        playNotifySound()
    else
        showNotification("❌ Введите число от 80 до 140", true)
        playNotifySound()
        fovInputBox.Text = tostring(currentFOV)
    end
end

fovInputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then updateFOVFromInput() end
end)

fovToggleBtn.MouseButton1Click:Connect(function()
    if fovActive then
        if fovConn then fovConn:Disconnect() end
        fovConn = nil
        camera.FieldOfView = 70
        fovActive = false
        fovStatus.Text = "STATUS: OFF"
        fovStatus.TextColor3 = Color3.fromRGB(140, 140, 155)
        fovToggleBtn.Text = "ВЫКЛ"
        showNotification("🔒 FOV Lock выключен", false)
        playNotifySound()
    else
        fovConn = camera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
            if camera.FieldOfView ~= currentFOV then
                camera.FieldOfView = currentFOV
            end
        end)
        camera.FieldOfView = currentFOV
        fovActive = true
        fovStatus.Text = "STATUS: ON (" .. currentFOV .. ")"
        fovStatus.TextColor3 = Color3.fromRGB(170, 190, 170)
        fovToggleBtn.Text = "ВКЛ"
        showNotification("🔒 FOV Lock включён на " .. currentFOV, false)
        playNotifySound()
    end
end)

-- === RESOLUTION КОНТЕНТ ===
local resContent = Instance.new("Frame")
resContent.Size = UDim2.new(1, 0, 0, 100)
resContent.BackgroundTransparency = 1
resContent.Parent = contentContainer
resContent.Visible = false
table.insert(tabContents, resContent)

local resTitle = Instance.new("TextLabel")
resTitle.Size = UDim2.new(1, 0, 0, 25)
resTitle.BackgroundTransparency = 1
resTitle.Text = "RESOLUTION MOD"
resTitle.TextColor3 = Color3.fromRGB(200, 200, 210)
resTitle.TextSize = 14
resTitle.Font = Enum.Font.GothamBold
resTitle.TextXAlignment = Enum.TextXAlignment.Left
resTitle.Parent = resContent

resToggleBtn.Size = UDim2.new(1, 0, 0, 32)
resToggleBtn.Position = UDim2.new(0, 0, 0, 30)
resToggleBtn.Text = "ВЫКЛ"
resToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
resToggleBtn.BackgroundTransparency = 0.3
resToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
resToggleBtn.TextSize = 12
resToggleBtn.Font = Enum.Font.GothamBold
resToggleBtn.BorderSizePixel = 0
resToggleBtn.Parent = resContent
setupButtonHover(resToggleBtn)

resStatus.Size = UDim2.new(1, 0, 0, 20)
resStatus.Position = UDim2.new(0, 0, 0, 70)
resStatus.BackgroundTransparency = 1
resStatus.Text = "STATUS: OFF"
resStatus.TextColor3 = Color3.fromRGB(140, 140, 155)
resStatus.TextSize = 10
resStatus.Font = Enum.Font.Gotham
resStatus.TextXAlignment = Enum.TextXAlignment.Left
resStatus.Parent = resContent

local resActive = false
local resConn = nil

resToggleBtn.MouseButton1Click:Connect(function()
    if resActive then
        if resConn then resConn:Disconnect() end
        resConn = nil
        resActive = false
        resStatus.Text = "STATUS: OFF"
        resStatus.TextColor3 = Color3.fromRGB(140, 140, 155)
        resToggleBtn.Text = "ВЫКЛ"
        showNotification("🔧 Resolution Mod выключен", false)
        playNotifySound()
    else
        resConn = RunService.RenderStepped:Connect(function()
            camera.CFrame = camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.80, 0, 0, 0, 1)
        end)
        resActive = true
        resStatus.Text = "STATUS: ON"
        resStatus.TextColor3 = Color3.fromRGB(170, 190, 170)
        resToggleBtn.Text = "ВКЛ"
        showNotification("🔧 Resolution Mod включён", false)
        playNotifySound()
    end
end)

-- === SKYBOX КОНТЕНТ ===
local skyboxContent = Instance.new("Frame")
skyboxContent.Size = UDim2.new(1, 0, 0, 140)
skyboxContent.BackgroundTransparency = 1
skyboxContent.Parent = contentContainer
skyboxContent.Visible = false
table.insert(tabContents, skyboxContent)

local skyboxTitle = Instance.new("TextLabel")
skyboxTitle.Size = UDim2.new(1, 0, 0, 25)
skyboxTitle.BackgroundTransparency = 1
skyboxTitle.Text = "SKYBOX CHANGER"
skyboxTitle.TextColor3 = Color3.fromRGB(200, 200, 210)
skyboxTitle.TextSize = 14
skyboxTitle.Font = Enum.Font.GothamBold
skyboxTitle.TextXAlignment = Enum.TextXAlignment.Left
skyboxTitle.Parent = skyboxContent

skyboxInput.Size = UDim2.new(1, 0, 0, 30)
skyboxInput.Position = UDim2.new(0, 0, 0, 30)
skyboxInput.PlaceholderText = "ID неба"
skyboxInput.Text = ""
skyboxInput.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
skyboxInput.BackgroundTransparency = 0.3
skyboxInput.TextColor3 = Color3.fromRGB(210, 210, 220)
skyboxInput.TextSize = 12
skyboxInput.Font = Enum.Font.Gotham
skyboxInput.BorderSizePixel = 0
skyboxInput.Parent = skyboxContent

skyboxApplyBtn.Size = UDim2.new(0.48, 0, 0, 30)
skyboxApplyBtn.Position = UDim2.new(0, 0, 0, 68)
skyboxApplyBtn.Text = "ПРИМЕНИТЬ"
skyboxApplyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
skyboxApplyBtn.BackgroundTransparency = 0.3
skyboxApplyBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
skyboxApplyBtn.TextSize = 11
skyboxApplyBtn.Font = Enum.Font.GothamBold
skyboxApplyBtn.BorderSizePixel = 0
skyboxApplyBtn.Parent = skyboxContent
setupButtonHover(skyboxApplyBtn)

skyboxResetBtn.Size = UDim2.new(0.48, 0, 0, 30)
skyboxResetBtn.Position = UDim2.new(0.52, 0, 0, 68)
skyboxResetBtn.Text = "СБРОСИТЬ"
skyboxResetBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
skyboxResetBtn.BackgroundTransparency = 0.3
skyboxResetBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
skyboxResetBtn.TextSize = 11
skyboxResetBtn.Font = Enum.Font.GothamBold
skyboxResetBtn.BorderSizePixel = 0
skyboxResetBtn.Parent = skyboxContent
setupButtonHover(skyboxResetBtn)

skyboxStatus.Size = UDim2.new(1, 0, 0, 20)
skyboxStatus.Position = UDim2.new(0, 0, 0, 108)
skyboxStatus.BackgroundTransparency = 1
skyboxStatus.Text = "ГОТОВ"
skyboxStatus.TextColor3 = Color3.fromRGB(140, 140, 155)
skyboxStatus.TextSize = 10
skyboxStatus.Font = Enum.Font.Gotham
skyboxStatus.TextXAlignment = Enum.TextXAlignment.Left
skyboxStatus.Parent = skyboxContent

skyboxApplyBtn.MouseButton1Click:Connect(function() applySkybox(skyboxInput.Text) end)
skyboxResetBtn.MouseButton1Click:Connect(function() resetSkybox() end)

-- === ESP КОНТЕНТ ===
local espContent = Instance.new("Frame")
espContent.Size = UDim2.new(1, 0, 0, 340)
espContent.BackgroundTransparency = 1
espContent.Parent = contentContainer
espContent.Visible = false
table.insert(tabContents, espContent)

local espTitle = Instance.new("TextLabel")
espTitle.Size = UDim2.new(1, 0, 0, 25)
espTitle.BackgroundTransparency = 1
espTitle.Text = "ESP"
espTitle.TextColor3 = Color3.fromRGB(200, 200, 210)
espTitle.TextSize = 14
espTitle.Font = Enum.Font.GothamBold
espTitle.TextXAlignment = Enum.TextXAlignment.Left
espTitle.Parent = espContent

espInput.Size = UDim2.new(1, 0, 0, 30)
espInput.Position = UDim2.new(0, 0, 0, 30)
espInput.PlaceholderText = "Имя игрока"
espInput.Text = ""
espInput.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
espInput.BackgroundTransparency = 0.3
espInput.TextColor3 = Color3.fromRGB(210, 210, 220)
espInput.TextSize = 12
espInput.Font = Enum.Font.Gotham
espInput.BorderSizePixel = 0
espInput.Parent = espContent

espRefreshBtn.Size = UDim2.new(0.32, 0, 0, 28)
espRefreshBtn.Position = UDim2.new(0, 0, 0, 68)
espRefreshBtn.Text = "ОБНОВИТЬ"
espRefreshBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
espRefreshBtn.BackgroundTransparency = 0.3
espRefreshBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
espRefreshBtn.TextSize = 10
espRefreshBtn.Font = Enum.Font.GothamBold
espRefreshBtn.BorderSizePixel = 0
espRefreshBtn.Parent = espContent
setupButtonHover(espRefreshBtn)

espAddBtn.Size = UDim2.new(0.32, 0, 0, 28)
espAddBtn.Position = UDim2.new(0.34, 0, 0, 68)
espAddBtn.Text = "ДОБАВИТЬ"
espAddBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
espAddBtn.BackgroundTransparency = 0.3
espAddBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
espAddBtn.TextSize = 10
espAddBtn.Font = Enum.Font.GothamBold
espAddBtn.BorderSizePixel = 0
espAddBtn.Parent = espContent
setupButtonHover(espAddBtn)

espRemoveAllBtn.Size = UDim2.new(0.32, 0, 0, 28)
espRemoveAllBtn.Position = UDim2.new(0.68, 0, 0, 68)
espRemoveAllBtn.Text = "ОЧИСТИТЬ"
espRemoveAllBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
espRemoveAllBtn.BackgroundTransparency = 0.3
espRemoveAllBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
espRemoveAllBtn.TextSize = 10
espRemoveAllBtn.Font = Enum.Font.GothamBold
espRemoveAllBtn.BorderSizePixel = 0
espRemoveAllBtn.Parent = espContent
setupButtonHover(espRemoveAllBtn)

local playersListLabel = Instance.new("TextLabel")
playersListLabel.Size = UDim2.new(0.48, 0, 0, 18)
playersListLabel.Position = UDim2.new(0, 0, 0, 104)
playersListLabel.BackgroundTransparency = 1
playersListLabel.Text = "ИГРОКИ"
playersListLabel.TextColor3 = Color3.fromRGB(140, 140, 155)
playersListLabel.TextSize = 9
playersListLabel.Font = Enum.Font.GothamBold
playersListLabel.TextXAlignment = Enum.TextXAlignment.Left
playersListLabel.Parent = espContent

playersListBox.Size = UDim2.new(0.48, 0, 0, 100)
playersListBox.Position = UDim2.new(0, 0, 0, 122)
playersListBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
playersListBox.BackgroundTransparency = 0.2
playersListBox.BorderSizePixel = 0
playersListBox.ScrollBarThickness = 3
playersListBox.Parent = espContent

local espListLabel = Instance.new("TextLabel")
espListLabel.Size = UDim2.new(0.48, 0, 0, 18)
espListLabel.Position = UDim2.new(0.52, 0, 0, 104)
espListLabel.BackgroundTransparency = 1
espListLabel.Text = "ESP АКТИВЕН"
espListLabel.TextColor3 = Color3.fromRGB(140, 140, 155)
espListLabel.TextSize = 9
espListLabel.Font = Enum.Font.GothamBold
espListLabel.TextXAlignment = Enum.TextXAlignment.Left
espListLabel.Parent = espContent

espListBox.Size = UDim2.new(0.48, 0, 0, 100)
espListBox.Position = UDim2.new(0.52, 0, 0, 122)
espListBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
espListBox.BackgroundTransparency = 0.2
espListBox.BorderSizePixel = 0
espListBox.ScrollBarThickness = 3
espListBox.Parent = espContent

espStatusLabel.Size = UDim2.new(1, 0, 0, 18)
espStatusLabel.Position = UDim2.new(0, 0, 0, 230)
espStatusLabel.BackgroundTransparency = 1
espStatusLabel.Text = "Нет активных"
espStatusLabel.TextColor3 = Color3.fromRGB(140, 140, 155)
espStatusLabel.TextSize = 9
espStatusLabel.Font = Enum.Font.Gotham
espStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
espStatusLabel.Parent = espContent

espRefreshBtn.MouseButton1Click:Connect(function()
    updatePlayersList()
    showNotification("📋 Список обновлён", false)
    playNotifySound()
end)

espAddBtn.MouseButton1Click:Connect(function()
    local name = espInput.Text
    if name == "" then
        showNotification("❌ Введите имя", true)
        playNotifySound()
        return
    end
    local target = game.Players:FindFirstChild(name)
    if not target then
        showNotification("❌ Игрок не найден", true)
        playNotifySound()
        return
    end
    if addESP(target) then
        local count = 0 for _ in pairs(espListData) do count = count + 1 end
        showNotification("✅ ESP добавлен для " .. target.Name, false)
        playNotifySound()
        espStatusLabel.Text = "Активно: " .. count
    else
        showNotification("❌ Уже в ESP", true)
        playNotifySound()
    end
    espInput.Text = ""
end)

espRemoveAllBtn.MouseButton1Click:Connect(function()
    removeAllESP()
    showNotification("🗑️ Весь ESP отключён", false)
    playNotifySound()
    espStatusLabel.Text = "Нет активных"
end)

-- === MISC КОНТЕНТ ===
local miscContent = Instance.new("Frame")
miscContent.Size = UDim2.new(1, 0, 0, 140)
miscContent.BackgroundTransparency = 1
miscContent.Parent = contentContainer
miscContent.Visible = false
table.insert(tabContents, miscContent)

local miscTitle = Instance.new("TextLabel")
miscTitle.Size = UDim2.new(1, 0, 0, 25)
miscTitle.BackgroundTransparency = 1
miscTitle.Text = "ТЕЛЕПОРТ"
miscTitle.TextColor3 = Color3.fromRGB(200, 200, 210)
miscTitle.TextSize = 14
miscTitle.Font = Enum.Font.GothamBold
miscTitle.TextXAlignment = Enum.TextXAlignment.Left
miscTitle.Parent = miscContent

teleportBtn.Size = UDim2.new(1, 0, 0, 32)
teleportBtn.Position = UDim2.new(0, 0, 0, 30)
teleportBtn.Text = "ТЕЛЕПОРТ (КЛИК)"
teleportBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
teleportBtn.BackgroundTransparency = 0.3
teleportBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
teleportBtn.TextSize = 11
teleportBtn.Font = Enum.Font.GothamBold
teleportBtn.BorderSizePixel = 0
teleportBtn.Parent = miscContent
setupButtonHover(teleportBtn)

teleportBtn.MouseButton1Click:Connect(function()
    teleportToMouse()
end)

local teleportBindLabel = Instance.new("TextLabel")
teleportBindLabel.Size = UDim2.new(0.5, 0, 0, 20)
teleportBindLabel.Position = UDim2.new(0, 0, 0, 72)
teleportBindLabel.BackgroundTransparency = 1
teleportBindLabel.Text = "КЛАВИША"
teleportBindLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
teleportBindLabel.TextSize = 10
teleportBindLabel.Font = Enum.Font.Gotham
teleportBindLabel.TextXAlignment = Enum.TextXAlignment.Left
teleportBindLabel.Parent = miscContent

teleportBindBtn.Size = UDim2.new(0.3, 0, 0, 28)
teleportBindBtn.Position = UDim2.new(0.5, 0, 0, 68)
teleportBindBtn.Text = teleportKey.Name
teleportBindBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
teleportBindBtn.BackgroundTransparency = 0.3
teleportBindBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
teleportBindBtn.TextSize = 11
teleportBindBtn.Font = Enum.Font.GothamBold
teleportBindBtn.BorderSizePixel = 0
teleportBindBtn.Parent = miscContent
setupButtonHover(teleportBindBtn)

teleportBindStatus.Size = UDim2.new(1, 0, 0, 18)
teleportBindStatus.Position = UDim2.new(0, 0, 0, 105)
teleportBindStatus.BackgroundTransparency = 1
teleportBindStatus.Text = "Нажми для смены"
teleportBindStatus.TextColor3 = Color3.fromRGB(140, 140, 155)
teleportBindStatus.TextSize = 9
teleportBindStatus.Font = Enum.Font.Gotham
teleportBindStatus.TextXAlignment = Enum.TextXAlignment.Left
teleportBindStatus.Parent = miscContent

teleportBindBtn.MouseButton1Click:Connect(function()
    if waitingForTeleportBind then
        waitingForTeleportBind = false
        teleportBindBtn.Text = teleportKey.Name
        teleportBindStatus.Text = "Нажми для смены"
        teleportBindStatus.TextColor3 = Color3.fromRGB(140, 140, 155)
    else
        waitingForTeleportBind = true
        teleportBindBtn.Text = "..."
        teleportBindStatus.Text = "Ожидание клавиши..."
        teleportBindStatus.TextColor3 = Color3.fromRGB(255, 200, 100)
    end
end)

-- === SETTINGS КОНТЕНТ ===
local settingsContent = Instance.new("Frame")
settingsContent.Size = UDim2.new(1, 0, 0, 360)
settingsContent.BackgroundTransparency = 1
settingsContent.Parent = contentContainer
settingsContent.Visible = false
table.insert(tabContents, settingsContent)

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1, 0, 0, 25)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Text = "НАСТРОЙКИ"
settingsTitle.TextColor3 = Color3.fromRGB(200, 200, 210)
settingsTitle.TextSize = 14
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
settingsTitle.Parent = settingsContent

-- БИНД МЕНЮ
local menuBindLabel = Instance.new("TextLabel")
menuBindLabel.Size = UDim2.new(0.5, 0, 0, 20)
menuBindLabel.Position = UDim2.new(0, 0, 0, 35)
menuBindLabel.BackgroundTransparency = 1
menuBindLabel.Text = "КЛАВИША МЕНЮ"
menuBindLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
menuBindLabel.TextSize = 10
menuBindLabel.Font = Enum.Font.Gotham
menuBindLabel.TextXAlignment = Enum.TextXAlignment.Left
menuBindLabel.Parent = settingsContent

menuBindBtn.Size = UDim2.new(0.3, 0, 0, 28)
menuBindBtn.Position = UDim2.new(0.5, 0, 0, 31)
menuBindBtn.Text = currentBind.Name
menuBindBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
menuBindBtn.BackgroundTransparency = 0.3
menuBindBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
menuBindBtn.TextSize = 11
menuBindBtn.Font = Enum.Font.GothamBold
menuBindBtn.BorderSizePixel = 0
menuBindBtn.Parent = settingsContent
setupButtonHover(menuBindBtn)

menuBindStatus.Size = UDim2.new(1, 0, 0, 18)
menuBindStatus.Position = UDim2.new(0, 0, 0, 68)
menuBindStatus.BackgroundTransparency = 1
menuBindStatus.Text = "Нажми для смены"
menuBindStatus.TextColor3 = Color3.fromRGB(140, 140, 155)
menuBindStatus.TextSize = 9
menuBindStatus.Font = Enum.Font.Gotham
menuBindStatus.TextXAlignment = Enum.TextXAlignment.Left
menuBindStatus.Parent = settingsContent

-- ПРОЗРАЧНОСТЬ
local transLabel = Instance.new("TextLabel")
transLabel.Size = UDim2.new(0.5, 0, 0, 20)
transLabel.Position = UDim2.new(0, 0, 0, 100)
transLabel.BackgroundTransparency = 1
transLabel.Text = "ПРОЗРАЧНОСТЬ (%)"
transLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
transLabel.TextSize = 10
transLabel.Font = Enum.Font.Gotham
transLabel.TextXAlignment = Enum.TextXAlignment.Left
transLabel.Parent = settingsContent

transparencyInput.Size = UDim2.new(0.3, 0, 0, 30)
transparencyInput.Position = UDim2.new(0.55, 0, 0, 96)
transparencyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
transparencyInput.TextColor3 = Color3.fromRGB(210, 210, 220)
transparencyInput.TextSize = 14
transparencyInput.Font = Enum.Font.Gotham
transparencyInput.BorderSizePixel = 0
transparencyInput.Text = tostring(menuTransparency)
transparencyInput.PlaceholderText = "85"
transparencyInput.ClearTextOnFocus = true
transparencyInput.Parent = settingsContent

transparencyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local v = tonumber(transparencyInput.Text)
        if v and v >= 0 and v <= 100 then
            menuTransparency = v
            updateMenuAppearance()
            showNotification("🎨 Прозрачность: " .. menuTransparency .. "%", false)
            playNotifySound()
        else
            showNotification("❌ Введите число от 0 до 100", true)
            playNotifySound()
            transparencyInput.Text = tostring(menuTransparency)
        end
    end
end)

-- ШИРИНА
local widthLabel = Instance.new("TextLabel")
widthLabel.Size = UDim2.new(0.5, 0, 0, 20)
widthLabel.Position = UDim2.new(0, 0, 0, 145)
widthLabel.BackgroundTransparency = 1
widthLabel.Text = "ШИРИНА (px)"
widthLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
widthLabel.TextSize = 10
widthLabel.Font = Enum.Font.Gotham
widthLabel.TextXAlignment = Enum.TextXAlignment.Left
widthLabel.Parent = settingsContent

widthInput.Size = UDim2.new(0.3, 0, 0, 30)
widthInput.Position = UDim2.new(0.55, 0, 0, 141)
widthInput.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
widthInput.TextColor3 = Color3.fromRGB(210, 210, 220)
widthInput.TextSize = 14
widthInput.Font = Enum.Font.Gotham
widthInput.BorderSizePixel = 0
widthInput.Text = tostring(menuWidth)
widthInput.PlaceholderText = "800"
widthInput.ClearTextOnFocus = true
widthInput.Parent = settingsContent

widthInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local v = tonumber(widthInput.Text)
        if v and v >= 400 and v <= 1200 then
            menuWidth = v
            updateMenuAppearance()
            showNotification("📏 Ширина: " .. menuWidth .. "px", false)
            playNotifySound()
        else
            showNotification("❌ Введите число от 400 до 1200", true)
            playNotifySound()
            widthInput.Text = tostring(menuWidth)
        end
    end
end)

-- ВЫСОТА
local heightLabel = Instance.new("TextLabel")
heightLabel.Size = UDim2.new(0.5, 0, 0, 20)
heightLabel.Position = UDim2.new(0, 0, 0, 190)
heightLabel.BackgroundTransparency = 1
heightLabel.Text = "ВЫСОТА (px)"
heightLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
heightLabel.TextSize = 10
heightLabel.Font = Enum.Font.Gotham
heightLabel.TextXAlignment = Enum.TextXAlignment.Left
heightLabel.Parent = settingsContent

heightInput.Size = UDim2.new(0.3, 0, 0, 30)
heightInput.Position = UDim2.new(0.55, 0, 0, 186)
heightInput.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
heightInput.TextColor3 = Color3.fromRGB(210, 210, 220)
heightInput.TextSize = 14
heightInput.Font = Enum.Font.Gotham
heightInput.BorderSizePixel = 0
heightInput.Text = tostring(menuHeight)
heightInput.PlaceholderText = "500"
heightInput.ClearTextOnFocus = true
heightInput.Parent = settingsContent

heightInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local v = tonumber(heightInput.Text)
        if v and v >= 350 and v <= 800 then
            menuHeight = v
            updateMenuAppearance()
            showNotification("📏 Высота: " .. menuHeight .. "px", false)
            playNotifySound()
        else
            showNotification("❌ Введите число от 350 до 800", true)
            playNotifySound()
            heightInput.Text = tostring(menuHeight)
        end
    end
end)

-- ЦВЕТ
local colorLabel = Instance.new("TextLabel")
colorLabel.Size = UDim2.new(1, 0, 0, 20)
colorLabel.Position = UDim2.new(0, 0, 0, 235)
colorLabel.BackgroundTransparency = 1
colorLabel.Text = "ЦВЕТ МЕНЮ (RGB)"
colorLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
colorLabel.TextSize = 10
colorLabel.Font = Enum.Font.Gotham
colorLabel.TextXAlignment = Enum.TextXAlignment.Left
colorLabel.Parent = settingsContent

colorPreview.Size = UDim2.new(0.1, 0, 0, 25)
colorPreview.Position = UDim2.new(0, 0, 0, 260)
colorPreview.BackgroundColor3 = menuColor
colorPreview.BorderSizePixel = 1
colorPreview.BorderColor3 = Color3.fromRGB(60, 60, 70)
colorPreview.Parent = settingsContent

colorR.Size = UDim2.new(0.2, 0, 0, 25)
colorR.Position = UDim2.new(0.12, 0, 0, 260)
colorR.PlaceholderText = "R"
colorR.Text = tostring(math.floor(menuColor.R * 255))
colorR.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
colorR.TextColor3 = Color3.fromRGB(210, 210, 220)
colorR.TextSize = 12
colorR.Font = Enum.Font.Gotham
colorR.BorderSizePixel = 0
colorR.Parent = settingsContent

colorG.Size = UDim2.new(0.2, 0, 0, 25)
colorG.Position = UDim2.new(0.34, 0, 0, 260)
colorG.PlaceholderText = "G"
colorG.Text = tostring(math.floor(menuColor.G * 255))
colorG.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
colorG.TextColor3 = Color3.fromRGB(210, 210, 220)
colorG.TextSize = 12
colorG.Font = Enum.Font.Gotham
colorG.BorderSizePixel = 0
colorG.Parent = settingsContent

colorB.Size = UDim2.new(0.2, 0, 0, 25)
colorB.Position = UDim2.new(0.56, 0, 0, 260)
colorB.PlaceholderText = "B"
colorB.Text = tostring(math.floor(menuColor.B * 255))
colorB.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
colorB.TextColor3 = Color3.fromRGB(210, 210, 220)
colorB.TextSize = 12
colorB.Font = Enum.Font.Gotham
colorB.BorderSizePixel = 0
colorB.Parent = settingsContent

colorApplyBtn.Size = UDim2.new(0.2, 0, 0, 25)
colorApplyBtn.Position = UDim2.new(0.78, 0, 0, 260)
colorApplyBtn.Text = "ПРИМЕНИТЬ"
colorApplyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
colorApplyBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
colorApplyBtn.TextSize = 10
colorApplyBtn.Font = Enum.Font.GothamBold
colorApplyBtn.BorderSizePixel = 0
colorApplyBtn.Parent = settingsContent
setupButtonHover(colorApplyBtn)

colorApplyBtn.MouseButton1Click:Connect(function()
    local r = tonumber(colorR.Text) or 18
    local g = tonumber(colorG.Text) or 18
    local b = tonumber(colorB.Text) or 22
    r = math.clamp(r, 0, 255)
    g = math.clamp(g, 0, 255)
    b = math.clamp(b, 0, 255)
    menuColor = Color3.fromRGB(r, g, b)
    updateMenuAppearance()
    showNotification("🎨 Цвет изменён!", false)
    playNotifySound()
end)

-- ДРУЗЬЯ
friendsStatusLabel.Size = UDim2.new(1, 0, 0, 18)
friendsStatusLabel.Position = UDim2.new(0, 0, 0, 310)
friendsStatusLabel.BackgroundTransparency = 1
friendsStatusLabel.Text = "Друзей: 0"
friendsStatusLabel.TextColor3 = Color3.fromRGB(140, 140, 155)
friendsStatusLabel.TextSize = 9
friendsStatusLabel.Font = Enum.Font.Gotham
friendsStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
friendsStatusLabel.Parent = settingsContent

-- === КОНФИГИ КОНТЕНТ ===
local configsContent = Instance.new("Frame")
configsContent.Size = UDim2.new(1, 0, 0, 300)
configsContent.BackgroundTransparency = 1
configsContent.Parent = contentContainer
configsContent.Visible = false
table.insert(tabContents, configsContent)

local configsTitle = Instance.new("TextLabel")
configsTitle.Size = UDim2.new(1, 0, 0, 25)
configsTitle.BackgroundTransparency = 1
configsTitle.Text = "УПРАВЛЕНИЕ КОНФИГАМИ"
configsTitle.TextColor3 = Color3.fromRGB(200, 200, 210)
configsTitle.TextSize = 14
configsTitle.Font = Enum.Font.GothamBold
configsTitle.TextXAlignment = Enum.TextXAlignment.Left
configsTitle.Parent = configsContent

configNameInput.Size = UDim2.new(0.6, 0, 0, 30)
configNameInput.Position = UDim2.new(0, 0, 0, 35)
configNameInput.PlaceholderText = "Название конфига"
configNameInput.Text = ""
configNameInput.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
configNameInput.TextColor3 = Color3.fromRGB(210, 210, 220)
configNameInput.TextSize = 12
configNameInput.Font = Enum.Font.Gotham
configNameInput.BorderSizePixel = 0
configNameInput.Parent = configsContent

saveConfigBtn.Size = UDim2.new(0.3, 0, 0, 30)
saveConfigBtn.Position = UDim2.new(0.62, 0, 0, 35)
saveConfigBtn.Text = "СОХРАНИТЬ"
saveConfigBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
saveConfigBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
saveConfigBtn.TextSize = 11
saveConfigBtn.Font = Enum.Font.GothamBold
saveConfigBtn.BorderSizePixel = 0
saveConfigBtn.Parent = configsContent
setupButtonHover(saveConfigBtn)

saveConfigBtn.MouseButton1Click:Connect(function()
    local name = configNameInput.Text
    if name == "" then
        showNotification("❌ Введите название конфига", true)
        playNotifySound()
        return
    end
    saveCurrentConfig(name)
    configNameInput.Text = ""
end)

local configsListLabel = Instance.new("TextLabel")
configsListLabel.Size = UDim2.new(1, 0, 0, 18)
configsListLabel.Position = UDim2.new(0, 0, 0, 80)
configsListLabel.BackgroundTransparency = 1
configsListLabel.Text = "СОХРАНЁННЫЕ КОНФИГИ"
configsListLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
configsListLabel.TextSize = 10
configsListLabel.Font = Enum.Font.GothamBold
configsListLabel.TextXAlignment = Enum.TextXAlignment.Left
configsListLabel.Parent = configsContent

configListBox.Size = UDim2.new(1, 0, 0, 180)
configListBox.Position = UDim2.new(0, 0, 0, 100)
configListBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
configListBox.BackgroundTransparency = 0.2
configListBox.BorderSizePixel = 0
configListBox.ScrollBarThickness = 3
configListBox.Parent = configsContent

configStatus.Size = UDim2.new(1, 0, 0, 18)
configStatus.Position = UDim2.new(0, 0, 0, 290)
configStatus.BackgroundTransparency = 1
configStatus.Text = "Конфиги сохраняются автоматически"
configStatus.TextColor3 = Color3.fromRGB(140, 140, 155)
configStatus.TextSize = 9
configStatus.Font = Enum.Font.Gotham
configStatus.TextXAlignment = Enum.TextXAlignment.Left
configStatus.Parent = configsContent

updateConfigListDisplay()

-- Активация первой вкладки
tabFOV.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
tabFOV.TextColor3 = Color3.fromRGB(255, 255, 255)
for i = 2, #tabs do
    tabContents[i].Visible = false
end

-- FPS
fpsLabel.Size = UDim2.new(0, 80, 0, 25)
fpsLabel.Position = UDim2.new(0, 10, 0, 8)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
fpsLabel.TextSize = 12
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextXAlignment = Enum.TextXAlignment.Center
fpsLabel.Text = "FPS: 0"
fpsLabel.Parent = gui

local fc = 0
local lt = tick()
RunService.RenderStepped:Connect(function()
    fc = fc + 1
    if tick() - lt >= 1 then
        fpsLabel.Text = "FPS: " .. fc
        fc = 0
        lt = tick()
    end
end)

-- ОБНОВЛЕНИЕ CANVAS SIZE
local function updateCanvasSize()
    local h = 0
    for _, child in ipairs(contentContainer:GetChildren()) do
        if child:IsA("Frame") then
            h = h + child.Size.Y.Offset + 12
        end
    end
    contentContainer.CanvasSize = UDim2.new(0, 0, 0, h + 20)
end
contentContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCanvasSize)
updateCanvasSize()

-- Выход игроков (ESP)
game.Players.PlayerRemoving:Connect(function(leaving)
    if espListData[leaving] then
        removeESP(leaving)
        local count = 0 for _ in pairs(espListData) do count = count + 1 end
        espStatusLabel.Text = count > 0 and "Активно: " .. count or "Нет активных"
        showNotification("🔴 " .. leaving.Name .. " вышел", true)
        playNotifySound()
    end
end)

updatePlayersList()
updateBindDisplay()
updateTeleportBindDisplay()

print("GOXIE SCRIPT loaded | Press " .. currentBind.Name .. " to open menu | Configs saved")
