-- 加载WindUI库（核心依赖）
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not success then
    warn("WindUI库加载失败，请检查网络或链接有效性！")
    return
end

-- 创建主窗口
local Window = WindUI:CreateWindow({
    Title = "xiao xin",
    Icon = "crown",
    Author = "xiao xin",
    AuthorImage = 90840643379863,
    Folder = "CloudHub",
    Size = UDim2.fromOffset(560, 360),
    Transparent = true,
    User = {
        Enabled = true,
        Callback = function() print("窗口已打开") end,
        Anonymous = false
    },
})

-- 编辑窗口打开按钮样式
Window:EditOpenButton({
    Title = "xiao xin",
    Icon = "crown",
    CornerRadius = UDim.new(1, 0),
    StrokeThickness = 3,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(144, 238, 144)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 0))
    }),
    Draggable = true
})

-- 工具函数（简化控件创建）
local function Tab(title)
    return Window:Tab({Title = title, Icon = "eye"})
end

-- 本地通用标签（基础属性设置）
local GeneralTab = Tab("本地通用")
local loops = {
    WalkSpeed = false,
    JumpPower = false,
    AutoApply = false
}
local gravityValue = 196.2
local nightVisionEnabled = false

-- 步行速度调节
GeneralTab:Slider({
    Title = "步行速度!",
    Step = 1,
    Value = {Min = 16, Max = 400, Default = 16},
    Callback = function(Speed)
        loops.WalkSpeed = false
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = Speed
        end
    end
})

-- 跳跃高度调节
GeneralTab:Slider({
    Title = "跳跃高度!",
    Step = 1,
    Value = {Min = 50, Max = 400, Default = 50},
    Callback = function(JumpPower)
        loops.JumpPower = false
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = JumpPower
        end
    end
})

-- 重力设置
GeneralTab:Input({
    Title = "重力设置!",
    Desc = "输入重力值（默认196.2）",
    Value = tostring(gravityValue),
    Placeholder = "例如：100",
    Callback = function(Gravity)
        local num = tonumber(Gravity)
        if num then
            gravityValue = num
            game.Workspace.Gravity = num
        end
    end
})

-- 夜视功能
GeneralTab:Toggle({
    Title = "夜视",
    Value = false,
    Callback = function(Enabled)
        nightVisionEnabled = Enabled
        game.Lighting.Ambient = Enabled and Color3.new(0.8, 0.8, 0.8) or Color3.new(0.1, 0.1, 0.1)
    end
})

-- 自动应用基础属性（防重置）
GeneralTab:Toggle({
    Title = "自动应用属性",
    Value = false,
    Callback = function(Enabled)
        loops.AutoApply = Enabled
        if Enabled then
            spawn(function()
                while loops.AutoApply do
                    task.wait(0.5)
                    local char = game.Players.LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then
                        -- 保持当前设置的属性（而非固定默认值）
                        local humanoid = char.Humanoid
                        humanoid.WalkSpeed = humanoid.WalkSpeed
                        humanoid.JumpPower = humanoid.JumpPower
                    end
                end
            end)
        end
    end
})

-- 战斗标签（战斗功能设置）
local BattleTab = Tab("战斗")
local hitMOD = "meleepunch" -- 默认攻击方式：普通拳
local autokill = false
local autostomp = false
local grabplay = false

-- 物品栏数量调节
BattleTab:Slider({
    Title = "物品栏数量",
    Step = 1,
    Value = {Min = 1, Max = 9, Default = 6},
    Callback = function(value)
        local success, inventory = pcall(function()
            return require(game.ReplicatedStorage.devv.client.Objects.v3item.modules.inventory)
        end)
        if success then
            inventory.numSlots = value
        else
            warn("物品栏模块加载失败：" .. inventory)
        end
    end
})

-- 攻击方式选择
BattleTab:Dropdown({
    Title = "攻击方式",
    Values = {"超级拳", "普通拳"},
    Value = "普通拳",
    Callback = function(value)
        hitMOD = value == "超级拳" and "meleemegapunch" or "meleepunch"
    end
})

-- 战斗光环开关
BattleTab:Toggle({
    Title = "杀戮光环",
    Value = false,
    Callback = function(state)
        autokill = state
    end
})

BattleTab:Toggle({
    Title = "踩踏光环",
    Value = false,
    Callback = function(state)
        autostomp = state
    end
})

BattleTab:Toggle({
    Title = "抓取光环",
    Value = false,
    Callback = function(state)
        grabplay = state
    end
})

-- 战斗核心逻辑（补全原缺失代码）
game:GetService("RunService").Heartbeat:Connect(function()
    pcall(function()
        local localPlayer = game.Players.LocalPlayer
        local char = localPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end

        -- 自动杀戮逻辑（基于光环开关）
        if autokill then
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (char.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if distance <= 15 then -- 攻击范围：15 studs
                        -- 触发对应攻击模式
                        game.ReplicatedStorage:FindFirstChild(hitMOD, true)?.FireServer()
                    end
                end
            end
        end

        -- 踩踏光环逻辑（靠近时触发）
        if autostomp and char:FindFirstChild("Humanoid") then
            for _, part in ipairs(workspace:GetPartsInPart(char.HumanoidRootPart)) do
                local humanoid = part.Parent:FindFirstChild("Humanoid")
                if humanoid and humanoid.Parent ~= char then
                    humanoid.Health = 0
                end
            end
        end

        -- 抓取光环逻辑（简化实现）
        if grabplay and char:FindFirstChild("HumanoidRootPart") then
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (char.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if distance <= 10 then
                        player.Character.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                    end
                end
            end
        end
    end)
end)

print("脚本加载完成！WindUI窗口已创建")
