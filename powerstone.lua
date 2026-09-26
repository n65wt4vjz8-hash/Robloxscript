local player=game.Players.LocalPlayer
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaPowerStone"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,180,0,120)
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
title.Text="Power Stone"
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
local powerLabel=Instance.new("TextLabel")
powerLabel.Size=UDim2.new(0.4,0,0,24)
powerLabel.Position=UDim2.new(0.3,0,0.28,0)
powerLabel.BackgroundTransparency=1
powerLabel.Text="Power: 300"
powerLabel.TextColor3=Color3.fromRGB(200,220,255)
powerLabel.Font=Enum.Font.GothamBold
powerLabel.TextSize=12
powerLabel.Parent=frame
local minusBtn=Instance.new("TextButton")
minusBtn.Size=UDim2.new(0.18,0,0,24)
minusBtn.Position=UDim2.new(0.1,0,0.28,0)
minusBtn.BackgroundColor3=Color3.fromRGB(70,50,50)
minusBtn.Text="−"
minusBtn.TextColor3=Color3.fromRGB(255,255,255)
minusBtn.Font=Enum.Font.GothamBold
minusBtn.TextSize=16
minusBtn.Parent=frame
local mbc=Instance.new("UICorner")
mbc.CornerRadius=UDim.new(0,6)
mbc.Parent=minusBtn
local plusBtn=Instance.new("TextButton")
plusBtn.Size=UDim2.new(0.18,0,0,24)
plusBtn.Position=UDim2.new(0.72,0,0.28,0)
plusBtn.BackgroundColor3=Color3.fromRGB(50,70,50)
plusBtn.Text="＋"
plusBtn.TextColor3=Color3.fromRGB(255,255,255)
plusBtn.Font=Enum.Font.GothamBold
plusBtn.TextSize=12
plusBtn.Parent=frame
local pbc=Instance.new("UICorner")
pbc.CornerRadius=UDim.new(0,6)
pbc.Parent=plusBtn
local fireBtn=Instance.new("TextButton")
fireBtn.Size=UDim2.new(0.9,0,0,40)
fireBtn.Position=UDim2.new(0.05,0,0.58,0)
fireBtn.BackgroundColor3=Color3.fromRGB(120,50,50)
fireBtn.Text="LAUNCH!"
fireBtn.TextColor3=Color3.fromRGB(255,255,255)
fireBtn.Font=Enum.Font.GothamBold
fireBtn.TextSize=16
fireBtn.Parent=frame
local fbc=Instance.new("UICorner")
fbc.CornerRadius=UDim.new(0,8)
fbc.Parent=fireBtn
local power=300
local function launch(pl)
    if not pl then return end
    local char=pl.Character
    if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local bv=Instance.new("BodyVelocity")
    bv.MaxForce=Vector3.new(1e5,1e6,1e5)
    bv.Velocity=Vector3.new(
        math.random(-30,30),
        power,
        math.random(-30,30)
    )
    bv.Parent=hrp
    local bg=Instance.new("BodyGyro")
    bg.MaxTorque=Vector3.new(1e5,1e5,1e5)
    bg.P=1e4
    bg.CFrame=hrp.CFrame*CFrame.Angles(math.random()*6,math.random()*6,math.random()*6)
    bg.Parent=hrp
    game:GetService("Debris"):AddItem(bv,0.5)
    game:GetService("Debris"):AddItem(bg,0.5)
end
fireBtn.MouseButton1Click:Connect(function()
    fireBtn.Text="LAUNCHING..."
    for _,pl in ipairs(game.Players:GetPlayers()) do
        if pl~=player then
            pcall(function()
                launch(pl)
            end)
        end
    end
    task.wait(0.5)
    fireBtn.Text="LAUNCH!"
end)
minusBtn.MouseButton1Click:Connect(function()
    power=math.max(50,power-50)
    powerLabel.Text="Power: "..power
end)
plusBtn.MouseButton1Click:Connect(function()
    power=math.min(2000,power+50)
    powerLabel.Text="Power: "..power
end)
