local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name=tostring(math.random(100000,999999))
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end

local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,180,0,150)
frame.Position=UDim2.new(0.05,0,0.35,0)
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
title.Text="Black Hole"
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

local statusLabel=Instance.new("TextLabel")
statusLabel.Size=UDim2.new(1,0,0,18)
statusLabel.Position=UDim2.new(0,0,0.18,0)
statusLabel.BackgroundTransparency=1
statusLabel.Text="Collected: 0"
statusLabel.TextColor3=Color3.fromRGB(200,220,255)
statusLabel.Font=Enum.Font.GothamBold
statusLabel.TextSize=11
statusLabel.Parent=frame

local toggleBtn=Instance.new("TextButton")
toggleBtn.Size=UDim2.new(0.9,0,0,36)
toggleBtn.Position=UDim2.new(0.05,0,0.38,0)
toggleBtn.BackgroundColor3=Color3.fromRGB(60,60,70)
toggleBtn.Text="HOLE: OFF"
toggleBtn.TextColor3=Color3.fromRGB(255,255,255)
toggleBtn.Font=Enum.Font.GothamBold
toggleBtn.TextSize=14
toggleBtn.Parent=frame
local tbc=Instance.new("UICorner")
tbc.CornerRadius=UDim.new(0,8)
tbc.Parent=toggleBtn

local infoLabel=Instance.new("TextLabel")
infoLabel.Size=UDim2.new(0.9,0,0,18)
infoLabel.Position=UDim2.new(0.05,0,0.72,0)
infoLabel.BackgroundTransparency=1
infoLabel.Text="Front 5 studs"
infoLabel.TextColor3=Color3.fromRGB(150,160,180)
infoLabel.Font=Enum.Font.Gotham
infoLabel.TextSize=10
infoLabel.Parent=frame

local enabled=false
local blackholePos=nil
local pinnedParts={}

local function getHRP()
    local char=player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function isPlayerPart(part)
    for _,pl in ipairs(game.Players:GetPlayers()) do
        local char=pl.Character
        if char and part:IsDescendantOf(char) then return true end
    end
    return false
end

local function isMyPart(part)
    local myChar=player.Character
    if myChar and part:IsDescendantOf(myChar) then return true end
    return false
end

local function collect()
    local hrp=getHRP()
    if not hrp then return end
    if not blackholePos then
        blackholePos=hrp.Position+hrp.CFrame.LookVector*5
    end
    local count=0
    
    -- プレイヤーを集める
    for _,pl in ipairs(game.Players:GetPlayers()) do
        if pl~=player then
            local char=pl.Character
            if char then
                local tHrp=char:FindFirstChild("HumanoidRootPart")
                if tHrp then
                    pcall(function()
                        tHrp.CFrame=CFrame.new(blackholePos)
                        tHrp.Velocity=Vector3.zero
                        tHrp.RotVelocity=Vector3.zero
                    end)
                    count=count+1
                end
            end
        end
    end
    
    -- 動く物を集める
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Anchored then
            if not isMyPart(obj) and not isPlayerPart(obj) then
                pcall(function()
                    obj.CFrame=CFrame.new(blackholePos)
                    obj.Velocity=Vector3.zero
                    obj.RotVelocity=Vector3.zero
                end)
                count=count+1
            end
        end
    end
    
    statusLabel.Text="Collected: "..count
end

RS.Heartbeat:Connect(function()
    if not enabled then return end
    collect()
end)

toggleBtn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        toggleBtn.Text="HOLE: ON"
        toggleBtn.BackgroundColor3=Color3.fromRGB(120,0,180)
        local hrp=getHRP()
        if hrp then
            blackholePos=hrp.Position+hrp.CFrame.LookVector*5
        end
    else
        toggleBtn.Text="HOLE: OFF"
        toggleBtn.BackgroundColor3=Color3.fromRGB(60,60,70)
        blackholePos=nil
        statusLabel.Text="Collected: 0"
    end
end)

player.CharacterAdded:Connect(function()
    if enabled then
        enabled=false
        toggleBtn.Text="HOLE: OFF"
        toggleBtn.BackgroundColor3=Color3.fromRGB(60,60,70)
        blackholePos=nil
    end
end)

warn("BlackHole 起動")
