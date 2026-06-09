-- Goxie Script Menu (ФИНАЛ: вкладки + увеличенный шрифт + друзья)
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
local tabThirdPerson = Instance.new("TextButton")
local tabSkybox = Instance.new("TextButton")
local tabESP = Instance.new("TextButton")
local tabSettings = Instance.new("TextButton")

-- Контент для вкладок
local contentContainer = Instance.new("ScrollingFrame")
local contentPadding = Instance.new("UIPadding")
local contentList = Instance.new("UIListLayout")

-- --- FOV ---
local btnFOV = Instance.new("TextButton")
local statusFOV = Instance.new("TextLabel")
local fovInputBox = Instance.new("TextBox")

-- --- RESOLUTION ---
local btnRes = Instance.new("TextButton")
local statusRes = Instance.new("TextLabel")

-- --- 3-е лицо ---
local btnThirdPerson = Instance.new("TextButton")
local statusThirdPerson = Instance.new("TextLabel")

-- --- SKYBOX ---
local skyboxInputBox = Instance.new("TextBox")
local btnSkybox = Instance.new("TextButton")
local btnResetSkybox = Instance.new("TextButton")
local statusSkybox = Instance.new("TextLabel")

-- --- ESP ---
local playerDropdown = Instance.new("TextBox")
local btnAddESP = Instance.new("TextButton")
local refreshBtn = Instance.new("TextButton")
local playersList = Instance.new("ScrollingFrame")
local espList = Instance.new("ScrollingFrame")
local statusESP = Instance.new("TextLabel")

-- --- SETTINGS ---
local bindButton = Instance.new("TextButton")
local bindStatus = Instance.new("TextLabel")
local friendStatusLabel = Instance.new("TextLabel")

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
loadingText.Text = "Goxie Script"
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

-- === СЛЕЖЕНИЕ ЗА ДРУЗЬЯМИ (ИСПРАВЛЕНО) ===
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
    if friendStatusLabel then
        local count = 0
        for _ in pairs(friends) do count = count + 1 end
        friendStatusLabel.Text = "Друзей в списке: " .. count
    end
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

-- === 3-Е ЛИЦО ===
local thirdPersonActive = false
local yaw = 45
local pitch = 25
local distance = 15
local rotating = false
local lastMousePos = Vector2.new()

local function setThirdPerson(enabled)
    thirdPersonActive = enabled
    if enabled then
        statusThirdPerson.Text = "ON (3 лицо)"
        statusThirdPerson.TextColor3 = Color3.fromRGB(170, 190, 170)
        btnThirdPerson.Text = "ВЫКЛЮЧИТЬ 3 ЛИЦО"
    else
        camera.CameraType = Enum.CameraType.Custom
        statusThirdPerson.Text = "OFF (1 лицо)"
        statusThirdPerson.TextColor3 = Color3.fromRGB(140, 140, 155)
        btnThirdPerson.Text = "ВКЛЮЧИТЬ 3 ЛИЦО"
    end
end

UserInputService.InputBegan:Connect(function(input)
    if not thirdPersonActive then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rotating = true
        lastMousePos = UserInputService:GetMouseLocation()
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
    if input.KeyCode == Enum.KeyCode.ButtonWheelUp then
        distance = math.max(distance - 1, 5)
    elseif input.KeyCode == Enum.KeyCode.ButtonWheelDown then
        distance = math.min(distance + 1, 30)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if not thirdPersonActive then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rotating = false
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
    end
end)

RunService.RenderStepped:Connect(function()
    if not thirdPersonActive then return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local rootPart = player.Character.HumanoidRootPart
    
    if rotating then
        local delta = UserInputService:GetMouseLocation() - lastMousePos
        yaw = yaw - delta.X * 0.5
        pitch = math.clamp(pitch - delta.Y * 0.5, -80, 80)
        lastMousePos = UserInputService:GetMouseLocation()
    end
    
    local radYaw = math.rad(yaw)
    local radPitch = math.rad(pitch)
    local offset = Vector3.new(
        math.cos(radYaw) * math.cos(radPitch) * distance,
        math.sin(radPitch) * distance + 2,
        math.sin(radYaw) * math.cos(radPitch) * distance
    )
    camera.CFrame = CFrame.new(rootPart.Position + offset, rootPart.Position)
    camera.CameraType = Enum.CameraType.Scriptable
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
        statusSkybox.Text = "Ошибка: введите число"
        statusSkybox.TextColor3 = Color3.fromRGB(200, 120, 120)
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
    statusSkybox.Text = "Изменено! ID: " .. assetId
    statusSkybox.TextColor3 = Color3.fromRGB(120, 200, 120)
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
        statusSkybox.Text = "Небо сброшено"
        statusSkybox.TextColor3 = Color3.fromRGB(140, 140, 155)
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
    label.TextSize = 18
    label.Font = Enum.Font.GothamBold
    label.TextStrokeTransparency = 0.3
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Parent = billboard
    return billboard
end

local function addESPToPlayer(target)
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

local function removeESPFromPlayer(target)
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
        removeESPFromPlayer(plr)
    end
end

local function updateESPDisplay()
    for _, child in ipairs(espList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local y = 0
    for plr, _ in pairs(espListData) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 25)
        btn.Position = UDim2.new(0, 5, 0, y)
        btn.Text = plr.Name .. " ✖"
        btn.BackgroundColor3 = Color3.fromRGB(30, 20, 20)
        btn.BackgroundTransparency = 0.3
        btn.TextColor3 = Color3.fromRGB(255, 150, 150)
        btn.TextSize = 14
        btn.Font = Enum.Font.Gotham
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(55, 55, 70)
        btn.Parent = espList
        btn.MouseButton1Click:Connect(function()
            removeESPFromPlayer(plr)
            showNotification("❌ ESP выключен для " .. plr.Name, false)
            playNotifySound()
            local count = 0 for _ in pairs(espListData) do count = count + 1 end
            statusESP.Text = count > 0 and "Активно (" .. count .. ")" or "Нет активных"
            statusESP.TextColor3 = count > 0 and Color3.fromRGB(170, 190, 170) or Color3.fromRGB(140, 140, 155)
        end)
        setupButtonHover(btn)
        y = y + 30
    end
    espList.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

local function updatePlayersList()
    for _, child in ipairs(playersList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local players = game.Players:GetPlayers()
    local y = 0
    for _, plr in ipairs(players) do
        if plr ~= player then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -10, 0, 25)
            btn.Position = UDim2.new(0, 5, 0, y)
            btn.Text = plr.Name
            btn.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
            btn.BackgroundTransparency = 0.3
            btn.TextColor3 = Color3.fromRGB(200, 200, 210)
            btn.TextSize = 14
            btn.Font = Enum.Font.Gotham
            btn.BorderSizePixel = 1
            btn.BorderColor3 = Color3.fromRGB(45, 45, 55)
            btn.Parent = playersList
            btn.MouseButton1Click:Connect(function()
                playerDropdown.Text = plr.Name
            end)
            setupButtonHover(btn)
            y = y + 30
        end
    end
    playersList.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

-- === НАСТРОЙКА БИНДА ===
local currentBind = Enum.KeyCode.RightShift
local waitingForBind = false

local function updateBindDisplay()
    bindButton.Text = currentBind.Name
    bindStatus.Text = "Текущий: " .. currentBind.Name .. " | Нажми для смены"
end

local function setBind(key)
    currentBind = key
    updateBindDisplay()
    showNotification("🔑 Бинд изменён на: " .. key.Name, false)
    playNotifySound()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if waitingForBind then
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            setBind(input.KeyCode)
            waitingForBind = false
            bindButton.Text = currentBind.Name
            bindStatus.Text = "Готово! Бинд: " .. currentBind.Name
            wait(1)
            bindStatus.Text = "Нажми для смены бинда"
            bindStatus.TextColor3 = Color3.fromRGB(140, 140, 155)
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
    local origTrans = button.BackgroundTransparency
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        button.BackgroundTransparency = 0.15
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = origColor
        button.BackgroundTransparency = origTrans
    end)
end

-- === УВЕДОМЛЕНИЯ ===
notificationContainer.Size = UDim2.new(0, 350, 0, 200)
notificationContainer.Position = UDim2.new(1, -360, 0, 10)
notificationContainer.BackgroundTransparency = 1
notificationContainer.Parent = gui

function showNotification(msg, isError)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, -10, 0, 45)
    notif.Position = UDim2.new(0, 5, 0, 0)
    notif.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    notif.BackgroundTransparency = 0.2
    notif.BorderSizePixel = 1
    notif.BorderColor3 = Color3.fromRGB(60, 60, 80)
    notif.Parent = notificationContainer
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = msg
    text.TextColor3 = isError and Color3.fromRGB(255, 120, 120) or Color3.fromRGB(120, 255, 120)
    text.TextSize = 16
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
            y = y + 45
        end
    end
    notif.Position = UDim2.new(0, 5, 0, y)
    game:GetService("Debris"):AddItem(notif, 3)
    wait(2.8)
    for i = 1, 5 do
        notif.BackgroundTransparency = notif.BackgroundTransparency + 0.2
        wait(0.02)
    end
    notif:Destroy()
    local y2 = 0
    for _, child in ipairs(notificationContainer:GetChildren()) do
        if child:IsA("Frame") then
            child.Position = UDim2.new(0, 5, 0, y2)
            y2 = y2 + 45
        end
    end
end

-- === ОСНОВНОЕ ОКНО ===
frame.Size = UDim2.new(0, 750, 0, 600)
frame.Position = UDim2.new(0.5, -375, 0.5, -300)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(30, 30, 35)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

-- ЗАГОЛОВОК
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
title.BackgroundTransparency = 0.3
title.Text = "GOXIE SCRIPT"
title.TextColor3 = Color3.fromRGB(220, 220, 230)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = frame

-- КНОПКА ЗАКРЫТИЯ
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 8)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
closeBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
closeBtn.BackgroundTransparency = 0.2
closeBtn.BorderSizePixel = 0
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function() frame.Visible = false end)
setupButtonHover(closeBtn)

-- ВКЛАДКИ (СЛЕВА)
tabsFrame.Size = UDim2.new(0, 140, 1, -55)
tabsFrame.Position = UDim2.new(0, 10, 0, 55)
tabsFrame.BackgroundTransparency = 1
tabsFrame.Parent = frame

local tabs = {tabFOV, tabResolution, tabThirdPerson, tabSkybox, tabESP, tabSettings}
local tabNames = {"FOV", "RESOLUTION", "3RD PERSON", "SKYBOX", "ESP", "SETTINGS"}
local currentTab = "FOV"

for i, tab in ipairs(tabs) do
    tab.Size = UDim2.new(1, 0, 0, 40)
    tab.Position = UDim2.new(0, 0, 0, (i-1) * 45)
    tab.Text = tabNames[i]
    tab.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    tab.BackgroundTransparency = 0.3
    tab.TextColor3 = Color3.fromRGB(200, 200, 210)
    tab.TextSize = 16
    tab.Font = Enum.Font.GothamBold
    tab.BorderSizePixel = 1
    tab.BorderColor3 = Color3.fromRGB(45, 45, 55)
    tab.Parent = tabsFrame
    setupButtonHover(tab)
    
    tab.MouseButton1Click:Connect(function()
        currentTab = tab.Text
        for _, t in ipairs(tabs) do
            t.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
            t.TextColor3 = Color3.fromRGB(200, 200, 210)
        end
        tab.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        tab.TextColor3 = Color3.fromRGB(255, 255, 255)
        updateContentVisibility()
    end)
end

-- КОНТЕЙНЕР ДЛЯ КОНТЕНТА
contentContainer.Size = UDim2.new(1, -160, 1, -55)
contentContainer.Position = UDim2.new(0, 155, 0, 55)
contentContainer.BackgroundTransparency = 1
contentContainer.BorderSizePixel = 0
contentContainer.ScrollBarThickness = 6
contentContainer.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
contentContainer.Parent = frame

contentPadding.PaddingLeft = UDim.new(0, 10)
contentPadding.PaddingRight = UDim.new(0, 10)
contentPadding.PaddingTop = UDim.new(0, 10)
contentPadding.PaddingBottom = UDim.new(0, 10)
contentPadding.Parent = contentContainer

contentList.SortOrder = Enum.SortOrder.LayoutOrder
contentList.Padding = UDim.new(0, 15)
contentList.Parent = contentContainer

-- ФУНКЦИЯ СКРЫТИЯ/ПОКАЗА КОНТЕНТА
local function hideAllContent()
    for _, child in ipairs(contentContainer:GetChildren()) do
        if child:IsA("Frame") then
            child.Visible = false
        end
    end
end

local function showContent(frameToShow)
    hideAllContent()
    frameToShow.Visible = true
end

-- === FOV КОНТЕНТ ===
local fovContent = Instance.new("Frame")
fovContent.Size = UDim2.new(1, 0, 0, 200)
fovContent.BackgroundTransparency = 1
fovContent.Parent = contentContainer

local fovTitle = Instance.new("TextLabel")
fovTitle.Size = UDim2.new(1, 0, 0, 40)
fovTitle.BackgroundTransparency = 1
fovTitle.Text = "НАСТРОЙКИ FOV"
fovTitle.TextColor3 = Color3.fromRGB(220, 220, 230)
fovTitle.TextSize = 22
fovTitle.Font = Enum.Font.GothamBold
fovTitle.TextXAlignment = Enum.TextXAlignment.Left
fovTitle.Parent = fovContent

btnFOV.Size = UDim2.new(0.6, 0, 0, 45)
btnFOV.Position = UDim2.new(0, 10, 0, 55)
btnFOV.Text = "ACTIVATE FOV LOCK"
btnFOV.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
btnFOV.BackgroundTransparency = 0.3
btnFOV.TextColor3 = Color3.fromRGB(200, 200, 210)
btnFOV.TextSize = 16
btnFOV.Font = Enum.Font.Gotham
btnFOV.BorderSizePixel = 1
btnFOV.BorderColor3 = Color3.fromRGB(45, 45, 55)
btnFOV.Parent = fovContent
setupButtonHover(btnFOV)

local fovInputLabel = Instance.new("TextLabel")
fovInputLabel.Size = UDim2.new(0.3, 0, 0, 30)
fovInputLabel.Position = UDim2.new(0, 10, 0, 115)
fovInputLabel.BackgroundTransparency = 1
fovInputLabel.Text = "Значение FOV (80-140):"
fovInputLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
fovInputLabel.TextSize = 16
fovInputLabel.TextXAlignment = Enum.TextXAlignment.Left
fovInputLabel.Parent = fovContent

fovInputBox.Size = UDim2.new(0.2, 0, 0, 35)
fovInputBox.Position = UDim2.new(0.35, 0, 0, 112)
fovInputBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
fovInputBox.BackgroundTransparency = 0.3
fovInputBox.TextColor3 = Color3.fromRGB(210, 210, 220)
fovInputBox.TextSize = 16
fovInputBox.Font = Enum.Font.Gotham
fovInputBox.BorderSizePixel = 1
fovInputBox.BorderColor3 = Color3.fromRGB(45, 45, 55)
fovInputBox.Text = "85"
fovInputBox.PlaceholderText = "85"
fovInputBox.ClearTextOnFocus = true
fovInputBox.Parent = fovContent

statusFOV.Size = UDim2.new(0.5, 0, 0, 30)
statusFOV.Position = UDim2.new(0, 10, 0, 160)
statusFOV.BackgroundTransparency = 1
statusFOV.Text = "OFF"
statusFOV.TextColor3 = Color3.fromRGB(140, 140, 155)
statusFOV.TextSize = 16
statusFOV.TextXAlignment = Enum.TextXAlignment.Left
statusFOV.Parent = fovContent

-- === RESOLUTION КОНТЕНТ ===
local resContent = Instance.new("Frame")
resContent.Size = UDim2.new(1, 0, 0, 200)
resContent.BackgroundTransparency = 1
resContent.Parent = contentContainer
resContent.Visible = false

local resTitle = Instance.new("TextLabel")
resTitle.Size = UDim2.new(1, 0, 0, 40)
resTitle.BackgroundTransparency = 1
resTitle.Text = "НАСТРОЙКИ RESOLUTION MOD"
resTitle.TextColor3 = Color3.fromRGB(220, 220, 230)
resTitle.TextSize = 22
resTitle.Font = Enum.Font.GothamBold
resTitle.TextXAlignment = Enum.TextXAlignment.Left
resTitle.Parent = resContent

btnRes.Size = UDim2.new(0.6, 0, 0, 45)
btnRes.Position = UDim2.new(0, 10, 0, 55)
btnRes.Text = "ACTIVATE RESOLUTION MOD"
btnRes.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
btnRes.BackgroundTransparency = 0.3
btnRes.TextColor3 = Color3.fromRGB(200, 200, 210)
btnRes.TextSize = 16
btnRes.Font = Enum.Font.Gotham
btnRes.BorderSizePixel = 1
btnRes.BorderColor3 = Color3.fromRGB(45, 45, 55)
btnRes.Parent = resContent
setupButtonHover(btnRes)

statusRes.Size = UDim2.new(0.5, 0, 0, 30)
statusRes.Position = UDim2.new(0, 10, 0, 115)
statusRes.BackgroundTransparency = 1
statusRes.Text = "OFF"
statusRes.TextColor3 = Color3.fromRGB(140, 140, 155)
statusRes.TextSize = 16
statusRes.TextXAlignment = Enum.TextXAlignment.Left
statusRes.Parent = resContent

-- === 3RD PERSON КОНТЕНТ ===
local thirdContent = Instance.new("Frame")
thirdContent.Size = UDim2.new(1, 0, 0, 200)
thirdContent.BackgroundTransparency = 1
thirdContent.Parent = contentContainer
thirdContent.Visible = false

local thirdTitle = Instance.new("TextLabel")
thirdTitle.Size = UDim2.new(1, 0, 0, 40)
thirdTitle.BackgroundTransparency = 1
thirdTitle.Text = "НАСТРОЙКИ 3-ГО ЛИЦА"
thirdTitle.TextColor3 = Color3.fromRGB(220, 220, 230)
thirdTitle.TextSize = 22
thirdTitle.Font = Enum.Font.GothamBold
thirdTitle.TextXAlignment = Enum.TextXAlignment.Left
thirdTitle.Parent = thirdContent

btnThirdPerson.Size = UDim2.new(0.6, 0, 0, 45)
btnThirdPerson.Position = UDim2.new(0, 10, 0, 55)
btnThirdPerson.Text = "ВКЛЮЧИТЬ 3 ЛИЦО"
btnThirdPerson.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
btnThirdPerson.BackgroundTransparency = 0.3
btnThirdPerson.TextColor3 = Color3.fromRGB(200, 200, 210)
btnThirdPerson.TextSize = 16
btnThirdPerson.Font = Enum.Font.Gotham
btnThirdPerson.BorderSizePixel = 1
btnThirdPerson.BorderColor3 = Color3.fromRGB(45, 45, 55)
btnThirdPerson.Parent = thirdContent
setupButtonHover(btnThirdPerson)

statusThirdPerson.Size = UDim2.new(0.5, 0, 0, 30)
statusThirdPerson.Position = UDim2.new(0, 10, 0, 115)
statusThirdPerson.BackgroundTransparency = 1
statusThirdPerson.Text = "OFF (1 лицо)"
statusThirdPerson.TextColor3 = Color3.fromRGB(140, 140, 155)
statusThirdPerson.TextSize = 16
statusThirdPerson.TextXAlignment = Enum.TextXAlignment.Left
statusThirdPerson.Parent = thirdContent

-- === SKYBOX КОНТЕНТ ===
local skyboxContent = Instance.new("Frame")
skyboxContent.Size = UDim2.new(1, 0, 0, 200)
skyboxContent.BackgroundTransparency = 1
skyboxContent.Parent = contentContainer
skyboxContent.Visible = false

local skyboxTitle = Instance.new("TextLabel")
skyboxTitle.Size = UDim2.new(1, 0, 0, 40)
skyboxTitle.BackgroundTransparency = 1
skyboxTitle.Text = "НАСТРОЙКИ SKYBOX"
skyboxTitle.TextColor3 = Color3.fromRGB(220, 220, 230)
skyboxTitle.TextSize = 22
skyboxTitle.Font = Enum.Font.GothamBold
skyboxTitle.TextXAlignment = Enum.TextXAlignment.Left
skyboxTitle.Parent = skyboxContent

skyboxInputBox.Size = UDim2.new(0.5, 0, 0, 35)
skyboxInputBox.Position = UDim2.new(0, 10, 0, 55)
skyboxInputBox.PlaceholderText = "Введите ID неба"
skyboxInputBox.Text = ""
skyboxInputBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
skyboxInputBox.BackgroundTransparency = 0.3
skyboxInputBox.TextColor3 = Color3.fromRGB(210, 210, 220)
skyboxInputBox.TextSize = 16
skyboxInputBox.Font = Enum.Font.Gotham
skyboxInputBox.BorderSizePixel = 1
skyboxInputBox.BorderColor3 = Color3.fromRGB(45, 45, 55)
skyboxInputBox.Parent = skyboxContent

btnSkybox.Size = UDim2.new(0.2, 0, 0, 35)
btnSkybox.Position = UDim2.new(0.52, 0, 0, 55)
btnSkybox.Text = "ПРИМЕНИТЬ"
btnSkybox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
btnSkybox.BackgroundTransparency = 0.3
btnSkybox.TextColor3 = Color3.fromRGB(200, 200, 210)
btnSkybox.TextSize = 14
btnSkybox.Font = Enum.Font.Gotham
btnSkybox.BorderSizePixel = 1
btnSkybox.BorderColor3 = Color3.fromRGB(45, 45, 55)
btnSkybox.Parent = skyboxContent
setupButtonHover(btnSkybox)

btnResetSkybox.Size = UDim2.new(0.2, 0, 0, 35)
btnResetSkybox.Position = UDim2.new(0.74, 0, 0, 55)
btnResetSkybox.Text = "СБРОСИТЬ"
btnResetSkybox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
btnResetSkybox.BackgroundTransparency = 0.3
btnResetSkybox.TextColor3 = Color3.fromRGB(200, 200, 210)
btnResetSkybox.TextSize = 14
btnResetSkybox.Font = Enum.Font.Gotham
btnResetSkybox.BorderSizePixel = 1
btnResetSkybox.BorderColor3 = Color3.fromRGB(45, 45, 55)
btnResetSkybox.Parent = skyboxContent
setupButtonHover(btnResetSkybox)

statusSkybox.Size = UDim2.new(0.5, 0, 0, 30)
statusSkybox.Position = UDim2.new(0, 10, 0, 105)
statusSkybox.BackgroundTransparency = 1
statusSkybox.Text = "Готов"
statusSkybox.TextColor3 = Color3.fromRGB(140, 140, 155)
statusSkybox.TextSize = 14
statusSkybox.TextXAlignment = Enum.TextXAlignment.Left
statusSkybox.Parent = skyboxContent

-- === ESP КОНТЕНТ ===
local espContent = Instance.new("Frame")
espContent.Size = UDim2.new(1, 0, 0, 450)
espContent.BackgroundTransparency = 1
espContent.Parent = contentContainer
espContent.Visible = false

local espTitle = Instance.new("TextLabel")
espTitle.Size = UDim2.new(1, 0, 0, 40)
espTitle.BackgroundTransparency = 1
espTitle.Text = "НАСТРОЙКИ ESP"
espTitle.TextColor3 = Color3.fromRGB(220, 220, 230)
espTitle.TextSize = 22
espTitle.Font = Enum.Font.GothamBold
espTitle.TextXAlignment = Enum.TextXAlignment.Left
espTitle.Parent = espContent

playerDropdown.Size = UDim2.new(0.6, 0, 0, 35)
playerDropdown.Position = UDim2.new(0, 10, 0, 50)
playerDropdown.PlaceholderText = "Введите имя игрока"
playerDropdown.Text = ""
playerDropdown.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
playerDropdown.BackgroundTransparency = 0.3
playerDropdown.TextColor3 = Color3.fromRGB(210, 210, 220)
playerDropdown.TextSize = 14
playerDropdown.Font = Enum.Font.Gotham
playerDropdown.BorderSizePixel = 1
playerDropdown.BorderColor3 = Color3.fromRGB(45, 45, 55)
playerDropdown.Parent = espContent

refreshBtn.Size = UDim2.new(0.18, 0, 0, 35)
refreshBtn.Position = UDim2.new(0.62, 0, 0, 50)
refreshBtn.Text = "ОБНОВИТЬ"
refreshBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
refreshBtn.BackgroundTransparency = 0.3
refreshBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
refreshBtn.TextSize = 12
refreshBtn.Font = Enum.Font.Gotham
refreshBtn.BorderSizePixel = 1
refreshBtn.BorderColor3 = Color3.fromRGB(45, 45, 55)
refreshBtn.Parent = espContent
setupButtonHover(refreshBtn)

btnAddESP.Size = UDim2.new(0.18, 0, 0, 35)
btnAddESP.Position = UDim2.new(0.81, 0, 0, 50)
btnAddESP.Text = "ДОБАВИТЬ"
btnAddESP.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
btnAddESP.BackgroundTransparency = 0.3
btnAddESP.TextColor3 = Color3.fromRGB(200, 200, 210)
btnAddESP.TextSize = 12
btnAddESP.Font = Enum.Font.Gotham
btnAddESP.BorderSizePixel = 1
btnAddESP.BorderColor3 = Color3.fromRGB(45, 45, 55)
btnAddESP.Parent = espContent
setupButtonHover(btnAddESP)

local playersLabel = Instance.new("TextLabel")
playersLabel.Size = UDim2.new(0.48, 0, 0, 25)
playersLabel.Position = UDim2.new(0, 10, 0, 100)
playersLabel.BackgroundTransparency = 1
playersLabel.Text = "Доступные игроки:"
playersLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
playersLabel.TextSize = 14
playersLabel.TextXAlignment = Enum.TextXAlignment.Left
playersLabel.Parent = espContent

playersList.Size = UDim2.new(0.48, 0, 0, 140)
playersList.Position = UDim2.new(0, 10, 0, 125)
playersList.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
playersList.BackgroundTransparency = 0.2
playersList.BorderSizePixel = 1
playersList.BorderColor3 = Color3.fromRGB(45, 45, 55)
playersList.ScrollBarThickness = 6
playersList.Parent = espContent

local espLabel = Instance.new("TextLabel")
espLabel.Size = UDim2.new(0.48, 0, 0, 25)
espLabel.Position = UDim2.new(0.51, 0, 0, 100)
espLabel.BackgroundTransparency = 1
espLabel.Text = "ESP активен для:"
espLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
espLabel.TextSize = 14
espLabel.TextXAlignment = Enum.TextXAlignment.Left
espLabel.Parent = espContent

espList.Size = UDim2.new(0.48, 0, 0, 140)
espList.Position = UDim2.new(0.51, 0, 0, 125)
espList.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
espList.BackgroundTransparency = 0.2
espList.BorderSizePixel = 1
espList.BorderColor3 = Color3.fromRGB(45, 45, 55)
espList.ScrollBarThickness = 6
espList.Parent = espContent

statusESP.Size = UDim2.new(1, -20, 0, 30)
statusESP.Position = UDim2.new(0, 10, 0, 280)
statusESP.BackgroundTransparency = 1
statusESP.Text = "Нет активных"
statusESP.TextColor3 = Color3.fromRGB(140, 140, 155)
statusESP.TextSize = 14
statusESP.TextXAlignment = Enum.TextXAlignment.Left
statusESP.Parent = espContent

-- === SETTINGS КОНТЕНТ ===
local settingsContent = Instance.new("Frame")
settingsContent.Size = UDim2.new(1, 0, 0, 280)
settingsContent.BackgroundTransparency = 1
settingsContent.Parent = contentContainer
settingsContent.Visible = false

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1, 0, 0, 40)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Text = "НАСТРОЙКИ"
settingsTitle.TextColor3 = Color3.fromRGB(220, 220, 230)
settingsTitle.TextSize = 22
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
settingsTitle.Parent = settingsContent

local bindLabel = Instance.new("TextLabel")
bindLabel.Size = UDim2.new(0.3, 0, 0, 30)
bindLabel.Position = UDim2.new(0, 10, 0, 55)
bindLabel.BackgroundTransparency = 1
bindLabel.Text = "Клавиша для открытия:"
bindLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
bindLabel.TextSize = 16
bindLabel.TextXAlignment = Enum.TextXAlignment.Left
bindLabel.Parent = settingsContent

bindButton.Size = UDim2.new(0.2, 0, 0, 35)
bindButton.Position = UDim2.new(0.35, 0, 0, 52)
bindButton.Text = currentBind.Name
bindButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
bindButton.BackgroundTransparency = 0.2
bindButton.TextColor3 = Color3.fromRGB(220, 220, 230)
bindButton.TextSize = 16
bindButton.Font = Enum.Font.GothamBold
bindButton.BorderSizePixel = 1
bindButton.BorderColor3 = Color3.fromRGB(55, 55, 70)
bindButton.Parent = settingsContent
setupButtonHover(bindButton)

bindStatus.Size = UDim2.new(0.5, 0, 0, 30)
bindStatus.Position = UDim2.new(0, 10, 0, 100)
bindStatus.BackgroundTransparency = 1
bindStatus.Text = "Нажми для смены бинда"
bindStatus.TextColor3 = Color3.fromRGB(140, 140, 155)
bindStatus.TextSize = 14
bindStatus.TextXAlignment = Enum.TextXAlignment.Left
bindStatus.Parent = settingsContent

friendStatusLabel.Size = UDim2.new(1, -20, 0, 30)
friendStatusLabel.Position = UDim2.new(0, 10, 0, 150)
friendStatusLabel.BackgroundTransparency = 1
friendStatusLabel.Text = "Загрузка друзей..."
friendStatusLabel.TextColor3 = Color3.fromRGB(140, 140, 155)
friendStatusLabel.TextSize = 14
friendStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
friendStatusLabel.Parent = settingsContent

local function updateContentVisibility()
    fovContent.Visible = (currentTab == "FOV")
    resContent.Visible = (currentTab == "RESOLUTION")
    thirdContent.Visible = (currentTab == "3RD PERSON")
    skyboxContent.Visible = (currentTab == "SKYBOX")
    espContent.Visible = (currentTab == "ESP")
    settingsContent.Visible = (currentTab == "SETTINGS")
end

-- Активируем первую вкладку
tabFOV.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
tabFOV.TextColor3 = Color3.fromRGB(255, 255, 255)
updateContentVisibility()

-- FPS
fpsLabel.Size = UDim2.new(0, 200, 0, 45)
fpsLabel.Position = UDim2.new(0.5, -100, 0, 5)
fpsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
fpsLabel.BackgroundTransparency = 0.5
fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsLabel.TextSize = 22
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextXAlignment = Enum.TextXAlignment.Center
fpsLabel.BorderSizePixel = 1
fpsLabel.BorderColor3 = Color3.fromRGB(70, 70, 85)
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
            h = child.Size.Y.Offset + 20
        end
    end
    contentContainer.CanvasSize = UDim2.new(0, 0, 0, h)
end
contentContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCanvasSize)
updateCanvasSize()

-- === ЛОГИКА FOV ===
local fovActive = false
local fovConn = nil
local currentFOV = 85

fovInputBox.FocusLost:Connect(function(enter)
    if enter then
        local v = tonumber(fovInputBox.Text)
        if v and v >= 80 and v <= 140 then
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
end)

btnFOV.MouseButton1Click:Connect(function()
    if fovActive then
        if fovConn then fovConn:Disconnect() end
        fovConn = nil
        camera.FieldOfView = 70
        fovActive = false
        statusFOV.Text = "OFF"
        statusFOV.TextColor3 = Color3.fromRGB(140, 140, 155)
        btnFOV.Text = "ACTIVATE FOV LOCK"
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
        statusFOV.Text = "ON (" .. currentFOV .. ")"
        statusFOV.TextColor3 = Color3.fromRGB(170, 190, 170)
        btnFOV.Text = "DEACTIVATE FOV LOCK"
        showNotification("🔒 FOV Lock включён на " .. currentFOV, false)
        playNotifySound()
    end
end)

-- === ЛОГИКА RESOLUTION ===
local resActive = false
local resConn = nil

btnRes.MouseButton1Click:Connect(function()
    if resActive then
        if resConn then resConn:Disconnect() end
        resConn = nil
        resActive = false
        statusRes.Text = "OFF"
        statusRes.TextColor3 = Color3.fromRGB(140, 140, 155)
        btnRes.Text = "ACTIVATE RESOLUTION MOD"
        showNotification("🔧 Resolution Mod выключен", false)
        playNotifySound()
    else
        resConn = RunService.RenderStepped:Connect(function()
            camera.CFrame = camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.80, 0, 0, 0, 1)
        end)
        resActive = true
        statusRes.Text = "ON"
        statusRes.TextColor3 = Color3.fromRGB(170, 190, 170)
        btnRes.Text = "DEACTIVATE RESOLUTION MOD"
        showNotification("🔧 Resolution Mod включён", false)
        playNotifySound()
    end
end)

-- === ЛОГИКА 3-ГО ЛИЦА ===
btnThirdPerson.MouseButton1Click:Connect(function()
    setThirdPerson(not thirdPersonActive)
end)

-- === ЛОГИКА SKYBOX ===
btnSkybox.MouseButton1Click:Connect(function() applySkybox(skyboxInputBox.Text) end)
btnResetSkybox.MouseButton1Click:Connect(function() resetSkybox() end)

-- === ЛОГИКА ESP ===
refreshBtn.MouseButton1Click:Connect(function()
    updatePlayersList()
    showNotification("📋 Список игроков обновлён", false)
    playNotifySound()
end)

btnAddESP.MouseButton1Click:Connect(function()
    local name = playerDropdown.Text
    if name == "" then
        showNotification("❌ Введите имя игрока", true)
        playNotifySound()
        return
    end
    local target = game.Players:FindFirstChild(name)
    if not target then
        showNotification("❌ Игрок не найден", true)
        playNotifySound()
        return
    end
    if addESPToPlayer(target) then
        local count = 0 for _ in pairs(espListData) do count = count + 1 end
        showNotification("✅ ESP добавлен для " .. target.Name, false)
        playNotifySound()
        statusESP.Text = "Активно (" .. count .. ")"
        statusESP.TextColor3 = Color3.fromRGB(170, 190, 170)
    else
        showNotification("❌ Уже в ESP", true)
        playNotifySound()
    end
    playerDropdown.Text = ""
end)

local btnRemoveAll = Instance.new("TextButton")
btnRemoveAll.Size = UDim2.new(0.18, 0, 0, 35)
btnRemoveAll.Position = UDim2.new(0.62, 0, 0, 100)
btnRemoveAll.Text = "УДАЛИТЬ ВСЕХ"
btnRemoveAll.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
btnRemoveAll.BackgroundTransparency = 0.3
btnRemoveAll.TextColor3 = Color3.fromRGB(200, 200, 210)
btnRemoveAll.TextSize = 12
btnRemoveAll.Font = Enum.Font.Gotham
btnRemoveAll.BorderSizePixel = 1
btnRemoveAll.BorderColor3 = Color3.fromRGB(45, 45, 55)
btnRemoveAll.Parent = espContent
setupButtonHover(btnRemoveAll)

btnRemoveAll.MouseButton1Click:Connect(function()
    removeAllESP()
    showNotification("🗑️ Весь ESP отключён", false)
    playNotifySound()
    statusESP.Text = "Нет активных"
    statusESP.TextColor3 = Color3.fromRGB(140, 140, 155)
end)

-- === ЛОГИКА БИНДА ===
bindButton.MouseButton1Click:Connect(function()
    if waitingForBind then
        waitingForBind = false
        bindButton.Text = currentBind.Name
        bindStatus.Text = "Нажми для смены бинда"
        bindStatus.TextColor3 = Color3.fromRGB(140, 140, 155)
    else
        waitingForBind = true
        bindButton.Text = "..."
        bindStatus.Text = "Ожидание нажатия клавиши..."
        bindStatus.TextColor3 = Color3.fromRGB(255, 200, 100)
    end
end)

-- Выход игроков (ESP)
game.Players.PlayerRemoving:Connect(function(leaving)
    if espListData[leaving] then
        removeESPFromPlayer(leaving)
        local count = 0 for _ in pairs(espListData) do count = count + 1 end
        statusESP.Text = count > 0 and "Активно (" .. count .. ")" or "Нет активных"
        statusESP.TextColor3 = count > 0 and Color3.fromRGB(170, 190, 170) or Color3.fromRGB(140, 140, 155)
        showNotification("🔴 " .. leaving.Name .. " вышел из игры", true)
        playNotifySound()
    end
end)

updatePlayersList()
updateBindDisplay()

print("Goxie Script loaded | Press " .. currentBind.Name .. " to open menu")
