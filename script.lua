--[[
    ══════════════════════════════════════════════════════════════════════════════════
    👑 AVERLIK HUB - ANIMAL HOSPITAL (PRO WAYPOINT CUSTOMIZER & SMART AUTOFARM)
    ══════════════════════════════════════════════════════════════════════════════════
    • Возможности:
        1. 📍 ПОЛНАЯ НАСТРОЙКА ТОЧЕК ТЕЛЕПОРТА (Пользователь сам задает куда ТПшить)
        2. 💾 Сохранение и загрузка точек из файла Waypoints.json
        3. 🧠 Smart Targeter: находит живого больного в любой палате без спама пустых комнат
        4. 💊 Контроль инвентаря (3/3): не спамит шкафы если полная сумка
        5. ⚡ Палата 7 (Реанимация / Мини-игра сердца)
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

    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then
        repeat
            task.wait(0.05)
            LocalPlayer = Players.LocalPlayer
        until LocalPlayer
    end

    -- Звук запуска
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

    -- Таблица пользовательских точек телепорта (Waypoints)
    local CustomWaypoints = {
        Ward1 = Vector3.new(-168.42, 5.81, -41.04),
        Ward2 = Vector3.new(-121.33, 5.81, -59.95),
        Ward3 = Vector3.new(-168.08, 5.81, -80.10),
        Ward4 = Vector3.new(-121.16, 5.81, -99.06),
        Ward5 = Vector3.new(-153.91, 5.81, -114.83),
        Ward6 = nil,
        Ward7 = nil,
        Cabinets = nil,
        LabScanner = nil,
        Reception = Vector3.new(-108.72, 3.41, 10.20),
        Coffee = Vector3.new(-123.82, 7.93, 10.22)
    }

    -- Конфигурация
    local Config = {
        AutoHospitalCycle = false,
        AutoRegistration = true,
        StepDelay = 0.5,

        -- Палата 7
        Room7_AutoCycle = false,
        Room7_AutoHeartGame = true,
        Room7_AutoIVDrip = true,

        -- Игрок
        WalkSpeed = 16,
        WalkSpeedEnabled = false,
        NoClip = false,
        AntiAFK = true,
        InfiniteSanity = true,

        -- Visuals & Misc
        FPSBoost = false,
        LowGraphics = false,

        AccentColor = Color3.fromRGB(219, 70, 237),
        BackgroundColor = Color3.fromRGB(16, 16, 20),
        SidebarColor = Color3.fromRGB(13, 13, 16),
        SelectedConfig = "Default"
    }

    -- Загрузка точек из файла если существует
    pcall(function()
        if readfile and isfile and isfile("AverlikHub/Waypoints.json") then
            local data = HttpService:JSONDecode(readfile("AverlikHub/Waypoints.json"))
            if data and type(data) == "table" then
                for k, v in pairs(data) do
                    if v and v.x and v.y and v.z then
                        CustomWaypoints[k] = Vector3.new(v.x, v.y, v.z)
                    end
                end
            end
        end
    end)

    local function SafeFind(str, query)
        if not str or type(str) ~= "string" or not query then return false end
        return string.find(string.lower(str), string.lower(query), 1, true) ~= nil
    end

    -- Фильтр дверей и мусора
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

    local function GetPromptTargetCFrame(prompt)
        if not prompt then return nil end
        local parent = prompt.Parent
        if not parent then return nil end

        if parent:IsA("Attachment") then return parent.WorldCFrame end
        if parent:IsA("BasePart") then return parent.CFrame end
        if parent:IsA("Model") then
            local pPart = parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart", true)
            if pPart then return pPart.CFrame end
        end

        local ancestorPart = prompt:FindFirstAncestorWhichIsA("BasePart")
        if ancestorPart then return ancestorPart.CFrame end

        return nil
    end

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
                    root.CFrame = CFrame.new(cf + Vector3.new(0, 2.5, 0))
                elseif typeof(cf) == "CFrame" then
                    root.CFrame = cf + Vector3.new(0, 2.5, 0)
                end
            end
        end)
    end

    local function GetMyPosition()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        return root and root.Position or nil
    end

    local function SafeInteractPrompt(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return false end
        local holdTime = prompt.HoldDuration or 0
        pcall(function()
            if fireproximityprompt then
                fireproximityprompt(prompt, holdTime)
            else
                prompt:InputHoldBegin()
                task.wait(holdTime > 0 and (holdTime + 0.1) or 0.15)
                prompt:InputHoldEnd()
            end
        end)
        return true
    end

    local function EquipMedicalTool(preferredName)
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
                task.wait(0.1)
                pcall(function() targetTool:Activate() end)
            end
        end)
    end

    local function FindWardModel(wardNumber)
        local query = "палата " .. tostring(wardNumber)
        local queryEng = "room " .. tostring(wardNumber)
        local queryNum = tostring(wardNumber)

        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") then
                local oName = string.lower(obj.Name)
                if oName == query or oName == queryEng or (SafeFind(oName, "room") and SafeFind(oName, queryNum)) or (SafeFind(oName, "палат") and SafeFind(oName, queryNum)) then
                    return obj
                end
            end
        end
        return nil
    end

    local function FindWardBedPosition(wardNumber)
        local key = "Ward" .. tostring(wardNumber)
        if CustomWaypoints[key] then
            return CustomWaypoints[key]
        end

        local wardModel = FindWardModel(wardNumber)
        if wardModel then
            local bed = wardModel:FindFirstChild("Bed", true) or wardModel:FindFirstChild("HospitalBed", true) or wardModel:FindFirstChild("Mattress", true)
            if bed then
                return bed:IsA("Model") and (bed.PrimaryPart and bed.PrimaryPart.Position or bed:GetBoundingBox().Position) or bed.Position
            end
            local anyPart = wardModel:FindFirstChildWhichIsA("BasePart", true)
            if anyPart then return anyPart.Position end
        end
        return nil
    end

    local function IsDNAPrompt(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled or IsDoorOrTrash(prompt) then return false end
        local act = string.lower(tostring(prompt.ActionText or ""))
        return SafeFind(act, "анализ") or SafeFind(act, "днк") or SafeFind(act, "dna") or SafeFind(act, "sample")
    end

    local function IsLabMachinePrompt(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled or IsDoorOrTrash(prompt) then return false end
        local act = string.lower(tostring(prompt.ActionText or ""))
        local objT = string.lower(tostring(prompt.ObjectText or ""))
        local pName = string.lower(tostring(prompt.Parent and prompt.Parent.Name or ""))
        return SafeFind(act, "провест") or SafeFind(act, "сканир") or SafeFind(act, "scan") or SafeFind(act, "встав") or SafeFind(objT, "компьют") or SafeFind(pName, "scan") or SafeFind(pName, "pc") or SafeFind(pName, "lab")
    end

    local function IsCabinetPrompt(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled or IsDoorOrTrash(prompt) then return false end
        local pName = string.lower(tostring(prompt.Parent and prompt.Parent.Name or ""))
        local gName = string.lower(tostring(prompt.Parent and prompt.Parent.Parent and prompt.Parent.Parent.Name or ""))
        if SafeFind(pName, "shelf") or SafeFind(pName, "cabinet") or SafeFind(pName, "шкаф") or SafeFind(pName, "полк") or SafeFind(gName, "shelf") or SafeFind(gName, "cabinet") or SafeFind(gName, "шкаф") then
            return true
        end
        local act = string.lower(tostring(prompt.ActionText or ""))
        local medWords = {"травы", "сироп", "аптечка", "таблетк", "пластыр", "бинт", "капельниц", "шприц", "herbs", "syrup", "kit", "pill"}
        for _, m in ipairs(medWords) do
            if SafeFind(act, m) and not SafeFind(pName, "bed") and not SafeFind(pName, "patient") then
                return true
            end
        end
        return false
    end

    local function IsHealPrompt(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled or IsDoorOrTrash(prompt) then return false end
        local act = string.lower(tostring(prompt.ActionText or ""))
        return SafeFind(act, "лечит") or SafeFind(act, "heal") or SafeFind(act, "дать") or SafeFind(act, "give") or SafeFind(act, "укол")
    end

    local function IsReceptionPrompt(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled or IsDoorOrTrash(prompt) then return false end
        local act = string.lower(tostring(prompt.ActionText or ""))
        local objT = string.lower(tostring(prompt.ObjectText or ""))
        local pName = string.lower(tostring(prompt.Parent and prompt.Parent.Name or ""))
        return SafeFind(act, "регистр") or SafeFind(act, "звонок") or SafeFind(act, "bell") or SafeFind(objT, "регистр") or SafeFind(pName, "reception") or SafeFind(pName, "bell")
    end

    local function IsCoffeePrompt(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled or IsDoorOrTrash(prompt) then return false end
        local act = string.lower(tostring(prompt.ActionText or ""))
        local objT = string.lower(tostring(prompt.ObjectText or ""))
        local pName = string.lower(tostring(prompt.Parent and prompt.Parent.Name or ""))
        return SafeFind(act, "coffee") or SafeFind(act, "кофе") or SafeFind(objT, "кофе") or SafeFind(objT, "рассудок") or SafeFind(pName, "coffee")
    end

    local function SolveHeartMinigame()
        local solved = false
        pcall(function()
            local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if not pg then return end
            for _, gui in pairs(pg:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Enabled and gui.Name ~= "AverlikHub_MainGui" then
                    for _, btn in pairs(gui:GetDescendants()) do
                        if (btn:IsA("ImageButton") or btn:IsA("TextButton")) and btn.Visible and btn.Active then
                            local bName = string.lower(btn.Name)
                            if SafeFind(bName, "click") or SafeFind(bName, "hand") or SafeFind(bName, "tap") or SafeFind(bName, "target") or SafeFind(bName, "point") or SafeFind(bName, "heart") then
                                pcall(function()
                                    if firesignal then
                                        firesignal(btn.MouseButton1Click)
                                        firesignal(btn.Activated)
                                    end
                                end)
                                solved = true
                            end
                        end
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
    local winW = math.clamp(vpSize.X - 40, 340, 680)
    local winH = math.clamp(vpSize.Y - 60, 300, 460)

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
    Sidebar.Parent = MainWindow

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
    HeaderTitle.Text = "Больница"
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
    HeaderSub.Text = "Настройка точек и авто-лечение"
    HeaderSub.Font = Enum.Font.Gotham
    HeaderSub.TextSize = 10
    HeaderSub.TextColor3 = Color3.fromRGB(140, 140, 155)
    HeaderSub.Position = UDim2.new(0, 16, 0, 29)
    HeaderSub.Size = UDim2.new(0, 230, 0, 14)
    HeaderSub.BackgroundTransparency = 1
    HeaderSub.TextXAlignment = Enum.TextXAlignment.Left
    HeaderSub.ZIndex = 1003
    HeaderSub.Parent = ContentHeader

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

        function tabObj:CreateDualButton(titleLeft, titleRight, callbackLeft, callbackRight)
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, 0, 0, 34)
            row.BackgroundTransparency = 1
            row.ZIndex = 1004
            row.Parent = pageScroll

            local btnL = Instance.new("TextButton")
            btnL.Size = UDim2.new(0.68, -4, 1, 0)
            btnL.Position = UDim2.new(0, 0, 0, 0)
            btnL.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            btnL.BorderSizePixel = 0
            btnL.Text = titleLeft
            btnL.Font = Enum.Font.GothamMedium
            btnL.TextSize = 10
            btnL.TextColor3 = Color3.fromRGB(240, 240, 250)
            btnL.ZIndex = 1005
            btnL.Parent = row

            local cL = Instance.new("UICorner")
            cL.CornerRadius = UDim.new(0, 8)
            cL.Parent = btnL

            local sL = Instance.new("UIStroke")
            sL.Color = Color3.fromRGB(45, 45, 60)
            sL.Thickness = 1
            sL.Parent = btnL

            local btnR = Instance.new("TextButton")
            btnR.Size = UDim2.new(0.32, -4, 1, 0)
            btnR.Position = UDim2.new(0.68, 4, 0, 0)
            btnR.BackgroundColor3 = Config.AccentColor
            btnR.BorderSizePixel = 0
            btnR.Text = titleRight
            btnR.Font = Enum.Font.GothamBold
            btnR.TextSize = 10
            btnR.TextColor3 = Color3.fromRGB(255, 255, 255)
            btnR.ZIndex = 1005
            btnR.Parent = row

            local cR = Instance.new("UICorner")
            cR.CornerRadius = UDim.new(0, 8)
            cR.Parent = btnR

            btnL.MouseButton1Click:Connect(function()
                if callbackLeft then callbackLeft() end
            end)

            btnR.MouseButton1Click:Connect(function()
                if callbackRight then callbackRight() end
            end)

            return row
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

        function tabObj:CreateInput(title, placeholder, defaultVal, callback)
            local inputCard = Instance.new("Frame")
            inputCard.Name = "Input_" .. title
            inputCard.Size = UDim2.new(1, 0, 0, 44)
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

            local tLabel = Instance.new("TextLabel")
            tLabel.Text = title
            tLabel.Font = Enum.Font.GothamMedium
            tLabel.TextSize = 11
            tLabel.TextColor3 = Color3.fromRGB(240, 240, 250)
            tLabel.Position = UDim2.new(0, 10, 0, 0)
            tLabel.Size = UDim2.new(0.5, 0, 1, 0)
            tLabel.BackgroundTransparency = 1
            tLabel.TextXAlignment = Enum.TextXAlignment.Left
            tLabel.ZIndex = 1005
            tLabel.Parent = inputCard

            local tbBox = Instance.new("TextBox")
            tbBox.Size = UDim2.new(0.45, 0, 0, 26)
            tbBox.Position = UDim2.new(0.52, 0, 0.5, -13)
            tbBox.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
            tbBox.BorderSizePixel = 0
            tbBox.Text = defaultVal or ""
            tbBox.PlaceholderText = placeholder or ""
            tbBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 115)
            tbBox.Font = Enum.Font.Gotham
            tbBox.TextSize = 11
            tbBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            tbBox.ClearTextOnFocus = false
            tbBox.ZIndex = 1005
            tbBox.Parent = inputCard

            local tbCorner = Instance.new("UICorner")
            tbCorner.CornerRadius = UDim.new(0, 6)
            tbCorner.Parent = tbBox

            tbBox.FocusLost:Connect(function()
                if callback then callback(tbBox.Text) end
            end)

            table.insert(tabObj.Elements, {Type = "Input", Title = title, Card = inputCard})
            return tbBox
        end

        return tabObj
    end

    -- Вкладки хаба
    local TabHospital  = CreateTab("Больница", "🩺", "Авто-цикл: Палаты 1 - 5 (Как на видео)", 1)
    local TabWaypoints = CreateTab("Точки ТП", "📍", "Настройка кастомных точек телепорта", 2)
    local TabRoom7     = CreateTab("Палата 7", "⚡", "Реанимация, ЭКГ сердца и капельница", 3)
    local TabTeleports = CreateTab("Телепорты", "🚀", "Мгновенное перемещение по палатам 1-7", 4)
    local TabAutoFarm  = CreateTab("Авто фарм", "💲", "Автоматизация больницы и заработка", 5)
    local TabPlayer    = CreateTab("Игрок", "👤", "Модификаторы скорости, прыжка и рассудка", 6)
    local TabMisc      = CreateTab("Misc", "📄", "Сервер, FPS Boost и настройки графики", 7)
    local TabSettings  = CreateTab("Settings", "⚙️", "Конфигурация и интерфейс", 8)

    -- 1. БОЛЬНИЦА (ПАЛАТЫ 1 - 5 ПОЛНЫЙ ЦИКЛ)
    TabHospital:CreateSection("Авто-прохождение палат 1 - 5")
    TabHospital:CreateToggle("Авто-цикл больницы (Палаты 1-5)", "Проходит все 5 шагов: ДНК ➔ Сканер ➔ Аптека ➔ Лечение", Config.AutoHospitalCycle, function(val)
        Config.AutoHospitalCycle = val
        SendNotification("Больница", val and "Авто-цикл больницы запущен!" or "Авто-цикл выключен", 3)
    end)
    TabHospital:CreateToggle("Авто-регистрация (Ресепшен)", "Автоматически регистрирует посетителей на входе", Config.AutoRegistration, function(val)
        Config.AutoRegistration = val
    end)
    TabHospital:CreateSlider("Задержка между шагами (сек)", 0.2, 2.0, Config.StepDelay, function(val)
        Config.StepDelay = val
    end)

    TabHospital:CreateSection("Быстрые действия")
    TabHospital:CreateButton("Взять лекарства со шкафа (Заполнить слоты)", true, function()
        task.spawn(function()
            local cabPos = CustomWaypoints.Cabinets
            if cabPos then TeleportTo(cabPos) end
            local count = 0
            for _, obj in pairs(Workspace:GetDescendants()) do
                if IsCabinetPrompt(obj) then
                    local targetCF = GetPromptTargetCFrame(obj)
                    if targetCF then
                        TeleportTo(targetCF)
                        task.wait(0.2)
                        SafeInteractPrompt(obj)
                        count = count + 1
                        task.wait(0.3)
                        if count >= 3 then break end
                    end
                end
            end
            SendNotification("Аптека", "Взято лекарств: " .. tostring(count), 2)
        end)
    end)
    TabHospital:CreateButton("Выпить кофе (Восстановить рассудок)", false, function()
        task.spawn(function()
            local cPos = CustomWaypoints.Coffee
            if cPos then TeleportTo(cPos) end
            for _, obj in pairs(Workspace:GetDescendants()) do
                if IsCoffeePrompt(obj) then
                    local targetCF = GetPromptTargetCFrame(obj)
                    if targetCF then
                        TeleportTo(targetCF)
                        task.wait(0.2)
                        SafeInteractPrompt(obj)
                        SendNotification("Рассудок", "Кофе выпит! Рассудок восстановлен.", 2)
                        return
                    end
                end
            end
            SendNotification("Рассудок", "Кофейный аппарат не найден", 2)
        end)
    end)

    -- 2. ТОЧКИ ТЕЛЕПОРТА (КАСТОМНЫЙ РЕДАКТОР)
    TabWaypoints:CreateSection("Кастомная запись точек телепорта")
    TabWaypoints:CreateButton("💾 Сохранить все точки в файл (Waypoints.json)", true, function()
        pcall(function()
            if writefile and makefolder then
                if not isfolder("AverlikHub") then makefolder("AverlikHub") end
                local exportData = {}
                for k, v in pairs(CustomWaypoints) do
                    if v then exportData[k] = {x = v.X, y = v.Y, z = v.Z} end
                end
                writefile("AverlikHub/Waypoints.json", HttpService:JSONEncode(exportData))
            end
        end)
        SendNotification("Waypoints", "Точки сохранены в памяти и файле!", 3)
    end)

    local function MakeWaypointRow(keyName, displayName)
        TabWaypoints:CreateDualButton("📍 Записать точку: " .. displayName, "🚀 ТП", function()
            local pos = GetMyPosition()
            if pos then
                CustomWaypoints[keyName] = pos
                SendNotification("Точка сохранена", displayName .. ": (" .. math.floor(pos.X) .. ", " .. math.floor(pos.Y) .. ", " .. math.floor(pos.Z) .. ")", 2)
            end
        end, function()
            local pos = CustomWaypoints[keyName] or FindWardBedPosition(tonumber(string.match(keyName, "%d+")) or 1)
            if pos then
                TeleportTo(pos)
                SendNotification("Телепорт", "Перемещен к: " .. displayName, 2)
            else
                SendNotification("Ошибка", "Сначала подойдите и нажмите 'Записать точку'", 2)
            end
        end)
    end

    TabWaypoints:CreateSection("Палаты (Койки пациентов)")
    MakeWaypointRow("Ward1", "Палата 1 (Койка)")
    MakeWaypointRow("Ward2", "Палата 2 (Койка)")
    MakeWaypointRow("Ward3", "Палата 3 (Койка)")
    MakeWaypointRow("Ward4", "Палата 4 (Койка)")
    MakeWaypointRow("Ward5", "Палата 5 (Койка)")
    MakeWaypointRow("Ward6", "Палата 6 (Койка)")
    MakeWaypointRow("Ward7", "Палата 7 (Реанимация)")

    TabWaypoints:CreateSection("Инфраструктура")
    MakeWaypointRow("Cabinets", "Шкаф с лекарствами")
    MakeWaypointRow("LabScanner", "Лаборатория (Сканер)")
    MakeWaypointRow("Reception", "Ресепшен (Вход)")
    MakeWaypointRow("Coffee", "Кофейный автомат")

    -- 3. ПАЛАТА 7 (РЕАНИМАЦИЯ)
    TabRoom7:CreateSection("Реанимация Палаты 7")
    TabRoom7:CreateToggle("Авто-цикл: Палата 7", "Полный цикл реанимации (ЭКГ + Капельница + Аптечка)", Config.Room7_AutoCycle, function(val)
        Config.Room7_AutoCycle = val
        SendNotification("Палата 7", val and "Авто-цикл палаты 7 активен!" or "Авто-цикл остановлен", 2)
    end)
    TabRoom7:CreateToggle("Авто-решение мини-игры ЭКГ", "Автоматически кликает по точкам сердца на мониторе", Config.Room7_AutoHeartGame, function(val)
        Config.Room7_AutoHeartGame = val
    end)
    TabRoom7:CreateToggle("Авто-капельница и лечение", "Берет капельницу/аптечку и ставит больному кролику", Config.Room7_AutoIVDrip, function(val)
        Config.Room7_AutoIVDrip = val
    end)
    TabRoom7:CreateButton("Пройти мини-игру сердца сейчас (Мгновенно)", true, function()
        local solved = SolveHeartMinigame()
        SendNotification("Мини-игра", solved and "Точки сердца успешно нажаты!" or "Экран мини-игры пока не открыт", 2)
    end)

    -- 4. ТЕЛЕПОРТЫ
    TabTeleports:CreateSection("Все палаты больницы (1 - 7)")
    for i = 1, 6 do
        TabTeleports:CreateButton("Палата " .. tostring(i) .. " (Койка пациента)", i <= 3, function()
            local cf = FindWardBedPosition(i)
            if cf then TeleportTo(cf); SendNotification("Телепорт", "Перемещен в Палату " .. tostring(i), 2)
            else SendNotification("Телепорт", "Палата " .. tostring(i) .. " не найдена", 2) end
        end)
    end
    TabTeleports:CreateButton("Палата 7 (Реанимация / ICU)", true, function()
        local cf = FindWardBedPosition(7)
        if cf then TeleportTo(cf); SendNotification("Телепорт", "Перемещен в Палату 7 (Реанимация)", 2)
        else SendNotification("Телепорт", "Палата 7 не найдена", 2) end
    end)

    -- 5. АВТО ФАРМ
    TabAutoFarm:CreateSection("Автоматизация")
    TabAutoFarm:CreateToggle("Автофарм", "Автоматически выполняет заработок валюты", Config.AutoFarm, function(val) Config.AutoFarm = val end)
    TabAutoFarm:CreateToggle("Автосбор наград", "Собирает награды и дропы", Config.AutoCollect, function(val) Config.AutoCollect = val end)

    -- 6. ИГРОК
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
    TabPlayer:CreateToggle("Бесконечный рассудок (Auto Coffee)", "Автоматически пьет кофе при падении рассудка", Config.InfiniteSanity, function(val)
        Config.InfiniteSanity = val
    end)
    TabPlayer:CreateToggle("NoClip", "Прохождение сквозь объекты и стены", Config.NoClip, function(val) Config.NoClip = val end)
    TabPlayer:CreateToggle("Anti AFK", "Предотвращает кик за неактивность", Config.AntiAFK, function(val) Config.AntiAFK = val end)

    -- 7. MISC
    TabMisc:CreateSection("Сервер и Графика")
    TabMisc:CreateButton("Rejoin (Перезайти на сервер)", false, function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
    TabMisc:CreateToggle("FPS Boost", "Отключает тени и тяжелые эффекты", Config.FPSBoost, function(val)
        Config.FPSBoost = val
        if val then
            Lighting.GlobalShadows = false
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled = false end
            end
        end
    end)

    -- 8. SETTINGS
    TabSettings:CreateSection("Конфигурация")
    pcall(function()
        if TabSettings.CreateInput then
            TabSettings:CreateInput("Название конфига", "default", "default", function(val) Config.SelectedConfig = val end)
        end
    end)
    TabSettings:CreateButton("Сохранить конфиг", true, function()
        pcall(function()
            if writefile and makefolder then
                if not isfolder("AverlikHub") then makefolder("AverlikHub") end
                writefile("AverlikHub/" .. (Config.SelectedConfig or "default") .. ".json", HttpService:JSONEncode(Config))
            end
        end)
        SendNotification("Config", "Конфиг сохранен!", 2)
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

    -- Anti-AFK
    pcall(function()
        LocalPlayer.Idled:Connect(function()
            if Config.AntiAFK then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end
        end)
    end)

    -- NoClip
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

    -- FPS & Time counter
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
    -- 🎬 УМНЫЙ ЦИКЛ БОЛЬНИЦЫ (С ИСПОЛЬЗОВАНИЕМ КАСТОМНЫХ ТОЧЕК И ПОИСКА БОЛЬНЫХ)
    -- ══════════════════════════════════════════════════════════════════════════
    local isHospitalRunning = false

    local function ProcessHospitalCycle()
        -- 0. Авто-регистрация
        if Config.AutoRegistration then
            local recPos = CustomWaypoints.Reception
            if recPos then
                TeleportTo(recPos)
                task.wait(0.2)
            end
            for _, rObj in pairs(Workspace:GetDescendants()) do
                if IsReceptionPrompt(rObj) then
                    local rCF = GetPromptTargetCFrame(rObj)
                    if rCF then
                        TeleportTo(rCF)
                        task.wait(0.2)
                        SafeInteractPrompt(rObj)
                        task.wait(Config.StepDelay or 0.5)
                        break
                    end
                end
            end
        end

        -- 1. Сначала проверяем: есть ли активный больной для ДНК или Лечения в ЛЮБОЙ палате
        local activeDnaPrompt = nil
        local activeHealPrompt = nil

        for _, p in pairs(Workspace:GetDescendants()) do
            if IsDNAPrompt(p) then
                activeDnaPrompt = p
                break
            elseif IsHealPrompt(p) then
                activeHealPrompt = p
                break
            end
        end

        -- 2. Если есть пациент для ДНК анализа:
        if activeDnaPrompt then
            local pCF = GetPromptTargetCFrame(activeDnaPrompt)
            if pCF then
                TeleportTo(pCF)
                task.wait(0.3)
                SafeInteractPrompt(activeDnaPrompt)
                task.wait(1.0) -- Взятие ДНК

                -- Перенос в лабораторию
                local labPos = CustomWaypoints.LabScanner
                if labPos then
                    TeleportTo(labPos)
                    task.wait(0.2)
                end

                for _, lObj in pairs(Workspace:GetDescendants()) do
                    if IsLabMachinePrompt(lObj) then
                        local lCF = GetPromptTargetCFrame(lObj)
                        if lCF then
                            TeleportTo(lCF)
                            task.wait(0.2)
                            SafeInteractPrompt(lObj)
                            task.wait(2.2) -- Ожидание расшифровки анализа
                            break
                        end
                    end
                end
            end
        end

        -- 3. Если есть пациент для лечения:
        if activeHealPrompt then
            -- Проверяем инвентарь: есть ли лекарство?
            local bp = LocalPlayer:FindFirstChild("Backpack")
            local char = LocalPlayer.Character
            local hasTool = false
            if char and char:FindFirstChildWhichIsA("Tool") then hasTool = true end
            if bp and #bp:GetChildren() > 0 then hasTool = true end

            -- Если нет лекарства в руках/рюкзаке — берем из шкафа
            if not hasTool then
                local cabPos = CustomWaypoints.Cabinets
                if cabPos then
                    TeleportTo(cabPos)
                    task.wait(0.2)
                end
                for _, cabObj in pairs(Workspace:GetDescendants()) do
                    if IsCabinetPrompt(cabObj) then
                        local cabCF = GetPromptTargetCFrame(cabObj)
                        if cabCF then
                            TeleportTo(cabCF)
                            task.wait(0.2)
                            SafeInteractPrompt(cabObj)
                            task.wait(0.4)
                            break
                        end
                    end
                end
            end

            -- Подходим к больному, берем лекарство и лечим
            local hCF = GetPromptTargetCFrame(activeHealPrompt)
            if hCF then
                TeleportTo(hCF)
                task.wait(0.25)
                EquipMedicalTool()
                task.wait(0.15)
                SafeInteractPrompt(activeHealPrompt)
                task.wait(1.4) -- Лечение
            end
        end

        -- 4. Если нет напрямую найденных промптов — обходим палаты по очереди (по кастомным точкам или авто-поиску)
        if not activeDnaPrompt and not activeHealPrompt then
            for wardNum = 1, 5 do
                if not Config.AutoHospitalCycle then break end
                local wardPos = FindWardBedPosition(wardNum)
                if wardPos then
                    TeleportTo(wardPos)
                    task.wait(0.3)

                    -- Проверяем промпты рядом с койкой (в радиусе 15 studs)
                    for _, p in pairs(Workspace:GetDescendants()) do
                        if IsDNAPrompt(p) or IsHealPrompt(p) then
                            local pCF = GetPromptTargetCFrame(p)
                            if pCF and (pCF.Position - wardPos).Magnitude < 18 then
                                if IsDNAPrompt(p) then
                                    SafeInteractPrompt(p)
                                    task.wait(1.0)
                                    -- Сканер
                                    local labPos = CustomWaypoints.LabScanner
                                    if labPos then TeleportTo(labPos); task.wait(0.2) end
                                    for _, lObj in pairs(Workspace:GetDescendants()) do
                                        if IsLabMachinePrompt(lObj) then
                                            local lCF = GetPromptTargetCFrame(lObj)
                                            if lCF then TeleportTo(lCF); SafeInteractPrompt(lObj); task.wait(2.2); break end
                                        end
                                    end
                                elseif IsHealPrompt(p) then
                                    EquipMedicalTool()
                                    SafeInteractPrompt(p)
                                    task.wait(1.4)
                                end
                                break
                            end
                        end
                    end
                end
                task.wait(Config.StepDelay or 0.5)
            end
        end
    end

    task.spawn(function()
        while true do
            task.wait(0.3)
            if Config.AutoHospitalCycle and not isHospitalRunning then
                isHospitalRunning = true
                pcall(ProcessHospitalCycle)
                isHospitalRunning = false
            end
        end
    end)

    -- Палата 7
    local isHandlingRoom7 = false
    task.spawn(function()
        while true do
            task.wait(0.3)
            if Config.Room7_AutoCycle and not isHandlingRoom7 then
                isHandlingRoom7 = true
                pcall(function()
                    local room7Pos = CustomWaypoints.Ward7 or FindWardBedPosition(7)
                    if room7Pos then
                        TeleportTo(room7Pos)
                        task.wait(0.25)

                        if Config.Room7_AutoHeartGame then
                            for i = 1, 15 do
                                SolveHeartMinigame()
                                task.wait(0.1)
                            end
                        end

                        if Config.Room7_AutoIVDrip then
                            local bp = LocalPlayer:FindFirstChild("Backpack")
                            local char = LocalPlayer.Character
                            local hasDrip = false
                            if char and char:FindFirstChildWhichIsA("Tool") then hasDrip = true end
                            if bp and #bp:GetChildren() > 0 then hasDrip = true end

                            if not hasDrip then
                                local cabPos = CustomWaypoints.Cabinets
                                if cabPos then TeleportTo(cabPos); task.wait(0.2) end
                                for _, medObj in pairs(Workspace:GetDescendants()) do
                                    if IsCabinetPrompt(medObj) then
                                        local act = string.lower(tostring(medObj.ActionText or ""))
                                        if SafeFind(act, "капельниц") or SafeFind(act, "drip") or SafeFind(act, "аптечк") then
                                            local medCF = GetPromptTargetCFrame(medObj)
                                            if medCF then
                                                TeleportTo(medCF)
                                                task.wait(0.2)
                                                SafeInteractPrompt(medObj)
                                                task.wait(0.3)
                                                break
                                            end
                                        end
                                    end
                                end
                            end

                            TeleportTo(room7Pos)
                            task.wait(0.2)
                            EquipMedicalTool("капельниц")
                            for _, pPrompt in pairs(Workspace:GetDescendants()) do
                                if IsHealPrompt(pPrompt) or IsDNAPrompt(pPrompt) then
                                    local pCF = GetPromptTargetCFrame(pPrompt)
                                    if pCF and (room7Pos - pCF.Position).Magnitude < 25 then
                                        SafeInteractPrompt(pPrompt)
                                        task.wait(0.8)
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
            task.wait(3.0)
            if Config.InfiniteSanity then
                pcall(function()
                    local cofPos = CustomWaypoints.Coffee
                    if cofPos then TeleportTo(cofPos); task.wait(0.2) end
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if IsCoffeePrompt(obj) then
                            local targetCF = GetPromptTargetCFrame(obj)
                            if targetCF then
                                TeleportTo(targetCF)
                                task.wait(0.2)
                                SafeInteractPrompt(obj)
                                task.wait(0.4)
                                break
                            end
                        end
                    end
                end)
            end
        end
    end)

    SendNotification("Averlik Hub", "Averlik Hub загружен! Вкладка 'Точки ТП' доступна для настройки.", 4)
    print("[Averlik Hub] Кастомный менеджер точек готов к работе!")
end

local ok, err = pcall(RunAverlikHub)
if not ok then
    warn("[Averlik Hub Error]:", err)
end
