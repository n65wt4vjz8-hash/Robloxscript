local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local plr = Players.LocalPlayer
local PlayerGui = plr:WaitForChild("PlayerGui")
local cam = workspace.CurrentCamera

local CY = Color3.fromRGB(0, 220, 255)
local CY2 = Color3.fromRGB(0, 150, 200)
local CY3 = Color3.fromRGB(0, 90, 140)
local BG = Color3.fromRGB(0, 10, 20)
local BG2 = Color3.fromRGB(0, 20, 40)
local WH = Color3.fromRGB(220, 245, 255)
local RD = Color3.fromRGB(255, 60, 60)

local F = {fly=false, speed=false, jump=false, bright=false, noclip=false, infjump=false, nofog=false, fps=false}

local espData = {}
local espSelected = {}
local fpsValue = 60
local msValue = 16.7
local fpsTimer = 0
local frameCount = 0

local origLight = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    FogStart = Lighting.FogStart,
    FogEnd = Lighting.FogEnd,
}

local function cnr(o, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = o
end

local function strk(o, c, t, tr)
    local s = Instance.new("UIStroke")
    s.Color = c
    s.Thickness = t or 1
    s.Transparency = tr or 0.3
    s.Parent = o
end

local function clk(b, cb)
    local last = 0
    local function go()
        local now = tick()
        if now - last < 0.25 then return end
        last = now
        cb()
    end
    b.MouseButton1Click:Connect(go)
    b.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then go() end
    end)
end

local flyBV, flyBG, flyC

local function startFly()
    local c = plr.Character
    if not c then return end
    local h = c:FindFirstChild("HumanoidRootPart")
    local u = c:FindFirstChildOfClass("Humanoid")
    if not h or not u then return end
    u.PlatformStand = true
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e5,1e5,1e5)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = h
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e5,1e5,1e5)
    flyBG.P = 1e4
    flyBG.CFrame = h.CFrame
    flyBG.Parent = h
    flyC = RunService.RenderStepped:Connect(function()
        if not F.fly or not h.Parent then return end
        local d = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then d += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then d -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then d -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then d += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then d += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d -= Vector3.new(0,1,0) end
        flyBV.Velocity = d.Magnitude > 0 and d.Unit * 100 or Vector3.zero
        flyBG.CFrame = cam.CFrame
    end)
end

local function stopFly()
    if flyC then flyC:Disconnect() flyC = nil end
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
    local c = plr.Character
    if c then
        local u = c:FindFirstChildOfClass("Humanoid")
        if u then u.PlatformStand = false end
    end
end

local function applySpeed()
    local c = plr.Character
    if not c then return end
    local u = c:FindFirstChildOfClass("Humanoid")
    if u then u.WalkSpeed = F.speed and 60 or 16 end
end

local function applyJump()
    local c = plr.Character
    if not c then return end
    local u = c:FindFirstChildOfClass("Humanoid")
    if u then u.JumpPower = F.jump and 120 or 50 end
end

local function applyBright()
    if F.bright then
        Lighting.Ambient = Color3.fromRGB(200,200,200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200,200,200)
        Lighting.Brightness = 3
    else
        Lighting.Ambient = origLight.Ambient
        Lighting.OutdoorAmbient = origLight.OutdoorAmbient
        Lighting.Brightness = origLight.Brightness
    end
end

local function applyNoFog()
    if F.nofog then
        Lighting.FogStart = math.huge
        Lighting.FogEnd = math.huge
    else
        Lighting.FogStart = origLight.FogStart
        Lighting.FogEnd = origLight.FogEnd
    end
end

local ncC

local function startNoclip()
    if ncC then return end
    ncC = RunService.Stepped:Connect(function()
        if not F.noclip then return end
        local c = plr.Character
        if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end

UIS.JumpRequest:Connect(function()
    if not F.infjump then return end
    local c = plr.Character
    if not c then return end
    local u = c:FindFirstChildOfClass("Humanoid")
    if u then u:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

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

local function createESP(target)
    if target == plr then return end
    if espData[target] then return end
    local c = target.Character
    if not c then return end
    local h = c:FindFirstChild("HumanoidRootPart")
    if not h then return end
    local hl = Instance.new("Highlight")
    hl.FillColor = CY
    hl.OutlineColor = WH
    hl.FillTransparency = 0.6
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = c
    hl.Parent = c
    local head = c:FindFirstChild("Head")
    local bb
    if head then
        bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0, 160, 0, 44)
        bb.StudsOffset = Vector3.new(0, 3, 0)
        bb.AlwaysOnTop = true
        bb.Parent = head
        local nm = Instance.new("TextLabel")
        nm.Size = UDim2.new(1, 0, 0, 20)
        nm.BackgroundTransparency = 1
        nm.Text = string.upper(target.DisplayName)
        nm.TextColor3 = WH
        nm.TextSize = 13
        nm.Font = Enum.Font.Code
        nm.TextStrokeTransparency = 0
        nm.TextStrokeColor3 = CY3
        nm.Parent = bb
        local d = Instance.new("TextLabel")
        d.Size = UDim2.new(1, 0, 0, 14)
        d.Position = UDim2.new(0, 0, 0, 22)
        d.BackgroundTransparency = 1
        d.Text = "0m"
        d.TextColor3 = CY
        d.TextSize = 11
        d.Font = Enum.Font.Code
        d.TextStrokeTransparency = 0
        d.TextStrokeColor3 = BG
        d.Parent = bb
        espData[target] = {hl = hl, bb = bb, dist = d}
    else
        espData[target] = {hl = hl}
    end
    local conn = RunService.Heartbeat:Connect(function()
        if not target.Parent then conn:Disconnect() return end
        local data = espData[target]
        if not data then return end
        local tc = target.Character
        if not tc then return end
        local th = tc:FindFirstChild("HumanoidRootPart")
        if not th then return end
        local mc = plr.Character
        if not mc then return end
        local mh = mc:FindFirstChild("HumanoidRootPart")
        if not mh then return end
        if data.dist then
            data.dist.Text = string.format("%.0fm", (th.Position - mh.Position).Magnitude)
        end
    end)
    espData[target].conn = conn
end

local function removeESP(target)
    if espData[target] then
        local d = espData[target]
        if d.hl and d.hl.Parent then d.hl:Destroy() end
        if d.bb and d.bb.Parent then d.bb:Destroy() end
        if d.conn then d.conn:Disconnect() end
        espData[target] = nil
    end
end

local function toggleESP(target)
    if espSelected[target] then
        espSelected[target] = nil
        removeESP(target)
    else
        espSelected[target] = true
        createESP(target)
    end
end

local function tpToPlayer(target)
    local mc = plr.Character
    if not mc then return end
    local mh = mc:FindFirstChild("HumanoidRootPart")
    if not mh then return end
    local tc = target.Character
    if not tc then return end
    local th = tc:FindFirstChild("HumanoidRootPart")
    if not th then return end
    mh.CFrame = th.CFrame * CFrame.new(0, 0, 3)
end

plr.CharacterAdded:Connect(function()
    task.wait(1)
    if F.speed then applySpeed() end
    if F.jump then applyJump() end
    if F.fly then stopFly() F.fly = false end
    if F.noclip then startNoclip() end
    for t, _ in pairs(espSelected) do
        task.wait(0.3)
        removeESP(t)
        createESP(t)
    end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "IronManHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 220, 0, 380)
main.Position = UDim2.new(0, 15, 0, 15)
main.BackgroundColor3 = BG
main.BackgroundTransparency = 0.15
main.BorderSizePixel = 0
main.Parent = gui
cnr(main, 4)
strk(main, CY, 1.5, 0.2)

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 28)
header.BackgroundColor3 = BG2
header.BackgroundTransparency = 0.2
header.BorderSizePixel = 0
header.Parent = main
cnr(header, 4)

local hfix = Instance.new("Frame")
hfix.Size = UDim2.new(1, 0, 0, 8)
hfix.Position = UDim2.new(0, 0, 1, -8)
hfix.BackgroundColor3 = BG2
hfix.BackgroundTransparency = 0.2
hfix.BorderSizePixel = 0
hfix.Parent = header

local hline = Instance.new("Frame")
hline.Size = UDim2.new(1, 0, 0, 1)
hline.Position = UDim2.new(0, 0, 1, -1)
hline.BackgroundColor3 = CY
hline.BackgroundTransparency = 0.3
hline.BorderSizePixel = 0
hline.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "» J.A.R.V.I.S."
title.TextColor3 = CY
title.TextSize = 12
title.Font = Enum.Font.Code
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 18, 0, 18)
closeBtn.Position = UDim2.new(1, -22, 0.5, -9)
closeBtn.BackgroundColor3 = RD
closeBtn.BackgroundTransparency = 0.3
closeBtn.Text = "×"
closeBtn.TextColor3 = WH
closeBtn.TextSize = 12
closeBtn.Font = Enum.Font.Code
closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = false
closeBtn.Parent = header
cnr(closeBtn, 9)

local arc = Instance.new("Frame")
arc.Size = UDim2.new(0, 70, 0, 70)
arc.Position = UDim2.new(0.5, -35, 0, 34)
arc.BackgroundColor3 = BG
arc.BackgroundTransparency = 0.4
arc.BorderSizePixel = 0
arc.Parent = main
cnr(arc, 35)
strk(arc, CY, 1.5, 0.3)

local core = Instance.new("Frame")
core.Size = UDim2.new(0, 24, 0, 24)
core.Position = UDim2.new(0.5, -12, 0.5, -12)
core.BackgroundColor3 = WH
core.BackgroundTransparency = 0.2
core.BorderSizePixel = 0
core.Parent = arc
cnr(core, 12)

local function rotRing(sz, col, sp, tr)
    local r = Instance.new("Frame")
    r.Size = UDim2.new(0, sz, 0, sz)
    r.Position = UDim2.new(0.5, -sz/2, 0.5, -sz/2)
    r.BackgroundTransparency = 1
    r.BorderSizePixel = 0
    r.Parent = arc
    cnr(r, sz/2)
    strk(r, col, 1, tr or 0.3)
    local rot = 0
    task.spawn(function()
        while r.Parent do
            rot = rot + sp * 0.02
            r.Rotation = rot
            task.wait(0.02)
        end
    end)
end
rotRing(80, CY, 2, 0.2)
rotRing(92, CY2, -1.5, 0.4)
rotRing(104, CY3, 1, 0.6)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -16, 1, -150)
scroll.Position = UDim2.new(0, 8, 0, 110)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = CY
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = main

local lay = Instance.new("UIListLayout")
lay.Padding = UDim.new(0, 4)
lay.Parent = scroll
lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 4)
end)

local function makeBtn(text, key, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 24)
    b.BackgroundColor3 = BG
    b.BackgroundTransparency = 0.3
    b.Text = "  " .. text
    b.TextColor3 = CY
    b.TextSize = 11
    b.Font = Enum.Font.Code
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = scroll
    cnr(b, 2)
    local st = strk(b, CY3, 1, 0.5)
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0, 40, 1, 0)
    status.Position = UDim2.new(1, -44, 0, 0)
    status.BackgroundTransparency = 1
    status.Text = "OFF"
    status.TextColor3 = RD
    status.TextSize = 10
    status.Font = Enum.Font.Code
    status.TextXAlignment = Enum.TextXAlignment.Right
    status.Parent = b
    local function update()
        if F[key] then
            b.BackgroundColor3 = CY2
            b.BackgroundTransparency = 0.5
            b.TextColor3 = WH
            st.Color = CY
            status.Text = "ON"
            status.TextColor3 = CY
        else
            b.BackgroundColor3 = BG
            b.BackgroundTransparency = 0.3
            b.TextColor3 = CY
            st.Color = CY3
            status.Text = "OFF"
            status.TextColor3 = RD
        end
    end
    clk(b, function()
        cb()
        update()
    end)
    update()
end

makeBtn("FLY", "fly", function()
    F.fly = not F.fly
    if F.fly then startFly() else stopFly() end
end)
makeBtn("SPEED", "speed", function()
    F.speed = not F.speed
    applySpeed()
end)
makeBtn("JUMP", "jump", function()
    F.jump = not F.jump
    applyJump()
end)
makeBtn("INF JUMP", "infjump", function()
    F.infjump = not F.infjump
end)
makeBtn("NOCLIP", "noclip", function()
    F.noclip = not F.noclip
    if F.noclip then startNoclip() end
end)
makeBtn("BRIGHT", "bright", function()
    F.bright = not F.bright
    applyBright()
end)
makeBtn("NO FOG", "nofog", function()
    F.nofog = not F.nofog
    applyNoFog()
end)

local plPanel = Instance.new("Frame")
plPanel.Size = UDim2.new(0, 240, 0, 340)
plPanel.Position = UDim2.new(1, -255, 0, 15)
plPanel.BackgroundColor3 = BG
plPanel.BackgroundTransparency = 0.15
plPanel.BorderSizePixel = 0
plPanel.Parent = gui
cnr(plPanel, 4)
strk(plPanel, CY, 1.5, 0.2)

local plH = Instance.new("Frame")
plH.Size = UDim2.new(1, 0, 0, 28)
plH.BackgroundColor3 = BG2
plH.BackgroundTransparency = 0.2
plH.BorderSizePixel = 0
plH.Parent = plPanel
cnr(plH, 4)

local plHFix = Instance.new("Frame")
plHFix.Size = UDim2.new(1, 0, 0, 8)
plHFix.Position = UDim2.new(0, 0, 1, -8)
plHFix.BackgroundColor3 = BG2
plHFix.BackgroundTransparency = 0.2
plHFix.BorderSizePixel = 0
plHFix.Parent = plH

local plHLine = Instance.new("Frame")
plHLine.Size = UDim2.new(1, 0, 0, 1)
plHLine.Position = UDim2.new(0, 0, 1, -1)
plHLine.BackgroundColor3 = CY
plHLine.BackgroundTransparency = 0.3
plHLine.BorderSizePixel = 0
plHLine.Parent = plH

local plTitle = Instance.new("TextLabel")
plTitle.Size = UDim2.new(1, -12, 1, 0)
plTitle.Position = UDim2.new(0, 12, 0, 0)
plTitle.BackgroundTransparency = 1
plTitle.Text = "» TARGETS"
plTitle.TextColor3 = CY
plTitle.TextSize = 12
plTitle.Font = Enum.Font.Code
plTitle.TextXAlignment = Enum.TextXAlignment.Left
plTitle.Parent = plH

local plScroll = Instance.new("ScrollingFrame")
plScroll.Size = UDim2.new(1, -16, 1, -42)
plScroll.Position = UDim2.new(0, 8, 0, 34)
plScroll.BackgroundTransparency = 1
plScroll.BorderSizePixel = 0
plScroll.ScrollBarThickness = 3
plScroll.ScrollBarImageColor3 = CY
plScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
plScroll.Parent = plPanel

local plLay = Instance.new("UIListLayout")
plLay.Padding = UDim.new(0, 4)
plLay.Parent = plScroll
plLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    plScroll.CanvasSize = UDim2.new(0, 0, 0, plLay.AbsoluteContentSize.Y + 4)
end)

local rowData = {}

local function makeRow(target)
    if target == plr then return end
    if rowData[target] then return end
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -4, 0, 26)
    row.BackgroundColor3 = BG
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.Parent = plScroll
    cnr(row, 2)
    local rowStroke = strk(row, CY3, 1, 0.5)
    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, -64, 1, 0)
    name.Position = UDim2.new(0, 8, 0, 0)
    name.BackgroundTransparency = 1
    name.Text = target.DisplayName
    name.TextColor3 = CY
    name.TextSize = 11
    name.Font = Enum.Font.Code
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.TextTruncate = Enum.TextTruncate.AtEnd
    name.Parent = row
    local espB = Instance.new("TextButton")
    espB.Size = UDim2.new(0, 26, 0, 20)
    espB.Position = UDim2.new(1, -56, 0.5, -10)
    espB.BackgroundColor3 = BG
    espB.BackgroundTransparency = 0.3
    espB.Text = "◉"
    espB.TextColor3 = CY
    espB.TextSize = 12
    espB.Font = Enum.Font.Code
    espB.BorderSizePixel = 0
    espB.AutoButtonColor = false
    espB.Parent = row
    cnr(espB, 2)
    local espBS = strk(espB, CY3, 1, 0.5)
    local tpB = Instance.new("TextButton")
    tpB.Size = UDim2.new(0, 26, 0, 20)
    tpB.Position = UDim2.new(1, -28, 0.5, -10)
    tpB.BackgroundColor3 = BG
    tpB.BackgroundTransparency = 0.3
    tpB.Text = "»"
    tpB.TextColor3 = CY
    tpB.TextSize = 12
    tpB.Font = Enum.Font.Code
    tpB.BorderSizePixel = 0
    tpB.AutoButtonColor = false
    tpB.Parent = row
    cnr(tpB, 2)
    local tpBS = strk(tpB, CY3, 1, 0.5)
    local function updateRow()
        if espSelected[target] then
            espB.BackgroundColor3 = CY2
            espB.TextColor3 = WH
            espBS.Color = CY
            name.TextColor3 = WH
            row.BackgroundColor3 = CY3
            row.BackgroundTransparency = 0.5
            rowStroke.Color = CY
        else
            espB.BackgroundColor3 = BG
            espB.TextColor3 = CY
            espBS.Color = CY3
            name.TextColor3 = CY
            row.BackgroundColor3 = BG
            row.BackgroundTransparency = 0.3
            rowStroke.Color = CY3
        end
    end
    clk(espB, function()
        toggleESP(target)
        updateRow()
    end)
    clk(tpB, function()
        tpToPlayer(target)
    end)
    rowData[target] = {row = row, update = updateRow}
end

local function removeRow(target)
    if rowData[target] then
        rowData[target].row:Destroy()
        rowData[target] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    makeRow(p)
end
Players.PlayerAdded:Connect(function(p)
    task.wait(0.5)
    makeRow(p)
end)
Players.PlayerRemoving:Connect(function(p)
    removeESP(p)
    espSelected[p] = nil
    removeRow(p)
end)

local fpsPanel = Instance.new("Frame")
fpsPanel.Size = UDim2.new(0, 150, 0, 60)
fpsPanel.Position = UDim2.new(1, -165, 0, 15)
fpsPanel.BackgroundColor3 = BG
fpsPanel.BackgroundTransparency = 0.15
fpsPanel.BorderSizePixel = 0
fpsPanel.Visible = false
fpsPanel.Parent = gui
cnr(fpsPanel, 4)
strk(fpsPanel, CY, 1.5, 0.2)

local fpsH = Instance.new("Frame")
fpsH.Size = UDim2.new(1, 0, 0, 20)
fpsH.BackgroundColor3 = BG2
fpsH.BackgroundTransparency = 0.2
fpsH.BorderSizePixel = 0
fpsH.Parent = fpsPanel
cnr(fpsH, 4)

local fpsHFix = Instance.new("Frame")
fpsHFix.Size = UDim2.new(1, 0, 0, 8)
fpsHFix.Position = UDim2.new(0, 0, 1, -8)
fpsHFix.BackgroundColor3 = BG2
fpsHFix.BackgroundTransparency = 0.2
fpsHFix.BorderSizePixel = 0
fpsHFix.Parent = fpsH

local fpsHLine = Instance.new("Frame")
fpsHLine.Size = UDim2.new(1, 0, 0, 1)
fpsHLine.Position = UDim2.new(0, 0, 1, -1)
fpsHLine.BackgroundColor3 = CY
fpsHLine.BackgroundTransparency = 0.3
fpsHLine.BorderSizePixel = 0
fpsHLine.Parent = fpsH

local fpsTitle = Instance.new("TextLabel")
fpsTitle.Size = UDim2.new(1, -8, 1, 0)
fpsTitle.Position = UDim2.new(0, 8, 0, 0)
fpsTitle.BackgroundTransparency = 1
fpsTitle.Text = "» FPS"
fpsTitle.TextColor3 = CY
fpsTitle.TextSize = 9
fpsTitle.Font = Enum.Font.Code
fpsTitle.TextXAlignment = Enum.TextXAlignment.Left
fpsTitle.Parent = fpsH

local fpsLbl = Instance.new("TextLabel")
fpsLbl.Size = UDim2.new(0, 65, 0, 16)
fpsLbl.Position = UDim2.new(0, 10, 0, 26)
fpsLbl.BackgroundTransparency = 1
fpsLbl.Text = "FPS 60"
fpsLbl.TextColor3 = CY
fpsLbl.TextSize = 12
fpsLbl.Font = Enum.Font.Code
fpsLbl.TextXAlignment = Enum.TextXAlignment.Left
fpsLbl.Parent = fpsPanel

local msLbl = Instance.new("TextLabel")
msLbl.Size = UDim2.new(0, 65, 0, 16)
msLbl.Position = UDim2.new(1, -75, 0, 26)
msLbl.BackgroundTransparency = 1
msLbl.Text = "MS 16.7"
msLbl.TextColor3 = WH
msLbl.TextSize = 12
msLbl.Font = Enum.Font.Code
msLbl.TextXAlignment = Enum.TextXAlignment.Right
msLbl.Parent = fpsPanel

task.spawn(function()
    while gui.Parent do
        task.wait(0.25)
        if F.fps then
            fpsLbl.Text = "FPS " .. fpsValue
            msLbl.Text = string.format("MS %.1f", msValue)
            if fpsValue < 30 then
                fpsLbl.TextColor3 = RD
            elseif fpsValue < 50 then
                fpsLbl.TextColor3 = Color3.fromRGB(255,200,0)
            else
                fpsLbl.TextColor3 = CY
            end
        end
    end
end)

makeBtn("FPS / MS", "fps", function()
    fpsPanel.Visible = F.fps
end)

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 45, 0, 45)
toggleBtn.Position = UDim2.new(0, 15, 0, 15)
toggleBtn.BackgroundColor3 = BG
toggleBtn.BackgroundTransparency = 0.15
toggleBtn.Text = "◉"
toggleBtn.TextColor3 = CY
toggleBtn.TextSize = 22
toggleBtn.Font = Enum.Font.Code
toggleBtn.BorderSizePixel = 0
toggleBtn.AutoButtonColor = false
toggleBtn.Visible = false
toggleBtn.Parent = gui
cnr(toggleBtn, 22)
strk(toggleBtn, CY, 2, 0.2)

local function setVis(v)
    main.Visible = v
    plPanel.Visible = v
    if v and F.fps then
        fpsPanel.Visible = true
    else
        fpsPanel.Visible = false
    end
    toggleBtn.Visible = not v
end

clk(closeBtn, function() setVis(false) end)
clk(toggleBtn, function() setVis(true) end)

local function makeDrag(handle, panel)
    local drag, dI, dS, sP = false, nil, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            dS = i.Position
            sP = panel.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            dI = i
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if i == dI and drag then
            local d = i.Position - dS
            panel.Position = UDim2.new(sP.X.Scale, sP.X.Offset + d.X, sP.Y.Scale, sP.Y.Offset + d.Y)
        end
    end)
end

makeDrag(header, main)
makeDrag(plH, plPanel)
makeDrag(fpsH, fpsPanel)

UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        setVis(not main.Visible)
    end
end)

print("[IRONMAN] OK")
