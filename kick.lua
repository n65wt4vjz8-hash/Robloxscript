local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaKick"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,160,0,220)
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
title.Text="Kick (Freeze)"
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
toggleBtn.Size=UDim2.new(0.9,0,0,26)
toggleBtn.Position=UDim2.new(0.05,0,0.13,0)
toggleBtn.BackgroundColor3=Color3.fromRGB(60,60,70)
toggleBtn.Text="FREEZE: OFF"
toggleBtn.TextColor3=Color3.fromRGB(255,255,255)
toggleBtn.Font=Enum.Font.GothamBold
toggleBtn.TextSize=11
toggleBtn.Parent=frame
local tbc=Instance.new("UICorner")
tbc.CornerRadius=UDim.new(0,6)
tbc.Parent=toggleBtn
local list=Instance.new("ScrollingFrame")
list.Size=UDim2.new(0.9,0,0,150)
list.Position=UDim2.new(0.05,0,0.28,0)
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
local enabled=false
local targetPlayer=nil
local targetButton=nil
local savedCFrame=nil
local function freezePlayer(pl)
    if not pl then return end
    local char=pl.Character
    if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if not savedCFrame then
        savedCFrame=hrp.CFrame
    end
    hrp.CFrame=savedCFrame
    hrp.Velocity=Vector3.zero
    hrp.RotVelocity=Vector3.zero
end
RS.Heartbeat:Connect(function()
    if not enabled then return end
    if not targetPlayer then return end
    freezePlayer(targetPlayer)
end)
local function makePlayerBtn(pl)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,-6,0,22)
    b.BackgroundColor3=Color3.fromRGB(45,45,60)
    b.Text=pl.Name
    b.TextColor3=Color3.fromRGB(255,255,255)
    b.Font=Enum.Font.GothamBold
    b.TextSize=9
    b.Parent=list
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,4)
    c.Parent=b
    b.MouseButton1Click:Connect(function()
        if targetButton then
            targetButton.BackgroundColor3=Color3.fromRGB(45,45,60)
        end
        targetPlayer=pl
        targetButton=b
        savedCFrame=nil
        b.BackgroundColor3=Color3.fromRGB(0,150,80)
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
        savedCFrame=nil
    end
end)
toggleBtn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        toggleBtn.Text="FREEZE: ON"
        toggleBtn.BackgroundColor3=Color3.fromRGB(0,150,80)
    else
        toggleBtn.Text="FREEZE: OFF"
        toggleBtn.BackgroundColor3=Color3.fromRGB(60,60,70)
        savedCFrame=nil
        if targetPlayer then
            local char=targetPlayer.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity=Vector3.zero
                hrp.RotVelocity=Vector3.zero
            end
        end
    end
end)
player.CharacterAdded:Connect(function()
    if enabled then
        enabled=false
        toggleBtn.Text="FREEZE: OFF"
        toggleBtn.BackgroundColor3=Color3.fromRGB(60,60,70)
        savedCFrame=nil
    end
end)
