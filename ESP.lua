local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaESP"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,180,0,80)
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
title.Text="ESP"
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
local toggle=Instance.new("TextButton")
toggle.Size=UDim2.new(0.9,0,0,30)
toggle.Position=UDim2.new(0.05,0,0.4,0)
toggle.BackgroundColor3=Color3.fromRGB(60,60,70)
toggle.Text="ESP: OFF"
toggle.TextColor3=Color3.fromRGB(255,255,255)
toggle.Font=Enum.Font.GothamBold
toggle.TextSize=13
toggle.Parent=frame
local tc2=Instance.new("UICorner")
tc2.CornerRadius=UDim.new(0,6)
tc2.Parent=toggle
local enabled=false
local conn
local tags={}
local function createNameTag(pl)
    if pl==player then return end
    local box=Instance.new("BillboardGui")
    box.Name="ESP_"..pl.Name
    box.Size=UDim2.new(0,100,0,30)
    box.StudsOffset=Vector3.new(0,3,0)
    box.AlwaysOnTop=true
    box.Parent=gui
    local label=Instance.new("TextLabel")
    label.Size=UDim2.new(1,0,1,0)
    label.BackgroundTransparency=1
    label.Text=pl.Name
    label.TextColor3=Color3.fromRGB(255,50,50)
    label.TextStrokeTransparency=0
    label.TextStrokeColor3=Color3.fromRGB(0,0,0)
    label.Font=Enum.Font.GothamBold
    label.TextSize=14
    label.Parent=box
    return box
end
local function update()
    for _,pl in ipairs(game.Players:GetPlayers()) do
        if pl==player then continue end
        if not tags[pl] then
            tags[pl]=createNameTag(pl)
        end
        local tag=tags[pl]
        if tag then
            if pl.Character then
                local hrp=pl.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    tag.Adornee=hrp
                    tag.Enabled=true
                else
                    tag.Enabled=false
                end
            else
                tag.Enabled=false
            end
        end
    end
end
toggle.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        toggle.Text="ESP: ON"
        toggle.BackgroundColor3=Color3.fromRGB(0,150,80)
        update()
        conn=RS.RenderStepped:Connect(function()
            if not enabled then return end
            update()
        end)
    else
        toggle.Text="ESP: OFF"
        toggle.BackgroundColor3=Color3.fromRGB(60,60,70)
        if conn then conn:Disconnect() conn=nil end
        for _,tag in pairs(tags) do
            if tag then tag.Enabled=false end
        end
    end
end)
game.Players.PlayerRemoving:Connect(function(pl)
    if tags[pl] then
        tags[pl]:Destroy()
        tags[pl]=nil
    end
end)
player.CharacterAdded:Connect(function()
    if enabled then
        for _,tag in pairs(tags) do
            if tag then tag.Enabled=false end
        end
    end
end)
