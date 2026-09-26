local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")

local gui=Instance.new("ScreenGui")
gui.Name=tostring(math.random(100000,999999))
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end

local frame=Instance.new("Frame")
frame.Name=tostring(math.random(100000,999999))
frame.Size=UDim2.new(0,180,0,120)
frame.Position=UDim2.new(0.05,0,0.35,0)
frame.BackgroundColor3=Color3.fromRGB(20,20,25)
frame.BorderSizePixel=0
frame.Active=true
frame.Draggable=true
frame.Parent=gui
local fc=Instance.new("UICorner")
fc.CornerRadius=UDim.new(0,10)
fc.Parent=frame

local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,24)
title.BackgroundColor3=Color3.fromRGB(35,35,45)
title.BorderSizePixel=0
title.Text="Auto Parry (25)"
title.TextColor3=Color3.fromRGB(255,255,255)
title.Font=Enum.Font.GothamBold
title.TextSize=13
title.Parent=frame
local tc=Instance.new("UICorner")
tc.CornerRadius=UDim.new(0,10)
tc.Parent=title

local closeBtn=Instance.new("TextButton")
closeBtn.Size=UDim2.new(0,22,0,22)
closeBtn.Position=UDim2.new(1,-25,0,1)
closeBtn.BackgroundColor3=Color3.fromRGB(180,50,50)
closeBtn.Text="×"
closeBtn.TextColor3=Color3.fromRGB(255,255,255)
closeBtn.Font=Enum.Font.GothamBold
closeBtn.TextSize=14
closeBtn.Parent=title
local cc=Instance.new("UICorner")
cc.CornerRadius=UDim.new(0,5)
cc.Parent=closeBtn
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local toggleBtn=Instance.new("TextButton")
toggleBtn.Size=UDim2.new(0.9,0,0,32)
toggleBtn.Position=UDim2.new(0.05,0,0.25,0)
toggleBtn.BackgroundColor3=Color3.fromRGB(60,60,70)
toggleBtn.Text="PARRY: OFF"
toggleBtn.TextColor3=Color3.fromRGB(255,255,255)
toggleBtn.Font=Enum.Font.GothamBold
toggleBtn.TextSize=13
toggleBtn.Parent=frame
local tbc=Instance.new("UICorner")
tbc.CornerRadius=UDim.new(0,6)
tbc.Parent=toggleBtn

local statusLabel=Instance.new("TextLabel")
statusLabel.Size=UDim2.new(1,0,0,18)
statusLabel.Position=UDim2.new(0,0,0.65,0)
statusLabel.BackgroundTransparency=1
statusLabel.Text="Idle"
statusLabel.TextColor3=Color3.fromRGB(150,160,180)
statusLabel.Font=Enum.Font.GothamBold
statusLabel.TextSize=11
statusLabel.Parent=frame

local distLabel=Instance.new("TextLabel")
distLabel.Size=UDim2.new(1,0,0,18)
distLabel.Position=UDim2.new(0,0,0.85,0)
distLabel.BackgroundTransparency=1
distLabel.Text="Trigger: 25 studs"
distLabel.TextColor3=Color3.fromRGB(200,220,255)
distLabel.Font=Enum.Font.GothamBold
distLabel.TextSize=11
distLabel.Parent=frame

local enabled=false
local parryDist=25
local lastParry=0
local parryCooldown=0

local function getHRP()
    local char=player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function isTarget()
    local char=player.Character
    if not char then return false end
    for _,v in ipairs(char:GetChildren()) do
        if v:IsA("Highlight") then return true end
    end
    return false
end

local function getBalls()
    local balls={}
    for _,obj in ipairs(workspace:GetChildren()) do
        local n=obj.Name:lower()
        if n:find("ball") or n=="balls" then
            if obj:IsA("Folder") then
                for _,child in ipairs(obj:GetChildren()) do
                    table.insert(balls,child)
                end
            else
                table.insert(balls,obj)
            end
        end
    end
    return balls
end

local function simulateTap()
    pcall(function()
        if mouse1click then
            mouse1click()
        end
    end)
end

local conn=RS.Heartbeat:Connect(function()
    if not enabled then return end
    local now=tick()
    if parryCooldown>0 and now-lastParry<parryCooldown then return end
    local hrp=getHRP()
    if not hrp then return end
    if not isTarget() then
        statusLabel.Text="Id対le (not target)"
        return
   移動 end
    local balls=getBalls()
    if #balls==0 then
        statusLabel.Text="No balls"
        return
    end
    local closest=999
    local closestBall=nil
    for _,ball in ipairs(balls) do
        local pos=nil
        if ball:IsA("BasePart") then
            pos=ball.Position
        elseif ball:IsA("Model") then
            local part=ball:FindFirstChildWhichIsA("BasePart")
            if part then pos=part.Position end
        end
        if pos then
            local dist=(pos-hrp.Position).Magnitude
            if dist<closest then
                closest=dist
                closestBall=ball
            end
        end
    end
    statusLabel.Text="Dist: "..math.floor(closest)
    if closest<=parryDist and closestBall then
        statusLabel.Text="PARRY! ("..math.floor(closest)..")"
        simulateTap()
        lastParry=now
    end
end)

toggleBtn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        toggleBtn.Text="PARRY: ON"
        toggleBtn.BackgroundColor3=Color3.fromRGB(0,150,80)
        statusLabel.Text="Active"
    else
        toggleBtn.Text="PARRY: OFF"
        toggleBtn.BackgroundColor3=Color3.fromRGB(60,60,70)
        statusLabel.Text="Idle"
    end
end)

player.CharacterAdded:Connect(function()
    if enabled then
        enabled=false
        toggleBtn.Text="PARRY: OFF"
        toggleBtn.BackgroundColor3=Color3.fromRGB(60,60,70)
        statusLabel.Text="Idle"
    end
end)

warn("Auto Parry (mouse1click版) 起動")
