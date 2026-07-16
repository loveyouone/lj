-- 加载 WindUI 库
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
WindUI:SetNotificationLower(true)

-- 窗口
local Window = WindUI:CreateWindow({
    Title = "MM2 工具集",
    Author = "by 用户"
})

Window:ToggleTransparency(true)

-- ===== 基础功能 =====
local MainTab = Window:Tab({
    Title = "基础功能",
    Icon = "house"
})

local infJumpEnabled = false
local infJumpConn
MainTab:Toggle({
    Title = "无限跳跃",
    Callback = function(v)
        infJumpEnabled = v
        if v then
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

local noClipEnabled = false
local noClipConn
MainTab:Toggle({
    Title = "穿墙",
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

local xrayEnabled = false
local xrayConn
MainTab:Toggle({
    Title = "透视",
    Callback = function(v)
        xrayEnabled = v
        if v then
            if not xrayConn then
                xrayConn = game:GetService("RunService").Heartbeat:Connect(function()
                    if xrayEnabled then
                        for _, obj in ipairs(workspace:GetDescendants()) do
                            if obj:IsA("BasePart") then
                                local isPlayer = obj:FindFirstAncestorOfClass("Model") and game:GetService("Players"):GetPlayerFromCharacter(obj:FindFirstAncestorOfClass("Model"))
                                if not isPlayer then
                                    obj.LocalTransparencyModifier = 0.4
                                end
                            end
                        end
                    end
                end)
            end
        else
            if xrayConn then
                xrayConn:Disconnect()
                xrayConn = nil
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        local isPlayer = obj:FindFirstAncestorOfClass("Model") and game:GetService("Players"):GetPlayerFromCharacter(obj:FindFirstAncestorOfClass("Model"))
                        if not isPlayer then
                            obj.LocalTransparencyModifier = 0
                        end
                    end
                end
            end
        end
    end
})

MainTab:Slider({
    Title = "移动速度",
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

MainTab:Slider({
    Title = "跳跃高度",
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

-- 分隔线
MainTab:Divider()

-- 自动捡枪功能
local autoGunEnabled = false
local autoGunConn
local savedGunPos = nil

MainTab:Toggle({
    Title = "自动捡枪",
    Callback = function(v)
        autoGunEnabled = v
        if v then
            if not autoGunConn then
                autoGunConn = game:GetService("RunService").Heartbeat:Connect(function()
                    if autoGunEnabled then
                        local char = game.Players.LocalPlayer.Character
                        if char then
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local gunDrop = workspace:FindFirstChild("GunDrop", true)
                                if gunDrop then
                                    local part = gunDrop:IsA("BasePart") and gunDrop or gunDrop:FindFirstChildWhichIsA("BasePart")
                                    if part then
                                        if not savedGunPos then
                                            savedGunPos = hrp.CFrame
                                        end
                                        hrp.CFrame = part.CFrame
                                        task.wait(0.3)
                                        if savedGunPos then
                                            hrp.CFrame = savedGunPos
                                            savedGunPos = nil
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        else
            if autoGunConn then
                autoGunConn:Disconnect()
                autoGunConn = nil
                savedGunPos = nil
            end
        end
    end
})

-- ===== 透视 =====
local EspTab = Window:Tab({
    Title = "透视",
    Icon = "eye"
})

-- ESP 状态（完全局部化）
local espState = {
    running = false,
    heartbeatConn = nil,
    playerAddedConn = nil,
    playerRemovingConn = nil,
    playerEspData = {},
    gunEspData = nil,
    gunDropCache = nil,
}

-- 销毁所有ESP对象
local function destroyAllESPObjects()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BillboardGui") and (obj.Name == "ESP_Tag" or obj.Name == "DroppedGunESP") then
            obj:Destroy()
        end
        if obj:IsA("Highlight") and (obj.Name == "PlayerHighlight" or obj.Name == "DroppedGunHighlight") then
            obj:Destroy()
        end
    end
end

-- 清理单个玩家的ESP和所有连接
local function cleanPlayerESP(player)
    local data = espState.playerEspData[player]
    if data then
        if data.highlight then data.highlight:Destroy() end
        if data.billboard then data.billboard:Destroy() end
        if data.connections then
            for _, conn in ipairs(data.connections) do
                conn:Disconnect()
            end
        end
        espState.playerEspData[player] = nil
    end
end

-- 停止ESP（彻底清理所有）
local function stopESP()
    if espState.heartbeatConn then
        espState.heartbeatConn:Disconnect()
        espState.heartbeatConn = nil
    end
    if espState.playerAddedConn then
        espState.playerAddedConn:Disconnect()
        espState.playerAddedConn = nil
    end
    if espState.playerRemovingConn then
        espState.playerRemovingConn:Disconnect()
        espState.playerRemovingConn = nil
    end
    
    -- 清理所有玩家ESP（包括连接）
    for player, _ in pairs(espState.playerEspData) do
        cleanPlayerESP(player)
    end
    espState.playerEspData = {}
    
    -- 清理枪支ESP
    if espState.gunEspData then
        if espState.gunEspData.highlight then espState.gunEspData.highlight:Destroy() end
        if espState.gunEspData.billboard then espState.gunEspData.billboard:Destroy() end
        espState.gunEspData = nil
    end
    espState.gunDropCache = nil
    
    destroyAllESPObjects()
    espState.running = false
end

local espEnabled = false

EspTab:Toggle({
    Title = "开启透视",
    Callback = function(v)
        espEnabled = v
        
        if v then
            if espState.running then
                stopESP()
            end
            
            local Players = game:GetService("Players")
            local RunService = game:GetService("RunService")
            local Workspace = game:GetService("Workspace")
            local LocalPlayer = Players.LocalPlayer

            if not LocalPlayer then
                repeat task.wait() until Players.LocalPlayer
                LocalPlayer = Players.LocalPlayer
            end

            destroyAllESPObjects()

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

                local connections = {}
                -- 监听背包变化
                local function onBackpackChanged()
                    updatePlayerESP(player)
                end
                local backpack = player:FindFirstChild("Backpack")
                if backpack then
                    local conn1 = backpack.ChildAdded:Connect(onBackpackChanged)
                    local conn2 = backpack.ChildRemoved:Connect(onBackpackChanged)
                    table.insert(connections, conn1)
                    table.insert(connections, conn2)
                end

                -- 监听角色中工具变化
                local function onCharacterChildChanged(child)
                    if child:IsA("Tool") then
                        updatePlayerESP(player)
                    end
                end
                local conn3 = character.ChildAdded:Connect(onCharacterChildChanged)
                local conn4 = character.ChildRemoved:Connect(onCharacterChildChanged)
                table.insert(connections, conn3)
                table.insert(connections, conn4)

                -- 监听角色重生
                local conn5 = player.CharacterAdded:Connect(function()
                    task.wait(0.2)
                    cleanPlayerESP(player)
                    setupPlayerESP(player)
                end)
                table.insert(connections, conn5)

                playerEspData[player] = {
                    highlight = highlight,
                    billboard = billboard,
                    textLabel = textLabel,
                    distLabel = distLabel,
                    weaponType = "CIVILIAN",
                    connections = connections,
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
            end

            -- 初始化现有玩家
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    pcall(setupPlayerESP, player)
                end
            end

            local playerAddedConn = Players.PlayerAdded:Connect(function(player)
                if player == LocalPlayer then return end
                pcall(setupPlayerESP, player)
            end)

            local playerRemovingConn = Players.PlayerRemoving:Connect(function(player)
                cleanPlayerESP(player)
            end)

            -- 枪支ESP
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

            local heartbeatConn = RunService.Heartbeat:Connect(function()
                for player, data in pairs(playerEspData) do
                    pcall(updatePlayerDistance, player, data)
                end
                pcall(updateGunESP)
            end)

            -- 保存状态
            espState.running = true
            espState.heartbeatConn = heartbeatConn
            espState.playerAddedConn = playerAddedConn
            espState.playerRemovingConn = playerRemovingConn
            espState.playerEspData = playerEspData
            espState.gunEspData = gunEspData
            espState.gunDropCache = gunDropCache
            
        else
            -- 关闭透视：彻底清理所有资源
            stopESP()
        end
    end
})

-- ===== 子弹追踪 =====
local BulletTab = Window:Tab({
    Title = "子弹追踪",
    Icon = "crosshair"
})

local bulletEnabled = false
local shootGui = nil

BulletTab:Toggle({
    Title = "开启子弹追踪",
    Callback = function(v)
        bulletEnabled = v
        if v then
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
                        -- 射击逻辑（瞄准躯干）
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
                            -- 瞄准躯干（胸部）：RootPart位置向下偏移1单位
                            return root.Position - Vector3.new(0, 1, 0)
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

            shootGui = screenGui
        else
            if shootGui then
                shootGui:Destroy()
                shootGui = nil
            end
        end
    end
})

-- ===== 传送 =====
local TeleportTab = Window:Tab({
    Title = "传送",
    Icon = "map-pin"
})

TeleportTab:Button({
    Title = "传送到枪支",
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

TeleportTab:Button({
    Title = "传送到警长",
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

TeleportTab:Button({
    Title = "传送到杀手",
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

TeleportTab:Button({
    Title = "传送到出生点",
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

-- ===== 杀手功能 =====
local MurderTab = Window:Tab({
    Title = "杀手功能",
    Icon = "skull"
})

local killAllEnabled = false
local killAllConn

MurderTab:Toggle({
    Title = "自动杀死全部玩家",
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
