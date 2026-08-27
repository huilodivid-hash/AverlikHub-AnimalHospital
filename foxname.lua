-- ══════════════════════════════════════════════════════════════════════════════════
-- 🦊 FOXNAME HUB: ANIMAL HOSPITAL (100% CLEAN DEOBFUSCATED SOURCE)
-- ══════════════════════════════════════════════════════════════════════════════════
-- Original: Foxname Hub | Animal Hospital (Foxname.top)
-- Deobfuscated & Reconstructed Clean Source Code
-- ══════════════════════════════════════════════════════════════════════════════════

local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/huilodivid-hash/AverlikHub-AnimalHospital/main/fluent.lua"))()
local SaveManager, InterfaceManager
pcall(function()
    SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
    InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
end)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════════════════════════════
-- 📍 WAYPOINTS TABLE
-- ══════════════════════════════════════════════════════════════════════════════════
local Waypoints = {
    Reception = CFrame.new(20.45, 3.20, -55.80),
    Reception_Camera = CFrame.new(17.10, 3.20, -56.50),
    Reception_Printer = CFrame.new(24.30, 3.20, -54.90),
    Coffee = CFrame.new(5.20, 3.20, -42.10),

    Ward1_Bed = CFrame.new(-38.5, 3.2, -18.2),
    Ward2_Bed = CFrame.new(-38.5, 3.2, 5.4),
    Ward3_Bed = CFrame.new(-38.5, 3.2, 29.1),
    Ward4_Bed = CFrame.new(38.5, 3.2, -18.2),
    Ward5_Bed = CFrame.new(38.5, 3.2, 5.4),
    Ward6_Bed = CFrame.new(38.5, 3.2, 29.1),
    Ward7_Bed = CFrame.new(0.0, 3.2, 65.0),

    Ward1_Device = CFrame.new(-45.2, 3.2, -18.2),
    Ward2_Device = CFrame.new(-45.2, 3.2, 5.4),
    Ward3_Device = CFrame.new(-45.2, 3.2, 29.1),
    Ward4_Device = CFrame.new(45.2, 3.2, -18.2),
    Ward5_Device = CFrame.new(45.2, 3.2, 5.4),
    Ward6_Device = CFrame.new(45.2, 3.2, 29.1),

    Med_FirstAid = CFrame.new(-12.5, 3.2, -8.4),
    Med_Thermometer = CFrame.new(-12.5, 3.2, -8.4),
    Med_Drops = CFrame.new(-12.5, 3.2, 8.4),
    Med_IVDrip = CFrame.new(-12.5, 3.2, 8.4),
    Med_Herbs = CFrame.new(12.5, 3.2, -8.4),
    Med_Pills = CFrame.new(12.5, 3.2, -8.4),
    Med_Syrup = CFrame.new(12.5, 3.2, 8.4),
    Med_Mixture = CFrame.new(12.5, 3.2, 8.4),
    Med_Bandage = CFrame.new(0.0, 3.2, -18.5),
    Med_Plaster = CFrame.new(0.0, 3.2, -18.5)
}

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🛠️ HELPER FUNCTIONS
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

local function SkipDoctorDialogue()
    pcall(function()
        local rem = ReplicatedStorage:FindFirstChild("RE/SetDoctorDialogueSkipped") or ReplicatedStorage:FindFirstChild("SetDoctorDialogueSkipped")
        if rem and rem:IsA("RemoteEvent") then
            rem:FireServer(true)
        end
    end)
end

local function TriggerQuickstart()
    pcall(function()
        local rem = ReplicatedStorage:FindFirstChild("RE/Quickstart") or ReplicatedStorage:FindFirstChild("Quickstart")
        if rem and rem:IsA("RemoteEvent") then
            rem:FireServer()
        end
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🩺 AUTOMATION ENGINE
-- ══════════════════════════════════════════════════════════════════════════
local function EquipMedicine(medKey)
    local char = GetCharacter()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum or not backpack then return false end

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

    TeleportTo(bedCF)
    task.wait(0.4)

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local act = string.lower(tostring(obj.ActionText or ""))
            if SafeFind(act, "dna") or SafeFind(act, "днк") or SafeFind(act, "взять") or SafeFind(act, "образец") or SafeFind(act, "sample") then
                local pPart = obj.Parent and (obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart"))
                if pPart and (pPart.Position - bedCF.Position).Magnitude < 15 then
                    SafeInteractPrompt(obj, 0.3)
                    task.wait(0.4)
                    break
                end
            end
        end
    end

    TeleportTo(devCF)
    task.wait(0.4)

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

    task.wait(5.5)
    SkipDoctorDialogue()

    local diagnosedMed = "Med_FirstAid"
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

    local shelfCF = Waypoints[diagnosedMed]
    if shelfCF then
        TeleportTo(shelfCF)
        task.wait(0.4)
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

    TeleportTo(bedCF)
    task.wait(0.4)
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

local function ProcessReceptionCheckIn()
    local recCF = Waypoints.Reception
    local camCF = Waypoints.Reception_Camera
    local prnCF = Waypoints.Reception_Printer
    if not recCF then return end

    TeleportTo(recCF); task.wait(0.4)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local act = string.lower(tostring(obj.ActionText or ""))
            if SafeFind(act, "заполн") or SafeFind(act, "принять") or SafeFind(act, "check") or SafeFind(act, "form") or SafeFind(act, "бланк") then
                SafeInteractPrompt(obj, 0.4); task.wait(0.4); break
            end
        end
    end

    if camCF then
        TeleportTo(camCF); task.wait(0.4)
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local act = string.lower(tostring(obj.ActionText or ""))
                if SafeFind(act, "фото") or SafeFind(act, "camera") or SafeFind(act, "photo") or SafeFind(act, "снять") then
                    SafeInteractPrompt(obj, 0.4); task.wait(0.4); break
                end
            end
        end
    end

    TeleportTo(recCF); task.wait(0.4)
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local act = string.lower(tostring(obj.ActionText or ""))
            if SafeFind(act, "ввести") or SafeFind(act, "регистр") or SafeFind(act, "компьют") or SafeFind(act, "pc") then
                SafeInteractPrompt(obj, 0.4); task.wait(1.5); break
            end
        end
    end

    if prnCF then
        TeleportTo(prnCF); task.wait(0.4)
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local act = string.lower(tostring(obj.ActionText or ""))
                if SafeFind(act, "печат") or SafeFind(act, "print") or SafeFind(act, "талон") or SafeFind(act, "взять") then
                    SafeInteractPrompt(obj, 0.4); task.wait(0.4); break
                end
            end
        end
    end
end

local function CleanSlime()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local act = string.lower(tostring(obj.ActionText or ""))
            local objT = string.lower(tostring(obj.ObjectText or ""))
            if SafeFind(act, "clean") or SafeFind(act, "убрать") or SafeFind(act, "вытереть") or SafeFind(objT, "slime") or SafeFind(objT, "слиз") then
                local pCF = obj.Parent and obj.Parent:IsA("BasePart") and obj.Parent.CFrame
                if pCF then
                    local oldPos = GetRootPart() and GetRootPart().CFrame
                    TeleportTo(pCF); task.wait(0.2)
                    SafeInteractPrompt(obj, 0.4); task.wait(0.4)
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
                    TeleportTo(pCF); task.wait(0.2)
                    SafeInteractPrompt(obj, 0.4); task.wait(0.4)
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
-- 🖼️ FLUENT UI INTERFACE (EXACT STRUCTURE FROM SCREENSHOT)
-- ══════════════════════════════════════════════════════════════════════════
local Window = Fluent:CreateWindow({
    Title = "Foxname Hub | Animal Hospital",
    SubTitle = "Foxname.top",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Auto = Window:AddTab({ Title = "Auto", Icon = "briefcase" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }),
    Tool = Window:AddTab({ Title = "Tool", Icon = "wrench" }),
    Visual = Window:AddTab({ Title = "Visual", Icon = "eye" }),
    User = Window:AddTab({ Title = "User", Icon = "user" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "file-text" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🏠 MAIN TAB
-- ══════════════════════════════════════════════════════════════════════════
Tabs.Main:AddParagraph({
    Title = "Foxname Hub | Animal Hospital",
    Content = "Clean deobfuscated release for Animal Hospital.
Enjoy automated hospital treatments, reception, and defense!"
})

Tabs.Main:AddButton({
    Title = "Quickstart Shift (RE/Quickstart)",
    Description = "Instantly start hospital shift without waiting countdown",
    Callback = TriggerQuickstart
})

Tabs.Main:AddToggle("SkipDoctorDialogue", {
    Title = "Skip Doctor Dialogue",
    Description = "Automatically skips doctor speeches",
    Default = false,
    Callback = function(Value)
        if Value then SkipDoctorDialogue() end
    end
})

Tabs.Main:AddToggle("KeepSanity", {
    Title = "Auto Keep Sanity (100%)",
    Description = "Automatically drinks coffee when sanity drops",
    Default = false
})

-- ══════════════════════════════════════════════════════════════════════════════════
-- 💼 AUTO TAB (EXACT TOGGLES FROM SCREENSHOT)
-- ══════════════════════════════════════════════════════════════════════════
local AutoCheckInToggle = Tabs.Auto:AddToggle("AutoCheckIn", {
    Title = "Auto Check In",
    Description = "Auto register visitors at reception desk",
    Default = false
})

local AutoTreatmentToggle = Tabs.Auto:AddToggle("AutoTreatment", {
    Title = "Auto Treatment",
    Description = "Auto full cycle treatment for wards 1 - 5",
    Default = false
})

local AutoCleanSlimeToggle = Tabs.Auto:AddToggle("AutoCleanSlime", {
    Title = "Auto Clean Slime",
    Description = "Auto clean slime when the slime appears",
    Default = false
})

local AutoFixCamToggle = Tabs.Auto:AddToggle("AutoFixCam", {
    Title = "Auto Fix Cam",
    Description = "Auto press camera fix prompts when cameras break",
    Default = false
})

local AutoShutterToggle = Tabs.Auto:AddToggle("AutoShutterOnAnomaly", {
    Title = "Auto Shutter On Anomaly",
    Description = "Auto Close Shutter when Anomaly/Skinwalker is in the counter",
    Default = false
})

local AutoKillAnomalyToggle = Tabs.Auto:AddToggle("AutoKillAnomaly", {
    Title = "Auto Kill Anomaly When Treatment",
    Description = "Auto defend and eliminate anomalies during patient treatment",
    Default = false
})

local AutoHelpPatientToggle = Tabs.Auto:AddToggle("AutoHelpPatient", {
    Title = "Auto Help Patient",
    Description = "Auto assist fallen/distressed patients",
    Default = false
})

-- ══════════════════════════════════════════════════════════════════════════════════
-- 📍 TELEPORT TAB
-- ══════════════════════════════════════════════════════════════════════════
Tabs.Teleport:AddSection("Wards (Beds 1 - 7)")
for i = 1, 6 do
    Tabs.Teleport:AddButton({
        Title = "Ward " .. tostring(i) .. " Bed",
        Callback = function() TeleportTo(Waypoints["Ward" .. tostring(i) .. "_Bed"]) end
    })
end
Tabs.Teleport:AddButton({
    Title = "Ward 7 (ICU / Rabbit)",
    Callback = function() TeleportTo(Waypoints.Ward7_Bed) end
})

Tabs.Teleport:AddSection("Devices / Scanners")
for i = 1, 6 do
    Tabs.Teleport:AddButton({
        Title = "Ward " .. tostring(i) .. " Scanner / Device",
        Callback = function() TeleportTo(Waypoints["Ward" .. tostring(i) .. "_Device"]) end
    })
end

Tabs.Teleport:AddSection("Main Areas")
Tabs.Teleport:AddButton({ Title = "Reception Desk", Callback = function() TeleportTo(Waypoints.Reception) end })
Tabs.Teleport:AddButton({ Title = "Reception Camera", Callback = function() TeleportTo(Waypoints.Reception_Camera) end })
Tabs.Teleport:AddButton({ Title = "Ticket Printer", Callback = function() TeleportTo(Waypoints.Reception_Printer) end })
Tabs.Teleport:AddButton({ Title = "Coffee Machine", Callback = function() TeleportTo(Waypoints.Coffee) end })

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🧰 TOOL TAB (SHELVES)
-- ══════════════════════════════════════════════════════════════════════════
Tabs.Tool:AddSection("Red Shelf")
Tabs.Tool:AddButton({ Title = "Grab Medkit / First Aid", Callback = function() TeleportTo(Waypoints.Med_FirstAid) end })
Tabs.Tool:AddButton({ Title = "Grab Thermometer", Callback = function() TeleportTo(Waypoints.Med_Thermometer) end })

Tabs.Tool:AddSection("Blue Shelf")
Tabs.Tool:AddButton({ Title = "Grab Drops", Callback = function() TeleportTo(Waypoints.Med_Drops) end })
Tabs.Tool:AddButton({ Title = "Grab IV Drip", Callback = function() TeleportTo(Waypoints.Med_IVDrip) end })

Tabs.Tool:AddSection("Green Shelf")
Tabs.Tool:AddButton({ Title = "Grab Herbs", Callback = function() TeleportTo(Waypoints.Med_Herbs) end })
Tabs.Tool:AddButton({ Title = "Grab Pills", Callback = function() TeleportTo(Waypoints.Med_Pills) end })

Tabs.Tool:AddSection("Yellow Shelf")
Tabs.Tool:AddButton({ Title = "Grab Cough Syrup", Callback = function() TeleportTo(Waypoints.Med_Syrup) end })
Tabs.Tool:AddButton({ Title = "Grab Mixture", Callback = function() TeleportTo(Waypoints.Med_Mixture) end })

Tabs.Tool:AddSection("Grey Shelf")
Tabs.Tool:AddButton({ Title = "Grab Bandage", Callback = function() TeleportTo(Waypoints.Med_Bandage) end })
Tabs.Tool:AddButton({ Title = "Grab Plaster", Callback = function() TeleportTo(Waypoints.Med_Plaster) end })

-- ══════════════════════════════════════════════════════════════════════════════════
-- 👁️ VISUAL TAB (ESP)
-- ══════════════════════════════════════════════════════════════════════════
local ESPList = {}
local function UpdateESP()
    for _, hl in pairs(ESPList) do pcall(function() hl:Destroy() end) end
    table.clear(ESPList)

    for _, m in pairs(Workspace:GetDescendants()) do
        if m:IsA("Model") and m ~= LocalPlayer.Character then
            local name = string.lower(m.Name)
            local hum = m:FindFirstChildOfClass("Humanoid")
            local isPlayer = false
            for _, pl in pairs(Players:GetPlayers()) do
                if pl.Character == m then isPlayer = true; break end
            end

            if isPlayer and Options.PlayerESP and Options.PlayerESP.Value then
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(60, 160, 255)
                hl.Adornee = m; hl.Parent = m
                table.insert(ESPList, hl)
            elseif not isPlayer and hum then
                if (SafeFind(name, "skinwalker") or SafeFind(name, "anomaly") or SafeFind(name, "monster")) and Options.AnomalyESP and Options.AnomalyESP.Value then
                    local hl = Instance.new("Highlight")
                    hl.FillColor = Color3.fromRGB(255, 40, 40)
                    hl.Adornee = m; hl.Parent = m
                    table.insert(ESPList, hl)
                elseif Options.PatientESP and Options.PatientESP.Value then
                    local hl = Instance.new("Highlight")
                    hl.FillColor = Color3.fromRGB(80, 240, 120)
                    hl.Adornee = m; hl.Parent = m
                    table.insert(ESPList, hl)
                end
            end
        end
    end
end

Tabs.Visual:AddToggle("PatientESP", { Title = "Patient ESP", Default = false, Callback = UpdateESP })
Tabs.Visual:AddToggle("AnomalyESP", { Title = "Anomaly / Monster ESP", Default = false, Callback = UpdateESP })
Tabs.Visual:AddToggle("PlayerESP", { Title = "Player ESP", Default = false, Callback = UpdateESP })

-- ══════════════════════════════════════════════════════════════════════════════════
-- 👤 USER TAB
-- ══════════════════════════════════════════════════════════════════════════
local WalkSpeedSlider = Tabs.User:AddSlider("WalkSpeed", {
    Title = "WalkSpeed",
    Min = 16,
    Max = 150,
    Default = 16,
    Rounding = 0,
    Callback = function(Value)
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Value end
    end
})

Tabs.User:AddToggle("NoClip", {
    Title = "NoClip",
    Default = false,
    Callback = function(Value)
        local conn
        if Value then
            conn = RunService.Stepped:Connect(function()
                if not Options.NoClip.Value then conn:Disconnect(); return end
                if LocalPlayer.Character then
                    for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end
            end)
        end
    end
})

-- ══════════════════════════════════════════════════════════════════════════════════
-- 📄 MISC TAB
-- ══════════════════════════════════════════════════════════════════════════
Tabs.Misc:AddButton({
    Title = "Hop to Least Players Server",
    Description = "Teleport to the server with fewest active players",
    Callback = function()
        task.spawn(function()
            local success, servers = pcall(function()
                local url = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"
                return HttpService:JSONDecode(game:HttpGet(url))
            end)
            if success and servers and servers.data then
                for _, s in pairs(servers.data) do
                    if type(s) == "table" and s.id ~= game.JobId and (s.playing or 0) > 0 and (s.playing or 0) < (s.maxPlayers or 10) then
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                        return
                    end
                end
            end
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end
})

Tabs.Misc:AddButton({
    Title = "Rejoin Server",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
})

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🚀 BACKGROUND THREADS
-- ══════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(1.0)
        if Options.AutoTreatment and Options.AutoTreatment.Value then
            for w = 1, 5 do
                if not (Options.AutoTreatment and Options.AutoTreatment.Value) then break end
                pcall(function() ProcessWardTreatment(w) end)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(2.0)
        if Options.AutoCheckIn and Options.AutoCheckIn.Value then pcall(ProcessReceptionCheckIn) end
        if Options.AutoCleanSlime and Options.AutoCleanSlime.Value then pcall(CleanSlime) end
        if Options.AutoFixCam and Options.AutoFixCam.Value then pcall(FixCameras) end
        if Options.AutoShutterOnAnomaly and Options.AutoShutterOnAnomaly.Value then pcall(CheckAnomalyShutter) end
    end
end)

task.spawn(function()
    while true do
        task.wait(3.0)
        if Options.KeepSanity and Options.KeepSanity.Value then
            pcall(function()
                TeleportTo(Waypoints.Coffee)
                task.wait(0.3)
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
    end
end)

-- Initialize SaveManager & Select First Tab
pcall(function()
    if SaveManager and InterfaceManager then
        SaveManager:SetLibrary(Fluent)
        InterfaceManager:SetLibrary(Fluent)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({})
        InterfaceManager:SetFolder("FoxnameHub")
        SaveManager:SetFolder("FoxnameHub/AnimalHospital")

        InterfaceManager:BuildInterfaceSection(Tabs.Settings)
        SaveManager:BuildConfigSection(Tabs.Settings)
    end
end)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Foxname Hub",
    Content = "Animal Hospital loaded successfully!",
    Duration = 5
})
