local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local cam=workspace.CurrentCamera
local gui=Instance.new("ScreenGui")
gui.Name="DeltaAimbot"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,200,0,120)
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
title.Size=UDim2.new(1,0,0,26)
title.BackgroundColor3=Color3.fromRGB(35,35,45)
title.BorderSizePixel=0
title.Text="Aimbot"
title.TextColor3=Color3.fromRGB(255,255,255)
title.Font=Enum.Font.GothamBold
title.TextSize=14
title.Parent=frame
local tc=Instance.new("UICorner")
tc.CornerRadius=UDim.new(0,10)
tc.Parent=title
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
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)
local toggle=Instance.new("TextButton")
toggle.Size=UDim2.new(0.9,0,0,32)
toggle.Position=UDim2.new(0.05,0,0.3,0)
toggle.BackgroundColor3=Color3.fromRGB(60,60,70)
toggle.Text="Aim: OFF"
toggle.TextColor3=Color3.fromRGB(255,255,255)
toggle.Font=Enum.Font.GothamBold
toggle.TextSize=14
toggle.Parent=frame
local tc2=Instance.new("UICorner")
tc2.CornerRadius=UDim.new(0,6)
tc2.Parent=toggle
local lbl=Instance.new("TextLabel")
lbl.Size=UDim2.new(1,0,0,22)
lbl.Position=UDim2.new(0,0,0.7,0)
lbl.BackgroundTransparency=1
lbl.Text="FOV: 200"
lbl.TextColor3=Color3.fromRGB(200,220,255)
lbl.Font=Enum.Font.GothamBold
lbl.TextSize=11
lbl.Parent=frame
local enabled=false
local fov=200
local target=nil
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
        local screenPos,onScreen=cam:WorldToViewportPoint(hrp.Position)
        if not onScreen then continue end
        local dist=(Vector2.new(screenPos.X,screenPos.Y)-center).Magnitude
        if dist<shortest then
            shortest=dist
            closest=hrp
        end
    end
    return closest
end
local conn
toggle.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        toggle.Text="Aim: ON"
        toggle.BackgroundColor3=Color3.fromRGB(0,150,80)
        conn=RS.RenderStepped:Connect(function()
            if not enabled then return end
            local t=getClosest()
            if t then
                cam.CFrame=CFrame.new(cam.CFrame.Position,t.Position)
            end
        end)
    else
        toggle.Text="Aim: OFF"
        toggle.BackgroundColor3=Color3.fromRGB(60,60,70)
        if conn then conn:Disconnect() conn=nil end
    end
end)
player.CharacterAdded:Connect(function()
    if enabled then
        enabled=false
        toggle.Text="Aim: OFF"
        toggle.BackgroundColor3=Color3.fromRGB(60,60,70)
        if conn then conn:Disconnect() conn=nil end
    end
end)
