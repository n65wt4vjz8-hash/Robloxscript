local player=game.Players.LocalPlayer
local CG=game:GetService("CoreGui")
local TweenService=game:GetService("TweenService")

local KEY=player.Name

-- ===== GUI =====
local gui=Instance.new("ScreenGui")
gui.Name=tostring(math.random(100000,999999))
gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true
gui.DisplayOrder=9999
pcall(function() gui.Parent=CG end)
if not gui.Parent then gui.Parent=player:WaitForChild("PlayerGui") end

-- 真っ白な背景
local whiteBg=Instance.new("Frame")
whiteBg.Size=UDim2.new(1,0,1,0)
whiteBg.BackgroundColor3=Color3.fromRGB(255,255,255)
whiteBg.BorderSizePixel=0
whiteBg.ZIndex=1
whiteBg.Parent=gui

-- ウイルス警告ポップアップ
local popup=Instance.new("Frame")
popup.Size=UDim2.new(0,300,0,320)
popup.Position=UDim2.new(0.5,-150,0.5,-160)
popup.BackgroundColor3=Color3.fromRGB(245,245,245)
popup.BorderSizePixel=0
popup.ZIndex=10
popup.Parent=gui

local pc=Instance.new("UICorner")
pc.CornerRadius=UDim.new(0,22)
pc.Parent=popup

local warningIcon=Instance.new("TextLabel")
warningIcon.Size=UDim2.new(1,0,0,90)
warningIcon.Position=UDim2.new(0,0,0,20)
warningIcon.BackgroundTransparency=1
warningIcon.Text="⚠️"
warningIcon.TextColor3=Color3.fromRGB(255,59,48)
warningIcon.Font=Enum.Font.GothamBold
warningIcon.TextSize=70
warningIcon.ZIndex=11
warningIcon.Parent=popup

local titleLabel=Instance.new("TextLabel")
titleLabel.Size=UDim2.new(1,0,0,34)
titleLabel.Position=UDim2.new(0,0,0,115)
titleLabel.BackgroundTransparency=1
titleLabel.Text="ウイルス検出"
titleLabel.TextColor3=Color3.fromRGB(0,0,0)
titleLabel.Font=Enum.Font.GothamBold
titleLabel.TextSize=22
titleLabel.ZIndex=11
titleLabel.Parent=popup

local msgLabel=Instance.new("TextLabel")
msgLabel.Size=UDim2.new(0.88,0,0,90)
msgLabel.Position=UDim2.new(0.06,0,0,155)
msgLabel.BackgroundTransparency=1
msgLabel.Text="お使いのiPhoneは2種類のウイルスに感染しています。今すぐ削除してください。"
msgLabel.TextColor3=Color3.fromRGB(80,80,80)
msgLabel.Font=Enum.Font.Gotham
msgLabel.TextSize=15
msgLabel.TextWrapped=true
msgLabel.ZIndex=11
msgLabel.Parent=popup

local deleteBtn=Instance.new("TextButton")
deleteBtn.Size=UDim2.new(0.88,0,0,44)
deleteBtn.Position=UDim2.new(0.06,0,0.74,0)
deleteBtn.BackgroundColor3=Color3.fromRGB(255,59,48)
deleteBtn.Text="削除"
deleteBtn.TextColor3=Color3.fromRGB(255,255,255)
deleteBtn.Font=Enum.Font.GothamBold
deleteBtn.TextSize=17
deleteBtn.ZIndex=11
deleteBtn.Parent=popup

local dbc=Instance.new("UICorner")
dbc.CornerRadius=UDim.new(0,12)
dbc.Parent=deleteBtn

local closeBtn=Instance.new("TextButton")
closeBtn.Size=UDim2.new(0.88,0,0,40)
closeBtn.Position=UDim2.new(0.06,0,0.88,0)
closeBtn.BackgroundColor3=Color3.fromRGB(225,225,225)
closeBtn.Text="後で"
closeBtn.TextColor3=Color3.fromRGB(60,60,60)
closeBtn.Font=Enum.Font.GothamBold
closeBtn.TextSize=15
closeBtn.ZIndex=11
closeBtn.Parent=popup

local cbc=Instance.new("UICorner")
cbc.CornerRadius=UDim.new(0,12)
cbc.Parent=closeBtn

-- ===== ロード画面 =====
local function showLoadingScreen()
    whiteBg.Visible=false
    popup.Visible=false

    local loadFrame=Instance.new("Frame")
    loadFrame.Size=UDim2.new(0,300,0,180)
    loadFrame.Position=UDim2.new(0.5,-150,0.5,-90)
    loadFrame.BackgroundColor3=Color3.fromRGB(245,245,245)
    loadFrame.BorderSizePixel=0
    loadFrame.ZIndex=40
    loadFrame.Parent=gui

    local lfc=Instance.new("UICorner")
    lfc.CornerRadius=UDim.new(0,22)
    lfc.Parent=loadFrame

    local statusText=Instance.new("TextLabel")
    statusText.Size=UDim2.new(1,0,0,30)
    statusText.Position=UDim2.new(0,0,0,35)
    statusText.BackgroundTransparency=1
    statusText.Text=""
    statusText.TextColor3=Color3.fromRGB(0,0,0)
    statusText.Font=Enum.Font.GothamBold
    statusText.TextSize=18
    statusText.ZIndex=41
    statusText.Parent=loadFrame

    local loadBg=Instance.new("Frame")
    loadBg.Size=UDim2.new(0.85,0,0,10)
    loadBg.Position=UDim2.new(0.075,0,0.5,0)
    loadBg.BackgroundColor3=Color3.fromRGB(220,220,220)
    loadBg.BorderSizePixel=0
    loadBg.ClipsDescendants=true
    loadBg.ZIndex=41
    loadBg.Parent=loadFrame

    local lbc=Instance.new("UICorner")
    lbc.CornerRadius=UDim.new(0,5)
    lbc.Parent=loadBg

    local loadBar=Instance.new("Frame")
    loadBar.Size=UDim2.new(0,0,1,0)
    loadBar.BackgroundColor3=Color3.fromRGB(0,122,255)
    loadBar.BorderSizePixel=0
    loadBar.ZIndex=42
    loadBar.Parent=loadBg

    local lbrc=Instance.new("UICorner")
    lbrc.CornerRadius=UDim.new(0,5)
    lbrc.Parent=loadBar

    local percentText=Instance.new("TextLabel")
    percentText.Size=UDim2.new(1,0,0,24)
    percentText.Position=UDim2.new(0,0,0.7,0)
    percentText.BackgroundTransparency=1
    percentText.Text="0%"
    percentText.TextColor3=Color3.fromRGB(100,100,100)
    percentText.Font=Enum.Font.GothamBold
    percentText.TextSize=14
    percentText.ZIndex=41
    percentText.Parent=loadFrame

    local steps={
        "IPアドレスを入手",
        "メールアドレスを入手",
        "電話番号を入力",
        "パスワードを入手"
    }

    task.spawn(function()
        local totalSteps=#steps
        for i,step in ipairs(steps) do
            statusText.Text=step
            statusText.TextColor3=Color3.fromRGB(0,0,0)
            local targetPercent=i/totalSteps
            local tween=TweenService:Create(loadBar,TweenInfo.new(1.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
                Size=UDim2.new(targetPercent,0,1,0)
            })
            tween:Play()
            task.spawn(function()
                for p=1,100 do
                    task.wait(0.012)
                    percentText.Text=math.floor((i-1)/totalSteps*100+p/totalSteps).."%"
                end
            end)
            task.wait(1.4)
            statusText.Text=step.." ✓"
            statusText.TextColor3=Color3.fromRGB(0,180,80)
            task.wait(0.4)
        end
        statusText.Text="完了"
        statusText.TextColor3=Color3.fromRGB(0,180,80)
        loadBar.BackgroundColor3=Color3.fromRGB(0,200,80)
        percentText.Text="100%"
        task.wait(1.5)
        -- GUIを全部消す
        if gui then gui:Destroy() end
        warn("WhiteVirus 終了")
    end)
end

-- ===== キー入力画面 =====
local function showKeyInput()
    whiteBg.Visible=false
    popup.Visible=false

    local keyFrame=Instance.new("Frame")
    keyFrame.Size=UDim2.new(0,300,0,220)
    keyFrame.Position=UDim2.new(0.5,-150,0.5,-110)
    keyFrame.BackgroundColor3=Color3.fromRGB(245,245,245)
    keyFrame.BorderSizePixel=0
    keyFrame.ZIndex=30
    keyFrame.Parent=gui

    local kfc=Instance.new("UICorner")
    kfc.CornerRadius=UDim.new(0,22)
    kfc.Parent=keyFrame

    local kIcon=Instance.new("TextLabel")
    kIcon.Size=UDim2.new(1,0,0,50)
    kIcon.Position=UDim2.new(0,0,0,15)
    kIcon.BackgroundTransparency=1
    kIcon.Text="🔑"
    kIcon.TextColor3=Color3.fromRGB(255,180,50)
    kIcon.Font=Enum.Font.GothamBold
    kIcon.TextSize=40
    kIcon.ZIndex=31
    kIcon.Parent=keyFrame

    local kTitle=Instance.new("TextLabel")
    kTitle.Size=UDim2.new(1,0,0,30)
    kTitle.Position=UDim2.new(0,0,0,65)
    kTitle.BackgroundTransparency=1
    kTitle.Text="キーを入力"
    kTitle.TextColor3=Color3.fromRGB(0,0,0)
    kTitle.Font=Enum.Font.GothamBold
    kTitle.TextSize=20
    kTitle.ZIndex=31
    kTitle.Parent=keyFrame

    local kDesc=Instance.new("TextLabel")
    kDesc.Size=UDim2.new(0.9,0,0,24)
    kDesc.Position=UDim2.new(0.05,0,0,95)
    kDesc.BackgroundTransparency=1
    kDesc.Text="ヒント: あなたのユーザーネーム"
    kDesc.TextColor3=Color3.fromRGB(120,120,120)
    kDesc.Font=Enum.Font.Gotham
    kDesc.TextSize=13
    kDesc.ZIndex=31
    kDesc.Parent=keyFrame

    local kBox=Instance.new("TextBox")
    kBox.Size=UDim2.new(0.88,0,0,40)
    kBox.Position=UDim2.new(0.06,0,0.53,0)
    kBox.BackgroundColor3=Color3.fromRGB(255,255,255)
    kBox.BorderSizePixel=0
    kBox.PlaceholderText="Key..."
    kBox.Text=""
    kBox.TextColor3=Color3.fromRGB(0,0,0)
    kBox.Font=Enum.Font.Gotham
    kBox.TextSize=14
    kBox.ZIndex=31
    kBox.Parent=keyFrame

    local kbc=Instance.new("UICorner")
    kbc.CornerRadius=UDim.new(0,10)
    kbc.Parent=kBox

    local kStroke=Instance.new("UIStroke")
    kStroke.Color=Color3.fromRGB(200,200,200)
    kStroke.Thickness=1
    kStroke.Parent=kBox

    local kStatus=Instance.new("TextLabel")
    kStatus.Size=UDim2.new(0.9,0,0,18)
    kStatus.Position=UDim2.new(0.05,0,0.73,0)
    kStatus.BackgroundTransparency=1
    kStatus.Text=""
    kStatus.TextColor3=Color3.fromRGB(255,59,48)
    kStatus.Font=Enum.Font.Gotham
    kStatus.TextSize=12
    kStatus.ZIndex=31
    kStatus.Parent=keyFrame

    local kBtn=Instance.new("TextButton")
    kBtn.Size=UDim2.new(0.88,0,0,40)
    kBtn.Position=UDim2.new(0.06,0,0.85,0)
    kBtn.BackgroundColor3=Color3.fromRGB(0,122,255)
    kBtn.Text="認証"
    kBtn.TextColor3=Color3.fromRGB(255,255,255)
    kBtn.Font=Enum.Font.GothamBold
    kBtn.TextSize=15
    kBtn.ZIndex=31
    kBtn.Parent=keyFrame

    local kbtc=Instance.new("UICorner")
    kbtc.CornerRadius=UDim.new(0,12)
    kbtc.Parent=kBtn

    kBtn.MouseButton1Click:Connect(function()
        if kBox.Text==KEY then
            kStatus.Text="認証成功"
            kStatus.TextColor3=Color3.fromRGB(0,200,80)
            task.wait(0.6)
            keyFrame:Destroy()
            showLoadingScreen()
        else
            kStatus.Text="キーが違います"
            kStatus.TextColor3=Color3.fromRGB(255,59,48)
            kBox.Text=""
        end
    end)

    kBox.FocusLost:Connect(function(enter)
        if enter then
            kBtn.MouseButton1Click:Fire()
        end
    end)
end

-- ===== 削除確認ダイアログ =====
local function showDeleteConfirm(fileName, isVirus)
    local confirm=Instance.new("Frame")
    confirm.Size=UDim2.new(0,280,0,180)
    confirm.Position=UDim2.new(0.5,-140,0.5,-90)
    confirm.BackgroundColor3=Color3.fromRGB(245,245,245)
    confirm.BorderSizePixel=0
    confirm.ZIndex=100
    confirm.Parent=gui

    local cfc=Instance.new("UICorner")
    cfc.CornerRadius=UDim.new(0,16)
    cfc.Parent=confirm

    local cTitle=Instance.new("TextLabel")
    cTitle.Size=UDim2.new(1,0,0,30)
    cTitle.Position=UDim2.new(0,0,0,20)
    cTitle.BackgroundTransparency=1
    cTitle.Text="削除の確認"
    cTitle.TextColor3=Color3.fromRGB(0,0,0)
    cTitle.Font=Enum.Font.GothamBold
    cTitle.TextSize=17
    cTitle.ZIndex=101
    cTitle.Parent=confirm

    local cMsg=Instance.new("TextLabel")
    cMsg.Size=UDim2.new(0.9,0,0,60)
    cMsg.Position=UDim2.new(0.05,0,0,55)
    cMsg.BackgroundTransparency=1
    cMsg.Text="「"..fileName.."」を削除しますか？"
    cMsg.TextColor3=Color3.fromRGB(80,80,80)
    cMsg.Font=Enum.Font.Gotham
    cMsg.TextSize=14
    cMsg.TextWrapped=true
    cMsg.ZIndex=101
    cMsg.Parent=confirm

    local yesBtn=Instance.new("TextButton")
    yesBtn.Size=UDim2.new(0.42,0,0,38)
    yesBtn.Position=UDim2.new(0.06,0,0.7,0)
    yesBtn.BackgroundColor3=Color3.fromRGB(255,59,48)
    yesBtn.Text="削除"
    yesBtn.TextColor3=Color3.fromRGB(255,255,255)
    yesBtn.Font=Enum.Font.GothamBold
    yesBtn.TextSize=15
    yesBtn.ZIndex=101
    yesBtn.Parent=confirm

    local ybc=Instance.new("UICorner")
    ybc.CornerRadius=UDim.new(0,10)
    ybc.Parent=yesBtn

    local noBtn=Instance.new("TextButton")
    noBtn.Size=UDim2.new(0.42,0,0,38)
    noBtn.Position=UDim2.new(0.52,0,0.7,0)
    noBtn.BackgroundColor3=Color3.fromRGB(225,225,225)
    noBtn.Text="キャンセル"
    noBtn.TextColor3=Color3.fromRGB(60,60,60)
    noBtn.Font=Enum.Font.GothamBold
    noBtn.TextSize=15
    noBtn.ZIndex=101
    noBtn.Parent=confirm

    local nbc=Instance.new("UICorner")
    nbc.CornerRadius=UDim.new(0,10)
    nbc.Parent=noBtn

    noBtn.MouseButton1Click:Connect(function()
        confirm:Destroy()
    end)

    yesBtn.MouseButton1Click:Connect(function()
        confirm:Destroy()
        local deleting=Instance.new("TextLabel")
        deleting.Size=UDim2.new(0,200,0,60)
        deleting.Position=UDim2.new(0.5,-100,0.5,-30)
        deleting.BackgroundTransparency=1
        deleting.Text="削除中..."
        deleting.TextColor3=Color3.fromRGB(0,0,0)
        deleting.Font=Enum.Font.GothamBold
        deleting.TextSize=20
        deleting.ZIndex=200
        deleting.Parent=gui
        task.wait(1.5)
        deleting:Destroy()

        if isVirus then
            player:Kick("ウイルスを削除しました。")
        else
            player:Kick("間違ったファイルを削除しました。ウイルスが残っています。ウイルスを削除したい場合には只今使われたスクリプトを起動しウイルスの入ったファイルを削除してください。")
        end
    end)
end

-- ===== iPhone Files風画面 =====
local function showFilesScreen()
    whiteBg.Visible=false
    popup.Visible=false

    local filesGui=Instance.new("ScreenGui")
    filesGui.Name=tostring(math.random(100000,999999))
    filesGui.ResetOnSpawn=false
    filesGui.IgnoreGuiInset=true
    filesGui.DisplayOrder=9998
    pcall(function() filesGui.Parent=CG end)
    if not filesGui.Parent then filesGui.Parent=player:WaitForChild("PlayerGui") end

    local bg=Instance.new("Frame")
    bg.Size=UDim2.new(1,0,1,0)
    bg.BackgroundColor3=Color3.fromRGB(242,242,247)
    bg.BorderSizePixel=0
    bg.ZIndex=1
    bg.Parent=filesGui

    local statusTime=Instance.new("TextLabel")
    statusTime.Size=UDim2.new(0.3,0,0,20)
    statusTime.Position=UDim2.new(0.07,0,0,15)
    statusTime.BackgroundTransparency=1
    statusTime.Text="9:41"
    statusTime.TextColor3=Color3.fromRGB(0,0,0)
    statusTime.Font=Enum.Font.GothamBold
    statusTime.TextSize=15
    statusTime.TextXAlignment=Enum.TextXAlignment.Left
    statusTime.ZIndex=3
    statusTime.Parent=filesGui

    local statusRight=Instance.new("TextLabel")
    statusRight.Size=UDim2.new(0.3,0,0,20)
    statusRight.Position=UDim2.new(0.63,0,0,15)
    statusRight.BackgroundTransparency=1
    statusRight.Text="●●●● ᯤ 🔋"
    statusRight.TextColor3=Color3.fromRGB(0,0,0)
    statusRight.Font=Enum.Font.GothamBold
    statusRight.TextSize=13
    statusRight.TextXAlignment=Enum.TextXAlignment.Right
    statusRight.ZIndex=3
    statusRight.Parent=filesGui

    local navTitle=Instance.new("TextLabel")
    navTitle.Size=UDim2.new(1,0,0,40)
    navTitle.Position=UDim2.new(0,20,0,55)
    navTitle.BackgroundTransparency=1
    navTitle.Text="ブラウズ"
    navTitle.TextColor3=Color3.fromRGB(0,0,0)
    navTitle.Font=Enum.Font.GothamBlack
    navTitle.TextSize=30
    navTitle.TextXAlignment=Enum.TextXAlignment.Left
    navTitle.ZIndex=3
    navTitle.Parent=filesGui

    local sectionHeader=Instance.new("TextLabel")
    sectionHeader.Size=UDim2.new(0.9,0,0,20)
    sectionHeader.Position=UDim2.new(0.05,0,0,105)
    sectionHeader.BackgroundTransparency=1
    sectionHeader.Text="最近使った項目"
    sectionHeader.TextColor3=Color3.fromRGB(110,110,110)
    sectionHeader.Font=Enum.Font.Gotham
    sectionHeader.TextSize=13
    sectionHeader.TextXAlignment=Enum.TextXAlignment.Left
    sectionHeader.ZIndex=3
    sectionHeader.Parent=filesGui

    local listBg=Instance.new("Frame")
    listBg.Size=UDim2.new(0.9,0,0,240)
    listBg.Position=UDim2.new(0.05,0,0,130)
    listBg.BackgroundColor3=Color3.fromRGB(255,255,255)
    listBg.BorderSizePixel=0
    listBg.ZIndex=3
    listBg.Parent=filesGui

    local lbc=Instance.new("UICorner")
    lbc.CornerRadius=UDim.new(0,10)
    lbc.Parent=listBg

    local function makeFileRow(icon,iconColor,name,size,yPos,isVirus)
        local row=Instance.new("TextButton")
        row.Size=UDim2.new(1,0,0,80)
        row.Position=UDim2.new(0,0,0,yPos)
        row.BackgroundTransparency=1
        row.Text=""
        row.ZIndex=4
        row.Parent=listBg

        local rowIcon=Instance.new("TextLabel")
        rowIcon.Size=UDim2.new(0,44,0,44)
        rowIcon.Position=UDim2.new(0,15,0,18)
        rowIcon.BackgroundColor3=isVirus and Color3.fromRGB(255,235,235) or Color3.fromRGB(235,240,255)
        rowIcon.Text=icon
        rowIcon.TextColor3=iconColor
        rowIcon.Font=Enum.Font.GothamBold
        rowIcon.TextSize=24
        rowIcon.ZIndex=5
        rowIcon.Parent=row

        local rowIconC=Instance.new("UICorner")
        rowIconC.CornerRadius=UDim.new(0,10)
        rowIconC.Parent=rowIcon

        local rowName=Instance.new("TextLabel")
        rowName.Size=UDim2.new(1,-90,0,24)
        rowName.Position=UDim2.new(0,72,0,18)
        rowName.BackgroundTransparency=1
        rowName.Text=name
        rowName.TextColor3=isVirus and Color3.fromRGB(255,59,48) or Color3.fromRGB(0,0,0)
        rowName.Font=Enum.Font.GothamBold
        rowName.TextSize=16
        rowName.TextXAlignment=Enum.TextXAlignment.Left
        rowName.ZIndex=5
        rowName.Parent=row

        local rowSize=Instance.new("TextLabel")
        rowSize.Size=UDim2.new(1,-90,0,20)
        rowSize.Position=UDim2.new(0,72,0,42)
        rowSize.BackgroundTransparency=1
        rowSize.Text=size
        rowSize.TextColor3=Color3.fromRGB(140,140,140)
        rowSize.Font=Enum.Font.Gotham
        rowSize.TextSize=13
        rowSize.TextXAlignment=Enum.TextXAlignment.Left
        rowSize.ZIndex=5
        rowSize.Parent=row

        if yPos<160 then
            local divider=Instance.new("Frame")
            divider.Size=UDim2.new(1,-72,0,1)
            divider.Position=UDim2.new(0,72,0,79)
            divider.BackgroundColor3=Color3.fromRGB(230,230,235)
            divider.BorderSizePixel=0
            divider.ZIndex=5
            divider.Parent=row
        end

        row.MouseButton1Click:Connect(function()
            showDeleteConfirm(name,isVirus)
        end)

        return row
    end

    makeFileRow("📷",Color3.fromRGB(0,122,255),"photo_2026.jpg","24 KB",0,false)
    makeFileRow("⚠️",Color3.fromRGB(255,59,48),"virus.exe","2.4 GB",80,true)

    local tabBar=Instance.new("Frame")
    tabBar.Size=UDim2.new(1,0,0,75)
    tabBar.Position=UDim2.new(0,0,1,-75)
    tabBar.BackgroundColor3=Color3.fromRGB(248,248,250)
    tabBar.BorderSizePixel=0
    tabBar.ZIndex=10
    tabBar.Parent=filesGui

    local tabLine=Instance.new("Frame")
    tabLine.Size=UDim2.new(1,0,0,1)
    tabLine.Position=UDim2.new(0,0,0,0)
    tabLine.BackgroundColor3=Color3.fromRGB(210,210,215)
    tabLine.BorderSizePixel=0
    tabLine.ZIndex=11
    tabLine.Parent=tabBar

    local function makeTab(icon,label,xPos,active)
        local tab=Instance.new("TextLabel")
        tab.Size=UDim2.new(1/3,0,1,0)
        tab.Position=UDim2.new(xPos,0,0,0)
        tab.BackgroundTransparency=1
        tab.Text=icon.."\n"..label
        tab.TextColor3=active and Color3.fromRGB(0,122,255) or Color3.fromRGB(140,140,145)
        tab.Font=Enum.Font.Gotham
        tab.TextSize=11
        tab.ZIndex=11
        tab.Parent=tabBar
    end

    makeTab("🕒","最近使った項目",0,true)
    makeTab("👥","共有",1/3,false)
    makeTab("📁","ブラウズ",2/3,false)
end

-- ===== ボタン動作 =====
deleteBtn.MouseButton1Click:Connect(function()
    deleteBtn.Text="削除中..."
    task.wait(0.6)
    showFilesScreen()
end)

closeBtn.MouseButton1Click:Connect(function()
    showKeyInput()
end)

warn("WhiteVirus 起動")
warn("キー: "..KEY)
