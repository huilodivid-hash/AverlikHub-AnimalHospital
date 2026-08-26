--[[
    ══════════════════════════════════════════════════════════════════════════════════
    👑 AVERLIK HUB - ANIMAL HOSPITAL (SPECIAL ROOM 7 & ALL WARDS UPDATE)
    ══════════════════════════════════════════════════════════════════════════════════
    • Точный дизайн: Averlik Hub (Glassmorphism & Neon Purple #d946ef)
    • Совместимость: 100% Все эксплоиты (Solara, Wave, Delta, Arceus X, Codex, etc.)
    • Отдельный модуль: ПАЛАТА 7 (Реанимация / Операционная / Мини-игра сердца)
        - Авто-прохождение сканирования сердца (Автоклик по точкам)
        - Авто-капельница и аптечка
        - Прямой телепорт к койке и аппарату ЭКГ
        - Телепорты во все палаты (1, 2, 3, 4, 5, 6, 7)
    ══════════════════════════════════════════════════════════════════════════════════
--]]

local function RunAverlikHub()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local Lighting = game:GetService("Lighting")
    local VirtualUser = game:GetService("VirtualUser")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local GuiService = game:GetService("GuiService")

    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then
        repeat
            task.wait(0.05)
            LocalPlayer = Players.LocalPlayer
        until LocalPlayer
    end

    -- Звук успешного запуска
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://4590662766"
        sound.Volume = 0.5
        sound.Parent = Workspace
        sound:Play()
        sound.Ended:Connect(function() sound:Destroy() end)
    end)

    -- Очистка старых копий
    pcall(function()
        if getgenv and getgenv().AverlikHub_Instance then
            getgenv().AverlikHub_Instance:Destroy()
        end
        if getgenv and getgenv().AverlikHub_ESPFolder then
            getgenv().AverlikHub_ESPFolder:Destroy()
        end
        for _, old in pairs(game:GetService("CoreGui"):GetChildren()) do
            if old.Name == "AverlikHub_MainGui" then old:Destroy() end
        end
        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if pg then
            for _, old in pairs(pg:GetChildren()) do
                if old.Name == "AverlikHub_MainGui" then old:Destroy() end
            end
        end
    end)

    local function GetSafeParent()
        local parent = nil
        pcall(function()
            local cg = game:GetService("CoreGui")
            local test = Instance.new("Folder")
            test.Parent = cg
            test:Destroy()
            parent = cg
        end)
        if parent then return parent end

        if gethui then
            local ok, h = pcall(gethui)
            if ok and h then return h end
        end

        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:FindFirstChild("PlayerGui")
        if pg then return pg end

        return LocalPlayer:WaitForChild("PlayerGui", 5)
    end

    local GuiParent = GetSafeParent()
    if not GuiParent then
        GuiParent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AverlikHub_MainGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 999999
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Enabled = true
    ScreenGui.Parent = GuiParent

    if getgenv then
        getgenv().AverlikHub_Instance = ScreenGui
    end

    -- Конфигурация
    local Config = {
        -- Авто фарм
        AutoFarm = false,
        AutoCollect = false,
        AutoInteract = false,
        AutoSell = false,
        AutoBuy = false,
        AutoUpgrade = false,
        AutoFixSabotages = false,

        -- Больница Общее
        AutoHeal = false,
        AutoHealTeleport = true,
        AutoTakeMedicine = true,
        AutoScanner = true,
        AutoEquipTools = true,
        PriorityHeal = true,
        HealDelay = 0.8,
        ESP_Patients = false,
        ESP_Cabinets = false,

        -- Палата 7 (Реанимация / ICU)
        Room7_AutoCycle = false,
        Room7_AutoHeartGame = true,
        Room7_AutoIVDrip = true,
        Room7_AutoScan = true,

        -- Задания
        AutoAcceptQuests = false,
        AutoQuest = false,
        AutoCompleteQuest = false,
        AutoClaimRewards = false,
        ESP_Quests = false,

        -- Игрок
        WalkSpeed = 16,
        WalkSpeedEnabled = false,
        JumpPower = 50,
        JumpPowerEnabled = false,
        NoClip = false,
        AntiAFK = true,
        InfiniteSanity = false,
        InfiniteJump = false,

        -- Visuals
        ESP_Players = false,
        ESP_Animals = false,
        ESP_NPCs = false,
        ESP_Items = false,
        ShowDistance = true,
        Tracers = false,

        -- Misc
        FPSBoost = false,
        LowGraphics = false,

        -- Тема
        AccentColor = Color3.fromRGB(219, 70, 237),
        BackgroundColor = Color3.fromRGB(16, 16, 20),
        SidebarColor = Color3.fromRGB(13, 13, 16),
        SelectedConfig = "Default"
    }

    local MemoryConfigs = {}
    local DebounceMap = {}

    local function SafeFind(str, query)
        if not str or type(str) ~= "string" or not query then return false end
        return string.find(string.lower(str), string.lower(query), 1, true) ~= nil
    end

    -- Проверка на двери и мусор
    local function IsDoorOrTrash(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") then return true end
        local act = string.lower(tostring(prompt.ActionText or ""))
        local objT = string.lower(tostring(prompt.ObjectText or ""))
        local pName = string.lower(tostring(prompt.Parent and prompt.Parent.Name or ""))
        if SafeFind(act, "door") or SafeFind(act, "двер") or SafeFind(act, "откры") or SafeFind(act, "open") or SafeFind(act, "закры") or SafeFind(act, "close") then return true end
        if SafeFind(objT, "door") or SafeFind(objT, "двер") or SafeFind(pName, "door") or SafeFind(pName, "двер") or SafeFind(pName, "handle") or SafeFind(pName, "knob") then return true end
        if SafeFind(act, "trash") or SafeFind(act, "мусор") or SafeFind(objT, "trash") or SafeFind(pName, "trash") or SafeFind(pName, "bin") then return true end
        return false
    end

    -- Промпт на койке/пациенте
    local function IsBedPatientPrompt(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return false end
        if IsDoorOrTrash(prompt) then return false end

        local pName = string.lower(tostring(prompt.Parent and prompt.Parent.Name or ""))
        local gName = string.lower(tostring(prompt.Parent and prompt.Parent.Parent and prompt.Parent.Parent.Name or ""))
        local ggName = string.lower(tostring(prompt.Parent and prompt.Parent.Parent and prompt.Parent.Parent.Parent and prompt.Parent.Parent.Parent.Name or ""))

        if SafeFind(pName, "shelf") or SafeFind(pName, "cabinet") or SafeFind(pName, "шкаф") or SafeFind(pName, "полк") or SafeFind(gName, "shelf") or SafeFind(gName, "cabinet") or SafeFind(gName, "шкаф") then
            return false
        end

        local act = string.lower(tostring(prompt.ActionText or ""))
        if SafeFind(act, "анализ") or SafeFind(act, "днк") or SafeFind(act, "dna") or SafeFind(act, "test") or SafeFind(act, "капельниц") or SafeFind(act, "укол") or SafeFind(act, "лекарств") then
            return true
        end

        if SafeFind(pName, "bed") or SafeFind(pName, "patient") or SafeFind(pName, "rabbit") or SafeFind(pName, "cat") or SafeFind(pName, "dog") or SafeFind(pName, "койк") or SafeFind(pName, "кроват") or SafeFind(gName, "bed") or SafeFind(gName, "patient") or SafeFind(ggName, "bed") then
            return true
        end

        return false
    end

    -- Промпт в шкафу с медикаментами
    local function IsMedicineCabinetPrompt(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return false end
        if IsDoorOrTrash(prompt) then return false end

        local pName = string.lower(tostring(prompt.Parent and prompt.Parent.Name or ""))
        local gName = string.lower(tostring(prompt.Parent and prompt.Parent.Parent and prompt.Parent.Parent.Name or ""))

        if SafeFind(pName, "shelf") or SafeFind(pName, "cabinet") or SafeFind(pName, "шкаф") or SafeFind(pName, "полк") or SafeFind(gName, "shelf") or SafeFind(gName, "cabinet") or SafeFind(gName, "шкаф") or SafeFind(gName, "pharmacy") then
            return true
        end

        local act = string.lower(tostring(prompt.ActionText or ""))
        local medWords = {"сироп", "травы", "аптечка", "таблетк", "пластыр", "бинт", "капельниц", "шприц", "syrup", "herbs", "kit", "pill", "bandage", "drip"}
        for _, m in ipairs(medWords) do
            if SafeFind(act, m) and not SafeFind(pName, "bed") then
                return true
            end
        end

        return false
    end

    -- Промпт аппарата ЭКГ / Сердца в палате 7
    local function IsRoom7HeartMonitorPrompt(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return false end
        local act = string.lower(tostring(prompt.ActionText or ""))
        local objT = string.lower(tostring(prompt.ObjectText or ""))
        local pName = string.lower(tostring(prompt.Parent and prompt.Parent.Name or ""))
        local gName = string.lower(tostring(prompt.Parent and prompt.Parent.Parent and prompt.Parent.Parent.Name or ""))

        if SafeFind(act, "сердц") or SafeFind(act, "heart") or SafeFind(act, "экг") or SafeFind(act, "действие") or SafeFind(act, "монитор") or SafeFind(objT, "сердц") or SafeFind(objT, "монитор") or SafeFind(pName, "monitor") or SafeFind(pName, "ecg") or SafeFind(pName, "heart") or SafeFind(gName, "monitor") then
            return true
        end
        return false
    end

    -- Сканер анализов
    local function IsLabScannerPrompt(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return false end
        local act = string.lower(tostring(prompt.ActionText or ""))
        local objT = string.lower(tostring(prompt.ObjectText or ""))
        local pName = string.lower(tostring(prompt.Parent and prompt.Parent.Name or ""))
        local gName = string.lower(tostring(prompt.Parent and prompt.Parent.Parent and prompt.Parent.Parent.Name or ""))

        if SafeFind(act, "сканир") or SafeFind(act, "scan") or SafeFind(act, "анализ") or SafeFind(act, "компьют") or SafeFind(act, "computer") or SafeFind(objT, "компьют") or SafeFind(pName, "scan") or SafeFind(pName, "pc") or SafeFind(pName, "lab") or SafeFind(gName, "table") or SafeFind(gName, "desk") then
            return true
        end
        return false
    end

    -- Кофе
    local function IsCoffeePrompt(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return false end
        local act = string.lower(tostring(prompt.ActionText or ""))
        local objT = string.lower(tostring(prompt.ObjectText or ""))
        local pName = string.lower(tostring(prompt.Parent and prompt.Parent.Name or ""))
        return SafeFind(act, "coffee") or SafeFind(act, "кофе") or SafeFind(objT, "кофе") or SafeFind(objT, "рассудок") or SafeFind(pName, "coffee")
    end

    -- CFrame точки
    local function GetPromptTargetCFrame(prompt)
        if not prompt then return nil end
        local parent = prompt.Parent
        if not parent then return nil end

        if parent:IsA("Attachment") then
            return parent.WorldCFrame
        elseif parent:IsA("BasePart") then
            return parent.CFrame
        elseif parent:IsA("Model") then
            local pPart = parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart", true)
            if pPart then return pPart.CFrame end
        end

        local ancestorPart = prompt:FindFirstAncestorWhichIsA("BasePart")
        if ancestorPart then return ancestorPart.CFrame end

        return nil
    end

    -- Экипировка любого медицинского инструмента
    local function EquipAnyMedicalTool(preferredName)
        pcall(function()
            local bp = LocalPlayer:FindFirstChild("Backpack")
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if not bp or not hum then return end

            local tools = bp:GetChildren()
            local targetTool = nil

            if preferredName then
                for _, tool in ipairs(tools) do
                    if tool:IsA("Tool") and SafeFind(tool.Name, preferredName) then
                        targetTool = tool
                        break
                    end
                end
            end

            if not targetTool then
                for _, tool in ipairs(tools) do
                    if tool:IsA("Tool") then
                        targetTool = tool
                        break
                    end
                end
            end

            if targetTool then
                hum:EquipTool(targetTool)
                task.wait(0.06)
                pcall(function() targetTool:Activate() end)
            end
        end)
    end

    -- Взаимодействие с ProximityPrompt
    local function SafeInteractPrompt(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return false end
        local holdTime = prompt.HoldDuration or 0
        pcall(function()
            if fireproximityprompt then
                fireproximityprompt(prompt, holdTime)
            else
                prompt:InputHoldBegin()
                task.wait(holdTime > 0 and (holdTime + 0.05) or 0.1)
                prompt:InputHoldEnd()
            end
        end)
        return true
    end

    -- Телепорт
    local function TeleportTo(cf)
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if root then
                if hum then
                    hum.Sit = false
                    hum.PlatformStand = false
                end
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                if typeof(cf) == "Vector3" then
                    root.CFrame = CFrame.new(cf + Vector3.new(0, 3, 0))
                elseif typeof(cf) == "CFrame" then
                    root.CFrame = cf + Vector3.new(0, 3, 0)
                end
            end
        end)
    end

    -- Поиск координат палат (1-7)
    local function FindWardCFrame(wardNumber)
        local query = "палата " .. tostring(wardNumber)
        local queryEng = "room " .. tostring(wardNumber)
        local queryNum = tostring(wardNumber)

        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                local oName = string.lower(obj.Name)
                if oName == query or oName == queryEng or (SafeFind(oName, "room") and SafeFind(oName, queryNum)) or (SafeFind(oName, "палат") and SafeFind(oName, queryNum)) then
                    local bed = obj:FindFirstChild("Bed", true) or obj:FindFirstChild("HospitalBed", true) or obj:FindFirstChildWhichIsA("BasePart", true)
                    if bed then
                        return bed:IsA("Model") and (bed.PrimaryPart and bed.PrimaryPart.CFrame or bed:GetBoundingBox()) or bed.CFrame
                    end
                end
            end
        end

        -- Если палата 7: ищем по оборудованию реанимации (операционные лампы, монитор)
        if wardNumber == 7 then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and (SafeFind(obj.Name, "7") or SafeFind(obj.Name, "icu") or SafeFind(obj.Name, "operat") or SafeFind(obj.Name, "reanim")) then
                    local pPart = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                    if pPart then return pPart.CFrame end
                end
            end
        end

        return nil
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- ⚡ АВТО-ПРОХОЖДЕНИЕ МИНИ-ИГРЫ СЕРДЦА (ПАЛАТА 7)
    -- ══════════════════════════════════════════════════════════════════════════
    local function SolveHeartMinigame()
        local solved = false
        pcall(function()
            local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if not pg then return end

            -- Поиск всех интерактивных кнопок мини-игры на экране игрока
            for _, gui in pairs(pg:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AverlikHub_MainGui" then
                    for _, btn in pairs(gui:GetDescendants()) do
                        if btn:IsA("ImageButton") or btn:IsA("TextButton") then
                            if btn.Visible and btn.Active then
                                local bName = string.lower(btn.Name)
                                -- Иконки руки, клика, точки сердца
                                if SafeFind(bName, "click") or SafeFind(bName, "hand") or SafeFind(bName, "tap") or SafeFind(bName, "target") or SafeFind(bName, "point") or SafeFind(bName, "heart") then
                                    pcall(function()
                                        for i = 1, 3 do
                                            if firesignal then
                                                firesignal(btn.MouseButton1Click)
                                                firesignal(btn.Activated)
                                            end
                                        end
                                    end)
                                    solved = true
                                end
                            end
                        end
                    end
                end
            end

            -- Также проверяем 3D-кнопки (ClickDetector / SurfaceGui)
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ClickDetector") and obj.MaxActivationDistance > 0 then
                    local pName = string.lower(tostring(obj.Parent and obj.Parent.Name or ""))
                    if SafeFind(pName, "heart") or SafeFind(pName, "point") or SafeFind(pName, "tap") or SafeFind(pName, "screen") then
                        pcall(function()
                            if fireclickdetector then
                                fireclickdetector(obj)
                            end
                        end)
                        solved = true
                    end
                end
            end
        end)
        return solved
    end

    -- Уведомления
    local ToastContainer = Instance.new("Frame")
    ToastContainer.Name = "ToastContainer"
    ToastContainer.Size = UDim2.new(0, 260, 0, 300)
    ToastContainer.Position = UDim2.new(1, -280, 0, 30)
    ToastContainer.BackgroundTransparency = 1
    ToastContainer.ZIndex = 10000
    ToastContainer.Parent = ScreenGui

    local ToastListLayout = Instance.new("UIListLayout")
    ToastListLayout.Padding = UDim.new(0, 8)
    ToastListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    ToastListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ToastListLayout.Parent = ToastContainer

    local function SendNotification(title, message, duration)
        duration = duration or 3
        task.spawn(function()
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, 0, 0, 52)
            card.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
            card.BorderSizePixel = 0
            card.Position = UDim2.new(1, 30, 0, 0)
            card.ZIndex = 10001

            local stroke = Instance.new("UIStroke")
            stroke.Color = Config.AccentColor
            stroke.Thickness = 1.2
            stroke.Parent = card

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = card

            local tLbl = Instance.new("TextLabel")
            tLbl.Text = tostring(title)
            tLbl.Font = Enum.Font.GothamBold
            tLbl.TextSize = 13
            tLbl.TextColor3 = Config.AccentColor
            tLbl.Position = UDim2.new(0, 12, 0, 7)
            tLbl.Size = UDim2.new(1, -24, 0, 16)
            tLbl.BackgroundTransparency = 1
            tLbl.TextXAlignment = Enum.TextXAlignment.Left
            tLbl.ZIndex = 10002
            tLbl.Parent = card

            local dLbl = Instance.new("TextLabel")
            dLbl.Text = tostring(message)
            dLbl.Font = Enum.Font.Gotham
            dLbl.TextSize = 11
            dLbl.TextColor3 = Color3.fromRGB(200, 200, 215)
            dLbl.Position = UDim2.new(0, 12, 0, 26)
            dLbl.Size = UDim2.new(1, -24, 0, 20)
            dLbl.BackgroundTransparency = 1
            dLbl.TextXAlignment = Enum.TextXAlignment.Left
            dLbl.ZIndex = 10002
            dLbl.Parent = card

            card.Parent = ToastContainer
            pcall(function()
                TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
            end)

            task.wait(duration)
            if card and card.Parent then
                local tw = TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 30, 0, 0)})
                tw:Play()
                tw.Completed:Connect(function() card:Destroy() end)
            end
        end)
    end

    -- Виджет HUD
    local FloatingPill = Instance.new("Frame")
    FloatingPill.Name = "FloatingHUD"
    FloatingPill.Size = UDim2.new(0, 165, 0, 46)
    FloatingPill.Position = UDim2.new(0, 20, 1, -70)
    FloatingPill.AnchorPoint = Vector2.new(0, 1)
    FloatingPill.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
    FloatingPill.BorderSizePixel = 0
    FloatingPill.Active = true
    FloatingPill.Visible = true
    FloatingPill.ZIndex = 5000
    FloatingPill.Parent = ScreenGui

    local PillCorner = Instance.new("UICorner")
    PillCorner.CornerRadius = UDim.new(0, 12)
    PillCorner.Parent = FloatingPill

    local PillStroke = Instance.new("UIStroke")
    PillStroke.Color = Color3.fromRGB(36, 36, 46)
    PillStroke.Thickness = 1.2
    PillStroke.Parent = FloatingPill

    local PillLogo = Instance.new("Frame")
    PillLogo.Size = UDim2.new(0, 30, 0, 30)
    PillLogo.Position = UDim2.new(0, 8, 0.5, -15)
    PillLogo.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    PillLogo.BorderSizePixel = 0
    PillLogo.ZIndex = 5001
    PillLogo.Parent = FloatingPill

    local PillLogoCorner = Instance.new("UICorner")
    PillLogoCorner.CornerRadius = UDim.new(0, 8)
    PillLogoCorner.Parent = PillLogo

    local PillLogoText = Instance.new("TextLabel")
    PillLogoText.Text = "A"
    PillLogoText.Font = Enum.Font.GothamBold
    PillLogoText.TextSize = 16
    PillLogoText.TextColor3 = Config.AccentColor
    PillLogoText.Size = UDim2.new(1, 0, 1, 0)
    PillLogoText.BackgroundTransparency = 1
    PillLogoText.ZIndex = 5002
    PillLogoText.Parent = PillLogo

    local PillTitle = Instance.new("TextLabel")
    PillTitle.Text = "Averlik Hub"
    PillTitle.Font = Enum.Font.GothamBold
    PillTitle.TextSize = 12
    PillTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    PillTitle.Position = UDim2.new(0, 46, 0, 6)
    PillTitle.Size = UDim2.new(1, -52, 0, 16)
    PillTitle.BackgroundTransparency = 1
    PillTitle.TextXAlignment = Enum.TextXAlignment.Left
    PillTitle.ZIndex = 5001
    PillTitle.Parent = FloatingPill

    local PillSub = Instance.new("TextLabel")
    PillSub.Name = "HUD_TimeFPS"
    PillSub.Text = "00:00 • 60 fps"
    PillSub.Font = Enum.Font.Gotham
    PillSub.TextSize = 10
    PillSub.TextColor3 = Color3.fromRGB(150, 150, 165)
    PillSub.Position = UDim2.new(0, 46, 0, 23)
    PillSub.Size = UDim2.new(1, -52, 0, 16)
    PillSub.BackgroundTransparency = 1
    PillSub.TextXAlignment = Enum.TextXAlignment.Left
    PillSub.ZIndex = 5001
    PillSub.Parent = FloatingPill

    local PillBtn = Instance.new("TextButton")
    PillBtn.Size = UDim2.new(1, 0, 1, 0)
    PillBtn.BackgroundTransparency = 1
    PillBtn.Text = ""
    PillBtn.ZIndex = 5005
    PillBtn.Parent = FloatingPill

    -- Главное окно
    local cam = Workspace.CurrentCamera
    local vpSize = cam and cam.ViewportSize or Vector2.new(1280, 720)
    local winW = math.clamp(vpSize.X - 40, 320, 670)
    local winH = math.clamp(vpSize.Y - 60, 280, 440)

    local MainWindow = Instance.new("Frame")
    MainWindow.Name = "MainWindow"
    MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
    MainWindow.Size = UDim2.new(0, winW, 0, winH)
    MainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainWindow.BackgroundColor3 = Config.BackgroundColor
    MainWindow.BorderSizePixel = 0
    MainWindow.Active = true
    MainWindow.Visible = true
    MainWindow.ZIndex = 1000
    MainWindow.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 14)
    MainCorner.Parent = MainWindow

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(34, 34, 44)
    MainStroke.Thickness = 1.2
    MainStroke.Parent = MainWindow

    local function EnableDrag(frame, handle)
        handle = handle or frame
        local dragging, dragInput, dragStart, startPos

        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position

                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)

        handle.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                dragInput = input
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    EnableDrag(MainWindow)
    EnableDrag(FloatingPill)

    -- Сайдбар
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Sidebar.Position = UDim2.new(0, 0, 0, 0)
    Sidebar.BackgroundColor3 = Config.SidebarColor
    Sidebar.BorderSizePixel = 0
    Sidebar.ZIndex = 1001
    Sidebar.Parent = Sidebar

    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 14)
    SidebarCorner.Parent = Sidebar

    local SidebarMask = Instance.new("Frame")
    SidebarMask.Size = UDim2.new(0, 14, 1, 0)
    SidebarMask.Position = UDim2.new(1, -14, 0, 0)
    SidebarMask.BackgroundColor3 = Config.SidebarColor
    SidebarMask.BorderSizePixel = 0
    SidebarMask.ZIndex = 1001
    SidebarMask.Parent = Sidebar

    local SidebarDivider = Instance.new("Frame")
    SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
    SidebarDivider.Position = UDim2.new(1, 0, 0, 0)
    SidebarDivider.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    SidebarDivider.BorderSizePixel = 0
    SidebarDivider.ZIndex = 1002
    SidebarDivider.Parent = Sidebar

    local BrandFrame = Instance.new("Frame")
    BrandFrame.Size = UDim2.new(1, 0, 0, 56)
    BrandFrame.BackgroundTransparency = 1
    BrandFrame.ZIndex = 1002
    BrandFrame.Parent = Sidebar

    local BrandLogo = Instance.new("Frame")
    BrandLogo.Size = UDim2.new(0, 32, 0, 32)
    BrandLogo.Position = UDim2.new(0, 12, 0, 12)
    BrandLogo.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    BrandLogo.BorderSizePixel = 0
    BrandLogo.ZIndex = 1003
    BrandLogo.Parent = BrandFrame

    local BrandLogoCorner = Instance.new("UICorner")
    BrandLogoCorner.CornerRadius = UDim.new(0, 8)
    BrandLogoCorner.Parent = BrandLogo

    local BrandLogoLetter = Instance.new("TextLabel")
    BrandLogoLetter.Text = "A"
    BrandLogoLetter.Font = Enum.Font.GothamBold
    BrandLogoLetter.TextSize = 17
    BrandLogoLetter.TextColor3 = Config.AccentColor
    BrandLogoLetter.Size = UDim2.new(1, 0, 1, 0)
    BrandLogoLetter.BackgroundTransparency = 1
    BrandLogoLetter.ZIndex = 1004
    BrandLogoLetter.Parent = BrandLogo

    local BrandTitle = Instance.new("TextLabel")
    BrandTitle.Text = "Averlik Hub"
    BrandTitle.Font = Enum.Font.GothamBold
    BrandTitle.TextSize = 13
    BrandTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    BrandTitle.Position = UDim2.new(0, 50, 0, 11)
    BrandTitle.Size = UDim2.new(1, -55, 0, 16)
    BrandTitle.BackgroundTransparency = 1
    BrandTitle.TextXAlignment = Enum.TextXAlignment.Left
    BrandTitle.ZIndex = 1003
    BrandTitle.Parent = BrandFrame

    local BrandSub = Instance.new("TextLabel")
    BrandSub.Text = "Animal Hospital"
    BrandSub.Font = Enum.Font.Gotham
    BrandSub.TextSize = 10
    BrandSub.TextColor3 = Color3.fromRGB(140, 140, 155)
    BrandSub.Position = UDim2.new(0, 50, 0, 27)
    BrandSub.Size = UDim2.new(1, -55, 0, 14)
    BrandSub.BackgroundTransparency = 1
    BrandSub.TextXAlignment = Enum.TextXAlignment.Left
    BrandSub.ZIndex = 1003
    BrandSub.Parent = BrandFrame

    local TabListContainer = Instance.new("ScrollingFrame")
    TabListContainer.Name = "TabList"
    TabListContainer.Size = UDim2.new(1, -14, 1, -125)
    TabListContainer.Position = UDim2.new(0, 7, 0, 58)
    TabListContainer.BackgroundTransparency = 1
    TabListContainer.BorderSizePixel = 0
    TabListContainer.ScrollBarThickness = 2
    TabListContainer.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 60)
    TabListContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabListContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabListContainer.ZIndex = 1003
    TabListContainer.Parent = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 3)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Parent = TabListContainer

    local SidebarFooter = Instance.new("Frame")
    SidebarFooter.Name = "Footer"
    SidebarFooter.Size = UDim2.new(1, -14, 0, 50)
    SidebarFooter.Position = UDim2.new(0, 7, 1, -56)
    SidebarFooter.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    SidebarFooter.BorderSizePixel = 0
    SidebarFooter.ZIndex = 1003
    SidebarFooter.Parent = Sidebar

    local FooterCorner = Instance.new("UICorner")
    FooterCorner.CornerRadius = UDim.new(0, 10)
    FooterCorner.Parent = SidebarFooter

    local FooterStroke = Instance.new("UIStroke")
    FooterStroke.Color = Color3.fromRGB(30, 30, 40)
    FooterStroke.Thickness = 1
    FooterStroke.Parent = SidebarFooter

    local DiscordLabel = Instance.new("TextLabel")
    DiscordLabel.Text = "discord.gg/bJFF653nK"
    DiscordLabel.Font = Enum.Font.GothamBold
    DiscordLabel.TextSize = 10
    DiscordLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    DiscordLabel.Position = UDim2.new(0, 0, 0, 6)
    DiscordLabel.Size = UDim2.new(1, 0, 0, 16)
    DiscordLabel.BackgroundTransparency = 1
    DiscordLabel.ZIndex = 1004
    DiscordLabel.Parent = SidebarFooter

    local FooterSub = Instance.new("TextLabel")
    FooterSub.Name = "FooterTimeFPS"
    FooterSub.Text = "00:00 • 60 fps"
    FooterSub.Font = Enum.Font.Gotham
    FooterSub.TextSize = 10
    FooterSub.TextColor3 = Color3.fromRGB(140, 140, 155)
    FooterSub.Position = UDim2.new(0, 0, 0, 24)
    FooterSub.Size = UDim2.new(1, 0, 0, 16)
    FooterSub.BackgroundTransparency = 1
    FooterSub.ZIndex = 1004
    FooterSub.Parent = SidebarFooter

    -- Контентная область
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -160, 1, 0)
    ContentArea.Position = UDim2.new(0, 160, 0, 0)
    ContentArea.BackgroundTransparency = 1
    ContentArea.ZIndex = 1001
    ContentArea.Parent = MainWindow

    local ContentHeader = Instance.new("Frame")
    ContentHeader.Name = "Header"
    ContentHeader.Size = UDim2.new(1, 0, 0, 56)
    ContentHeader.Position = UDim2.new(0, 0, 0, 0)
    ContentHeader.BackgroundTransparency = 1
    ContentHeader.ZIndex = 1002
    ContentHeader.Parent = ContentArea

    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Name = "Title"
    HeaderTitle.Text = "Авто фарм"
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.TextSize = 16
    HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    HeaderTitle.Position = UDim2.new(0, 16, 0, 10)
    HeaderTitle.Size = UDim2.new(0, 200, 0, 18)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.ZIndex = 1003
    HeaderTitle.Parent = ContentHeader

    local HeaderSub = Instance.new("TextLabel")
    HeaderSub.Name = "Subtitle"
    HeaderSub.Text = "Автоматизация больницы и заработка"
    HeaderSub.Font = Enum.Font.Gotham
    HeaderSub.TextSize = 10
    HeaderSub.TextColor3 = Color3.fromRGB(140, 140, 155)
    HeaderSub.Position = UDim2.new(0, 16, 0, 29)
    HeaderSub.Size = UDim2.new(0, 230, 0, 14)
    HeaderSub.BackgroundTransparency = 1
    HeaderSub.TextXAlignment = Enum.TextXAlignment.Left
    HeaderSub.ZIndex = 1003
    HeaderSub.Parent = ContentHeader

    local SearchBoxContainer = Instance.new("Frame")
    SearchBoxContainer.Name = "SearchContainer"
    SearchBoxContainer.Size = UDim2.new(0, 130, 0, 28)
    SearchBoxContainer.Position = UDim2.new(1, -170, 0, 14)
    SearchBoxContainer.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    SearchBoxContainer.BorderSizePixel = 0
    SearchBoxContainer.ZIndex = 1003
    SearchBoxContainer.Parent = ContentHeader

    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 8)
    SearchCorner.Parent = SearchBoxContainer

    local SearchStroke = Instance.new("UIStroke")
    SearchStroke.Color = Color3.fromRGB(30, 30, 40)
    SearchStroke.Thickness = 1
    SearchStroke.Parent = SearchBoxContainer

    local SearchInput = Instance.new("TextBox")
    SearchInput.Name = "Input"
    SearchInput.PlaceholderText = "Поиск..."
    SearchInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 115)
    SearchInput.Text = ""
    SearchInput.Font = Enum.Font.Gotham
    SearchInput.TextSize = 11
    SearchInput.TextColor3 = Color3.fromRGB(240, 240, 250)
    SearchInput.Size = UDim2.new(1, -14, 1, 0)
    SearchInput.Position = UDim2.new(0, 8, 0, 0)
    SearchInput.BackgroundTransparency = 1
    SearchInput.TextXAlignment = Enum.TextXAlignment.Left
    SearchInput.ClearTextOnFocus = false
    SearchInput.ZIndex = 1004
    SearchInput.Parent = SearchBoxContainer

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -34, 0, 14)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Text = "✕"
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 12
    CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 195)
    CloseBtn.ZIndex = 1003
    CloseBtn.Parent = ContentHeader

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseBtn

    local function ToggleGUI()
        MainWindow.Visible = not MainWindow.Visible
    end

    CloseBtn.MouseButton1Click:Connect(function()
        MainWindow.Visible = false
        SendNotification("Averlik Hub", "Интерфейс скрыт. Кликните по виджету снизу.", 3)
    end)

    PillBtn.MouseButton1Click:Connect(ToggleGUI)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and (input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.Insert) then
            ToggleGUI()
        end
    end)

    local PagesHolder = Instance.new("Frame")
    PagesHolder.Name = "PagesHolder"
    PagesHolder.Size = UDim2.new(1, 0, 1, -56)
    PagesHolder.Position = UDim2.new(0, 0, 0, 56)
    PagesHolder.BackgroundTransparency = 1
    PagesHolder.ZIndex = 1002
    PagesHolder.Parent = ContentArea

    -- UI Builder
    local Tabs = {}
    local CurrentTab = nil

    local function CreateTab(name, icon, subtitle, layoutOrder)
        local tabButton = Instance.new("TextButton")
        tabButton.Name = "Tab_" .. name
        tabButton.Size = UDim2.new(1, 0, 0, 32)
        tabButton.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
        tabButton.BackgroundTransparency = 1
        tabButton.BorderSizePixel = 0
        tabButton.Text = ""
        tabButton.LayoutOrder = layoutOrder or 1
        tabButton.ZIndex = 1004
        tabButton.Parent = TabListContainer

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 8)
        tabCorner.Parent = tabButton

        local iconLabel = Instance.new("TextLabel")
        iconLabel.Name = "Icon"
        iconLabel.Text = icon or "•"
        iconLabel.Font = Enum.Font.GothamBold
        iconLabel.TextSize = 12
        iconLabel.TextColor3 = Color3.fromRGB(140, 140, 155)
        iconLabel.Position = UDim2.new(0, 8, 0, 0)
        iconLabel.Size = UDim2.new(0, 18, 1, 0)
        iconLabel.BackgroundTransparency = 1
        iconLabel.ZIndex = 1005
        iconLabel.Parent = tabButton

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "Label"
        nameLabel.Text = name
        nameLabel.Font = Enum.Font.GothamMedium
        nameLabel.TextSize = 11
        nameLabel.TextColor3 = Color3.fromRGB(160, 160, 175)
        nameLabel.Position = UDim2.new(0, 32, 0, 0)
        nameLabel.Size = UDim2.new(1, -36, 1, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.ZIndex = 1005
        nameLabel.Parent = tabButton

        local pageScroll = Instance.new("ScrollingFrame")
        pageScroll.Name = "Page_" .. name
        pageScroll.Size = UDim2.new(1, -20, 1, -10)
        pageScroll.Position = UDim2.new(0, 10, 0, 0)
        pageScroll.BackgroundTransparency = 1
        pageScroll.BorderSizePixel = 0
        pageScroll.ScrollBarThickness = 3
        pageScroll.ScrollBarImageColor3 = Color3.fromRGB(45, 45, 60)
        pageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        pageScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        pageScroll.Visible = false
        pageScroll.ZIndex = 1003
        pageScroll.Parent = PagesHolder

        local pageLayout = Instance.new("UIListLayout")
        pageLayout.Padding = UDim.new(0, 6)
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Parent = pageScroll

        local tabObj = {
            Button = tabButton,
            Page = pageScroll,
            Name = name,
            Subtitle = subtitle or "Параметры и функции",
            Elements = {}
        }

        local function SelectThisTab()
            for _, t in pairs(Tabs) do
                t.Page.Visible = false
                t.Button.BackgroundTransparency = 1
                local lbl = t.Button:FindFirstChild("Label")
                local icn = t.Button:FindFirstChild("Icon")
                if lbl then lbl.TextColor3 = Color3.fromRGB(150, 150, 165) end
                if icn then icn.TextColor3 = Color3.fromRGB(140, 140, 155) end
            end

            CurrentTab = tabObj
            pageScroll.Visible = true
            tabButton.BackgroundTransparency = 0
            tabButton.BackgroundColor3 = Color3.fromRGB(26, 25, 34)
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            iconLabel.TextColor3 = Config.AccentColor

            HeaderTitle.Text = name
            HeaderSub.Text = tabObj.Subtitle
        end

        tabButton.MouseButton1Click:Connect(SelectThisTab)
        table.insert(Tabs, tabObj)

        function tabObj:CreateSection(sectionTitle)
            local secFrame = Instance.new("Frame")
            secFrame.Name = "Sec_" .. sectionTitle
            secFrame.Size = UDim2.new(1, 0, 0, 22)
            secFrame.BackgroundTransparency = 1
            secFrame.ZIndex = 1004
            secFrame.Parent = pageScroll

            local lbl = Instance.new("TextLabel")
            lbl.Text = sectionTitle
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 11
            lbl.TextColor3 = Color3.fromRGB(150, 150, 165)
            lbl.Size = UDim2.new(0, 0, 1, 0)
            lbl.AutomaticSize = Enum.AutomaticSize.X
            lbl.BackgroundTransparency = 1
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 1005
            lbl.Parent = secFrame

            local line = Instance.new("Frame")
            line.Size = UDim2.new(1, -(lbl.AbsoluteSize.X + 15), 0, 1)
            line.Position = UDim2.new(1, 0, 0.5, 0)
            line.AnchorPoint = Vector2.new(1, 0.5)
            line.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            line.BorderSizePixel = 0
            line.ZIndex = 1004
            line.Parent = secFrame

            lbl:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                line.Size = UDim2.new(1, -(lbl.AbsoluteSize.X + 15), 0, 1)
            end)
        end

        function tabObj:CreateToggle(title, description, defaultValue, callback)
            local toggleCard = Instance.new("Frame")
            toggleCard.Name = "Toggle_" .. title
            toggleCard.Size = UDim2.new(1, 0, 0, 42)
            toggleCard.BackgroundColor3 = Color3.fromRGB(19, 19, 25)
            toggleCard.BorderSizePixel = 0
            toggleCard.ZIndex = 1004
            toggleCard.Parent = pageScroll

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = toggleCard

            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(28, 28, 38)
            stroke.Thickness = 1
            stroke.Parent = toggleCard

            local tLabel = Instance.new("TextLabel")
            tLabel.Text = title
            tLabel.Font = Enum.Font.GothamMedium
            tLabel.TextSize = 11
            tLabel.TextColor3 = Color3.fromRGB(240, 240, 250)
            tLabel.Position = UDim2.new(0, 10, 0, 5)
            tLabel.Size = UDim2.new(1, -60, 0, 16)
            tLabel.BackgroundTransparency = 1
            tLabel.TextXAlignment = Enum.TextXAlignment.Left
            tLabel.ZIndex = 1005
            tLabel.Parent = toggleCard

            local dLabel = Instance.new("TextLabel")
            dLabel.Text = description or ""
            dLabel.Font = Enum.Font.Gotham
            dLabel.TextSize = 9
            dLabel.TextColor3 = Color3.fromRGB(120, 120, 135)
            dLabel.Position = UDim2.new(0, 10, 0, 22)
            dLabel.Size = UDim2.new(1, -60, 0, 14)
            dLabel.BackgroundTransparency = 1
            dLabel.TextXAlignment = Enum.TextXAlignment.Left
            dLabel.ZIndex = 1005
            dLabel.Parent = toggleCard

            local switch = Instance.new("Frame")
            switch.Size = UDim2.new(0, 36, 0, 18)
            switch.Position = UDim2.new(1, -44, 0.5, -9)
            switch.BackgroundColor3 = defaultValue and Config.AccentColor or Color3.fromRGB(40, 40, 52)
            switch.BorderSizePixel = 0
            switch.ZIndex = 1005
            switch.Parent = toggleCard

            local swCorner = Instance.new("UICorner")
            swCorner.CornerRadius = UDim.new(1, 0)
            swCorner.Parent = switch

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 12, 0, 12)
            knob.Position = defaultValue and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.BorderSizePixel = 0
            knob.ZIndex = 1006
            knob.Parent = switch

            local knCorner = Instance.new("UICorner")
            knCorner.CornerRadius = UDim.new(1, 0)
            knCorner.Parent = knob

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.ZIndex = 1007
            btn.Parent = toggleCard

            local state = defaultValue

            local function SetState(val)
                state = val
                local targetPos = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
                local targetColor = state and Config.AccentColor or Color3.fromRGB(40, 40, 52)

                pcall(function()
                    TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetPos}):Play()
                    TweenService:Create(switch, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = targetColor}):Play()
                end)

                if callback then callback(state) end
            end

            btn.MouseButton1Click:Connect(function() SetState(not state) end)
            table.insert(tabObj.Elements, {Type = "Toggle", Title = title, Card = toggleCard, Set = SetState})
            return {Set = SetState}
        end

        function tabObj:CreateButton(title, isPrimary, callback)
            local btnCard = Instance.new("TextButton")
            btnCard.Name = "Btn_" .. title
            btnCard.Size = UDim2.new(1, 0, 0, 34)
            btnCard.BackgroundColor3 = isPrimary and Config.AccentColor or Color3.fromRGB(32, 32, 42)
            btnCard.BorderSizePixel = 0
            btnCard.Text = title
            btnCard.Font = Enum.Font.GothamBold
            btnCard.TextSize = 11
            btnCard.TextColor3 = Color3.fromRGB(255, 255, 255)
            btnCard.AutoButtonColor = false
            btnCard.ZIndex = 1004
            btnCard.Parent = pageScroll

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = btnCard

            local stroke = Instance.new("UIStroke")
            stroke.Color = isPrimary and Color3.fromRGB(240, 130, 255) or Color3.fromRGB(44, 44, 58)
            stroke.Thickness = 1
            stroke.Parent = btnCard

            btnCard.MouseEnter:Connect(function()
                local hoverColor = isPrimary and Color3.fromRGB(235, 90, 255) or Color3.fromRGB(42, 42, 54)
                pcall(function()
                    TweenService:Create(btnCard, TweenInfo.new(0.15), {BackgroundColor3 = hoverColor}):Play()
                end)
            end)

            btnCard.MouseLeave:Connect(function()
                local baseColor = isPrimary and Config.AccentColor or Color3.fromRGB(32, 32, 42)
                pcall(function()
                    TweenService:Create(btnCard, TweenInfo.new(0.15), {BackgroundColor3 = baseColor}):Play()
                end)
            end)

            btnCard.MouseButton1Click:Connect(function()
                pcall(function()
                    TweenService:Create(btnCard, TweenInfo.new(0.08), {Size = UDim2.new(1, -4, 0, 32)}):Play()
                    task.wait(0.08)
                    TweenService:Create(btnCard, TweenInfo.new(0.08), {Size = UDim2.new(1, 0, 0, 34)}):Play()
                end)
                if callback then callback() end
            end)

            table.insert(tabObj.Elements, {Type = "Button", Title = title, Card = btnCard})
            return btnCard
        end

        function tabObj:CreateSlider(title, min, max, defaultVal, callback)
            local sliderCard = Instance.new("Frame")
            sliderCard.Name = "Slider_" .. title
            sliderCard.Size = UDim2.new(1, 0, 0, 46)
            sliderCard.BackgroundColor3 = Color3.fromRGB(19, 19, 25)
            sliderCard.BorderSizePixel = 0
            sliderCard.ZIndex = 1004
            sliderCard.Parent = pageScroll

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = sliderCard

            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(28, 28, 38)
            stroke.Thickness = 1
            stroke.Parent = sliderCard

            local tLabel = Instance.new("TextLabel")
            tLabel.Text = title
            tLabel.Font = Enum.Font.GothamMedium
            tLabel.TextSize = 11
            tLabel.TextColor3 = Color3.fromRGB(240, 240, 250)
            tLabel.Position = UDim2.new(0, 10, 0, 6)
            tLabel.Size = UDim2.new(1, -70, 0, 14)
            tLabel.BackgroundTransparency = 1
            tLabel.TextXAlignment = Enum.TextXAlignment.Left
            tLabel.ZIndex = 1005
            tLabel.Parent = sliderCard

            local valLabel = Instance.new("TextLabel")
            valLabel.Text = tostring(defaultVal)
            valLabel.Font = Enum.Font.GothamBold
            valLabel.TextSize = 11
            valLabel.TextColor3 = Config.AccentColor
            valLabel.Position = UDim2.new(1, -55, 0, 6)
            valLabel.Size = UDim2.new(0, 45, 0, 14)
            valLabel.BackgroundTransparency = 1
            valLabel.TextXAlignment = Enum.TextXAlignment.Right
            valLabel.ZIndex = 1005
            valLabel.Parent = sliderCard

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -20, 0, 5)
            track.Position = UDim2.new(0, 10, 0, 28)
            track.BackgroundColor3 = Color3.fromRGB(34, 34, 46)
            track.BorderSizePixel = 0
            track.ZIndex = 1005
            track.Parent = sliderCard

            local trCorner = Instance.new("UICorner")
            trCorner.CornerRadius = UDim.new(1, 0)
            trCorner.Parent = track

            local pct = math.clamp((defaultVal - min) / (max - min), 0, 1)
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(pct, 0, 1, 0)
            fill.BackgroundColor3 = Config.AccentColor
            fill.BorderSizePixel = 0
            fill.ZIndex = 1006
            fill.Parent = track

            local fCorner = Instance.new("UICorner")
            fCorner.CornerRadius = UDim.new(1, 0)
            fCorner.Parent = fill

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 11, 0, 11)
            knob.Position = UDim2.new(1, -5, 0.5, -5)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.BorderSizePixel = 0
            knob.ZIndex = 1007
            knob.Parent = fill

            local knCorner = Instance.new("UICorner")
            knCorner.CornerRadius = UDim.new(1, 0)
            knCorner.Parent = knob

            local isDragging = false
            local function UpdateSlider(inputPos)
                local relX = math.clamp(inputPos.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
                local newPct = relX / track.AbsoluteSize.X
                local val = math.floor((min + (max - min) * newPct) * 10) / 10
                if max > 50 then val = math.floor(min + (max - min) * newPct) end
                fill.Size = UDim2.new(newPct, 0, 1, 0)
                valLabel.Text = tostring(val)
                if callback then callback(val) end
            end

            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = true
                    UpdateSlider(input.Position)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input.Position)
                end
            end)

            table.insert(tabObj.Elements, {Type = "Slider", Title = title, Card = sliderCard})
        end

        function tabObj:CreateDropdown(title, items, defaultItem, callback)
            local dropCard = Instance.new("Frame")
            dropCard.Name = "Dropdown_" .. title
            dropCard.Size = UDim2.new(1, 0, 0, 38)
            dropCard.BackgroundColor3 = Color3.fromRGB(19, 19, 25)
            dropCard.BorderSizePixel = 0
            dropCard.ClipsDescendants = false
            dropCard.ZIndex = 1004
            dropCard.Parent = pageScroll

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = dropCard

            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(28, 28, 38)
            stroke.Thickness = 1
            stroke.Parent = dropCard

            local tLabel = Instance.new("TextLabel")
            tLabel.Text = title
            tLabel.Font = Enum.Font.GothamMedium
            tLabel.TextSize = 11
            tLabel.TextColor3 = Color3.fromRGB(240, 240, 250)
            tLabel.Position = UDim2.new(0, 10, 0, 0)
            tLabel.Size = UDim2.new(0.48, 0, 1, 0)
            tLabel.BackgroundTransparency = 1
            tLabel.TextXAlignment = Enum.TextXAlignment.Left
            tLabel.ZIndex = 1005
            tLabel.Parent = dropCard

            local selBtn = Instance.new("TextButton")
            selBtn.Size = UDim2.new(0.5, -10, 0, 24)
            selBtn.Position = UDim2.new(0.5, 0, 0.5, -12)
            selBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
            selBtn.BorderSizePixel = 0
            selBtn.Text = (defaultItem or "Select...") .. "  ▼"
            selBtn.Font = Enum.Font.Gotham
            selBtn.TextSize = 10
            selBtn.TextColor3 = Color3.fromRGB(200, 200, 215)
            selBtn.ZIndex = 1005
            selBtn.Parent = dropCard

            local selCorner = Instance.new("UICorner")
            selCorner.CornerRadius = UDim.new(0, 6)
            selCorner.Parent = selBtn

            local listFrame = Instance.new("ScrollingFrame")
            listFrame.Size = UDim2.new(1, 0, 0, 100)
            listFrame.Position = UDim2.new(0, 0, 1, 4)
            listFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
            listFrame.BorderSizePixel = 0
            listFrame.ScrollBarThickness = 2
            listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
            listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
            listFrame.Visible = false
            listFrame.ZIndex = 2500
            listFrame.Parent = selBtn

            local listCorner = Instance.new("UICorner")
            listCorner.CornerRadius = UDim.new(0, 6)
            listCorner.Parent = listFrame

            local listStroke = Instance.new("UIStroke")
            listStroke.Color = Color3.fromRGB(42, 42, 54)
            listStroke.Thickness = 1
            listStroke.Parent = listFrame

            local listLayout = Instance.new("UIListLayout")
            listLayout.Padding = UDim.new(0, 2)
            listLayout.Parent = listFrame

            local function RefreshItems(newItems)
                for _, c in pairs(listFrame:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for _, itm in ipairs(newItems) do
                    local itemBtn = Instance.new("TextButton")
                    itemBtn.Size = UDim2.new(1, 0, 0, 22)
                    itemBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
                    itemBtn.BackgroundTransparency = 0.5
                    itemBtn.BorderSizePixel = 0
                    itemBtn.Text = tostring(itm)
                    itemBtn.Font = Enum.Font.Gotham
                    itemBtn.TextSize = 10
                    itemBtn.TextColor3 = Color3.fromRGB(230, 230, 240)
                    itemBtn.ZIndex = 2501
                    itemBtn.Parent = listFrame

                    itemBtn.MouseButton1Click:Connect(function()
                        selBtn.Text = tostring(itm) .. "  ▼"
                        listFrame.Visible = false
                        if callback then callback(itm) end
                    end)
                end
            end

            RefreshItems(items)

            selBtn.MouseButton1Click:Connect(function()
                listFrame.Visible = not listFrame.Visible
            end)

            table.insert(tabObj.Elements, {Type = "Dropdown", Title = title, Card = dropCard, Refresh = RefreshItems})
            return {Refresh = RefreshItems}
        end

        function tabObj:CreateInput(title, placeholder, defaultVal, callback)
            local inputCard = Instance.new("Frame")
            inputCard.Name = "Input_" .. title
            inputCard.Size = UDim2.new(1, 0, 0, 38)
            inputCard.BackgroundColor3 = Color3.fromRGB(19, 19, 25)
            inputCard.BorderSizePixel = 0
            inputCard.ZIndex = 1004
            inputCard.Parent = pageScroll

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = inputCard

            local stroke = Instance.new("UIStroke")
            stroke.Color = Color3.fromRGB(28, 28, 38)
            stroke.Thickness = 1
            stroke.Parent = inputCard

            local tb = Instance.new("TextBox")
            tb.PlaceholderText = placeholder or title
            tb.Text = defaultVal or ""
            tb.Font = Enum.Font.Gotham
            tb.TextSize = 11
            tb.TextColor3 = Color3.fromRGB(240, 240, 250)
            tb.PlaceholderColor3 = Color3.fromRGB(100, 100, 115)
            tb.Size = UDim2.new(1, -20, 1, 0)
            tb.Position = UDim2.new(0, 10, 0, 0)
            tb.BackgroundTransparency = 1
            tb.TextXAlignment = Enum.TextXAlignment.Left
            tb.ClearTextOnFocus = false
            tb.ZIndex = 1005
            tb.Parent = inputCard

            tb.FocusLost:Connect(function()
                if callback then callback(tb.Text) end
            end)

            table.insert(tabObj.Elements, {Type = "Input", Title = title, Card = inputCard, TextBox = tb})
            return tb
        end

        return tabObj
    end

    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(SearchInput.Text)
        if not CurrentTab then return end

        for _, el in pairs(CurrentTab.Elements) do
            if query == "" or SafeFind(el.Title, query) then
                el.Card.Visible = true
            else
                el.Card.Visible = false
            end
        end
    end)

    -- Вкладки
    local TabAutoFarm  = CreateTab("Авто фарм", "💲", "Автоматизация больницы и заработка", 1)
    local TabHospital  = CreateTab("Больница", "🩺", "Управление пациентами, уход и лечение", 2)
    local TabRoom7     = CreateTab("Палата 7", "⚡", "Реанимация, ЭКГ сердца и капельница", 3)
    local TabQuests    = CreateTab("Задания", "📜", "Автовыполнение и квесты", 4)
    local TabTeleports = CreateTab("Телепорты", "🚀", "Мгновенное перемещение по палатам 1-7", 5)
    local TabPlayer    = CreateTab("Игрок", "👤", "Модификаторы скорости, прыжка и рассудка", 6)
    local TabVisuals   = CreateTab("Visuals", "👁️", "ESP подсветка, дистанция и трейсеры", 7)
    local TabMisc      = CreateTab("Misc", "📄", "Сервер, FPS Boost и настройки графики", 8)
    local TabSettings  = CreateTab("Settings", "⚙️", "Interface and theme", 9)

    -- 1. Авто фарм
    TabAutoFarm:CreateSection("Основной заработок")
    TabAutoFarm:CreateToggle("Автофарм", "Автоматически выполняет основные действия для заработка валюты", Config.AutoFarm, function(val)
        Config.AutoFarm = val
        SendNotification("Автофарм", val and "Автофарм запущен" or "Автофарм остановлен", 2)
    end)
    TabAutoFarm:CreateToggle("Автосбор", "Автоматически собирает доступные награды, монеты и дропы", Config.AutoCollect, function(val)
        Config.AutoCollect = val
    end)
    TabAutoFarm:CreateToggle("Автовзаимодействие", "Автоматически активирует нужные объекты и NPC в радиусе", Config.AutoInteract, function(val)
        Config.AutoInteract = val
    end)
    TabAutoFarm:CreateSection("Торговля и развитие")
    TabAutoFarm:CreateToggle("Автопродажа", "Автоматически продаёт накопленные ресурсы и вылеченных животных", Config.AutoSell, function(val)
        Config.AutoSell = val
    end)
    TabAutoFarm:CreateToggle("Автопокупка", "Автоматически покупает необходимые предметы и медикаменты", Config.AutoBuy, function(val)
        Config.AutoBuy = val
    end)
    TabAutoFarm:CreateToggle("Автоулучшение", "Автоматически приобретает доступные улучшения больницы", Config.AutoUpgrade, function(val)
        Config.AutoUpgrade = val
    end)
    TabAutoFarm:CreateToggle("Автоустранение саботажей", "Автоматически чинит поломки, протечки и тушит пожары", Config.AutoFixSabotages, function(val)
        Config.AutoFixSabotages = val
    end)

    -- 2. Больница
    TabHospital:CreateSection("Автоматизация лечения (Палаты 1-6)")
    TabHospital:CreateToggle("Автолечение (Full Auto)", "Полный цикл: анализ ДНК -> сканер -> аптека -> лечение", Config.AutoHeal, function(val)
        Config.AutoHeal = val
        SendNotification("Больница", val and "Автолечение запущено!" or "Автолечение выключено", 2)
    end)
    TabHospital:CreateSlider("Задержка лечения (сек)", 0.2, 3.0, Config.HealDelay, function(val)
        Config.HealDelay = val
    end)
    TabHospital:CreateToggle("Авто-ТП к больным", "Телепортирует прямо на койку больного в палате", Config.AutoHealTeleport, function(val)
        Config.AutoHealTeleport = val
    end)
    TabHospital:CreateToggle("Авто-взятие медикаментов", "Автоматически забирает нужные лекарства со шкафа в коридоре", Config.AutoTakeMedicine, function(val)
        Config.AutoTakeMedicine = val
    end)
    TabHospital:CreateToggle("Авто-сканирование анализов", "Автоматически кладет пробирку с анализом в ПК-сканер", Config.AutoScanner, function(val)
        Config.AutoScanner = val
    end)
    TabHospital:CreateToggle("Авто-экипировка лекарств", "Автоматически достает нужные лекарства из рюкзака", Config.AutoEquipTools, function(val)
        Config.AutoEquipTools = val
    end)

    TabHospital:CreateSection("Быстрые действия")
    TabHospital:CreateButton("Взять лекарства со шкафа (Заполнить инвентарь 4/4)", true, function()
        task.spawn(function()
            local count = 0
            for _, obj in pairs(Workspace:GetDescendants()) do
                if IsMedicineCabinetPrompt(obj) then
                    local targetCF = GetPromptTargetCFrame(obj)
                    if targetCF then
                        TeleportTo(targetCF)
                        task.wait(0.15)
                        SafeInteractPrompt(obj)
                        count = count + 1
                        task.wait(0.25)
                        if count >= 4 then break end
                    end
                end
            end
            SendNotification("Аптека", "Взято лекарств: " .. tostring(count), 2)
        end)
    end)
    TabHospital:CreateButton("Сдать анализы в сканер сейчас", false, function()
        task.spawn(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if IsLabScannerPrompt(obj) then
                    local targetCF = GetPromptTargetCFrame(obj)
                    if targetCF then
                        TeleportTo(targetCF)
                        task.wait(0.15)
                        SafeInteractPrompt(obj)
                        task.wait(0.2)
                        SendNotification("Сканер", "Анализ загружен в компьютер!", 2)
                        return
                    end
                end
            end
            SendNotification("Сканер", "Сканер не найден рядом", 2)
        end)
    end)
    TabHospital:CreateButton("Выпить кофе (Восстановить рассудок)", false, function()
        task.spawn(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if IsCoffeePrompt(obj) then
                    local targetCF = GetPromptTargetCFrame(obj)
                    if targetCF then
                        TeleportTo(targetCF)
                        task.wait(0.15)
                        SafeInteractPrompt(obj)
                        SendNotification("Рассудок", "Кофе выпит! Рассудок восстановлен.", 2)
                        return
                    end
                end
            end
            SendNotification("Рассудок", "Кофейный аппарат не найден", 2)
        end)
    end)

    -- 3. ПАЛАТА 7 (РЕАНИМАЦИЯ / ОПЕРАЦИОННАЯ)
    TabRoom7:CreateSection("Реанимация Палаты 7")
    TabRoom7:CreateToggle("Авто-цикл: Палата 7", "Полный автофарм реанимации (ЭКГ + Капельница + Аптечка)", Config.Room7_AutoCycle, function(val)
        Config.Room7_AutoCycle = val
        SendNotification("Палата 7", val and "Авто-цикл палаты 7 активен!" or "Авто-цикл остановлен", 2)
    end)
    TabRoom7:CreateToggle("Авто-решение мини-игры ЭКГ", "Автоматически кликает по точкам сердца на мониторе", Config.Room7_AutoHeartGame, function(val)
        Config.Room7_AutoHeartGame = val
    end)
    TabRoom7:CreateToggle("Авто-капельница и лечение", "Берет капельницу/аптечку и ставит больному кролику", Config.Room7_AutoIVDrip, function(val)
        Config.Room7_AutoIVDrip = val
    end)

    TabRoom7:CreateSection("Быстрые действия Палаты 7")
    TabRoom7:CreateButton("Телепорт в Палату 7 (Койка пациента)", true, function()
        local cf = FindWardCFrame(7)
        if cf then
            TeleportTo(cf)
            SendNotification("Палата 7", "Перемещен к койке реанимации!", 2)
        else
            SendNotification("Палата 7", "Ищем координаты палаты 7...", 2)
        end
    end)
    TabRoom7:CreateButton("Пройти мини-игру сердца сейчас (Мгновенно)", true, function()
        local solved = SolveHeartMinigame()
        SendNotification("Мини-игра", solved and "Точки сердца успешно нажаты!" or "Экран мини-игры пока не открыт", 2)
    end)
    TabRoom7:CreateButton("Взять Капельницу / Аптечку со шкафа", false, function()
        task.spawn(function()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if IsMedicineCabinetPrompt(obj) then
                    local act = string.lower(tostring(obj.ActionText or ""))
                    if SafeFind(act, "капельниц") or SafeFind(act, "drip") or SafeFind(act, "аптечк") or SafeFind(act, "kit") then
                        local targetCF = GetPromptTargetCFrame(obj)
                        if targetCF then
                            TeleportTo(targetCF)
                            task.wait(0.15)
                            SafeInteractPrompt(obj)
                            SendNotification("Медикаменты", "Капельница/Аптечка взята!", 2)
                            return
                        end
                    end
                end
            end
            SendNotification("Медикаменты", "Капельница не найдена на полках", 2)
        end)
    end)

    -- 4. Задания
    TabQuests:CreateSection("Квесты и награды")
    TabQuests:CreateToggle("Автопринятие заданий", "Автоматически принимает доступные квесты у NPC", Config.AutoAcceptQuests, function(val)
        Config.AutoAcceptQuests = val
    end)
    TabQuests:CreateToggle("Автоквест", "Самостоятельно проходит выбранные задания", Config.AutoQuest, function(val)
        Config.AutoQuest = val
    end)
    TabQuests:CreateToggle("Автозавершение квеста", "Автоматически выполняет необходимые условия сдачи", Config.AutoCompleteQuest, function(val)
        Config.AutoCompleteQuest = val
    end)
    TabQuests:CreateToggle("Автополучение наград", "Забирает награду сразу после завершения квеста", Config.AutoClaimRewards, function(val)
        Config.AutoClaimRewards = val
    end)
    TabQuests:CreateToggle("ESP заданий", "Показывает местоположение нужных NPC и объектов", Config.ESP_Quests, function(val)
        Config.ESP_Quests = val
    end)

    -- 5. Телепорты
    TabTeleports:CreateSection("Все палаты больницы (1 - 7)")
    TabTeleports:CreateButton("Палата 1 (Койка пациента)", true, function()
        local cf = FindWardCFrame(1)
        if cf then TeleportTo(cf); SendNotification("Телепорт", "Перемещен в Палату 1", 2)
        else SendNotification("Телепорт", "Палата 1 не найдена", 2) end
    end)
    TabTeleports:CreateButton("Палата 2 (Койка пациента)", true, function()
        local cf = FindWardCFrame(2)
        if cf then TeleportTo(cf); SendNotification("Телепорт", "Перемещен в Палату 2", 2)
        else SendNotification("Телепорт", "Палата 2 не найдена", 2) end
    end)
    TabTeleports:CreateButton("Палата 3 (Койка пациента)", true, function()
        local cf = FindWardCFrame(3)
        if cf then TeleportTo(cf); SendNotification("Телепорт", "Перемещен в Палату 3", 2)
        else SendNotification("Телепорт", "Палата 3 не найдена", 2) end
    end)
    TabTeleports:CreateButton("Палата 4 (Койка пациента)", false, function()
        local cf = FindWardCFrame(4)
        if cf then TeleportTo(cf); SendNotification("Телепорт", "Перемещен в Палату 4", 2)
        else SendNotification("Телепорт", "Палата 4 не найдена", 2) end
    end)
    TabTeleports:CreateButton("Палата 5 (Койка пациента)", false, function()
        local cf = FindWardCFrame(5)
        if cf then TeleportTo(cf); SendNotification("Телепорт", "Перемещен в Палату 5", 2)
        else SendNotification("Телепорт", "Палата 5 не найдена", 2) end
    end)
    TabTeleports:CreateButton("Палата 6 (Койка пациента)", false, function()
        local cf = FindWardCFrame(6)
        if cf then TeleportTo(cf); SendNotification("Телепорт", "Перемещен в Палату 6", 2)
        else SendNotification("Телепорт", "Палата 6 не найдена", 2) end
    end)
    TabTeleports:CreateButton("Палата 7 (Реанимация / ICU)", true, function()
        local cf = FindWardCFrame(7)
        if cf then TeleportTo(cf); SendNotification("Телепорт", "Перемещен в Палату 7 (Реанимация)", 2)
        else SendNotification("Телепорт", "Палата 7 не найдена", 2) end
    end)

    TabTeleports:CreateSection("Инфраструктура")
    TabTeleports:CreateButton("Телепорт к шкафу с медикаментами (Аптека)", false, function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local nearestCF, minDist = nil, math.huge

        for _, obj in pairs(Workspace:GetDescendants()) do
            if IsMedicineCabinetPrompt(obj) then
                local targetCF = GetPromptTargetCFrame(obj)
                if targetCF then
                    local dist = (root.Position - targetCF.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        nearestCF = targetCF
                    end
                end
            end
        end

        if nearestCF then
            TeleportTo(nearestCF)
            SendNotification("Телепорт", "Телепортирован к шкафу с лекарствами!", 2)
        else
            SendNotification("Телепорт", "Шкаф с лекарствами не найден", 2)
        end
    end)

    TabTeleports:CreateButton("Телепорт к кофе (Восстановление рассудка)", false, function()
        for _, obj in pairs(Workspace:GetDescendants()) do
            if IsCoffeePrompt(obj) then
                local targetCF = GetPromptTargetCFrame(obj)
                if targetCF then
                    TeleportTo(targetCF)
                    SendNotification("Телепорт", "Телепортирован к кофейному аппарату!", 2)
                    return
                end
            end
        end
        SendNotification("Телепорт", "Кофейный аппарат не найден", 2)
    end)

    -- 6. Игрок
    TabPlayer:CreateSection("Параметры персонажа")
    TabPlayer:CreateToggle("Изменение скорости", "Включает кастомную скорость передвижения", Config.WalkSpeedEnabled, function(val)
        Config.WalkSpeedEnabled = val
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = val and Config.WalkSpeed or 16 end
    end)
    TabPlayer:CreateSlider("Скорость (WalkSpeed)", 16, 250, Config.WalkSpeed, function(val)
        Config.WalkSpeed = val
        if Config.WalkSpeedEnabled then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = val end
        end
    end)
    TabPlayer:CreateToggle("Изменение прыжка", "Включает повышенную высоту прыжка", Config.JumpPowerEnabled, function(val)
        Config.JumpPowerEnabled = val
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = val and Config.JumpPower or 50
        end
    end)
    TabPlayer:CreateSlider("Высота прыжка (JumpPower)", 50, 300, Config.JumpPower, function(val)
        Config.JumpPower = val
        if Config.JumpPowerEnabled then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then
                hum.UseJumpPower = true
                hum.JumpPower = val
            end
        end
    end)
    TabPlayer:CreateSection("Утилиты")
    TabPlayer:CreateToggle("NoClip", "Прохождение сквозь объекты и стены", Config.NoClip, function(val)
        Config.NoClip = val
        SendNotification("NoClip", val and "NoClip включен" or "NoClip выключен", 2)
    end)
    TabPlayer:CreateToggle("Anti AFK", "Предотвращает кик за неактивность", Config.AntiAFK, function(val)
        Config.AntiAFK = val
    end)
    TabPlayer:CreateToggle("Бесконечный рассудок (Auto Coffee)", "Автоматически выпивает кофе при падении рассудка", Config.InfiniteSanity, function(val)
        Config.InfiniteSanity = val
    end)
    TabPlayer:CreateToggle("Бесконечный прыжок", "Позволяет совершать бесконечные прыжки в воздухе", Config.InfiniteJump, function(val)
        Config.InfiniteJump = val
    end)

    -- 7. Visuals
    TabVisuals:CreateSection("ESP Подсветка")
    TabVisuals:CreateToggle("ESP Игроков", "Подсвечивает всех игроков на сервере", Config.ESP_Players, function(val)
        Config.ESP_Players = val
    end)
    TabVisuals:CreateToggle("ESP Коек с пациентами", "Подсвечивает койки с больными животными", Config.ESP_Patients, function(val)
        Config.ESP_Patients = val
    end)
    TabVisuals:CreateToggle("ESP Шкафов с медикаментами", "Подсвечивает полки с лекарствами в коридоре", Config.ESP_Cabinets, function(val)
        Config.ESP_Cabinets = val
    end)
    TabVisuals:CreateToggle("ESP Предметов", "Выделяет ресурсы, медикаменты, монеты и мусор", Config.ESP_Items, function(val)
        Config.ESP_Items = val
    end)
    TabVisuals:CreateSection("Дополнительно")
    TabVisuals:CreateToggle("Дистанция", "Отображает расстояние в studs до каждого объекта", Config.ShowDistance, function(val)
        Config.ShowDistance = val
    end)
    TabVisuals:CreateToggle("Tracers (Линии)", "Рисует направляющие линии к объектам", Config.Tracers, function(val)
        Config.Tracers = val
    end)

    -- 8. Misc
    TabMisc:CreateSection("Сервер")
    TabMisc:CreateButton("Rejoin (Перезайти на сервер)", false, function()
        SendNotification("Сервер", "Перезаход на сервер...", 2)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)
    TabMisc:CreateButton("Server Hop (Сменить сервер)", true, function()
        SendNotification("Сервер", "Поиск других публичных серверов...", 3)
        task.spawn(function()
            local sfUrl = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"
            local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(sfUrl)) end)
            if success and result and result.data then
                for _, s in ipairs(result.data) do
                    if s.playing and s.maxPlayers and s.playing < s.maxPlayers and s.id ~= game.JobId then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                        return
                    end
                end
            end
            SendNotification("Сервер", "Не удалось найти сервер для перехода.", 3)
        end)
    end)
    TabMisc:CreateSection("Оптимизация производительности")
    TabMisc:CreateToggle("FPS Boost", "Отключает тяжелые частицы, тени и разгружает движок", Config.FPSBoost, function(val)
        Config.FPSBoost = val
        if val then
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then v.Enabled = false end
            end
            SendNotification("FPS Boost", "Визуальные эффекты упрощены", 2)
        end
    end)
    TabMisc:CreateToggle("Low Graphics", "Снижает качество текстур и материалов", Config.LowGraphics, function(val)
        Config.LowGraphics = val
        if val then
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsA("MeshPart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 0.5
                end
            end
            SendNotification("Low Graphics", "Режим низкой графики активирован", 2)
        end
    end)

    -- 9. Settings
    local ConfigNameInput = TabSettings:CreateInput("Config name", "Введите название конфига...", "default", function(val)
        Config.SelectedConfig = val
    end)
    local ConfigDropdown
    local function GetSavedConfigs()
        local cfgList = {"Default"}
        pcall(function()
            if isfolder and isfolder("AverlikHub/Configs") and listfiles then
                for _, f in pairs(listfiles("AverlikHub/Configs")) do
                    local name = string.match(f, "([^/\\]+)%.json$")
                    if name then table.insert(cfgList, name) end
                end
            end
        end)
        for k, _ in pairs(MemoryConfigs) do
            if not table.find(cfgList, k) then table.insert(cfgList, k) end
        end
        return cfgList
    end
    TabSettings:CreateButton("Create config", true, function()
        local name = ConfigNameInput.Text ~= "" and ConfigNameInput.Text or "Default"
        MemoryConfigs[name] = HttpService:JSONEncode(Config)
        pcall(function()
            if makefolder and writefile then
                if not isfolder("AverlikHub") then makefolder("AverlikHub") end
                if not isfolder("AverlikHub/Configs") then makefolder("AverlikHub/Configs") end
                writefile("AverlikHub/Configs/" .. name .. ".json", HttpService:JSONEncode(Config))
            end
        end)
        SendNotification("Config", "Конфиг '" .. name .. "' успешно создан!", 3)
        if ConfigDropdown then ConfigDropdown.Refresh(GetSavedConfigs()) end
    end)
    ConfigDropdown = TabSettings:CreateDropdown("Selected config", GetSavedConfigs(), Config.SelectedConfig, function(val)
        Config.SelectedConfig = val
    end)
    TabSettings:CreateButton("Save config", true, function()
        local name = Config.SelectedConfig or "Default"
        MemoryConfigs[name] = HttpService:JSONEncode(Config)
        pcall(function()
            if writefile and makefolder then
                if not isfolder("AverlikHub") then makefolder("AverlikHub") end
                if not isfolder("AverlikHub/Configs") then makefolder("AverlikHub/Configs") end
                writefile("AverlikHub/Configs/" .. name .. ".json", HttpService:JSONEncode(Config))
            end
        end)
        SendNotification("Config", "Конфиг '" .. name .. "' сохранен!", 3)
    end)

    -- Активация 1 вкладки
    pcall(function()
        Tabs[1].Button.BackgroundColor3 = Color3.fromRGB(26, 25, 34)
        Tabs[1].Button.BackgroundTransparency = 0
        local lbl = Tabs[1].Button:FindFirstChild("Label")
        local icn = Tabs[1].Button:FindFirstChild("Icon")
        if lbl then lbl.TextColor3 = Color3.fromRGB(255, 255, 255) end
        if icn then icn.TextColor3 = Config.AccentColor end
        Tabs[1].Page.Visible = true
        CurrentTab = Tabs[1]
        HeaderTitle.Text = Tabs[1].Name
        HeaderSub.Text = Tabs[1].Subtitle
    end)

    pcall(function()
        LocalPlayer.Idled:Connect(function()
            if Config.AntiAFK then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end
        end)
    end)

    RunService.Stepped:Connect(function()
        if Config.NoClip then
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                end
            end
        end
    end)

    UserInputService.JumpRequest:Connect(function()
        if Config.InfiniteJump then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            if Config.WalkSpeedEnabled then hum.WalkSpeed = Config.WalkSpeed end
            if Config.JumpPowerEnabled then
                hum.UseJumpPower = true
                hum.JumpPower = Config.JumpPower
            end
        end
    end)

    local fpsCount, lastFpsTime = 0, tick()
    local currentFps = 60
    RunService.RenderStepped:Connect(function()
        fpsCount = fpsCount + 1
        if tick() - lastFpsTime >= 1 then
            currentFps = fpsCount
            fpsCount = 0
            lastFpsTime = tick()
            local timeStr = os.date("%H:%M")
            local statusText = timeStr .. " • " .. tostring(currentFps) .. " fps"
            FooterSub.Text = statusText
            PillSub.Text = statusText
        end
    end)

    -- ══════════════════════════════════════════════════════════════════════════
    -- 🩺 ПОЛНЫЙ ЦИКЛ АВТОЛЕЧЕНИЯ (ПАЛАТЫ 1-6)
    -- ══════════════════════════════════════════════════════════════════════════
    local isHandlingPatient = false

    local function FindActiveBedTarget()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return nil, nil end

        local candidates = {}
        local now = tick()

        for _, obj in pairs(Workspace:GetDescendants()) do
            if IsBedPatientPrompt(obj) then
                if not DebounceMap[obj] or (now - DebounceMap[obj]) > 3.0 then
                    local targetCF = GetPromptTargetCFrame(obj)
                    if targetCF then
                        local dist = (root.Position - targetCF.Position).Magnitude
                        table.insert(candidates, {Prompt = obj, CFrame = targetCF, Distance = dist})
                    end
                end
            end
        end

        if #candidates == 0 then return nil, nil end
        table.sort(candidates, function(a, b) return a.Distance < b.Distance end)
        return candidates[1].Prompt, candidates[1].CFrame
    end

    task.spawn(function()
        while true do
            task.wait(0.2)
            if Config.AutoHeal and not isHandlingPatient then
                local bestPrompt, bestCF = FindActiveBedTarget()
                if bestPrompt and bestCF and bestPrompt.Enabled then
                    isHandlingPatient = true
                    DebounceMap[bestPrompt] = tick()

                    pcall(function()
                        local char = LocalPlayer.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        if root then
                            if Config.AutoHealTeleport then
                                TeleportTo(bestCF)
                                task.wait(0.18)
                            end

                            if Config.AutoEquipTools then
                                EquipAnyMedicalTool()
                            end

                            SafeInteractPrompt(bestPrompt)
                            task.wait(math.max(bestPrompt.HoldDuration or 0.3, Config.HealDelay or 0.8))

                            if Config.AutoScanner then
                                for _, scObj in pairs(Workspace:GetDescendants()) do
                                    if IsLabScannerPrompt(scObj) then
                                        local scCF = GetPromptTargetCFrame(scObj)
                                        if scCF then
                                            TeleportTo(scCF)
                                            task.wait(0.15)
                                            SafeInteractPrompt(scObj)
                                            task.wait(0.2)
                                            break
                                        end
                                    end
                                end
                            end

                            if Config.AutoTakeMedicine then
                                local bp = LocalPlayer:FindFirstChild("Backpack")
                                local toolCount = bp and #bp:GetChildren() or 0
                                if toolCount < 4 then
                                    for _, medObj in pairs(Workspace:GetDescendants()) do
                                        if IsMedicineCabinetPrompt(medObj) then
                                            local medCF = GetPromptTargetCFrame(medObj)
                                            if medCF then
                                                TeleportTo(medCF)
                                                task.wait(0.15)
                                                SafeInteractPrompt(medObj)
                                                task.wait(0.2)
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)

                    isHandlingPatient = false
                end
            end
        end
    end)

    -- ══════════════════════════════════════════════════════════════════════════
    -- ⚡ ЦИКЛ АВТОФАРМА ПАЛАТЫ 7 (РЕАНИМАЦИЯ / ЭКГ / КАПЕЛЬНИЦА)
    -- ══════════════════════════════════════════════════════════════════════════
    local isHandlingRoom7 = false
    task.spawn(function()
        while true do
            task.wait(0.25)
            if Config.Room7_AutoCycle and not isHandlingRoom7 then
                isHandlingRoom7 = true
                pcall(function()
                    local room7CF = FindWardCFrame(7)
                    if room7CF then
                        -- 1. ТП в палату 7 к монитору/пациенту
                        TeleportTo(room7CF)
                        task.wait(0.2)

                        -- 2. Взаимодействие с монитором сердца
                        if Config.Room7_AutoHeartGame then
                            for _, obj in pairs(Workspace:GetDescendants()) do
                                if IsRoom7HeartMonitorPrompt(obj) then
                                    local mCF = GetPromptTargetCFrame(obj)
                                    if mCF then TeleportTo(mCF) task.wait(0.15) end
                                    SafeInteractPrompt(obj)
                                    task.wait(0.3)
                                    break
                                end
                            end

                            -- Автоклик по точкам сердца
                            for i = 1, 15 do
                                SolveHeartMinigame()
                                task.wait(0.1)
                            end
                        end

                        -- 3. Взятие капельницы или аптечки
                        if Config.Room7_AutoIVDrip then
                            for _, medObj in pairs(Workspace:GetDescendants()) do
                                if IsMedicineCabinetPrompt(medObj) then
                                    local act = string.lower(tostring(medObj.ActionText or ""))
                                    if SafeFind(act, "капельниц") or SafeFind(act, "drip") or SafeFind(act, "аптечк") then
                                        local medCF = GetPromptTargetCFrame(medObj)
                                        if medCF then
                                            TeleportTo(medCF)
                                            task.wait(0.15)
                                            SafeInteractPrompt(medObj)
                                            task.wait(0.2)
                                            break
                                        end
                                    end
                                end
                            end

                            -- 4. Применение капельницы к пациенту в палате 7
                            TeleportTo(room7CF)
                            task.wait(0.18)
                            EquipAnyMedicalTool("капельниц")
                            for _, pPrompt in pairs(Workspace:GetDescendants()) do
                                if IsBedPatientPrompt(pPrompt) then
                                    local pCF = GetPromptTargetCFrame(pPrompt)
                                    if pCF and (room7CF.Position - pCF.Position).Magnitude < 25 then
                                        SafeInteractPrompt(pPrompt)
                                        task.wait(0.5)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end)
                isHandlingRoom7 = false
            end
        end
    end)

    -- Авто-кофе
    task.spawn(function()
        while true do
            task.wait(2.5)
            if Config.InfiniteSanity then
                pcall(function()
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if IsCoffeePrompt(obj) then
                            local targetCF = GetPromptTargetCFrame(obj)
                            if targetCF then
                                TeleportTo(targetCF)
                                task.wait(0.15)
                                SafeInteractPrompt(obj)
                                task.wait(0.3)
                                break
                            end
                        end
                    end
                end)
            end
        end
    end)

    SendNotification("Averlik Hub", "Animal Hospital (Палата 7) загружен!", 4)
    print("[Averlik Hub] Готово к работе!")
end

local ok, err = pcall(RunAverlikHub)
if not ok then
    warn("[Averlik Hub Error]:", err)
end
