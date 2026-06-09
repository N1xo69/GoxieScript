-- Goxie Script Menu (ФИНАЛ: исправленный ESP + свободная камера 3-го лица)
-- Нажмите настроенную клавишу для открытия меню (по умолчанию Right Shift)

local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
local frame = Instance.new("Frame")
local title = Instance.new("TextLabel")
local closeBtn = Instance.new("TextButton")
local scrollContainer = Instance.new("ScrollingFrame")
local scrollPadding = Instance.new("UIPadding")
local scrollList = Instance.new("UIListLayout")

-- --- Функции ---
local btnFOV = Instance.new("TextButton")
local statusFOV = Instance.new("TextLabel")
local fovInputBox = Instance.new("TextBox")
local btnRes = Instance.new("TextButton")
local statusRes = Instance.new("TextLabel")

-- --- 3-е лицо ---
local btnThirdPerson = Instance.new("TextButton")
local statusThirdPerson = Instance.new("TextLabel")

-- --- Skybox ---
local skyboxInputBox = Instance.new("TextBox")
local btnSkybox = Instance.new("TextButton")
local btnResetSkybox = Instance.new("TextButton")
local statusSkybox = Instance.new("TextLabel")

-- --- ESP ---
local playerDropdown = Instance.new("TextBox")
local btnAddESP = Instance.new("TextButton")
local btnRemoveESP = Instance.new("TextButton")
local playersList = Instance.new("ScrollingFrame")
local refreshBtn = Instance.new("TextButton")
local espPlayersList = Instance.new("ScrollingFrame")
local statusESP = Instance.new("TextLabel")

-- --- НАСТРОЙКА БИНДА ---
local bindSection = Instance.new("Frame")
local bindLabel = Instance.new("TextLabel")
local bindButton = Instance.new("TextButton")
local bindStatus = Instance.new("TextLabel")

local fpsLabel = Instance.new("TextLabel")
local notificationContainer = Instance.new("Frame")

-- --- ЗАГРУЗОЧНЫЙ ЭКРАН ---
local loadingFrame = Instance.new("Frame")
local blurEffect = Instance.new("BlurEffect")
local loadingText = Instance.new("TextLabel")
local loadingSubText = Instance.new("TextLabel")

gui.Name = "GoxieScriptGUI"
gui.Parent = game.CoreGui
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- === ЗВУК ПРИ ЗАПУСКЕ ===
local function playStartupSound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://82845990304289"
    sound.Volume = 0.6
    sound.Parent = gui
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 5)
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

playStartupSound()

for i = 0, 20 do
    blurEffect.Size = i
    wait(0.02)
end

wait(1)

for i = 20, 0, -1 do
    blurEffect.Size = i
    wait(0.02)
end

loadingFrame:Destroy()
blurEffect:Destroy()

frame.Visible = false

local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- === 3-Е ЛИЦО (СВОБОДНАЯ КАМЕРА) ===
local thirdPersonActive = false
local thirdPersonCFrame = nil

local function setThirdPerson(enabled)
    thirdPersonActive = enabled
    if enabled then
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            thirdPersonCFrame = CFrame.new(rootPart.Position - Vector3.new(10, 5, 10), rootPart.Position)
            camera.CameraType = Enum.CameraType.Scriptable
            camera.CFrame = thirdPersonCFrame
        end
        statusThirdPerson.Text = "Status: ON (3 лицо)"
        statusThirdPerson.TextColor3 = Color3.fromRGB(170, 190, 170)
        btnThirdPerson.Text = "ВЫКЛЮЧИТЬ 3 ЛИЦО"
    else
        camera.CameraType = Enum.CameraType.Custom
        statusThirdPerson.Text = "Status: OFF (1 лицо)"
        statusThirdPerson.TextColor3 = Color3.fromRGB(140, 140, 155)
        btnThirdPerson.Text = "ВКЛЮЧИТЬ 3 ЛИЦО"
    end
end

-- Свободное управление камерой (правой кнопкой мыши)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not thirdPersonActive then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not thirdPersonActive then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
    end
end)

-- Управление камерой мышью
local mouse = player:GetMouse()
local lastMousePos = Vector2.new()
local rotating = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not thirdPersonActive then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rotating = true
        lastMousePos = UserInputService:GetMouseLocation()
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        rotating = false
    end
end)

local yaw = 45
local pitch = 25
local distance = 15

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
    
    local cameraPos = rootPart.Position + offset
    camera.CFrame = CFrame.new(cameraPos, rootPart.Position)
    camera.CameraType = Enum.CameraType.Scriptable
end)

-- Обработка колёсика мыши для приближения/отдаления
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not thirdPersonActive then return end
    if input.KeyCode == Enum.KeyCode.ButtonWheelUp then
        distance = math.max(distance - 1, 5)
    elseif input.KeyCode == Enum.KeyCode.ButtonWheelDown then
        distance = math.min(distance + 1, 30)
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
    if not id or id == "" then
        statusSkybox.Text = "Ошибка: введите ID"
        statusSkybox.TextColor3 = Color3.fromRGB(200, 120, 120)
        return false
    end
    
    local assetId = tonumber(id)
    if not assetId then
        statusSkybox.Text = "Ошибка: ID должно быть числом"
        statusSkybox.TextColor3 = Color3.fromRGB(200, 120, 120)
        return false
    end
    
    if not originalSkybox then
        saveOriginalSkybox()
    end
    
    local sky = lighting:FindFirstChildWhichIsA("Sky")
    if not sky then
        sky = Instance.new("Sky")
        sky.Parent = lighting
    end
    
    local assetUrl = "rbxassetid://" .. assetId
    
    local success, err = pcall(function()
        sky.SkyboxBk = assetUrl
        sky.SkyboxDn = assetUrl
        sky.SkyboxFt = assetUrl
        sky.SkyboxLf = assetUrl
        sky.SkyboxRt = assetUrl
        sky.SkyboxUp = assetUrl
    end)
    
    if success then
        statusSkybox.Text = "Небо изменено! ID: " .. assetId
        statusSkybox.TextColor3 = Color3.fromRGB(120, 200, 120)
        showNotification("🌤️ Небо изменено на ID: " .. assetId, false)
        return true
    else
        statusSkybox.Text = "Ошибка: неверный ID"
        statusSkybox.TextColor3 = Color3.fromRGB(200, 120, 120)
        return false
    end
end

local function resetSkybox()
    if originalSkybox then
        local sky = lighting:FindFirstChildWhichIsA("Sky")
        if not sky then
            sky = Instance.new("Sky")
            sky.Parent = lighting
        end
        sky.SkyboxBk = originalSkybox.SkyboxBk
        sky.SkyboxDn = originalSkybox.SkyboxDn
        sky.SkyboxFt = originalSkybox.SkyboxFt
        sky.SkyboxLf = originalSkybox.SkyboxLf
        sky.SkyboxRt = originalSkybox.SkyboxRt
        sky.SkyboxUp = originalSkybox.SkyboxUp
        statusSkybox.Text = "Небо сброшено"
        statusSkybox.TextColor3 = Color3.fromRGB(140, 140, 155)
        showNotification("🔄 Небо сброшено до оригинала", false)
    else
        statusSkybox.Text = "Нечего сбрасывать"
        statusSkybox.TextColor3 = Color3.fromRGB(200, 120, 120)
    end
end

-- === МНОЖЕСТВЕННЫЙ ESP ===
local espPlayers = {}
local nameTags = {}

local function createNametag(character, playerName)
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 250, 0, 40)
    billboard.Adornee = character:FindFirstChild("Head") or character
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = character

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Text = playerName
    textLabel.TextSize = 18
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextStrokeTransparency = 0.3
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.Parent = billboard

    return billboard
end

local function addESP(targetPlayer)
    if not targetPlayer or targetPlayer == player then return false end
    if espPlayers[targetPlayer] then return false end
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(0, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    
    if targetPlayer.Character then
        highlight.Parent = targetPlayer.Character
        local tag = createNametag(targetPlayer.Character, targetPlayer.Name)
        nameTags[targetPlayer] = tag
    end
    
    local characterAddedCon = targetPlayer.CharacterAdded:Connect(function(character)
        highlight.Parent = character
        if nameTags[targetPlayer] then nameTags[targetPlayer]:Destroy() end
        nameTags[targetPlayer] = createNametag(character, targetPlayer.Name)
    end)
    
    local characterRemovingCon = targetPlayer.CharacterRemoving:Connect(function()
        highlight.Parent = nil
        if nameTags[targetPlayer] then nameTags[targetPlayer]:Destroy() end
        nameTags[targetPlayer] = nil
    end)
    
    espPlayers[targetPlayer] = {
        highlight = highlight,
        addedCon = characterAddedCon,
        removingCon = characterRemovingCon
    }
    
    updateESPListDisplay()
    return true
end

local function removeESP(targetPlayer)
    if not espPlayers[targetPlayer] then return false end
    
    local data = espPlayers[targetPlayer]
    data.highlight:Destroy()
    data.addedCon:Disconnect()
    data.removingCon:Disconnect()
    if nameTags[targetPlayer] then nameTags[targetPlayer]:Destroy() end
    nameTags[targetPlayer] = nil
    espPlayers[targetPlayer] = nil
    
    updateESPListDisplay()
    return true
end

local function removeAllESP()
    for plr, _ in pairs(espPlayers) do
        removeESP(plr)
    end
end

local function updateESPListDisplay()
    for _, child in ipairs(espPlayersList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local y = 0
    for plr, _ in pairs(espPlayers) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 25)
        btn.Position = UDim2.new(0, 5, 0, y)
        btn.Text = plr.Name .. " ✖"
        btn.BackgroundColor3 = Color3.fromRGB(30, 20, 20)
        btn.BackgroundTransparency = 0.3
        btn.TextColor3 = Color3.fromRGB(255, 150, 150)
        btn.TextSize = 12
        btn.Font = Enum.Font.Gotham
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(55, 55, 70)
        btn.Parent = espPlayersList
        setupButtonHover(btn)
        
        btn.MouseButton1Click:Connect(function()
            removeESP(plr)
            showNotification("❌ ESP выключен для " .. plr.Name, false)
            local count = 0
            for _ in pairs(espPlayers) do count = count + 1 end
            if count == 0 then
                statusESP.Text = "ESP Status: Нет активных"
                statusESP.TextColor3 = Color3.fromRGB(140, 140, 155)
            else
                statusESP.Text = "ESP Status: Активно (" .. count .. " игроков)"
                statusESP.TextColor3 = Color3.fromRGB(170, 190, 170)
            end
        end)
        y = y + 30
    end
    espPlayersList.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

local function updatePlayersList()
    for _, child in ipairs(playersList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
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
            btn.TextSize = 12
            btn.Font = Enum.Font.Gotham
            btn.BorderSizePixel = 1
            btn.BorderColor3 = Color3.fromRGB(45, 45, 55)
            btn.Parent = playersList
            setupButtonHover(btn)
            
            btn.MouseButton1Click:Connect(function()
                playerDropdown.Text = plr.Name
            end)
            y = y + 30
        end
    end
    playersList.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

-- === НАСТРОЙКА БИНДА ===
local currentBind = Enum.KeyCode.RightShift
local isWaitingForBind = false

local function updateBindDisplay()
    if bindButton then bindButton.Text = currentBind.Name end
    if bindStatus then
        bindStatus.Text = "Текущий бинд: " .. currentBind.Name .. " | Нажми на кнопку, чтобы изменить"
        bindStatus.TextColor3 = Color3.fromRGB(170, 190, 170)
    end
end

local function setBind(keyCode)
    currentBind = keyCode
    updateBindDisplay()
    showNotification("🔑 Бинд изменён на: " .. keyCode.Name, false)
end

local function onInputBegan(input, gameProcessed)
    if gameProcessed then return end

    if isWaitingForBind then
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            setBind(input.KeyCode)
            isWaitingForBind = false
            if bindButton then bindButton.Text = currentBind.Name end
            if bindStatus then
                bindStatus.Text = "Готово! Новый бинд: " .. currentBind.Name
                wait(1)
                bindStatus.Text = "Нажми на кнопку, чтобы изменить бинд"
                bindStatus.TextColor3 = Color3.fromRGB(140, 140, 155)
            end
        end
        return
    end

    if input.KeyCode == currentBind then
        frame.Visible = not frame.Visible
    end
end

UserInputService.InputBegan:Connect(onInputBegan)

-- === ПОДСВЕТКА КНОПОК ===
local function setupButtonHover(button)
    local originalColor = button.BackgroundColor3
    local originalTrans = button.BackgroundTransparency
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        button.BackgroundTransparency = 0.15
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = originalColor
        button.BackgroundTransparency = originalTrans
    end)
end

-- --- УВЕДОМЛЕНИЯ ---
notificationContainer.Size = UDim2.new(0, 300, 0, 200)
notificationContainer.Position = UDim2.new(1, -310, 0, 10)
notificationContainer.BackgroundTransparency = 1
notificationContainer.Parent = gui

local function showNotification(message, isError)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, -10, 0, 40)
    notif.Position = UDim2.new(0, 5, 0, 0)
    notif.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    notif.BackgroundTransparency = 0.2
    notif.BorderSizePixel = 1
    notif.BorderColor3 = Color3.fromRGB(60, 60, 80)
    notif.Parent = notificationContainer

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = message
    text.TextColor3 = isError and Color3.fromRGB(255, 120, 120) or Color3.fromRGB(120, 255, 120)
    text.TextSize = 14
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

-- --- ОСНОВНОЕ ОКНО ---
frame.Size = UDim2.new(0, 550, 0, 800)
frame.Position = UDim2.new(0.5, -275, 0.5, -400)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.25
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(30, 30, 35)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
title.BackgroundTransparency = 0.3
title.Text = "Goxie Script"
title.TextColor3 = Color3.fromRGB(200, 200, 210)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = frame

closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 5)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
closeBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
closeBtn.BackgroundTransparency = 0.2
closeBtn.BorderSizePixel = 0
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
end)
setupButtonHover(closeBtn)

-- --- СКРОЛЛ КОНТЕЙНЕР ---
scrollContainer.Size = UDim2.new(1, -20, 1, -55)
scrollContainer.Position = UDim2.new(0, 10, 0, 50)
scrollContainer.BackgroundTransparency = 1
scrollContainer.BorderSizePixel = 0
scrollContainer.ScrollBarThickness = 6
scrollContainer.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
scrollContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollContainer.Parent = frame

scrollPadding.PaddingLeft = UDim.new(0, 10)
scrollPadding.PaddingRight = UDim.new(0, 10)
scrollPadding.PaddingTop = UDim.new(0, 10)
scrollPadding.PaddingBottom = UDim.new(0, 10)
scrollPadding.Parent = scrollContainer

scrollList.SortOrder = Enum.SortOrder.LayoutOrder
scrollList.Padding = UDim.new(0, 15)
scrollList.Parent = scrollContainer

-- --- FPS ---
fpsLabel.Size = UDim2.new(0, 180, 0, 50)
fpsLabel.Position = UDim2.new(0.5, -90, 0, 0)
fpsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
fpsLabel.BackgroundTransparency = 0.5
fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsLabel.TextSize = 24
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextXAlignment = Enum.TextXAlignment.Center
fpsLabel.BorderSizePixel = 2
fpsLabel.BorderColor3 = Color3.fromRGB(70, 70, 85)
fpsLabel.Parent = gui

local frameCount = 0
local lastTime = tick()
local fpsConnection = nil

local function updateFPS()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastTime >= 1 then
        local currentFPS = frameCount
        frameCount = 0
        lastTime = now
        fpsLabel.Text = "FPS: " .. currentFPS
    end
end
fpsConnection = RunService.RenderStepped:Connect(updateFPS)

-- --- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ---
local function createSection(titleText, height)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, height)
    section.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    section.BackgroundTransparency = 0.4
    section.BorderSizePixel = 1
    section.BorderColor3 = Color3.fromRGB(35, 35, 45)
    section.Parent = scrollContainer

    local sectionTitle = Instance.new("TextLabel")
    sectionTitle.Size = UDim2.new(1, 0, 0, 30)
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.Text = titleText
    sectionTitle.TextColor3 = Color3.fromRGB(180, 180, 195)
    sectionTitle.TextSize = 15
    sectionTitle.Font = Enum.Font.GothamBold
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sectionTitle.Parent = section

    return section
end

-- === 1. FOV ===
local fovSection = createSection("FOV LOCK", 140)
btnFOV.Size = UDim2.new(1, -20, 0, 35)
btnFOV.Position = UDim2.new(0, 10, 0, 35)
btnFOV.Text = "ACTIVATE FOV LOCK"
btnFOV.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
btnFOV.BackgroundTransparency = 0.3
btnFOV.TextColor3 = Color3.fromRGB(200, 200, 210)
btnFOV.TextSize = 13
btnFOV.Font = Enum.Font.Gotham
btnFOV.BorderSizePixel = 1
btnFOV.BorderColor3 = Color3.fromRGB(45, 45, 55)
btnFOV.Parent = fovSection
setupButtonHover(btnFOV)

local fovInputLabel = Instance.new("TextLabel")
fovInputLabel.Size = UDim2.new(0.4, 0, 0, 25)
fovInputLabel.Position = UDim2.new(0, 10, 0, 80)
fovInputLabel.BackgroundTransparency = 1
fovInputLabel.Text = "Значение FOV (80-140):"
fovInputLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
fovInputLabel.TextSize = 12
fovInputLabel.TextXAlignment = Enum.TextXAlignment.Left
fovInputLabel.Parent = fovSection

fovInputBox.Size = UDim2.new(0.3, 0, 0, 30)
fovInputBox.Position = UDim2.new(0.55, 0, 0, 77)
fovInputBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
fovInputBox.BackgroundTransparency = 0.3
fovInputBox.TextColor3 = Color3.fromRGB(210, 210, 220)
fovInputBox.TextSize = 13
fovInputBox.Font = Enum.Font.Gotham
fovInputBox.BorderSizePixel = 1
fovInputBox.BorderColor3 = Color3.fromRGB(45, 45, 55)
fovInputBox.Text = "85"
fovInputBox.PlaceholderText = "85"
fovInputBox.ClearTextOnFocus = true
fovInputBox.Parent = fovSection
setupButtonHover(fovInputBox)

statusFOV.Size = UDim2.new(1, -20, 0, 20)
statusFOV.Position = UDim2.new(0, 10, 0, 115)
statusFOV.Text = "Status: OFF"
statusFOV.TextColor3 = Color3.fromRGB(140, 140, 155)
statusFOV.TextSize = 12
statusFOV.TextXAlignment = Enum.TextXAlignment.Left
statusFOV.BackgroundTransparency = 1
statusFOV.Parent = fovSection

-- === 2. RESOLUTION ===
local resSection = createSection("RESOLUTION MOD", 100)
btnRes.Size = UDim2.new(1, -20, 0, 40)
btnRes.Position = UDim2.new(0, 10, 0, 35)
btnRes.Text = "ACTIVATE RESOLUTION MOD (0.80)"
btnRes.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
btnRes.BackgroundTransparency = 0.3
btnRes.TextColor3 = Color3.fromRGB(200, 200, 210)
btnRes.TextSize = 13
btnRes.Font = Enum.Font.Gotham
btnRes.BorderSizePixel = 1
btnRes.BorderColor3 = Color3.fromRGB(45, 45, 55)
btnRes.Parent = resSection
setupButtonHover(btnRes)

statusRes.Size = UDim2.new(1, -20, 0, 20)
statusRes.Position = UDim2.new(0, 10, 0, 80)
statusRes.Text = "Status: OFF"
statusRes.TextColor3 = Color3.fromRGB(140, 140, 155)
statusRes.TextSize = 12
statusRes.TextXAlignment = Enum.TextXAlignment.Left
statusRes.BackgroundTransparency = 1
statusRes.Parent = resSection

-- === 3. 3-Е ЛИЦО ===
local thirdPersonSection = createSection("ТРЕТЬЕ ЛИЦО", 100)
btnThirdPerson.Size = UDim2.new(1, -20, 0, 40)
btnThirdPerson.Position = UDim2.new(0, 10, 0, 35)
btnThirdPerson.Text = "ВКЛЮЧИТЬ 3 ЛИЦО"
btnThirdPerson.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
btnThirdPerson.BackgroundTransparency = 0.3
btnThirdPerson.TextColor3 = Color3.fromRGB(200, 200, 210)
btnThirdPerson.TextSize = 13
btnThirdPerson.Font = Enum.Font.Gotham
btnThirdPerson.BorderSizePixel = 1
btnThirdPerson.BorderColor3 = Color3.fromRGB(45, 45, 55)
btnThirdPerson.Parent = thirdPersonSection
setupButtonHover(btnThirdPerson)

statusThirdPerson.Size = UDim2.new(1, -20, 0, 20)
statusThirdPerson.Position = UDim2.new(0, 10, 0, 80)
statusThirdPerson.Text = "Status: OFF (1 лицо)"
statusThirdPerson.TextColor3 = Color3.fromRGB(140, 140, 155)
statusThirdPerson.TextSize = 12
statusThirdPerson.TextXAlignment = Enum.TextXAlignment.Left
statusThirdPerson.BackgroundTransparency = 1
statusThirdPerson.Parent = thirdPersonSection

btnThirdPerson.MouseButton1Click:Connect(function()
    setThirdPerson(not thirdPersonActive)
end)

-- === 4. SKYBOX ===
local skyboxSection = createSection("SKYBOX CHANGER", 130)

skyboxInputBox.Size = UDim2.new(0.6, 0, 0, 35)
skyboxInputBox.Position = UDim2.new(0, 10, 0, 35)
skyboxInputBox.PlaceholderText = "Введите ID неба (например: 91458024)"
skyboxInputBox.Text = ""
skyboxInputBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
skyboxInputBox.BackgroundTransparency = 0.3
skyboxInputBox.TextColor3 = Color3.fromRGB(210, 210, 220)
skyboxInputBox.TextSize = 12
skyboxInputBox.Font = Enum.Font.Gotham
skyboxInputBox.BorderSizePixel = 1
skyboxInputBox.BorderColor3 = Color3.fromRGB(45, 45, 55)
skyboxInputBox.ClearTextOnFocus = false
skyboxInputBox.Parent = skyboxSection

btnSkybox.Size = UDim2.new(0.28, 0, 0, 35)
btnSkybox.Position = UDim2.new(0.62, 0, 0, 35)
btnSkybox.Text = "ПРИМЕНИТЬ"
btnSkybox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
btnSkybox.BackgroundTransparency = 0.3
btnSkybox.TextColor3 = Color3.fromRGB(200, 200, 210)
btnSkybox.TextSize = 11
btnSkybox.Font = Enum.Font.Gotham
btnSkybox.BorderSizePixel = 1
btnSkybox.BorderColor3 = Color3.fromRGB(45, 45, 55)
btnSkybox.Parent = skyboxSection
setupButtonHover(btnSkybox)

btnResetSkybox.Size = UDim2.new(0.28, 0, 0, 35)
btnResetSkybox.Position = UDim2.new(0.62, 0, 0, 75)
btnResetSkybox.Text = "СБРОСИТЬ"
btnResetSkybox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
btnResetSkybox.BackgroundTransparency = 0.3
btnResetSkybox.TextColor3 = Color3.fromRGB(200, 200, 210)
btnResetSkybox.TextSize = 11
btnResetSkybox.Font = Enum.Font.Gotham
btnResetSkybox.BorderSizePixel = 1
btnResetSkybox.BorderColor3 = Color3.fromRGB(45, 45, 55)
btnResetSkybox.Parent = skyboxSection
setupButtonHover(btnResetSkybox)

statusSkybox.Size = UDim2.new(1, -20, 0, 20)
statusSkybox.Position = UDim2.new(0, 10, 0, 115)
statusSkybox.Text = "Статус: готов"
statusSkybox.TextColor3 = Color3.fromRGB(140, 140, 155)
statusSkybox.TextSize = 11
statusSkybox.TextXAlignment = Enum.TextXAlignment.Left
statusSkybox.BackgroundTransparency = 1
statusSkybox.Parent = skyboxSection

btnSkybox.MouseButton1Click:Connect(function()
    applySkybox(skyboxInputBox.Text)
end)

btnResetSkybox.MouseButton1Click:Connect(function()
    resetSkybox()
end)

-- === 5. ESP ===
local espSection = createSection("ESP - МНОЖЕСТВЕННЫЙ", 370)

playerDropdown.Size = UDim2.new(1, -20, 0, 35)
playerDropdown.Position = UDim2.new(0, 10, 0, 35)
playerDropdown.PlaceholderText = "Введите имя игрока или выберите из списка"
playerDropdown.Text = ""
playerDropdown.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
playerDropdown.BackgroundTransparency = 0.3
playerDropdown.TextColor3 = Color3.fromRGB(210, 210, 220)
playerDropdown.TextSize = 12
playerDropdown.Font = Enum.Font.Gotham
playerDropdown.BorderSizePixel = 1
playerDropdown.BorderColor3 = Color3.fromRGB(45, 45, 55)
playerDropdown.ClearTextOnFocus = false
playerDropdown.Parent = espSection

local buttonWidth = 0.32
local buttonHeight = 30

refreshBtn.Size = UDim2.new(buttonWidth, 0, 0, buttonHeight)
refreshBtn.Position = UDim2.new(0, 10, 0, 78)
refreshBtn.Text = "Обновить список"
refreshBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
refreshBtn.BackgroundTransparency = 0.3
refreshBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
refreshBtn.TextSize = 11
refreshBtn.Font = Enum.Font.Gotham
refreshBtn.BorderSizePixel = 1
refreshBtn.BorderColor3 = Color3.fromRGB(45, 45, 55)
refreshBtn.Parent = espSection
setupButtonHover(refreshBtn)

btnAddESP.Size = UDim2.new(buttonWidth, 0, 0, buttonHeight)
btnAddESP.Position = UDim2.new(0.34, 0, 0, 78)
btnAddESP.Text = "➕ ДОБАВИТЬ"
btnAddESP.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
btnAddESP.BackgroundTransparency = 0.3
btnAddESP.TextColor3 = Color3.fromRGB(200, 200, 210)
btnAddESP.TextSize = 11
btnAddESP.Font = Enum.Font.Gotham
btnAddESP.BorderSizePixel = 1
btnAddESP.BorderColor3 = Color3.fromRGB(45, 45, 55)
btnAddESP.Parent = espSection
setupButtonHover(btnAddESP)

btnRemoveESP.Size = UDim2.new(buttonWidth, 0, 0, buttonHeight)
btnRemoveESP.Position = UDim2.new(0.68, 0, 0, 78)
btnRemoveESP.Text = "❌ УДАЛИТЬ ВСЕХ"
btnRemoveESP.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
btnRemoveESP.BackgroundTransparency = 0.3
btnRemoveESP.TextColor3 = Color3.fromRGB(200, 200, 210)
btnRemoveESP.TextSize = 11
btnRemoveESP.Font = Enum.Font.Gotham
btnRemoveESP.BorderSizePixel = 1
btnRemoveESP.BorderColor3 = Color3.fromRGB(45, 45, 55)
btnRemoveESP.Parent = espSection
setupButtonHover(btnRemoveESP)

local playersLabel = Instance.new("TextLabel")
playersLabel.Size = UDim2.new(0.48, 0, 0, 20)
playersLabel.Position = UDim2.new(0, 10, 0, 115)
playersLabel.BackgroundTransparency = 1
playersLabel.Text = "Доступные игроки:"
playersLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
playersLabel.TextSize = 12
playersLabel.TextXAlignment = Enum.TextXAlignment.Left
playersLabel.Parent = espSection

playersList.Size = UDim2.new(0.48, 0, 0, 120)
playersList.Position = UDim2.new(0, 10, 0, 135)
playersList.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
playersList.BackgroundTransparency = 0.2
playersList.BorderSizePixel = 1
playersList.BorderColor3 = Color3.fromRGB(45, 45, 55)
playersList.ScrollBarThickness = 6
playersList.Parent = espSection

local espPlayersLabel = Instance.new("TextLabel")
espPlayersLabel.Size = UDim2.new(0.48, 0, 0, 20)
espPlayersLabel.Position = UDim2.new(0.51, 0, 0, 115)
espPlayersLabel.BackgroundTransparency = 1
espPlayersLabel.Text = "ESP активен для:"
espPlayersLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
espPlayersLabel.TextSize = 12
espPlayersLabel.TextXAlignment = Enum.TextXAlignment.Left
espPlayersLabel.Parent = espSection

espPlayersList.Size = UDim2.new(0.48, 0, 0, 120)
espPlayersList.Position = UDim2.new(0.51, 0, 0, 135)
espPlayersList.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
espPlayersList.BackgroundTransparency = 0.2
espPlayersList.BorderSizePixel = 1
espPlayersList.BorderColor3 = Color3.fromRGB(45, 45, 55)
espPlayersList.ScrollBarThickness = 6
espPlayersList.Parent = espSection

statusESP.Size = UDim2.new(1, -20, 0, 25)
statusESP.Position = UDim2.new(0, 10, 0, 270)
statusESP.Text = "ESP Status: Нет активных"
statusESP.TextColor3 = Color3.fromRGB(140, 140, 155)
statusESP.TextSize = 12
statusESP.TextXAlignment = Enum.TextXAlignment.Left
statusESP.BackgroundTransparency = 1
statusESP.Parent = espSection

refreshBtn.MouseButton1Click:Connect(function()
    updatePlayersList()
    showNotification("📋 Список игроков обновлён", false)
end)

btnAddESP.MouseButton1Click:Connect(function()
    local name = playerDropdown.Text
    if name == nil or name == "" then
        showNotification("❌ Введите имя игрока", true)
        return
    end
    local target = game.Players:FindFirstChild(name)
    if not target then
        showNotification("❌ Игрок не найден", true)
        return
    end
    if addESP(target) then
        local count = 0
        for _ in pairs(espPlayers) do count = count + 1 end
        showNotification("✅ ESP добавлен для " .. target.Name, false)
        statusESP.Text = "ESP Status: Активно (" .. count .. " игроков)"
        statusESP.TextColor3 = Color3.fromRGB(170, 190, 170)
    else
        showNotification("❌ Уже в ESP или нельзя добавить себя", true)
    end
    playerDropdown.Text = ""
end)

btnRemoveESP.MouseButton1Click:Connect(function()
    removeAllESP()
    showNotification("🗑️ Весь ESP отключён", false)
    statusESP.Text = "ESP Status: Нет активных"
    statusESP.TextColor3 = Color3.fromRGB(140, 140, 155)
end)

-- === 6. НАСТРОЙКА БИНДА ===
bindSection.Size = UDim2.new(1, 0, 0, 80)
bindSection.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bindSection.BackgroundTransparency = 0.4
bindSection.BorderSizePixel = 1
bindSection.BorderColor3 = Color3.fromRGB(35, 35, 45)
bindSection.Parent = scrollContainer

local bindTitle = Instance.new("TextLabel")
bindTitle.Size = UDim2.new(1, 0, 0, 30)
bindTitle.BackgroundTransparency = 1
bindTitle.Text = "НАСТРОЙКА БИНДА МЕНЮ"
bindTitle.TextColor3 = Color3.fromRGB(180, 180, 195)
bindTitle.TextSize = 15
bindTitle.Font = Enum.Font.GothamBold
bindTitle.TextXAlignment = Enum.TextXAlignment.Left
bindTitle.Parent = bindSection

bindLabel.Size = UDim2.new(0.5, 0, 0, 25)
bindLabel.Position = UDim2.new(0, 10, 0, 35)
bindLabel.BackgroundTransparency = 1
bindLabel.Text = "Клавиша для открытия:"
bindLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
bindLabel.TextSize = 12
bindLabel.TextXAlignment = Enum.TextXAlignment.Left
bindLabel.Parent = bindSection

bindButton.Size = UDim2.new(0.2, 0, 0, 30)
bindButton.Position = UDim2.new(0.6, 0, 0, 33)
bindButton.Text = currentBind.Name
bindButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
bindButton.BackgroundTransparency = 0.2
bindButton.TextColor3 = Color3.fromRGB(220, 220, 230)
bindButton.TextSize = 12
bindButton.Font = Enum.Font.GothamBold
bindButton.BorderSizePixel = 1
bindButton.BorderColor3 = Color3.fromRGB(55, 55, 70)
bindButton.Parent = bindSection
setupButtonHover(bindButton)

bindStatus.Size = UDim2.new(1, -20, 0, 20)
bindStatus.Position = UDim2.new(0, 10, 0, 60)
bindStatus.BackgroundTransparency = 1
bindStatus.Text = "Нажми на кнопку, чтобы изменить бинд"
bindStatus.TextColor3 = Color3.fromRGB(140, 140, 155)
bindStatus.TextSize = 11
bindStatus.TextXAlignment = Enum.TextXAlignment.Left
bindStatus.Parent = bindSection

bindButton.MouseButton1Click:Connect(function()
    if isWaitingForBind then
        isWaitingForBind = false
        bindButton.Text = currentBind.Name
        bindStatus.Text = "Нажми на кнопку, чтобы изменить бинд"
        bindStatus.TextColor3 = Color3.fromRGB(140, 140, 155)
    else
        isWaitingForBind = true
        bindButton.Text = "..."
        bindStatus.Text = "Ожидание нажатия клавиши..."
        bindStatus.TextColor3 = Color3.fromRGB(255, 200, 100)
    end
end)

-- Обновление CanvasSize
local function updateCanvasSize()
    local totalHeight = 0
    for _, child in ipairs(scrollContainer:GetChildren()) do
        if child:IsA("Frame") and child ~= scrollPadding and child ~= scrollList then
            totalHeight = totalHeight + child.Size.Y.Offset + scrollList.Padding.Offset
        end
    end
    scrollContainer.CanvasSize = UDim2.new(0, 0, 0, totalHeight + 20)
end

game:GetService("RunService").Heartbeat:Wait()
updateCanvasSize()
scrollContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCanvasSize)

-- === ЛОГИКА FOV ===
local fovActive = false
local fovConnection = nil
local currentFOV = 85

fovInputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local newValue = tonumber(fovInputBox.Text)
        if newValue and newValue >= 80 and newValue <= 140 then
            currentFOV = newValue
            if fovActive then
                camera.FieldOfView = currentFOV
            end
            showNotification("✅ FOV установлен на " .. currentFOV, false)
        else
            showNotification("❌ Введите число от 80 до 140", true)
            fovInputBox.Text = tostring(currentFOV)
        end
    end
end)

local function setFOVLock(enabled)
    if enabled then
        if not fovConnection then
            fovConnection = camera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
                if camera.FieldOfView ~= currentFOV then
                    camera.FieldOfView = currentFOV
                end
            end)
            camera.FieldOfView = currentFOV
        end
        statusFOV.Text = "Status: ON (" .. currentFOV .. " - LOCKED)"
        statusFOV.TextColor3 = Color3.fromRGB(170, 190, 170)
        btnFOV.Text = "DEACTIVATE FOV LOCK"
    else
        if fovConnection then
            fovConnection:Disconnect()
            fovConnection = nil
            camera.FieldOfView = 70
        end
        statusFOV.Text = "Status: OFF"
        statusFOV.TextColor3 = Color3.fromRGB(140, 140, 155)
        btnFOV.Text = "ACTIVATE FOV LOCK"
    end
    fovActive = enabled
end

btnFOV.MouseButton1Click:Connect(function()
    setFOVLock(not fovActive)
end)

-- === ЛОГИКА RESOLUTION ===
local resActive = false
local resConnection = nil
local resolutionValue = 0.80

local function setResolution(enabled)
    if enabled then
        if not resConnection then
            resConnection = RunService.RenderStepped:Connect(function()
                camera.CFrame = camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, resolutionValue, 0, 0, 0, 1)
            end)
        end
        statusRes.Text = "Status: ON (" .. resolutionValue .. ")"
        statusRes.TextColor3 = Color3.fromRGB(170, 190, 170)
        btnRes.Text = "DEACTIVATE RESOLUTION MOD"
    else
        if resConnection then
            resConnection:Disconnect()
            resConnection = nil
        end
        statusRes.Text = "Status: OFF"
        statusRes.TextColor3 = Color3.fromRGB(140, 140, 155)
        btnRes.Text = "ACTIVATE RESOLUTION MOD (0.80)"
    end
    resActive = enabled
end

btnRes.MouseButton1Click:Connect(function()
    setResolution(not resActive)
end)

game.Players.PlayerRemoving:Connect(function(leavingPlayer)
    if espPlayers[leavingPlayer] then
        removeESP(leavingPlayer)
        local count = 0
        for _ in pairs(espPlayers) do count = count + 1 end
        if count == 0 then
            statusESP.Text = "ESP Status: Нет активных"
            statusESP.TextColor3 = Color3.fromRGB(140, 140, 155)
        else
            statusESP.Text = "ESP Status: Активно (" .. count .. " игроков)"
            statusESP.TextColor3 = Color3.fromRGB(170, 190, 170)
        end
        showNotification("🔴 " .. leavingPlayer.Name .. " вышел из игры, ESP отключён", true)
    end
end)

updatePlayersList()
updateBindDisplay()
updateESPListDisplay()

print("Goxie Script Menu loaded | Press " .. currentBind.Name .. " to open/close | v3.3 - Fixed ESP + Free 3rd Person Camera")
