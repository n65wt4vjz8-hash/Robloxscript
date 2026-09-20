local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local oldGui = LocalPlayer:FindFirstChild("TeleportListGUI")
if oldGui then oldGui:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "TeleportListGUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(0, 100, 0, 200)
scroll.Position = UDim2.new(0, 10, 0.5, -100)
scroll.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.Parent = gui

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 1)
layout.Parent = scroll

local function teleportTo(player)
    if player and player.Character then
        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetHRP and myHRP then
            myHRP.CFrame = targetHRP.CFrame + Vector3.new(3, 0, 0)
        end
    end
end

local function makeButton(player)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 20)
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = player.Name
    btn.TextSize = 10
    btn.Font = Enum.Font.Gotham
    btn.TextTruncate = Enum.TextTruncate.AtEnd
    btn.BorderSizePixel = 0
    btn.Name = player.Name
    btn.Parent = scroll
    btn.MouseButton1Click:Connect(function() teleportTo(player) end)
    return btn
end

local collapsed = false

local function makeHeader(player)
    local headerBtn = Instance.new("TextButton")
    headerBtn.Size = UDim2.new(1, -4, 0, 20)
    headerBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    headerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    headerBtn.Text = player.Name
    headerBtn.TextSize = 10
    headerBtn.Font = Enum.Font.GothamBold
    headerBtn.TextTruncate = Enum.TextTruncate.AtEnd
    headerBtn.BorderSizePixel = 0
    headerBtn.Name = "__HEADER__"
    headerBtn.Parent = scroll
    headerBtn.MouseButton1Click:Connect(function() teleportTo(player) end)

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 16, 0, 16)
    toggleBtn.Position = UDim2.new(1, -18, 0, 2)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Text = "▼"
    toggleBtn.TextSize = 12
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.BorderSizePixel = 0
    toggleBtn.ZIndex = 2
    toggleBtn.Parent = headerBtn

    toggleBtn.MouseButton1Click:Connect(function()
        collapsed = not collapsed
        toggleBtn.Text = collapsed and "▲" or "▼"
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("TextButton") and child.Name ~= "__HEADER__" then
                child.Visible = not collapsed
            end
        end
        task.wait()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 5)
    end)
end

local function rebuild()
    for _, c in ipairs(scroll:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end

    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p) end
    end

    if #list == 0 then
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        return
    end

    makeHeader(list[1])

    for i = 2, #list do
        local btn = makeButton(list[i])
        btn.Visible = not collapsed
    end

    task.wait()
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 5)
end

rebuild()

Players.PlayerAdded:Connect(function() task.wait(0.5) rebuild() end)
Players.PlayerRemoving:Connect(function() task.wait(0.5) rebuild() end)
