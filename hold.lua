local player=game.Players.LocalPlayer
local RS=game:GetService("RunService")
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
local function scanGrabParts()
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name~=nil then
            local parent=obj.Parent
            if parent and (parent.Name:lower():find("grab") or parent.Name:lower():find("hold") or parent.Name:lower():find("carry") or parent.Name:lower():find("blob")) then
                if not isHeld(obj) then
                    obj.Anchored=true
                    table.insert(heldParts,obj)
                end
            end
        end
    end
end
RS.Heartbeat:Connect(function()
    if not enabled then return end
    scanGrabParts()
    for _,part in ipairs(heldParts) do
        if part and part.Parent then
            if not part.Anchored then
                part.Anchored=true
            end
        end
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
