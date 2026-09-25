local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaAllSpin"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,200,0,160)
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
title.Text="All Spin (50)"
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
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0.9,0,0,26)
btn.Position=UDim2.new(0.05,0,0.18,0)
btn.BackgroundColor3=Color3.fromRGB(60,60,70)
btn.Text="SPIN: OFF"
btn.TextColor3=Color3.fromRGB(255,255,255)
btn.Font=Enum.Font.GothamBold
btn.TextSize=12
btn.Parent=frame
local bc=Instance.new("UICorner")
bc.CornerRadius=UDim.new(0,6)
bc.Parent=btn
local radiusLabel=Instance.new("TextLabel")
radiusLabel.Size=UDim2.new(0.4,0,0,22)
radiusLabel.Position=UDim2.new(0.3,0,0.42,0)
radiusLabel.BackgroundTransparency=1
radiusLabel.Text="SpinR: 50"
radiusLabel.TextColor3=Color3.fromRGB(200,220,255)
radiusLabel.Font=Enum.Font.GothamBold
radiusLabel.TextSize=11
radiusLabel.Parent=frame
local radiusMinus=Instance.new("TextButton")
radiusMinus.Size=UDim2.new(0.18,0,0,22)
radiusMinus.Position=UDim2.new(0.1,0,0.42,0)
radiusMinus.BackgroundColor3=Color3.fromRGB(70,50,50)
radiusMinus.Text="−"
radiusMinus.TextColor3=.FontColor3.fromRGB(255,255,255)
radiusMin=us.Font=Enum.Font.GothamBoldEnum
radiusMinus.TextSize=14
radius.FontMinus.Parent.G=frame
local rmc=Instance.new("othUICorner")
rmc.CornerRadius=UDim.new(0,6)
rmc.Parent=radiusMinus
local radiusPlus=Instance.new("TextButton")
radiusPlus.Size=UDim2.new(0.18,0,0,22)
radiusPlus.Position=UDim2.new(0.72,0,0.42,0)
radiusPlus.BackgroundColor3=Color3.fromRGB(50,70,50)
radiusPlus.Text="＋"
radiusPlus.TextColor3=Color3.fromRGB(255,255,255)
radiusPlusamBold
radiusPlus.TextSize=12
radiusPlus.Parent=frame
local rpc=Instance.new("UICorner")
rpc.CornerRadius=UDim.new(0,6)
rpc.Parent=radiusPlus
local speedLabel=Instance.new("TextLabel")
speedLabel.Size=UDim2.new(0.4,0,0,22)
speedLabel.Position=UDim2.new(0.3,0,0.65,0)
speedLabel.BackgroundTransparency=1
speedLabel.Text="Spd: 2"
speedLabel.TextColor3=Color3.fromRGB(200,220,255)
speedLabel.Font=Enum.Font.GothamBold
speedLabel.TextSize=11
speedLabel.Parent=frame
local speedMinus=Instance.new("TextButton")
speedMinus.Size=UDim2.new(0.18,0,0,22)
speedMinus.Position=UDim2.new(0.1,0,0.65,0)
speedMinus.BackgroundColor3=Color3.fromRGB(70,50,50)
speedMinus.Text="−"
speedMinus.TextColor3=Color3.fromRGB(255,255,255)
speedMinus.Font=Enum.Font.GothamBold
speedMinus.TextSize=14
speedMinus.Parent=frame
local smc=Instance.new("UICorner")
smc.CornerRadius=UDim.new(0,6)
smc.Parent=speedMinus
local speedPlus=Instance.new("TextButton")
speedPlus.Size=UDim2.new(0.18,0,0,22)
speedPlus.Position=UDim2.new(0.72,0,0.65,0)
speedPlus.BackgroundColor3=Color3.fromRGB(50,70,50)
speedPlus.Text="＋"
speedPlus.TextColor3=Color3.fromRGB(255,255,255)
speedPlus.Font=Enum.Font.GothamBold
speedPlus.TextSize=12
speedPlus.Parent=frame
local spc=Instance.new("UICorner")
spc.CornerRadius=UDim.new(0,6)
spc.Parent=speedPlus
local enabled=false
local detectRadius=50
local orbitRadius=50
local rotationSpeed=2
local angle=0
local lastTime=tick()
local cachedParts={}
local cacheTime=0
local function getHRP()
    local char=player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end
local function collectNearby()
    local hrp=getHRP()
    if not hrp then return {} end
    local center=hrp.Position
    local list={}
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local char=player.Character
            if not (char and obj:IsDescendantOf(char)) then
                local dist=(obj.Position-center).Magnitude
                if dist<detectRadius then
                    table.insert(list,obj)
                end
            end
        end
    end
    return list
end
local function arrange()
    local hrp=getHRP()
    if not hrp then return end
    local now=tick()
    local dt=now-lastTime
    lastTime=now
    angle=angle+dt*rotationSpeed*math.pi*2
    if angle>math.pi*2 then angle=angle-math.pi*2 end
    if now-cacheTime>0.5 then
        cachedParts=collectNearby()
        cacheTime=now
    end
    local items=cachedParts
    if #items==0 then return end
    local center=hrp.Position
    local total=#items
    for i,part in ipairs(items) do
        if part and part.Parent then
            local a=angle+(i/total)*math.pi*2
            local offset=Vector3.new(math.cos(a)*orbitRadius,0,math.sin(a)*orbitRadius)
            local targetPos=center+offset
            pcall(function()
                part.Anchored=false
                part.CFrame=CFrame.new(targetPos,center)
            end)
        end
    end
end
RS.Heartbeat:Connect(function()
    if not enabled then return end
    arrange()
end)
btn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        btn.Text="SPIN: ON"
        btn.BackgroundColor3=Color3.fromRGB(0,150,80)
        lastTime=tick()
        cachedParts=collectNearby()
        cacheTime=tick()
    else
        btn.Text="SPIN: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
    end
end)
radiusMinus.MouseButton1Click:Connect(function()
    detectRadius=math.max(5,detectRadius-5)
    orbitRadius=detectRadius
    radiusLabel.Text="SpinR: "..detectRadius
end)
radiusPlus.MouseButton1Click:Connect(function()
    detectRadius=math.min(200,detectRadius+5)
    orbitRadius=detectRadius
    radiusLabel.Text="SpinR: "..detectRadius
end)
speedMinus.MouseButton1Click:Connect(function()
    rotationSpeed=math.max(0.5,rotationSpeed-0.5)
    speedLabel.Text="Spd: "..rotationSpeed
end)
speedPlus.MouseButton1Click:Connect(function()
    rotationSpeed=math.min(20,rotationSpeed+0.5)
    speedLabel.Text="Spd: "..rotationSpeed
end)
player.CharacterAdded:Connect(function()
    if enabled then
        enabled=false
        btn.Text="SPIN: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
    end
end)
