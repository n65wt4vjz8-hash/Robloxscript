local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
local CG=game:GetService("CoreGui")
local ApiFTAP=loadstring(game:HttpGet("https://raw.githubusercontent.com/Oxwoey/FTAP-Module/refs/heads/main/Module/ModuleFTAP"))()
local gui=Instance.new("ScreenGui")
gui.Name="DeltaCombo"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0,140,0,60)
btn.Position=UDim2.new(0.05,0,0.4,0)
btn.BackgroundColor3=Color3.fromRGB(60,60,70)
btn.Text="COMBO: OFF"
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
local function tpTo(pl)
    if not pl then return end
    local char=pl.Character
    if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local myChar=player.Character
    local myHrp=myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    myHrp.CFrame=hrp.CFrame
end
RS.Heartbeat:Connect(function()
    if not enabled then return end
    for _,pl in ipairs(game.Players:GetPlayers()) do
        if pl~=player then
            pcall(function()
                tpTo(pl)
            end)
        end
    end
end)
btn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        btn.Text="COMBO: ON"
        btn.BackgroundColor3=Color3.fromRGB(0,150,80)
        pcall(function()
            ApiFTAP.KickAura(true)
        end)
    else
        btn.Text="COMBO: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
        pcall(function()
            ApiFTAP.KickAura(false)
        end)
    end
end)
player.CharacterAdded:Connect(function()
    if enabled then
        enabled=false
        btn.Text="COMBO: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
        pcall(function()
            ApiFTAP.KickAura(false)
        end)
    end
end)
