local player=game.Players.LocalPlayer
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaSavePos"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local frame=Instance.new("Frame")
frame.Size=UDim2.new(0,180,0,110)
frame.Position=UDim2.new(0.7,0,0.4,0)
frame.BackgroundColor3=Color3.fromRGB(25,25,30)
frame.BorderSizePixel=0
frame.Active=true
frame.Draggable=true
frame.Parent=gui
local c1=Instance.new("UICorner")
c1.CornerRadius=UDim.new(0,8)
c1.Parent=frame
local saveBtn=Instance.new("TextButton")
saveBtn.Size=UDim2.new(0.9,0,0,36)
saveBtn.Position=UDim2.new(0.05,0,0.08,0)
saveBtn.BackgroundColor3=Color3.fromRGB(50,70,110)
saveBtn.Text="固定 (Save)"
saveBtn.TextColor3=Color3.fromRGB(255,255,255)
saveBtn.Font=Enum.Font.GothamBold
saveBtn.TextSize=14
saveBtn.Parent=frame
local c2=Instance.new("UICorner")
c2.CornerRadius=UDim.new(0,6)
c2.Parent=saveBtn
local tpBtn=Instance.new("TextButton")
tpBtn.Size=UDim2.new(0.9,0,0,36)
tpBtn.Position=UDim2.new(0.05,0,0.55,0)
tpBtn.BackgroundColor3=Color3.fromRGB(50,90,60)
tpBtn.Text="TP"
tpBtn.TextColor3=Color3.fromRGB(255,255,255)
tpBtn.Font=Enum.Font.GothamBold
tpBtn.TextSize=14
tpBtn.Parent=frame
local c3=Instance.new("UICorner")
c3.CornerRadius=UDim.new(0,6)
c3.Parent=tpBtn
local savedCFrame=nil
saveBtn.MouseButton1Click:Connect(function()
    local char=player.Character
    if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    savedCFrame=hrp.CFrame
    saveBtn.Text="保存済み ✓"
    saveBtn.BackgroundColor3=Color3.fromRGB(0,150,80)
end)
tpBtn.MouseButton1Click:Connect(function()
    if not savedCFrame then
        tpBtn.Text="未保存"
        wait(1)
        tpBtn.Text="TP"
        return
    end
    local char=player.Character
    if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame=savedCFrame
end)
