local player=game.Players.LocalPlayer
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaTPS"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0,140,0,60)
btn.Position=UDim2.new(0.05,0,0.4,0)
btn.BackgroundColor3=Color3.fromRGB(60,60,70)
btn.Text="TPS: OFF"
btn.TextColor3=Color3.fromRGB(255,255,255)
btn.Font=Enum.Font.GothamBold
btn.TextSize=13
btn.Active=true
btn.Draggable=true
btn.Parent=gui
local bc=Instance.new("UICorner")
bc.CornerRadius=UDim.new(0,10)
bc.Parent=btn
local enabled=false
local function setTPS(on)
    if on then
        player.CameraMode=Enum.CameraMode.Classic
        player.CameraMaxZoomDistance=128
        player.CameraMinZoomDistance=0.5
    else
        player.CameraMode=Enum.CameraMode.LockFirstPerson
        player.CameraMaxZoomDistance=0.5
        player.CameraMinZoomDistance=0.5
    end
end
btn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        btn.Text="TPS: ON"
        btn.BackgroundColor3=Color3.fromRGB(0,150,80)
        setTPS(true)
    else
        btn.Text="TPS: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
        setTPS(false)
    end
end)
player.CharacterAdded:Connect(function()
    if enabled then
        task.wait(0.5)
        setTPS(true)
    end
end)
