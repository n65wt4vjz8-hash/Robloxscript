local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaThrow"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,180,0,140)
frame.Position=UDim2.new(0.05,0,0.4,0)
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
title.Text="Throw"
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
toggleBtn.Size=UDim2.new(0.9,0,0,28)
toggleBtn.Position=UDim2.new(0.05,0,0.2,0)
toggleBtn.BackgroundColor3=Color3.fromRGB(60,60,70)
toggleBtn.Text="THROW: OFF"
toggleBtn.TextColor3=Color3.fromRGB(255,255,255)
toggleBtn.Font=Enum.Font.GothamBold
toggleBtn.TextSize=12
toggleBtn.Parent=frame
local tbc=Instance.new("UICorner")
tbc.CornerRadius=UDim.new(0,6)
tbc.Parent=toggleBtn
local speedLabel=Instance.new("TextLabel")
speedLabel.Size=UDim2.new(0.5,0,0,28)
speedLabel.Position=UDim2.new(0.25,0,0.55,0)
speedLabel.BackgroundTransparency=1
speedLabel.Text="Speed: 100"
speedLabel.TextColor3=Color3.fromRGB(200,220,255)
speedLabel.Font=Enum.Font.GothamBold
speedLabel.TextSize=12
speedLabel.Parent=frame
local minusBtn=Instance.new("TextButton")
minusBtn.Size=UDim2.new(0.18,0,0,28)
minusBtn.Position=UDim2.new(0.05,0,0.55,0)
minusBtn.BackgroundColor3=Color3.fromRGB(70,50,50)
minusBtn.Text="−"
minusBtn.TextColor3=Color3.fromRGB(255,255,255)
minusBtn.Font=Enum.Font.GothamBold
minusBtn.TextSize=18
minusBtn.Parent=frame
local mbc=Instance.new("UICorner")
mbc.CornerRadius=UDim.new(0,6)
mbc.Parent=minusBtn
local plusBtn=Instance.new("TextButton")
plusBtn.Size=UDim2.new(0.18,0,0,28)
plusBtn.Position=UDim2.new(0.77,0,0.55,0)
plusBtn.BackgroundColor3=Color3.fromRGB(50,70,50)
plusBtn.Text="＋"
plusBtn.TextColor3=Color3.fromRGB(255,255,255)
plusBtn.Font=Enum.Font.GothamBold
plusBtn.TextSize=16
plusBtn.Parent=frame
local pbc=Instance.new("UICorner")
pbc.CornerRadius=UDim.new(0,6)
pbc.Parent=plusBtn
local resetBtn=Instance.new("TextButton")
resetBtn.Size=UDim2.new(0.9,0,0,22)
resetBtn.Position=UDim2.new(0.05,0,0.82,0)
resetBtn.BackgroundColor3=Color3.fromRGB(45,45,55)
resetBtn.Text="Reset (100)"
resetBtn.TextColor3=Color3.fromRGB(220,220,220)
resetBtn.Font=Enum.Font.Gotham
resetBtn.TextSize=10
resetBtn.Parent=frame
local rbc=Instance.new("UICorner")
rbc.CornerRadius=UDim.new(0,6)
rbc.Parent=resetBtn
local enabled=false
local speed=100
local thrown={}
local function applyToPart(part)
    if not part:IsA("BasePart") then return end
    if part.Anchored then return end
    if thrown[part] then return end
    if part.Velocity.Magnitude<10 then return end
    local char=player.Character
    if char and part:IsDescendantOf(char) then return end
    thrown[part]=true
    local dir=part.Velocity.Unit
    local bf=Instance.new("BodyForce")
    bf.Force=Vector3.new(0,workspace.Gravity*part:GetMass(),0)
    bf.Parent=part
    local bv=Instance.new("BodyVelocity")
    bv.MaxForce=Vector3.new(1e5,1e5,1e5)
    bv.Velocity=dir*speed
    bv.Parent=part
    task.spawn(function()
        task.wait(3)
        if bf and bf.Parent then bf:Destroy() end
        if bv and bv.Parent then bv:Destroy() end
    end)
end
RS.Heartbeat:Connect(function()
    if not enabled then return end
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            applyToPart(obj)
        end
    end
end)
toggleBtn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        toggleBtn.Text="THROW: ON"
        toggleBtn.BackgroundColor3=Color3.fromRGB(0,150,80)
    else
        toggleBtn.Text="THROW: OFF"
        toggleBtn.BackgroundColor3=Color3.fromRGB(60,60,70)
        thrown={}
    end
end)
minusBtn.MouseButton1Click:Connect(function()
    speed=math.max(10,speed-10)
    speedLabel.Text="Speed: "..speed
end)
plusBtn.MouseButton1Click:Connect(function()
    speed=math.min(1000,speed+10)
    speedLabel.Text="Speed: "..speed
end)
resetBtn.MouseButton1Click:Connect(function()
    speed=100
    speedLabel.Text="Speed: "..speed
end)
player.CharacterAdded:Connect(function()
    if enabled then
        enabled=false
        toggleBtn.Text="THROW: OFF"
        toggleBtn.BackgroundColor3=Color3.fromRGB(60,60,70)
        thrown={}
    end
end)
