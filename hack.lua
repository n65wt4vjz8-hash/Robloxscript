--[[ hack.lua - 完全版（ハブ開閉トグル付き・音なし） ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local plr = Players.LocalPlayer
local cam = workspace.CurrentCamera
local PlayerGui = plr:WaitForChild("PlayerGui")

local function getGuiParent()
    local ok = pcall(function()
        local t = Instance.new("ScreenGui")
        t.Parent = CoreGui
        t:Destroy()
    end)
    if ok then return CoreGui end
    return PlayerGui
end
local guiParent = getGuiParent()

local C_GREEN  = Color3.fromRGB(0, 255, 100)
local C_GREEN2 = Color3.fromRGB(0, 180, 70)
local C_CYAN   = Color3.fromRGB(0, 255, 255)
local C_RED    = Color3.fromRGB(255, 60, 80)
local C_YELLOW = Color3.fromRGB(255, 220, 60)
local C_PURPLE = Color3.fromRGB(180, 80, 255)
local C_BG     = Color3.fromRGB(0, 3, 0)
local C_PANEL  = Color3.fromRGB(0, 8, 3)
local C_LINE   = Color3.fromRGB(0, 60, 30)

local authed = false
local selectedPlayers = {}
local playerButtons = {}
local espData = {}
local fpsValue = 60
local msValue = 16.7
local fpsTimer = 0
local frameCount = 0
local defaultFOV = cam.FieldOfView
local currentFOV = defaultFOV
local flyEnabled = false
local flySpeed = 80
local speedEnabled = false
local speedValue = 16
local jumpEnabled = false
local jumpValue = 50
local infJumpEnabled = false
local fullbrightEnabled = false
local noFogEnabled = false
local tracerEnabled = false

-- ANTI設定
local antiKickEnabled = false
local antiFlingEnabled = false
local antiVoidEnabled = false
local antiTeleportEnabled = false
local antiAnchorEnabled = false
local antiGrabEnabled = false
local protectionCount = 0
local lastResetTime = 0
local lastPosition = nil
local lastCFrame = nil
local antiConns = {}

local originalLighting = {
    Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness, FogStart = Lighting.FogStart, FogEnd = Lighting.FogEnd,
}
local tracers = {}

local function addTerminalCorners(parent, color, size, zindex)
    size = size or 10; color = color or C_GREEN; zindex = zindex or 11
    local positions = {{0,0,1,1},{1,0,-1,1},{0,1,1,-1},{1,1,-1,-1}}
    for _, pos in ipairs(positions) do
        local h = Instance.new("Frame")
        h.Size = UDim2.new(0, size, 0, 2)
        h.Position = UDim2.new(pos[1], pos[3] == 1 and 0 or -size, pos[2], pos[4] == 1 and 0 or -2)
        h.BackgroundColor3 = color; h.BorderSizePixel = 0; h.ZIndex = zindex; h.Parent = parent
        local v = Instance.new("Frame")
        v.Size = UDim2.new(0, 2, 0, size)
        v.Position = UDim2.new(pos[1], pos[3] == 1 and 0 or -2, pos[2], pos[4] == 1 and 0 or -size)
        v.BackgroundColor3 = color; v.BorderSizePixel = 0; v.ZIndex = zindex; v.Parent = parent
    end
end

local function addTerminalGrid(parent, cell, transparency, color, zindex)
    cell = cell or 12; transparency = transparency or 0.9; color = color or C_LINE; zindex = zindex or 1
    task.spawn(function()
        task.wait(0.1)
        local w = parent.AbsoluteSize.X; local h = parent.AbsoluteSize.Y
        if w <= 0 or h <= 0 then return end
        for x = 0, w, cell do
            local line = Instance.new("Frame")
            line.Size = UDim2.new(0, 1, 1, 0); line.Position = UDim2.new(0, x, 0, 0)
            line.BackgroundColor3 = color; line.BackgroundTransparency = transparency
            line.BorderSizePixel = 0; line.ZIndex = zindex; line.Parent = parent
        end
        for y = 0, h, cell do
            local line = Instance.new("Frame")
            line.Size = UDim2.new(1, 0, 0, 1); line.Position = UDim2.new(0, 0, 0, y)
            line.BackgroundColor3 = color; line.BackgroundTransparency = transparency
            line.BorderSizePixel = 0; line.ZIndex = zindex; line.Parent = parent
        end
    end)
end

local function bindClick(btn, callback)
    local lastClick = 0
    local function tryClick()
        local now = tick()
        if now - lastClick < 0.2 then return end
        lastClick = now; callback()
    end
    btn.MouseButton1Click:Connect(tryClick)
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then tryClick() end
    end)
end

local function makeDraggable(frame, dragBar)
    dragBar = dragBar or frame
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    dragBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
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
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

RunService.RenderStepped:Connect(function(dt)
    frameCount = frameCount + 1; fpsTimer = fpsTimer + dt
    if fpsTimer >= 0.5 then
        fpsValue = math.floor(frameCount / fpsTimer)
        msValue = (fpsTimer / frameCount) * 1000
        frameCount = 0; fpsTimer = 0
    end
end)

------------------------------------------------------------
-- ANTI 機能
------------------------------------------------------------
local function startAntiKick()
    if antiConns.kick then return end
    antiConns.kick = RunService.Heartbeat:Connect(function()
        if not antiKickEnabled then return end
        local char = plr.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local speed = hrp.AssemblyLinearVelocity.Magnitude
        if speed > 200 then
            local now = tick()
            if now - lastResetTime > 0.5 then
                lastResetTime = now
                protectionCount = protectionCount + 1
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end)
end

local function startAntiFling()
    if antiConns.fling then return end
    antiConns.fling = RunService.Heartbeat:Connect(function()
        if not antiFlingEnabled then return end
        local char = plr.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local vel = hrp.AssemblyLinearVelocity.Magnitude
        local angVel = hrp.AssemblyAngularVelocity.Magnitude
        if vel > 300 or angVel > 50 then
            local now = tick()
            if now - lastResetTime > 0.3 then
                lastResetTime = now
                protectionCount = protectionCount + 1
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end)
end

local function startAntiVoid()
    if antiConns.void then return end
    antiConns.void = RunService.Heartbeat:Connect(function()
        if not antiVoidEnabled then return end
        local char = plr.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        if hrp.Position.Y < -50 then
            local now = tick()
            if now - lastResetTime > 1 then
                lastResetTime = now
                protectionCount = protectionCount + 1
                hrp.CFrame = CFrame.new(0, 50, 0)
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end)
end

local function startAntiTeleport()
    if antiConns.tp then return end
    local char = plr.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then lastCFrame = hrp.CFrame end
    end
    antiConns.tp = RunService.Heartbeat:Connect(function()
        if not antiTeleportEnabled then return end
        local c = plr.Character; if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        if lastCFrame then
            local dist = (hrp.Position - lastCFrame.Position).Magnitude
            if dist > 25 then
                protectionCount = protectionCount + 1
                hrp.CFrame = lastCFrame
                hrp.AssemblyLinearVelocity = Vector3.zero
                return
            end
        end
        lastCFrame = hrp.CFrame
    end)
end

local function startAntiAnchor()
    if antiConns.anchor then return end
    antiConns.anchor = RunService.Heartbeat:Connect(function()
        if not antiAnchorEnabled then return end
        local c = plr.Character; if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        if hrp.Anchored then
            hrp.Anchored = false
            protectionCount = protectionCount + 1
        end
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then
            if hum.PlatformStand and not flyEnabled then
                hum.PlatformStand = false
                protectionCount = protectionCount + 1
            end
        end
    end)
end

local function startAntiGrab()
    if antiConns.grab then return end
    antiConns.grab = RunService.Heartbeat:Connect(function()
        if not antiGrabEnabled then return end
        local c = plr.Character; if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return end

        for _, obj in ipairs(hrp:GetChildren()) do
            if obj:IsA("Weld") or obj:IsA("WeldConstraint") or obj:IsA("Motor6D") then
                local p0 = obj.Part0
                local p1 = obj.Part1
                local p0Mine = p0 and p0:IsDescendantOf(c)
                local p1Mine = p1 and p1:IsDescendantOf(c)
                if not (p0Mine and p1Mine) then
                    obj:Destroy()
                    protectionCount = protectionCount + 1
                end
            end
        end

        for _, obj in ipairs(hrp:GetChildren()) do
            if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition")
                or obj:IsA("BodyGyro") or obj:IsA("BodyThrust")
                or obj:IsA("BodyAngularVelocity") or obj:IsA("BodyForce") then
                if obj ~= flyBV and obj ~= flyBG then
                    obj:Destroy()
                    protectionCount = protectionCount + 1
                end
            end
        end

        for _, part in ipairs(c:GetDescendants()) do
            if part:IsA("BasePart") then
                for _, obj in ipairs(part:GetChildren()) do
                    if obj:IsA("Weld") or obj:IsA("WeldConstraint") then
                        local p0 = obj.Part0
                        local p1 = obj.Part1
                        local p0Mine = p0 and p0:IsDescendantOf(c)
                        local p1Mine = p1 and p1:IsDescendantOf(c)
                        if not (p0Mine and p1Mine) then
                            obj:Destroy()
                            protectionCount = protectionCount + 1
                        end
                    end
                end
            end
        end

        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then
            local state = hum:GetState()
            if state == Enum.HumanoidStateType.FallingDown
                or state == Enum.HumanoidStateType.Ragdoll then
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                protectionCount = protectionCount + 1
            end
        end
    end)
end

------------------------------------------------------------
-- 移動機能
------------------------------------------------------------
local flyBV, flyBG, flyConn
local function startFly()
    local char = plr.Character; if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    flyEnabled = true; hum.PlatformStand = true
    flyBV = Instance.new("BodyVelocity"); flyBV.MaxForce = Vector3.new(1e5,1e5,1e5)
    flyBV.Velocity = Vector3.zero; flyBV.Parent = hrp
    flyBG = Instance.new("BodyGyro"); flyBG.MaxTorque = Vector3.new(1e5,1e5,1e5)
    flyBG.P = 1e4; flyBG.CFrame = hrp.CFrame; flyBG.Parent = hrp
    flyConn = RunService.RenderStepped:Connect(function()
        if not flyEnabled or not hrp or not hrp.Parent then return end
        local moveDir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir -= Vector3.new(0,1,0) end
        flyBV.Velocity = moveDir.Magnitude > 0 and (moveDir.Unit * flySpeed) or Vector3.zero
        flyBG.CFrame = cam.CFrame
    end)
end
local function stopFly()
    flyEnabled = false
    if flyConn then flyConn:Disconnect() end
    if flyBV then flyBV:Destroy() end
    if flyBG then flyBG:Destroy() end
    local char = plr.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end
local function applySpeed()
    local char = plr.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = speedEnabled and speedValue or 16 end
end
local function applyJump()
    local char = plr.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.JumpPower = jumpEnabled and jumpValue or 50 end
end
UIS.JumpRequest:Connect(function()
    if not infJumpEnabled then return end
    local char = plr.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

local function applyFullbright()
    if fullbrightEnabled then
        Lighting.Ambient = Color3.fromRGB(200,200,200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200,200,200)
        Lighting.Brightness = 3
    else
        Lighting.Ambient = originalLighting.Ambient
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        Lighting.Brightness = originalLighting.Brightness
    end
end
local function applyNoFog()
    if noFogEnabled then
        Lighting.FogEnd = math.huge; Lighting.FogStart = math.huge
    else
        Lighting.FogStart = originalLighting.FogStart; Lighting.FogEnd = originalLighting.FogEnd
    end
end
local function updateTracers()
    if not tracerEnabled then
        for _, t in pairs(tracers) do if t.line and t.line.Parent then t.line:Destroy() end end
        tracers = {}; return
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= plr then
            local c = p.Character
            if c then
                local hrp = c:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local line = tracers[p]
                    if not line or not line.line or not line.line.Parent then
                        local l = Instance.new("Part"); l.Anchored = true; l.CanCollide = false
                        l.CastShadow = false; l.Material = Enum.Material.Neon
                        l.Color = C_RED; l.Transparency = 0.3; l.Parent = workspace
                        tracers[p] = {line = l}; line = tracers[p]
                    end
                    local from = cam.CFrame.Position - Vector3.new(0,2,0)
                    local to = hrp.Position
                    line.line.Size = Vector3.new(0.1,0.1,(to-from).Magnitude)
                    line.line.CFrame = CFrame.new(from, to) * CFrame.Angles(math.pi/2,0,0)
                end
            end
        end
    end
end
RunService.RenderStepped:Connect(updateTracers)

local function makeToggle(parent, text, yPos, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -12, 0, 24); row.Position = UDim2.new(0, 6, 0, yPos)
    row.BackgroundColor3 = Color3.fromRGB(0,10,3); row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0; row.ZIndex = 12; row.Parent = parent
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 2)
    local stroke = Instance.new("UIStroke"); stroke.Thickness = 1
    stroke.Color = C_GREEN2; stroke.Transparency = 0.5; stroke.Parent = row
    local statusBar = Instance.new("Frame"); statusBar.Size = UDim2.new(0,3,1,0)
    statusBar.Position = UDim2.new(0,0,0,0); statusBar.BackgroundColor3 = C_GREEN2
    statusBar.BorderSizePixel = 0; statusBar.ZIndex = 13; statusBar.Parent = row
    local state = false
    local promptLbl = Instance.new("TextLabel")
    promptLbl.Size = UDim2.new(0,10,1,0); promptLbl.Position = UDim2.new(0,8,0,0)
    promptLbl.BackgroundTransparency = 1; promptLbl.Text = ">"
    promptLbl.TextColor3 = C_GREEN; promptLbl.TextSize = 10
    promptLbl.Font = Enum.Font.Code; promptLbl.TextXAlignment = Enum.TextXAlignment.Left
    promptLbl.ZIndex = 13; promptLbl.Parent = row
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-60,1,0); lbl.Position = UDim2.new(0,22,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = C_GREEN
    lbl.TextSize = 10; lbl.Font = Enum.Font.Code
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 13; lbl.Parent = row
    local statusLbl = Instance.new("TextLabel")
    statusLbl.Size = UDim2.new(0,46,1,0); statusLbl.Position = UDim2.new(1,-48,0,0)
    statusLbl.BackgroundTransparency = 1; statusLbl.Text = "[OFF]"
    statusLbl.TextColor3 = C_GREEN2; statusLbl.TextSize = 9
    statusLbl.Font = Enum.Font.Code; statusLbl.TextXAlignment = Enum.TextXAlignment.Right
    statusLbl.ZIndex = 13; statusLbl.Parent = row
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1,0,1,0); clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""; clickBtn.ZIndex = 14; clickBtn.Parent = row
    bindClick(clickBtn, function()
        state = not state
        if state then
            statusBar.BackgroundColor3 = C_GREEN; stroke.Color = C_GREEN
            stroke.Transparency = 0.1; lbl.TextColor3 = C_GREEN
            promptLbl.TextColor3 = C_GREEN
            statusLbl.Text = "[ ON]"; statusLbl.TextColor3 = C_GREEN
        else
            statusBar.BackgroundColor3 = C_GREEN2; stroke.Color = C_GREEN2
            stroke.Transparency = 0.5; lbl.TextColor3 = C_GREEN
            promptLbl.TextColor3 = C_GREEN2
            statusLbl.Text = "[OFF]"; statusLbl.TextColor3 = C_GREEN2
        end
        callback(state)
    end)
end

local scrollFrameRef
local function buildPlayerSelectGui(parent)
    local panel = Instance.new("Frame")
    panel.Size = UDim2.new(1,-12,1,-12); panel.Position = UDim2.new(0,6,0,6)
    panel.BackgroundTransparency = 1; panel.ZIndex = 10; panel.Parent = parent
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1,0,1,0); scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0; scrollFrame.ScrollBarThickness = 3
    scrollFrame.ScrollBarImageColor3 = C_GREEN; scrollFrame.CanvasSize = UDim2.new(0,0,0,0)
    scrollFrame.ZIndex = 11; scrollFrame.Parent = panel
    local scrollLayout = Instance.new("UIListLayout")
    scrollLayout.Padding = UDim.new(0,2); scrollLayout.SortOrder = Enum.SortOrder.Name
    scrollLayout.Parent = scrollFrame
    scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0,0,0,scrollLayout.AbsoluteContentSize.Y + 6)
    end)
    scrollFrameRef = scrollFrame
end

local function makePlayerButton(targetPlayer)
    if targetPlayer == plr then return end
    if playerButtons[targetPlayer] then return end
    if not scrollFrameRef then return end
    local btn = Instance.new("Frame")
    btn.Size = UDim2.new(1,-4,0,22); btn.BackgroundColor3 = Color3.fromRGB(0,10,3)
    btn.BackgroundTransparency = 0.3; btn.BorderSizePixel = 0
    btn.ZIndex = 11; btn.Parent = scrollFrameRef
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,2)
    local stroke = Instance.new("UIStroke"); stroke.Thickness = 1
    stroke.Color = C_GREEN2; stroke.Transparency = 0.5; stroke.Parent = btn
    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0,5,0,5); statusDot.Position = UDim2.new(0,6,0.5,-2.5)
    statusDot.BackgroundColor3 = C_GREEN2; statusDot.BorderSizePixel = 0
    statusDot.ZIndex = 12; statusDot.Parent = btn
    Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1,0)
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Size = UDim2.new(1,-50,1,0); nameLbl.Position = UDim2.new(0,16,0,0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = string.upper(targetPlayer.DisplayName)
    nameLbl.TextColor3 = C_GREEN; nameLbl.TextSize = 10
    nameLbl.Font = Enum.Font.Code; nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    nameLbl.ZIndex = 12; nameLbl.Parent = btn
    local tpBtn = Instance.new("TextButton")
    tpBtn.Size = UDim2.new(0,26,0,16); tpBtn.Position = UDim2.new(1,-30,0.5,-8)
    tpBtn.BackgroundColor3 = Color3.fromRGB(0,30,15); tpBtn.BackgroundTransparency = 0.3
    tpBtn.Text = "TP"; tpBtn.TextColor3 = C_GREEN; tpBtn.TextSize = 9
    tpBtn.Font = Enum.Font.Code; tpBtn.BorderSizePixel = 0
    tpBtn.ZIndex = 14; tpBtn.Parent = btn
    Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0,2)
    local tpStroke = Instance.new("UIStroke"); tpStroke.Thickness = 1
    tpStroke.Color = C_GREEN; tpStroke.Transparency = 0.4; tpStroke.Parent = tpBtn
    bindClick(tpBtn, function()
        local myChar = plr.Character; if not myChar then return end
        local myHrp = myChar:FindFirstChild("HumanoidRootPart"); if not myHrp then return end
        local targetChar = targetPlayer.Character; if not targetChar then return end
        local targetHrp = targetChar:FindFirstChild("HumanoidRootPart"); if not targetHrp then return end
        local offset = -targetHrp.CFrame.LookVector * 3
        myHrp.CFrame = targetHrp.CFrame + offset + Vector3.new(0,1,0)
        tpBtn.TextColor3 = C_CYAN; tpStroke.Color = C_CYAN
        task.wait(0.3)
        if tpBtn and tpBtn.Parent then tpBtn.TextColor3 = C_GREEN; tpStroke.Color = C_GREEN end
    end)
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1,-30,1,0); clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""; clickBtn.ZIndex = 13; clickBtn.Parent = btn
    bindClick(clickBtn, function()
        selectedPlayers[targetPlayer] = not selectedPlayers[targetPlayer]
        if selectedPlayers[targetPlayer] then
            statusDot.BackgroundColor3 = C_CYAN; stroke.Color = C_GREEN
            stroke.Transparency = 0.1; nameLbl.TextColor3 = C_CYAN
            btn.BackgroundColor3 = Color3.fromRGB(0,20,10)
        else
            statusDot.BackgroundColor3 = C_GREEN2; stroke.Color = C_GREEN2
            stroke.Transparency = 0.5; nameLbl.TextColor3 = C_GREEN
            btn.BackgroundColor3 = Color3.fromRGB(0,10,3)
        end
    end)
    playerButtons[targetPlayer] = {btn = btn, statusDot = statusDot, stroke = stroke, nameLbl = nameLbl}
end

local function removePlayerButton(targetPlayer)
    if playerButtons[targetPlayer] then
        local b = playerButtons[targetPlayer]
        if b.btn and b.btn.Parent then b.btn:Destroy() end
        playerButtons[targetPlayer] = nil
    end
end

local function createESP(targetPlayer)
    if targetPlayer == plr then return end
    if espData[targetPlayer] then return end
    local char = targetPlayer.Character; if not char then return end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = C_GREEN; highlight.OutlineColor = C_CYAN
    highlight.FillTransparency = 0.6; highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = char; highlight.Enabled = false; highlight.Parent = char
    local head = char:FindFirstChild("Head"); local bb
    if head then
        bb = Instance.new("BillboardGui")
        bb.Size = UDim2.new(0,220,0,60); bb.StudsOffset = Vector3.new(0,3.5,0)
        bb.AlwaysOnTop = true; bb.MaxDistance = math.huge
        bb.Enabled = false; bb.Parent = head
        local p2 = Instance.new("Frame")
        p2.Size = UDim2.new(1,0,1,0); p2.BackgroundColor3 = Color3.fromRGB(0,5,2)
        p2.BackgroundTransparency = 0.3; p2.BorderSizePixel = 0; p2.Parent = bb
        Instance.new("UICorner", p2).CornerRadius = UDim.new(0,2)
        local s2 = Instance.new("UIStroke"); s2.Thickness = 1
        s2.Color = C_GREEN; s2.Transparency = 0.3; s2.Parent = p2
        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1,-8,0,22); nameLbl.Position = UDim2.new(0,4,0,4)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = "> " .. string.upper(targetPlayer.DisplayName)
        nameLbl.TextColor3 = C_GREEN; nameLbl.TextSize = 13
        nameLbl.Font = Enum.Font.Code
        nameLbl.TextXAlignment = Enum.TextXAlignment.Center; nameLbl.Parent = p2
        local distLbl = Instance.new("TextLabel")
        distLbl.Size = UDim2.new(1,-8,0,14); distLbl.Position = UDim2.new(0,4,0,28)
        distLbl.BackgroundTransparency = 1; distLbl.Text = "DIST: 0.0m"
        distLbl.TextColor3 = C_GREEN2; distLbl.TextSize = 10
        distLbl.Font = Enum.Font.Code
        distLbl.TextXAlignment = Enum.TextXAlignment.Center; distLbl.Parent = p2
        local hpBg = Instance.new("Frame")
        hpBg.Size = UDim2.new(1,-8,0,4); hpBg.Position = UDim2.new(0,4,1,-7)
        hpBg.BackgroundColor3 = Color3.fromRGB(0,10,3); hpBg.BorderSizePixel = 0; hpBg.Parent = p2
        local hpFill = Instance.new("Frame")
        hpFill.Size = UDim2.new(1,0,1,0); hpFill.BackgroundColor3 = C_GREEN
        hpFill.BorderSizePixel = 0; hpFill.Parent = hpBg
        espData[targetPlayer] = {highlight = highlight, billboard = bb, distLbl = distLbl, hpFill = hpFill}
    else
        espData[targetPlayer] = {highlight = highlight}
    end
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not targetPlayer or not targetPlayer.Parent then
            if conn then conn:Disconnect() end; return
        end
        local data = espData[targetPlayer]; if not data then return end
        local isSelected = selectedPlayers[targetPlayer] == true
        if data.highlight then data.highlight.Enabled = isSelected end
        if data.billboard then data.billboard.Enabled = isSelected end
        if not isSelected then return end
        local c = targetPlayer.Character; if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local myChar = plr.Character; if not myChar then return end
        local myHrp = myChar:FindFirstChild("HumanoidRootPart"); if not myHrp then return end
        local dist = (hrp.Position - myHrp.Position).Magnitude
        if data.distLbl then
            data.distLbl.Text = string.format("DIST: %.1fm", dist)
            if dist < 30 then
                data.distLbl.TextColor3 = C_RED
                if data.highlight then data.highlight.FillColor = C_RED; data.highlight.OutlineColor = C_RED end
            elseif dist < 100 then
                data.distLbl.TextColor3 = C_YELLOW
                if data.highlight then data.highlight.FillColor = C_YELLOW; data.highlight.OutlineColor = C_YELLOW end
            else
                data.distLbl.TextColor
