local KEY="Luck"
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
frame.Size=UDim2.new(0,220,0,130)
frame.Position=UDim2.new(0.5,-110,0.5,-65)
frame.BackgroundColor3=Color3.fromRGB(20,20,25)
frame.BorderSizePixel=0
frame.Parent=gui
local fc=Instance.new("UICorner")
fc.CornerRadius=UDim.new(0,10)
fc.Parent=frame
local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,30)
title.BackgroundColor3=Color3.fromRGB(35,35,45)
title.BorderSizePixel=0
title.Text="Key System"
title.TextColor3=Color3.fromRGB(255,255,255)
title.Font=Enum.Font.GothamBold
title.TextSize=14
title.Parent=frame
local tc=Instance.new("UICorner")
tc.CornerRadius=UDim.new(0,10)
tc.Parent=title
local box=Instance.new("TextBox")
box.Size=UDim2.new(0.9,0,0,32)
box.Position=UDim2.new(0.05,0,0.3,0)
box.BackgroundColor3=Color3.fromRGB(45,45,55)
box.PlaceholderText="Key..."
box.Text=""
box.TextColor3=Color3.fromRGB(255,255,255)
box.Font=Enum.Font.GothamBold
box.TextSize=13
box.ClearTextOnFocus=false
box.Parent=frame
local bc=Instance.new("UICorner")
bc.CornerRadius=UDim.new(0,6)
bc.Parent=box
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0.9,0,0,32)
btn.Position=UDim2.new(0.05,0,0.58,0)
btn.BackgroundColor3=Color3.fromRGB(0,150,80)
btn.Text="OK"
btn.TextColor3=Color3.fromRGB(255,255,255)
btn.Font=Enum.Font.GothamBold
btn.TextSize=14
btn.Parent=frame
local btc=Instance.new("UICorner")
btc.CornerRadius=UDim.new(0,6)
btc.Parent=btn
local status=Instance.new("TextLabel")
status.Size=UDim2.new(1,0,0,20)
status.Position=UDim2.new(0,0,0.84,0)
status.BackgroundTransparency=1
status.Text=""
status.TextColor3=Color3.fromRGB(255,100,100)
status.Font=Enum.Font.GothamBold
status.TextSize=11
status.Parent=frame
local function openAimbot()
    local af=Instance.new("Frame")
    af.Size=UDim2.new(0,200,0,120)
    af.Position=UDim2.new(0.05,0,0.3,0)
    af.BackgroundColor3=Color3.fromRGB(20,20,25)
    af.BorderSizePixel=0
    af.Active=true
    af.Draggable=true
    af.Parent=gui
    local afc=Instance.new("UICorner")
    afc.CornerRadius=UDim.new(0,10)
    afc.Parent=af
    local at=Instance.new("TextLabel")
    at.Size=UDim2.new(1,0,0,26)
    at.BackgroundColor3=Color3.fromRGB(35,35,45)
    at.BorderSizePixel=0
    at.Text="Aimbot"
    at.TextColor3=Color3.fromRGB(255,255,255)
    at.Font=Enum.Font.GothamBold
    at.TextSize=14
    at.Parent=af
    local atc=Instance.new("UICorner")
    atc.CornerRadius=UDim.new(0,10)
    atc.Parent=at
    local ac=Instance.new("TextButton")
    ac.Size=UDim2.new(0,24,0,24)
    ac.Position=UDim2.new(1,-28,0,1)
    ac.BackgroundColor3=Color3.fromRGB(180,50,50)
    ac.Text="×"
    ac.TextColor3=Color3.fromRGB(255,255,255)
    ac.Font=Enum.Font.GothamBold
    ac.TextSize=16
    ac.Parent=at
    local acc=Instance.new("UICorner")
    acc.CornerRadius=UDim.new(0,6)
    acc.Parent=ac
    ac.MouseButton1Click:Connect(function()
        af:Destroy()
    end)
    local tg=Instance.new("TextButton")
    tg.Size=UDim2.new(0.9,0,0,32)
    tg.Position=UDim2.new(0.05,0,0.3,0)
    tg.BackgroundColor3=Color3.fromRGB(60,60,70)
    tg.Text="OFF"
    tg.TextColor3=Color3.fromRGB(255,255,255)
    tg.Font=Enum.Font.GothamBold
    tg.TextSize=14
    tg.Parent=af
    local tgc=Instance.new("UICorner")
    tgc.CornerRadius=UDim.new(0,6)
    tgc.Parent=tg
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,0,0,22)
    lbl.Position=UDim2.new(0,0,0.7,0)
    lbl.BackgroundTransparency=1
    lbl.Text="FOV: 200"
    lbl.TextColor3=Color3.fromRGB(200,220,255)
    lbl.Font=Enum.Font.GothamBold
    lbl.TextSize=11
    lbl.Parent=af
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
    tg.MouseButton1Click:Connect(function()
        enabled=not enabled
        if enabled then
            tg.Text="ON"
            tg.BackgroundColor3=Color3.fromRGB(0,150,80)
            conn=RS.RenderStepped:Connect(function()
                if not enabled then return end
                local t=getClosest()
                if t then cam.CFrame=CFrame.new(cam.CFrame.Position,t.Position) end
            end)
        else
            tg.Text="OFF"
            tg.BackgroundColor3=Color3.fromRGB(60,60,70)
            if conn then conn:Disconnect() conn=nil end
        end
    end)
    player.CharacterAdded:Connect(function()
        if enabled then
            enabled=false
            tg.Text="OFF"
            tg.BackgroundColor3=Color3.fromRGB(60,60,70)
            if conn then conn:Disconnect() conn=nil end
        end
    end)
end
btn.MouseButton1Click:Connect(function()
    if box.Text==KEY then
        status.Text="OK"
        status.TextColor3=Color3.fromRGB(0,220,120)
        task.wait(0.5)
        frame:Destroy()
        openAimbot()
    else
        status.Text="Wrong"
        box.Text=""
    end
end)
box.FocusLost:Connect(function(enter)
    if enter then btn.MouseButton1Click:Fire() end
end)
