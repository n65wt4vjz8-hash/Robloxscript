local player=game.Players.LocalPlayer
local UIS=game:GetService("UserInputService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaTapTP"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0,120,0,50)
btn.Position=UDim2.new(0.05,0,0.3,0)
btn.BackgroundColor3=Color3.fromRGB(60,60,70)
btn.Text="TP: OFF"
btn.TextColor3=Color3.fromRGB(255,255,255)
btn.Font=Enum.Font.GothamBold
btn.TextSize=16
btn.Active=true
btn.Draggable=true
btn.Parent=gui
local bc=Instance.new("UICorner")
bc.CornerRadius=UDim.new(0,10)
bc.Parent=btn
local enabled=false
local function tpTo(pos)
    local char=player.Character
    if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame=CFrame.new(pos+Vector3.new(0,3,0))
end
UIS.InputBegan:Connect(function(input,gp)
    if gp then return end
    if not enabled then return end
    if input.UserInputType==Enum.UserInputType.Touch then
        local pos=input.Position
        local ray=workspace.CurrentCamera:ViewportPointToRay(pos.X,pos.Y)
        local params=RaycastParams.new()
        params.FilterDescendantsInstances={player.Character}
        params.FilterType=Enum.RaycastFilterType.Exclude
        local result=workspace:Raycast(ray.Origin,ray.Direction*1000,params)
        if result then
            tpTo(result.Position)
        end
    end
end)
btn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        btn.Text="TP: ON"
        btn.BackgroundColor3=Color3.fromRGB(0,150,80)
    else
        btn.Text="TP: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
    end
end)
player.CharacterAdded:Connect(function()
    if enabled then
        enabled=false
        btn.Text="TP: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
    end
end)
