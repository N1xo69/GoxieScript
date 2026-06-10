-- Goxie Script Menu (БЕЗ SKYBOX - ПОЛНАЯ ВЕРСИЯ)
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
local tabESP = Instance.new("TextButton")
local tabMisc = Instance.new("TextButton")
local tabSettings = Instance.new("TextButton")

-- Контент
local contentContainer = Instance.new("ScrollingFrame")

-- --- FOV ---
local fovToggleBtn = Instance.new("TextButton")
local fovStatus = Instance.new("TextLabel")
local fovInputBox = Instance.new("TextBox")

-- --- RESOLUTION ---
local resToggleBtn = Instance.new("TextButton")
local resStatus = Instance.new("TextLabel")

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
local teleportKey = Enum.KeyCode.Z

-- --- SETTINGS ---
local transparencyInput = Instance.new("TextBox")
local menuBindBtn = Instance.new("TextButton")
local menuBindStatus = Instance.new("TextLabel")

local fpsLabel = Instance.new("TextLabel")
local loadingFrame = Instance.new("Frame")
local blurEffect = Instance.new("BlurEffect")
local loadingText = Instance.new("TextLabel")
local loadingSubText = Instance.new("TextLabel")

gui.Name = "GoxieScriptGUI"
gui.Parent = game.CoreGui
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- === НАСТРОЙКИ ===
local menuTransparency = 85
local menuWidth = 500
local menuHeight = 400
local currentBind = Enum.KeyCode.RightShift
local waitingForBind = false

-- === ЗВУК ===
local function playSound()
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

playSound()

for i = 0, 20 do blurEffect.Size = i wait(0.02) end
wait(1)
for i = 20, 0, -1 do blurEffect.Size = i wait(0.02) end
loadingFrame:Destroy()
blurEffect:Destroy()

frame.Visible = false

local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- === ОБНОВЛЕНИЕ МЕНЮ ===
local function updateMenu()
    frame.Size = UDim2.new(0, menuWidth, 0, menuHeight)
    frame.Position = UDim2.new(0.5, -menuWidth/2, 0.5, -menuHeight/2)
    frame.BackgroundTransparency = 1 - (menuTransparency / 100)
end

-- === ТЕЛЕПОРТ ===
local function teleport()
    local mouse = player:GetMouse()
    local hit = mouse.Hit
    if hit and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(hit.X, hit.Y + 3, hit.Z)
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if waitingForBind then
        if input.KeyCode ~= Enum.KeyCode.Unknown then
            currentBind = input.KeyCode
            waitingForBind = false
            menuBindBtn.Text = currentBind.Name
            menuBindStatus.Text = "Бинд: " .. currentBind.Name
            wait(1)
            menuBindStatus.Text = "Нажми для смены"
            playSound()
        end
        return
    end
    if input.KeyCode == currentBind then
        frame.Visible = not frame.Visible
    end
    if input.KeyCode == teleportKey then
        teleport()
    end
end)

-- === ESP ===
local espListData = {}

local function createNametag(character, playerName)
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 250, 0, 30)
    billboard.Adornee = character:FindFirstChild("Head") or character
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = character
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Text = playerName
    textLabel.TextSize = 14
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextStrokeTransparency = 0.3
    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    textLabel.Parent = billboard
    return billboard
end

local function addESP(target)
    if espListData[target] or target == player then return false end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(0, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.Parent = target.Character
    local nametag = nil
    if target.Character then
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
    if data then
        if data.highlight then data.highlight:Destroy() end
        if data.nametag then data.nametag:Destroy() end
        if data.added then data.added:Disconnect() end
        if data.removing then data.removing:Disconnect() end
        espListData[target] = nil
    end
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
        btn.Size = UDim2.new(1, -10, 0, 25)
        btn.Position = UDim2.new(0, 5, 0, y)
        btn.Text = plr.Name
        btn.BackgroundColor3 = Color3.fromRGB(40, 50, 40)
        btn.TextColor3 = Color3.fromRGB(150, 200, 150)
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = espListBox
        btn.MouseButton1Click:Connect(function()
            removeESP(plr)
            playSound()
            local count = 0 for _ in pairs(espListData) do count = count + 1 end
            espStatusLabel.Text = count > 0 and "Активно: " .. count or "Нет активных"
        end)
        setupHover(btn)
        y = y + 30
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
            btn.Size = UDim2.new(1, -10, 0, 25)
            btn.Position = UDim2.new(0, 5, 0, y)
            btn.Text = plr.Name
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            btn.TextColor3 = Color3.fromRGB(220, 220, 230)
            btn.TextSize = 12
            btn.Font = Enum.Font.GothamBold
            btn.BorderSizePixel = 0
            btn.Parent = playersListBox
            btn.MouseButton1Click:Connect(function()
                espInput.Text = plr.Name
            end)
            setupHover(btn)
            y = y + 30
        end
    end
    playersListBox.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

function setupHover(btn)
    local orig = btn.BackgroundColor3
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(70, 70, 90) end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = orig end)
end

-- === ОСНОВНОЕ ОКНО ===
frame.Size = UDim2.new(0, menuWidth, 0, menuHeight)
frame.Position = UDim2.new(0.5, -menuWidth/2, 0.5, -menuHeight/2)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
frame.BackgroundTransparency = 1 - (menuTransparency / 100)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
title.Text = "GOXIE SCRIPT"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Center
title.Parent = frame

closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
closeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function() frame.Visible = false end)
setupHover(closeBtn)

fpsLabel.Size = UDim2.new(0, 140, 0, 40)
fpsLabel.Position = UDim2.new(0.5, -70, 0, 0)
fpsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
fpsLabel.BackgroundTransparency = 0.5
fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsLabel.TextSize = 20
fpsLabel.Font = Enum.Font.GothamBold
fpsLabel.TextXAlignment = Enum.TextXAlignment.Center
fpsLabel.BorderSizePixel = 2
fpsLabel.BorderColor3 = Color3.fromRGB(70, 70, 85)
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

tabsFrame.Size = UDim2.new(1, 0, 0, 35)
tabsFrame.Position = UDim2.new(0, 0, 0, 40)
tabsFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
tabsFrame.Parent = frame

local tabs = {tabFOV, tabResolution, tabESP, tabMisc, tabSettings}
local tabNames = {"FOV", "RES", "ESP", "MISC", "SET"}
local tabContents = {}

for i, tab in ipairs(tabs) do
    tab.Size = UDim2.new(0.2, 0, 1, 0)
    tab.Position = UDim2.new((i-1) * 0.2, 0, 0, 0)
    tab.Text = tabNames[i]
    tab.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    tab.TextColor3 = Color3.fromRGB(180, 180, 190)
    tab.TextSize = 13
    tab.Font = Enum.Font.GothamBold
    tab.BorderSizePixel = 0
    tab.Parent = tabsFrame
    tab.MouseButton1Click:Connect(function()
        for j, t in ipairs(tabs) do
            t.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
            t.TextColor3 = Color3.fromRGB(180, 180, 190)
            if tabContents[j] then tabContents[j].Visible = false end
        end
        tab.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        tab.TextColor3 = Color3.fromRGB(255, 255, 255)
        if tabContents[i] then tabContents[i].Visible = true end
    end)
    setupHover(tab)
end

contentContainer.Size = UDim2.new(1, -20, 1, -85)
contentContainer.Position = UDim2.new(0, 10, 0, 80)
contentContainer.BackgroundTransparency = 1
contentContainer.ScrollBarThickness = 4
contentContainer.Parent = frame

-- === FOV ===
local fovContent = Instance.new("Frame")
fovContent.Size = UDim2.new(1, 0, 0, 140)
fovContent.BackgroundTransparency = 1
fovContent.Parent = contentContainer
table.insert(tabContents, fovContent)

local fovTitle = Instance.new("TextLabel")
fovTitle.Size = UDim2.new(1, 0, 0, 30)
fovTitle.BackgroundTransparency = 1
fovTitle.Text = "FOV LOCK"
fovTitle.TextColor3 = Color3.fromRGB(220, 220, 230)
fovTitle.TextSize = 18
fovTitle.Font = Enum.Font.GothamBold
fovTitle.Parent = fovContent

fovToggleBtn.Size = UDim2.new(1, 0, 0, 35)
fovToggleBtn.Position = UDim2.new(0, 0, 0, 35)
fovToggleBtn.Text = "ВЫКЛ"
fovToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
fovToggleBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
fovToggleBtn.TextSize = 14
fovToggleBtn.Font = Enum.Font.GothamBold
fovToggleBtn.Parent = fovContent
setupHover(fovToggleBtn)

local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(0.5, 0, 0, 25)
fovLabel.Position = UDim2.new(0, 0, 0, 78)
fovLabel.BackgroundTransparency = 1
fovLabel.Text = "FOV (80-140):"
fovLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
fovLabel.TextSize = 13
fovLabel.Font = Enum.Font.GothamBold
fovLabel.Parent = fovContent

fovInputBox.Size = UDim2.new(0.3, 0, 0, 32)
fovInputBox.Position = UDim2.new(0.55, 0, 0, 75)
fovInputBox.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
fovInputBox.TextColor3 = Color3.fromRGB(230, 230, 240)
fovInputBox.TextSize = 14
fovInputBox.Font = Enum.Font.GothamBold
fovInputBox.Text = "85"
fovInputBox.Parent = fovContent

fovStatus.Size = UDim2.new(1, 0, 0, 25)
fovStatus.Position = UDim2.new(0, 0, 0, 115)
fovStatus.BackgroundTransparency = 1
fovStatus.Text = "OFF"
fovStatus.TextColor3 = Color3.fromRGB(160, 160, 170)
fovStatus.TextSize = 13
fovStatus.Font = Enum.Font.GothamBold
fovStatus.Parent = fovContent

local fovActive = false
local fovConn = nil
local currentFOV = 85

fovInputBox.FocusLost:Connect(function()
    local v = tonumber(fovInputBox.Text)
    if v and v >= 80 and v <= 140 then
        currentFOV = v
        if fovActive then camera.FieldOfView = currentFOV end
    else
        fovInputBox.Text = tostring(currentFOV)
    end
end)

fovToggleBtn.MouseButton1Click:Connect(function()
    if fovActive then
        if fovConn then fovConn:Disconnect() end
        fovConn = nil
        camera.FieldOfView = 70
        fovActive = false
        fovStatus.Text = "OFF"
        fovToggleBtn.Text = "ВЫКЛ"
        playSound()
    else
        fovConn = camera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
            if camera.FieldOfView ~= currentFOV then
                camera.FieldOfView = currentFOV
            end
        end)
        camera.FieldOfView = currentFOV
        fovActive = true
        fovStatus.Text = "ON (" .. currentFOV .. ")"
        fovStatus.TextColor3 = Color3.fromRGB(180, 220, 180)
        fovToggleBtn.Text = "ВКЛ"
        playSound()
    end
end)

-- === RESOLUTION ===
local resContent = Instance.new("Frame")
resContent.Size = UDim2.new(1, 0, 0, 110)
resContent.BackgroundTransparency = 1
resContent.Parent = contentContainer
resContent.Visible = false
table.insert(tabContents, resContent)

local resTitle = Instance.new("TextLabel")
resTitle.Size = UDim2.new(1, 0, 0, 30)
resTitle.BackgroundTransparency = 1
resTitle.Text = "RESOLUTION MOD"
resTitle.TextColor3 = Color3.fromRGB(220, 220, 230)
resTitle.TextSize = 18
resTitle.Font = Enum.Font.GothamBold
resTitle.Parent = resContent

resToggleBtn.Size = UDim2.new(1, 0, 0, 35)
resToggleBtn.Position = UDim2.new(0, 0, 0, 35)
resToggleBtn.Text = "ВЫКЛ"
resToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
resToggleBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
resToggleBtn.TextSize = 14
resToggleBtn.Font = Enum.Font.GothamBold
resToggleBtn.Parent = resContent
setupHover(resToggleBtn)

resStatus.Size = UDim2.new(1, 0, 0, 25)
resStatus.Position = UDim2.new(0, 0, 0, 80)
resStatus.BackgroundTransparency = 1
resStatus.Text = "OFF"
resStatus.TextColor3 = Color3.fromRGB(160, 160, 170)
resStatus.TextSize = 13
resStatus.Font = Enum.Font.GothamBold
resStatus.Parent = resContent

local resActive = false
local resConn = nil

resToggleBtn.MouseButton1Click:Connect(function()
    if resActive then
        if resConn then resConn:Disconnect() end
        resConn = nil
        resActive = false
        resStatus.Text = "OFF"
        resToggleBtn.Text = "ВЫКЛ"
        playSound()
    else
        resConn = RunService.RenderStepped:Connect(function()
            camera.CFrame = camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, 0.80, 0, 0, 0, 1)
        end)
        resActive = true
        resStatus.Text = "ON"
        resStatus.TextColor3 = Color3.fromRGB(180, 220, 180)
        resToggleBtn.Text = "ВКЛ"
        playSound()
    end
end)

-- === ESP ===
local espContent = Instance.new("Frame")
espContent.Size = UDim2.new(1, 0, 0, 340)
espContent.BackgroundTransparency = 1
espContent.Parent = contentContainer
espContent.Visible = false
table.insert(tabContents, espContent)

local espTitle = Instance.new("TextLabel")
espTitle.Size = UDim2.new(1, 0, 0, 30)
espTitle.BackgroundTransparency = 1
espTitle.Text = "ESP"
espTitle.TextColor3 = Color3.fromRGB(220, 220, 230)
espTitle.TextSize = 18
espTitle.Font = Enum.Font.GothamBold
espTitle.Parent = espContent

espInput.Size = UDim2.new(1, 0, 0, 32)
espInput.Position = UDim2.new(0, 0, 0, 35)
espInput.PlaceholderText = "Имя игрока"
espInput.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
espInput.TextColor3 = Color3.fromRGB(230, 230, 240)
espInput.TextSize = 14
espInput.Font = Enum.Font.GothamBold
espInput.Parent = espContent

espRefreshBtn.Size = UDim2.new(0.32, 0, 0, 32)
espRefreshBtn.Position = UDim2.new(0, 0, 0, 75)
espRefreshBtn.Text = "ОБНОВИТЬ"
espRefreshBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
espRefreshBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
espRefreshBtn.TextSize = 12
espRefreshBtn.Font = Enum.Font.GothamBold
espRefreshBtn.Parent = espContent
setupHover(espRefreshBtn)

espAddBtn.Size = UDim2.new(0.32, 0, 0, 32)
espAddBtn.Position = UDim2.new(0.34, 0, 0, 75)
espAddBtn.Text = "ДОБАВИТЬ"
espAddBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
espAddBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
espAddBtn.TextSize = 12
espAddBtn.Font = Enum.Font.GothamBold
espAddBtn.Parent = espContent
setupHover(espAddBtn)

espRemoveAllBtn.Size = UDim2.new(0.32, 0, 0, 32)
espRemoveAllBtn.Position = UDim2.new(0.68, 0, 0, 75)
espRemoveAllBtn.Text = "ОЧИСТИТЬ ВСЕХ"
espRemoveAllBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
espRemoveAllBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
espRemoveAllBtn.TextSize = 12
espRemoveAllBtn.Font = Enum.Font.GothamBold
espRemoveAllBtn.Parent = espContent
setupHover(espRemoveAllBtn)

local playersLabel = Instance.new("TextLabel")
playersLabel.Size = UDim2.new(0.48, 0, 0, 20)
playersLabel.Position = UDim2.new(0, 0, 0, 115)
playersLabel.BackgroundTransparency = 1
playersLabel.Text = "ИГРОКИ"
playersLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
playersLabel.TextSize = 12
playersLabel.Font = Enum.Font.GothamBold
playersLabel.Parent = espContent

playersListBox.Size = UDim2.new(0.48, 0, 0, 100)
playersListBox.Position = UDim2.new(0, 0, 0, 135)
playersListBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
playersListBox.ScrollBarThickness = 3
playersListBox.Parent = espContent

local espLabel = Instance.new("TextLabel")
espLabel.Size = UDim2.new(0.48, 0, 0, 20)
espLabel.Position = UDim2.new(0.52, 0, 0, 115)
espLabel.BackgroundTransparency = 1
espLabel.Text = "ESP АКТИВЕН"
espLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
espLabel.TextSize = 12
espLabel.Font = Enum.Font.GothamBold
espLabel.Parent = espContent

espListBox.Size = UDim2.new(0.48, 0, 0, 100)
espListBox.Position = UDim2.new(0.52, 0, 0, 135)
espListBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
espListBox.ScrollBarThickness = 3
espListBox.Parent = espContent

espStatusLabel.Size = UDim2.new(1, 0, 0, 22)
espStatusLabel.Position = UDim2.new(0, 0, 0, 245)
espStatusLabel.BackgroundTransparency = 1
espStatusLabel.Text = "Нет активных"
espStatusLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
espStatusLabel.TextSize = 12
espStatusLabel.Font = Enum.Font.GothamBold
espStatusLabel.Parent = espContent

espRefreshBtn.MouseButton1Click:Connect(function()
    updatePlayersList()
    playSound()
end)

espAddBtn.MouseButton1Click:Connect(function()
    local name = espInput.Text
    if name == "" then return end
    local target = game.Players:FindFirstChild(name)
    if not target then return end
    if addESP(target) then
        local count = 0 for _ in pairs(espListData) do count = count + 1 end
        espStatusLabel.Text = "Активно: " .. count
        playSound()
    end
    espInput.Text = ""
end)

espRemoveAllBtn.MouseButton1Click:Connect(function()
    removeAllESP()
    espStatusLabel.Text = "Нет активных"
    playSound()
end)

-- === MISC ===
local miscContent = Instance.new("Frame")
miscContent.Size = UDim2.new(1, 0, 0, 100)
miscContent.BackgroundTransparency = 1
miscContent.Parent = contentContainer
miscContent.Visible = false
table.insert(tabContents, miscContent)

local miscTitle = Instance.new("TextLabel")
miscTitle.Size = UDim2.new(1, 0, 0, 30)
miscTitle.BackgroundTransparency = 1
miscTitle.Text = "ТЕЛЕПОРТ"
miscTitle.TextColor3 = Color3.fromRGB(220, 220, 230)
miscTitle.TextSize = 18
miscTitle.Font = Enum.Font.GothamBold
miscTitle.Parent = miscContent

teleportBtn.Size = UDim2.new(1, 0, 0, 38)
teleportBtn.Position = UDim2.new(0, 0, 0, 35)
teleportBtn.Text = "ТЕЛЕПОРТ (КЛИК)   |   КЛАВИША: Z"
teleportBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
teleportBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
teleportBtn.TextSize = 14
teleportBtn.Font = Enum.Font.GothamBold
teleportBtn.Parent = miscContent
setupHover(teleportBtn)

teleportBtn.MouseButton1Click:Connect(function() teleport() end)

-- === SETTINGS ===
local settingsContent = Instance.new("Frame")
settingsContent.Size = UDim2.new(1, 0, 0, 170)
settingsContent.BackgroundTransparency = 1
settingsContent.Parent = contentContainer
settingsContent.Visible = false
table.insert(tabContents, settingsContent)

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1, 0, 0, 30)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Text = "НАСТРОЙКИ"
settingsTitle.TextColor3 = Color3.fromRGB(220, 220, 230)
settingsTitle.TextSize = 18
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.Parent = settingsContent

local bindLabel = Instance.new("TextLabel")
bindLabel.Size = UDim2.new(0.5, 0, 0, 25)
bindLabel.Position = UDim2.new(0, 0, 0, 40)
bindLabel.BackgroundTransparency = 1
bindLabel.Text = "КЛАВИША МЕНЮ"
bindLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
bindLabel.TextSize = 13
bindLabel.Font = Enum.Font.GothamBold
bindLabel.Parent = settingsContent

menuBindBtn.Size = UDim2.new(0.3, 0, 0, 32)
menuBindBtn.Position = UDim2.new(0.5, 0, 0, 37)
menuBindBtn.Text = currentBind.Name
menuBindBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
menuBindBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
menuBindBtn.TextSize = 14
menuBindBtn.Font = Enum.Font.GothamBold
menuBindBtn.Parent = settingsContent
setupHover(menuBindBtn)

menuBindStatus.Size = UDim2.new(1, 0, 0, 22)
menuBindStatus.Position = UDim2.new(0, 0, 0, 78)
menuBindStatus.BackgroundTransparency = 1
menuBindStatus.Text = "Нажми для смены"
menuBindStatus.TextColor3 = Color3.fromRGB(160, 160, 170)
menuBindStatus.TextSize = 12
menuBindStatus.Font = Enum.Font.GothamBold
menuBindStatus.Parent = settingsContent

menuBindBtn.MouseButton1Click:Connect(function()
    if waitingForBind then
        waitingForBind = false
        menuBindBtn.Text = currentBind.Name
        menuBindStatus.Text = "Нажми для смены"
    else
        waitingForBind = true
        menuBindBtn.Text = "..."
        menuBindStatus.Text = "Ожидание клавиши..."
    end
end)

local transLabel = Instance.new("TextLabel")
transLabel.Size = UDim2.new(0.5, 0, 0, 25)
transLabel.Position = UDim2.new(0, 0, 0, 115)
transLabel.BackgroundTransparency = 1
transLabel.Text = "ПРОЗРАЧНОСТЬ (%)"
transLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
transLabel.TextSize = 13
transLabel.Font = Enum.Font.GothamBold
transLabel.Parent = settingsContent

transparencyInput.Size = UDim2.new(0.3, 0, 0, 32)
transparencyInput.Position = UDim2.new(0.55, 0, 0, 112)
transparencyInput.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
transparencyInput.TextColor3 = Color3.fromRGB(230, 230, 240)
transparencyInput.TextSize = 14
transparencyInput.Font = Enum.Font.GothamBold
transparencyInput.Text = tostring(menuTransparency)
transparencyInput.Parent = settingsContent

transparencyInput.FocusLost:Connect(function()
    local v = tonumber(transparencyInput.Text)
    if v and v >= 0 and v <= 100 then
        menuTransparency = v
        updateMenu()
    else
        transparencyInput.Text = tostring(menuTransparency)
    end
end)

-- УВЕДОМЛЕНИЯ
local notifContainer = Instance.new("Frame")
notifContainer.Size = UDim2.new(0, 300, 0, 150)
notifContainer.Position = UDim2.new(1, -310, 0, 10)
notifContainer.BackgroundTransparency = 1
notifContainer.Parent = gui

function showNotification(msg)
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, -10, 0, 30)
    notif.Position = UDim2.new(0, 5, 0, 0)
    notif.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    notif.BackgroundTransparency = 0.15
    notif.Parent = notifContainer
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = msg
    text.TextColor3 = Color3.fromRGB(255, 200, 100)
    text.TextSize = 13
    text.Font = Enum.Font.GothamBold
    text.Parent = notif
    notif.Position = UDim2.new(0, 5, 0, -40)
    for i = 1, 4 do
        notif.Position = UDim2.new(0, 5, 0, notif.Position.Y.Offset + 10)
        wait(0.02)
    end
    local y = 0
    for _, child in ipairs(notifContainer:GetChildren()) do
        if child:IsA("Frame") and child ~= notif then
            child.Position = UDim2.new(0, 5, 0, y)
            y = y + 35
        end
    end
    notif.Position = UDim2.new(0, 5, 0, y)
    wait(2)
    for i = 1, 4 do
        notif.BackgroundTransparency = notif.BackgroundTransparency + 0.2
        wait(0.02)
    end
    notif:Destroy()
    local y2 = 0
    for _, child in ipairs(notifContainer:GetChildren()) do
        if child:IsA("Frame") then
            child.Position = UDim2.new(0, 5, 0, y2)
            y2 = y2 + 35
        end
    end
end

tabFOV.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
tabFOV.TextColor3 = Color3.fromRGB(255, 255, 255)

local function updateCanvasSize()
    local h = 0
    for _, child in ipairs(contentContainer:GetChildren()) do
        if child:IsA("Frame") then
            h = h + child.Size.Y.Offset + 10
        end
    end
    contentContainer.CanvasSize = UDim2.new(0, 0, 0, h + 20)
end
contentContainer:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCanvasSize)
updateCanvasSize()

game.Players.PlayerRemoving:Connect(function(leaving)
    if espListData[leaving] then
        removeESP(leaving)
        local count = 0 for _ in pairs(espListData) do count = count + 1 end
        espStatusLabel.Text = count > 0 and "Активно: " .. count or "Нет активных"
    end
end)

updatePlayersList()
updateESPDisplay()
updateMenu()

print("GOXIE SCRIPT loaded | Press " .. currentBind.Name .. " to open menu")
