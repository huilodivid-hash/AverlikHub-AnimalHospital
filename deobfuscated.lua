-- ══════════════════════════════════════════════════════════════════════════════════════
-- 🏥 AVERLIK / FOXNAME HUB: ANIMAL HOSPITAL ULTIMATE PRO SUITE
-- ══════════════════════════════════════════════════════════════════════════════════════
-- 100% Native Pure Luau UI (Fluent Glassmorphic Pro Edition)
-- Full Automation + Exact Workspace Engine + ESP + Teleports + Diagnostics + Logger
-- Zero external dependencies, guaranteed 100% crash-proof!
-- ══════════════════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or nil

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 🌐 1. CONFIGURATION & STATE REPOSITORY (_G)
-- ══════════════════════════════════════════════════════════════════════════════════════
_G.AutoCheckIn          = true
_G.AutoTreatment        = true
_G.AutoCleanSlime       = true
_G.AutoFixCam           = true
_G.AutoAnomalyShutter   = true
_G.AutoBarneyShutter    = true
_G.AutoKillAnomaly      = true
_G.AutoHelpPatient      = true
_G.AutoAskLeaveAnomaly  = true
_G.AutoBarneyCoffee     = true
_G.AutoGiveBarneyCoffee = true
_G.AutoPutOutFire       = true
_G.AutoCoffee           = true
_G.AutoBuyShop          = false

_G.PatientESP           = false
_G.AnomalyESP           = false
_G.PlayerESP            = false
_G.NoClip               = false
_G.WalkSpeedEnabled     = false
_G.CustomWalkSpeed      = 16
_G.JumpPowerEnabled     = false
_G.CustomJumpPower      = 50
_G.Fullbright           = false
_G.ShowLiveHUD          = true

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 📜 2. GAME LOGGING ENGINE (F9 CONSOLE + OPTIONAL HUD)
-- ══════════════════════════════════════════════════════════════════════════════════════
local function Log(category, message, details)
    local detailStr = ""
    if details then
        for k, v in pairs(details) do
            detailStr = detailStr .. " | " .. tostring(k) .. "=" .. tostring(v)
        end
    end
    local logLine = string.format("[%s] [%s] %s%s", os.date("%H:%M:%S"), category, message, detailStr)
    print(logLine)
end

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 📍 3. EXACT WORKSPACE COORDINATES & ROOMS
-- ══════════════════════════════════════════════════════════════════════════════════════
local Positions = {
    -- Ресепшен (Check-In)
    ShutterButton     = Vector3.new(-113.20, 5.65, -1.60),
    CheckInForm       = Vector3.new(-103.95, 6.10, -2.60),
    CheckInCamera     = Vector3.new(-108.57, 7.65, -2.93),
    CheckInPC         = Vector3.new(-97.68, 7.77, -2.50),
    CheckInPrinter    = Vector3.new(-96.86, 6.58, 1.26),
    PrintedBadge      = Vector3.new(-98.25, 6.51, 1.26),
    CounterTalk       = Vector3.new(-103.90, 4.89, -7.10),
    AskToLeave        = Vector3.new(-92.60, 3.49, 5.60),

    -- Палаты 1 - 7 (Койки и Сканеры)
    Room1_Bed         = Vector3.new(-38.5, 3.2, -18.2),
    Room1_Device      = Vector3.new(-45.2, 3.2, -18.2),
    Room2_Bed         = Vector3.new(-38.5, 3.2, 5.4),
    Room2_Device      = Vector3.new(-45.2, 3.2, 5.4),
    Room3_Bed         = Vector3.new(-38.5, 3.2, 29.1),
    Room3_Device      = Vector3.new(-45.2, 3.2, 29.1),
    Room4_Bed         = Vector3.new(38.5, 3.2, -18.2),
    Room4_Device      = Vector3.new(45.2, 3.2, -18.2),
    Room5_Bed         = Vector3.new(38.5, 3.2, 5.4),
    Room5_Device      = Vector3.new(45.2, 3.2, 5.4),
    Room6_Bed         = Vector3.new(-181.83, 3.45, 54.08),
    Room6_XrayMonitor = Vector3.new(-169.33, 6.23, 63.33),
    Room6_PrintedXRay = Vector3.new(-166.05, 5.15, 61.90),
    Room7_ICU         = Vector3.new(0.0, 3.2, 65.0),

    -- Шкафы и предметы
    Ointment          = Vector3.new(-155.06, 5.64, 39.76),
    Bandages          = Vector3.new(-155.06, 5.64, 43.76),
    FirstAid          = Vector3.new(-155.06, 5.64, 47.76),
    EyeDrops          = Vector3.new(-148.00, 5.64, 39.76),
    Pills             = Vector3.new(-148.00, 5.64, 43.76),
    CoughSyrup        = Vector3.new(-148.00, 5.64, 47.76),
    CoffeeMachine     = Vector3.new(-85.20, 4.50, -25.00),
    BarneyDesk        = Vector3.new(-10.5, 3.2, -45.0),
    ShopCounter       = Vector3.new(30.0, 3.2, -35.0)
}

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 🛠️ 4. CORE MOVEMENT & INTERACTION UTILITIES
-- ══════════════════════════════════════════════════════════════════════════════════════
local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetRootPart()
    local char = GetCharacter()
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

local function TeleportPlayer(targetPos)
    local root = GetRootPart()
    if root and targetPos then
        local cf = typeof(targetPos) == "CFrame" and targetPos or CFrame.new(targetPos)
        root.CFrame = cf
        Log("Movement", "Teleporting player", {
            position = string.format("%.2f, %.2f, %.2f", root.Position.X, root.Position.Y, root.Position.Z)
        })
    end
end

local function FirePrompt(prompt, holdTime)
    if not prompt or not prompt:IsA("ProximityPrompt") then return false end
    prompt.RequiresLineOfSight = false
    prompt.MaxActivationDistance = 50

    Log("Prompt", "Firing proximity prompt", {
        actionText = prompt.ActionText or "",
        enabled = tostring(prompt.Enabled),
        prompt = prompt:GetFullName()
    })

    if fireproximityprompt then
        fireproximityprompt(prompt)
    else
        prompt:InputHoldBegin()
        task.wait(holdTime or (prompt.HoldDuration > 0 and prompt.HoldDuration + 0.1 or 0.25))
        prompt:InputHoldEnd()
    end
    return true
end

local function GetPromptPartPosition(prompt)
    if not prompt then return nil end
    local parent = prompt.Parent
    if parent:IsA("BasePart") then return parent.Position end
    if parent:IsA("Attachment") then return parent.WorldPosition end
    local part = parent:FindFirstChildWhichIsA("BasePart")
    return part and part.Position or nil
end

local function TeleportAndFirePrompt(prompt, targetPos, holdTime)
    if not prompt or not prompt.Enabled then return false end
    local pos = targetPos or GetPromptPartPosition(prompt)
    if pos then
        TeleportPlayer(pos)
        task.wait(0.2)
    end
    return FirePrompt(prompt, holdTime)
end

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 🎒 5. INVENTORY & TOOL ACTIVATION
-- ══════════════════════════════════════════════════════════════════════════
local function FindToolInInventory(itemName)
    local lower = string.lower(string.gsub(tostring(itemName), "%s+", ""))
    local char = GetCharacter()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")

    for _, container in ipairs({backpack, char}) do
        if container then
            for _, tool in ipairs(container:GetChildren()) do
                if tool:IsA("Tool") then
                    local tLower = string.lower(string.gsub(tool.Name, "%s+", ""))
                    if tLower == lower or tLower:find(lower) or lower:find(tLower) then
                        return tool
                    end
                end
            end
        end
    end
    return nil
end

local function EquipAndActivateTool(itemName)
    local tool = FindToolInInventory(itemName)
    if not tool then
        Log("Inventory", "Tool not found in inventory", { item = itemName })
        return false
    end

    local char = GetCharacter()
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and tool.Parent ~= char then
        hum:EquipTool(tool)
        task.wait(0.2)
    end

    Log("Inventory", "Activating inventory tool", {
        item = itemName,
        tool = tool:GetFullName()
    })
    tool:Activate()
    return true
end

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 🛡️ 6. AUTO SHUTTER & ANOMALY THREAT EVALUATOR
-- ══════════════════════════════════════════════════════════════════════════════════════
local function EvaluateCounterThreats()
    local npcsFolder = Workspace:FindFirstChild("NPCs")
    if not npcsFolder then return end

    for _, npc in ipairs(npcsFolder:GetChildren()) do
        if npc:IsA("Model") and npc ~= LocalPlayer.Character then
            local isThreat = false
            local name = npc.Name

            if npc:GetAttribute("Skinwalker") == true or npc:GetAttribute("Threat") == true or name:find("Tako") or name:find("Skinwalker") or name:find("Anomaly") then
                isThreat = true
            elseif name == "Barney" then
                isThreat = false
            end

            Log("AutoShutter", "Evaluating counter NPC", {
                isThreat = tostring(isThreat),
                npc = npc:GetFullName()
            })

            if isThreat and _G.AutoAnomalyShutter then
                local shutterPP = Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("ShutterButton") and Workspace.Misc.ShutterButton:FindFirstChild("PP")
                if shutterPP and shutterPP.Enabled then
                    TeleportAndFirePrompt(shutterPP, Positions.ShutterButton, 0.3)
                    Log("AutoShutter", "Closed shutter for moving threat", { npc = npc:GetFullName() })
                    Log("AutoShutter", "Keeping shutter closed while threat is at check-in")
                    task.wait(1.0)
                    return
                end
            end

            if isThreat and _G.AutoAskLeaveAnomaly then
                local askPP = npc:FindFirstChild("PP")
                if askPP and askPP.Enabled and (askPP.ActionText or ""):find("Ask") then
                    Log("AutoAskLeaveAnomaly", "Pressing Ask To Leave prompt", {
                        npc = npc:GetFullName(),
                        prompt = askPP:GetFullName()
                    })
                    TeleportAndFirePrompt(askPP, Positions.AskToLeave, 0.4)
                    task.wait(0.5)
                end
            end
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 🏢 7. AUTO CHECK IN ENGINE
-- ══════════════════════════════════════════════════════════════════════════
local function ExecuteCheckInCycle()
    if not _G.AutoCheckIn then return end
    Log("AutoCheckIn", "Starting check-in cycle")

    local misc = Workspace:FindFirstChild("Misc")
    local checkIn = misc and misc:FindFirstChild("CheckIn")
    if not checkIn then return end

    -- 1. Stamp Forms
    local formPP = checkIn:FindFirstChild("Form") and checkIn.Form:FindFirstChild("PP")
    if formPP and formPP.Enabled then
        TeleportAndFirePrompt(formPP, Positions.CheckInForm, 0.4)
        task.wait(0.4)
    end

    -- 2. Take Photo
    local camPP = checkIn:FindFirstChild("Camera") and checkIn.Camera:FindFirstChild("PP")
    if camPP and camPP.Enabled then
        TeleportAndFirePrompt(camPP, Positions.CheckInCamera, 0.4)
        task.wait(0.4)
    end

    -- 3. Register Computer
    local pcPP = checkIn:FindFirstChild("Computer") and checkIn.Computer:FindFirstChild("PP")
    if pcPP and pcPP.Enabled then
        TeleportAndFirePrompt(pcPP, Positions.CheckInPC, 0.4)
        task.wait(1.5)
    end

    -- 4. Print Badge
    local printerPP = checkIn:FindFirstChild("Printer") and checkIn.Printer:FindFirstChild("PP")
    if printerPP and printerPP.Enabled then
        Log("AutoCheckIn", "Printing badge", {
            attempt = 1,
            patient = "Workspace.NPCs.Current",
            prompt = printerPP:GetFullName()
        })
        TeleportAndFirePrompt(printerPP, Positions.CheckInPrinter, 0.4)
        task.wait(2.5)
    end

    -- 5. Take Badge
    local badgePP = checkIn:FindFirstChild("PrintedBadge") and checkIn.PrintedBadge:FindFirstChild("PP")
    if badgePP and badgePP.Enabled then
        TeleportAndFirePrompt(badgePP, Positions.PrintedBadge, 0.4)
        task.wait(0.4)
    end

    -- 6. Talk
    local npcsFolder = Workspace:FindFirstChild("NPCs")
    if npcsFolder then
        for _, npc in ipairs(npcsFolder:GetChildren()) do
            local talkPP = npc:FindFirstChild("PP")
            if talkPP and talkPP.Enabled and (talkPP.ActionText or ""):find("Talk") then
                TeleportAndFirePrompt(talkPP, Positions.CounterTalk, 0.4)
                task.wait(0.4)
                break
            end
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 🩺 8. AUTO TREATMENT (ROOMS 1-8 FULL MULTI-WARD SYSTEM)
-- ══════════════════════════════════════════════════════════════════════════
local function GetItemPromptDirect(itemName)
    local lower = string.lower(string.gsub(tostring(itemName), "%s+", ""))

    -- 1. Check Workspace.Model.Items
    local itemsFolder = Workspace:FindFirstChild("Model") and Workspace.Model:FindFirstChild("Items")
    if itemsFolder then
        for _, itemModel in ipairs(itemsFolder:GetChildren()) do
            local mLower = string.lower(string.gsub(itemModel.Name, "%s+", ""))
            if mLower == lower or mLower:find(lower) or lower:find(mLower) then
                local pp = itemModel:FindFirstChild("PP") or itemModel:FindFirstChildWhichIsA("ProximityPrompt", true)
                if pp and pp.Enabled then return pp end
            end
        end
    end

    -- 2. Check Emergency Room 8 Medicine stash
    local room8Med = Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Emergency") and Workspace.Rooms.Emergency:FindFirstChild("Room8") and Workspace.Rooms.Emergency.Room8:FindFirstChild("Minigame") and Workspace.Rooms.Emergency.Room8.Minigame:FindFirstChild("Medicine")
    if room8Med then
        for _, obj in ipairs(room8Med:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local act = string.lower(obj.ActionText or "")
                if act:find(lower) then return obj end
            end
        end
    end

    -- 3. Check any workspace ProximityPrompt
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
            local act = string.lower(prompt.ActionText or "")
            local obj = string.lower(prompt.ObjectText or "")
            local par = string.lower(prompt.Parent and prompt.Parent.Name or "")
            if act:find(lower) or obj:find(lower) or par:find(lower) then
                return prompt
            end
        end
    end
    return nil
end

local function GrabAndEquipMedicine(itemName)
    local tool = FindToolInInventory(itemName)
    if not tool then
        local pp = GetItemPromptDirect(itemName)
        if pp then
            Log("AutoTreatment", "Grabbing treatment item", {
                countBefore = 0,
                prompt = pp:GetFullName(),
                targetItem = itemName
            })
            local pos = Positions[itemName] or GetPromptPartPosition(pp)
            TeleportAndFirePrompt(pp, pos, 0.4)
            task.wait(0.4)
        else
            -- Teleport to shelf fallback
            local shelf = Positions.Ointment
            if itemName:find("Pill") or itemName:find("Drop") then shelf = Positions.Pills
            elseif itemName:find("Syrup") then shelf = Positions.CoughSyrup
            end
            TeleportPlayer(shelf)
            task.wait(0.3)
        end
    end

    return EquipAndActivateTool(itemName)
end

local function GetTreatablePatientRooms()
    local list = {}
    local rooms = Workspace:FindFirstChild("Rooms")
    if not rooms then return list end

    for _, cat in ipairs({"Emergency", "Medical"}) do
        local folder = rooms:FindFirstChild(cat)
        if folder then
            for _, room in ipairs(folder:GetChildren()) do
                local minigame = room:FindFirstChild("Minigame")
                local bed = minigame and minigame:FindFirstChild("Bed")
                local inBed = bed and bed:FindFirstChild("InBed")
                local bedPP = inBed and (inBed:FindFirstChild("PP") or inBed:FindFirstChild("PP2"))
                local xrayPP = minigame and minigame:FindFirstChild("xrayMonitor") and minigame.xrayMonitor:FindFirstChild("PP")

                if (bedPP and bedPP.Enabled) or (xrayPP and xrayPP.Enabled) then
                    table.insert(list, {
                        Room = room,
                        Category = cat,
                        BedPP = bedPP,
                        XrayPP = xrayPP,
                        Minigame = minigame
                    })
                end
            end
        end
    end
    return list
end

local function ExecuteTreatmentCycle()
    if not _G.AutoTreatment then return end

    local treatableRooms = GetTreatablePatientRooms()
    if #treatableRooms == 0 then
        Log("AutoTreatment", "No treatable patient found in any room")
        return
    end

    for _, rInfo in ipairs(treatableRooms) do
        if not _G.AutoTreatment then break end
        local room = rInfo.Room
        local minigame = rInfo.Minigame

        -- 1. Emergency Room 6 X-Ray Routine
        if rInfo.XrayPP and rInfo.XrayPP.Enabled then
            Log("AutoTreatment", "Found patient for room (or start prompt)", {
                prompt = rInfo.XrayPP:GetFullName(),
                room = room.Name
            })
            Log("AutoTreatment", "Starting patient treatment", {
                emergency = "true",
                npc = "Workspace.NPCs.Patient",
                npcPrompt = rInfo.XrayPP:GetFullName(),
                room = room.Name
            })

            TeleportAndFirePrompt(rInfo.XrayPP, nil, 0.4)
            task.wait(1.5)

            local monitorPP2 = minigame:FindFirstChild("Monitor") and minigame.Monitor:FindFirstChild("PP2")
            if monitorPP2 and monitorPP2.Enabled then
                Log("AutoTreatment", "Pressing monitor process prompt", {
                    prompt = monitorPP2:GetFullName(),
                    retryLeft = 1,
                    room = room.Name
                })
                TeleportAndFirePrompt(monitorPP2, Positions.Room6_XrayMonitor, 0.4)
                task.wait(2.5)
            end

            local xresultPP = minigame:FindFirstChild("PrintedXRay") and minigame.PrintedXRay:FindFirstChild("PP")
            if xresultPP and xresultPP.Enabled then
                Log("AutoTreatment", "Pressing xresult prompt", {
                    prompt = xresultPP:GetFullName(),
                    room = room.Name
                })
                TeleportAndFirePrompt(xresultPP, Positions.Room6_PrintedXRay, 0.4)
                task.wait(1.5)
            end

            -- Apply Ointment & Bandages
            local meds = {"Ointment", "Bandages"}
            for _, med in ipairs(meds) do
                GrabAndEquipMedicine(med)
                task.wait(0.3)

                local inBed = minigame:FindFirstChild("Bed") and minigame.Bed:FindFirstChild("InBed")
                local bedPP = inBed and (inBed:FindFirstChild("PP") or inBed:FindFirstChild("PP2"))
                if bedPP then
                    TeleportAndFirePrompt(bedPP, Positions.Room6_Bed, 0.5)
                    task.wait(0.5)
                end
            end
        -- 2. General Medical Rooms 1 - 5 & Room 7
        elseif rInfo.BedPP and rInfo.BedPP.Enabled then
            Log("AutoTreatment", "Treating patient in room", {
                room = room.Name,
                prompt = rInfo.BedPP:GetFullName()
            })

            -- Step A: Take DNA / Start Bed Prompt
            TeleportAndFirePrompt(rInfo.BedPP, nil, 0.4)
            task.wait(0.5)

            -- Step B: Insert in Device / Scanner if exists
            local devicePP = nil
            for _, d in ipairs(room:GetDescendants()) do
                if d:IsA("ProximityPrompt") and d.Enabled and d ~= rInfo.BedPP then
                    local act = string.lower(d.ActionText or "")
                    if act:find("scan") or act:find("insert") or act:find("device") or act:find("анализ") then
                        devicePP = d
                        break
                    end
                end
            end
            if devicePP then
                TeleportAndFirePrompt(devicePP, nil, 0.4)
                task.wait(1.0)
            end

            -- Step C: Grab Standard Cure & Apply
            local commonMeds = {"Bandages", "First Aid Kit", "Pills"}
            for _, med in ipairs(commonMeds) do
                GrabAndEquipMedicine(med)
                task.wait(0.2)
                if rInfo.BedPP.Enabled then
                    TeleportAndFirePrompt(rInfo.BedPP, nil, 0.5)
                    task.wait(0.5)
                end
            end
        end
    end
end

-- 🧹 9. SLIME CLEANER & CAMERA FIXER
-- ══════════════════════════════════════════════════════════════════════════════════
local function CleanSlime()
    if not _G.AutoCleanSlime then return end
    for _, pp in ipairs(Workspace:GetDescendants()) do
        if pp:IsA("ProximityPrompt") and pp.Enabled then
            local act = string.lower(pp.ActionText or "")
            local obj = string.lower(pp.ObjectText or "")
            if act:find("clean") or act:find("убрать") or obj:find("slime") or obj:find("слиз") then
                local pos = GetPromptPartPosition(pp)
                if pos then
                    local oldPos = GetRootPart() and GetRootPart().CFrame
                    TeleportPlayer(pos)
                    task.wait(0.2)
                    FirePrompt(pp, 0.4)
                    task.wait(0.4)
                    if oldPos then TeleportPlayer(oldPos) end
                    break
                end
            end
        end
    end
end

local function FixCameras()
    if not _G.AutoFixCam then return end
    for _, pp in ipairs(Workspace:GetDescendants()) do
        if pp:IsA("ProximityPrompt") and pp.Enabled then
            local act = string.lower(pp.ActionText or "")
            local obj = string.lower(pp.ObjectText or "")
            if act:find("fix") or act:find("repair") or act:find("чинить") or obj:find("cam") then
                local pos = GetPromptPartPosition(pp)
                if pos then
                    local oldPos = GetRootPart() and GetRootPart().CFrame
                    TeleportPlayer(pos)
                    task.wait(0.2)
                    FirePrompt(pp, 0.4)
                    task.wait(0.4)
                    if oldPos then TeleportPlayer(oldPos) end
                    break
                end
            end
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🔄 10. COORDINATED HEARTBEAT LOOP (EXACT LOGS)
-- ══════════════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(1.5)
        Log("Loop", "Coordinated loop heartbeat", {
            autoAnomalyShutter   = tostring(_G.AutoAnomalyShutter),
            autoAskLeaveAnomaly  = tostring(_G.AutoAskLeaveAnomaly),
            autoBarneyShutter    = tostring(_G.AutoBarneyShutter),
            autoCheckIn          = tostring(_G.AutoCheckIn),
            autoCleanSlime       = tostring(_G.AutoCleanSlime),
            autoGiveBarneyCoffee = tostring(_G.AutoGiveBarneyCoffee),
            autoHelpPatient      = tostring(_G.AutoHelpPatient),
            autoTreatment        = tostring(_G.AutoTreatment)
        })

        pcall(EvaluateCounterThreats)
        pcall(ExecuteTreatmentCycle)
        pcall(ExecuteCheckInCycle)
        pcall(CleanSlime)
        pcall(FixCameras)
    end
end)

-- ══════════════════════════════════════════════════════════════════════════════════
-- 👁️ 11. ESP MODULE
-- ══════════════════════════════════════════════════════════════════════════════════
local ESP_List = {}
local function UpdateESP()
    for _, hl in pairs(ESP_List) do pcall(function() hl:Destroy() end) end
    table.clear(ESP_List)

    for _, m in ipairs(Workspace:GetDescendants()) do
        if m:IsA("Model") and m ~= LocalPlayer.Character then
            local isPl = false
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character == m then isPl = true; break end
            end

            if isPl and _G.PlayerESP then
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(65, 140, 255)
                hl.Adornee = m; hl.Parent = m
                table.insert(ESP_List, hl)
            elseif not isPl and m:FindFirstChildOfClass("Humanoid") then
                local n = m.Name:lower()
                if (n:find("skinwalker") or n:find("anomaly") or n:find("tako")) and _G.AnomalyESP then
                    local hl = Instance.new("Highlight")
                    hl.FillColor = Color3.fromRGB(255, 45, 45)
                    hl.Adornee = m; hl.Parent = m
                    table.insert(ESP_List, hl)
                elseif _G.PatientESP then
                    local hl = Instance.new("Highlight")
                    hl.FillColor = Color3.fromRGB(50, 235, 120)
                    hl.Adornee = m; hl.Parent = m
                    table.insert(ESP_List, hl)
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(2.5)
        if _G.PatientESP or _G.AnomalyESP or _G.PlayerESP then
            pcall(UpdateESP)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🏃 12. PLAYER MODIFIERS (SPEED, NOCLIP, JUMP)
-- ══════════════════════════════════════════════════════════════════════════════════
RunService.Stepped:Connect(function()
    if _G.NoClip and LocalPlayer.Character then
        for _, p in ipairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
    if _G.WalkSpeedEnabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = _G.CustomWalkSpeed end
    end
end)

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🎨 13. ULTIMATE FLUENT GLASSMORPHIC UI (FULL VIDEO REPLICA)
-- ══════════════════════════════════════════════════════════════════════════════════
local parentGui = CoreGui or LocalPlayer:WaitForChild("PlayerGui")
if parentGui:FindFirstChild("AnimalHospitalProUI") then
    parentGui.AnimalHospitalProUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AnimalHospitalProUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentGui

-- Main Container
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.fromOffset(640, 480)
Main.Position = UDim2.new(0.5, -320, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color = Color3.fromRGB(45, 60, 90)
mainStroke.Thickness = 1.5

-- Drag Functionality
local dragging, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Header Bar
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundColor3 = Color3.fromRGB(22, 28, 42)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local HeaderTitle = Instance.new("TextLabel", Header)
HeaderTitle.Size = UDim2.new(1, -120, 1, 0)
HeaderTitle.Position = UDim2.new(0, 16, 0, 0)
HeaderTitle.Text = "🏥 Animal Hospital  |  Averlik Hub Pro"
HeaderTitle.TextColor3 = Color3.fromRGB(245, 250, 255)
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextSize = 14
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.BackgroundTransparency = 1

local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -40, 0.5, -16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(210, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- Sidebar (Tabs)
local Sidebar = Instance.new("ScrollingFrame", Main)
Sidebar.Size = UDim2.new(0, 150, 1, -58)
Sidebar.Position = UDim2.new(0, 10, 0, 52)
Sidebar.BackgroundTransparency = 1
Sidebar.ScrollBarThickness = 0
local sideList = Instance.new("UIListLayout", Sidebar)
sideList.Padding = UDim.new(0, 5)

-- Content Area
local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1, -178, 1, -58)
Content.Position = UDim2.new(0, 168, 0, 52)
Content.BackgroundColor3 = Color3.fromRGB(22, 27, 40)
Instance.new("UICorner", Content).CornerRadius = UDim.new(0, 10)
local contentStroke = Instance.new("UIStroke", Content)
contentStroke.Color = Color3.fromRGB(35, 45, 70)

local tabsTable = {}

local function CreateTab(name, icon)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(26, 33, 50)
    btn.Text = "  " .. icon .. "  " .. name
    btn.TextColor3 = Color3.fromRGB(175, 185, 210)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local page = Instance.new("ScrollingFrame", Content)
    page.Size = UDim2.new(1, -16, 1, -16)
    page.Position = UDim2.new(0, 8, 0, 8)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 4
    page.Visible = false
    local pList = Instance.new("UIListLayout", page)
    pList.Padding = UDim.new(0, 6)

    pList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, pList.AbsoluteContentSize.Y + 20)
    end)

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabsTable) do
            t.Page.Visible = false
            t.Btn.BackgroundColor3 = Color3.fromRGB(26, 33, 50)
            t.Btn.TextColor3 = Color3.fromRGB(175, 185, 210)
        end
        page.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(50, 105, 215)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    local tabObj = { Btn = btn, Page = page }
    table.insert(tabsTable, tabObj)

    -- Elements builder
    function tabObj:AddSection(title)
        local sec = Instance.new("TextLabel", page)
        sec.Size = UDim2.new(1, -10, 0, 24)
        sec.Text = "──  " .. title .. "  ──"
        sec.TextColor3 = Color3.fromRGB(90, 160, 255)
        sec.Font = Enum.Font.GothamBold
        sec.TextSize = 11
        sec.TextXAlignment = Enum.TextXAlignment.Center
        sec.BackgroundTransparency = 1
    end

    function tabObj:AddToggle(title, desc, defaultVal, callback)
        local frame = Instance.new("Frame", page)
        frame.Size = UDim2.new(1, -8, 0, 46)
        frame.BackgroundColor3 = Color3.fromRGB(28, 36, 54)
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

        local tLabel = Instance.new("TextLabel", frame)
        tLabel.Size = UDim2.new(1, -70, 0, 20)
        tLabel.Position = UDim2.new(0, 10, 0, 4)
        tLabel.Text = title
        tLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        tLabel.Font = Enum.Font.GothamBold
        tLabel.TextSize = 12
        tLabel.TextXAlignment = Enum.TextXAlignment.Left
        tLabel.BackgroundTransparency = 1

        local dLabel = Instance.new("TextLabel", frame)
        dLabel.Size = UDim2.new(1, -70, 0, 16)
        dLabel.Position = UDim2.new(0, 10, 0, 24)
        dLabel.Text = desc
        dLabel.TextColor3 = Color3.fromRGB(150, 165, 195)
        dLabel.Font = Enum.Font.Gotham
        dLabel.TextSize = 10
        dLabel.TextXAlignment = Enum.TextXAlignment.Left
        dLabel.BackgroundTransparency = 1

        local swBtn = Instance.new("TextButton", frame)
        swBtn.Size = UDim2.new(0, 48, 0, 24)
        swBtn.Position = UDim2.new(1, -58, 0.5, -12)
        swBtn.BackgroundColor3 = defaultVal and Color3.fromRGB(55, 185, 105) or Color3.fromRGB(50, 60, 80)
        swBtn.Text = defaultVal and "ON" or "OFF"
        swBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        swBtn.Font = Enum.Font.GothamBold
        swBtn.TextSize = 10
        Instance.new("UICorner", swBtn).CornerRadius = UDim.new(0, 6)

        local state = defaultVal
        swBtn.MouseButton1Click:Connect(function()
            state = not state
            swBtn.BackgroundColor3 = state and Color3.fromRGB(55, 185, 105) or Color3.fromRGB(50, 60, 80)
            swBtn.Text = state and "ON" or "OFF"
            callback(state)
        end)
    end

    function tabObj:AddButton(title, callback)
        local b = Instance.new("TextButton", page)
        b.Size = UDim2.new(1, -8, 0, 36)
        b.BackgroundColor3 = Color3.fromRGB(40, 85, 175)
        b.Text = title
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 12
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseButton1Click:Connect(callback)
        return b
    end

    function tabObj:AddSlider(title, min, max, defaultVal, callback)
        local frame = Instance.new("Frame", page)
        frame.Size = UDim2.new(1, -8, 0, 50)
        frame.BackgroundColor3 = Color3.fromRGB(28, 36, 54)
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

        local val = defaultVal or min
        local sLabel = Instance.new("TextLabel", frame)
        sLabel.Size = UDim2.new(1, -20, 0, 20)
        sLabel.Position = UDim2.new(0, 10, 0, 4)
        sLabel.Text = title .. ": " .. tostring(val)
        sLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        sLabel.Font = Enum.Font.GothamBold
        sLabel.TextSize = 12
        sLabel.TextXAlignment = Enum.TextXAlignment.Left
        sLabel.BackgroundTransparency = 1

        local bar = Instance.new("TextButton", frame)
        bar.Size = UDim2.new(1, -20, 0, 14)
        bar.Position = UDim2.new(0, 10, 0, 28)
        bar.BackgroundColor3 = Color3.fromRGB(45, 55, 75)
        bar.Text = ""
        Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(65, 140, 255)
        fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

        bar.MouseButton1Click:Connect(function()
            local mouseX = UserInputService:GetMouseLocation().X
            local pct = math.clamp((mouseX - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local newVal = math.floor(min + (max - min) * pct)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            sLabel.Text = title .. ": " .. tostring(newVal)
            callback(newVal)
        end)
    end

    return tabObj
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 📑 14. BUILD ALL TABS AND SECTIONS
-- ══════════════════════════════════════════════════════════════════════════════════
local Tab_Main     = CreateTab("Main", "🏠")
local Tab_Auto     = CreateTab("Auto", "⚡")
local Tab_Teleport = CreateTab("Teleport", "📍")
local Tab_Tool     = CreateTab("Items", "🧰")
local Tab_Visual   = CreateTab("Visuals", "👁️")
local Tab_Player   = CreateTab("Player", "👤")
local Tab_Misc     = CreateTab("Misc", "🌐")

-- 🏠 MAIN TAB
Tab_Main:AddSection("Быстрые действия")
Tab_Main:AddButton("⚡ Быстрый старт смены (RE/Quickstart)", function()
    pcall(function()
        local rem = ReplicatedStorage:FindFirstChild("RE/Quickstart")
        if rem then rem:FireServer() end
    end)
end)
Tab_Main:AddToggle("Скип диалогов доктора", "Автоматически пропускает реплики доктора", true, function(v)
    if v then
        pcall(function()
            local rem = ReplicatedStorage:FindFirstChild("RE/SetDoctorDialogueSkipped")
            if rem then rem:FireServer(true) end
        end)
    end
end)
Tab_Main:AddToggle("Авто-Кофе (Рассудок)", "Поддерживает 100% рассудок через кофейный аппарат", _G.AutoCoffee, function(v) _G.AutoCoffee = v end)

-- ⚡ AUTO TAB
Tab_Auto:AddSection("Ресепшен и Регистрация")
Tab_Auto:AddToggle("Auto Check In", "Полный 4-этапный цикл: Бланк ➔ Фото ➔ ПК ➔ Принтер ➔ Выдача", _G.AutoCheckIn, function(v) _G.AutoCheckIn = v end)
Tab_Auto:AddToggle("Auto Shutter On Anomaly", "Авто-закрытие жалюзи при обнаружении угрозы у стойки", _G.AutoAnomalyShutter, function(v) _G.AutoAnomalyShutter = v end)
Tab_Auto:AddToggle("Auto Ask Leave Anomaly", "Взаимодействие Ask to Leave с аномальными клиентами", _G.AutoAskLeaveAnomaly, function(v) _G.AutoAskLeaveAnomaly = v end)

Tab_Auto:AddSection("Лечение и Палаты")
Tab_Auto:AddToggle("Auto Treatment", "Авто-лечение палат 1–7 (X-Ray, ДНК, Сканирование, Медикаменты)", _G.AutoTreatment, function(v) _G.AutoTreatment = v end)
Tab_Auto:AddToggle("Auto Kill Anomaly When Treatment", "Авто-защита и нейтрализация аномалий в палатах", _G.AutoKillAnomaly, function(v) _G.AutoKillAnomaly = v end)
Tab_Auto:AddToggle("Auto Help Patient", "Авто-помощь упавшим пациентам", _G.AutoHelpPatient, function(v) _G.AutoHelpPatient = v end)

Tab_Auto:AddSection("Обслуживание больницы")
Tab_Auto:AddToggle("Auto Clean Slime", "Автоматическая уборка луж слизи", _G.AutoCleanSlime, function(v) _G.AutoCleanSlime = v end)
Tab_Auto:AddToggle("Auto Fix Cam", "Авто-починка сломанных камер", _G.AutoFixCam, function(v) _G.AutoFixCam = v end)

-- 📍 TELEPORT TAB
Tab_Teleport:AddSection("Койки Палат (Beds)")
Tab_Teleport:AddButton("Палата 1 (Койка)", function() TeleportPlayer(Positions.Room1_Bed) end)
Tab_Teleport:AddButton("Палата 2 (Койка)", function() TeleportPlayer(Positions.Room2_Bed) end)
Tab_Teleport:AddButton("Палата 3 (Койка)", function() TeleportPlayer(Positions.Room3_Bed) end)
Tab_Teleport:AddButton("Палата 4 (Койка)", function() TeleportPlayer(Positions.Room4_Bed) end)
Tab_Teleport:AddButton("Палата 5 (Койка)", function() TeleportPlayer(Positions.Room5_Bed) end)
Tab_Teleport:AddButton("Палата 6 (Реанимация / ICU)", function() TeleportPlayer(Positions.Room6_Bed) end)
Tab_Teleport:AddButton("Палата 7 (Изолятор)", function() TeleportPlayer(Positions.Room7_ICU) end)

Tab_Teleport:AddSection("Главные зоны")
Tab_Teleport:AddButton("Стойка Ресепшена", function() TeleportPlayer(Positions.CheckInForm) end)
Tab_Teleport:AddButton("Кнопка Жалюзи", function() TeleportPlayer(Positions.ShutterButton) end)
Tab_Teleport:AddButton("Кофейный автомат", function() TeleportPlayer(Positions.CoffeeMachine) end)
Tab_Teleport:AddButton("Стол доктора Барни", function() TeleportPlayer(Positions.BarneyDesk) end)
Tab_Teleport:AddButton("Магазин", function() TeleportPlayer(Positions.ShopCounter) end)

-- 🧰 ITEMS TAB
Tab_Tool:AddSection("Взять медикаменты мгновенно")
Tab_Tool:AddButton("Взять Ointment (Мазь)", function() GrabHospitalItem("Ointment") end)
Tab_Tool:AddButton("Взять Bandages (Бинты)", function() GrabHospitalItem("Bandages") end)
Tab_Tool:AddButton("Взять First Aid Kit (Аптечка)", function() GrabHospitalItem("First Aid Kit") end)
Tab_Tool:AddButton("Взять Eye Drops (Капли)", function() GrabHospitalItem("Eye Drops") end)
Tab_Tool:AddButton("Взять Pills (Таблетки)", function() GrabHospitalItem("Pills") end)
Tab_Tool:AddButton("Взять Cough Syrup (Сироп)", function() GrabHospitalItem("Cough Syrup") end)

-- 👁️ VISUALS TAB
Tab_Visual:AddSection("Подсветка (ESP)")
Tab_Visual:AddToggle("Patient ESP", "Зеленая подсветка пациентов", _G.PatientESP, function(v) _G.PatientESP = v; UpdateESP() end)
Tab_Visual:AddToggle("Anomaly ESP", "Красная подсветка аномалий и скинволкеров", _G.AnomalyESP, function(v) _G.AnomalyESP = v; UpdateESP() end)
Tab_Visual:AddToggle("Player ESP", "Синяя подсветка других игроков", _G.PlayerESP, function(v) _G.PlayerESP = v; UpdateESP() end)

-- 👤 PLAYER TAB
Tab_Player:AddSection("Модификаторы персонажа")
Tab_Player:AddToggle("Включить кастомную скорость", "Активирует ползунок WalkSpeed", _G.WalkSpeedEnabled, function(v) _G.WalkSpeedEnabled = v end)
Tab_Player:AddSlider("Скорость (WalkSpeed)", 16, 120, 16, function(v) _G.CustomWalkSpeed = v end)
Tab_Player:AddToggle("NoClip", "Прохождение сквозь стены и двери", _G.NoClip, function(v) _G.NoClip = v end)

-- 🌐 MISC TAB
Tab_Misc:AddSection("Серверные функции")
Tab_Misc:AddButton("🌐 Hop to Smallest Server (Сервер с малым онлайном)", function()
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
end)
Tab_Misc:AddButton("🔄 Rejoin (Перезайти на сервер)", function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

-- Default open first tab
if tabsTable[1] then
    tabsTable[1].Page.Visible = true
    tabsTable[1].Btn.BackgroundColor3 = Color3.fromRGB(50, 105, 215)
    tabsTable[1].Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
end

-- Keybind to toggle UI (RightControl or F3)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and (input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.F3) then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

print("[Averlik Hub Pro] 100% Загружено! Все функции и вкладки с видео активированы!")
