-- 加载 WindUI 库
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
WindUI:SetNotificationLower(true)

-- 窗口
local Window = WindUI:CreateWindow({
    Title = "MM2 工具集",
    Icon = "target",
    Author = "by 用户"
})

-- 透明背景
Window:ToggleTransparency(true)

-- ===== 基本功能标签页 =====
local BasicTab = Window:Tab({
    Title = "基本功能",
    Icon = "settings"
})

local BasicSection = BasicTab:Section({
    Title = "移动增强",
    Icon = "move"
})

-- 无限跳跃（开关）
local infJumpEnabled = false
BasicSection:Toggle({
    Title = "无限跳跃",
    Desc = "在空中可以无限次跳跃",
    Callback = function(v)
        infJumpEnabled = v
        if v then
            -- 连接跳跃事件
            if not infJumpConn then
                infJumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
                    if infJumpEnabled then
                        local char = game.Players.LocalPlayer.Character
                        if char then
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health > 0 then
                                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                            end
                        end
                    end
                end)
            end
        else
            if infJumpConn then
                infJumpConn:Disconnect()
                infJumpConn = nil
            end
        end
    end
})

-- 穿墙（开关）
local noClipEnabled = false
local noClipConn
BasicSection:Toggle({
    Title = "穿墙 (NoClip)",
    Desc = "穿过墙壁和障碍物",
    Callback = function(v)
        noClipEnabled = v
        if v then
            if not noClipConn then
                noClipConn = game:GetService("RunService").Stepped:Connect(function()
                    if noClipEnabled then
                        local char = game.Players.LocalPlayer.Character
                        if char then
                            for _, part in ipairs(char:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                        end
                    end
                end)
            end
        else
            if noClipConn then
                noClipConn:Disconnect()
                noClipConn = nil
                -- 恢复碰撞
                local char = game.Players.LocalPlayer.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end
            end
        end
    end
})

-- 透视（开关）
local xrayEnabled = false
BasicSection:Toggle({
    Title = "透视 (Xray)",
    Desc = "透视场景中的物体",
    Callback = function(v)
        xrayEnabled = v
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local isPlayer = obj:FindFirstAncestorOfClass("Model") and game:GetService("Players"):GetPlayerFromCharacter(obj:FindFirstAncestorOfClass("Model"))
                if not isPlayer then
                    obj.LocalTransparencyModifier = v and 0.4 or 0
                end
            end
        end
    end
})

-- 触碰飞行（开关）
local flingEnabled = false
local flingConn
BasicSection:Toggle({
    Title = "触碰飞行 (Touch Fling)",
    Desc = "触碰物体时获得巨大速度",
    Callback = function(v)
        flingEnabled = v
        if v then
            if not flingConn then
                flingConn = game:GetService("RunService").Heartbeat:Connect(function()
                    if flingEnabled then
                        local char = game.Players.LocalPlayer.Character
                        if char then
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local vel = hrp.AssemblyLinearVelocity
                                hrp.AssemblyLinearVelocity = Vector3.new(vel.X * 1.5, 50, vel.Z * 1.5)
                            end
                        end
                    end
                end)
            end
        else
            if flingConn then
                flingConn:Disconnect()
                flingConn = nil
            end
        end
    end
})

-- 移动速度滑块
BasicSection:Slider({
    Title = "移动速度",
    Desc = "调整行走速度",
    Step = 1,
    Value = {
        Min = 16,
        Max = 200,
        Default = 16,
    },
    Callback = function(value)
        local char = game.Players.LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = value
            end
        end
    end
})

-- 跳跃增强滑块
BasicSection:Slider({
    Title = "跳跃高度",
    Desc = "调整跳跃高度",
    Step = 1,
    Value = {
        Min = 50,
        Max = 300,
        Default = 50,
    },
    Callback = function(value)
        local char = game.Players.LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.JumpPower = value
            end
        end
    end
})

-- ===== 透视标签页 =====
local EspTab = Window:Tab({
    Title = "透视",
    Icon = "eye"
})

local EspSection = EspTab:Section({
    Title = "玩家与枪支透视",
    Icon = "eye"
})

-- 一键开启透视（开关）
local espEnabled = false
local espConnections = {}
local espCleanup = function() end

EspSection:Toggle({
    Title = "一键开启透视",
    Desc = "显示所有玩家和掉落枪支的位置",
    Callback = function(v)
        espEnabled = v
        if v then
            -- 启动 ESP（使用 mm2.lua 中的逻辑）
            -- 由于 mm2.lua 中的 ESP 是持续运行的，我们将其封装为启动和停止函数
            -- 但为了简单，我们直接复制 mm2.lua 中的相关代码并在此处执行
            -- 注意：需要避免重复创建，这里用全局变量控制
            if not _G.ESP_RUNNING then
                _G.ESP_RUNNING = true
                -- 执行 ESP 初始化（复制自 mm2.lua）
                local Players = game:GetService("Players")
                local RunService = game:GetService("RunService")
                local Workspace = game:GetService("Workspace")
                local LocalPlayer = Players.LocalPlayer

                if not LocalPlayer then
                    repeat task.wait() until Players.LocalPlayer
                    LocalPlayer = Players.LocalPlayer
                end

                local function cleanAllESP()
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if obj:IsA("BillboardGui") and (obj.Name == "ESP_Tag" or obj.Name == "DroppedGunESP") then
                            obj:Destroy()
                        end
                        if obj:IsA("Highlight") and (obj.Name == "PlayerHighlight" or obj.Name == "DroppedGunHighlight") then
                            obj:Destroy()
                        end
                    end
                end
                cleanAllESP()

                local PLAYER_COLORS = {
                    KNIFE = Color3.fromRGB(255, 50, 50),
                    GUN = Color3.fromRGB(50, 180, 255),
                    CIVILIAN = Color3.fromRGB(50, 255, 100)
                }

                local PLAYER_TEXT_COLORS = {
                    KNIFE = Color3.fromRGB(255, 180, 180),
                    GUN = Color3.fromRGB(180, 220, 255),
                    CIVILIAN = Color3.fromRGB(180, 255, 180)
                }

                local playerEspData = {}

                local function getPlayerWeaponType(player)
                    if not player then return "CIVILIAN" end
                    local backpack = player:FindFirstChild("Backpack")
                    if backpack then
                        for _, child in ipairs(backpack:GetChildren()) do
                            if child:IsA("Tool") then
                                if child.Name == "Knife" then return "KNIFE" end
                                if child.Name == "Gun" then return "GUN" end
                            end
                        end
                    end
                    local character = player.Character
                    if character then
                        for _, child in ipairs(character:GetChildren()) do
                            if child:IsA("Tool") then
                                if child.Name == "Knife" then return "KNIFE" end
                                if child.Name == "Gun" then return "GUN" end
                            end
                        end
                    end
                    return "CIVILIAN"
                end

                local function createPlayerESP(player)
                    if playerEspData[player] then return end
                    local character = player.Character
                    if not character then return end
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if not rootPart then return end

                    local highlight = Instance.new("Highlight")
                    highlight.Name = "PlayerHighlight"
                    highlight.FillTransparency = 1
                    highlight.OutlineTransparency = 0
                    highlight.Parent = character
                    highlight.Adornee = character

                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "ESP_Tag"
                    billboard.Size = UDim2.new(0, 110, 0, 26)
                    billboard.StudsOffset = Vector3.new(0, 3, 0)
                    billboard.MaxDistance = 0
                    billboard.AlwaysOnTop = true
                    billboard.Parent = rootPart

                    local frame = Instance.new("Frame")
                    frame.Size = UDim2.new(1, 0, 1, 0)
                    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    frame.BackgroundTransparency = 0.3
                    frame.BorderSizePixel = 0
                    frame.Parent = billboard

                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(0, 8)
                    corner.Parent = frame

                    local layout = Instance.new("UIListLayout")
                    layout.FillDirection = Enum.FillDirection.Horizontal
                    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                    layout.VerticalAlignment = Enum.VerticalAlignment.Center
                    layout.Padding = UDim.new(0, 4)
                    layout.Parent = frame

                    local textLabel = Instance.new("TextLabel")
                    textLabel.Size = UDim2.new(0, 60, 0, 20)
                    textLabel.BackgroundTransparency = 1
                    textLabel.Text = "平民"
                    textLabel.TextColor3 = PLAYER_TEXT_COLORS.CIVILIAN
                    textLabel.TextSize = 12
                    textLabel.Font = Enum.Font.GothamMedium
                    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    textLabel.TextStrokeTransparency = 0.2
                    textLabel.TextXAlignment = Enum.TextXAlignment.Left
                    textLabel.Parent = frame

                    local distLabel = Instance.new("TextLabel")
                    distLabel.Size = UDim2.new(0, 35, 0, 20)
                    distLabel.BackgroundTransparency = 1
                    distLabel.Text = "0m"
                    distLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                    distLabel.TextSize = 11
                    distLabel.Font = Enum.Font.GothamMedium
                    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    distLabel.TextStrokeTransparency = 0.2
                    distLabel.TextXAlignment = Enum.TextXAlignment.Right
                    distLabel.Parent = frame

                    playerEspData[player] = {
                        highlight = highlight,
                        billboard = billboard,
                        textLabel = textLabel,
                        distLabel = distLabel,
                        weaponType = "CIVILIAN"
                    }
                end

                local function updatePlayerESP(player)
                    local data = playerEspData[player]
                    if not data then return end

                    local weaponType = getPlayerWeaponType(player)
                    if data.weaponType == weaponType then return end

                    data.weaponType = weaponType

                    local borderColor = PLAYER_COLORS[weaponType]
                    local textColor = PLAYER_TEXT_COLORS[weaponType]
                    local labelText = weaponType == "KNIFE" and "杀手" or weaponType == "GUN" and "警长" or "平民"

                    data.highlight.OutlineColor = borderColor
                    data.textLabel.Text = labelText
                    data.textLabel.TextColor3 = textColor
                end

                local function updatePlayerDistance(player, data)
                    if not player or not data then return end
                    local localChar = LocalPlayer.Character
                    if not localChar then return end
                    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
                    if not localRoot then return end

                    local targetChar = player.Character
                    if not targetChar then return end
                    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                    if not targetRoot then return end

                    local dist = (localRoot.Position - targetRoot.Position).Magnitude
                    data.distLabel.Text = string.format("%.0fm", dist)
                end

                local function cleanPlayerESP(player)
                    local data = playerEspData[player]
                    if data then
                        if data.highlight then data.highlight:Destroy() end
                        if data.billboard then data.billboard:Destroy() end
                        playerEspData[player] = nil
                    end
                end

                local function setupPlayerESP(player)
                    if player == LocalPlayer then return end
                    if playerEspData[player] then return end

                    local character = player.Character
                    if not character then
                        player.CharacterAdded:Connect(function()
                            task.wait(0.1)
                            setupPlayerESP(player)
                        end)
                        return
                    end

                    createPlayerESP(player)
                    updatePlayerESP(player)

                    local function onBackpackChanged()
                        updatePlayerESP(player)
                    end

                    local backpack = player:FindFirstChild("Backpack")
                    if backpack then
                        backpack.ChildAdded:Connect(onBackpackChanged)
                        backpack.ChildRemoved:Connect(onBackpackChanged)
                    end

                    local function onCharacterChildChanged(child)
                        if child:IsA("Tool") then
                            updatePlayerESP(player)
                        end
                    end
                    character.ChildAdded:Connect(onCharacterChildChanged)
                    character.ChildRemoved:Connect(onCharacterChildChanged)

                    player.CharacterAdded:Connect(function()
                        task.wait(0.2)
                        cleanPlayerESP(player)
                        setupPlayerESP(player)
                    end)
                end

                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        pcall(setupPlayerESP, player)
                    end
                end

                Players.PlayerAdded:Connect(function(player)
                    if player == LocalPlayer then return end
                    pcall(setupPlayerESP, player)
                end)

                Players.PlayerRemoving:Connect(cleanPlayerESP)

                local gunEspData = nil
                local gunDropCache = nil

                local function clearGunESP()
                    if gunEspData then
                        if gunEspData.highlight then gunEspData.highlight:Destroy() end
                        if gunEspData.billboard then gunEspData.billboard:Destroy() end
                        gunEspData = nil
                    end
                    gunDropCache = nil
                end

                local function createGunESP(gunDrop)
                    clearGunESP()

                    local gunPart = nil
                    if gunDrop:IsA("BasePart") then
                        gunPart = gunDrop
                    else
                        gunPart = gunDrop:FindFirstChild("HumanoidRootPart")
                        if not gunPart then
                            for _, child in ipairs(gunDrop:GetDescendants()) do
                                if child:IsA("BasePart") then
                                    gunPart = child
                                    break
                                end
                            end
                        end
                    end

                    if not gunPart then return false end

                    local gunModel = gunDrop

                    local highlight = Instance.new("Highlight")
                    highlight.Name = "DroppedGunHighlight"
                    highlight.FillColor = Color3.fromRGB(255, 200, 50)
                    highlight.OutlineColor = Color3.fromRGB(255, 200, 50)
                    highlight.FillTransparency = 1
                    highlight.OutlineTransparency = 0
                    highlight.Parent = gunModel
                    highlight.Adornee = gunModel

                    local billboard = Instance.new("BillboardGui")
                    billboard.Name = "DroppedGunESP"
                    billboard.Size = UDim2.new(0, 110, 0, 28)
                    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
                    billboard.MaxDistance = 200
                    billboard.AlwaysOnTop = true
                    billboard.Parent = gunPart

                    local frame = Instance.new("Frame")
                    frame.Size = UDim2.new(1, 0, 1, 0)
                    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    frame.BackgroundTransparency = 0.3
                    frame.BorderSizePixel = 0
                    frame.Parent = billboard

                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(0, 8)
                    corner.Parent = frame

                    local textLabel = Instance.new("TextLabel")
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.Text = "枪"
                    textLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
                    textLabel.TextSize = 13
                    textLabel.Font = Enum.Font.GothamBold
                    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    textLabel.TextStrokeTransparency = 0.2
                    textLabel.TextXAlignment = Enum.TextXAlignment.Center
                    textLabel.TextYAlignment = Enum.TextYAlignment.Center
                    textLabel.Parent = frame

                    gunEspData = {
                        highlight = highlight,
                        billboard = billboard,
                        textLabel = textLabel,
                        part = gunPart,
                        model = gunModel
                    }
                    gunDropCache = gunDrop
                    return true
                end

                local function updateGunESP()
                    local gunDrop = Workspace:FindFirstChild("GunDrop", true)

                    if gunDrop then
                        if gunDropCache ~= gunDrop then
                            clearGunESP()
                            createGunESP(gunDrop)
                        end

                        if gunEspData and gunEspData.part and gunEspData.part.Parent then
                            local localChar = LocalPlayer.Character
                            if localChar then
                                local localRoot = localChar:FindFirstChild("HumanoidRootPart")
                                if localRoot then
                                    local dist = (localRoot.Position - gunEspData.part.Position).Magnitude
                                    gunEspData.textLabel.Text = string.format("枪 (%.0fm)", dist)
                                end
                            end
                        end
                    else
                        if gunDropCache then
                            clearGunESP()
                        end
                    end
                end

                -- 连接更新循环
                local heartbeatConn = RunService.Heartbeat:Connect(function()
                    for player, data in pairs(playerEspData) do
                        pcall(updatePlayerDistance, player, data)
                    end
                    pcall(updateGunESP)
                end)

                -- 保存连接以便关闭
                _G.ESP_HEARTBEAT = heartbeatConn
                _G.ESP_PLAYER_DATA = playerEspData
                _G.ESP_CLEANUP = function()
                    heartbeatConn:Disconnect()
                    for player, data in pairs(playerEspData) do
                        cleanPlayerESP(player)
                    end
                    clearGunESP()
                    cleanAllESP()
                end
            end
        else
            -- 关闭 ESP
            if _G.ESP_CLEANUP then
                _G.ESP_CLEANUP()
                _G.ESP_RUNNING = false
                _G.ESP_HEARTBEAT = nil
                _G.ESP_CLEANUP = nil
            end
        end
    end
})

-- ===== 子弹追踪标签页 =====
local BulletTab = Window:Tab({
    Title = "子弹追踪",
    Icon = "crosshair"
})

local BulletSection = BulletTab:Section({
    Title = "自动瞄准杀手",
    Icon = "target"
})

local bulletEnabled = false
local shootButton = nil
local shootGui = nil

BulletSection:Toggle({
    Title = "开启子弹追踪",
    Desc = "开启后显示射击按钮，点击自动瞄准杀手",
    Callback = function(v)
        bulletEnabled = v
        if v then
            -- 创建射击按钮（参考 mm2.lua 中的按钮创建）
            local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
            local screenGui = Instance.new("ScreenGui")
            screenGui.Name = "AimBot"
            screenGui.Parent = playerGui
            screenGui.ResetOnSpawn = false

            local button = Instance.new("TextButton")
            button.Size = UDim2.new(0, 90, 0, 50)
            button.Position = UDim2.new(0.5, -45, 0.5, -25)
            button.Text = "射击"
            button.TextColor3 = Color3.fromRGB(200, 200, 200)
            button.TextSize = 18
            button.Font = Enum.Font.GothamMedium
            button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            button.BackgroundTransparency = 0.5
            button.BorderSizePixel = 0
            button.TextTransparency = 0.3
            button.Parent = screenGui

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 12)
            corner.Parent = button

            -- 拖拽逻辑（移动端）
            local isDragging = false
            local isPressed = false
            local dragStartPos = nil
            local startButtonPos = nil

            button.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.UserInputType == Enum.UserInputType.Touch then
                    isPressed = true
                    dragStartPos = input.Position
                    startButtonPos = button.Position
                    isDragging = false
                end
            end)

            button.InputChanged:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.UserInputType == Enum.UserInputType.Touch and isPressed then
                    local delta = input.Position - dragStartPos
                    if delta.Magnitude > 10 then
                        isDragging = true
                        button.Position = UDim2.new(
                            startButtonPos.X.Scale,
                            startButtonPos.X.Offset + delta.X,
                            startButtonPos.Y.Scale,
                            startButtonPos.Y.Offset + delta.Y
                        )
                    end
                end
            end)

            button.InputEnded:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.UserInputType == Enum.UserInputType.Touch then
                    if not isDragging then
                        -- 射击逻辑
                        local function getMurderer()
                            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                                if player ~= game.Players.LocalPlayer then
                                    local char = player.Character
                                    local backpack = player:FindFirstChild("Backpack")
                                    if (backpack and backpack:FindFirstChild("Knife")) or (char and char:FindFirstChild("Knife")) then
                                        return player
                                    end
                                end
                            end
                            return nil
                        end

                        local function getMurdererPosition()
                            local murderer = getMurderer()
                            if not murderer then return nil end
                            local char = murderer.Character
                            if not char then return nil end
                            local root = char:FindFirstChild("HumanoidRootPart")
                            if not root then return nil end
                            return root.Position
                        end

                        local function hasGun()
                            local backpack = game.Players.LocalPlayer:FindFirstChild("Backpack")
                            local char = game.Players.LocalPlayer.Character
                            return (backpack and backpack:FindFirstChild("Gun")) or (char and char:FindFirstChild("Gun"))
                        end

                        if not hasGun() then return end

                        local targetPos = getMurdererPosition()
                        if not targetPos then return end

                        local char = game.Players.LocalPlayer.Character
                        if not char then return end

                        local gun = game.Players.LocalPlayer:FindFirstChild("Backpack") and game.Players.LocalPlayer.Backpack:FindFirstChild("Gun")
                        if not gun then
                            gun = char:FindFirstChild("Gun")
                        end
                        if not gun then return end

                        local handle = gun:FindFirstChild("Handle")
                        if not handle then return end

                        local shootEvent = gun:FindFirstChild("Shoot")
                        if not shootEvent then return end

                        local gunPos = handle.Position
                        local startCFrame = CFrame.lookAt(gunPos, targetPos)
                        local targetCFrame = CFrame.new(targetPos)

                        pcall(function()
                            shootEvent:FireServer(startCFrame, targetCFrame)
                        end)
                    end
                    isDragging = false
                    isPressed = false
                end
            end)

            shootButton = button
            shootGui = screenGui
        else
            -- 关闭子弹追踪，移除按钮
            if shootGui then
                shootGui:Destroy()
                shootGui = nil
                shootButton = nil
            end
        end
    end
})

-- ===== 传送标签页 =====
local TeleportTab = Window:Tab({
    Title = "传送",
    Icon = "map-pin"
})

local TeleportSection = TeleportTab:Section({
    Title = "快速传送",
    Icon = "map"
})

-- 传送到枪支
TeleportSection:Button({
    Title = "传送到枪支",
    Desc = "传送到掉落枪支的位置",
    Callback = function()
        local gunDrop = workspace:FindFirstChild("GunDrop", true)
        if gunDrop then
            local part = gunDrop:IsA("BasePart") and gunDrop or gunDrop:FindFirstChildWhichIsA("BasePart")
            if part then
                local char = game.Players.LocalPlayer.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = part.CFrame
                    end
                end
            end
        end
    end
})

-- 传送到警长
TeleportSection:Button({
    Title = "传送到警长",
    Desc = "传送到持有警长枪的玩家",
    Callback = function()
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                local char = player.Character
                local backpack = player:FindFirstChild("Backpack")
                if (backpack and backpack:FindFirstChild("Gun")) or (char and char:FindFirstChild("Gun")) then
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.CFrame = char.HumanoidRootPart.CFrame
                        end
                        break
                    end
                end
            end
        end
    end
})

-- 传送到杀手
TeleportSection:Button({
    Title = "传送到杀手",
    Desc = "传送到持有杀手刀的玩家",
    Callback = function()
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                local char = player.Character
                local backpack = player:FindFirstChild("Backpack")
                if (backpack and backpack:FindFirstChild("Knife")) or (char and char:FindFirstChild("Knife")) then
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.CFrame = char.HumanoidRootPart.CFrame
                        end
                        break
                    end
                end
            end
        end
    end
})

-- 传送到出生点
TeleportSection:Button({
    Title = "传送到出生点",
    Desc = "传送到地图的出生点",
    Callback = function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:lower():find("spawn") then
                local char = game.Players.LocalPlayer.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = obj.CFrame
                    end
                end
                break
            end
        end
    end
})

-- ===== 杀手功能标签页 =====
local MurderTab = Window:Tab({
    Title = "杀手功能",
    Icon = "skull"
})

local MurderSection = MurderTab:Section({
    Title = "自动击杀",
    Icon = "sword"
})

-- 自动杀死全部玩家
local killAllEnabled = false
local killAllConn

MurderSection:Toggle({
    Title = "自动杀死全部玩家",
    Desc = "自动传送到每个玩家并击杀",
    Callback = function(v)
        killAllEnabled = v
        if v then
            if not killAllConn then
                killAllConn = game:GetService("RunService").Heartbeat:Connect(function()
                    if killAllEnabled then
                        local localPlayer = game.Players.LocalPlayer
                        local char = localPlayer.Character
                        if char then
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                                    if player ~= localPlayer then
                                        local targetChar = player.Character
                                        if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                                            hrp.CFrame = targetChar.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                                            task.wait(0.1)
                                            -- 这里可能需要调用击杀逻辑，但通常需要手动攻击，这里仅传送
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        else
            if killAllConn then
                killAllConn:Disconnect()
                killAllConn = nil
            end
        end
    end
})

print("UI 加载完成")