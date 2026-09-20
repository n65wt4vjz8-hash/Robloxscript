
local player=game.Players.LocalPlayer
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaTP"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0,80,0,80)
btn.Position=UDim2.new(0.75,0,0.5,0)
btn.BackgroundColor3=Color3.fromRGB(30,30,40)
btn.Text="TP"
btn.TextColor3=Color3.fromRGB(255,255,255)
btn.Font=Enum.Font.GothamBold
btn.TextSize=20
btn.Active=true
btn.Draggable=true
btn.Parent=gui
local c=Instance.new("UICorner")
c.CornerRadius=UDim.new(0,12)
c.Parent=btn
local function tp()
    local char=player.Character
    if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dir=hrp.CFrame.LookVector
    hrp.CFrame=hrp.CFrame+dir*5
end
btn.MouseButton1Click:Connect(tp)
