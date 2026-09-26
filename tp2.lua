local player=game.Players.LocalPlayer
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name=tostring(math.random(100000,999999))
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
title.Text="TP Step"
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
local distLabel=Instance.new("TextLabel")
distLabel.Size=UDim2.new(0.4,0,0,24)
distLabel.Position=UDim2.new(0.3,0,0.28,0)
distLabel.BackgroundTransparency=1
distLabel.Text="Dist: 2"
distLabel.TextColor3=Color3.fromRGB(200,220,255)
distLabel.Font=Enum.Font.GothamBold
distLabel.TextSize=12
distLabel.Parent=frame
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
local tpBtn=Instance.new("TextButton")
tpBtn.Size=UDim2.new(0.9,0,0,40)
tpBtn.Position=UDim2.new(0.05,0,0.58,0)
tpBtn.BackgroundColor3=Color3.fromRGB(50,90,150)
tpBtn.Text="TP +2"
tpBtn.TextColor3=Color3.fromRGB(255,255,255)
tpBtn.Font=Enum.Font.GothamBold
tpBtn.TextSize=16
tpBtn.Parent=frame
local tbc=Instance.new("UICorner")
tbc.CornerRadius=UDim.new(0,8)
tbc.Parent=tpBtn
local distance=2
local function tpForward()
    local char=player.Character
    if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dir=hrp.CFrame.LookVector
    hrp.CFrame=hrp.CFrame+dir*distance
end
tpBtn.MouseButton1Click:Connect(function()
    tpForward()
    tpBtn.Text="TP!"
    task.wait(0.15)
    tpBtn.Text="TP +"..distance
end)
minusBtn.MouseButton1Click:Connect(function()
    distance=math.max(1,distance-1)
    distLabel.Text="Dist: "..distance
    tpBtn.Text="TP +"..distance
end)
plusBtn.MouseButton1Click:Connect(function()
    distance=math.min(50,distance+1)
    distLabel.Text="Dist: "..distance
    tpBtn.Text="TP +"..distance
end)
