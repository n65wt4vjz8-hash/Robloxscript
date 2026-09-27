--[[ neon_program.lua - Key → ロード → ESP + TP + FPS/ms + FOV調整 ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")

local plr = Players.LocalPlayer
local cam = workspace.CurrentCamera
local PlayerGui = plr:WaitForChild("PlayerGui")

------------------------------------------------------------
-- GUI親の取得（Delta対応）
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
local C_DARK   = Color3.fromRGB(2, 2, 8)
local C_PANEL  = Color3.fromRGB(8, 8, 20)

------------------------------------------------------------
-- 状態
------------------------------------------------------------
local authed = false
local selectedPlayers = {}
local playerButtons = {}
local espData = {}

local fpsValue = 60
local msValue = 16.7
local fpsTimer = 0
local frameCount = 0

-- ★ FOV
local defaultFOV = cam.FieldOfView
local currentFOV = defaultFOV

------------------------------------------------------------
-- ヘルパー
------------------------------------------------------------
local function addCorners(parent, color, size, zindex)
    size = size or 40
    color = color or C_CYAN
    zindex = zindex or 10
    local positions = {
        {0, 0, 1, 1}, {1, 0, -1, 1}, {0, 1, 1, -1}, {1, 1, -1, -1},
    }
    for _, pos in ipairs(positions) do
        local h = Instance.new("Frame")
        h.Size = UDim2.new(0, size, 0, 3)
        h.Position = UDim2.new(pos[1], pos[3] == 1 and 0 or -size, pos[2], pos[4] == 1 and 0 or -3)
        h.BackgroundColor3 = color
        h.BorderSizePixel = 0
        h.ZIndex = zindex
        h.Parent = parent

        local v = Instance.new("Frame")
        v.Size = UDim2.new(0, 3, 0, size)
        v.Position = UDim2.new(pos[1], pos[3] == 1 and 0 or -3, pos[2], pos[4] == 1 and 0 or -size)
        v.BackgroundColor3 = color
        v.BorderSizePixel = 0
        v.ZIndex = zindex
        v.Parent = parent
    end
end

local function addGrid(parent, cell, transparency, color)
    cell = cell or 60
    transparency = transparency or 0.9
    color = color or C_CYAN
    task.spawn(function()
        task.wait(0.1)
        local w = parent.AbsoluteSize.X
        local h = parent.AbsoluteSize.Y
        for x = 0, w, cell do
            local line = Instance.new("Frame")
            line.Size = UDim2.new(0, 1, 1, 0)
            line.Position = UDim2.new(0, x, 0, 0)
            line.BackgroundColor3 = color
            line.BackgroundTransparency = transparency
            line.BorderSizePixel = 0
            line.Parent = parent
        end
        for y = 0, h, cell do
            local line = Instance.new("Frame")
            line.Size = UDim2.new(1, 0, 0, 1)
            line.Position = UDim2.new(0, 0, 0, y)
            line.BackgroundColor3 = color
            line.BackgroundTransparency = transparency
            line.BorderSizePixel = 0
            line.Parent = parent
        end
    end)
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
gui.Name = "NeonProgramGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = guiParent

-- 背景
local bg = Instance.new("Frame")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundColor3 = C_DARK
bg.BorderSizePixel = 0
bg.ZIndex = 0
bg.Parent = gui

-- グリッド
local gridContainer = Instance.new("Frame")
gridContainer.Size = UDim2.new(1, 0, 1, 0)
gridContainer.BackgroundTransparency = 1
gridContainer.ZIndex = 1
gridContainer.Parent = gui
addGrid(gridContainer, 60, 0.9, C_CYAN)

-- 走査線
task.spawn(function()
    task.wait(0.2)
    for y = 0, 1080, 4 do
        local line = Instance.new("Frame")
        line.Size = UDim2.new(1, 0, 0, 1)
        line.Position = UDim2.new(0, 0, 0, y)
        line.BackgroundColor3 = C_CYAN
        line.BackgroundTransparency = 0.92
        line.BorderSizePixel = 0
        line.ZIndex = 2
        line.Parent = gui
    end
end)

addCorners(gui, C_CYAN, 50, 5)

------------------------------------------------------------
-- PERFORMANCE パネル（右上）
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

addCorners(infoPanel, C_CYAN, 6, 11)

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
-- ★ FOV パネル（PERFORMANCEの下）
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

addCorners(fovPanel, C_PURPLE, 6, 11)

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

-- 数値表示
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

-- − ボタン
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

-- + ボタン
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

-- RESET ボタン
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

-- プリセットボタン（小さい）
local presetFrame = Instance.new("Frame")
presetFrame.Size = UDim2.new(1, -8, 0, 0)
presetFrame.Position = UDim2.new(0, 6, 0, 0)
presetFrame.BackgroundTransparency = 1
presetFrame.ZIndex = 12
presetFrame.Parent = fovPanel

local function updateFOV(newFOV)
    newFOV = math.clamp(newFOV, 30, 120)
    currentFOV = newFOV
    cam.FieldOfView = newFOV
    fovValueLbl.Text = "FOV: " .. math.floor(newFOV)
end

bindClick(minusBtn, function()
    updateFOV(currentFOV - 5)
end)

bindClick(plusBtn, function()
    updateFOV(currentFOV + 5)
end)

bindClick(resetFovBtn, function()
    updateFOV(defaultFOV)
end)

------------------------------------------------------------
-- KEY入力画面
------------------------------------------------------------
local keyScreen = Instance.new("Frame")
keyScreen.Size = UDim2.new(1, 0, 1, 0)
keyScreen.BackgroundTransparency = 1
keyScreen.ZIndex = 10
keyScreen.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 100)
title.Position = UDim2.new(0, 0, 0.15, 0)
title.BackgroundTransparency = 1
title.Text = "◢ ACCESS TERMINAL ◣"
title.TextColor3 = C_CYAN
title.TextStrokeTransparency = 1
title.TextSize = 42
title.Font = Enum.Font.Code
title.ZIndex = 10
title.Parent = keyScreen

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, 0, 0, 24)
subtitle.Position = UDim2.new(0, 0, 0.19, 0)
subtitle.BackgroundTransparency = 1
subtitle.Text = "// SECURE AUTHENTICATION PROTOCOL v3.7.1"
subtitle.TextColor3 = C_PURPLE
subtitle.TextSize = 12
subtitle.Font = Enum.Font.Code
subtitle.ZIndex = 10
subtitle.Parent = keyScreen

local inputPanel = Instance.new("Frame")
inputPanel.Size = UDim2.new(0, 420, 0, 120)
inputPanel.Position = UDim2.new(0.5, -210, 0.42, 0)
inputPanel.BackgroundColor3 = C_PANEL
inputPanel.BackgroundTransparency = 0.2
inputPanel.BorderSizePixel = 0
inputPanel.ZIndex = 10
inputPanel.Parent = keyScreen
Instance.new("UICorner", inputPanel).CornerRadius = UDim.new(0, 4)

local panelStroke = Instance.new("UIStroke")
panelStroke.Thickness = 2
panelStroke.Color = C_CYAN
panelStroke.Transparency = 0.2
panelStroke.Parent = inputPanel

addCorners(inputPanel, C_CYAN, 12, 11)

local inputLabel = Instance.new("TextLabel")
inputLabel.Size = UDim2.new(1, -24, 0, 16)
inputLabel.Position = UDim2.new(0, 12, 0, 8)
inputLabel.BackgroundTransparency = 1
inputLabel.Text = "▸ KEY INPUT REQUIRED"
inputLabel.TextColor3 = C_CYAN
inputLabel.TextSize = 11
inputLabel.Font = Enum.Font.Code
inputLabel.TextXAlignment = Enum.TextXAlignment.Left
inputLabel.ZIndex = 11
inputLabel.Parent = inputPanel

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(1, -24, 0, 46)
keyBox.Position = UDim2.new(0, 12, 0, 30)
keyBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
keyBox.BackgroundTransparency = 0.1
keyBox.TextColor3 = C_CYAN
keyBox.PlaceholderText = "> enter your key _"
keyBox.PlaceholderColor3 = Color3.fromRGB(80, 80, 120)
keyBox.Text = ""
keyBox.TextSize = 20
keyBox.Font = Enum.Font.Code
keyBox.ClearTextOnFocus = false
keyBox.BorderSizePixel = 0
keyBox.ZIndex = 11
keyBox.Parent = inputPanel
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 2)

local keyBoxStroke = Instance.new("UIStroke")
keyBoxStroke.Thickness = 2
keyBoxStroke.Color = C_PINK
keyBoxStroke.Transparency = 0.1
keyBoxStroke.Parent = keyBox

local verifyBtn = Instance.new("TextButton")
verifyBtn.Size = UDim2.new(1, -24, 0, 32)
verifyBtn.Position = UDim2.new(0, 12, 1, -42)
verifyBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
verifyBtn.BackgroundTransparency = 0.3
verifyBtn.TextColor3 = C_GREEN
verifyBtn.Text = "[ ▶ EXECUTE VERIFICATION ]"
verifyBtn.TextSize = 13
verifyBtn.Font = Enum.Font.Code
verifyBtn.BorderSizePixel = 0
verifyBtn.ZIndex = 11
verifyBtn.Parent = inputPanel
Instance.new("UICorner", verifyBtn).CornerRadius = UDim.new(0, 2)

local verifyStroke = Instance.new("UIStroke")
verifyStroke.Thickness = 2
verifyStroke.Color = C_GREEN
verifyStroke.Transparency = 0.3
verifyStroke.Parent = verifyBtn

local statusLbl = Instance.new("TextLabel")
statusLbl.Size = UDim2.new(1, 0, 0, 34)
statusLbl.Position = UDim2.new(0, 0, 0.62, 0)
statusLbl.BackgroundTransparency = 1
statusLbl.Text = ""
statusLbl.TextColor3 = C_RED
statusLbl.TextSize = 18
statusLbl.Font = Enum.Font.Code
statusLbl.ZIndex = 10
statusLbl.Parent = keyScreen

local logLbl = Instance.new("TextLabel")
logLbl.Size = UDim2.new(0, 500, 0, 20)
logLbl.Position = UDim2.new(0, 30, 1, -40)
logLbl.BackgroundTransparency = 1
logLbl.Text = ""
logLbl.TextColor3 = C_CYAN
logLbl.TextSize = 11
logLbl.Font = Enum.Font.Code
logLbl.TextXAlignment = Enum.TextXAlignment.Left
logLbl.ZIndex = 10
logLbl.Parent = keyScreen

------------------------------------------------------------
-- ロード画面
------------------------------------------------------------
local loadScreen = Instance.new("Frame")
loadScreen.Size = UDim2.new(1, 0, 1, 0)
loadScreen.BackgroundTransparency = 1
loadScreen.ZIndex = 20
loadScreen.Visible = false
loadScreen.Parent = gui

local loadTitle = Instance.new("TextLabel")
loadTitle.Size = UDim2.new(1, 0, 0, 60)
loadTitle.Position = UDim2.new(0, 0, 0.12, 0)
loadTitle.BackgroundTransparency = 1
loadTitle.Text = "◢ INITIALIZING ◣"
loadTitle.TextColor3 = C_CYAN
loadTitle.TextStrokeTransparency = 1
loadTitle.TextSize = 38
loadTitle.Font = Enum.Font.Code
loadTitle.ZIndex = 21
loadTitle.Parent = loadScreen

local logFrame = Instance.new("Frame")
logFrame.Size = UDim2.new(0, 500, 0, 220)
logFrame.Position = UDim2.new(0.5, -250, 0.35, 0)
logFrame.BackgroundColor3 = C_PANEL
logFrame.BackgroundTransparency = 0.2
logFrame.BorderSizePixel = 0
logFrame.ZIndex = 21
logFrame.Parent = loadScreen
Instance.new("UICorner", logFrame).CornerRadius = UDim.new(0, 4)

local logStroke = Instance.new("UIStroke")
logStroke.Thickness = 2
logStroke.Color = C_CYAN
logStroke.Transparency = 0.3
logStroke.Parent = logFrame

addCorners(logFrame, C_CYAN, 12, 22)

local logHeader = Instance.new("Frame")
logHeader.Size = UDim2.new(1, 0, 0, 20)
logHeader.BackgroundColor3 = C_CYAN
logHeader.BackgroundTransparency = 0.85
logHeader.BorderSizePixel = 0
logHeader.ZIndex = 22
logHeader.Parent = logFrame

local logHeaderLbl = Instance.new("TextLabel")
logHeaderLbl.Size = UDim2.new(1, -20, 1, 0)
logHeaderLbl.Position = UDim2.new(0, 10, 0, 0)
logHeaderLbl.BackgroundTransparency = 1
logHeaderLbl.Text = "▸ SYSTEM_LOADER.SYS  [/proc/sys]"
logHeaderLbl.TextColor3 = C_CYAN
logHeaderLbl.TextSize = 10
logHeaderLbl.Font = Enum.Font.Code
logHeaderLbl.TextXAlignment = Enum.TextXAlignment.Left
logHeaderLbl.ZIndex = 23
logHeaderLbl.Parent = logHeader

local logContainer = Instance.new("Frame")
logContainer.Size = UDim2.new(1, -20, 1, -30)
logContainer.Position = UDim2.new(0, 10, 0, 26)
logContainer.BackgroundTransparency = 1
logContainer.ZIndex = 22
logContainer.Parent = logFrame

local logLayout = Instance.new("UIListLayout")
logLayout.Padding = UDim.new(0, 3)
logLayout.SortOrder = Enum.SortOrder.LayoutOrder
logLayout.Parent = logContainer

local barFrame = Instance.new("Frame")
barFrame.Size = UDim2.new(0, 500, 0, 40)
barFrame.Position = UDim2.new(0.5, -250, 0.77, 0)
barFrame.BackgroundColor3 = C_PANEL
barFrame.BackgroundTransparency = 0.3
barFrame.BorderSizePixel = 0
barFrame.ZIndex = 21
barFrame.Parent = loadScreen
Instance.new("UICorner", barFrame).CornerRadius = UDim.new(0, 4)

local barStroke = Instance.new("UIStroke")
barStroke.Thickness = 2
barStroke.Color = C_CYAN
barStroke.Transparency = 0.3
barStroke.Parent = barFrame

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(1, -20, 0, 12)
barBg.Position = UDim2.new(0, 10, 0, 22)
barBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
barBg.BorderSizePixel = 0
barBg.ZIndex = 22
barBg.Parent = barFrame
Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 2)

local SEGMENTS = 50
local segmentFrames = {}
for i = 1, SEGMENTS do
    local seg = Instance.new("Frame")
    seg.Size = UDim2.new(1/SEGMENTS - 0.003, 0, 1, 0)
    seg.Position = UDim2.new((i - 1)/SEGMENTS, 0, 0, 0)
    seg.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    seg.BackgroundTransparency = 0.7
    seg.BorderSizePixel = 0
    seg.ZIndex = 23
    seg.Parent = barBg
    table.insert(segmentFrames, seg)
end

local percentLbl = Instance.new("TextLabel")
percentLbl.Size = UDim2.new(0, 100, 0, 12)
percentLbl.Position = UDim2.new(1, -110, 0, 3)
percentLbl.BackgroundTransparency = 1
percentLbl.Text = "0.000%"
percentLbl.TextColor3 = C_CYAN
percentLbl.TextSize = 11
percentLbl.Font = Enum.Font.Code
percentLbl.TextXAlignment = Enum.TextXAlignment.Right
percentLbl.ZIndex = 22
percentLbl.Parent = barFrame

------------------------------------------------------------
-- ログ
------------------------------------------------------------
local logIndex = 0
local function addLog(prefix, text, color)
    logIndex = logIndex + 1
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 16)
    container.BackgroundTransparency = 1
    container.ZIndex = 22
    container.Parent = logContainer

    local num = Instance.new("TextLabel")
    num.Size = UDim2.new(0, 26, 1, 0)
    num.BackgroundTransparency = 1
    num.Text = string.format("%02d", logIndex)
    num.TextColor3 = Color3.fromRGB(80, 80, 120)
    num.TextSize = 10
    num.Font = Enum.Font.Code
    num.TextXAlignment = Enum.TextXAlignment.Left
    num.ZIndex = 23
    num.Parent = container

    local prefixLbl = Instance.new("TextLabel")
    prefixLbl.Size = UDim2.new(0, 36, 1, 0)
    prefixLbl.Position = UDim2.new(0, 28, 0, 0)
    prefixLbl.BackgroundTransparency = 1
    prefixLbl.Text = prefix
    prefixLbl.TextColor3 = color or C_CYAN
    prefixLbl.TextSize = 10
    prefixLbl.Font = Enum.Font.Code
    prefixLbl.TextXAlignment = Enum.TextXAlignment.Left
    prefixLbl.ZIndex = 23
    prefixLbl.Parent = container

    local txtLbl = Instance.new("TextLabel")
    txtLbl.Size = UDim2.new(1, -70, 1, 0)
    txtLbl.Position = UDim2.new(0, 66, 0, 0)
    txtLbl.BackgroundTransparency = 1
    txtLbl.Text = text
    txtLbl.TextColor3 = C_CYAN
    txtLbl.TextSize = 11
    txtLbl.Font = Enum.Font.Code
    txtLbl.TextXAlignment = Enum.TextXAlignment.Left
    txtLbl.ZIndex = 23
    txtLbl.Parent = container

    return {container = container, txt = txtLbl}
end

local function updateProgress(pct)
    local segCount = math.floor(SEGMENTS * pct / 100)
    for i, seg in ipairs(segmentFrames) do
        if i <= segCount then
            seg.BackgroundColor3 = C_CYAN
            seg.BackgroundTransparency = 0
        else
            seg.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
            seg.BackgroundTransparency = 0.7
        end
    end
    percentLbl.Text = string.format("%.3f%%", pct)
end

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
    local newCF = targetHrp.CFrame + offset + Vector3.new(0, 1, 0)
    myHrp.CFrame = newCF
end

------------------------------------------------------------
-- プレイヤー選択GUI
------------------------------------------------------------
local selectGui
local scrollFrameRef

local function buildPlayerSelectGui()
    selectGui = Instance.new("ScreenGui")
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

    addCorners(panel, C_CYAN, 8, 11)

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

    scrollFrameRef = scrollFrame
end

local function makePlayerButton(targetPlayer)
    if targetPlayer == plr then return end
    if playerButtons[targetPlayer] then return end
    if not scrollFrameRef then return end

    local btn = Instance.new("Frame")
    btn.Name = "PlayerBtn_" .. targetPlayer.Name
    btn.Size = UDim2.new(1, -4, 0, 22)
    btn.BackgroundColor3 = Color3.fromRGB(15, 20, 35)
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    btn.ZIndex = 11
    btn.Parent = scrollFrameRef
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

    -- 選択ボタン
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
    highlight.Name = "ProgramESP"
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
        bb.Name = "ProgramESPBillboard"
        bb.Size = UDim2.new(0, 220, 0, 60)
        bb.StudsOffset = Vector3.new(0, 3.5, 0)
        bb.AlwaysOnTop = true
        bb.MaxDistance = math.huge
        bb.Enabled = false
        bb.Parent = head

        local panel = Instance.new("Frame")
        panel.Size = UDim2.new(1, 0, 1, 0)
        panel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        panel.BackgroundTransparency = 0.4
        panel.BorderSizePixel = 0
        panel.Parent = bb
        Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 3)

        local stroke = Instance.new("UIStroke")
        stroke.Thickness = 1
        stroke.Color = C_CYAN
        stroke.Transparency = 0.2
        stroke.Parent = panel

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, -8, 0, 22)
        nameLbl.Position = UDim2.new(0, 4, 0, 4)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = "▸ " .. string.upper(targetPlayer.DisplayName)
        nameLbl.TextColor3 = C_CYAN
        nameLbl.TextSize = 13
        nameLbl.Font = Enum.Font.Code
        nameLbl.TextXAlignment = Enum.TextXAlignment.Center
        nameLbl.Parent = panel

        local distLbl = Instance.new("TextLabel")
        distLbl.Size = UDim2.new(1, -8, 0, 14)
        distLbl.Position = UDim2.new(0, 4, 0, 28)
        distLbl.BackgroundTransparency = 1
        distLbl.Text = "DIST: 0.0m"
        distLbl.TextColor3 = C_PURPLE
        distLbl.TextSize = 10
        distLbl.Font = Enum.Font.Code
        distLbl.TextXAlignment = Enum.TextXAlignment.Center
        distLbl.Parent = panel

        local hpBg = Instance.new("Frame")
        hpBg.Size = UDim2.new(1, -8, 0, 5)
        hpBg.Position = UDim2.new(0, 4, 1, -8)
        hpBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        hpBg.BorderSizePixel = 0
        hpBg.Parent = panel
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

local function startESP()
    buildPlayerSelectGui()

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
end

------------------------------------------------------------
-- 認証
------------------------------------------------------------
local function runLoadSequence()
    keyScreen.Visible = false
    loadScreen.Visible = true

    logIndex = 0
    for _, c in ipairs(logContainer:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    updateProgress(0)

    task.wait(0.4)

    local steps = {
        {prefix = "[SYS]", text = "Booting system...", color = C_CYAN, time = 0.8, pct = 14},
        {prefix = "[NET]", text = "Checking connection...", color = C_CYAN, time = 0.9, pct = 30},
        {prefix = "[ADR]", text = "Verifying address...", color = C_CYAN, time = 1.0, pct = 46},
        {prefix = "[IDN]", text = "Authenticating identity...", color = C_PURPLE, time = 1.1, pct = 62},
        {prefix = "[SCN]", text = "Scanning player network...", color = C_PURPLE, time = 1.0, pct = 78},
        {prefix = "[PRG]", text = "Compiling target list...", color = C_PINK, time = 0.9, pct = 92},
        {prefix = "[OK ]", text = "System ready.", color = C_GREEN, time = 0.8, pct = 100},
    }

    for _, step in ipairs(steps) do
        local log = addLog(step.prefix, step.text, step.color)
        task.wait(step.time)
        updateProgress(step.pct)
        log.txt.Text = step.text .. " ... OK"
        log.txt.TextColor3 = C_GREEN
    end

    loadTitle.Text = "◢ COMPLETE ◣"
    loadTitle.TextColor3 = C_GREEN
    task.wait(0.8)
end

local function onAuthSuccess()
    if authed then return end
    authed = true

    statusLbl.Text = "✓ ACCESS GRANTED"
    statusLbl.TextColor3 = C_GREEN
    logLbl.Text = ">> authentication successful for " .. plr.DisplayName

    local flash = Instance.new("Frame")
    flash.Size = UDim2.new(1, 0, 1, 0)
    flash.BackgroundColor3 = C_GREEN
    flash.BorderSizePixel = 0
    flash.ZIndex = 200
    flash.BackgroundTransparency = 0.3
    flash.Parent = gui
    TweenService:Create(flash, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
    task.delay(0.9, function() if flash and flash.Parent then flash:Destroy() end end)

    title.Text = "◢ ACCESS GRANTED ◣"
    title.TextColor3 = C_GREEN

    task.wait(1.5)

    task.spawn(function()
        runLoadSequence()

        task.wait(0.5)

        TweenService:Create(bg, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
        TweenService:Create(gridContainer, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()

        task.wait(0.8)

        keyScreen:Destroy()
        loadScreen:Destroy()
        bg:Destroy()
        gridContainer:Destroy()

        -- 走査線も削除（Performance/FOVパネルは残す）
        for _, child in ipairs(gui:GetChildren()) do
            if child:IsA("Frame") and child.Name ~= "PerformancePanel" and child.Name ~= "FovPanel" then
                if child.BackgroundTransparency == 0.92 then
                    child:Destroy()
                end
            end
        end

        -- 走査線とビネットだけのオーバーレイ
        local overlay = Instance.new("ScreenGui")
        overlay.Name = "ProgramOverlay"
        overlay.ResetOnSpawn = false
        overlay.IgnoreGuiInset = true
        overlay.DisplayOrder = 500
        overlay.Parent = guiParent

        task.spawn(function()
            task.wait(0.1)
            for y = 0, 1080, 4 do
                local line = Instance.new("Frame")
                line.Size = UDim2.new(1, 0, 0, 1)
                line.Position = UDim2.new(0, 0, 0, y)
                line.BackgroundColor3 = C_CYAN
                line.BackgroundTransparency = 0.93
                line.BorderSizePixel = 0
                line.ZIndex = 1
                line.Parent = overlay
            end
        end)

        local vign = Instance.new("Frame")
        vign.Size = UDim2.new(1, 0, 1, 0)
        vign.BackgroundColor3 = Color3.fromRGB(0, 30, 60)
        vign.BackgroundTransparency = 1
        vign.BorderSizePixel = 0
        vign.ZIndex = 2
        vign.Parent = overlay

        local vigGrad = Instance.new("UIGradient")
        vigGrad.Rotation = 0
        vigGrad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.3),
            NumberSequenceKeypoint.new(0.3, 1),
            NumberSequenceKeypoint.new(0.7, 1),
            NumberSequenceKeypoint.new(1, 0.3),
        })
        vigGrad.Parent = vign

        addCorners(overlay, C_CYAN, 40, 5)

        local hudTitle = Instance.new("TextLabel")
        hudTitle.Size = UDim2.new(0, 400, 0, 24)
        hudTitle.Position = UDim2.new(0, 50, 0, 30)
        hudTitle.BackgroundTransparency = 1
        hudTitle.Text = "◢ SYSTEM: ONLINE ◣"
        hudTitle.TextColor3 = C_CYAN
        hudTitle.TextSize = 14
        hudTitle.Font = Enum.Font.Code
        hudTitle.TextXAlignment = Enum.TextXAlignment.Left
        hudTitle.ZIndex = 5
        hudTitle.Parent = overlay

        startESP()

        print("[NeonProgram] 完了！")
    end)
end

------------------------------------------------------------
-- Key検証
------------------------------------------------------------
local function verify()
    if authed then return end
    local input = keyBox.Text
    local correct = plr.DisplayName

    if input:lower() == correct:lower() then
        onAuthSuccess()
    else
        statusLbl.Text = "✗ ACCESS DENIED"
        statusLbl.TextColor3 = C_RED
        logLbl.Text = ">> invalid key detected"

        local flash = Instance.new("Frame")
        flash.Size = UDim2.new(1, 0, 1, 0)
        flash.BackgroundColor3 = C_RED
        flash.BorderSizePixel = 0
        flash.ZIndex = 200
        flash.BackgroundTransparency = 0.5
        flash.Parent = gui
        TweenService:Create(flash, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
        task.delay(0.5, function() if flash and flash.Parent then flash:Destroy() end end)

        local basePos = inputPanel.Position
        for i = 1, 8 do
            inputPanel.Position = basePos + UDim2.new(math.random(-10, 10) / 1000, 0, 0, 0)
            task.wait(0.03)
        end
        inputPanel.Position = basePos

        keyBox.Text = ""
        keyBox:CaptureFocus()
    end
end

bindClick(verifyBtn, verify)
keyBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then verify() end
end)

task.wait(0.3)
keyBox:CaptureFocus()

print("[NeonProgram] Keyを入力: " .. plr.DisplayName)
