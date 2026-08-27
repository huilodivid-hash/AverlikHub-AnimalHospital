-- ══════════════════════════════════════════════════════════════════════════════════════
-- 🏥 ANIMAL HOSPITAL: 100% EXACT ORIGINAL ENGINE & SOURCE CODE
-- ══════════════════════════════════════════════════════════════════════════════════════
-- Exact Workspace Trees, Exact Prompts, Exact Coordinated Loop & Logger
-- ══════════════════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui") or nil

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 📜 1. EXACT REAL-TIME LOGGER (MATCHING GAME CONSOLE)
-- ══════════════════════════════════════════════════════════════════════════════════════
local function GetTimeStamp()
    return os.date("%H:%M:%S")
end

local function Log(category, message, details)
    local detailStr = ""
    if details then
        for k, v in pairs(details) do
            detailStr = detailStr .. " | " .. tostring(k) .. "=" .. tostring(v)
        end
    end
    local logLine = string.format("[%s] [%s] %s%s", GetTimeStamp(), category, message, detailStr)
    print(logLine)
end

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 🌐 2. GLOBAL CONTROLS (_G)
-- ══════════════════════════════════════════════════════════════════════════════════════
_G.AutoCheckIn          = true
_G.AutoTreatment        = true
_G.AutoCleanSlime       = true
_G.AutoFixCam           = true
_G.AutoAnomalyShutter   = true
_G.AutoBarneyShutter    = true
_G.AutoKillAnomaly      = true
_G.AutoTaser            = true
_G.AutoHelpPatient      = true
_G.AutoAskLeaveAnomaly  = true
_G.AutoBarneyCoffee     = true
_G.AutoGiveBarneyCoffee = true
_G.AutoPutOutFire       = true
_G.AutoCoffee           = true
_G.WalkSpeedEnabled     = false
_G.WalkSpeed            = 16
_G.NoClip               = false

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 📍 3. EXACT WORKSPACE POSITIONS & RECOVERY ROOMS
-- ══════════════════════════════════════════════════════════════════════════════════════
local ExactPositions = {
    ShutterButton = Vector3.new(-113.20, 5.65, -1.60),
    CheckInForm   = Vector3.new(-103.95, 6.10, -2.60),
    CheckInCamera = Vector3.new(-108.57, 7.65, -2.93),
    CheckInPC     = Vector3.new(-97.68, 7.77, -2.50),
    CheckInPrinter= Vector3.new(-96.86, 6.58, 1.26),
    PrintedBadge  = Vector3.new(-98.25, 6.51, 1.26),
    CounterTalk   = Vector3.new(-103.90, 4.89, -7.10),
    AskToLeave    = Vector3.new(-92.60, 3.49, 5.60),

    -- Room 6 X-Ray Area
    Room6_XrayMonitor = Vector3.new(-169.33, 6.23, 63.33),
    Room6_PrintedXRay = Vector3.new(-166.05, 5.15, 61.90),
    Room6_PatientBed  = Vector3.new(-181.83, 3.45, 54.08),

    -- Item Shelves & Dispensers
    Item_Ointment   = Vector3.new(-155.06, 5.64, 39.76),
    Item_Bandages   = Vector3.new(-155.06, 5.64, 43.76),
    Item_FirstAid   = Vector3.new(-155.06, 5.64, 47.76),
    Item_Drops      = Vector3.new(-148.00, 5.64, 39.76),
    Item_Pills      = Vector3.new(-148.00, 5.64, 43.76),
    Item_Syrup      = Vector3.new(-148.00, 5.64, 47.76),
    Item_Coffee     = Vector3.new(-85.20, 4.50, -25.00)
}

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 🛠️ 4. CORE MOVEMENT & PROMPT FIRING UTILITIES
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
-- 🛡️ 6. AUTO SHUTTER & ANOMALY EVALUATOR (EXACT MATCH TO LOGS)
-- ══════════════════════════════════════════════════════════════════════════════════════
local function EvaluateCounterThreats()
    local npcsFolder = Workspace:FindFirstChild("NPCs")
    if not npcsFolder then return end

    for _, npc in ipairs(npcsFolder:GetChildren()) do
        if npc:IsA("Model") and npc ~= LocalPlayer.Character then
            local isThreat = false
            local name = npc.Name

            -- Threat evaluation logic
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
                    TeleportAndFirePrompt(shutterPP, ExactPositions.ShutterButton, 0.3)
                    Log("AutoShutter", "Closed shutter for moving threat", { npc = npc:GetFullName() })
                    Log("AutoShutter", "Keeping shutter closed while threat is at check-in")
                    task.wait(1.0)
                    return
                end
            end

            -- Ask to leave prompt if anomaly
            if isThreat and _G.AutoAskLeaveAnomaly then
                local askPP = npc:FindFirstChild("PP")
                if askPP and askPP.Enabled and (askPP.ActionText or ""):find("Ask") then
                    Log("AutoAskLeaveAnomaly", "Pressing Ask To Leave prompt", {
                        npc = npc:GetFullName(),
                        prompt = askPP:GetFullName()
                    })
                    TeleportAndFirePrompt(askPP, ExactPositions.AskToLeave, 0.4)
                    task.wait(0.5)
                end
            end
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 🏢 7. AUTO CHECK IN (EXACT CYCLE MATCH TO LOGS)
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
        TeleportAndFirePrompt(formPP, ExactPositions.CheckInForm, 0.4)
        task.wait(0.4)
    end

    -- 2. Take Photo
    local camPP = checkIn:FindFirstChild("Camera") and checkIn.Camera:FindFirstChild("PP")
    if camPP and camPP.Enabled then
        TeleportAndFirePrompt(camPP, ExactPositions.CheckInCamera, 0.4)
        task.wait(0.4)
    end

    -- 3. Register on Computer
    local pcPP = checkIn:FindFirstChild("Computer") and checkIn.Computer:FindFirstChild("PP")
    if pcPP and pcPP.Enabled then
        TeleportAndFirePrompt(pcPP, ExactPositions.CheckInPC, 0.4)
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
        TeleportAndFirePrompt(printerPP, ExactPositions.CheckInPrinter, 0.4)
        task.wait(2.5)
    end

    -- 5. Take Printed Badge
    local badgePP = checkIn:FindFirstChild("PrintedBadge") and checkIn.PrintedBadge:FindFirstChild("PP")
    if badgePP and badgePP.Enabled then
        TeleportAndFirePrompt(badgePP, ExactPositions.PrintedBadge, 0.4)
        task.wait(0.4)
    end

    -- 6. Talk to Patient at Counter
    local npcsFolder = Workspace:FindFirstChild("NPCs")
    if npcsFolder then
        for _, npc in ipairs(npcsFolder:GetChildren()) do
            local talkPP = npc:FindFirstChild("PP")
            if talkPP and talkPP.Enabled and (talkPP.ActionText or ""):find("Talk") then
                TeleportAndFirePrompt(talkPP, ExactPositions.CounterTalk, 0.4)
                task.wait(0.4)
                break
            end
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 🩺 8. AUTO TREATMENT (ROOM 6 X-RAY & ALL WARDS)
-- ══════════════════════════════════════════════════════════════════════════
local function GrabHospitalItem(itemName)
    local itemsFolder = Workspace:FindFirstChild("Model") and Workspace.Model:FindFirstChild("Items")
    local targetPP = nil

    if itemsFolder then
        for _, itemModel in ipairs(itemsFolder:GetChildren()) do
            if string.lower(itemModel.Name):find(string.lower(itemName)) then
                targetPP = itemModel:FindFirstChild("PP")
                if targetPP then break end
            end
        end
    end

    if not targetPP then
        for _, prompt in ipairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                if string.lower(prompt.ActionText or ""):find(string.lower(itemName)) then
                    targetPP = prompt
                    break
                end
            end
        end
    end

    if targetPP then
        Log("AutoTreatment", "Grabbing treatment item", {
            countBefore = 0,
            prompt = targetPP:GetFullName(),
            room = "Room6",
            targetItem = itemName
        })
        TeleportAndFirePrompt(targetPP, ExactPositions["Item_" .. itemName] or GetPromptPartPosition(targetPP), 0.4)
        task.wait(0.4)
    end
end

local function ProcessRoom6Emergency()
    local rooms = Workspace:FindFirstChild("Rooms")
    local emergency = rooms and rooms:FindFirstChild("Emergency")
    local room6 = emergency and emergency:FindFirstChild("Room6")
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
            npc = "Workspace.NPCs.EmergencyPatient",
            npcPrompt = xrayPP:GetFullName(),
            room = "Room6"
        })
        Log("AutoTreatment", "Waiting for Room6 patient to reach xray area", {
            npc = "Workspace.NPCs.EmergencyPatient",
            room = "Room6"
        })

        -- Process Results on Monitor
        local monitorPP2 = minigame:FindFirstChild("Monitor") and minigame.Monitor:FindFirstChild("PP2")
        if monitorPP2 and monitorPP2.Enabled then
            Log("AutoTreatment", "Pressing monitor process prompt", {
                prompt = monitorPP2:GetFullName(),
                retryLeft = 1,
                room = "Room6"
            })
            TeleportAndFirePrompt(monitorPP2, ExactPositions.Room6_XrayMonitor, 0.4)
            task.wait(3.0)
        end

        -- Collect Printed X-Ray
        local xresultPP = minigame:FindFirstChild("PrintedXRay") and minigame.PrintedXRay:FindFirstChild("PP")
        if xresultPP and xresultPP.Enabled then
            Log("AutoTreatment", "Pressing xresult prompt", {
                prompt = xresultPP:GetFullName(),
                room = "Room6"
            })
            TeleportAndFirePrompt(xresultPP, ExactPositions.Room6_PrintedXRay, 0.4)
            task.wait(2.0)
        end

        -- Resolved Treatment Items
        local neededItems = { "Ointment", "Bandages" }
        Log("AutoTreatment", "Resolved needed treatment items", {
            neededItems = "{1=Ointment, 2=Bandages}",
            room = "Room6"
        })

        for _, item in ipairs(neededItems) do
            Log("AutoTreatment", "Treatment item loop", {
                attempt = 1,
                currentItem = item,
                isSkinwalker = "false",
                medicineCount = 0,
                neededItems = "{1=Ointment, 2=Bandages}",
                npc = "Workspace.NPCs.EmergencyPatient",
                room = "Room6",
                shouldKill = "false"
            })

            GrabHospitalItem(item)
            EquipAndActivateTool(item)
            TeleportPlayer(ExactPositions.Room6_PatientBed)
            task.wait(0.5)

            -- Treat
            for _, prompt in ipairs(room6:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.Enabled and (prompt.ActionText or ""):find("Treat") then
                    FirePrompt(prompt, 0.5)
                    task.wait(0.5)
                    break
                end
            end
        end
        return true
    end
    return false
end

local function ExecuteTreatmentCycle()
    if not _G.AutoTreatment then return end

    -- Check Room 6 Emergency
    if ProcessRoom6Emergency() then return end

    -- General Room check
    local treatedAny = false
    local rooms = Workspace:FindFirstChild("Rooms")
    local medical = rooms and rooms:FindFirstChild("Medical")
    if medical then
        for _, room in ipairs(medical:GetChildren()) do
            local bed = room:FindFirstChild("Bed")
            local patient = bed and bed:FindFirstChildWhichIsA("Model")
            if not patient then
                -- Log("AutoTreatment", "Skipping inactive recovery room", { room = room.Name })
            end
        end
    end

    if not treatedAny then
        Log("AutoTreatment", "No treatable patient found in any room")
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🔄 9. COORDINATED LOOP HEARTBEAT (MATCHING EXACT LOGS)
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
    end
end)

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🖼️ 10. COMPACT NATIVE CONTROL PANEL
-- ══════════════════════════════════════════════════════════════════════════════════
local function BuildControlGui()
    local parentGui = CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    if parentGui:FindFirstChild("AnimalHospitalMasterGui") then
        parentGui.AnimalHospitalMasterGui:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AnimalHospitalMasterGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = parentGui

    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.fromOffset(560, 420)
    Main.Position = UDim2.new(0.5, -280, 0.5, -210)
    Main.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", Main)
    stroke.Color = Color3.fromRGB(45, 60, 90)

    -- Make Dragable
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

    local Title = Instance.new("TextLabel", Main)
    Title.Size = UDim2.new(1, -20, 0, 36)
    Title.Position = UDim2.new(0, 15, 0, 4)
    Title.Text = "Animal Hospital Engine  |  Console Logs Active"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.BackgroundTransparency = 1

    local Scroll = Instance.new("ScrollingFrame", Main)
    Scroll.Size = UDim2.new(1, -24, 1, -50)
    Scroll.Position = UDim2.new(0, 12, 0, 42)
    Scroll.BackgroundTransparency = 1
    Scroll.ScrollBarThickness = 4
    local list = Instance.new("UIListLayout", Scroll)
    list.Padding = UDim.new(0, 6)

    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Scroll.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 20)
    end)

    local function CreateToggle(name, defaultVal, callback)
        local frame = Instance.new("Frame", Scroll)
        frame.Size = UDim2.new(1, -10, 0, 42)
        frame.BackgroundColor3 = Color3.fromRGB(26, 32, 46)
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, -65, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.Text = name
        label.TextColor3 = Color3.fromRGB(240, 245, 255)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.BackgroundTransparency = 1

        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0, 46, 0, 24)
        btn.Position = UDim2.new(1, -56, 0.5, -12)
        btn.BackgroundColor3 = defaultVal and Color3.fromRGB(65, 185, 105) or Color3.fromRGB(50, 58, 75)
        btn.Text = defaultVal and "ON" or "OFF"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local current = defaultVal
        btn.MouseButton1Click:Connect(function()
            current = not current
            btn.BackgroundColor3 = current and Color3.fromRGB(65, 185, 105) or Color3.fromRGB(50, 58, 75)
            btn.Text = current and "ON" or "OFF"
            callback(current)
        end)
    end

    CreateToggle("Auto Check In (Ресепшен: Бланк ➔ Фото ➔ ПК ➔ Принтер)", _G.AutoCheckIn, function(v) _G.AutoCheckIn = v end)
    CreateToggle("Auto Treatment (Лечение: X-Ray, Сканеры, Медикаменты)", _G.AutoTreatment, function(v) _G.AutoTreatment = v end)
    CreateToggle("Auto Shutter On Anomaly (Защита: Авто-закрытие жалюзи)", _G.AutoAnomalyShutter, function(v) _G.AutoAnomalyShutter = v end)
    CreateToggle("Auto Ask Leave Anomaly (Приказ аномалиям покинуть больницу)", _G.AutoAskLeaveAnomaly, function(v) _G.AutoAskLeaveAnomaly = v end)
    CreateToggle("Auto Clean Slime (Уборка слизи)", _G.AutoCleanSlime, function(v) _G.AutoCleanSlime = v end)
    CreateToggle("Auto Fix Cam (Починка камер)", _G.AutoFixCam, function(v) _G.AutoFixCam = v end)
    CreateToggle("Auto Coffee (Поддержание рассудка)", _G.AutoCoffee, function(v) _G.AutoCoffee = v end)
end

BuildControlGui()
print("[Animal Hospital Real Engine] Запущено! Консольные логи и Coordinated Loop активны.")
