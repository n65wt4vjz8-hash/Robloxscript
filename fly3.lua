
local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaFly3"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,180,0,90)
frame.Position=UDim2.new(0.05,0,0.3,0)
frame.BackgroundColor3=Color3.fromRGB(20,20,25)
frame.BorderSizePixel=0
frame.Active=true
frame.Draggable=true
frame.Parent=gui
local fc=Instance.new("UICorner")
fc.CornerRadius=UDim.new(0,10)
fc.Parent=frame
local normalSize=UDim2.new(0,180,0,90)
local minimized=false
local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,26)
title.BackgroundColor3=Color3.fromRGB(35,35,45)
title.BorderSizePixel=0
title.Text="Fly"
title.TextColor3=Color3.fromRGB(255,255,255)
title.Font=Enum.Font.GothamBold
title.TextSize=14
title.Parent=frame
local tc=Instance.new("UICorner")
tc.CornerRadius=UDim.new(0,10)
tc.Parent=title
local minBtn=Instance.new("TextButton")
minBtn.Size=UDim2.new(0,24,0,24)
minBtn.Position=UDim2.new(1,-56,0,1)
minBtn.BackgroundColor3=Color3.fromRGB(80,80,100)
minBtn.Text="−"
minBtn.TextColor3=Color3.fromRGB(255,255,255)
minBtn.Font=Enum.Font.GothamBold
minBtn.TextSize=16
minBtn.Parent=title
local mc2=Instance.new("UICorner")
mc2.CornerRadius=UDim.new(0,6)
mc2.Parent=minBtn
local closeBtn=Instance.new("TextButton")
closeBtn.Size=UDim2.new(0,24,0,24)
closeBtn.Position=UDim2.new(1,-28,0,1)
closeBtn.BackgroundColor3=Color3.fromRGB(180,50,50)
closeBtn.Text="×"
closeBtn.TextColor3=Color3.fromRGB(255,255,255)
closeBtn.Font=Enum.Font.GothamBold
closeBtn.TextSize=16
closeBtn.Parent=title
local cc=Instance.new("UICorner")
cc.CornerRadius=UDim.new(0,6)
cc.Parent=closeBtn
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0.9,0,0,32)
btn.Position=UDim2.new(0.05,0,0.38,0)
btn.BackgroundColor3=Color3.fromRGB(60,60,70)
btn.Text="Fly: OFF"
btn.TextColor3=Color3.fromRGB(255,255,255)
btn.Font=Enum.Font.GothamBold
btn.TextSize=14
btn.Parent=frame
local bc=Instance.new("UICorner")
bc.CornerRadius=UDim.new(0,6)
bc.Parent=btn
local lbl=Instance.new("TextLabel")
lbl.Size=UDim2.new(0.5,0,0,22)
lbl.Position=UDim2.new(0.25,0,0.72,0)
lbl.BackgroundTransparency=1
lbl.Text="Speed: 1"
lbl.TextColor3=Color3.fromRGB(200,220,255)
lbl.Font=Enum.Font.GothamBold
lbl.TextSize=11
lbl.Parent=frame
local minus=Instance.new("TextButton")
minus.Size=UDim2.new(0.18,0,0,22)
minus.Position=UDim2.new(0.05,0,0.72,0)
minus.BackgroundColor3=Color3.fromRGB(70,50,50)
minus.Text="−"
minus.TextColor3=Color3.fromRGB(255,255,255)
minus.Font=Enum.Font.GothamBold
minus.TextSize=14
minus.Parent=frame
local mc=Instance.new("UICorner")
mc.CornerRadius=UDim.new(0,6)
mc.Parent=minus
local plus=Instance.new("TextButton")
plus.Size=UDim2.new(0.18,0,0,22)
plus.Position=UDim2.new(0.77,0,0.72,0)
plus.BackgroundColor3=Color3.fromRGB(50,70,50)
plus.Text="＋"
plus.TextColor3=Color3.fromRGB(255,255,255)
plus.Font=Enum.Font.GothamBold
plus.TextSize=12
plus.Parent=frame
local pc=Instance.new("UICorner")
pc.CornerRadius=UDim.new(0,6)
pc.Parent=plus
minBtn.MouseButton1Click:Connect(function()
    minimized=not minimized
    if minimized then
        frame.Size=UDim2.new(0,180,0,26)
        minBtn.Text="＋"
    else
        frame.Size=normalSize
        minBtn.Text="−"
    end
end)
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)
local flying=false
local speed=1
local conn
local function startFly()
    if flying then return end
    flying=true
    conn=RS.RenderStepped:Connect(function()
        if not flying then return end
        local c=player.Character
        if not c then return end
        local h=c:FindFirstChild("HumanoidRootPart")
        if not h then return end
        local cam=workspace.CurrentCamera
        local look=cam.CFrame.LookVector
        if look.Magnitude>0 then
            h.CFrame=h.CFrame+look.Unit*speed
        end
    end)
    btn.Text="Fly: ON"
    btn.BackgroundColor3=Color3.fromRGB(0,150,80)
end
local function stopFly()
    if not flying then return end
    flying=false
    if conn then conn:Disconnect() conn=nil end
    btn.Text="Fly: OFF"
    btn.BackgroundColor3=Color3.fromRGB(60,60,70)
end
minus.MouseButton1Click:Connect(function()
    speed=math.max(0.5,speed-0.5)
    lbl.Text="Speed: "..speed
end)
plus.MouseButton1Click:Connect(function()
    speed=math.min(20,speed+0.5)
    lbl.Text="Speed: "..speed
end)
btn.MouseButton1Click:Connect(function()
    if flying then stopFly() else startFly() end
end)
player.CharacterAdded:Connect(function()
    if flying then stopFly() end
end)
