--[[
    ══════════════════════════════════════════════════════════════════════════════════
    👑 AVERLIK HUB - ANIMAL HOSPITAL (PERFECT SMART AUTO-HEAL 1-5 & PRESET WAYPOINTS)
    ══════════════════════════════════════════════════════════════════════════════════
    • Ключевые исправления:
        1. 🚫 НЕ ТЕЛЕПОРТИРУЕТСЯ В ПУСТЫЕ ПАЛАТЫ:
           - Предварительно сканирует Workspace: если в палате нет больного (нет prompt), палата пропускается мгновенно!
        2. ⏳ ИДЕАЛЬНЫЙ ТАЙМИНГ НА СКАНЕРЕ И КОМПЬЮТЕРЕ:
           - Не улетает раньше времени!
           - Держит E для вставки ДНК ➔ ждет завершения центрифуги (3.5с) ➔ нажимает на компьютер для получения рецепта/вещей!
        3. 💊 ТОЧНЫЙ ЗАБОР ЛЕКАРСТВА И ЛЕЧЕНИЕ:
           - ТП к нужной полке ➔ забирает предмет ➔ ТП к койке ➔ берет в руку ➔ лечит больного (Hold E).
        4. 👀 СОХРАНЕНИЕ ТОЧНОГО УГЛА ВЗГЛЯДА ПЕРСОНАЖА.
        5. 🌐 Server Hop (Случайный / Малолюдный / Rejoin).
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

    -- 📍 Таблица кастомных точек телепортации (Все ваши сохраненные координаты и ракурсы)
    local CustomWaypoints = {
        -- Ресепшен (Все шаги)
        Reception = CFrame.new(-108.7247, 3.4125, 10.2041, 1.0000, 0, 0, 0, 1.0000, 0, 0, 0, 1.0000),
        Reception_Form = CFrame.new(-103.9118, 3.4125, -0.4003, 1.0000, 0, 0.0052, 0, 1.0000, 0, -0.0052, 0, 1.0000),
        Reception_Camera = CFrame.new(-108.7958, 3.4125, -0.3836, 0.9994, 0, -0.0349, 0, 1.0000, 0, 0.0349, 0, 0.9994),
        Reception_Printer = CFrame.new(-99.5409, 3.4125, 0.0997, 0.3818, 0, -0.9242, 0, 1.0000, 0, 0.9242, 0, 0.3818),

        -- Палаты 1 - 5, 7 (Койка + Устройство)
        Ward1_Bed = CFrame.new(-168.4174, 5.8061, -41.0413, 1.0000, 0, 0, 0, 1.0000, 0, 0, 0, 1.0000),
        Ward1_Device = CFrame.new(-177.6558, 3.4575, -44.2175, 0.0276, 0, 0.9996, 0, 1.0000, 0, -0.9996, 0, 0.0276),

        Ward2_Bed = CFrame.new(-121.2388, 5.8061, -59.5030, 1.0000, 0, -0.0026, 0, 1.0000, 0, 0.0026, 0, 1.0000),
        Ward2_Device = CFrame.new(-111.4617, 3.4575, -56.7069, -0.0144, 0, -0.9999, 0, 1.0000, 0, 0.9999, 0, -0.0144),

        Ward3_Bed = CFrame.new(-168.0784, 5.8135, -80.1025, 1.0000, 0, 0, 0, 1.0000, 0, 0, 0, 1.0000),
        Ward3_Device = CFrame.new(-177.9783, 3.4575, -83.5864, 0.0101, 0, 0.9999, 0, 1.0000, 0, -0.9999, 0, 0.0101),

        Ward4_Bed = CFrame.new(-121.1582, 5.8061, -99.0621, 1.0000, 0, 0, 0, 1.0000, 0, 0, 0, 1.0000),
        Ward4_Device = CFrame.new(-111.0429, 3.4575, -94.0062, 0.0066, 0, -1.0000, 0, 1.0000, 0, 1.0000, 0, 0.0066),

        Ward5_Bed = CFrame.new(-154.0585, 5.8060, -114.6957, 0.0084, 0, 1.0000, 0, 1.0000, 0, -1.0000, 0, 0.0084),
        Ward5_Device = CFrame.new(-150.8929, 3.4575, -124.0175, 0.9999, 0, -0.0166, 0, 1.0000, 0, 0.0166, 0, 0.9999),

        Ward6_Bed = nil,
        Ward6_Device = nil,

        Ward7_Bed = CFrame.new(-105.4788, 5.8661, 51.9991, 1.0000, 0, 0, 0, 1.0000, 0, 0, 0, 1.0000),
        Ward7_Device = CFrame.new(-106.3802, 3.4575, 58.4393, 1.0000, 0, 0, 0, 1.0000, 0, 0, 0, 1.0000),

        -- 💊 РАЗДЕЛЬНЫЕ МЕДИКАМЕНТЫ В ШКАФАХ (ТОЧНЫЕ ПОЗИЦИИ И ВЗГЛЯД НА ПОЛКУ)
        Med_Herbs = CFrame.new(-137.1196, 3.4575, -57.8230, -0.0229, 0, -0.9997, 0, 1.0000, 0, 0.9997, 0, -0.0229),
        Med_Pills = CFrame.new(-137.0331, 3.4575, -63.5557, -0.0194, 0, -0.9998, 0, 1.0000, 0, 0.9998, 0, -0.0194),
        Med_Drops = CFrame.new(-152.7902, 3.4575, -56.1025, 0.0082, 0, 1.0000, 0, 1.0000, 0, -1.0000, 0, 0.0082),
        Med_IVDrip = CFrame.new(-152.7524, 3.4575, -60.7020, 0.0082, 0, 1.0000, 0, 1.0000, 0, -1.0000, 0, 0.0082),
        Med_FirstAid = CFrame.new(-152.6409, 3.4575, -67.7490, 0.0551, 0, 0.9985, 0, 1.0000, 0, -0.9985, 0, 0.0551),
        Med_Thermometer = CFrame.new(-152.4051, 3.4575, -72.6085, -0.0095, 0, 1.0000, 0, 1.0000, 0, -1.0000, 0, -0.0095),
        Med_Syrup = CFrame.new(-136.6097, 3.4575, -82.4880, -0.0558, 0, -0.9984, 0, 1.0000, 0, 0.9984, 0, -0.0558),
        Med_Mixture = CFrame.new(-136.8368, 3.4575, -78.4278, -0.0541, 0, -0.9985, 0, 1.0000, 0, 0.9985, 0, -0.0541),
        Med_Bandage = CFrame.new(-152.8181, 3.4575, -79.3061, 0.0306, 0, 0.9995, 0, 1.0000, 0, -0.9995, 0, 0.0306),
        Med_Plaster = CFrame.new(-152.5291, 3.4575, -84.2309, -0.0165, 0, 0.9999, 0, 1.0000, 0, -0.9999, 0, -0.0165),

        -- Кофе
        Coffee = CFrame.new(-123.8188, 7.9340, 10.2180, 1.0000, 0, 0, 0, 1.0000, 0, 0, 0, 1.0000)
    }

    -- Загрузка сохраненных точек из файла Waypoints.json
    pcall(function()
        if readfile and isfile and isfile("AverlikHub/Waypoints.json") then
            local data = HttpService:JSONDecode(readfile("AverlikHub/Waypoints.json"))
            if data and type(data) == "table" then
                for k, v in pairs(data) do
                    if v then
                        local cf = nil
                        if v.components and type(v.components) == "table" and #v.components == 12 then
                            cf = CFrame.new(unpack(v.components))
                        elseif v.lookX and v.lookY and v.lookZ and v.x and v.y and v.z then
                            cf = CFrame.lookAt(Vector3.new(v.x, v.y, v.z), Vector3.new(v.x + v.lookX, v.y + v.lookY, v.z + v.lookZ))
                        elseif v.x and v.y and v.z then
                            cf = CFrame.new(v.x, v.y, v.z)
                        end

                        if cf then
                            CustomWaypoints[k] = cf
                            if string.sub(k, 1, 4) == "Ward" and not string.find(k, "_") then
                                CustomWaypoints[k .. "_Bed"] = cf
                            end
                        end
                    end
                end
            end
        end
    end)

    -- Конфигурация хаба
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
                if typeof(cf) == "CFrame" then
                    -- Точно сохраняет угол взгляда и направление персонажа
                    root.CFrame = cf + Vector3.new(0, 0.2, 0)
                elseif typeof(cf) == "Vector3" then
                    root.CFrame = CFrame.new(cf + Vector3.new(0, 2.5, 0))
                end
            end
        end)
    end

    local function GetMyCFrame()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        return root and root.CFrame or nil
    end

    local function GetMyPosition()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        return root and root.Position or nil
    end

    local function SafeInteractPrompt(prompt, extraHold)
        if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return false end
        local holdTime = prompt.HoldDuration or 0
        if extraHold then holdTime = holdTime + extraHold end
        pcall(function()
            if fireproximityprompt then
                fireproximityprompt(prompt, holdTime)
            else
                prompt:InputHoldBegin()
                task.wait(holdTime > 0 and (holdTime + 0.2) or 0.25)
                prompt:InputHoldEnd()
            end
        end)
        return true
    end

    local function DoesToolMatchMedicine(toolName, reqMedKey)
        if not toolName or not reqMedKey then return false end
        local t = string.lower(toolName)
        if reqMedKey == "Med_Herbs" and (SafeFind(t, "трав") or SafeFind(t, "herb") or SafeFind(t, "plant") or SafeFind(t, "растен") or SafeFind(t, "живот") or SafeFind(t, "stomach")) then return true end
        if reqMedKey == "Med_Pills" and (SafeFind(t, "таблет") or SafeFind(t, "pill") or SafeFind(t, "капсул") or SafeFind(t, "голов") or SafeFind(t, "head")) then return true end
        if reqMedKey == "Med_Drops" and (SafeFind(t, "капл") or SafeFind(t, "drop") or SafeFind(t, "глаз") or SafeFind(t, "eye") or SafeFind(t, "сухост") or SafeFind(t, "зрен")) then return true end
        if reqMedKey == "Med_IVDrip" and (SafeFind(t, "капельниц") or SafeFind(t, "iv") or SafeFind(t, "drip") or SafeFind(t, "кров") or SafeFind(t, "blood")) then return true end
        if reqMedKey == "Med_FirstAid" and (SafeFind(t, "аптеч") or SafeFind(t, "aid") or SafeFind(t, "kit") or SafeFind(t, "помощ") or SafeFind(t, "травм")) then return true end
        if reqMedKey == "Med_Thermometer" and (SafeFind(t, "термометр") or SafeFind(t, "шприц") or SafeFind(t, "thermo") or SafeFind(t, "syringe") or SafeFind(t, "градусник") or SafeFind(t, "температур")) then return true end
        if reqMedKey == "Med_Syrup" and (SafeFind(t, "сироп") or SafeFind(t, "syrup") or SafeFind(t, "кашел") or SafeFind(t, "горл")) then return true end
        if reqMedKey == "Med_Mixture" and (SafeFind(t, "микстур") or SafeFind(t, "mixture") or SafeFind(t, "зель") or SafeFind(t, "аллерг") or SafeFind(t, "сып")) then return true end
        if reqMedKey == "Med_Bandage" and (SafeFind(t, "бинт") or SafeFind(t, "band") or SafeFind(t, "повяз") or SafeFind(t, "перевяз") or SafeFind(t, "перелом")) then return true end
        if reqMedKey == "Med_Plaster" and (SafeFind(t, "пластыр") or SafeFind(t, "plaster") or SafeFind(t, "patch") or SafeFind(t, "ссадин") or SafeFind(t, "порез")) then return true end
        return false
    end

    local function EquipRequiredMedicine(reqMedKey)
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if not hum then return false end

        -- 1. Проверяем, держим ли мы уже правильный предмет
        local holdingTool = char:FindFirstChildWhichIsA("Tool")
        if holdingTool then
            if DoesToolMatchMedicine(holdingTool.Name, reqMedKey) then
                return true
            else
                -- Снимаем неправильный предмет, чтобы случайно не убить пациента
                hum:UnequipTools()
                task.wait(0.2)
            end
        end

        -- 2. Ищем строго подходящий предмет в рюкзаке
        if bp then
            for _, tool in ipairs(bp:GetChildren()) do
                if tool:IsA("Tool") and DoesToolMatchMedicine(tool.Name, reqMedKey) then
                    hum:EquipTool(tool)
                    task.wait(0.2)
                    return true
                end
            end
        end

        return false
    end

    local function EquipMedicalTool(preferredName)
        pcall(function()
            local bp = LocalPlayer:FindFirstChild("Backpack")
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if not bp or not hum then return end

            if preferredName then
                for _, tool in ipairs(bp:GetChildren()) do
                    if tool:IsA("Tool") and SafeFind(tool.Name, preferredName) then
                        hum:EquipTool(tool)
                        task.wait(0.15)
                        return
                    end
                end
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

    local function GetWardBedPosition(wardNumber)
        local key = "Ward" .. tostring(wardNumber) .. "_Bed"
        if CustomWaypoints[key] then return CustomWaypoints[key] end
        if CustomWaypoints["Ward" .. tostring(wardNumber)] then return CustomWaypoints["Ward" .. tostring(wardNumber)] end

        local wardModel = FindWardModel(wardNumber)
        if wardModel then
            local bed = wardModel:FindFirstChild("Bed", true) or wardModel:FindFirstChild("HospitalBed", true) or wardModel:FindFirstChild("Mattress", true)
            if bed then
                return bed:IsA("Model") and (bed.PrimaryPart and bed.PrimaryPart.CFrame or bed:GetBoundingBox()) or bed.CFrame
            end
            local anyPart = wardModel:FindFirstChildWhichIsA("BasePart", true)
            if anyPart then return anyPart.CFrame end
        end
        return nil
    end

    local function GetWardDevicePosition(wardNumber)
        local key = "Ward" .. tostring(wardNumber) .. "_Device"
        if CustomWaypoints[key] then return CustomWaypoints[key] end

        local wardModel = FindWardModel(wardNumber)
        if wardModel then
            for _, p in pairs(wardModel:GetDescendants()) do
                local pName = string.lower(p.Name)
                if SafeFind(pName, "scanner") or SafeFind(pName, "centrifuge") or SafeFind(pName, "pc") or SafeFind(pName, "computer") or SafeFind(pName, "desk") or SafeFind(pName, "стол") then
                    if p:IsA("BasePart") then return p.CFrame
                    elseif p:IsA("Model") and p.PrimaryPart then return p.PrimaryPart.CFrame end
                end
            end
        end
        return nil
    end

    local function IsDNAPrompt(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled or IsDoorOrTrash(prompt) then return false end
        local act = string.lower(tostring(prompt.ActionText or ""))
        return SafeFind(act, "анализ") or SafeFind(act, "днк") or SafeFind(act, "dna") or SafeFind(act, "sample") or SafeFind(act, "взят")
    end

    local function IsLabMachinePrompt(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled or IsDoorOrTrash(prompt) then return false end
        local act = string.lower(tostring(prompt.ActionText or ""))
        local objT = string.lower(tostring(prompt.ObjectText or ""))
        local pName = string.lower(tostring(prompt.Parent and prompt.Parent.Name or ""))
        return SafeFind(act, "провест") or SafeFind(act, "сканир") or SafeFind(act, "scan") or SafeFind(act, "встав") or SafeFind(objT, "компьют") or SafeFind(pName, "scan") or SafeFind(pName, "pc") or SafeFind(pName, "lab") or SafeFind(act, "анализ")
    end

    local function IsCabinetPrompt(prompt)
        if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled or IsDoorOrTrash(prompt) then return false end
        local pName = string.lower(tostring(prompt.Parent and prompt.Parent.Name or ""))
        local gName = string.lower(tostring(prompt.Parent and prompt.Parent.Parent and prompt.Parent.Parent.Name or ""))
        if SafeFind(pName, "shelf") or SafeFind(pName, "cabinet") or SafeFind(pName, "шкаф") or SafeFind(pName, "полк") or SafeFind(gName, "shelf") or SafeFind(gName, "cabinet") or SafeFind(gName, "шкаф") then
            return true
        end
        local act = string.lower(tostring(prompt.ActionText or ""))
        local medWords = {"травы", "сироп", "аптечка", "таблетк", "пластыр", "бинт", "капельниц", "шприц", "капли", "микстур", "herbs", "syrup", "kit", "pill", "drop"}
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
        return SafeFind(act, "лечит") or SafeFind(act, "heal") or SafeFind(act, "дать") or SafeFind(act, "give") or SafeFind(act, "укол") or SafeFind(act, "вылеч")
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

    -- Проверка активности палаты (есть ли больной на койке, анализ в сканере или задача на ПК)
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

    -- HUD виджет
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
    local winW = math.clamp(vpSize.X - 40, 360, 720)
    local winH = math.clamp(vpSize.Y - 60, 320, 500)

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
    HeaderSub.Text = "Авто-лечение палат 1-5"
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
            row.Size = UDim2.new(1, 0, 0, 32)
            row.BackgroundTransparency = 1
            row.ZIndex = 1004
            row.Parent = pageScroll

            local btnL = Instance.new("TextButton")
            btnL.Size = UDim2.new(0.72, -4, 1, 0)
            btnL.Position = UDim2.new(0, 0, 0, 0)
            btnL.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
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
            sL.Color = Color3.fromRGB(40, 40, 56)
            sL.Thickness = 1
            sL.Parent = btnL

            local btnR = Instance.new("TextButton")
            btnR.Size = UDim2.new(0.28, -4, 1, 0)
            btnR.Position = UDim2.new(0.72, 4, 0, 0)
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

    -- ══════════════════════════════════════════════════════════════════════════
    -- 🎛️ ВСЕ 10 ВКЛАДОК AVERLIK HUB + CYRAA HUB PRO
    -- ══════════════════════════════════════════════════════════════════════════
    local TabHospital  = CreateTab("Авто-Лечение", "🩺", "Палаты 1 - 5: Авто-цикл с защитой от гибели", 1)
    local TabReception = CreateTab("Ресепшен", "🏢", "Авто-прием посетителей, камера и печать", 2)
    local TabShelves   = CreateTab("Шкафы", "💊", "Красный, Синий, Зеленый, Желтый, Серый шкафы", 3)
    local TabESP       = CreateTab("ESP", "👁️", "Пациенты, Аномалии, Скинволкеры, Игроки", 4)
    local TabServer    = CreateTab("Лобби/Сервер", "🌐", "RE/Quickstart, RE/SkipDialogue, Сервер Хоп", 5)
    local TabRoom7     = CreateTab("Палата 7", "⚡", "Реанимация, ЭКГ сердца и капельница", 6)
    local TabWaypoints = CreateTab("Точки ТП", "📍", "3D Неоновые маркеры и 32 точки координат", 7)
    local TabPlayer    = CreateTab("Игрок", "👤", "Скорость, прыжки, NoClip, Auto Coffee", 8)
    local TabMisc      = CreateTab("Anti-Lag / FPS", "⚡", "Оптимизация графики и FPS Boost", 9)
    local TabSettings  = CreateTab("Настройки", "⚙️", "Темы, цвета и сохранение профилей", 10)

    -- ══════════════════════════════════════════════════════════════════════════
    -- 🔧 ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ (CYRAA & AVERLIK)
    -- ══════════════════════════════════════════════════════════════════════════
    local function SkipDoctorDialogue()
        pcall(function()
            local rs = game:GetService("ReplicatedStorage")
            local rem = rs:FindFirstChild("RE/SetDoctorDialogueSkipped") or rs:FindFirstChild("SetDoctorDialogueSkipped")
            if rem and rem:IsA("RemoteEvent") then
                rem:FireServer(true)
                SendNotification("Диалог", "Диалог доктора успешно пропущен!", 2)
            end
        end)
    end

    local function TriggerQuickstart()
        pcall(function()
            local rs = game:GetService("ReplicatedStorage")
            local rem = rs:FindFirstChild("RE/Quickstart") or rs:FindFirstChild("Quickstart")
            if rem and rem:IsA("RemoteEvent") then
                rem:FireServer()
                SendNotification("Лобби", "Смена запущена через RE/Quickstart!", 2)
            else
                SendNotification("Лобби", "Quickstart RemoteEvent не найден", 2)
            end
        end)
    end

    local function TriggerCameraShutter()
        local recPos = CustomWaypoints.Reception
        local camPos = CustomWaypoints.Reception_Camera or (recPos and recPos * CFrame.new(-3.5, 0, 0))
        if camPos then TeleportTo(camPos); task.wait(0.2) end
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled and not IsDoorOrTrash(obj) then
                local act = string.lower(tostring(obj.ActionText or ""))
                local objT = string.lower(tostring(obj.ObjectText or ""))
                local pName = string.lower(tostring(obj.Parent and obj.Parent.Name or ""))
                if SafeFind(act, "фото") or SafeFind(act, "снять") or SafeFind(act, "photo") or SafeFind(act, "camera") or SafeFind(pName, "cam") or SafeFind(objT, "камер") then
                    SafeInteractPrompt(obj, 0.4)
                    SendNotification("Камера", "Снимок сделан!", 2)
                    return true
                end
            elseif obj:IsA("ClickDetector") and obj.Parent then
                local pName = string.lower(obj.Parent.Name)
                if SafeFind(pName, "cam") or SafeFind(pName, "photo") or SafeFind(pName, "камер") then
                    pcall(function() if fireclickdetector then fireclickdetector(obj) end end)
                    SendNotification("Камера", "Снимок сделан!", 2)
                    return true
                end
            end
        end
        return false
    end

    local function FastTakeMedicine(medKey, displayName)
        task.spawn(function()
            local pos = CustomWaypoints[medKey]
            if pos then
                TeleportTo(pos)
                task.wait(0.3)
                local myP = GetMyPosition()
                for _, cabObj in pairs(Workspace:GetDescendants()) do
                    if IsCabinetPrompt(cabObj) then
                        local cabCF = GetPromptTargetCFrame(cabObj)
                        if cabCF and myP and (cabCF.Position - myP).Magnitude < 7.5 then
                            SafeInteractPrompt(cabObj, 0.4)
                            task.wait(0.4)
                            EquipRequiredMedicine(medKey)
                            SendNotification("Шкаф", "Взято лекарство: " .. tostring(displayName or medKey), 2)
                            return
                        end
                    end
                end
                SendNotification("Шкаф", "Подсказка шкафа не найдена поблизости", 2)
            else
                SendNotification("Шкаф", "Точка полки " .. tostring(medKey) .. " не найдена", 2)
            end
        end)
    end

    -- ESP СИСТЕМА (Пациенты, Аномалии, Игроки)
    local ESP_Storage = { Patients = {}, Anomalies = {}, Players = {} }

    local function ClearESPTable(t)
        for obj, hl in pairs(t) do
            pcall(function() if hl and hl.Parent then hl:Destroy() end end)
        end
        table.clear(t)
    end

    local function UpdatePatientESP(enabled)
        ClearESPTable(ESP_Storage.Patients)
        if not enabled then return end
        for _, m in pairs(Workspace:GetDescendants()) do
            if m:IsA("Model") and m ~= LocalPlayer.Character and not m:IsDescendantOf(LocalPlayer.Character) then
                local hum = m:FindFirstChildOfClass("Humanoid")
                local head = m:FindFirstChild("Head") or m:FindFirstChild("HumanoidRootPart")
                if hum or head then
                    local name = string.lower(m.Name)
                    if not SafeFind(name, "skinwalker") and not SafeFind(name, "monster") and not SafeFind(name, "anomaly") then
                        local isPlayer = false
                        for _, pl in pairs(Players:GetPlayers()) do
                            if pl.Character == m then isPlayer = true; break end
                        end
                        if not isPlayer then
                            local hl = Instance.new("Highlight")
                            hl.Name = "Averlik_PatientHighlight"
                            hl.FillColor = Color3.fromRGB(80, 240, 120)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.45
                            hl.OutlineTransparency = 0.1
                            hl.Adornee = m
                            hl.Parent = m
                            ESP_Storage.Patients[m] = hl
                        end
                    end
                end
            end
        end
    end

    local function UpdateAnomalyESP(enabled)
        ClearESPTable(ESP_Storage.Anomalies)
        if not enabled then return end
        for _, m in pairs(Workspace:GetDescendants()) do
            if m:IsA("Model") and m ~= LocalPlayer.Character then
                local name = string.lower(m.Name)
                if SafeFind(name, "skinwalker") or SafeFind(name, "anomaly") or SafeFind(name, "monster") or SafeFind(name, "ghost") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "Averlik_AnomalyHighlight"
                    hl.FillColor = Color3.fromRGB(255, 40, 40)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 0)
                    hl.FillTransparency = 0.25
                    hl.OutlineTransparency = 0.0
                    hl.Adornee = m
                    hl.Parent = m
                    ESP_Storage.Anomalies[m] = hl
                end
            end
        end
    end

    local function UpdatePlayerESP(enabled)
        ClearESPTable(ESP_Storage.Players)
        if not enabled then return end
        for _, pl in pairs(Players:GetPlayers()) do
            if pl ~= LocalPlayer and pl.Character then
                local hl = Instance.new("Highlight")
                hl.Name = "Averlik_PlayerHighlight"
                hl.FillColor = Color3.fromRGB(70, 160, 255)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.5
                hl.OutlineTransparency = 0.1
                hl.Adornee = pl.Character
                hl.Parent = pl.Character
                ESP_Storage.Players[pl.Character] = hl
            end
        end
    end

    local function HopToLeastPlayersServer()
        SendNotification("Сервер Хоп", "Поиск сервера с наименьшим количеством игроков...", 2)
        task.spawn(function()
            local success, servers = pcall(function()
                local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"
                local response = game:HttpGet(url)
                return HttpService:JSONDecode(response)
            end)
            if success and servers and servers.data then
                local validServers = {}
                for _, s in pairs(servers.data) do
                    if type(s) == "table" and s.id and s.id ~= game.JobId and (s.playing or 0) > 0 and (s.playing or 0) < (s.maxPlayers or 10) then
                        table.insert(validServers, s)
                    end
                end
                if #validServers > 0 then
                    table.sort(validServers, function(a, b) return (a.playing or 0) < (b.playing or 0) end)
                    local target = validServers[1]
                    SendNotification("Сервер Хоп", "Подключение (" .. tostring(target.playing) .. "/" .. tostring(target.maxPlayers) .. " игроков)...", 3)
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, target.id, LocalPlayer)
                    return
                end
            end
            SendNotification("Сервер Хоп", "Сервер не найден, перезаход...", 2)
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end

    local function ApplyAntiLag(enable)
        pcall(function()
            local Lighting = game:GetService("Lighting")
            local Terrain = Workspace:FindFirstChildOfClass("Terrain")
            if enable then
                pcall(function() settings().Rendering.QualityLevel = 1 end)
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 9e9
                Lighting.Brightness = 1
                if Terrain then
                    Terrain.WaterWaveSize = 0
                    Terrain.WaterWaveSpeed = 0
                    Terrain.WaterReflectance = 0
                    Terrain.WaterTransparency = 0
                end
                for _, v in pairs(Lighting:GetChildren()) do
                    if v:IsA("PostEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("Atmosphere") then
                        v.Enabled = false
                    end
                end
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v:IsA("BasePart") and not v:IsA("MeshPart") then
                        v.Material = Enum.Material.SmoothPlastic
                        v.CastShadow = false
                    elseif v:IsA("Decal") or v:IsA("Texture") then
                        v.Transparency = 0.5
                    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") then
                        v.Enabled = false
                    end
                end
                SendNotification("FPS Boost", "Anti-Lag включен! FPS повышен.", 2)
            else
                Lighting.GlobalShadows = true
                SendNotification("FPS Boost", "Стандартная графика возвращена.", 2)
            end
        end)
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- 1. ВКЛАДКА: АВТО-ЛЕЧЕНИЕ (ПАЛАТЫ 1 - 5)
    -- ══════════════════════════════════════════════════════════════════════════
    TabHospital:CreateSection("Авто-Фарм и Лечение палат 1 - 5")
    TabHospital:CreateToggle("Авто-цикл больницы (Auto Treatment)", "Полный цикл: ДНК ➔ Сканер ➔ Шкаф ➔ Лечение с защитой", Config.AutoHospitalCycle, function(val)
        Config.AutoHospitalCycle = val
        SendNotification("Больница", val and "Авто-лечение запущено!" or "Авто-лечение остановлено", 3)
    end)
    TabHospital:CreateToggle("Авто-поддержание рассудка (Keep Sanity 100%)", "Пьет кофе из автомата при падении рассудка", Config.AutoKeepSanity or true, function(val)
        Config.AutoKeepSanity = val
    end)
    TabHospital:CreateToggle("Скип диалогов доктора (RE/SetDoctorDialogueSkipped)", "Автоматически пропускает реплики доктора", Config.SkipDoctorDialogue or true, function(val)
        Config.SkipDoctorDialogue = val
        if val then SkipDoctorDialogue() end
    end)
    TabHospital:CreateSlider("Задержка между шагами (сек)", 0.2, 2.0, Config.StepDelay or 0.5, function(val)
        Config.StepDelay = val
    end)
    TabHospital:CreateSlider("Ожидание сканера/центрифуги (сек)", 3.0, 12.0, Config.ScannerWaitDelay or 6.0, function(val)
        Config.ScannerWaitDelay = val
    end)

    TabHospital:CreateSection("Быстрые действия")
    TabHospital:CreateButton("☕ Выпить кофе сейчас (Рассудок на 100%)", true, function()
        task.spawn(function()
            local cPos = CustomWaypoints.Coffee
            if cPos then TeleportTo(cPos) end
            for _, obj in pairs(Workspace:GetDescendants()) do
                if IsCoffeePrompt(obj) then
                    local targetCF = GetPromptTargetCFrame(obj)
                    if targetCF then
                        TeleportTo(targetCF); task.wait(0.2)
                        SafeInteractPrompt(obj, 0.2)
                        SendNotification("Рассудок", "Кофе выпит! Рассудок восстановлен.", 2)
                        return
                    end
                end
            end
            SendNotification("Рассудок", "Кофейный аппарат не найден", 2)
        end)
    end)
    TabHospital:CreateButton("🧹 Очистить руки от неправильных предметов", false, function()
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:UnequipTools() end
            SendNotification("Инвентарь", "Руки очищены", 2)
        end)
    end)

    -- ══════════════════════════════════════════════════════════════════════════
    -- 2. ВКЛАДКА: РЕСЕПШЕН (RECEPTION & SECRETARY)
    -- ══════════════════════════════════════════════════════════════════════════
    TabReception:CreateSection("Автоматизация Ресепшена")
    TabReception:CreateToggle("Авто-прием посетителей (Auto Visitor only)", "Автоматически регистрирует всех ожидающих клиентов", Config.AutoRegistration, function(val)
        Config.AutoRegistration = val
        SendNotification("Ресепшен", val and "Авто-ресепшен включен!" or "Авто-ресепшен выключен", 2)
    end)
    TabReception:CreateToggle("Авто-спуск затвора камеры (Trigger Shutter)", "Автоматически делает фото при приближении к камере", Config.AutoCamera or true, function(val)
        Config.AutoCamera = val
    end)
    TabReception:CreateButton("📋 Принять клиента сейчас (Бланк ➔ Фото ➔ ПК ➔ Печать)", true, function()
        task.spawn(function()
            SendNotification("Ресепшен", "Регистрация клиента начата...", 2)
            ProcessReceptionIntake()
        end)
    end)
    TabReception:CreateButton("📷 Сделать фото на камеру сейчас", false, function()
        TriggerCameraShutter()
    end)
    TabReception:CreateButton("🚀 Телепорт к стойке ресепшена", false, function()
        local recPos = CustomWaypoints.Reception
        if recPos then TeleportTo(recPos); SendNotification("Телепорт", "Стойка ресепшена", 2) end
    end)

    -- ══════════════════════════════════════════════════════════════════════════
    -- 3. ВКЛАДКА: ШКАФЫ И МЕДИКАМЕНТЫ (SHELVE TELEPORTS)
    -- ══════════════════════════════════════════════════════════════════════════
    TabShelves:CreateSection("🟥 Красный шкаф (Red Shelf)")
    TabShelves:CreateButton("🧰 Взять Аптечку (Medkit / First Aid)", true, function() FastTakeMedicine("Med_FirstAid", "Аптечка") end)
    TabShelves:CreateButton("🌡️ Взять Термометр / Шприц (Thermometer)", false, function() FastTakeMedicine("Med_Thermometer", "Термометр/Шприц") end)

    TabShelves:CreateSection("🟦 Синий шкаф (Blue Shelf)")
    TabShelves:CreateButton("💧 Взять Капли для глаз (Drops)", true, function() FastTakeMedicine("Med_Drops", "Капли") end)
    TabShelves:CreateButton("💉 Взять Капельницу (IV Drip)", false, function() FastTakeMedicine("Med_IVDrip", "Капельница") end)

    TabShelves:CreateSection("🟩 Зеленый шкаф (Green Shelf)")
    TabShelves:CreateButton("🌿 Взять Травы (Herbs)", true, function() FastTakeMedicine("Med_Herbs", "Травы") end)
    TabShelves:CreateButton("💊 Взять Таблетки (Pills)", false, function() FastTakeMedicine("Med_Pills", "Таблетки") end)

    TabShelves:CreateSection("🟨 Желтый шкаф (Yellow Shelf)")
    TabShelves:CreateButton("🍯 Взять Сироп от кашля (Cough Syrup)", true, function() FastTakeMedicine("Med_Syrup", "Сироп от кашля") end)
    TabShelves:CreateButton("🧪 Взять Микстуру (Mixture)", false, function() FastTakeMedicine("Med_Mixture", "Микстура") end)

    TabShelves:CreateSection("⬜ Серый шкаф (White / Grey Shelf)")
    TabShelves:CreateButton("🩹 Взять Бинты (Bandage)", true, function() FastTakeMedicine("Med_Bandage", "Бинты") end)
    TabShelves:CreateButton("🩹 Взять Пластыри (Plaster)", false, function() FastTakeMedicine("Med_Plaster", "Пластыри") end)

    -- ══════════════════════════════════════════════════════════════════════════
    -- 4. ВКЛАДКА: ESP И ВИЗУАЛИЗАТОРЫ
    -- ══════════════════════════════════════════════════════════════════════════
    TabESP:CreateSection("Подсветка объектов (ESP)")
    TabESP:CreateToggle("ESP Пациентов (Patient ESP / Highlight)", "Зеленая подсветка всех больных животных в палатах", Config.PatientESP or false, function(val)
        Config.PatientESP = val
        UpdatePatientESP(val)
    end)
    TabESP:CreateToggle("ESP Аномалий и Монстров (Anomaly ESP)", "Яркая красная подсветка скинволкеров и аномалий", Config.AnomalyESP or false, function(val)
        Config.AnomalyESP = val
        UpdateAnomalyESP(val)
    end)
    TabESP:CreateToggle("ESP Игроков (Player ESP)", "Синяя подсветка других врачей и игроков на сервере", Config.PlayerESP or false, function(val)
        Config.PlayerESP = val
        UpdatePlayerESP(val)
    end)
    TabESP:CreateToggle("3D Маркеры точек в мире (Waypoint ESP)", "Неоновые круги и стрелки взгляда сохраненных точек", ShowWaypointESP, function(val)
        ShowWaypointESP = val
        UpdateWaypointVisuals()
    end)
    TabESP:CreateButton("🔄 Обновить и перезапустить все ESP", false, function()
        UpdatePatientESP(Config.PatientESP)
        UpdateAnomalyESP(Config.AnomalyESP)
        UpdatePlayerESP(Config.PlayerESP)
        UpdateWaypointVisuals()
        SendNotification("ESP", "ESP подсветка обновлена!", 2)
    end)

    -- ══════════════════════════════════════════════════════════════════════════
    -- 5. ВКЛАДКА: ЛОББИ И СЕРВЕР (LOBBY & SERVER)
    -- ══════════════════════════════════════════════════════════════════════════
    TabServer:CreateSection("Сетевые функции")
    TabServer:CreateButton("⚡ Быстрый старт смены (RE/Quickstart)", true, function()
        TriggerQuickstart()
    end)
    TabServer:CreateButton("⏩ Скипнуть диалоги доктора (RE/SetDoctorDialogueSkipped)", false, function()
        SkipDoctorDialogue()
    end)
    TabServer:CreateButton("🌐 Hop to Least Players (На самый пустой сервер)", true, function()
        HopToLeastPlayersServer()
    end)
    TabServer:CreateButton("🎲 Случайный Сервер Хоп", false, function()
        ServerHop(false)
    end)
    TabServer:CreateButton("🔄 Rejoin (Перезайти на этот же сервер)", false, function()
        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
    end)

    -- ══════════════════════════════════════════════════════════════════════════
    -- 6. ВКЛАДКА: ПАЛАТА 7 (РЕАНИМАЦИЯ / ICU)
    -- ══════════════════════════════════════════════════════════════════════════
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

    -- ══════════════════════════════════════════════════════════════════════════
    -- 7. ВКЛАДКА: ТОЧКИ ТЕЛЕПОРТА (WAYPOINTS)
    -- ══════════════════════════════════════════════════════════════════════════
    TabWaypoints:CreateSection("3D Визуализация и Сохранение")
    TabWaypoints:CreateToggle("3D Маркеры всех точек в мире (ESP)", "Показывает неоновые круги, названия и стрелки взгляда прямо в игре", ShowWaypointESP, function(val)
        ShowWaypointESP = val
        UpdateWaypointVisuals()
    end)
    TabWaypoints:CreateButton("💾 Сохранить все 32 точки в файл (Waypoints.json)", true, function()
        SaveWaypointsToFile()
        SendNotification("Waypoints", "Все 32 точки и углы взгляда сохранены!", 3)
    end)
    TabWaypoints:CreateButton("📋 Скопировать координаты в буфер (JSON)", false, function()
        pcall(function()
            local exportData = {}
            for k, v in pairs(CustomWaypoints) do
                if typeof(v) == "CFrame" then
                    local look = v.LookVector
                    exportData[k] = {x = v.X, y = v.Y, z = v.Z, lookX = look.X, lookY = look.Y, lookZ = look.Z, components = {v:GetComponents()}}
                end
            end
            local jsonStr = HttpService:JSONEncode(exportData)
            if setclipboard then
                setclipboard(jsonStr)
                SendNotification("Буфер обмена", "JSON с координатами скопирован в буфер!", 2)
            end
        end)
    end)

    TabWaypoints:CreateSection("➕ Создать свою новую точку")
    local customPointName = "Custom_Point_1"
    TabWaypoints:CreateInput("Имя новой точки", "Например: Моя_Точка", "Custom_Point_1", function(val)
        customPointName = val
    end)
    TabWaypoints:CreateButton("➕ Записать текущую позицию как новую точку", true, function()
        local cf = GetMyCFrame()
        if cf and customPointName and customPointName ~= "" then
            CustomWaypoints[customPointName] = cf
            SaveWaypointsToFile()
            UpdateWaypointVisuals()
            SendNotification("Waypoints", "Создана и сохранена точка: " .. customPointName, 3)
        end
    end)

    TabWaypoints:CreateSection("✅ Зафиксированные точки")
    TabWaypoints:CreateButton("📊 Все 32 основные точки зафиксированы и активны", false, function()
        SendNotification("Статус", "Палаты 1-5, Палата 7, Ресепшен и 10 полок лекарств готовы к работе!", 3)
    end)

    -- ══════════════════════════════════════════════════════════════════════════
    -- 8. ВКЛАДКА: ИГРОК (PLAYER)
    -- ══════════════════════════════════════════════════════════════════════════
    TabPlayer:CreateSection("Параметры персонажа")
    TabPlayer:CreateToggle("Изменение скорости", "Включает кастомную скорость передвижения", Config.WalkSpeedEnabled, function(val)
        Config.WalkSpeedEnabled = val
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = val and Config.WalkSpeed or 16 end
    end)
    TabPlayer:CreateSlider("Скорость (WalkSpeed)", 16, 250, Config.WalkSpeed or 16, function(val)
        Config.WalkSpeed = val
        if Config.WalkSpeedEnabled then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = val end
        end
    end)
    TabPlayer:CreateToggle("NoClip", "Прохождение сквозь объекты и стены", Config.NoClip, function(val) Config.NoClip = val end)
    TabPlayer:CreateToggle("Anti AFK", "Предотвращает кик за неактивность", Config.AntiAFK, function(val) Config.AntiAFK = val end)

    -- ══════════════════════════════════════════════════════════════════════════
    -- 9. ВКЛАДКА: ОПТИМИЗАЦИЯ И FPS BOOST (ANTI-LAG)
    -- ══════════════════════════════════════════════════════════════════════════
    TabMisc:CreateSection("Anti-Lag & Оптимизация графики")
    TabMisc:CreateToggle("Anti-Lag / FPS Boost", "Отключает тени, частицы, волны воды и тяжелые эффекты", Config.FPSBoost or false, function(val)
        Config.FPSBoost = val
        ApplyAntiLag(val)
    end)
    TabMisc:CreateButton("🧹 Применить максимальное ускорение FPS", true, function()
        ApplyAntiLag(true)
    end)

    -- ══════════════════════════════════════════════════════════════════════════
    -- 10. ВКЛАДКА: НАСТРОЙКИ (SETTINGS)
    -- ══════════════════════════════════════════════════════════════════════════
    TabSettings:CreateSection("Конфигурация")
    pcall(function()
        if TabSettings.CreateInput then
            TabSettings:CreateInput("Название конфига", "default", "default", function(val) Config.SelectedConfig = val end)
        end
    end)
    TabSettings:CreateButton("💾 Сохранить конфиг", true, function()
        pcall(function()
            if writefile and makefolder then
                if not isfolder("AverlikHub") then makefolder("AverlikHub") end
                writefile("AverlikHub/" .. (Config.SelectedConfig or "default") .. ".json", HttpService:JSONEncode(Config))
            end
        end)
        SendNotification("Config", "Конфиг сохранен!", 2)
    end)

    -- ══════════════════════════════════════════════════════════════════════════
    -- 🎬 УМНЫЙ ЦИКЛ БОЛЬНИЦЫ (КОЙКА ➔ СКАНЕР ➔ ПОЛКА НУЖНОГО ЛЕКАРСТВА ➔ КОЙКА)
    -- ══════════════════════════════════════════════════════════════════════════
    local isHospitalRunning = false

    local function MatchMedicineKey(text, img)
        local t = string.lower(tostring(text or ""))
        local i = string.lower(tostring(img or ""))

        -- 1. 🌿 Травы (Живот / Тошнота / Отравление / Желудок)
        if SafeFind(t, "живот") or SafeFind(t, "болит живот") or SafeFind(t, "тошнот") or SafeFind(t, "рвот") or SafeFind(t, "отравлен") or SafeFind(t, "желудок") or SafeFind(t, "пищевар") or SafeFind(t, "несварен") or SafeFind(t, "колик") or SafeFind(t, "аппетит") or SafeFind(t, "stomach") or SafeFind(t, "belly") or SafeFind(t, "tummy") or SafeFind(t, "nausea") or SafeFind(t, "vomit") or SafeFind(t, "poison") or SafeFind(t, "digest") or SafeFind(t, "cramp") or SafeFind(t, "gut") or SafeFind(t, "трав") or SafeFind(t, "растен") or SafeFind(t, "herb") or SafeFind(t, "plant") or SafeFind(t, "leaf") or SafeFind(i, "herb") or SafeFind(i, "plant") or SafeFind(i, "leaf") then
            return "Med_Herbs"
        end

        -- 2. 💊 Таблетки (Голова / Мигрень / Давление / Стресс)
        if SafeFind(t, "голов") or SafeFind(t, "болит голова") or SafeFind(t, "мигрен") or SafeFind(t, "давлен") or SafeFind(t, "головокружен") or SafeFind(t, "бессонниц") or SafeFind(t, "стресс") or SafeFind(t, "headache") or SafeFind(t, "head") or SafeFind(t, "migraine") or SafeFind(t, "dizzy") or SafeFind(t, "dizziness") or SafeFind(t, "pressure") or SafeFind(t, "таблет") or SafeFind(t, "пилюл") or SafeFind(t, "капсул") or SafeFind(t, "pill") or SafeFind(i, "pill") then
            return "Med_Pills"
        end

        -- 3. 💧 Капли (Глаза / Сухость глаз / Зрение / Нос / Уши / Слезы)
        if SafeFind(t, "глаз") or SafeFind(t, "сухост") or SafeFind(t, "сухие") or SafeFind(t, "зрени") or SafeFind(t, "слез") or SafeFind(t, "слезотечен") or SafeFind(t, "век") or SafeFind(t, "конъюнктивит") or SafeFind(t, "насморк") or SafeFind(t, "сопл") or SafeFind(t, "уши") or SafeFind(t, "ухо") or SafeFind(t, "отит") or SafeFind(t, "заложенност") or SafeFind(t, "eye") or SafeFind(t, "eyes") or SafeFind(t, "dry") or SafeFind(t, "dry eyes") or SafeFind(t, "vision") or SafeFind(t, "tear") or SafeFind(t, "tears") or SafeFind(t, "nose") or SafeFind(t, "ear") or SafeFind(t, "ears") or SafeFind(t, "капл") or SafeFind(t, "drop") or SafeFind(i, "drop") then
            return "Med_Drops"
        end

        -- 4. 💉 Капельницы (Обезвоживание / Истощение / Слабость / Кровь)
        if SafeFind(t, "обезвоживан") or SafeFind(t, "истощен") or SafeFind(t, "слабост") or SafeFind(t, "упадок сил") or SafeFind(t, "потеря сознания") or SafeFind(t, "анеми") or SafeFind(t, "интоксикац") or SafeFind(t, "dehydration") or SafeFind(t, "exhaust") or SafeFind(t, "weak") or SafeFind(t, "weakness") or SafeFind(t, "faint") or SafeFind(t, "blood") or SafeFind(t, "капельниц") or SafeFind(t, "iv") or SafeFind(t, "drip") or SafeFind(i, "drip") or SafeFind(i, "iv") then
            return "Med_IVDrip"
        end

        -- 5. 🧰 Аптечки (Тяжелая травма / Кровотечение / Открытая рана / Укус)
        if SafeFind(t, "тяжелая травма") or SafeFind(t, "травм") or SafeFind(t, "ран") or SafeFind(t, "кровотечен") or SafeFind(t, "глубокий порез") or SafeFind(t, "укус") or SafeFind(t, "injury") or SafeFind(t, "wound") or SafeFind(t, "bleed") or SafeFind(t, "bleeding") or SafeFind(t, "bite") or SafeFind(t, "trauma") or SafeFind(t, "аптеч") or SafeFind(t, "первая помощ") or SafeFind(t, "first aid") or SafeFind(t, "kit") or SafeFind(i, "kit") or SafeFind(i, "aid") then
            return "Med_FirstAid"
        end

        -- 6. 🌡️ Термометры / Шприцы (Температура / Жар / Лихорадка / Вирус / Грипп)
        if SafeFind(t, "температур") or SafeFind(t, "жар") or SafeFind(t, "лихорадк") or SafeFind(t, "озноб") or SafeFind(t, "инфекци") or SafeFind(t, "вирус") or SafeFind(t, "грипп") or SafeFind(t, "воспален") or SafeFind(t, "temperature") or SafeFind(t, "fever") or SafeFind(t, "hot") or SafeFind(t, "virus") or SafeFind(t, "infection") or SafeFind(t, "flu") or SafeFind(t, "chill") or SafeFind(t, "термометр") or SafeFind(t, "шприц") or SafeFind(t, "укол") or SafeFind(t, "градусник") or SafeFind(t, "вакцин") or SafeFind(t, "thermometer") or SafeFind(t, "syringe") or SafeFind(t, "inject") or SafeFind(i, "thermo") or SafeFind(i, "syringe") then
            return "Med_Thermometer"
        end

        -- 7. 🍯 Сиропы (Кашель / Горло / Простуда / Ангина)
        if SafeFind(t, "кашел") or SafeFind(t, "кашля") or SafeFind(t, "горл") or SafeFind(t, "болит горло") or SafeFind(t, "простуд") or SafeFind(t, "хрип") or SafeFind(t, "ангин") or SafeFind(t, "першен") or SafeFind(t, "голос") or SafeFind(t, "бронхит") or SafeFind(t, "cough") or SafeFind(t, "throat") or SafeFind(t, "sore throat") or SafeFind(t, "bronchitis") or SafeFind(t, "cold") or SafeFind(t, "сироп") or SafeFind(t, "syrup") or SafeFind(i, "syrup") then
            return "Med_Syrup"
        end

        -- 8. 🧪 Микстуры (Аллергия / Зуд / Сыпь / Покраснение / Кожа)
        if SafeFind(t, "аллерги") or SafeFind(t, "зуд") or SafeFind(t, "сып") or SafeFind(t, "покраснени") or SafeFind(t, "чешет") or SafeFind(t, "раздражен") or SafeFind(t, "кож") or SafeFind(t, "отек") or SafeFind(t, "крапивниц") or SafeFind(t, "allergy") or SafeFind(t, "itch") or SafeFind(t, "itchy") or SafeFind(t, "rash") or SafeFind(t, "redness") or SafeFind(t, "skin") or SafeFind(t, "irritation") or SafeFind(t, "микстур") or SafeFind(t, "зель") or SafeFind(t, "mixture") or SafeFind(t, "potion") or SafeFind(i, "mixture") then
            return "Med_Mixture"
        end

        -- 9. 🩹 Бинты (Перелом / Вывих / Сломана лапа / Кость / Растяжение)
        if SafeFind(t, "перелом") or SafeFind(t, "вывих") or SafeFind(t, "сломан") or SafeFind(t, "кость") or SafeFind(t, "трещин") or SafeFind(t, "растяжен") or SafeFind(t, "лап") or SafeFind(t, "нога") or SafeFind(t, "broken") or SafeFind(t, "fracture") or SafeFind(t, "bone") or SafeFind(t, "sprain") or SafeFind(t, "dislocate") or SafeFind(t, "leg") or SafeFind(t, "arm") or SafeFind(t, "paw") or SafeFind(t, "бинт") or SafeFind(t, "повязк") or SafeFind(t, "перевязк") or SafeFind(t, "bandage") or SafeFind(t, "band") or SafeFind(i, "band") then
            return "Med_Bandage"
        end

        -- 10. 🩹 Пластыри (Царапина / Ссадина / Мелкий порез / Мозоль / Синяк)
        if SafeFind(t, "царапин") or SafeFind(t, "ссадин") or SafeFind(t, "мелкий порез") or SafeFind(t, "мозол") or SafeFind(t, "синяк") or SafeFind(t, "потертост") or SafeFind(t, "scratch") or SafeFind(t, "scrape") or SafeFind(t, "bruise") or SafeFind(t, "small cut") or SafeFind(t, "blister") or SafeFind(t, "пластыр") or SafeFind(t, "лейкопластыр") or SafeFind(t, "plaster") or SafeFind(t, "patch") or SafeFind(i, "plaster") or SafeFind(i, "patch") then
            return "Med_Plaster"
        end

        return nil
    end

    local function StripTags(str)
        if not str or type(str) ~= "string" then return "" end
        return string.gsub(str, "<[^>]+>", "")
    end

    -- 🩺 НАИБОЛЕЕ НАДЕЖНЫЙ МНОГОСЛОЙНЫЙ ДВИЖОК ОПРЕДЕЛЕНИЯ ДИАГНОЗА
    local function GetDiagnosedMedicine(wardNum, maxWaitSeconds)
        maxWaitSeconds = maxWaitSeconds or 3.5
        local startTime = tick()

        local devPos = wardNum and GetWardDevicePosition(wardNum) or nil
        local devVec = devPos and (typeof(devPos) == "CFrame" and devPos.Position or devPos) or nil
        local bedPos = wardNum and GetWardBedPosition(wardNum) or nil
        local bedVec = bedPos and (typeof(bedPos) == "CFrame" and bedPos.Position or bedPos) or nil

        while (tick() - startTime) <= maxWaitSeconds do
            -- 1. СЛОЙ 1: SurfaceGui и BillboardGui на мониторе ПК, центрифуге и доске палаты
            for _, gui in pairs(Workspace:GetDescendants()) do
                if gui:IsA("SurfaceGui") or gui:IsA("BillboardGui") then
                    local isNear = true
                    if devVec or bedVec then
                        local adPart = gui.Adornee or gui.Parent
                        if adPart and adPart:IsA("BasePart") then
                            local d1 = devVec and (adPart.Position - devVec).Magnitude or 999
                            local d2 = bedVec and (adPart.Position - bedVec).Magnitude or 999
                            if d1 > 35 and d2 > 35 then isNear = false end
                        end
                    end

                    if isNear then
                        for _, elem in pairs(gui:GetDescendants()) do
                            if (elem:IsA("TextLabel") or elem:IsA("TextButton") or elem:IsA("TextBox")) and elem.Visible then
                                local cleanText = StripTags(elem.Text)
                                local matched = MatchMedicineKey(cleanText, nil)
                                if matched then return matched end
                            elseif elem:IsA("ImageLabel") or elem:IsA("ImageButton") then
                                local matched = MatchMedicineKey(elem.Name, elem.Image)
                                if matched then return matched end
                            end
                        end
                    end
                end
            end

            -- 2. СЛОЙ 2: Атрибуты (Attributes) и Value-объекты моделей палаты и пациента
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") or obj:IsA("Configuration") or obj:IsA("Folder") then
                    local isNear = true
                    local primary = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj.Parent
                    if primary and primary:IsA("BasePart") and (devVec or bedVec) then
                        local d1 = devVec and (primary.Position - devVec).Magnitude or 999
                        local d2 = bedVec and (primary.Position - bedVec).Magnitude or 999
                        if d1 > 35 and d2 > 35 then isNear = false end
                    end

                    if isNear then
                        local attrs = obj:GetAttributes()
                        for attrName, attrVal in pairs(attrs) do
                            local matched = MatchMedicineKey(tostring(attrVal), nil)
                            if matched then return matched end
                        end
                        for _, valObj in pairs(obj:GetChildren()) do
                            if valObj:IsA("StringValue") then
                                local matched = MatchMedicineKey(valObj.Value, nil)
                                if matched then return matched end
                            end
                        end
                    end
                end
            end

            -- 3. СЛОЙ 3: Всплывающий интерфейс рецепта / карточки (PlayerGui)
            local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if pg then
                for _, g in pairs(pg:GetChildren()) do
                    if g:IsA("ScreenGui") and g.Enabled and g.Name ~= "AverlikHub_MainGui" then
                        for _, elem in pairs(g:GetDescendants()) do
                            if (elem:IsA("TextLabel") or elem:IsA("TextButton") or elem:IsA("TextBox")) and elem.Visible then
                                local cleanText = StripTags(elem.Text)
                                local matched = MatchMedicineKey(cleanText, nil)
                                if matched then return matched end
                            elseif elem:IsA("ImageLabel") or elem:IsA("ImageButton") then
                                local matched = MatchMedicineKey(elem.Name, elem.Image)
                                if matched then return matched end
                            end
                        end
                    end
                end
            end

            -- 4. СЛОЙ 4: Глобальный поиск по всем видимым надписям больницы
            for _, gui in pairs(Workspace:GetDescendants()) do
                if (gui:IsA("SurfaceGui") or gui:IsA("BillboardGui")) and gui.Enabled then
                    for _, elem in pairs(gui:GetDescendants()) do
                        if (elem:IsA("TextLabel") or elem:IsA("TextButton")) and elem.Visible then
                            local cleanText = StripTags(elem.Text)
                            local matched = MatchMedicineKey(cleanText, nil)
                            if matched then return matched end
                        end
                    end
                end
            end

            task.wait(0.25)
        end

        return nil
    end

    -- Проверка активности палаты (есть ли живой больной на койке или активная подсказка)
    local function IsWardActive(wardNum)
        local bedPos = GetWardBedPosition(wardNum)
        if not bedPos then return false end
        local bedVec = typeof(bedPos) == "CFrame" and bedPos.Position or bedPos

        -- 1. Проверка активных ProximityPrompt возле койки (взятие ДНК или лечение)
        for _, p in pairs(Workspace:GetDescendants()) do
            if p:IsA("ProximityPrompt") and p.Enabled and not IsDoorOrTrash(p) then
                local pCF = GetPromptTargetCFrame(p)
                if pCF and (pCF.Position - bedVec).Magnitude < 14 then
                    if IsDNAPrompt(p) or IsHealPrompt(p) then
                        return true
                    end
                end
            end
        end

        -- 2. Проверка пациента (модели живого зверька с Humanoid или Head на койке)
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= LocalPlayer.Character and not obj:IsDescendantOf(LocalPlayer.Character) then
                local oName = string.lower(obj.Name)
                if not SafeFind(oName, "bed") and not SafeFind(oName, "room") and not SafeFind(oName, "палат") and not SafeFind(oName, "мебел") and not SafeFind(oName, "door") and not SafeFind(oName, "wall") and not SafeFind(oName, "floor") then
                    local hum = obj:FindFirstChildOfClass("Humanoid")
                    local head = obj:FindFirstChild("Head") or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("UpperTorso")
                    if hum or head or SafeFind(oName, "patient") or SafeFind(oName, "больной") or SafeFind(oName, "пациент") or SafeFind(oName, "animal") or SafeFind(oName, "bunny") or SafeFind(oName, "cat") or SafeFind(oName, "dog") then
                        local pos = head and head.Position or (obj.PrimaryPart and obj.PrimaryPart.Position)
                        if pos and (pos - bedVec).Magnitude < 8.5 then
                            return true
                        end
                    end
                end
            end
        end

        return false
    end

    local function PerformDeskAnalysis(devPos)
        if not devPos then return end
        local devVec = typeof(devPos) == "CFrame" and devPos.Position or devPos

        -- ШАГ 2.1: Встаем перед сканером (левый аппарат)
        TeleportTo(devPos)
        task.wait(0.35)

        -- 1-е НАЖАТИЕ: Вставить пробирку в сканер / Запустить анализ
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled and not IsDoorOrTrash(obj) then
                local pCF = GetPromptTargetCFrame(obj)
                if pCF and (pCF.Position - devVec).Magnitude < 16 then
                    SafeInteractPrompt(obj, 0.4)
                    task.wait(0.3)
                    break
                end
            elseif obj:IsA("ClickDetector") and obj.Parent then
                local p = obj.Parent
                if p:IsA("BasePart") and (p.Position - devVec).Magnitude < 16 then
                    pcall(function() if fireclickdetector then fireclickdetector(obj) end end)
                    task.wait(0.3)
                    break
                end
            end
        end

        -- Ожидание работы центрифуги (до появления «Завершено» или по таймеру)
        local maxWait = Config.ScannerWaitDelay or 6.5
        local startTime = tick()
        while (tick() - startTime) < maxWait do
            task.wait(0.3)
            local isFinished = false
            for _, sg in pairs(Workspace:GetDescendants()) do
                if (sg:IsA("SurfaceGui") or sg:IsA("BillboardGui")) and sg.Adornee then
                    local adPart = sg.Adornee:IsA("BasePart") and sg.Adornee or nil
                    if adPart and (adPart.Position - devVec).Magnitude < 16 then
                        for _, txt in pairs(sg:GetDescendants()) do
                            if (txt:IsA("TextLabel") or txt:IsA("TextButton")) and SafeFind(txt.Text, "завершен") then
                                isFinished = true
                                break
                            end
                        end
                    end
                end
                if isFinished then break end
            end
            if isFinished and (tick() - startTime >= 4.0) then
                break
            end
        end
        task.wait(0.8) -- Дополнительный буфер для обновления ПК

        -- ШАГ 2.2: Встаем прямо перед компьютером (сдвиг вправо к монитору и клавиатуре)
        local pcPos = typeof(devPos) == "CFrame" and (devPos * CFrame.new(2.8, 0, 0)) or (devVec + Vector3.new(2.8, 0, 0))
        TeleportTo(pcPos)
        task.wait(0.3)

        local pcVec = typeof(pcPos) == "CFrame" and pcPos.Position or pcPos

        -- 2-е НАЖАТИЕ: Нажать на компьютер («Необходимые действия !»)
        for repeatClick = 1, 3 do
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled and not IsDoorOrTrash(obj) then
                    local pCF = GetPromptTargetCFrame(obj)
                    if pCF and (pCF.Position - pcVec).Magnitude < 16 then
                        SafeInteractPrompt(obj, 0.4)
                        task.wait(0.2)
                    end
                elseif obj:IsA("ClickDetector") and obj.Parent then
                    local p = obj.Parent
                    if p:IsA("BasePart") and (p.Position - pcVec).Magnitude < 16 then
                        pcall(function() if fireclickdetector then fireclickdetector(obj) end end)
                        task.wait(0.2)
                    end
                end
            end

            -- Нажатие на экран компьютера (SurfaceGui / BillboardGui)
            for _, sg in pairs(Workspace:GetDescendants()) do
                if (sg:IsA("SurfaceGui") or sg:IsA("BillboardGui")) and sg.Adornee then
                    local adPart = sg.Adornee:IsA("BasePart") and sg.Adornee or nil
                    if adPart and (adPart.Position - pcVec).Magnitude < 16 then
                        for _, btn in pairs(sg:GetDescendants()) do
                            if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Visible then
                                pcall(function()
                                    if firesignal then
                                        firesignal(btn.MouseButton1Click)
                                        firesignal(btn.Activated)
                                    end
                                end)
                            end
                        end
                    end
                end
            end
            task.wait(0.3)
        end
    end

    local lastReceptionTime = 0

    local function HasWaitingReceptionCustomers()
        local recPos = CustomWaypoints.Reception
        if not recPos then return false end
        local recVec = typeof(recPos) == "CFrame" and recPos.Position or recPos

        -- 1. Проверка табло над ресепшеном
        for _, gui in pairs(Workspace:GetDescendants()) do
            if (gui:IsA("SurfaceGui") or gui:IsA("BillboardGui")) and gui.Enabled then
                local adPart = gui.Adornee or gui.Parent
                if adPart and adPart:IsA("BasePart") and (adPart.Position - recVec).Magnitude < 30 then
                    for _, lbl in pairs(gui:GetDescendants()) do
                        if (lbl:IsA("TextLabel") or lbl:IsA("TextBox")) and lbl.Visible then
                            local t = string.lower(lbl.Text)
                            if SafeFind(t, "регистрац") or SafeFind(t, "требуют") then
                                local num = tonumber(string.match(t, "%d+"))
                                if num and num > 0 then return true end
                            end
                        end
                    end
                end
            end
        end

        -- 2. Проверка активного бланка на стойке
        local formPos = CustomWaypoints.Reception_Form or recPos
        local formVec = typeof(formPos) == "CFrame" and formPos.Position or formPos
        for _, p in pairs(Workspace:GetDescendants()) do
            if p:IsA("ProximityPrompt") and p.Enabled and not IsDoorOrTrash(p) then
                local pCF = GetPromptTargetCFrame(p)
                if pCF and (pCF.Position - formVec).Magnitude < 12 then
                    local act = string.lower(tostring(p.ActionText or ""))
                    if SafeFind(act, "заполн") or SafeFind(act, "форм") or SafeFind(act, "бланк") then
                        return true
                    end
                end
            end
        end

        -- 3. Проверка зверька у стойки
        for _, m in pairs(Workspace:GetDescendants()) do
            if m:IsA("Model") and m ~= LocalPlayer.Character and not m:IsDescendantOf(LocalPlayer.Character) then
                local hum = m:FindFirstChildOfClass("Humanoid")
                local head = m:FindFirstChild("Head") or m:FindFirstChild("HumanoidRootPart")
                if (hum or head) then
                    local pPos = head and head.Position or (m.PrimaryPart and m.PrimaryPart.Position)
                    if pPos and (pPos - recVec).Magnitude < 10 then
                        return true
                    end
                end
            end
        end

        return false
    end

    -- 📋 ПОЛНЫЙ ЦИКЛ ПРИНЯТИЯ КЛИЕНТОВ НА РЕСЕПШЕНЕ (Бланк ➔ Фото ➔ ПК ➔ Печать)
    local function ProcessReceptionIntake()
        local recPos = CustomWaypoints.Reception
        if not recPos then return false end
        local recVec = typeof(recPos) == "CFrame" and recPos.Position or recPos

        if not HasWaitingReceptionCustomers() then
            return false
        end

        local totalRegistered = 0

        while HasWaitingReceptionCustomers() and totalRegistered < 5 do
            -- 1. ШАГ 1: Заполнить форму (Планшет / Бланк на столе)
            local formPos = CustomWaypoints.Reception_Form or recPos
            TeleportTo(formPos)
            task.wait(0.2)

            local formDone = false
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled and not IsDoorOrTrash(obj) then
                    local pCF = GetPromptTargetCFrame(obj)
                    if pCF and (pCF.Position - recVec).Magnitude < 16 then
                        local act = string.lower(tostring(obj.ActionText or ""))
                        local objT = string.lower(tostring(obj.ObjectText or ""))
                        if SafeFind(act, "заполн") or SafeFind(act, "форм") or SafeFind(act, "бланк") or SafeFind(objT, "бланк") or SafeFind(objT, "форм") then
                            SafeInteractPrompt(obj, 0.4)
                            formDone = true
                            task.wait(0.5)
                            break
                        end
                    end
                elseif obj:IsA("ClickDetector") and obj.Parent then
                    local p = obj.Parent
                    if p:IsA("BasePart") and (p.Position - recVec).Magnitude < 16 then
                        local pName = string.lower(p.Name)
                        if SafeFind(pName, "clip") or SafeFind(pName, "form") or SafeFind(pName, "paper") or SafeFind(pName, "бланк") then
                            pcall(function() if fireclickdetector then fireclickdetector(obj) end end)
                            formDone = true
                            task.wait(0.5)
                            break
                        end
                    end
                end
            end

            if not formDone then break end

            -- 2. ШАГ 2: Сделать фото (Камера на штативе слева)
            local camPos = CustomWaypoints.Reception_Camera or (recPos * CFrame.new(-3.5, 0, 0))
            TeleportTo(camPos)
            task.wait(0.2)

            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled and not IsDoorOrTrash(obj) then
                    local pCF = GetPromptTargetCFrame(obj)
                    if pCF and (pCF.Position - recVec).Magnitude < 18 then
                        local act = string.lower(tostring(obj.ActionText or ""))
                        local objT = string.lower(tostring(obj.ObjectText or ""))
                        local pName = string.lower(tostring(obj.Parent and obj.Parent.Name or ""))
                        if SafeFind(act, "фото") or SafeFind(act, "снять") or SafeFind(act, "photo") or SafeFind(act, "camera") or SafeFind(pName, "cam") or SafeFind(objT, "камер") then
                            SafeInteractPrompt(obj, 0.4)
                            task.wait(0.5)
                            break
                        end
                    end
                elseif obj:IsA("ClickDetector") and obj.Parent then
                    local p = obj.Parent
                    if p:IsA("BasePart") and (p.Position - recVec).Magnitude < 18 then
                        local pName = string.lower(p.Name)
                        if SafeFind(pName, "cam") or SafeFind(pName, "photo") or SafeFind(pName, "камер") then
                            pcall(function() if fireclickdetector then fireclickdetector(obj) end end)
                            task.wait(0.5)
                            break
                        end
                    end
                end
            end

            -- 3. ШАГ 3: Ожидание прогресс-бара регистрации на ПК (1.8 сек)
            task.wait(1.8)

            -- 4. ШАГ 4: Распечатать талон (Принтер справа от ПК)
            local printPos = CustomWaypoints.Reception_Printer or (recPos * CFrame.new(3.8, 0, 0))
            TeleportTo(printPos)
            task.wait(0.2)

            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Enabled and not IsDoorOrTrash(obj) then
                    local pCF = GetPromptTargetCFrame(obj)
                    if pCF and (pCF.Position - recVec).Magnitude < 18 then
                        local act = string.lower(tostring(obj.ActionText or ""))
                        local objT = string.lower(tostring(obj.ObjectText or ""))
                        local pName = string.lower(tostring(obj.Parent and obj.Parent.Name or ""))
                        if SafeFind(act, "печат") or SafeFind(act, "print") or SafeFind(pName, "print") or SafeFind(objT, "принтер") then
                            SafeInteractPrompt(obj, 0.4)
                            task.wait(0.5)
                            break
                        end
                    end
                elseif obj:IsA("ClickDetector") and obj.Parent then
                    local p = obj.Parent
                    if p:IsA("BasePart") and (p.Position - recVec).Magnitude < 18 then
                        local pName = string.lower(p.Name)
                        if SafeFind(pName, "print") or SafeFind(pName, "принтер") then
                            pcall(function() if fireclickdetector then fireclickdetector(obj) end end)
                            task.wait(0.5)
                            break
                        end
                    end
                end
            end

            totalRegistered = totalRegistered + 1
            SendNotification("Ресепшен", "Клиент успешно зарегистрирован! (" .. tostring(totalRegistered) .. ")", 2)
            task.wait(0.8)
        end

        return totalRegistered > 0
    end

    local function ProcessHospitalCycle()
        -- 0. Авто-принятие клиентов на ресепшене
        if Config.AutoRegistration and (tick() - lastReceptionTime > 15) then
            lastReceptionTime = tick()
            pcall(ProcessReceptionIntake)
        end

        -- Проход по палатам 1 - 5 (ПРОВЕРКА НАЛИЧИЯ БОЛЬНОГО ➔ КОЙКА ➔ СКАНЕР ➔ ПОЛКА ➔ ЛЕЧЕНИЕ)
        for wardNum = 1, 5 do
            if not Config.AutoHospitalCycle then break end

            local bedPos = GetWardBedPosition(wardNum)
            local devPos = GetWardDevicePosition(wardNum)

            if bedPos and IsWardActive(wardNum) then
                local bedVec = typeof(bedPos) == "CFrame" and bedPos.Position or bedPos

                -- Проверяем Prompts на койке
                local bedDNA = nil
                local bedHeal = nil
                for _, p in pairs(Workspace:GetDescendants()) do
                    if p:IsA("ProximityPrompt") and p.Enabled and not IsDoorOrTrash(p) then
                        local pCF = GetPromptTargetCFrame(p)
                        if pCF and (pCF.Position - bedVec).Magnitude < 18 then
                            if IsDNAPrompt(p) then bedDNA = p end
                            if IsHealPrompt(p) then bedHeal = p end
                        end
                    end
                end

                -- ШАГ 1: Если пациент ждет взятия анализа ДНК
                if bedDNA then
                    TeleportTo(bedPos)
                    task.wait(0.35)
                    SafeInteractPrompt(bedDNA, 0.4)
                    task.wait(1.2)
                end

                -- ШАГ 2: Перенос в сканер и взаимодействие с компьютером (2 нажатия)
                if devPos then
                    PerformDeskAnalysis(devPos)
                end

                -- ШАГ 3: ЧТЕНИЕ ДИАГНОЗА (Строгий многослойный опрос до 5.0 сек)
                local reqMedKey = GetDiagnosedMedicine(wardNum, 5.0)

                if not reqMedKey then
                    SendNotification("⚠️ Внимание", "Диагноз в палате " .. tostring(wardNum) .. " не определен!\nЛечение пропущено во избежание ошибки.", 3)
                    print("[Averlik Hub] Диагноз в палате " .. tostring(wardNum) .. " не распознан. Пропуск палаты.")
                else
                    SendNotification("🩺 Диагноз", "Палата " .. tostring(wardNum) .. ": Требуется " .. tostring(reqMedKey), 2)

                    -- Проверяем, держим ли мы уже нужное лекарство
                    local hasMatching = EquipRequiredMedicine(reqMedKey)

                    if not hasMatching then
                        local medTarget = CustomWaypoints[reqMedKey]
                        if medTarget then
                            TeleportTo(medTarget)
                            task.wait(0.4)

                            local myP = GetMyPosition()
                            for _, cabObj in pairs(Workspace:GetDescendants()) do
                                if IsCabinetPrompt(cabObj) then
                                    local cabCF = GetPromptTargetCFrame(cabObj)
                                    if cabCF and myP and (cabCF.Position - myP).Magnitude < 7.5 then
                                        SafeInteractPrompt(cabObj, 0.4)
                                        task.wait(0.5)
                                        break
                                    end
                                end
                            end

                            -- Одеваем строго требуемое лекарство
                            EquipRequiredMedicine(reqMedKey)
                        end
                    end

                    -- ШАГ 4 & 5: СТРОГАЯ ЗАЩИТА: Лечим пациента ТОЛЬКО если в руках правильное лекарство!
                    if EquipRequiredMedicine(reqMedKey) then
                        TeleportTo(bedPos)
                        task.wait(0.35)

                        local bedVec = typeof(bedPos) == "CFrame" and bedPos.Position or bedPos
                        for _, p in pairs(Workspace:GetDescendants()) do
                            if IsHealPrompt(p) then
                                local pCF = GetPromptTargetCFrame(p)
                                if pCF and (pCF.Position - bedVec).Magnitude < 18 then
                                    SafeInteractPrompt(p, 0.5)
                                    task.wait(1.5) -- Процесс лечения больного
                                    SendNotification("✨ Успех", "Пациент в палате " .. tostring(wardNum) .. " успешно вылечен!", 2)
                                    break
                                end
                            end
                        end
                    else
                        SendNotification("❌ Отмена", "Не найдено верное лекарство для палаты " .. tostring(wardNum) .. "!\nЛечение отменено во избежание гибели.", 3)
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
                    local room7Pos = CustomWaypoints.Ward7_Bed or GetWardBedPosition(7)
                    local room7Dev = CustomWaypoints.Ward7_Device or room7Pos
                    if room7Pos then
                        TeleportTo(room7Pos)
                        task.wait(0.3)

                        if Config.Room7_AutoHeartGame then
                            if room7Dev then TeleportTo(room7Dev); task.wait(0.25) end
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
                                local cabPos = CustomWaypoints.Med_IVDrip or CustomWaypoints.Med_FirstAid
                                if cabPos then TeleportTo(cabPos); task.wait(0.3) end
                                for _, medObj in pairs(Workspace:GetDescendants()) do
                                    if IsCabinetPrompt(medObj) then
                                        local act = string.lower(tostring(medObj.ActionText or ""))
                                        if SafeFind(act, "капельниц") or SafeFind(act, "drip") or SafeFind(act, "аптечк") then
                                            local medCF = GetPromptTargetCFrame(medObj)
                                            if medCF then
                                                TeleportTo(medCF)
                                                task.wait(0.2)
                                                SafeInteractPrompt(medObj, 0.3)
                                                task.wait(0.4)
                                                break
                                            end
                                        end
                                    end
                                end
                            end

                            TeleportTo(room7Pos)
                            task.wait(0.3)
                            EquipMedicalTool("капельниц")
                            for _, pPrompt in pairs(Workspace:GetDescendants()) do
                                if IsHealPrompt(pPrompt) or IsDNAPrompt(pPrompt) then
                                    local pCF = GetPromptTargetCFrame(pPrompt)
                                    if pCF then
                                        local r7Vec = typeof(room7Pos) == "CFrame" and room7Pos.Position or room7Pos
                                        if (r7Vec - pCF.Position).Magnitude < 25 then
                                            SafeInteractPrompt(pPrompt, 0.5)
                                            task.wait(0.8)
                                            break
                                        end
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
                                SafeInteractPrompt(obj, 0.3)
                                task.wait(0.4)
                                break
                            end
                        end
                    end
                end)
            end
        end
    end)

    SendNotification("Averlik Hub", "Animal Hospital: идеальный авто-цикл готов!", 4)
    print("[Averlik Hub] Умная фильтрация палат и тайминги компьютеров готовы!")
end

local ok, err = pcall(RunAverlikHub)
if not ok then
    warn("[Averlik Hub Error]:", err)
end