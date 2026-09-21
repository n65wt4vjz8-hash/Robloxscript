
local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local Balls=workspace:WaitForChild("Balls")
local RS2=game:GetService("ReplicatedStorage")
local Remotes=RS2:WaitForChild("Remotes")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaBall"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,160,0,90)
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
title.Text="Auto Parry"
title.TextColor3=Color3.fromRGB(255,255,255)
title.Font=Enum.Font.GothamBold
title.TextSize=12
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
btn.Size=UDim2.new(0.9,0,0,30)
btn.Position=UDim2.new(0.05,0,0.35,0)
btn.BackgroundColor3=Color3.fromRGB(60,60,70)
btn.Text="Parry: OFF"
btn.TextColor3=Color3.fromRGB(255,255,255)
btn.Font=Enum.Font.GothamBold
btn.TextSize=12
btn.Parent=frame
local bc=Instance.new("UICorner")
bc.CornerRadius=UDim.new(0,6)
bc.Parent=btn
local lbl=Instance.new("TextLabel")
lbl.Size=UDim2.new(1,0,0,18)
lbl.Position=UDim2.new(0,0,0.75,0)
lbl.BackgroundTransparency=1
lbl.Text="Dist: 8"
lbl.TextColor3=Color3.fromRGB(200,220,255)
lbl.Font=Enum.Font.GothamBold
lbl.TextSize=11
lbl.Parent=frame
local enabled=false
local lastParry=0
local ParryDistance=8
local ParryCooldown=0.3
local function isTarget()
    return player.Character and player.Character:FindFirstChild("Highlight") ~= nil
end
local function parry()
    if tick()-lastParry<ParryCooldown then return end
    lastParry=tick()
    local remote=Remotes:FindFirstChild("ParryButtonPress")
    if remote then
        remote:FireServer()
    end
end
RS.PreSimulation:Connect(function()
    if not enabled then return end
    if not isTarget() then return end
    local char=player.Character
    if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _,ball in ipairs(Balls:GetChildren()) do
        if ball:GetAttribute("realBall") then
            local dist=(ball.Position-hrp.Position).Magnitude
            if dist<=ParryDistance then
                parry()
                break
            end
        end
    end
end)
btn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        btn.Text="Parry: ON"
        btn.BackgroundColor3=Color3.fromRGB(0,150,80)
    else
        btn.Text="Parry: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
    end
end)
player.CharacterAdded:Connect(function()
    if enabled then
        enabled=false
        btn.Text="Parry: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
    end
end)
