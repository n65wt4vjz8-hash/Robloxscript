local ApiFTAP=loadstring(game:HttpGet("https://raw.githubusercontent.com/Oxwoey/FTAP-Module/refs/heads/main/Module/ModuleFTAP"))()
local player=game.Players.LocalPlayer
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaBlob"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0,140,0,60)
btn.Position=UDim2.new(0.05,0,0.4,0)
btn.BackgroundColor3=Color3.fromRGB(60,60,70)
btn.Text="AURA: OFF"
btn.TextColor3=Color3.fromRGB(255,255,255)
btn.Font=Enum.Font.GothamBold
btn.TextSize=14
btn.Active=true
btn.Draggable=true
btn.Parent=gui
local bc=Instance.new("UICorner")
bc.CornerRadius=UDim.new(0,10)
bc.Parent=btn
local enabled=false
btn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        btn.Text="AURA: ON"
        btn.BackgroundColor3=Color3.fromRGB(0,150,80)
        pcall(function()
            ApiFTAP.KickAura(true)
        end)
    else
        btn.Text="AURA: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
        pcall(function()
            ApiFTAP.KickAura(false)
        end)
    end
end)
player.CharacterAdded:Connect(function()
    if enabled then
        enabled=false
        btn.Text="AURA: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
        pcall(function()
            ApiFTAP.KickAura(false)
        end)
    end
end)
