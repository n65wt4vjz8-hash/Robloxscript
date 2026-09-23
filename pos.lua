local player=game.Players.LocalPlayer
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaPos"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,100,0,90)
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
local saved=nil
local saveBtn=Instance.new("TextButton")
saveBtn.Size=UDim2.new(0.9,0,0,24)
saveBtn.Position=UDim2.new(0.05,0,0.28,0)
saveBtn.BackgroundColor3=Color3.fromRGB(50,70,110)
saveBtn.Text="SAVE"
saveBtn.TextColor3=Color3.fromRGB(255,255,255)
saveBtn.Font=Enum.Font.GothamBold
saveBtn.TextSize=10
saveBtn.Parent=frame
local sbc=Instance.new("UICorner")
sbc.CornerRadius=UDim.new(0,4)
sbc.Parent=saveBtn
local tpBtn=Instance.new("TextButton")
tpBtn.Size=UDim2.new(0.9,0,0,24)
tpBtn.Position=UDim2.new(0.05,0,0.58,0)
tpBtn.BackgroundColor3=Color3.fromRGB(50,90,60)
tpBtn.Text="TP"
tpBtn.TextColor3=Color3.fromRGB(255,255,255)
tpBtn.Font=Enum.Font.GothamBold
tpBtn.TextSize=10
tpBtn.Parent=frame
local tbc=Instance.new("UICorner")
tbc.CornerRadius=UDim.new(0,4)
tbc.Parent=tpBtn
saveBtn.MouseButton1Click:Connect(function()
    local char=player.Character
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    saved=hrp.CFrame
    saveBtn.Text="Saved!"
    saveBtn.BackgroundColor3=Color3.fromRGB(0,150,80)
    task.wait(0.8)
    saveBtn.Text="SAVE"
    saveBtn.BackgroundColor3=Color3.fromRGB(50,70,110)
end)
tpBtn.MouseButton1Click:Connect(function()
    if not saved then
        tpBtn.Text="Empty"
        task.wait(0.8)
        tpBtn.Text="TP"
        return
    end
    local char=player.Character
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame=saved
    tpBtn.Text="TP!"
    task.wait(0.4)
    tpBtn.Text="TP"
end)
