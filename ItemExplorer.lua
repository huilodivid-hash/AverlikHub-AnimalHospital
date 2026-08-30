-- ══════════════════════════════════════════════════════════════════════════════════════
-- 🔍 ANIMAL HOSPITAL ITEM & PROMPT EXPLORER (PRO GUI + ESP + TELEPORT)
-- ══════════════════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Clean previous instance
if _G.AH_ItemExplorerGui then
    pcall(function() _G.AH_ItemExplorerGui:Destroy() end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AnimalHospital_ItemExplorer"
ScreenGui.ResetOnSpawn = false
_G.AH_ItemExplorerGui = ScreenGui

pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Main Window Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 560, 0, 480)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 23)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(59, 130, 246)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Top Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 48)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -120, 1, 0)
TitleLabel.Position = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🏥 Animal Hospital — Item & Prompt Explorer"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -40, 0, 8)
CloseBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Controls Bar (Search + ESP Toggle + Scan)
local ControlsFrame = Instance.new("Frame")
ControlsFrame.Size = UDim2.new(1, -32, 0, 40)
ControlsFrame.Position = UDim2.new(0, 16, 0, 56)
ControlsFrame.BackgroundTransparency = 1
ControlsFrame.Parent = MainFrame

-- Search Box
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(0, 260, 1, 0)
SearchBox.Position = UDim2.new(0, 0, 0, 0)
SearchBox.BackgroundColor3 = Color3.fromRGB(26, 31, 44)
SearchBox.PlaceholderText = "🔍 Поиск предметов, промптов, комнат..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 130, 150)
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.TextSize = 13
SearchBox.Font = Enum.Font.Gotham
SearchBox.Parent = ControlsFrame

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 8)
SearchCorner.Parent = SearchBox

local SearchPadding = Instance.new("UIPadding")
SearchPadding.PaddingLeft = UDim.new(0, 10)
SearchPadding.Parent = SearchBox

-- Refresh Button
local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0, 110, 1, 0)
RefreshBtn.Position = UDim2.new(0, 270, 0, 0)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
RefreshBtn.Text = "🔄 Сканировать"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.TextSize = 13
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.Parent = ControlsFrame

local RefreshCorner = Instance.new("UICorner")
RefreshCorner.CornerRadius = UDim.new(0, 8)
RefreshCorner.Parent = RefreshBtn

-- ESP Toggle Button
local EspBtn = Instance.new("TextButton")
EspBtn.Size = UDim2.new(0, 130, 1, 0)
EspBtn.Position = UDim2.new(0, 390, 0, 0)
EspBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
EspBtn.Text = "✨ Включить ESP"
EspBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
EspBtn.TextSize = 13
EspBtn.Font = Enum.Font.GothamBold
EspBtn.Parent = ControlsFrame

local EspCorner = Instance.new("UICorner")
EspCorner.CornerRadius = UDim.new(0, 8)
EspCorner.Parent = EspBtn

-- Items Scrolling List Frame
local ListScroll = Instance.new("ScrollingFrame")
ListScroll.Size = UDim2.new(1, -32, 1, -112)
ListScroll.Position = UDim2.new(0, 16, 0, 104)
ListScroll.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
ListScroll.BorderSizePixel = 0
ListScroll.ScrollBarThickness = 6
ListScroll.ScrollBarImageColor3 = Color3.fromRGB(59, 130, 246)
ListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ListScroll.Parent = MainFrame

local ListCorner = Instance.new("UICorner")
ListCorner.CornerRadius = UDim.new(0, 8)
ListCorner.Parent = ListScroll

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 6)
ListLayout.Parent = ListScroll

local ListPadding = Instance.new("UIPadding")
ListPadding.PaddingTop = UDim.new(0, 6)
ListPadding.PaddingBottom = UDim.new(0, 6)
ListPadding.PaddingLeft = UDim.new(0, 6)
ListPadding.PaddingRight = UDim.new(0, 6)
ListPadding.Parent = ListScroll

-- Data & Scanner State
local FoundItems = {}
local EspActive = false
local EspBillboards = {}

local function ClearList()
    for _, child in ipairs(ListScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
end

local function ClearEsp()
    for _, bb in pairs(EspBillboards) do
        if bb and bb.Parent then bb:Destroy() end
    end
    EspBillboards = {}
end

local function ScanWorld()
    FoundItems = {}

    -- 1. Scan Model.Items (Shelves)
    local itemsFolder = Workspace:FindFirstChild("Model") and Workspace.Model:FindFirstChild("Items")
    if itemsFolder then
        for _, item in ipairs(itemsFolder:GetChildren()) do
            local pp = item:FindFirstChildWhichIsA("ProximityPrompt", true)
            local part = item:FindFirstChildWhichIsA("BasePart", true) or item
            local pos = part and (part:IsA("BasePart") and part.Position or part:GetPivot().Position)
            if pos then
                table.insert(FoundItems, {
                    Name = item.Name,
                    Category = "Shelf Item",
                    Position = pos,
                    Prompt = pp,
                    Instance = item,
                    Path = item:GetFullName()
                })
            end
        end
    end

    -- 2. Scan Rooms (Emergency & Medical)
    local rooms = Workspace:FindFirstChild("Rooms")
    if rooms then
        for _, folder in ipairs(rooms:GetChildren()) do
            for _, room in ipairs(folder:GetChildren()) do
                local minigame = room:FindFirstChild("Minigame")
                if minigame then
                    -- Medicine / Tools in room
                    local medFolder = minigame:FindFirstChild("Medicine") or minigame:FindFirstChild("Items")
                    if medFolder then
                        for _, med in ipairs(medFolder:GetDescendants()) do
                            if med:IsA("Model") or med:IsA("BasePart") then
                                local pp = med:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if pp then
                                    local part = med:IsA("BasePart") and med or med:FindFirstChildWhichIsA("BasePart", true)
                                    local pos = part and part.Position
                                    if pos then
                                        table.insert(FoundItems, {
                                            Name = med.Name .. " (" .. room.Name .. ")",
                                            Category = "Surgery/Room Tool",
                                            Position = pos,
                                            Prompt = pp,
                                            Instance = med,
                                            Path = med:GetFullName()
                                        })
                                    end
                                end
                            end
                        end
                    end

                    -- Beds & Devices
                    local bed = minigame:FindFirstChild("Bed")
                    if bed then
                        local inBed = bed:FindFirstChild("InBed")
                        local part = inBed and inBed:FindFirstChildWhichIsA("BasePart") or bed:FindFirstChildWhichIsA("BasePart", true)
                        local pos = part and part.Position
                        local pp = inBed and inBed:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if pos then
                            table.insert(FoundItems, {
                                Name = room.Name .. " Bed (Койка)",
                                Category = "Bed",
                                Position = pos,
                                Prompt = pp,
                                Instance = bed,
                                Path = bed:GetFullName()
                            })
                        end
                    end

                    -- Monitors
                    local monitor = minigame:FindFirstChild("Monitor") or minigame:FindFirstChild("xrayMonitor")
                    if monitor then
                        local part = monitor:FindFirstChildWhichIsA("BasePart", true)
                        local pos = part and part.Position
                        local pp = monitor:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if pos then
                            table.insert(FoundItems, {
                                Name = room.Name .. " Monitor (Аппарат)",
                                Category = "Device",
                                Position = pos,
                                Prompt = pp,
                                Instance = monitor,
                                Path = monitor:GetFullName()
                            })
                        end
                    end
                end
            end
        end
    end

    -- 3. Scan Misc (CheckIn, Computer, Shutter, Coffee)
    local misc = Workspace:FindFirstChild("Misc")
    if misc then
        for _, m in ipairs(misc:GetChildren()) do
            local pp = m:FindFirstChildWhichIsA("ProximityPrompt", true)
            local part = m:FindFirstChildWhichIsA("BasePart", true) or (m:IsA("BasePart") and m)
            local pos = part and part.Position
            if pos then
                table.insert(FoundItems, {
                    Name = m.Name,
                    Category = "Misc / CheckIn",
                    Position = pos,
                    Prompt = pp,
                    Instance = m,
                    Path = m:GetFullName()
                })
            end
        end
    end

    -- 4. Scan NPCs
    local npcs = Workspace:FindFirstChild("NPCs")
    if npcs then
        for _, npc in ipairs(npcs:GetChildren()) do
            if npc:IsA("Model") and npc ~= LocalPlayer.Character then
                local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChildWhichIsA("BasePart", true)
                local pp = npc:FindFirstChildWhichIsA("ProximityPrompt", true)
                local pos = root and root.Position
                if pos then
                    local cat = npc:GetAttribute("Skinwalker") == true and "⚠️ Аномалия / Угроза" or "👤 Пациент / NPC"
                    table.insert(FoundItems, {
                        Name = npc.Name,
                        Category = cat,
                        Position = pos,
                        Prompt = pp,
                        Instance = npc,
                        Path = npc:GetFullName()
                    })
                end
            end
        end
    end
end

local function RenderList(filterText)
    ClearList()
    filterText = string.lower(filterText or "")

    local count = 0
    for _, item in ipairs(FoundItems) do
        local match = filterText == "" or string.lower(item.Name):find(filterText) or string.lower(item.Category):find(filterText)
        if match then
            count = count + 1

            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, 0, 0, 52)
            card.BackgroundColor3 = Color3.fromRGB(26, 31, 44)
            card.BorderSizePixel = 0
            card.Parent = ListScroll

            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 6)
            cardCorner.Parent = card

            -- Item Title & Category
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -220, 0, 24)
            nameLabel.Position = UDim2.new(0, 10, 0, 4)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = item.Name
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextSize = 13
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Parent = card

            local catLabel = Instance.new("TextLabel")
            catLabel.Size = UDim2.new(1, -220, 0, 18)
            catLabel.Position = UDim2.new(0, 10, 0, 26)
            catLabel.BackgroundTransparency = 1
            local promptInfo = item.Prompt and (" | Prompt: " .. (item.Prompt.ActionText ~= "" and item.Prompt.ActionText or item.Prompt.Name)) or " | No Prompt"
            catLabel.Text = string.format("[%s] (%.1f, %.1f, %.1f)%s", item.Category, item.Position.X, item.Position.Y, item.Position.Z, promptInfo)
            catLabel.TextColor3 = Color3.fromRGB(156, 163, 175)
            catLabel.TextSize = 11
            catLabel.Font = Enum.Font.Gotham
            catLabel.TextXAlignment = Enum.TextXAlignment.Left
            catLabel.Parent = card

            -- Teleport Button
            local tpBtn = Instance.new("TextButton")
            tpBtn.Size = UDim2.new(0, 65, 0, 34)
            tpBtn.Position = UDim2.new(1, -210, 0, 9)
            tpBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
            tpBtn.Text = "🚀 ТП"
            tpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            tpBtn.TextSize = 12
            tpBtn.Font = Enum.Font.GothamBold
            tpBtn.Parent = card

            local tpCorner = Instance.new("UICorner")
            tpCorner.CornerRadius = UDim.new(0, 6)
            tpCorner.Parent = tpBtn

            tpBtn.MouseButton1Click:Connect(function()
                local root = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso"))
                if root then
                    root.CFrame = CFrame.new(item.Position + Vector3.new(0, 2.5, 0))
                end
            end)

            -- Grab / Press Prompt Button
            local grabBtn = Instance.new("TextButton")
            grabBtn.Size = UDim2.new(0, 65, 0, 34)
            grabBtn.Position = UDim2.new(1, -140, 0, 9)
            grabBtn.BackgroundColor3 = item.Prompt and Color3.fromRGB(16, 185, 129) or Color3.fromRGB(75, 85, 99)
            grabBtn.Text = item.Prompt and "✋ Взять" or "—"
            grabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            grabBtn.TextSize = 12
            grabBtn.Font = Enum.Font.GothamBold
            grabBtn.Parent = card

            local grabCorner = Instance.new("UICorner")
            grabCorner.CornerRadius = UDim.new(0, 6)
            grabCorner.Parent = grabBtn

            if item.Prompt then
                grabBtn.MouseButton1Click:Connect(function()
                    local root = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso"))
                    if root then
                        root.CFrame = CFrame.new(item.Position + Vector3.new(0, 2, 0))
                        task.wait(0.15)
                    end
                    item.Prompt.RequiresLineOfSight = false
                    item.Prompt.MaxActivationDistance = 50
                    if fireproximityprompt then
                        pcall(fireproximityprompt, item.Prompt)
                    else
                        item.Prompt:InputHoldBegin()
                        task.wait(0.1)
                        item.Prompt:InputHoldEnd()
                    end
                end)
            end

            -- Copy Coords Button
            local copyBtn = Instance.new("TextButton")
            copyBtn.Size = UDim2.new(0, 65, 0, 34)
            copyBtn.Position = UDim2.new(1, -70, 0, 9)
            copyBtn.BackgroundColor3 = Color3.fromRGB(139, 92, 246)
            copyBtn.Text = "📋 Копия"
            copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            copyBtn.TextSize = 11
            copyBtn.Font = Enum.Font.GothamBold
            copyBtn.Parent = card

            local copyCorner = Instance.new("UICorner")
            copyCorner.CornerRadius = UDim.new(0, 6)
            copyCorner.Parent = copyBtn

            copyBtn.MouseButton1Click:Connect(function()
                local codeStr = string.format("Vector3.new(%.2f, %.2f, %.2f)", item.Position.X, item.Position.Y, item.Position.Z)
                if setclipboard then
                    setclipboard(codeStr)
                    copyBtn.Text = "✅ Скопировано"
                    task.delay(1.5, function() copyBtn.Text = "📋 Копия" end)
                else
                    print("COORDS:", codeStr)
                end
            end)
        end
    end

    ListScroll.CanvasSize = UDim2.new(0, 0, 0, count * 58)
end

local function UpdateEsp()
    ClearEsp()
    if not EspActive then return end

    for _, item in ipairs(FoundItems) do
        local part = item.Instance:IsA("BasePart") and item.Instance or item.Instance:FindFirstChildWhichIsA("BasePart", true)
        if part then
            local bb = Instance.new("BillboardGui")
            bb.Name = "ItemEsp_" .. item.Name
            bb.Adornee = part
            bb.Size = UDim2.new(0, 150, 0, 40)
            bb.AlwaysOnTop = true
            bb.StudsOffset = Vector3.new(0, 2, 0)
            bb.Parent = ScreenGui

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundColor3 = Color3.fromRGB(15, 17, 23)
            label.BackgroundTransparency = 0.3
            label.Text = item.Name .. "\n[" .. item.Category .. "]"
            label.TextColor3 = item.Category:find("Аномалия") and Color3.fromRGB(239, 68, 68) or (item.Category:find("Shelf") and Color3.fromRGB(59, 130, 246) or Color3.fromRGB(16, 185, 129))
            label.TextSize = 11
            label.Font = Enum.Font.GothamBold
            label.Parent = bb

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 4)
            corner.Parent = label

            table.insert(EspBillboards, bb)
        end
    end
end

-- Hook Events
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    RenderList(SearchBox.Text)
end)

RefreshBtn.MouseButton1Click:Connect(function()
    ScanWorld()
    RenderList(SearchBox.Text)
    if EspActive then UpdateEsp() end
end)

EspBtn.MouseButton1Click:Connect(function()
    EspActive = not EspActive
    if EspActive then
        EspBtn.Text = "🛑 Выключить ESP"
        EspBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
        UpdateEsp()
    else
        EspBtn.Text = "✨ Включить ESP"
        EspBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
        ClearEsp()
    end
end)

-- Initial Scan & Render
ScanWorld()
RenderList("")
print("✅ Animal Hospital Item & Prompt Explorer успешно открыт!")
