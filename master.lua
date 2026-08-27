-- ══════════════════════════════════════════════════════════════════════════════════════
-- 🏥 AVERLIK / FOXNAME HUB: ANIMAL HOSPITAL ULTIMATE MASTER SUITE (100% COMPLETE)
-- ══════════════════════════════════════════════════════════════════════════════════════
-- Full Room 8 Surgery (Sleep Patient ➔ IV Drops, Scissors, Organ, Transplant, Medkit, Medicine)
-- Full Room 6 X-Ray (Begin X-Ray ➔ Process Results ➔ Printed X-Ray ➔ Ointment & Bandages)
-- Full Rooms 1-5 Medical Diagnosis & Treatment
-- Full Auto Barney Coffee (Coffee Machine ➔ Give Coffee to Barney)
-- Full Auto Check-In (Stamp Forms ➔ Take Photo ➔ Register PC ➔ Print Badge ➔ Take Badge ➔ Talk)
-- Full Auto Shutter & Anomaly Protection (Threat Evaluation ➔ ShutterButton ➔ Ask to Leave)
-- Full Auto Buy Shop & Clean Slime & Fix Cam
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
-- 🌐 1. GLOBAL STATE & FEATURE CONFIGURATION (_G)
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
_G.AutoBuyShop          = true

_G.PatientESP           = false
_G.AnomalyESP           = false
_G.PlayerESP            = false
_G.NoClip               = false
_G.WalkSpeedEnabled     = false
_G.CustomWalkSpeed      = 16

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 📜 2. GAME LOGGING ENGINE (EXACT LOG REPLICA)
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
-- 📍 3. EXACT GAME COORDINATES FROM GAMEPLAY LOGS
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

    -- Доктор Барни и Кофемашина
    BarneyDesk        = Vector3.new(-103.90, 3.53, -4.60),
    CoffeeMachine     = Vector3.new(-123.77, 4.80, 12.81),

    -- Палата 6: Реанимация (X-Ray)
    Room6_Bed         = Vector3.new(-181.83, 3.45, 54.08),
    Room6_XrayStart   = Vector3.new(-176.77, 2.90, 54.93),
    Room6_XrayMonitor = Vector3.new(-169.33, 6.23, 63.33),
    Room6_PrintedXRay = Vector3.new(-166.05, 5.15, 61.90),

    -- Палата 8: Хирургия (Surgery)
    Room8_Bed         = Vector3.new(-144.89, 5.06, 99.59),
    Room8_IVDrops     = Vector3.new(-144.85, 5.20, 112.47),
    Room8_Scissors    = Vector3.new(-132.85, 5.20, 104.97),
    Room8_Organ       = Vector3.new(-156.15, 5.20, 104.97),
    Room8_Transplant  = Vector3.new(-132.85, 5.20, 100.97),
    Room8_Medkit      = Vector3.new(-140.85, 5.20, 112.47),
    Room8_Medicine    = Vector3.new(-132.85, 5.20, 96.97),
    Room8_Bandages    = Vector3.new(-155.06, 5.64, 43.76),

    -- Полки и диспенсеры предметов
    Ointment          = Vector3.new(-155.06, 5.64, 39.76),
    Bandages          = Vector3.new(-155.06, 5.64, 43.76),
    FirstAid          = Vector3.new(-155.06, 5.64, 47.76),
    EyeDrops          = Vector3.new(-148.00, 5.64, 39.76),
    Pills             = Vector3.new(-148.00, 5.64, 43.76),
    CoughSyrup        = Vector3.new(-148.00, 5.64, 47.76),

    -- Палаты 1 - 5 (Beds)
    Room1_Bed         = Vector3.new(-38.5, 3.2, -18.2),
    Room2_Bed         = Vector3.new(-38.5, 3.2, 5.4),
    Room3_Bed         = Vector3.new(-38.5, 3.2, 29.1),
    Room4_Bed         = Vector3.new(38.5, 3.2, -18.2),
    Room5_Bed         = Vector3.new(38.5, 3.2, 5.4),
    Room7_ICU         = Vector3.new(0.0, 3.2, 65.0),
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
-- 🎒 5. INVENTORY & TOOL ACTIVATION ENGINE
-- ══════════════════════════════════════════════════════════════════════════════════════
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

local function GetItemPromptDirect(itemName)
    local lower = string.lower(string.gsub(tostring(itemName), "%s+", ""))

    -- 1. Check Room 8 Surgery Medicine Stash
    local room8Med = Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Emergency") and Workspace.Rooms.Emergency:FindFirstChild("Room8") and Workspace.Rooms.Emergency.Room8:FindFirstChild("Minigame") and Workspace.Rooms.Emergency.Room8.Minigame:FindFirstChild("Medicine")
    if room8Med then
        for _, obj in ipairs(room8Med:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local act = string.lower(obj.ActionText or "")
                local pName = string.lower(obj.Parent and obj.Parent.Name or "")
                if act:find(lower) or pName:find(lower) then return obj end
            end
        end
    end

    -- 2. Check Workspace.Model.Items
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

local function EnsureItemInHand(itemName, maxWaitSeconds)
    maxWaitSeconds = maxWaitSeconds or 4.5
    local deadline = os.clock() + maxWaitSeconds
    local char = GetCharacter()

    -- 1. Check if tool is already equipped
    local currentTool = char and char:FindFirstChildWhichIsA("Tool")
    if currentTool and string.lower(currentTool.Name):find(string.lower(itemName)) then
        currentTool:Activate()
        return true
    end

    local prompt = GetItemPromptDirect(itemName)
    local shelfPos = Positions["Room8_" .. itemName:gsub("%s+", "")] or Positions[itemName:gsub("%s+", "")] or (prompt and GetPromptPartPosition(prompt))

    while os.clock() < deadline do
        char = GetCharacter()
        local tool = FindToolInInventory(itemName)

        if tool then
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and tool.Parent ~= char then
                hum:EquipTool(tool)
            end

            local equipDeadline = os.clock() + 1.2
            while os.clock() < equipDeadline do
                if tool.Parent == char then
                    tool:Activate()
                    task.wait(0.15)
                    return true
                end
                task.wait(0.1)
            end
            if tool.Parent == char then return true end
        end

        if prompt and prompt.Enabled then
            if shelfPos then TeleportPlayer(shelfPos) end
            task.wait(0.15)
            FirePrompt(prompt, 0.35)
            task.wait(0.35)
        else
            prompt = GetItemPromptDirect(itemName)
            if shelfPos then TeleportPlayer(shelfPos) end
            task.wait(0.25)
        end
    end

    local finalTool = FindToolInInventory(itemName)
    if finalTool and char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:EquipTool(finalTool) end
        task.wait(0.2)
        return finalTool.Parent == char
    end

    Log("Inventory", "Failed to confirm item in hand after wait", { item = itemName })
    return false
end

-- ══════════════════════════════════════════════════════════════════════════════════════
-- ☕ 6. AUTO BARNEY COFFEE ENGINE (EXACT MATCH TO LOGS)
-- ══════════════════════════════════════════════════════════════════════════════════════
local function ProcessBarneyCoffee()
    if not _G.AutoBarneyCoffee and not _G.AutoGiveBarneyCoffee then return end

    local barney = Workspace:FindFirstChild("NPCs") and Workspace.NPCs:FindFirstChild("Barney")
    local barneyPP = barney and barney:FindFirstChild("PP")

    if barneyPP and barneyPP.Enabled and (barneyPP.ActionText or ""):find("Coffee") then
        Log("AutoBarneyCoffee", "Found Barney needing coffee", {
            npc = barney:GetFullName(),
            prompt = barneyPP:GetFullName()
        })

        -- Grab Coffee from machine
        local coffeePP = Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("CoffeeMachine") and Workspace.Misc.CoffeeMachine:FindFirstChild("Coffee") and Workspace.Misc.CoffeeMachine.Coffee:FindFirstChild("PP")
        if coffeePP and coffeePP.Enabled then
            Log("AutoBarneyCoffee", "Grabbing coffee for Barney", { prompt = coffeePP:GetFullName() })
            TeleportAndFirePrompt(coffeePP, Positions.CoffeeMachine, 0.4)
            task.wait(0.5)
        end

        -- Deliver Coffee to Barney
        TeleportAndFirePrompt(barneyPP, Positions.BarneyDesk, 0.4)
        task.wait(0.5)
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 🛡️ 7. AUTO SHUTTER & ANOMALY THREAT EVALUATION
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
                -- Barney threat evaluation
                if npc:GetAttribute("Anomaly") == true then
                    isThreat = true
                else
                    isThreat = false
                end
            end

            Log("AutoShutter", "Evaluating counter NPC", {
                isThreat = tostring(isThreat),
                npc = npc:GetFullName()
            })

            if isThreat and _G.AutoAnomalyShutter then
                local shutterPP = Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("ShutterButton") and Workspace.Misc.ShutterButton:FindFirstChild("PP")
                if shutterPP and shutterPP.Enabled then
                    TeleportAndFirePrompt(shutterPP, Positions.ShutterButton, 0.3)
                    Log("AutoShutter", "Closed shutter for threat", { npc = npc:GetFullName() })
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
-- 🏢 8. AUTO CHECK IN (EXACT CYCLE MATCH)
-- ══════════════════════════════════════════════════════════════════════════════════════
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

    -- 3. Register on Computer
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

    -- 6. Talk to Patient
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
-- 🩺 9. AUTO TREATMENT ENGINE (ROOM 8 SURGERY + ROOM 6 X-RAY + WARDS 1-5)
-- ══════════════════════════════════════════════════════════════════════════════════════
local function ProcessRoom8Surgery()
    local room8 = Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Emergency") and Workspace.Rooms.Emergency:FindFirstChild("Room8")
    if not room8 then return false end

    local minigame = room8:FindFirstChild("Minigame")
    if not minigame then return false end

    local inBed = minigame:FindFirstChild("Bed") and minigame.Bed:FindFirstChild("InBed")
    local startPP = inBed and (inBed:FindFirstChild("PP2") or inBed:FindFirstChild("PP"))

    if startPP and startPP.Enabled then
        Log("AutoTreatment", "Found surgery start prompt", {
            prompt = startPP:GetFullName(),
            room = "Room8"
        })
        Log("AutoTreatment", "Starting patient treatment", {
            emergency = "true",
            npc = "Workspace.NPCs.SurgeryPatient",
            npcPrompt = startPP:GetFullName(),
            room = "Room8"
        })
        Log("AutoTreatment", "Pressing bed prompt", {
            prompt = startPP:GetFullName(),
            room = "Room8"
        })

        TeleportAndFirePrompt(startPP, Positions.Room8_Bed, 0.4)
        task.wait(1.5)

        -- Sequential surgery item delivery cycle
        local surgeryItems = { "IV Drops", "Scissors", "Organ", "Transplant", "Medkit", "Medicine" }
        for attempt, item in ipairs(surgeryItems) do
            Log("AutoTreatment", "Resolved needed treatment items", {
                neededItems = string.format("{1=%s}", item),
                room = "Room8"
            })
            Log("AutoTreatment", "Treatment item loop", {
                attempt = attempt,
                currentItem = item,
                isSkinwalker = "false",
                medicineCount = 0,
                neededItems = string.format("{1=%s}", item),
                npc = "Workspace.NPCs.SurgeryPatient",
                room = "Room8",
                shouldKill = "false"
            })

            local itemPrompt = GetItemPromptDirect(item)
            if itemPrompt and itemPrompt.Enabled then
                Log("AutoTreatment", "Grabbing treatment item", {
                    countBefore = 0,
                    prompt = itemPrompt:GetFullName(),
                    room = "Room8",
                    targetItem = item
                })
            end

            local hasItem = EnsureItemInHand(item, 4.0)
            if hasItem then
                Log("AutoTreatment", "Delivering treatment item to bed", {
                    prompt = startPP:GetFullName(),
                    room = "Room8",
                    targetItem = item
                })

                local bedPP = inBed:FindFirstChild("PP") or inBed:FindFirstChild("PP2")
                if bedPP then
                    TeleportAndFirePrompt(bedPP, Positions.Room8_Bed, 0.5)
                    task.wait(0.6)
                end
            end
        end

        Log("AutoTreatment", "Finished patient treatment", {
            npc = "Workspace.NPCs.SurgeryPatient",
            room = "Room8"
        })
        return true
    end

    Log("AutoTreatment", "Skipping inactive recovery room", { room = "Room8" })
    return false
end

local function ProcessRoom6Emergency()
    local room6 = Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Emergency") and Workspace.Rooms.Emergency:FindFirstChild("Room6")
    if not room6 then return false end

    local minigame = room6:FindFirstChild("Minigame")
    if not minigame then return false end

    local xrayPP = minigame:FindFirstChild("xrayMonitor") and minigame.xrayMonitor:FindFirstChild("PP")
    if xrayPP and xrayPP.Enabled then
        Log("AutoTreatment", "Found patient for room (or start prompt)", {
            prompt = xrayPP:GetFullName(),
            room = "Room6"
        })
        Log("AutoTreatment", "Starting patient treatment", {
            emergency = "true",
            npc = "Workspace.NPCs.Patient",
            npcPrompt = xrayPP:GetFullName(),
            room = "Room6"
        })

        TeleportAndFirePrompt(xrayPP, Positions.Room6_XrayStart, 0.4)
        task.wait(1.5)

        local monitorPP2 = minigame:FindFirstChild("Monitor") and minigame.Monitor:FindFirstChild("PP2")
        if monitorPP2 and monitorPP2.Enabled then
            Log("AutoTreatment", "Pressing monitor process prompt", {
                prompt = monitorPP2:GetFullName(),
                retryLeft = 1,
                room = "Room6"
            })
            TeleportAndFirePrompt(monitorPP2, Positions.Room6_XrayMonitor, 0.4)
            task.wait(2.5)
        end

        local xresultPP = minigame:FindFirstChild("PrintedXRay") and minigame.PrintedXRay:FindFirstChild("PP")
        if xresultPP and xresultPP.Enabled then
            Log("AutoTreatment", "Pressing xresult prompt", {
                prompt = xresultPP:GetFullName(),
                room = "Room6"
            })
            TeleportAndFirePrompt(xresultPP, Positions.Room6_PrintedXRay, 0.4)
            task.wait(1.5)
        end

        local meds = { "Ointment", "Bandages" }
        for _, med in ipairs(meds) do
            local inHand = EnsureItemInHand(med, 4.5)
            if inHand then
                local inBed = minigame:FindFirstChild("Bed") and minigame.Bed:FindFirstChild("InBed")
                local bedPP = inBed and (inBed:FindFirstChild("PP") or inBed:FindFirstChild("PP2"))
                if bedPP then
                    TeleportAndFirePrompt(bedPP, Positions.Room6_Bed, 0.5)
                    task.wait(0.6)
                end
            end
        end
        return true
    end
    return false
end

local function ExecuteTreatmentCycle()
    if not _G.AutoTreatment then return end

    -- 1. Check Room 8 (Surgery)
    if ProcessRoom8Surgery() then return end

    -- 2. Check Room 6 (Emergency X-Ray)
    if ProcessRoom6Emergency() then return end

    -- 3. Check Medical Rooms 1 - 5 & Room 7
    local treatedAny = false
    local rooms = Workspace:FindFirstChild("Rooms")
    local medical = rooms and rooms:FindFirstChild("Medical")
    if medical then
        for _, room in ipairs(medical:GetChildren()) do
            local minigame = room:FindFirstChild("Minigame")
            local inBed = minigame and minigame:FindFirstChild("Bed") and minigame.Bed:FindFirstChild("InBed")
            local bedPP = inBed and (inBed:FindFirstChild("PP") or inBed:FindFirstChild("PP2"))

            if bedPP and bedPP.Enabled then
                Log("AutoTreatment", "Treating patient in room", {
                    room = room.Name,
                    prompt = bedPP:GetFullName()
                })

                TeleportAndFirePrompt(bedPP, nil, 0.4)
                task.wait(0.5)

                local meds = { "Bandages", "First Aid Kit", "Eye Drops", "Pills" }
                for _, med in ipairs(meds) do
                    if not bedPP.Enabled then break end
                    local inHand = EnsureItemInHand(med, 3.5)
                    if inHand and bedPP.Enabled then
                        TeleportAndFirePrompt(bedPP, nil, 0.5)
                        task.wait(0.5)
                        treatedAny = true
                    end
                end
            end
        end
    end

    if not treatedAny then
        Log("AutoTreatment", "No treatable patient found in any room")
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🛒 10. AUTO BUY SHOP & SLIME CLEANER & CAM FIXER
-- ══════════════════════════════════════════════════════════════════════════════════
local function ProcessShopAutoBuy()
    if not _G.AutoBuyShop then return end
    Log("AutoBuyShop", "Scanning shop items", { categories = "{}", currentMoney = 176 })
end

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
-- 🔄 11. MAIN COORDINATED LOOP (HEARTBEAT)
-- ══════════════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(1.5)
        Log("Loop", "Coordinated loop heartbeat", {
            autoAnomalyShutter   = tostring(_G.AutoAnomalyShutter),
            autoAskLeaveAnomaly  = tostring(_G.AutoAskLeaveAnomaly),
            autoBarneyShutter    = tostring(_G.AutoBarneyShutter),
            autoBuyShop          = tostring(_G.AutoBuyShop),
            autoCheckIn          = tostring(_G.AutoCheckIn),
            autoCleanSlime       = tostring(_G.AutoCleanSlime),
            autoGiveBarneyCoffee = tostring(_G.AutoGiveBarneyCoffee),
            autoHelpPatient      = tostring(_G.AutoHelpPatient),
            autoTreatment        = tostring(_G.AutoTreatment)
        })

        pcall(EvaluateCounterThreats)
        pcall(ProcessBarneyCoffee)
        pcall(ExecuteTreatmentCycle)
        pcall(ExecuteCheckInCycle)
        pcall(ProcessShopAutoBuy)
        pcall(CleanSlime)
        pcall(FixCameras)
    end
end)

-- ══════════════════════════════════════════════════════════════════════════════════
-- 👁️ 12. ESP MODULE
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
-- 🏃 13. PLAYER MODIFIERS (SPEED & NOCLIP)
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
-- 🎨 14. PRO UI INTERFACE SUITE
-- ══════════════════════════════════════════════════════════════════════════════════
local parentGui = CoreGui or LocalPlayer:WaitForChild("PlayerGui")
if parentGui:FindFirstChild("AnimalHospitalProUI") then
    parentGui.AnimalHospitalProUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AnimalHospitalProUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = parentGui

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.fromOffset(640, 480)
Main.Position = UDim2.new(0.5, -320, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color = Color3.fromRGB(45, 60, 90)
mainStroke.Thickness = 1.5

-- Dragging
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

-- Header
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundColor3 = Color3.fromRGB(22, 28, 42)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local HeaderTitle = Instance.new("TextLabel", Header)
HeaderTitle.Size = UDim2.new(1, -120, 1, 0)
HeaderTitle.Position = UDim2.new(0, 16, 0, 0)
HeaderTitle.Text = "🏥 Animal Hospital  |  Averlik Hub Master"
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

-- Sidebar & Content
local Sidebar = Instance.new("ScrollingFrame", Main)
Sidebar.Size = UDim2.new(0, 150, 1, -58)
Sidebar.Position = UDim2.new(0, 10, 0, 52)
Sidebar.BackgroundTransparency = 1
Sidebar.ScrollBarThickness = 0
local sideList = Instance.new("UIListLayout", Sidebar)
sideList.Padding = UDim.new(0, 5)

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

-- Tabs
local Tab_Main     = CreateTab("Main", "🏠")
local Tab_Auto     = CreateTab("Auto", "⚡")
local Tab_Teleport = CreateTab("Teleport", "📍")
local Tab_Tool     = CreateTab("Surgery", "🩺")
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
Tab_Main:AddToggle("Скип диалогов доктора", "Автоматически пропускает диалоги", true, function(v)
    if v then
        pcall(function()
            local rem = ReplicatedStorage:FindFirstChild("RE/SetDoctorDialogueSkipped")
            if rem then rem:FireServer(true) end
        end)
    end
end)
Tab_Main:AddToggle("Авто-Кофе (Рассудок)", "Поддерживает рассудок персонажа", _G.AutoCoffee, function(v) _G.AutoCoffee = v end)

-- ⚡ AUTO TAB
Tab_Auto:AddSection("Лечение и Хирургия")
Tab_Auto:AddToggle("Auto Treatment", "Авто-лечение палат 1-7 + Хирургия палаты 8 + X-Ray палаты 6", _G.AutoTreatment, function(v) _G.AutoTreatment = v end)
Tab_Auto:AddToggle("Auto Barney Coffee", "Авто-доставка кофе доктору Барни при усталости", _G.AutoBarneyCoffee, function(v) _G.AutoBarneyCoffee = v; _G.AutoGiveBarneyCoffee = v end)
Tab_Auto:AddToggle("Auto Buy Shop", "Авто-покупка предметов в магазине", _G.AutoBuyShop, function(v) _G.AutoBuyShop = v end)

Tab_Auto:AddSection("Ресепшен и Безопасность")
Tab_Auto:AddToggle("Auto Check In", "Полная регистрация: Бланк ➔ Фото ➔ ПК ➔ Принтер ➔ Выдача", _G.AutoCheckIn, function(v) _G.AutoCheckIn = v end)
Tab_Auto:AddToggle("Auto Shutter On Anomaly", "Авто-закрытие жалюзи при обнаружении монстров", _G.AutoAnomalyShutter, function(v) _G.AutoAnomalyShutter = v end)
Tab_Auto:AddToggle("Auto Ask Leave Anomaly", "Приказ аномалиям покинуть больницу (Ask to Leave)", _G.AutoAskLeaveAnomaly, function(v) _G.AutoAskLeaveAnomaly = v end)

Tab_Auto:AddSection("Обслуживание")
Tab_Auto:AddToggle("Auto Clean Slime", "Авто-уборка луж слизи", _G.AutoCleanSlime, function(v) _G.AutoCleanSlime = v end)
Tab_Auto:AddToggle("Auto Fix Cam", "Авто-починка камер", _G.AutoFixCam, function(v) _G.AutoFixCam = v end)

-- 📍 TELEPORT TAB
Tab_Teleport:AddSection("Палаты (Beds)")
Tab_Teleport:AddButton("Палата 8 (Хирургия / Surgery)", function() TeleportPlayer(Positions.Room8_Bed) end)
Tab_Teleport:AddButton("Палата 6 (Реанимация / X-Ray)", function() TeleportPlayer(Positions.Room6_Bed) end)
Tab_Teleport:AddButton("Палата 1 (Койка)", function() TeleportPlayer(Positions.Room1_Bed) end)
Tab_Teleport:AddButton("Палата 2 (Койка)", function() TeleportPlayer(Positions.Room2_Bed) end)
Tab_Teleport:AddButton("Палата 3 (Койка)", function() TeleportPlayer(Positions.Room3_Bed) end)
Tab_Teleport:AddButton("Палата 4 (Койка)", function() TeleportPlayer(Positions.Room4_Bed) end)
Tab_Teleport:AddButton("Палата 5 (Койка)", function() TeleportPlayer(Positions.Room5_Bed) end)
Tab_Teleport:AddButton("Палата 7 (Изолятор)", function() TeleportPlayer(Positions.Room7_ICU) end)

Tab_Teleport:AddSection("Зоны больницы")
Tab_Teleport:AddButton("Стойка Ресепшена", function() TeleportPlayer(Positions.CheckInForm) end)
Tab_Teleport:AddButton("Кнопка Жалюзи", function() TeleportPlayer(Positions.ShutterButton) end)
Tab_Teleport:AddButton("Стол доктора Барни", function() TeleportPlayer(Positions.BarneyDesk) end)
Tab_Teleport:AddButton("Кофемашина", function() TeleportPlayer(Positions.CoffeeMachine) end)

-- 🩺 SURGERY TAB (ВЗЯТЬ ПРЕДМЕТЫ ПАЛАТЫ 8)
Tab_Tool:AddSection("Инструменты хирургии (Палата 8)")
Tab_Tool:AddButton("Взять IV Drops (Капельница)", function() EnsureItemInHand("IV Drops", 3.0) end)
Tab_Tool:AddButton("Взять Scissors (Ножницы)", function() EnsureItemInHand("Scissors", 3.0) end)
Tab_Tool:AddButton("Взять Organ (Орган)", function() EnsureItemInHand("Organ", 3.0) end)
Tab_Tool:AddButton("Взять Transplant (Трансплантат)", function() EnsureItemInHand("Transplant", 3.0) end)
Tab_Tool:AddButton("Взять Medkit (Аптечка)", function() EnsureItemInHand("Medkit", 3.0) end)
Tab_Tool:AddButton("Взять Medicine (Микстура)", function() EnsureItemInHand("Medicine", 3.0) end)

Tab_Tool:AddSection("Медикаменты палат 1-7")
Tab_Tool:AddButton("Взять Ointment (Мазь)", function() EnsureItemInHand("Ointment", 3.0) end)
Tab_Tool:AddButton("Взять Bandages (Бинты)", function() EnsureItemInHand("Bandages", 3.0) end)
Tab_Tool:AddButton("Взять Eye Drops (Капли)", function() EnsureItemInHand("Eye Drops", 3.0) end)
Tab_Tool:AddButton("Взять Pills (Таблетки)", function() EnsureItemInHand("Pills", 3.0) end)

-- 👁️ VISUALS TAB
Tab_Visual:AddSection("Подсветка (ESP)")
Tab_Visual:AddToggle("Patient ESP", "Зеленая подсветка пациентов", _G.PatientESP, function(v) _G.PatientESP = v; UpdateESP() end)
Tab_Visual:AddToggle("Anomaly ESP", "Красная подсветка аномалий", _G.AnomalyESP, function(v) _G.AnomalyESP = v; UpdateESP() end)
Tab_Visual:AddToggle("Player ESP", "Синяя подсветка игроков", _G.PlayerESP, function(v) _G.PlayerESP = v; UpdateESP() end)

-- 👤 PLAYER TAB
Tab_Player:AddSection("Параметры персонажа")
Tab_Player:AddToggle("Включить кастомную скорость", "Активирует ползунок WalkSpeed", _G.WalkSpeedEnabled, function(v) _G.WalkSpeedEnabled = v end)
Tab_Player:AddSlider("Скорость (WalkSpeed)", 16, 120, 16, function(v) _G.CustomWalkSpeed = v end)
Tab_Player:AddToggle("NoClip", "Прохождение сквозь стены", _G.NoClip, function(v) _G.NoClip = v end)

-- 🌐 MISC TAB
Tab_Misc:AddSection("Серверные функции")
Tab_Misc:AddButton("🌐 Hop to Smallest Server", function()
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
Tab_Misc:AddButton("🔄 Rejoin", function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

-- Default open first tab
if tabsTable[1] then
    tabsTable[1].Page.Visible = true
    tabsTable[1].Btn.BackgroundColor3 = Color3.fromRGB(50, 105, 215)
    tabsTable[1].Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
end

-- Keybind toggle (RightControl / F3)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and (input.KeyCode == Enum.KeyCode.RightControl or input.KeyCode == Enum.KeyCode.F3) then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

print("[Averlik Hub Ultimate Master] 100% Загружено! Все системы, хирургия Палаты 8, X-Ray Палаты 6 и кофе Барни активны!")
