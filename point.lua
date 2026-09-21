local player=game.Players.LocalPlayer
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaPoint"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,200,0,300)
frame.Position=UDim2.new(0.05,0,0.2,0)
frame.BackgroundColor3=Color3.fromRGB(20,20,25)
frame.BorderSizePixel=0
frame.Active=true
frame.Draggable=true
frame.Parent=gui
local fc=Instance.new("UICorner")
fc.CornerRadius=UDim.new(0,10)
fc.Parent=frame
local title=Instance.new("TextLabel")
title.Size=UDim2.new(1,0,0,30)
title.BackgroundColor3=Color3.fromRGB(35,35,45)
title.BorderSizePixel=0
title.Text="Point"
title.TextColor3=Color3.fromRGB(255,255,255)
title.Font=Enum.Font.GothamBold
title.TextSize=14
title.Parent=frame
local saveBtn=Instance.new("TextButton")
saveBtn.Size=UDim2.new(0.9,0,0,40)
saveBtn.Position=UDim2.new(0.05,0,0.2,0)
saveBtn.BackgroundColor3=Color3.fromRGB(50,70,110)
saveBtn.Text="SAVE"
saveBtn.TextColor3=Color3.fromRGB(255,255,255)
saveBtn.Font=Enum.Font.GothamBold
saveBtn.TextSize=16
saveBtn.Parent=frame
local tpBtn=Instance.new("TextButton")
tpBtn.Size=UDim2.new(0.9,0,0,40)
tpBtn.Position=UDim2.new(0.05,0,0.4,0)
tpBtn.BackgroundColor3=Color3.fromRGB(50,90,60)
tpBtn.Text="TP"
tpBtn.TextColor3=Color3.fromRGB(255,255,255)
tpBtn.Font=Enum.Font.GothamBold
tpBtn.TextSize=16
tpBtn.Parent=frame
local saved=nil
saveBtn.MouseButton1Click:Connect(function()
    local char=player.Character
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        saved=hrp.CFrame
        saveBtn.Text="SAVED!"
        task.wait(1)
        saveBtn.Text="SAVE"
    end
end)
tpBtn.MouseButton1Click:Connect(function()
    if not saved then return end
    local char=player.Character
    local hrp=char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame=saved
    end
end)
