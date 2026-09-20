local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaFly3"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,180,0,70)
frame.Position=UDim2.new(0.05,0,0.3,0)
frame.BackgroundColor3=Color3.fromRGB(20,20,25)
frame.BorderSizePixel=0
frame.Active=true
frame.Draggable=true
frame.Parent=gui
local fc=Instance.new("UICorner")
fc.CornerRadius=UDim.new(0,10)
fc.Parent=frame
local normalSize=UDim2.new(0,180,0,70)
local minimized=false
local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,26)
title.BackgroundColor3=Color3.fromRGB(35,35,45)
title.BorderSizePixel=0
title.Text="Fix"
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
btn.Position=UDim2.new(0.05,0,0.42,0)
btn.BackgroundColor3=Color3.fromRGB(60,60,70)
btn.Text="Fix: OFF"
btn.TextColor3=Color3.fromRGB(255,255,255)
btn.Font=Enum.Font.GothamBold
btn.TextSize=14
btn.Parent=frame
local bc=Instance.new("UICorner")
bc.CornerRadius=UDim.new(0,6)
bc.Parent=btn
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
local fixing=false
local bg,conn
local function startFix()
    if fixing then return end
    local c=player.Character
    if not c then return end
    local h=c:FindFirstChild("HumanoidRootPart")
    if not h then return end
    fixing=true
    bg=Instance.new("BodyGyro")
    bg.MaxTorque=Vector3.new(1e5,1e5,1e5)
    bg.P=1e4
    bg.CFrame=h.CFrame
    bg.Parent=h
    conn=RS.RenderStepped:Connect(function()
        if not fixing then return end
        local c2=player.Character
        if not c2 then return end
        local h2=c2:FindFirstChild("HumanoidRootPart")
        if not h2 then return end
        local move=c2:FindFirstChildOfClass("Humanoid")
        local vel=h2.Velocity
        local flat=Vector3.new(vel.X,0,vel.Z)
        if flat.Magnitude>0.1 then
            bg.CFrame=CFrame.new(h2.Position,h2.Position+flat.Unit)
        end
    end)
    btn.Text="Fix: ON"
    btn.BackgroundColor3=Color3.fromRGB(0,150,80)
end
local function stopFix()
    if not fixing then return end
    fixing=false
    if conn then conn:Disconnect() conn=nil end
    if bg then bg:Destroy() bg=nil end
    btn.Text="Fix: OFF"
    btn.BackgroundColor3=Color3.fromRGB(60,60,70)
end
btn.MouseButton1Click:Connect(function()
    if fixing then stopFix() else startFix() end
end)
player.CharacterAdded:Connect(function()
    if fixing then stopFix() end
end)
