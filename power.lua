local player=game.Players.LocalPlayer
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name=tostring(math.random(100000,999999))
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end

local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,180,0,240)
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
title.Text="Power"
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
statusLabel.Position=UDim2.new(0,0,0.11,0)
statusLabel.BackgroundTransparency=1
statusLabel.Text="Target: None"
statusLabel.TextColor3=Color3.fromRGB(200,220,255)
statusLabel.Font=Enum.Font.GothamBold
statusLabel.TextSize=11
statusLabel.Parent=frame

local list=Instance.new("ScrollingFrame")
list.Size=UDim2.new(0.9,0,0,140)
list.Position=UDim2.new(0.05,0,0.22,0)
list.BackgroundColor3=Color3.fromRGB(15,15,20)
list.BorderSizePixel=0
list.ScrollBarThickness=3
list.CanvasSize=UDim2.new(0,0,0,0)
list.AutomaticCanvasSize=Enum.AutomaticSize.Y
list.Parent=frame
local lc=Instance.new("UICorner")
lc.CornerRadius=UDim.new(0,6)
lc.Parent=list

local layout=Instance.new("UIListLayout")
layout.Padding=UDim.new(0,3)
layout.SortOrder=Enum.SortOrder.LayoutOrder
layout.Parent=list

local padding=Instance.new("UIPadding")
padding.PaddingTop=UDim.new(0,3)
padding.PaddingLeft=UDim.new(0,3)
padding.PaddingRight=UDim.new(0,3)
padding.Parent=list

local powerBtn=Instance.new("TextButton")
powerBtn.Size=UDim2.new(0.9,0,0,36)
powerBtn.Position=UDim2.new(0.05,0,0.84,0)
powerBtn.BackgroundColor3=Color3.fromRGB(180,50,50)
powerBtn.Text="POWER!"
powerBtn.TextColor3=Color3.fromRGB(255,255,255)
powerBtn.Font=Enum.Font.GothamBold
powerBtn.TextSize=15
powerBtn.Parent=frame
local pbc=Instance.new("UICorner")
pbc.CornerRadius=UDim.new(0,8)
pbc.Parent=powerBtn

local targetPlayer=nil
local targetButton=nil

local function getHRP()
    local char=player.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end

local function pullAndLaunch(target)
    if not target then return end
    local char=target.Character
    if not char then return end
    local tHrp=char:FindFirstChild("HumanoidRootPart")
    if not tHrp then return end
    local myHrp=getHRP()
    if not myHrp then return end

    -- 引き寄せ：自分の前方3studsに
    local myLook=myHrp.CFrame.LookVector
    local pullPos=myHrp.Position+myLook*3
    tHrp.CFrame=CFrame.new(pullPos)

    -- 少し待ってから吹き飛ばす
    task.wait(0.1)

    -- 前方に1000の力で吹き飛ばす
    local bv=Instance.new("BodyVelocity")
    bv.MaxForce=Vector3.new(1e6,1e6,1e6)
    bv.Velocity=myLook*1000+Vector3.new(0,100,0)
    bv.Parent=tHrp
    game:GetService("Debris"):AddItem(bv,0.5)
end

local function makePlayerBtn(pl)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,-6,0,26)
    b.BackgroundColor3=Color3.fromRGB(45,45,60)
    b.Text=pl.Name
    b.TextColor3=Color3.fromRGB(255,255,255)
    b.Font=Enum.Font.GothamBold
    b.TextSize=11
    b.Parent=list
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,5)
    c.Parent=b
    b.MouseButton1Click:Connect(function()
        if targetButton then
            targetButton.BackgroundColor3=Color3.fromRGB(45,45,60)
        end
        targetPlayer=pl
        targetButton=b
        b.BackgroundColor3=Color3.fromRGB(0,150,80)
        statusLabel.Text="Target: "..pl.Name
    end)
    return b
end

local buttons={}
for _,pl in ipairs(game.Players:GetPlayers()) do
    if pl~=player then
        buttons[pl]=makePlayerBtn(pl)
    end
end

game.Players.PlayerAdded:Connect(function(pl)
    if pl~=player then
        buttons[pl]=makePlayerBtn(pl)
    end
end)

game.Players.PlayerRemoving:Connect(function(pl)
    if buttons[pl] then
        buttons[pl]:Destroy()
        buttons[pl]=nil
    end
    if targetPlayer==pl then
        targetPlayer=nil
        targetButton=nil
        statusLabel.Text="Target: None"
    end
end)

powerBtn.MouseButton1Click:Connect(function()
    if not targetPlayer then
        powerBtn.Text="No Target"
        task.wait(0.8)
        powerBtn.Text="POWER!"
        return
    end
    powerBtn.Text="FIRING..."
    pullAndLaunch(targetPlayer)
    task.wait(0.5)
    powerBtn.Text="POWER!"
end)
