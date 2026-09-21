local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaTpme"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,180,0,130)
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
title.Text="TP Me"
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
btn.Size=UDim2.new(0.9,0,0,32)
btn.Position=UDim2.new(0.05,0,0.24,0)
btn.BackgroundColor3=Color3.fromRGB(60,60,70)
btn.Text="TP: OFF"
btn.TextColor3=Color3.fromRGB(255,255,255)
btn.Font=Enum.Font.GothamBold
btn.TextSize=14
btn.Parent=frame
local bc=Instance.new("UICorner")
bc.CornerRadius=UDim.new(0,6)
bc.Parent=btn
local lbl=Instance.new("TextLabel")
lbl.Size=UDim2.new(0.5,0,0,26)
lbl.Position=UDim2.new(0.25,0,0.55,0)
lbl.BackgroundTransparency=1
lbl.Text="Power: 25"
lbl.TextColor3=Color3.fromRGB(200,220,255)
lbl.Font=Enum.Font.GothamBold
lbl.TextSize=12
lbl.Parent=frame
local minus=Instance.new("TextButton")
minus.Size=UDim2.new(0.18,0,0,26)
minus.Position=UDim2.new(0.05,0,0.55,0)
minus.BackgroundColor3=Color3.fromRGB(70,50,50)
minus.Text="−"
minus.TextColor3=Color3.fromRGB(255,255,255)
minus.Font=Enum.Font.GothamBold
minus.TextSize=16
minus.Parent=frame
local mc=Instance.new("UICorner")
mc.CornerRadius=UDim.new(0,6)
mc.Parent=minus
local plus=Instance.new("TextButton")
plus.Size=UDim2.new(0.18,0,0,26)
plus.Position=UDim2.new(0.77,0,0.55,0)
plus.BackgroundColor3=Color3.fromRGB(50,70,50)
plus.Text="＋"
plus.TextColor3=Color3.fromRGB(255,255,255)
plus.Font=Enum.Font.GothamBold
plus.TextSize=14
plus.Parent=frame
local pc=Instance.new("UICorner")
pc.CornerRadius=UDim.new(0,6)
pc.Parent=plus
local reset=Instance.new("TextButton")
reset.Size=UDim2.new(0.9,0,0,22)
reset.Position=UDim2.new(0.05,0,0.78,0)
reset.BackgroundColor3=Color3.fromRGB(45,45,55)
reset.Text="Reset"
reset.TextColor3=Color3.fromRGB(220,220,220)
reset.Font=Enum.Font.Gotham
reset.TextSize=11
reset.Parent=frame
local rc=Instance.new("UICorner")
rc.CornerRadius=UDim.new(0,6)
rc.Parent=reset
local enabled=false
local power=25
local toggle=1
local conn
local function start()
    if conn then return end
    conn=RS.RenderStepped:Connect(function()
        if not enabled then return end
        local char=player.Character
        if not char then return end
        local hrp=char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local right=hrp.CFrame.RightVector
        hrp.CFrame=hrp.CFrame+right*power*toggle
        toggle=-toggle
    end)
end
local function stop()
    if conn then conn:Disconnect() conn=nil end
    toggle=1
end
btn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        btn.Text="TP: ON"
        btn.BackgroundColor3=Color3.fromRGB(0,150,80)
        start()
    else
        btn.Text="TP: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
        stop()
    end
end)
minus.MouseButton1Click:Connect(function()
    power=math.max(1,power-1)
    lbl.Text="Power: "..power
end)
plus.MouseButton1Click:Connect(function()
    power=math.min(200,power+1)
    lbl.Text="Power: "..power
end)
reset.MouseButton1Click:Connect(function()
    power=25
    lbl.Text="Power: "..power
end)
player.CharacterAdded:Connect(function()
    if enabled then
        enabled=false
        btn.Text="TP: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
        stop()
    end
end)
