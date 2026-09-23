local player=game.Players.LocalPlayer
local CG=game:GetService("CoreGui")
local UIS=game:GetService("UserInputService")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaSpd"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,200,0,140)
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
title.Text="Speed"
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
toggleBtn.Text="SPD: OFF"
toggleBtn.TextColor3=Color3.fromRGB(255,255,255)
toggleBtn.Font=Enum.Font.GothamBold
toggleBtn.TextSize=12
toggleBtn.Parent=frame
local tbc=Instance.new("UICorner")
tbc.CornerRadius=UDim.new(0,6)
tbc.Parent=toggleBtn
local speedLabel=Instance.new("TextLabel")
speedLabel.Size=UDim2.new(1,0,0,20)
speedLabel.Position=UDim2.new(0,0,0.5,0)
speedLabel.BackgroundTransparency=1
speedLabel.Text="Speed: 16"
speedLabel.TextColor3=Color3.fromRGB(200,220,255)
speedLabel.Font=Enum.Font.GothamBold
speedLabel.TextSize=12
speedLabel.Parent=frame
local barBg=Instance.new("Frame")
barBg.Size=UDim2.new(0.85,0,0,10)
barBg.Position=UDim2.new(0.075,0,0.75,0)
barBg.BackgroundColor3=Color3.fromRGB(40,40,55)
barBg.BorderSizePixel=0
barBg.Parent=frame
local bbc=Instance.new("UICorner")
bbc.CornerRadius=UDim.new(1,0)
bbc.Parent=barBg
local fill=Instance.new("Frame")
fill.Size=UDim2.new(0.03,0,1,0)
fill.BackgroundColor3=Color3.fromRGB(120,80,255)
fill.BorderSizePixel=0
fill.Parent=barBg
local fgc=Instance.new("UICorner")
fgc.CornerRadius=UDim.new(1,0)
fgc.Parent=fill
local knob=Instance.new("TextButton")
knob.Size=UDim2.new(0,24,0,24)
knob.Position=UDim2.new(0.03,-12,-0.7,0)
knob.BackgroundColor3=Color3.fromRGB(180,150,255)
knob.Text=""
knob.AutoButtonColor=false
knob.Parent=barBg
local kc=Instance.new("UICorner")
kc.CornerRadius=UDim.new(1,0)
kc.Parent=knob
local stroke=Instance.new("UIStroke")
stroke.Color=Color3.fromRGB(255,255,255)
stroke.Thickness=2
stroke.Parent=knob
local enabled=false
local minSpeed=1
local maxSpeed=500
local currentSpeed=16
local dragging=false
local function applySpeed()
    local char=player.Character
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if enabled then
        hum.WalkSpeed=currentSpeed
    else
        hum.WalkSpeed=16
    end
end
local function updateSpeed(percent)
    percent=math.clamp(percent,0,1)
    local spd=math.floor(minSpeed+(maxSpeed-minSpeed)*percent+0.5)
    currentSpeed=spd
    speedLabel.Text="Speed: "..spd
    fill.Size=UDim2.new(percent,0,1,0)
    knob.Position=UDim2.new(percent,-12,-0.7,0)
    applySpeed()
end
local function getPercentFromX(x)
    local pos=barBg.AbsolutePosition.X
    local size=barBg.AbsoluteSize.X
    return (x-pos)/size
end
knob.MouseButton1Down:Connect(function()
    dragging=true
end)
knob.MouseButton1Up:Connect(function()
    dragging=false
end)
UIS.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
        updateSpeed(getPercentFromX(input.Position.X))
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=false
    end
end)
barBg.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        updateSpeed(getPercentFromX(input.Position.X))
        dragging=true
    end
end)
toggleBtn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        toggleBtn.Text="SPD: ON"
        toggleBtn.BackgroundColor3=Color3.fromRGB(0,150,80)
    else
        toggleBtn.Text="SPD: OFF"
        toggleBtn.BackgroundColor3=Color3.fromRGB(60,60,70)
    end
    applySpeed()
end)
updateSpeed(0.03)
player.CharacterAdded:Connect(function()
    task.wait(1)
    applySpeed()
end)
