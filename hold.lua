local player=game.Players.LocalPlayer
local UIS=game:GetService("UserInputService")
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaHold"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0,150,0,60)
btn.Position=UDim2.new(0.05,0,0.4,0)
btn.BackgroundColor3=Color3.fromRGB(60,60,70)
btn.Text="HOLD: OFF"
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
local heldParts={}
local function isHeld(part)
    for _,p in ipairs(heldParts) do
        if p==part then return true end
    end
    return false
end
local function removeHeld(part)
    for i,p in ipairs(heldParts) do
        if p==part then
            table.remove(heldParts,i)
            return
        end
    end
end
UIS.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.UserInputType~=Enum.UserInputType.Touch then return end
    local pos=input.Position
    local ray=workspace.CurrentCamera:ViewportPointToRay(pos.X,pos.Y)
    local params=RaycastParams.new()
    params.FilterDescendantsInstances={player.Character}
    params.FilterType=Enum.RaycastFilterType.Exclude
    local result=workspace:Raycast(ray.Origin,ray.Direction*500,params)
    if result and result.Instance and isHeld(result.Instance) then
        result.Instance.Anchored=false
        removeHeld(result.Instance)
    end
end)
task.spawn(function()
    while true do
        if enabled then
            for _,obj in ipairs(workspace:GetChildren()) do
                if obj.Name=="GrabParts" or obj.Name:lower():find("grab") then
                    for _,part in ipairs(obj:GetDescendants()) do
                        if part:IsA("BasePart") and not part.Anchored and not isHeld(part) then
                            part.Anchored=true
                            table.insert(heldParts,part)
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)
btn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        btn.Text="HOLD: ON"
        btn.BackgroundColor3=Color3.fromRGB(0,150,80)
    else
        btn.Text="HOLD: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
    end
end)
player.CharacterAdded:Connect(function()
    if enabled then
        enabled=false
        btn.Text="HOLD: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
    end
end)
