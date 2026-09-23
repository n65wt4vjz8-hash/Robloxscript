local player=game.Players.LocalPlayer
local CG=game:GetService("CoreGui")
local UIS=game:GetService("UserInputService")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaPos"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,100,0,120)
frame.Position=UDim2.new(0.05,0,0.3,0)
frame.BackgroundColor3=Color3.fromRGB(20,20,25)
frame.BorderSizePixel=0
frame.Active=true
frame.Draggable=true
frame.Parent=gui
local fc=Instance.new("UICorner")
fc.CornerRadius=UDim.new(0,6)
fc.Parent=frame
local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,18)
title.BackgroundColor3=Color3.fromRGB(35,35,45)
title.BorderSizePixel=0
title.Text="Pos"
title.TextColor3=Color3.fromRGB(255,255,255)
title.Font=Enum.Font.GothamBold
title.TextSize=9
title.Parent=frame
local tc=Instance.new("UICorner")
tc.CornerRadius=UDim.new(0,6)
tc.Parent=title
local closeBtn=Instance.new("TextButton")
closeBtn.Size=UDim2.new(0,16,0,16)
closeBtn.Position=UDim2.new(1,-18,0,1)
closeBtn.BackgroundColor3=Color3.fromRGB(180,50,50)
closeBtn.Text="×"
closeBtn.TextColor3=Color3.fromRGB(255,255,255)
closeBtn.Font=Enum.Font.GothamBold
closeBtn.TextSize=11
closeBtn.Parent=title
local cc=Instance.new("UICorner")
cc.CornerRadius=UDim.new(0,4)
cc.Parent=closeBtn
closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)
local positions={}
local holdTime=0.5
local function makeSlot(num,y)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0.9,0,0,24)
    b.Position=UDim2.new(0.05,0,y,0)
    b.BackgroundColor3=Color3.fromRGB(45,45,60)
    b.Text="Slot "..num
    b.TextColor3=Color3.fromRGB(255,255,255)
    b.Font=Enum.Font.GothamBold
    b.TextSize=10
    b.Parent=frame
    local c=Instance.new("UICorner")
    c.CornerRadius=UDim.new(0,4)
    c.Parent=b
    local pressStart=0
    local longPressed=false
    b.MouseButton1Down:Connect(function()
        pressStart=tick()
        longPressed=false
    end)
    b.MouseButton1Up:Connect(function()
        local held=tick()-pressStart
        local char=player.Character
        local hrp=char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if held>=holdTime then
            positions[num]=hrp.CFrame
            b.Text="Saved "..num
            b.BackgroundColor3=Color3.fromRGB(50,70,110)
            task.wait(0.8)
            b.Text="Slot "..num
            b.BackgroundColor3=Color3.fromRGB(45,45,60)
        else
            if positions[num] then
                hrp.CFrame=positions[num]
                b.Text="TP!"
                b.BackgroundColor3=Color3.fromRGB(0,150,80)
                task.wait(0.4)
                b.Text="Slot "..num
                b.BackgroundColor3=Color3.fromRGB(45,45,60)
            else
                b.Text="Empty"
                task.wait(0.5)
                b.Text="Slot "..num
            end
        end
    end)
end
makeSlot(1,24)
makeSlot(2,52)
makeSlot(3,80)
local info=Instance.new("TextLabel")
info.Size=UDim2.new(1,0,0,14)
info.Position=UDim2.new(0,0,1,-16)
info.BackgroundTransparency=1
info.Text="Tap:TP / Hold:Save"
info.TextColor3=Color3.fromRGB(150,160,180)
info.Font=Enum.Font.Gotham
info.TextSize=7
info.Parent=frame
