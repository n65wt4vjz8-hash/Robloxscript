local player=game.Players.LocalPlayer
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaTP"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0,100,0,60)
btn.Position=UDim2.new(0.05,0,0.5,0)
btn.BackgroundColor3=Color3.fromRGB(50,90,150)
btn.Text="TP +20"
btn.TextColor3=Color3.fromRGB(255,255,255)
btn.Font=Enum.Font.GothamBold
btn.TextSize=16
btn.Active=true
btn.Draggable=true
btn.Parent=gui
local bc=Instance.new("UICorner")
bc.CornerRadius=UDim.new(0,12)
bc.Parent=btn
btn.MouseButton1Click:Connect(function()
    local char=player.Character
    if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dir=hrp.CFrame.LookVector
    hrp.CFrame=hrp.CFrame+dir*20
    btn.Text="TP!"
    task.wait(0.3)
    btn.Text="TP +20"
end)
