local player=game.Players.LocalPlayer
local CG=game:GetService("CoreGui")
local gui=Instance.new("ScreenGui")
gui.Name="DeltaExtGrab"
gui.ResetOnSpawn=false
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end
local btn=Instance.new("TextButton")
btn.Size=UDim2.new(0,140,0,60)
btn.Position=UDim2.new(0.05,0,0.4,0)
btn.BackgroundColor3=Color3.fromRGB(60,60,70)
btn.Text="EXT: OFF"
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
local distance=100
local mt=getrawmetatable(game)
local old=mt.__namecall
setreadonly(mt,false)
mt.__namecall=function(self,...)
    local method=getnamecallmethod()
    if method=="FireServer" and enabled then
        local name=self:GetFullName()
        if name:find("ExtendGrabLine") then
            local args={...}
            args[1]=distance
            return old(self,table.unpack(args))
        end
    end
    return old(self,...)
end
setreadonly(mt,true)
btn.MouseButton1Click:Connect(function()
    enabled=not enabled
    if enabled then
        btn.Text="EXT: ON"
        btn.BackgroundColor3=Color3.fromRGB(0,150,80)
    else
        btn.Text="EXT: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
    end
end)
player.CharacterAdded:Connect(function()
    if enabled then
        enabled=false
        btn.Text="EXT: OFF"
        btn.BackgroundColor3=Color3.fromRGB(60,60,70)
    end
end)
