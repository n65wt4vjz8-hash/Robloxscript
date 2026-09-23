local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local cam=workspace.CurrentCamera
local gui=Instance.new("ScreenGui")
gui.Name="DeltaBot"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,180,0,120)
frame.Position=UDim2.new(0.05,0,0.3,0)
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
title.Text="Camera Lock"
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
toggleBtn.Position=UDim2.new(0.05,0,0.28,0)
toggleBtn.BackgroundColor3=Color3.fromRGB(60,60,70)
toggleBtn.Text="BOT: OFF"
toggleBtn.TextColor3=Color3.fromRGB(255,255,255)
toggleBtn.Font=Enum.Font.GothamBold
toggleBtn.TextSize=14
toggleBtn.Parent=frame
local tbc=Instance.new("UICorner")
tbc.CornerRadius=UDim.new(0,6)
tbc.Parent=toggleBtn
local fovLabel=Instance.new("TextLabel")
fovLabel.Size=UDim2.new(0.5,0,0,24)
fovLabel.Position=UDim2.new(0.25,0,0.65,0)
fovLabel.BackgroundTransparency=1
fovLabel.Text="FOV: 200"
fovLabel.TextColor3=Color3.fromRGB(200,220,255)
fovLabel.Font=Enum.Font.GothamBold
fovLabel.TextSize=12
fovLabel.Parent=frame
local minusBtn=Instance.new("TextButton")
minusBtn.Size=UDim2.new(0.18,0,0,24)
minusBtn.Position=UDim2.new(0.05,0,0.65,0)
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
plusBtn.Position=UDim2.new(0.77,0,0.65,0)
plusBtn.BackgroundColor3=Color3.fromRGB(50,70,50)
plusBtn.Text="＋"
plusBtn.TextColor3=Color3.fromRGB(255,255,255)
plusBtn.Font=Enum.Font.GothamBold
plusBtn.TextSize=14
plusBtn.Parent=frame
local pbc=Instance.new("UICorner")
pbc.CornerRadius=UDim.new(0,6)
pbc.Parent=plusBtn
local enabled=false
local fov=200
local conn
local function getClosest()
    local closest=nil
    local shortest=fov
    local center=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/2)
    for _,p in ipairs(game.Players:GetPlayers()) do
        if p==player then continue end
        if not p.Character then continue end
        local hum=p.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health<=0 then continue end
        local hrp=p.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local sp,on=cam:WorldToViewportPoint(hrp.Position)
        if not on then continue end
        local d=(Vector2.new(sp.X,sp.Y)-center).Magnitude
        if d<shortest then
            shortest=d
            closest=hrp
        end
    end
    return closest
end
local function startLoop()
    if conn then return end
    conn=RS.RenderStepped:Connect(function()
        if not enabled then return end
        local t=getClosest()
        if t then
            cam.CFrame=CFrame.new(cam.CFrame.Position,t.Position)
        end
    end)
end
local function stopLoop()
    if conn then conn:Disconnect() conn=nil end
end
toggleBtn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        toggleBtn.Text="BOT: ON"
        toggleBtn.BackgroundColor3=Color3.fromRGB(0,150,80)
        startLoop()
    else
        toggleBtn.Text="BOT: OFF"
        toggleBtn.BackgroundColor3=Color3.fromRGB(60,60,70)
        stopLoop()
    end
end)
minusBtn.MouseButton1Click:Connect(function()
    fov=math.max(50,fov-50)
    fovLabel.Text="FOV: "..fov
end)
plusBtn.MouseButton1Click:Connect(function()
    fov=math.min(1000,fov+50)
    fovLabel.Text="FOV: "..fov
end)
player.CharacterAdded:Connect(function()
    if enabled then
        enabled=false
        toggleBtn.Text="BOT: OFF"
        toggleBtn.BackgroundColor3=Color3.fromRGB(60,60,70)
        stopLoop()
    end
end)
