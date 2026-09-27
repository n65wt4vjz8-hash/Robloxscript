--[[ jarvis.lua - JARVIS HUD (Delta最適化版) ]]
print("[JARVIS] 読み込み開始")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local plr = Players.LocalPlayer
local PlayerGui = plr:WaitForChild("PlayerGui")
local cam = workspace.CurrentCamera

print("[JARVIS] サービス取得OK")

-- カラー
local C_CYAN     = Color3.fromRGB(0, 200, 255)
local C_CYAN2    = Color3.fromRGB(0, 130, 200)
local C_BLUE     = Color3.fromRGB(0, 100, 180)
local C_WHITE    = Color3.fromRGB(220, 240, 255)
local C_BG       = Color3.fromRGB(0, 8, 18)
local C_PANEL    = Color3.fromRGB(0, 15, 30)
local C_RED      = Color3.fromRGB(255, 60, 60)
local C_GREEN    = Color3.fromRGB(0, 255, 150)
local C_YELLOW   = Color3.fromRGB(255, 200, 0)

local F = {
    fly = false,
    speed = false,
    jump = false,
    fullbright = false,
    noclip = false,
    infjump = false,
}

local speedValue = 50
local jumpValue = 100
local flySpeed = 80

local originalLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
}

-- ヘルパー
local function corner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = obj
end

local function stroke(obj, color, thick, transp)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thick or 1
    s.Transparency = transp or 0.3
    s.Parent = obj
end

local function bindClick(btn, cb)
    local last = 0
    local function try()
        local now = tick()
        if now - last < 0.2(input then return end
        last = now
        cb)
()
    end
    btn.Mouse       Button1Click:Connect(try)
    if btn.InputBegan:Connect(function input(input)
        if input.UserInput.UserType == Enum.UserInputType.Touch then try() end
    end)
end

local function makeDraggable(frame, dragBar)
    dragBar = dragBar or frame
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    dragBar.InputBegan:Connect(functionInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

------------------------------------------------------------
-- 機能
------------------------------------------------------------
local flyBV, flyBG, flyConn
local function startFly()
    local char = plr.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    hum.PlatformStand = true
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = hrp
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyBG.P = 1e4
    flyBG.CFrame = hrp.CFrame
    flyBG.Parent = hrp
    flyConn = RunService.RenderStepped:Connect(function()
        if not F.fly or not hrp.Parent then return end
        local moveDir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0, 1, 0) end
        flyBV.Velocity = moveDir.Magnitude > 0 and (moveDir.Unit * flySpeed) or Vector3.zero
        flyBG.CFrame = cam.CFrame
    end)
end

local function stopFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if flyBV then flyBV:Destroy(); flyBV = nil end
    if flyBG then flyBG:Destroy(); flyBG = nil end
    local char = plr.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

local function applySpeed()
    local char = plr.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = F.speed and speedValue or 16 end
end

local function applyJump()
    local char = plr.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = F.jump and jumpValue or 50 end
end

local function applyFullbright()
    if F.fullbright then
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        Lighting.Brightness = 3
    else
        Lighting.Ambient = originalLighting.Ambient
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        Lighting.Brightness = originalLighting.Brightness
    end
end

local noclipConn
local function startNoclip()
    if noclipConn then return end
    noclipConn = RunService.Stepped:Connect(function()
        if not F.noclip then return end
        local char = plr.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

UIS.JumpRequest:Connect(function()
    if not F.infjump then return end
    local char = plr.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

------------------------------------------------------------
-- ESP
------------------------------------------------------------
local espData = {}
local espSelected = {}

local function createESP(target)
    if target == plr then return end
    if espData[target] then return end
    local char = target.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    local hl = Instance.new("Highlight")
    hl.FillColor = C_CYAN
    hl.OutlineColor = C_WHITE
    hl.FillTransparency = 0.75
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = char
    hl.Parent = char

    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 200, 0, 80)
    bb.StudsOffset = Vector3.new(0, 3.8, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = math.huge
    bb.Parent = head

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = C_BG
    frame.BackgroundTransparency = 0.7
    frame.BorderSizePixel = 0
    frame.Parent = bb
    corner(frame, 4)
    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = C_CYAN
    frameStroke.Thickness = 1
    frameStroke.Transparency = 0.3
    frameStroke.Parent = frame

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -8, 0, 16)
    nameLbl.Position = UDim2.new(0, 4, 0, 6)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = string.upper(target.DisplayName)
    nameLbl.TextColor3 = C_WHITE
    nameLbl.TextSize = 12
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextStrokeTransparency = 0.5
    nameLbl.TextStrokeColor3 = C_CYAN
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = frame

    local distLbl = Instance.new("TextLabel")
    distLbl.Size = UDim2.new(1, -8, 0, 12)
    distLbl.Position = UDim2.new(0, 4, 0, 26)
    distLbl.BackgroundTransparency = 1
    distLbl.Text = "DIST: 0.0m"
    distLbl.TextColor3 = C_CYAN2
    distLbl.TextSize = 10
    distLbl.Font = Enum.Font.Code
    distLbl.TextXAlignment = Enum.TextXAlignment.Left
    distLbl.Parent = frame

    local hpBg = Instance.new("Frame")
    hpBg.Size = UDim2.new(1, -8, 0, 5)
    hpBg.Position = UDim2.new(0, 4, 1, -12)
    hpBg.BackgroundColor3 = C_BG
    hpBg.BorderSizePixel = 0
    hpBg.Parent = frame
    corner(hpBg, 2)
    local hpBgStroke = Instance.new("UIStroke")
    hpBgStroke.Color = C_CYAN
    hpBgStroke.Thickness = 1
    hpBgStroke.Transparency = 0.4
    hpBgStroke.Parent = hpBg

    local hpFill = Instance.new("Frame")
    hpFill.Size = UDim2.new(1, 0, 1, 0)
    hpFill.BackgroundColor3 = C_GREEN
    hpFill.BorderSizePixel = 0
    hpFill.Parent = hpBg
    corner(hpFill, 2)

    local hpText = Instance.new("TextLabel")
    hpText.Size = UDim2.new(1, -8, 0, 10)
    hpText.Position = UDim2.new(0, 4, 1, -24)
    hpText.BackgroundTransparency = 1
    hpText.Text = "HP: 100/100"
    hpText.TextColor3 = C_CYAN2
    hpText.TextSize = 9
    hpText.Font = Enum.Font.Code
    hpText.TextXAlignment = Enum.TextXAlignment.Right
    hpText.Parent = frame

    local conn = RunService.Heartbeat:Connect(function()
        if not target or not target.Parent then
            if conn then conn:Disconnect() end
            return
        end
        if not espSelected[target] then return end
        local c = target.Character
        if not c then return end
        local cHrp = c:FindFirstChild("HumanoidRootPart")
        if not cHrp then return end
        local myChar = plr.Character
        if not myChar then return end
        local myHrp = myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end

        local dist = (cHrp.Position - myHrp.Position).Magnitude
        distLbl.Text = string.format("DIST: %.1fm", dist)

        if dist < 30 then
            distLbl.TextColor3 = C_RED
            hl.FillColor = C_RED
            hl.OutlineColor = C_RED
            frameStroke.Color = C_RED
        elseif dist < 100 then
            distLbl.TextColor3 = C_YELLOW
            hl.FillColor = C_YELLOW
            hl.OutlineColor = C_YELLOW
            frameStroke.Color = C_YELLOW
        else
            distLbl.TextColor3 = C_CYAN2
            hl.FillColor = C_CYAN
            hl.OutlineColor = C_WHITE
            frameStroke.Color = C_CYAN
        end

        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then
            local ratio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            hpFill.Size = UDim2.new(ratio, 0, 1, 0)
            hpText.Text = string.format("HP: %d/%d", math.floor(hum.Health), math.floor(hum.MaxHealth))
            if ratio > 0.6 then
                hpFill.BackgroundColor3 = C_GREEN
            elseif ratio > 0.3 then
                hpFill.BackgroundColor3 = C_YELLOW
            else
                hpFill.BackgroundColor3 = C_RED
            end
        end
    end)

    espData[target] = {highlight = hl, billboard = bb, conn = conn}
end

local function removeESP(target)
    if espData[target] then
        local d = espData[target]
        if d.highlight and d.highlight.Parent then d.highlight:Destroy() end
        if d.billboard and d.billboard.Parent then d.billboard:Destroy() end
        if d.conn then d.conn:Disconnect() end
        espData[target] = nil
    end
end

local function toggleESPFor(target)
    if espSelected[target] then
        espSelected[target] = nil
        removeESP(target)
    else
        espSelected[target] = true
        createESP(target)
    end
end

------------------------------------------------------------
-- リスポーン対応
------------------------------------------------------------
plr.CharacterAdded:Connect(function()
    task.wait(1)
    if F.speed then applySpeed() end
    if F.jump then applyJump() end
    if F.fly then stopFly(); F.fly = false end
    if F.noclip then startNoclip() end
end)

------------------------------------------------------------
-- 回転リング
------------------------------------------------------------
local function createRotatingRing(parent, size, color, thickness, speed)
    local ring = Instance.new("Frame")
    ring.Size = UDim2.new(0, size, 0, size)
    ring.Position = UDim2.new(0.5, -size/2, 0.5, -size/2)
    ring.BackgroundTransparency = 1
    ring.BorderSizePixel = 0
    ring.Parent = parent

    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(1, 0)
    rc.Parent = ring

    local rs = Instance.new("UIStroke")
    rs.Color = color
    rs.Thickness = thickness
    rs.Transparency = 0.2
    rs.Parent = ring

    local rotation = 0
    task.spawn(function()
        while ring.Parent do
            rotation = rotation + speed * 0.016
            ring.Rotation = rotation
            task.wait(0.016)
        end
    end)
end

------------------------------------------------------------
-- 円形ボタン
------------------------------------------------------------
local function makeCircleButton(parent, size, xPos, yPos, icon, label, callback, stateKey)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, size, 0, size)
    btn.Position = xPos
    btn.AnchorPoint = Vector2.new(0.5, 0.5)
    btn.BackgroundColor3 = C_PANEL
    btn.BackgroundTransparency = 0.2
    btn.Text = icon
    btn.TextColor3 = C_CYAN
    btn.TextSize = size * 0.4
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent

    corner(btn, size / 2)
    local st = Instance.new("UIStroke")
    st.Color = C_CYAN
    st.Thickness = 2
    st.Transparency = 0.2
    st.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 14)
    lbl.Position = UDim2.new(0, 0, 1, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = C_CYAN
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamBold
    lbl.Parent = btn

    local function updateVisual()
        if stateKey and F[stateKey] then
            btn.BackgroundColor3 = C_CYAN
            btn.TextColor3 = C_BG
            st.Color = C_WHITE
            lbl.TextColor3 = C_WHITE
        else
            btn.BackgroundColor3 = C_PANEL
            btn.TextColor3 = C_CYAN
            st.Color = C_CYAN
            lbl.TextColor3 = C_CYAN
        end
    end

    bindClick(btn, function()
        callback()
        updateVisual()
    end)

    updateVisual()
end

------------------------------------------------------------
-- UI 生成
------------------------------------------------------------
print("[JARVIS] GUI作成開始")

local gui = Instance.new("ScreenGui")
gui.Name = "JarvisHud"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = PlayerGui

print("[JARVIS] ScreenGui 作成完了")

-- HUD
local hud = Instance.new("Frame")
hud.Size = UDim2.new(0, 500, 0, 500)
hud.Position = UDim2.new(0.5, -250, 0.5, -250)
hud.BackgroundTransparency = 1
hud.BorderSizePixel = 0
hud.Parent = gui

makeDraggable(hud)

-- 中心ディスク
local centerDisc = Instance.new("Frame")
centerDisc.Size = UDim2.new(0, 200, 0, 200)
centerDisc.Position = UDim2.new(0.5, -100, 0.5, -100)
centerDisc.BackgroundColor3 = C_BG
centerDisc.BackgroundTransparency = 0.3
centerDisc.BorderSizePixel = 0
centerDisc.Parent = hud
corner(centerDisc, 100)
local cds = Instance.new("UIStroke")
cds.Color = C_CYAN
cds.Thickness = 2
cds.Transparency = 0.2
cds.Parent = centerDisc

-- 中心の光
local centerGlow = Instance.new("Frame")
centerGlow.Size = UDim2.new(0, 80, 0, 80)
centerGlow.Position = UDim2.new(0.5, -40, 0.5, -40)
centerGlow.BackgroundColor3 = C_CYAN
centerGlow.BackgroundTransparency = 0.6
centerGlow.BorderSizePixel = 0
centerGlow.Parent = hud
corner(centerGlow, 40)

local arcText = Instance.new("TextLabel")
arcText.Size = UDim2.new(1, 0, 0, 20)
arcText.Position = UDim2.new(0, 0, 0.5, -10)
arcText.BackgroundTransparency = 1
arcText.Text = "JARVIS"
arcText.TextColor3 = C_WHITE
arcText.TextSize = 16
arcText.Font = Enum.Font.GothamBold
arcText.TextStrokeTransparency = 0.5
arcText.TextStrokeColor3 = C_CYAN
arcText.Parent = hud

-- 回転リング
createRotatingRing(hud, 260, C_CYAN, 2, 0.3)
createRotatingRing(hud, 300, C_CYAN2, 1, -0.2)
createRotatingRing(hud, 340, C_BLUE, 1, 0.15)

print("[JARVIS] センターHUD 作成完了")

-- 機能ボタン
makeCircleButton(hud, 55, UDim2.new(0.5, 0, 0, -10), nil, "✈", "FLY",
function()
    F.fly = not F.fly
    if F.fly then startFly() else stopFly() end
end, "fly")

makeCircleButton(hud, 55, UDim2.new(0.5, 0, 1, 10), nil, "⚡", "SPEED",
function()
    F.speed = not F.speed
    applySpeed()
end, "speed")

makeCircleButton(hud, 55, UDim2.new(0, -10, 0.5, 0), nil, "⇧", "JUMP",
function()
    F.jump = not F.jump
    applyJump()
end, "jump")

makeCircleButton(hud, 55, UDim2.new(1, 10, 0.5, 0), nil, "◉", "ESP ALL",
function()
    local anyOff = false
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr and not espSelected[p] then anyOff = true; break end
    end
    if anyOff then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= plr and not espSelected[p] then
                espSelected[p] = true
                createESP(p)
            end
        end
    else
        for p, _ in pairs(espSelected) do
            espSelected[p] = nil
            removeESP(p)
        end
    end
end, nil)

makeCircleButton(hud, 45, UDim2.new(0.18, 0, 0.18, 0), nil, "☀", "BRIGHT",
function()
    F.fullbright = not F.fullbright
    applyFullbright()
end, "fullbright")

makeCircleButton(hud, 45, UDim2.new(0.82, 0, 0.18, 0), nil, "◈", "NOCLIP",
function()
    F.noclip = not F.noclip
    if F.noclip then startNoclip() end
end, "noclip")

makeCircleButton(hud, 45, UDim2.new(0.18, 0, 0.82, 0), nil, "∞", "INFJMP",
function()
    F.infjump = not F.infjump
end, "infjump")

makeCircleButton(hud, 45, UDim2.new(0.82, 0, 0.82, 0), nil, "◐", "RESET",
function()
    F.fly = false; stopFly()
    F.speed = false; applySpeed()
    F.jump = false; applyJump()
    F.fullbright = false; applyFullbright()
    F.noclip = false
    F.infjump = false
end, nil)

print("[JARVIS] ボタン 作成完了")

------------------------------------------------------------
-- ステータスパネル（左上）
------------------------------------------------------------
local statusPanel = Instance.new("Frame")
statusPanel.Size = UDim2.new(0, 200, 0, 140)
statusPanel.Position = UDim2.new(0, 20, 0, 20)
statusPanel.BackgroundColor3 = C_BG
statusPanel.BackgroundTransparency = 0.3
statusPanel.BorderSizePixel = 0
statusPanel.Parent = gui
corner(statusPanel, 8)
stroke(statusPanel, C_CYAN, 1, 0.4)

local statusTitle = Instance.new("TextLabel")
statusTitle.Size = UDim2.new(1, -10, 0, 18)
statusTitle.Position = UDim2.new(0, 8, 0, 4)
statusTitle.BackgroundTransparency = 1
statusTitle.Text = "▸ JARVIS SYSTEM"
statusTitle.TextColor3 = C_CYAN
statusTitle.TextSize = 11
statusTitle.Font = Enum.Font.GothamBold
statusTitle.TextXAlignment = Enum.TextXAlignment.Left
statusTitle.Parent = statusPanel

local statusContainer = Instance.new("Frame")
statusContainer.Size = UDim2.new(1, -10, 1, -26)
statusContainer.Position = UDim2.new(0, 8, 0, 22)
statusContainer.BackgroundTransparency = 1
statusContainer.Parent = statusPanel

local statusLayout = Instance.new("UIListLayout")
statusLayout.Padding = UDim.new(0, 2)
statusLayout.Parent = statusContainer

local statusRows = {}
local function makeStatusRow(key, label)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 14)
    lbl.BackgroundTransparency = 1
    lbl.Text = "  " .. label .. ": OFF"
    lbl.TextColor3 = C_CYAN2
    lbl.TextSize = 10
    lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = statusContainer
    statusRows[key] = {lbl = lbl, label = label}
end

makeStatusRow("fly", "FLY")
makeStatusRow("speed", "SPEED")
makeStatusRow("jump", "JUMP")
makeStatusRow("fullbright", "BRIGHT")
makeStatusRow("noclip", "NOCLIP")
makeStatusRow("infjump", "INFJMP")

task.spawn(function()
    while gui.Parent do
        task.wait(0.3)
        for key, data in pairs(statusRows) do
            if F[key] then
                data.lbl.Text = "  " .. data.label .. ": ON"
                data.lbl.TextColor3 = C_GREEN
            else
                data.lbl.Text = "  " .. data.label .. ": OFF"
                data.lbl.TextColor3 = C_CYAN2
            end
        end
    end
end)

------------------------------------------------------------
-- 時刻表示（右上）
------------------------------------------------------------
local clockPanel = Instance.new("Frame")
clockPanel.Size = UDim2.new(0, 140, 0, 60)
clockPanel.Position = UDim2.new(1, -160, 0, 20)
clockPanel.BackgroundColor3 = C_BG
clockPanel.BackgroundTransparency = 0.3
clockPanel.BorderSizePixel = 0
clockPanel.Parent = gui
corner(clockPanel, 8)
stroke(clockPanel, C_CYAN, 1, 0.4)

local clockLbl = Instance.new("TextLabel")
clockLbl.Size = UDim2.new(1, 0, 0, 30)
clockLbl.Position = UDim2.new(0, 0, 0, 6)
clockLbl.BackgroundTransparency = 1
clockLbl.Text = "00:00"
clockLbl.TextColor3 = C_CYAN
clockLbl.TextSize = 22
clockLbl.Font = Enum.Font.Code
clockLbl.Parent = clockPanel

local dateLbl = Instance.new("TextLabel")
dateLbl.Size = UDim2.new(1, 0, 0, 16)
dateLbl.Position = UDim2.new(0, 0, 0, 36)
dateLbl.BackgroundTransparency = 1
dateLbl.Text = "SYSTEM ONLINE"
dateLbl.TextColor3 = C_CYAN2
dateLbl.TextSize = 9
dateLbl.Font = Enum.Font.Code
dateLbl.Parent = clockPanel

local startTime = tick()
task.spawn(function()
    while gui.Parent do
        task.wait(1)
        local elapsed = tick() - startTime
        local m = math.floor(elapsed / 60)
        local s = math.floor(elapsed % 60)
        clockLbl.Text = string.format("%02d:%02d", m, s)
    end
end)

------------------------------------------------------------
-- プレイヤーリスト（左下）
------------------------------------------------------------
local playerPanel = Instance.new("Frame")
playerPanel.Size = UDim2.new(0, 200, 0, 240)
playerPanel.Position = UDim2.new(0, 20, 1, -260)
playerPanel.BackgroundColor3 = C_BG
playerPanel.BackgroundTransparency = 0.3
playerPanel.BorderSizePixel = 0
playerPanel.Parent = gui
corner(playerPanel, 8)
stroke(playerPanel, C_CYAN, 1, 0.4)

local playerTitle = Instance.new("TextLabel")
playerTitle.Size = UDim2.new(1, -10, 0, 18)
playerTitle.Position = UDim2.new(0, 8, 0, 4)
playerTitle.BackgroundTransparency = 1
playerTitle.Text = "▸ PLAYERS"
playerTitle.TextColor3 = C_CYAN
playerTitle.TextSize = 11
playerTitle.Font = Enum.Font.GothamBold
playerTitle.TextXAlignment = Enum.TextXAlignment.Left
playerTitle.Parent = playerPanel

local playerScroll = Instance.new("ScrollingFrame")
playerScroll.Size = UDim2.new(1, -10, 1, -26)
playerScroll.Position = UDim2.new(0, 5, 0, 22)
playerScroll.BackgroundTransparency = 1
playerScroll.BorderSizePixel = 0
playerScroll.ScrollBarThickness = 3
playerScroll.ScrollBarImageColor3 = C_CYAN
playerScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
playerScroll.Parent = playerPanel

local plLayout = Instance.new("UIListLayout")
plLayout.Padding = UDim.new(0, 2)
plLayout.Parent = playerScroll
plLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    playerScroll.CanvasSize = UDim2.new(0, 0, 0, plLayout.AbsoluteContentSize.Y + 4)
end)

local function makePlayerRow(target)
    if target == plr then return end

    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 26)
    row.BackgroundColor3 = C_PANEL
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.Parent = playerScroll
    corner(row, 4)
    stroke(row, C_CYAN, 1, 0.7)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1, -60, 1, 0)
    nameLbl.Position = UDim2.new(0, 6, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = target.DisplayName
    nameLbl.TextColor3 = C_CYAN2
    nameLbl.TextSize = 10
    nameLbl.Font = Enum.Font.Code
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    nameLbl.Parent = row

    local espBtn = Instance.new("TextButton")
    espBtn.Size = UDim2.new(0, 24, 0, 20)
    espBtn.Position = UDim2.new(1, -52, 0.5, -10)
    espBtn.BackgroundColor3 = C_BG
    espBtn.BackgroundTransparency = 0.3
    espBtn.Text = "◉"
    espBtn.TextColor3 = C_CYAN
    espBtn.TextSize = 12
    espBtn.Font = Enum.Font.GothamBold
    espBtn.BorderSizePixel = 0
    espBtn.AutoButtonColor = false
    espBtn.Parent = row
    corner(espBtn, 4)
    local espStroke = Instance.new("UIStroke")
    espStroke.Color = C_CYAN
    espStroke.Thickness = 1
    espStroke.Transparency = 0.5
    espStroke.Parent = espBtn

    local tpBtn = Instance.new("TextButton")
    tpBtn.Size = UDim2.new(0, 24, 0, 20)
    tpBtn.Position = UDim2.new(1, -26, 0.5, -10)
    tpBtn.BackgroundColor3 = C_BG
    tpBtn.BackgroundTransparency = 0.3
    tpBtn.Text = "➤"
    tpBtn.TextColor3 = C_CYAN
    tpBtn.TextSize = 11
    tpBtn.Font = Enum.Font.GothamBold
    tpBtn.BorderSizePixel = 0
    tpBtn.AutoButtonColor = false
    tpBtn.Parent = row
    corner(tpBtn, 4)
    local tpStroke = Instance.new("UIStroke")
    tpStroke.Color = C_CYAN
    tpStroke.Thickness = 1
    tpStroke.Transparency = 0.5
    tpStroke.Parent = tpBtn

    bindClick(espBtn, function()
        toggleESPFor(target)
        if espSelected[target] then
            espBtn.BackgroundColor3 = C_CYAN
            espBtn.TextColor3 = C_BG
            espStroke.Color = C_WHITE
            nameLbl.TextColor3 = C_WHITE
            row.BackgroundColor3 = C_CYAN2
            row.BackgroundTransparency = 0.5
        else
            espBtn.BackgroundColor3 = C_BG
            espBtn.TextColor3 = C_CYAN
            espStroke.Color = C_CYAN
            nameLbl.TextColor3 = C_CYAN2
            row.BackgroundColor3 = C_PANEL
            row.BackgroundTransparency = 0.3
        end
    end)

    bindClick(tpBtn, function()
        local myChar = plr.Character
        if not myChar then return end
        local myHrp = myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end
        local tChar = target.Character
        if not tChar then return end
        local tHrp = tChar:FindFirstChild("HumanoidRootPart")
        if not tHrp then return end
        myHrp.CFrame = tHrp.CFrame * CFrame.new(0, 0, 3)
    end)

    target.CharacterAdded:Connect(function()
        task.wait(1)
        if espSelected[target] then
            removeESP(target)
            createESP(target)
        end
    end)
end

for _, p in ipairs(Players:GetPlayers()) do
    makePlayerRow(p)
end

Players.PlayerAdded:Connect(function(p)
    task.wait(0.5)
    makePlayerRow(p)
end)

Players.PlayerRemoving:Connect(function(p)
    removeESP(p)
    espSelected[p] = nil
end)

print("[JARVIS] プレイヤーリスト 作成完了")

------------------------------------------------------------
-- 開閉
------------------------------------------------------------
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        hud.Visible = not hud.Visible
        statusPanel.Visible = hud.Visible
        clockPanel.Visible = hud.Visible
        playerPanel.Visible = hud.Visible
    end
end)

print("[JARVIS] 起動完了 - 右Shiftで開閉")
