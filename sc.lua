--[[ script.lua - ESP + TP + FPS/ms + FOV（シンプル版・ドラッグ対応） ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")

local plr = Players.LocalPlayer
local cam = workspace.CurrentCamera
local PlayerGui = plr:WaitForChild("PlayerGui")

------------------------------------------------------------
-- GUI親
------------------------------------------------------------
local function getGuiParent()
    local ok = pcall(function()
        local test = Instance.new("ScreenGui")
        test.Parent = CoreGui
        test:Destroy()
    end)
    if ok then return CoreGui end
    return PlayerGui
end
local guiParent = getGuiParent()

------------------------------------------------------------
-- カラー
------------------------------------------------------------
local C_CYAN   = Color3.fromRGB(0, 255, 255)
local C_PINK   = Color3.fromRGB(255, 0, 200)
local C_PURPLE = Color3.fromRGB(160, 60, 255)
local C_GREEN  = Color3.fromRGB(0, 255, 130)
local C_RED    = Color3.fromRGB(255, 40, 80)
local C_YELLOW = Color3.fromRGB(255, 220, 60)
local C_PANEL  = Color3.fromRGB(8, 8, 20)

------------------------------------------------------------
-- 状態
------------------------------------------------------------
local selectedPlayers = {}
local playerButtons = {}
local espData = {}

local fpsValue = 60
local msValue = 16.7
local fpsTimer = 0
local frameCount = 0

local defaultFOV = cam.FieldOfView
local currentFOV = defaultFOV

------------------------------------------------------------
-- ヘルパー：四隅ブラケット
------------------------------------------------------------
local function addCorners(parent, color, size, zindex)
    size = size or 8
    color = color or C_CYAN
    zindex = zindex or 11
    local positions = {
        {0, 0, 1, 1}, {1, 0, -1, 1}, {0, 1, 1, -1}, {1, 1, -1, -1},
    }
    for _, pos in ipairs(positions) do
        local h = Instance.new("Frame")
        h.Size = UDim2.new(0, size, 0, 2)
        h.Position = UDim2.new(pos[1], pos[3] == 1 and 0 or -size, pos[2], pos[4] == 1 and 0 or -2)
        h.BackgroundColor3 = color
        h.BorderSizePixel = 0
        h.ZIndex = zindex
        h.Parent = parent

        local v = Instance.new("Frame")
        v.Size = UDim2.new(0, 2, 0, size)
        v.Position = UDim2.new(pos[1], pos[3] == 1 and 0 or -2, pos[2], pos[4] == 1 and 0 or -size)
        v.BackgroundColor3 = color
        v.BorderSizePixel = 0
        v.ZIndex = zindex
        v.Parent = parent
    end
end

-- タッチ・マウス両対応クリック
local function bindClick(btn, callback)
    local lastClick = 0
    local function tryClick()
        local now = tick()
        if now - lastClick < 0.2 then return end
        lastClick = now
        callback()
    end
    btn.MouseButton1Click:Connect(tryClick)
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            tryClick()
        end
    end)
end

-- ★ ドラッグ可能にする関数
local function makeDraggable(frame, dragBar)
    dragBar = dragBar or frame

    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

------------------------------------------------------------
-- FPS計算
------------------------------------------------------------
RunService.RenderStepped:Connect(function(dt)
    frameCount = frameCount + 1
    fpsTimer = fpsTimer + dt
    if fpsTimer >= 0.5 then
        fpsValue = math.floor(frameCount / fpsTimer)
        msValue = (fpsTimer / frameCount) * 1000
        frameCount = 0
        fpsTimer = 0
    end
end)

------------------------------------------------------------
-- GUI
------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "ScriptGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = guiParent

------------------------------------------------------------
-- PERFORMANCE パネル（右上・ドラッグ可能）
------------------------------------------------------------
local infoPanel = Instance.new("Frame")
infoPanel.Name = "PerformancePanel"
infoPanel.Size = UDim2.new(0, 170, 0, 76)
infoPanel.Position = UDim2.new(1, -186, 0, 16)
infoPanel.BackgroundColor3 = Color3.fromRGB(5, 10, 20)
infoPanel.BackgroundTransparency = 0.3
infoPanel.BorderSizePixel = 0
infoPanel.ZIndex = 10
infoPanel.Parent = gui
Instance.new("UICorner", infoPanel).CornerRadius = UDim.new(0, 3)

local infoStroke = Instance.new("UIStroke")
infoStroke.Thickness = 1
infoStroke.Color = C_CYAN
infoStroke.Transparency = 0.3
infoStroke.Parent = infoPanel

addCorners(infoPanel, C_CYAN, 6)

local infoHeader = Instance.new("TextLabel")
infoHeader.Size = UDim2.new(1, -8, 0, 14)
infoHeader.Position = UDim2.new(0, 6, 0, 2)
infoHeader.BackgroundTransparency = 1
infoHeader.Text = "▸ PERFORMANCE"
infoHeader.TextColor3 = C_CYAN
infoHeader.TextSize = 9
infoHeader.Font = Enum.Font.Code
infoHeader.TextXAlignment = Enum.TextXAlignment.Left
infoHeader.ZIndex = 12
infoHeader.Parent = infoPanel

local infoData = Instance.new("TextLabel")
infoData.Size = UDim2.new(1, -8, 1, -20)
infoData.Position = UDim2.new(0, 6, 0, 18)
infoData.BackgroundTransparency = 1
infoData.TextColor3 = C_GREEN
infoData.TextSize = 10
infoData.Font = Enum.Font.Code
infoData.TextXAlignment = Enum.TextXAlignment.Left
infoData.TextYAlignment = Enum.TextYAlignment.Top
infoData.ZIndex = 12
infoData.Parent = infoPanel

makeDraggable(infoPanel, infoHeader)

task.spawn(function()
    while gui.Parent do
        local t = tick()
        local hr = math.floor((t / 3600) % 24)
        local mn = math.floor((t / 60) % 60)
        local sc = math.floor(t % 60)
        infoData.Text = string.format(
            "FPS: %d | MS: %.1f\nSES: 0x%X\nT+%02d:%02d:%02d",
            fpsValue, msValue,
            math.floor(t * 100) % 0xFFFF,
            hr, mn, sc
        )
        if fpsValue < 30 then
            infoData.TextColor3 = C_RED
        elseif fpsValue < 50 then
            infoData.TextColor3 = C_YELLOW
        else
            infoData.TextColor3 = C_GREEN
        end
        task.wait(0.2)
    end
end)

------------------------------------------------------------
-- FOV パネル（ドラッグ可能）
------------------------------------------------------------
local fovPanel = Instance.new("Frame")
fovPanel.Name = "FovPanel"
fovPanel.Size = UDim2.new(0, 170, 0, 60)
fovPanel.Position = UDim2.new(1, -186, 0, 100)
fovPanel.BackgroundColor3 = Color3.fromRGB(5, 10, 20)
fovPanel.BackgroundTransparency = 0.3
fovPanel.BorderSizePixel = 0
fovPanel.ZIndex = 10
fovPanel.Parent = gui
Instance.new("UICorner", fovPanel).CornerRadius = UDim.new(0, 3)

local fovStroke = Instance.new("UIStroke")
fovStroke.Thickness = 1
fovStroke.Color = C_PURPLE
fovStroke.Transparency = 0.3
fovStroke.Parent = fovPanel

addCorners(fovPanel, C_PURPLE, 6)

local fovHeader = Instance.new("TextLabel")
fovHeader.Size = UDim2.new(1, -8, 0, 14)
fovHeader.Position = UDim2.new(0, 6, 0, 2)
fovHeader.BackgroundTransparency = 1
fovHeader.Text = "▸ FOV CONTROL"
fovHeader.TextColor3 = C_PURPLE
fovHeader.TextSize = 9
fovHeader.Font = Enum.Font.Code
fovHeader.TextXAlignment = Enum.TextXAlignment.Left
fovHeader.ZIndex = 12
fovHeader.Parent = fovPanel

makeDraggable(fovPanel, fovHeader)

local fovValueLbl = Instance.new("TextLabel")
fovValueLbl.Size = UDim2.new(1, -8, 0, 16)
fovValueLbl.Position = UDim2.new(0, 6, 0, 18)
fovValueLbl.BackgroundTransparency = 1
fovValueLbl.Text = "FOV: " .. math.floor(currentFOV)
fovValueLbl.TextColor3 = C_CYAN
fovValueLbl.TextSize = 12
fovValueLbl.Font = Enum.Font.Code
fovValueLbl.TextXAlignment = Enum.TextXAlignment.Left
fovValueLbl.ZIndex = 12
fovValueLbl.Parent = fovPanel

local minusBtn = Instance.new("TextButton")
minusBtn.Size = UDim2.new(0, 28, 0, 20)
minusBtn.Position = UDim2.new(0, 6, 0, 36)
minusBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
minusBtn.BackgroundTransparency = 0.2
minusBtn.Text = "−"
minusBtn.TextColor3 = C_CYAN
minusBtn.TextSize = 16
minusBtn.Font = Enum.Font.Code
minusBtn.BorderSizePixel = 0
minusBtn.ZIndex = 12
minusBtn.Parent = fovPanel
Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 2)

local minusStroke = Instance.new("UIStroke")
minusStroke.Thickness = 1
minusStroke.Color = C_CYAN
minusStroke.Transparency = 0.4
minusStroke.Parent = minusBtn

local plusBtn = Instance.new("TextButton")
plusBtn.Size = UDim2.new(0, 28, 0, 20)
plusBtn.Position = UDim2.new(0, 38, 0, 36)
plusBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
plusBtn.BackgroundTransparency = 0.2
plusBtn.Text = "+"
plusBtn.TextColor3 = C_CYAN
plusBtn.TextSize = 16
plusBtn.Font = Enum.Font.Code
plusBtn.BorderSizePixel = 0
plusBtn.ZIndex = 12
plusBtn.Parent = fovPanel
Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 2)

local plusStroke = Instance.new("UIStroke")
plusStroke.Thickness = 1
plusStroke.Color = C_CYAN
plusStroke.Transparency = 0.4
plusStroke.Parent = plusBtn

local resetFovBtn = Instance.new("TextButton")
resetFovBtn.Size = UDim2.new(0, 56, 0, 20)
resetFovBtn.Position = UDim2.new(0, 70, 0, 36)
resetFovBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 40)
resetFovBtn.BackgroundTransparency = 0.2
resetFovBtn.Text = "RESET"
resetFovBtn.TextColor3 = C_PINK
resetFovBtn.TextSize = 9
resetFovBtn.Font = Enum.Font.Code
resetFovBtn.BorderSizePixel = 0
resetFovBtn.ZIndex = 12
resetFovBtn.Parent = fovPanel
Instance.new("UICorner", resetFovBtn).CornerRadius = UDim.new(0, 2)

local resetStroke = Instance.new("UIStroke")
resetStroke.Thickness = 1
resetStroke.Color = C_PINK
resetStroke.Transparency = 0.4
resetStroke.Parent = resetFovBtn

local function updateFOV(newFOV)
    newFOV = math.clamp(newFOV, 30, 120)
    currentFOV = newFOV
    cam.FieldOfView = newFOV
    fovValueLbl.Text = "FOV: " .. math.floor(newFOV)
end

bindClick(minusBtn, function() updateFOV(currentFOV - 5) end)
bindClick(plusBtn, function() updateFOV(currentFOV + 5) end)
bindClick(resetFovBtn, function() updateFOV(defaultFOV) end)

------------------------------------------------------------
-- プレイヤー選択GUI（ドラッグ可能）
------------------------------------------------------------
local selectGui = Instance.new("ScreenGui")
selectGui.Name = "PlayerSelectGui"
selectGui.ResetOnSpawn = false
selectGui.IgnoreGuiInset = true
selectGui.DisplayOrder = 600
selectGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
selectGui.Parent = guiParent

local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 150, 0, 220)
panel.Position = UDim2.new(0, 12, 0.5, -110)
panel.BackgroundColor3 = Color3.fromRGB(5, 10, 20)
panel.BackgroundTransparency = 0.2
panel.BorderSizePixel = 0
panel.ZIndex = 10
panel.Parent = selectGui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 3)

local panelStroke = Instance.new("UIStroke")
panelStroke.Thickness = 1
panelStroke.Color = C_CYAN
panelStroke.Transparency = 0.3
panelStroke.Parent = panel

addCorners(panel, C_CYAN, 8)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 18)
header.BackgroundColor3 = C_CYAN
header.BackgroundTransparency = 0.85
header.BorderSizePixel = 0
header.ZIndex = 11
header.Parent = panel

local headerLbl = Instance.new("TextLabel")
headerLbl.Size = UDim2.new(1, -8, 1, 0)
headerLbl.Position = UDim2.new(0, 6, 0, 0)
headerLbl.BackgroundTransparency = 1
headerLbl.Text = "▸ TARGETS"
headerLbl.TextColor3 = C_CYAN
headerLbl.TextSize = 10
headerLbl.Font = Enum.Font.Code
headerLbl.TextXAlignment = Enum.TextXAlignment.Left
headerLbl.ZIndex = 12
headerLbl.Parent = header

-- ★ ドラッグ可能
makeDraggable(panel, header)

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -8, 1, -24)
scrollFrame.Position = UDim2.new(0, 4, 0, 22)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 3
scrollFrame.ScrollBarImageColor3 = C_CYAN
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ZIndex = 11
scrollFrame.Parent = panel

local scrollLayout = Instance.new("UIListLayout")
scrollLayout.Padding = UDim.new(0, 2)
scrollLayout.SortOrder = Enum.SortOrder.Name
scrollLayout.Parent = scrollFrame

scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, scrollLayout.AbsoluteContentSize.Y + 6)
end)

------------------------------------------------------------
-- TP機能
------------------------------------------------------------
local function teleportToPlayer(targetPlayer)
    local myChar = plr.Character
    if not myChar then return end
    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end

    local targetChar = targetPlayer.Character
    if not targetChar then return end
    local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetHrp then return end

    local offset = -targetHrp.CFrame.LookVector * 3
    myHrp.CFrame = targetHrp.CFrame + offset + Vector3.new(0, 1, 0)
end

------------------------------------------------------------
-- プレイヤーボタン作成
------------------------------------------------------------
local function makePlayerButton(targetPlayer)
    if targetPlayer == plr then return end
    if playerButtons[targetPlayer] then return end

    local btn = Instance.new("Frame")
    btn.Name = "PlayerBtn_" .. targetPlayer.Name
    btn.Size = UDim2.new(1, -4, 0, 22)
    btn.BackgroundColor3 = Color3.fromRGB(15, 20, 35)
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    btn.ZIndex = 11
    btn.Parent = scrollFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 2)

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = C_CYAN
    stroke.Transparency = 0.5
    stroke.Parent = btn

    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0, 5, 0, 5)
    statusDot.Position = UDim2.new(0, 6, 0.5, -2.5)
    statusDot.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    statusDot.BorderSizePixel = 0
    statusDot.ZIndex = 12
    statusDot.Parent = btn
    Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -50, 1, 0)
    nameLbl.Position = UDim2.new(0, 16, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = string.upper(targetPlayer.DisplayName)
    nameLbl.TextColor3 = C_CYAN
    nameLbl.TextSize = 10
    nameLbl.Font = Enum.Font.Code
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    nameLbl.ZIndex = 12
    nameLbl.Parent = btn

    -- TPボタン
    local tpBtn = Instance.new("TextButton")
    tpBtn.Size = UDim2.new(0, 26, 0, 18)
    tpBtn.Position = UDim2.new(1, -30, 0.5, -9)
    tpBtn.BackgroundColor3 = Color3.fromRGB(30, 50, 80)
    tpBtn.BackgroundTransparency = 0.2
    tpBtn.Text = "TP"
    tpBtn.TextColor3 = C_CYAN
    tpBtn.TextSize = 10
    tpBtn.Font = Enum.Font.Code
    tpBtn.BorderSizePixel = 0
    tpBtn.ZIndex = 14
    tpBtn.Parent = btn
    Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 2)

    local tpStroke = Instance.new("UIStroke")
    tpStroke.Thickness = 1
    tpStroke.Color = C_CYAN
    tpStroke.Transparency = 0.4
    tpStroke.Parent = tpBtn

    bindClick(tpBtn, function()
        teleportToPlayer(targetPlayer)
        tpBtn.TextColor3 = C_GREEN
        tpStroke.Color = C_GREEN
        task.wait(0.3)
        if tpBtn and tpBtn.Parent then
            tpBtn.TextColor3 = C_CYAN
            tpStroke.Color = C_CYAN
        end
    end)

    -- ESP選択ボタン
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, -30, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 13
    clickBtn.Parent = btn

    bindClick(clickBtn, function()
        selectedPlayers[targetPlayer] = not selectedPlayers[targetPlayer]

        if selectedPlayers[targetPlayer] then
            statusDot.BackgroundColor3 = C_GREEN
            stroke.Color = C_GREEN
            stroke.Transparency = 0.1
            nameLbl.TextColor3 = C_GREEN
            btn.BackgroundColor3 = Color3.fromRGB(0, 30, 20)
        else
            statusDot.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            stroke.Color = C_CYAN
            stroke.Transparency = 0.5
            nameLbl.TextColor3 = C_CYAN
            btn.BackgroundColor3 = Color3.fromRGB(15, 20, 35)
        end
    end)

    playerButtons[targetPlayer] = {
        btn = btn, statusDot = statusDot, stroke = stroke, nameLbl = nameLbl,
    }
end

local function removePlayerButton(targetPlayer)
    if playerButtons[targetPlayer] then
        local b = playerButtons[targetPlayer]
        if b.btn and b.btn.Parent then b.btn:Destroy() end
        playerButtons[targetPlayer] = nil
    end
end

------------------------------------------------------------
-- ESP
------------------------------------------------------------
local function createESP(targetPlayer)
    if targetPlayer == plr then return end
    if espData[targetPlayer] then return end

    local char = targetPlayer.Character
    if not char then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ScriptESP"
    highlight.FillColor = C_CYAN
    highlight.OutlineColor = Color3.fromRGB(0, 200, 255)
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = char
    highlight.Enabled = false
    highlight.Parent = char

    local head = char:FindFirstChild("Head")
    local bb
    if head then
        bb = Instance.new("BillboardGui")
        bb.Name = "ScriptESPBillboard"
        bb.Size = UDim2.new(0, 220, 0, 60)
        bb.StudsOffset = Vector3.new(0, 3.5, 0)
        bb.AlwaysOnTop = true
        bb.MaxDistance = math.huge
        bb.Enabled = false
        bb.Parent = head

        local panel2 = Instance.new("Frame")
        panel2.Size = UDim2.new(1, 0, 1, 0)
        panel2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        panel2.BackgroundTransparency = 0.4
        panel2.BorderSizePixel = 0
        panel2.Parent = bb
        Instance.new("UICorner", panel2).CornerRadius = UDim.new(0, 3)

        local stroke2 = Instance.new("UIStroke")
        stroke2.Thickness = 1
        stroke2.Color = C_CYAN
        stroke2.Transparency = 0.2
        stroke2.Parent = panel2

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, -8, 0, 22)
        nameLbl.Position = UDim2.new(0, 4, 0, 4)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = "▸ " .. string.upper(targetPlayer.DisplayName)
        nameLbl.TextColor3 = C_CYAN
        nameLbl.TextSize = 13
        nameLbl.Font = Enum.Font.Code
        nameLbl.TextXAlignment = Enum.TextXAlignment.Center
        nameLbl.Parent = panel2

        local distLbl = Instance.new("TextLabel")
        distLbl.Size = UDim2.new(1, -8, 0, 14)
        distLbl.Position = UDim2.new(0, 4, 0, 28)
        distLbl.BackgroundTransparency = 1
        distLbl.Text = "DIST: 0.0m"
        distLbl.TextColor3 = C_PURPLE
        distLbl.TextSize = 10
        distLbl.Font = Enum.Font.Code
        distLbl.TextXAlignment = Enum.TextXAlignment.Center
        distLbl.Parent = panel2

        local hpBg = Instance.new("Frame")
        hpBg.Size = UDim2.new(1, -8, 0, 5)
        hpBg.Position = UDim2.new(0, 4, 1, -8)
        hpBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        hpBg.BorderSizePixel = 0
        hpBg.Parent = panel2
        Instance.new("UICorner", hpBg).CornerRadius = UDim.new(0, 2)

        local hpFill = Instance.new("Frame")
        hpFill.Size = UDim2.new(1, 0, 1, 0)
        hpFill.BackgroundColor3 = C_GREEN
        hpFill.BorderSizePixel = 0
        hpFill.Parent = hpBg
        Instance.new("UICorner", hpFill).CornerRadius = UDim.new(0, 2)

        espData[targetPlayer] = {
            highlight = highlight,
            billboard = bb,
            distLbl = distLbl,
            hpFill = hpFill,
        }
    else
        espData[targetPlayer] = { highlight = highlight }
    end

    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not targetPlayer or not targetPlayer.Parent then
            if conn then conn:Disconnect() end
            return
        end

        local data = espData[targetPlayer]
        if not data then return end

        local isSelected = selectedPlayers[targetPlayer] == true
        if data.highlight then data.highlight.Enabled = isSelected end
        if data.billboard then data.billboard.Enabled = isSelected end

        if not isSelected then return end

        local c = targetPlayer.Character
        if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local myChar = plr.Character
        if not myChar then return end
        local myHrp = myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end

        local dist = (hrp.Position - myHrp.Position).Magnitude

        if data.distLbl then
            data.distLbl.Text = string.format("DIST: %.1fm", dist)
            if dist < 30 then
                data.distLbl.TextColor3 = C_RED
                if data.highlight then
                    data.highlight.FillColor = Color3.fromRGB(255, 60, 80)
                    data.highlight.OutlineColor = C_RED
                end
            elseif dist < 100 then
                data.distLbl.TextColor3 = C_YELLOW
                if data.highlight then
                    data.highlight.FillColor = Color3.fromRGB(255, 220, 60)
                    data.highlight.OutlineColor = C_YELLOW
                end
            else
                data.distLbl.TextColor3 = C_CYAN
                if data.highlight then
                    data.highlight.FillColor = C_CYAN
                    data.highlight.OutlineColor = Color3.fromRGB(0, 200, 255)
                end
            end
        end

        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum and data.hpFill then
            local ratio = hum.Health / hum.MaxHealth
            data.hpFill.Size = UDim2.new(ratio, 0, 1, 0)
            if ratio > 0.6 then
                data.hpFill.BackgroundColor3 = C_GREEN
            elseif ratio > 0.3 then
                data.hpFill.BackgroundColor3 = C_YELLOW
            else
                data.hpFill.BackgroundColor3 = C_RED
            end
        end
    end)

    espData[targetPlayer].conn = conn
end

local function removeESP(targetPlayer)
    if espData[targetPlayer] then
        local d = espData[targetPlayer]
        if d.highlight and d.highlight.Parent then d.highlight:Destroy() end
        if d.billboard and d.billboard.Parent then d.billboard:Destroy() end
        if d.conn then d.conn:Disconnect() end
        espData[targetPlayer] = nil
    end
end

------------------------------------------------------------
-- 起動
------------------------------------------------------------
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= plr then
        makePlayerButton(p)
        if p.Character then createESP(p) end

        p.CharacterAdded:Connect(function()
            task.wait(1)
            removeESP(p)
            createESP(p)
        end)
    end
end

Players.PlayerAdded:Connect(function(p)
    task.wait(1.5)
    if p ~= plr then
        makePlayerButton(p)
        if p.Character then createESP(p) end

        p.CharacterAdded:Connect(function()
            task.wait(1)
            removeESP(p)
            createESP(p)
        end)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    removeESP(p)
    removePlayerButton(p)
    selectedPlayers[p] = nil
end)

print("[Script] 起動完了 - " .. plr.DisplayName)
