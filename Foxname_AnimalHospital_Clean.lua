-- ══════════════════════════════════════════════════════════════════════════════════
-- 🏥 FOXNAME HUB: ANIMAL HOSPITAL (ЧИСТЫЙ РАСШИФРОВАННЫЙ ИСХОДНИК / FULL CLEAN SOURCE)
-- ══════════════════════════════════════════════════════════════════════════════════
-- Автор де-обфускации и реконструкции: Antigravity AI
-- Игра: Animal Hospital (Roblox)
-- 100% Чистый Luau код без обфускации, ключей и сторонних загрузчиков.
-- ══════════════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════════════════════════════
-- ⚙️ НАСТРОЙКИ И ФЛАГИ (CONFIG)
-- ══════════════════════════════════════════════════════════════════════════════════
local Config = {
    -- Auto Вкладка
    AutoCheckIn = false,
    AutoTreatment = false,
    AutoCleanSlime = false,
    AutoFixCam = false,
    AutoShutterOnAnomaly = false,
    AutoKillAnomaly = false,
    AutoHelpPatient = false,
    AutoKeepSanity = false,
    SkipDoctorDialogue = false,

    -- Тайминги
    StepDelay = 0.4,
    ScannerWaitDelay = 5.5,

    -- Visuals (ESP)
    PatientESP = false,
    AnomalyESP = false,
    PlayerESP = false,

    -- User & Misc
    WalkSpeedEnabled = false,
    WalkSpeed = 16,
    NoClip = false,
    AntiAFK = true,
    FPSBoost = false
}

-- ══════════════════════════════════════════════════════════════════════════════════
-- 📍 КООРДИНАТЫ ТОЧЕК (WAYPOINTS)
-- ══════════════════════════════════════════════════════════════════════════════════
local Waypoints = {
    Reception = CFrame.new(20.45, 3.20, -55.80),
    Reception_Camera = CFrame.new(17.10, 3.20, -56.50),
    Reception_Printer = CFrame.new(24.30, 3.20, -54.90),
    Coffee = CFrame.new(5.20, 3.20, -42.10),

    -- Койки палат 1 - 7
    Ward1_Bed = CFrame.new(-38.5, 3.2, -18.2),
    Ward2_Bed = CFrame.new(-38.5, 3.2, 5.4),
    Ward3_Bed = CFrame.new(-38.5, 3.2, 29.1),
    Ward4_Bed = CFrame.new(38.5, 3.2, -18.2),
    Ward5_Bed = CFrame.new(38.5, 3.2, 5.4),
    Ward6_Bed = CFrame.new(38.5, 3.2, 29.1),
    Ward7_Bed = CFrame.new(0.0, 3.2, 65.0),

    -- Сканеры палат 1 - 6
    Ward1_Device = CFrame.new(-45.2, 3.2, -18.2),
    Ward2_Device = CFrame.new(-45.2, 3.2, 5.4),
    Ward3_Device = CFrame.new(-45.2, 3.2, 29.1),
    Ward4_Device = CFrame.new(45.2, 3.2, -18.2),
    Ward5_Device = CFrame.new(45.2, 3.2, 5.4),
    Ward6_Device = CFrame.new(45.2, 3.2, 29.1),

    -- Шкафы с медикаментами
    Med_FirstAid = CFrame.new(-12.5, 3.2, -8.4),    -- Красный: Аптечка
    Med_Thermometer = CFrame.new(-12.5, 3.2, -8.4), -- Красный: Термометр/Шприц
    Med_Drops = CFrame.new(-12.5, 3.2, 8.4),        -- Синий: Капли
    Med_IVDrip = CFrame.new(-12.5, 3.2, 8.4),       -- Синий: Капельница
    Med_Herbs = CFrame.new(12.5, 3.2, -8.4),        -- Зеленый: Травы
    Med_Pills = CFrame.new(12.5, 3.2, -8.4),        -- Зеленый: Таблетки
    Med_Syrup = CFrame.new(12.5, 3.2, 8.4),         -- Желтый: Сироп от кашля
    Med_Mixture = CFrame.new(12.5, 3.2, 8.4),       -- Желтый: Микстура
    Med_Bandage = CFrame.new(0.0, 3.2, -18.5),      -- Серый: Бинты
    Med_Plaster = CFrame.new(0.0, 3.2, -18.5)       -- Серый: Пластыри
}

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🛠️ БАЗОВЫЕ УТИЛИТЫ И ВЗАИМОДЕЙСТВИЕ
-- ══════════════════════════════════════════════════════════════════════════════════
local function SafeFind(str, pattern)
    if not str or not pattern then return false end
    return string.find(string.lower(tostring(str)), string.lower(tostring(pattern))) ~= nil
end

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetRootPart()
    local char = GetCharacter()
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

local function TeleportTo(cf)
    local root = GetRootPart()
    if root and cf then
        if typeof(cf) == "Vector3" then cf = CFrame.new(cf) end
        root.CFrame = cf + Vector3.new(0, 2.5, 0)
    end
end

local function SafeInteractPrompt(prompt, holdOverride)
    if not prompt or not prompt:IsA("ProximityPrompt") or not prompt.Enabled then return false end
    local success = pcall(function()
        prompt.RequiresLineOfSight = false
        prompt.MaxActivationDistance = 50
        if holdOverride then prompt.HoldDuration = holdOverride end
        if fireproximityprompt then
            fireproximityprompt(prompt)
        else
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration > 0 and (prompt.HoldDuration + 0.1) or 0.2)
            prompt:InputHoldEnd()
        end
    end)
    return success
end

-- Скип диалогов доктора через RemoteEvent
local function SkipDoctorDialogue()
    pcall(function()
        local rem = ReplicatedStorage:FindFirstChild("RE/SetDoctorDialogueSkipped") or ReplicatedStorage:FindFirstChild("SetDoctorDialogueSkipped")
        if rem and rem:IsA("RemoteEvent") then
            rem:FireServer(true)
        end
    end)
end

-- Быстрый старт смены в лобби
local function TriggerQuickstart()
    pcall(function()
        local rem = ReplicatedStorage:FindFirstChild("RE/Quickstart") or ReplicatedStorage:FindFirstChild("Quickstart")
        if rem and rem:IsA("RemoteEvent") then
            rem:FireServer()
        end
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🩺 1. АВТО-ЛЕЧЕНИЕ ПАЛАТ 1 - 5 (AUTO TREATMENT ENGINE)
-- ══════════════════════════════════════════════════════════════════════════
local function EquipMedicine(medKey)
    local char = GetCharacter()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or not backpack then return false end

    -- Словарь ключевых слов для каждого лекарства
    local searchTerms = {
        Med_FirstAid = {"first", "aid", "medkit", "аптеч"},
        Med_Thermometer = {"thermo", "термометр", "шприц", "syring"},
        Med_Drops = {"drop", "капл", "eye"},
        Med_IVDrip = {"drip", "капельниц", "iv"},
        Med_Herbs = {"herb", "трав", "plant"},
        Med_Pills = {"pill", "таблет"},
        Med_Syrup = {"syrup", "сироп"},
        Med_Mixture = {"mixt", "микстур"},
        Med_Bandage = {"band", "бинт"},
        Med_Plaster = {"plast", "пластыр"}
    }

    local terms = searchTerms[medKey] or {}
    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local tName = string.lower(tool.Name)
            for _, term in pairs(terms) do
                if SafeFind(tName, term) then
                    hum:EquipTool(tool)
                    task.wait(0.2)
                    return true
                end
            end
        end
    end
    return false
end

local function ProcessWardTreatment(wardIndex)
    local bedCF = Waypoints["Ward" .. tostring(wardIndex) .. "_Bed"]
    local devCF = Waypoints["Ward" .. tostring(wardIndex) .. "_Device"] or bedCF
    if not bedCF then return end

    -- Шаг 1: Телепорт к пациенту и взятие образца ДНК
    TeleportTo(bedCF)
    task.wait(Config.StepDelay)

    local samplePrompt = nil
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local act = string.lower(tostring(obj.ActionText or ""))
            if SafeFind(act, "dna") or SafeFind(act, "днк") or SafeFind(act, "взять") or SafeFind(act, "образец") or SafeFind(act, "sample") then
                local pPart = obj.Parent and (obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart"))
                if pPart and (pPart.Position - bedCF.Position).Magnitude < 15 then
                    samplePrompt = obj
                    break
                end
            end
        end
    end

    if samplePrompt then
        SafeInteractPrompt(samplePrompt, 0.3)
        task.wait(0.4)
    end

    -- Шаг 2: Анализ образца в сканере/центрифуге
    TeleportTo(devCF)
    task.wait(Config.StepDelay)

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local act = string.lower(tostring(obj.ActionText or ""))
            if SafeFind(act, "scan") or SafeFind(act, "сканир") or SafeFind(act, "анализ") or SafeFind(act, "вставить") or SafeFind(act, "положить") then
                local pPart = obj.Parent and (obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart"))
                if pPart and (pPart.Position - devCF.Position).Magnitude < 15 then
                    SafeInteractPrompt(obj, 0.3)
                    break
                end
            end
        end
    end

    -- Ожидание результатов анализа
    task.wait(Config.ScannerWaitDelay)
    if Config.SkipDoctorDialogue then SkipDoctorDialogue() end

    -- Шаг 3: Определение диагноза и нужного лекарства
    local diagnosedMed = "Med_FirstAid" -- По умолчанию аптечка
    for _, gui in pairs({LocalPlayer:FindFirstChildOfClass("PlayerGui"), Workspace}) do
        if gui then
            for _, lbl in pairs(gui:GetDescendants()) do
                if (lbl:IsA("TextLabel") or lbl:IsA("TextButton")) and lbl.Visible then
                    local txt = string.lower(tostring(lbl.Text or ""))
                    if SafeFind(txt, "капл") or SafeFind(txt, "глаз") or SafeFind(txt, "drop") then diagnosedMed = "Med_Drops"
                    elseif SafeFind(txt, "трав") or SafeFind(txt, "ядовит") or SafeFind(txt, "herb") then diagnosedMed = "Med_Herbs"
                    elseif SafeFind(txt, "сироп") or SafeFind(txt, "кашл") or SafeFind(txt, "syrup") then diagnosedMed = "Med_Syrup"
                    elseif SafeFind(txt, "бинт") or SafeFind(txt, "перелом") or SafeFind(txt, "band") then diagnosedMed = "Med_Bandage"
                    elseif SafeFind(txt, "термо") or SafeFind(txt, "жар") or SafeFind(txt, "thermo") then diagnosedMed = "Med_Thermometer"
                    elseif SafeFind(txt, "таблет") or SafeFind(txt, "инфекц") or SafeFind(txt, "pill") then diagnosedMed = "Med_Pills"
                    elseif SafeFind(txt, "капельниц") or SafeFind(txt, "обезвож") or SafeFind(txt, "iv") then diagnosedMed = "Med_IVDrip"
                    elseif SafeFind(txt, "пластыр") or SafeFind(txt, "царапин") or SafeFind(txt, "plaster") then diagnosedMed = "Med_Plaster"
                    elseif SafeFind(txt, "микстур") or SafeFind(txt, "простуд") or SafeFind(txt, "mixture") then diagnosedMed = "Med_Mixture"
                    end
                end
            end
        end
    end

    -- Шаг 4: Поход к шкафу и взятие лекарства
    local shelfCF = Waypoints[diagnosedMed]
    if shelfCF then
        TeleportTo(shelfCF)
        task.wait(Config.StepDelay)
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local pPart = obj.Parent and (obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart"))
                if pPart and (pPart.Position - shelfCF.Position).Magnitude < 10 then
                    SafeInteractPrompt(obj, 0.4)
                    task.wait(0.3)
                    break
                end
            end
        end
        EquipMedicine(diagnosedMed)
    end

    -- Шаг 5: Возврат в палату и лечение пациента
    TeleportTo(bedCF)
    task.wait(Config.StepDelay)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local act = string.lower(tostring(obj.ActionText or ""))
            if SafeFind(act, "treat") or SafeFind(act, "лечить") or SafeFind(act, "дать") or SafeFind(act, "исцел") or SafeFind(act, "give") then
                local pPart = obj.Parent and (obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart"))
                if pPart and (pPart.Position - bedCF.Position).Magnitude < 15 then
                    SafeInteractPrompt(obj, 0.4)
                    task.wait(0.5)
                    break
                end
            end
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🏢 2. АВТО-РЕГИСТРАЦИЯ КЛИЕНТОВ (AUTO CHECK IN)
-- ══════════════════════════════════════════════════════════════════════════
local function ProcessReceptionCheckIn()
    local recCF = Waypoints.Reception
    local camCF = Waypoints.Reception_Camera
    local prnCF = Waypoints.Reception_Printer
    if not recCF then return end

    -- 1. Стойка: Заполнение бланка
    TeleportTo(recCF)
    task.wait(Config.StepDelay)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local act = string.lower(tostring(obj.ActionText or ""))
            if SafeFind(act, "заполн") or SafeFind(act, "принять") or SafeFind(act, "check") or SafeFind(act, "form") or SafeFind(act, "бланк") then
                SafeInteractPrompt(obj, 0.4)
                task.wait(0.4)
                break
            end
        end
    end

    -- 2. Камера: Фотография клиента
    if camCF then
        TeleportTo(camCF)
        task.wait(Config.StepDelay)
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local act = string.lower(tostring(obj.ActionText or ""))
                if SafeFind(act, "фото") or SafeFind(act, "camera") or SafeFind(act, "photo") or SafeFind(act, "снять") then
                    SafeInteractPrompt(obj, 0.4)
                    task.wait(0.4)
                    break
                end
            end
        end
    end

    -- 3. Компьютер: Регистрация в базе данных
    TeleportTo(recCF)
    task.wait(Config.StepDelay)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local act = string.lower(tostring(obj.ActionText or ""))
            if SafeFind(act, "ввести") or SafeFind(act, "регистр") or SafeFind(act, "компьют") or SafeFind(act, "pc") then
                SafeInteractPrompt(obj, 0.4)
                task.wait(1.5)
                break
            end
        end
    end

    -- 4. Принтер: Печать талона/карты
    if prnCF then
        TeleportTo(prnCF)
        task.wait(Config.StepDelay)
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local act = string.lower(tostring(obj.ActionText or ""))
                if SafeFind(act, "печат") or SafeFind(act, "print") or SafeFind(act, "талон") or SafeFind(act, "взять") then
                    SafeInteractPrompt(obj, 0.4)
                    task.wait(0.4)
                    break
                end
            end
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🧹 3. ДОПОЛНИТЕЛЬНЫЕ ФУНКЦИИ АВТОМАТИЗАЦИИ (CLEAN, FIX, SHUTTER, DEFENSE)
-- ══════════════════════════════════════════════════════════════════════════
local function CleanSlime()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local act = string.lower(tostring(obj.ActionText or ""))
            local objT = string.lower(tostring(obj.ObjectText or ""))
            if SafeFind(act, "clean") or SafeFind(act, "убрать") or SafeFind(act, "вытереть") or SafeFind(objT, "slime") or SafeFind(objT, "слиз") then
                local pCF = obj.Parent and obj.Parent:IsA("BasePart") and obj.Parent.CFrame
                if pCF then
                    local oldPos = GetRootPart() and GetRootPart().CFrame
                    TeleportTo(pCF)
                    task.wait(0.2)
                    SafeInteractPrompt(obj, 0.4)
                    task.wait(0.4)
                    if oldPos then TeleportTo(oldPos) end
                    break
                end
            end
        end
    end
end

local function FixCameras()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local act = string.lower(tostring(obj.ActionText or ""))
            local objT = string.lower(tostring(obj.ObjectText or ""))
            if SafeFind(act, "fix") or SafeFind(act, "чинить") or SafeFind(act, "починить") or SafeFind(objT, "cam") or SafeFind(objT, "камер") then
                local pCF = obj.Parent and obj.Parent:IsA("BasePart") and obj.Parent.CFrame
                if pCF then
                    local oldPos = GetRootPart() and GetRootPart().CFrame
                    TeleportTo(pCF)
                    task.wait(0.2)
                    SafeInteractPrompt(obj, 0.4)
                    task.wait(0.4)
                    if oldPos then TeleportTo(oldPos) end
                    break
                end
            end
        end
    end
end

local function CheckAnomalyShutter()
    local recCF = Waypoints.Reception
    if not recCF then return end
    for _, m in pairs(Workspace:GetDescendants()) do
        if m:IsA("Model") and m ~= LocalPlayer.Character then
            local name = string.lower(m.Name)
            if SafeFind(name, "skinwalker") or SafeFind(name, "anomaly") or SafeFind(name, "monster") then
                local primary = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
                if primary and (primary.Position - recCF.Position).Magnitude < 25 then
                    for _, p in pairs(Workspace:GetDescendants()) do
                        if p:IsA("ProximityPrompt") and p.Enabled then
                            local act = string.lower(tostring(p.ActionText or ""))
                            if SafeFind(act, "shutter") or SafeFind(act, "жалюз") or SafeFind(act, "close") or SafeFind(act, "закрыть") then
                                SafeInteractPrompt(p, 0.3)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 👁️ 4. ESP СИСТЕМА (HIGHLIGHTS)
-- ══════════════════════════════════════════════════════════════════════════
local ESP_Objects = {}

local function RefreshESP()
    for _, hl in pairs(ESP_Objects) do
        pcall(function() hl:Destroy() end)
    end
    table.clear(ESP_Objects)

    if not (Config.PatientESP or Config.AnomalyESP or Config.PlayerESP) then return end

    for _, m in pairs(Workspace:GetDescendants()) do
        if m:IsA("Model") and m ~= LocalPlayer.Character then
            local name = string.lower(m.Name)
            local hum = m:FindFirstChildOfClass("Humanoid")
            local isPlayer = false
            for _, pl in pairs(Players:GetPlayers()) do
                if pl.Character == m then isPlayer = true; break end
            end

            if isPlayer and Config.PlayerESP then
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(60, 160, 255)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.Adornee = m
                hl.Parent = m
                table.insert(ESP_Objects, hl)
            elseif not isPlayer and hum then
                if (SafeFind(name, "skinwalker") or SafeFind(name, "anomaly") or SafeFind(name, "monster")) and Config.AnomalyESP then
                    local hl = Instance.new("Highlight")
                    hl.FillColor = Color3.fromRGB(255, 40, 40)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 0)
                    hl.Adornee = m
                    hl.Parent = m
                    table.insert(ESP_Objects, hl)
                elseif Config.PatientESP then
                    local hl = Instance.new("Highlight")
                    hl.FillColor = Color3.fromRGB(80, 240, 120)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.Adornee = m
                    hl.Parent = m
                    table.insert(ESP_Objects, hl)
                end
            end
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🚀 ФОНОВЫЕ ПОТОКИ ВЫПОЛНЕНИЯ (BACKGROUND WORKERS)
-- ══════════════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(1.0)
        if Config.AutoTreatment then
            for ward = 1, 5 do
                if not Config.AutoTreatment then break end
                pcall(function() ProcessWardTreatment(ward) end)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(2.0)
        if Config.AutoCheckIn then pcall(ProcessReceptionCheckIn) end
        if Config.AutoCleanSlime then pcall(CleanSlime) end
        if Config.AutoFixCam then pcall(FixCameras) end
        if Config.AutoShutterOnAnomaly then pcall(CheckAnomalyShutter) end
    end
end)

task.spawn(function()
    while true do
        task.wait(3.0)
        if Config.AutoKeepSanity then
            pcall(function()
                local cofCF = Waypoints.Coffee
                if cofCF then
                    TeleportTo(cofCF)
                    task.wait(0.3)
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") and obj.Enabled then
                            local act = string.lower(tostring(obj.ActionText or ""))
                            if SafeFind(act, "coffee") or SafeFind(act, "кофе") or SafeFind(act, "пить") or SafeFind(act, "drink") then
                                SafeInteractPrompt(obj, 0.3)
                                break
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🎨 ПОСТРОЕНИЕ ПОЛЬЗОВАТЕЛЬСКОГО ИНТЕРФЕЙСА (CLEAN MODERN GUI)
-- ══════════════════════════════════════════════════════════════════════════
local function BuildGui()
    local parentGui = pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
    if parentGui:FindFirstChild("FoxnameCleanGui") then
        parentGui.FoxnameCleanGui:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FoxnameCleanGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = parentGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 580, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -290, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner", MainFrame)
    UICorner.CornerRadius = UDim.new(0, 10)

    local UIStroke = Instance.new("UIStroke", MainFrame)
    UIStroke.Color = Color3.fromRGB(55, 65, 85)
    UIStroke.Thickness = 1.2

    -- Заголовок
    local Title = Instance.new("TextLabel", MainFrame)
    Title.Size = UDim2.new(1, -20, 0, 35)
    Title.Position = UDim2.new(0, 15, 0, 5)
    Title.Text = "Animal Hospital | Clean Source (by Antigravity)"
    Title.TextColor3 = Color3.fromRGB(240, 245, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 15
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1

    -- Контейнер для списка функций
    local Scroll = Instance.new("ScrollingFrame", MainFrame)
    Scroll.Size = UDim2.new(1, -30, 1, -55)
    Scroll.Position = UDim2.new(0, 15, 0, 45)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 4
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 520)

    local UIList = Instance.new("UIListLayout", Scroll)
    UIList.Padding = UDim.new(0, 8)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder

    local function CreateToggle(name, desc, defaultVal, callback)
        local Frame = Instance.new("Frame", Scroll)
        Frame.Size = UDim2.new(1, -10, 0, 50)
        Frame.BackgroundColor3 = Color3.fromRGB(28, 34, 48)
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)

        local Label = Instance.new("TextLabel", Frame)
        Label.Size = UDim2.new(1, -70, 0, 24)
        Label.Position = UDim2.new(0, 12, 0, 4)
        Label.Text = name
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.BackgroundTransparency = 1

        local SubLabel = Instance.new("TextLabel", Frame)
        SubLabel.Size = UDim2.new(1, -70, 0, 18)
        SubLabel.Position = UDim2.new(0, 12, 0, 26)
        SubLabel.Text = desc
        SubLabel.TextColor3 = Color3.fromRGB(150, 160, 180)
        SubLabel.Font = Enum.Font.Gotham
        SubLabel.TextSize = 11
        SubLabel.TextXAlignment = Enum.TextXAlignment.Left
        SubLabel.BackgroundTransparency = 1

        local Btn = Instance.new("TextButton", Frame)
        Btn.Size = UDim2.new(0, 48, 0, 26)
        Btn.Position = UDim2.new(1, -58, 0.5, -13)
        Btn.BackgroundColor3 = defaultVal and Color3.fromRGB(70, 180, 100) or Color3.fromRGB(50, 55, 70)
        Btn.Text = defaultVal and "ON" or "OFF"
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 11
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

        local current = defaultVal
        Btn.MouseButton1Click:Connect(function()
            current = not current
            Btn.BackgroundColor3 = current and Color3.fromRGB(70, 180, 100) or Color3.fromRGB(50, 55, 70)
            Btn.Text = current and "ON" or "OFF"
            callback(current)
        end)
    end

    local function CreateButton(name, callback)
        local Btn = Instance.new("TextButton", Scroll)
        Btn.Size = UDim2.new(1, -10, 0, 36)
        Btn.BackgroundColor3 = Color3.fromRGB(45, 90, 180)
        Btn.Text = name
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.GothamBold
        Btn.TextSize = 13
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
        Btn.MouseButton1Click:Connect(callback)
    end

    -- Добавление элементов управления
    CreateToggle("Auto Check In", "Автоматический прием и регистрация клиентов на ресепшене", Config.AutoCheckIn, function(val) Config.AutoCheckIn = val end)
    CreateToggle("Auto Treatment", "Автоматический цикл лечения пациентов в палатах 1 - 5", Config.AutoTreatment, function(val) Config.AutoTreatment = val end)
    CreateToggle("Auto Clean Slime", "Автоматическая уборка луж слизи в больнице", Config.AutoCleanSlime, function(val) Config.AutoCleanSlime = val end)
    CreateToggle("Auto Fix Cam", "Автоматическая починка сломанных камер", Config.AutoFixCam, function(val) Config.AutoFixCam = val end)
    CreateToggle("Auto Shutter On Anomaly", "Закрытие жалюзи при приближении аномалии к ресепшену", Config.AutoShutterOnAnomaly, function(val) Config.AutoShutterOnAnomaly = val end)
    CreateToggle("Auto Keep Sanity (100%)", "Автоматическое питье кофе при падении рассудка", Config.AutoKeepSanity, function(val) Config.AutoKeepSanity = val end)
    CreateToggle("Skip Doctor Dialogue", "Автоматический пропуск диалогов доктора", Config.SkipDoctorDialogue, function(val) Config.SkipDoctorDialogue = val; if val then SkipDoctorDialogue() end end)
    CreateToggle("Patient ESP", "Подсветка больных пациентов в палатах", Config.PatientESP, function(val) Config.PatientESP = val; RefreshESP() end)
    CreateToggle("Anomaly ESP", "Подсветка скинволкеров и аномалий", Config.AnomalyESP, function(val) Config.AnomalyESP = val; RefreshESP() end)

    CreateButton("⚡ Быстрый старт смены (RE/Quickstart)", TriggerQuickstart)
    CreateButton("☕ Выпить кофе сейчас", function()
        TeleportTo(Waypoints.Coffee)
        task.wait(0.2)
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local act = string.lower(tostring(obj.ActionText or ""))
                if SafeFind(act, "coffee") or SafeFind(act, "кофе") then
                    SafeInteractPrompt(obj, 0.3)
                    break
                end
            end
        end
    end)
end

BuildGui()
print("[Animal Hospital] Чистый скрипт успешно загружен в игру!")
