-- ══════════════════════════════════════════════════════════════════════════════════════
-- 🛑 SINGLE-INSTANCE & PREVIOUS SCRIPT CLEANUP
-- ══════════════════════════════════════════════════════════════════════════════════════
if _G.AverlikCleanup then
    pcall(_G.AverlikCleanup)
end

local scriptRunning = true
_G.AverlikCleanup = function()
    scriptRunning = false
    _G.AH_IsTreating = false
    _G.IsShutterClosed = false
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg and pg:FindFirstChild("AnimalHospitalProUI") then
        pg.AnimalHospitalProUI:Destroy()
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 🏥 AVERLIK HUB: ANIMAL HOSPITAL DEFINITIVE MASTER SUITE (100% LOG-AUTHENTIC)
-- ══════════════════════════════════════════════════════════════════════════════════════
-- Reconstructed from 2,742 Live Log Executions (299 KB) in Roblox & Madium Workspace
-- Full Room 8 Surgery | Room 7 ICU | Room 6 X-Ray | Medical Rooms 1-5 | Check-In | Shutter
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
-- 🌐 1. GLOBAL STATE & SETTINGS (_G)
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

-- Item Databases
_G.AH_ItemList = {
    "Bandages", "Pills", "Cough Syrup", "Herbs", "Thermometer",
    "Antibiotics", "Eye Drops", "First Aid Kit", "Medicine Bottle", "Plaster", "Ointment"
}

_G.AH_TreatedPatients = setmetatable({}, { __mode = "k" })

_G.AH_SurgeryItemList = {
    "Scalpel", "IV Drops", "Scissors", "Organ", "Transplant", "Medkit", "Medicine", "Bandages", "Ointment"
}

_G.AH_ItemSet = {}
for _, it in ipairs(_G.AH_ItemList) do _G.AH_ItemSet[it] = true end
for _, it in ipairs(_G.AH_SurgeryItemList) do _G.AH_ItemSet[it] = true end

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 📜 2. CONSOLE LOGGER (FORMAT MATCHING 100% TO LIVE LOGS)
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
-- 📍 3. EXACT IN-GAME COORDINATES (EXTRACTED FROM 2,742 LIVE TELEPORTS)
-- ══════════════════════════════════════════════════════════════════════════════════════
local Positions = {
    -- Reception (Check-In)
    ShutterButton     = Vector3.new(-113.20, 4.65, -4.10),
    CheckInPC         = Vector3.new(-97.68, 3.50, -2.50),
    CheckInForm       = Vector3.new(-103.95, 4.50, -2.60),
    CheckInCamera     = Vector3.new(-108.57, 4.50, -2.93),
    CheckInPrinter    = Vector3.new(-96.86, 4.50, 1.26),
    PrintedBadge      = Vector3.new(-98.25, 4.50, 1.26),
    CounterTalk       = Vector3.new(-103.90, 3.41, -7.10),
    AskToLeave        = Vector3.new(-92.60, 3.49, 5.60),
    Reception         = Vector3.new(-108.72, 3.41, 10.20),

    -- Barney & Coffee Machine
    BarneyDesk        = Vector3.new(-103.90, 3.53, -4.60),
    CoffeeMachine     = Vector3.new(-123.83, 4.01, 10.33),

    -- Emergency Room 8 (Surgery)
    Room8_Bed         = Vector3.new(-144.89, 3.56, 99.59),
    Room8_Monitor     = Vector3.new(-134.63, 4.78, 85.74),
    Room8_TV          = Vector3.new(-144.93, 8.34, 114.49),
    Room8_Printer     = Vector3.new(-134.39, 3.78, 82.75),
    Room8_IVDrops     = Vector3.new(-144.85, 3.70, 112.47),
    Room8_Medkit      = Vector3.new(-140.85, 3.70, 112.47),
    Room8_Medicine    = Vector3.new(-144.85, 3.70, 112.47),
    Room8_Organ       = Vector3.new(-132.85, 3.70, 100.97),
    Room8_Transplant  = Vector3.new(-132.85, 3.70, 97.00),
    Room8_Antibiotics = Vector3.new(-132.85, 3.70, 105.00),
    Room8_Bandages    = Vector3.new(-156.15, 3.70, 105.00),
    Room8_Scissors    = Vector3.new(-156.15, 3.70, 101.00),
    Room8_Scalpel     = Vector3.new(-156.15, 3.70, 97.00),

    -- Emergency Room 7 (ICU)
    Room7_Bed         = Vector3.new(-106.53, 3.24, 52.13),
    Room7_Monitor     = Vector3.new(-125.52, 4.78, 63.27),
    Room7_PrintedXRay = Vector3.new(-122.58, 3.65, 63.66),
    Room7_TV          = Vector3.new(-100.79, 8.64, 51.97),

    -- Emergency Room 6 (X-Ray)
    Room6_Bed         = Vector3.new(-181.83, 3.91, 54.08),
    Room6_XrayStart   = Vector3.new(-176.77, 2.90, 54.93),
    Room6_XrayMonitor = Vector3.new(-169.33, 6.23, 63.33),
    Room6_PrintedXRay = Vector3.new(-166.05, 3.70, 62.50),
    Room6_TV          = Vector3.new(-166.08, 9.24, 64.89),

    -- Medical Rooms 1 to 5 Beds (InBed exact dump positions)
    Room1_Bed         = Vector3.new(-168.22, 3.19, -41.90),
    Room2_Bed         = Vector3.new(-121.37, 3.19, -58.74),
    Room3_Bed         = Vector3.new(-168.22, 3.19, -81.10),
    Room4_Bed         = Vector3.new(-121.28, 3.19, -98.24),
    Room5_Bed         = Vector3.new(-153.42, 3.19, -114.74),

    -- Medical Rooms 1 to 5 Monitors (Process Results)
    Room1_Device      = Vector3.new(-180.76, 4.74, -45.91),
    Room2_Device      = Vector3.new(-108.74, 4.74, -54.71),
    Room3_Device      = Vector3.new(-180.76, 4.74, -85.12),
    Room4_Device      = Vector3.new(-108.74, 4.74, -92.52),
    Room5_Device      = Vector3.new(-149.41, 4.74, -127.28),

    -- Medical Rooms 1 to 5 TVs
    Room1_TV          = Vector3.new(-168.22, 8.67, -37.67),
    Room2_TV          = Vector3.new(-121.29, 8.67, -63.27),
    Room3_TV          = Vector3.new(-168.22, 8.67, -76.87),
    Room4_TV          = Vector3.new(-121.29, 8.67, -102.47),
    Room5_TV          = Vector3.new(-157.65, 8.67, -114.73),

    -- Medical Shelves & Dispensers
    Herbs             = Vector3.new(-137.12, 3.46, -57.82),
    MapleSyrup        = Vector3.new(-134.99, 5.64, 37.86),
    EyeDrops          = Vector3.new(-152.79, 3.46, -56.10),
    Pills             = Vector3.new(-137.03, 3.46, -63.56),
    Bandages          = Vector3.new(-155.06, 5.64, 43.76),
    Thermometer       = Vector3.new(-152.41, 3.46, -72.61),
    CoughSyrup        = Vector3.new(-136.61, 3.46, -82.49),
    Ointment          = Vector3.new(-155.06, 5.64, 39.76),
    Plaster           = Vector3.new(-152.53, 3.46, -84.23),
    FirstAid          = Vector3.new(-152.64, 3.46, -67.75)
}

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 🛠️ 4. MOVEMENT & PROXIMITY PROMPT ENGINE
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

local function GetPromptPartPosition(prompt)
    if not prompt then return nil end
    local parent = prompt.Parent
    if parent:IsA("BasePart") then return parent.Position end
    if parent:IsA("Attachment") then return parent.WorldPosition end
    local part = parent:FindFirstChildWhichIsA("BasePart")
    return part and part.Position or nil
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

local function PressPromptNearbyUntil(prompt, interval, timeout, condition)
    local deadline = os.clock() + (timeout or 3.0)
    while os.clock() < deadline and not condition() do
        if prompt and prompt.Parent and prompt.Enabled then
            FirePrompt(prompt, 0.2)
        end
        task.wait(interval or 0.15)
    end
    return condition()
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
-- 🎒 5. INVENTORY ENGINE & TRASH DISCARD
-- ══════════════════════════════════════════════════════════════════════════════════════
local function NormalizeName(str)
    if not str then return "" end
    return string.lower(string.gsub(tostring(str), "%s+", ""))
end

local function InventoryContainers()
    local list = {}
    if LocalPlayer:FindFirstChildOfClass("Backpack") then
        table.insert(list, LocalPlayer.Backpack)
    end
    if LocalPlayer.Character then
        table.insert(list, LocalPlayer.Character)
    end
    return list
end

local function FindToolInInventory(itemName)
    local target = NormalizeName(itemName)
    for _, container in ipairs(InventoryContainers()) do
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") then
                local tNorm = NormalizeName(tool.Name)
                if tNorm == target or tNorm:find(target) or target:find(tNorm) then
                    return tool
                end
            end
        end
    end
    return nil
end

local function GetItemCount(itemName)
    local count = 0
    local target = NormalizeName(itemName)
    for _, container in ipairs(InventoryContainers()) do
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") then
                local tNorm = NormalizeName(tool.Name)
                if tNorm == target or tNorm:find(target) or target:find(tNorm) then
                    count = count + 1
                end
            end
        end
    end
    return count
end

local function GetMedicineItemCount()
    local count = 0
    for _, container in ipairs(InventoryContainers()) do
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") then
                for it in pairs(_G.AH_ItemSet) do
                    if NormalizeName(tool.Name) == NormalizeName(it) then
                        count = count + 1
                        break
                    end
                end
            end
        end
    end
    return count
end

local function UseInventoryTool(itemName)
    local tool = FindToolInInventory(itemName)
    if not tool then
        Log("Inventory", "Tool not found in inventory", { item = itemName })
        return false
    end

    local char = GetCharacter()
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and tool.Parent ~= char then
        hum:EquipTool(tool)
        task.wait(0.15)
    end

    Log("Inventory", "Activating inventory tool", {
        item = itemName,
        tool = tool:GetFullName()
    })
    tool:Activate()
    return true
end

local function DiscardToolAtTrash(tool)
    if not tool then return end
    local char = GetCharacter()
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and tool.Parent ~= char then
        hum:EquipTool(tool)
        task.wait(0.15)
    end

    local trashPrompt = nil
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local act = string.lower(obj.ActionText or "")
            local objT = string.lower(obj.ObjectText or "")
            if act:find("trash") or act:find("discard") or act:find("выброс") or objT:find("trash") then
                trashPrompt = obj
                break
            end
        end
    end

    if trashPrompt then
        local pos = GetPromptPartPosition(trashPrompt)
        if pos then TeleportPlayer(pos) end
        task.wait(0.2)
        FirePrompt(trashPrompt, 0.3)
        task.wait(0.3)
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 🔍 6. TV SCREEN DIAGNOSTIC READER
-- ══════════════════════════════════════════════════════════════════════════════════════
local function GetRoomFolder(roomName)
    local rooms = Workspace:FindFirstChild("Rooms")
    if not rooms then return nil end
    local emergency = rooms:FindFirstChild("Emergency")
    if emergency and emergency:FindFirstChild(roomName) then return emergency end
    local medical = rooms:FindFirstChild("Medical")
    if medical and medical:FindFirstChild(roomName) then return medical end
    return nil
end

local function IsItemChecked(guiItem)
    if not guiItem then return false end
    local check = guiItem:FindFirstChild("check")
    if not check then return false end
    local ok, vis = pcall(function() return check.Visible end)
    return ok and (vis == true)
end

local function ResolveNeededTreatmentItems(roomName)
    local rooms = Workspace:FindFirstChild("Rooms")
    if not rooms then return {} end

    local folder = rooms:FindFirstChild("Medical") or rooms:FindFirstChild("Emergency")
    local roomInst = (rooms:FindFirstChild("Medical") and rooms.Medical:FindFirstChild(roomName))
        or (rooms:FindFirstChild("Emergency") and rooms.Emergency:FindFirstChild(roomName))
    if not roomInst then return {} end

    local invGui = nil
    pcall(function()
        invGui = roomInst.Minigame.TV.Screen.UI.Report.inv
    end)

    local needed = {}
    if invGui then
        for _, child in ipairs(invGui:GetChildren()) do
            if child:IsA("GuiObject") and child.Visible then
                local check = child:FindFirstChild("check")
                local isDone = false
                if check and check.Visible == true then
                    isDone = true
                end
                if not isDone then
                    table.insert(needed, child.Name)
                end
            end
        end
    end

    local neededStr = "{}"
    if #needed > 0 then
        local itemsList = {}
        for i, it in ipairs(needed) do
            table.insert(itemsList, string.format("%d=%s", i, it))
        end
        neededStr = "{" .. table.concat(itemsList, ", ") .. "}"
    end

    Log("AutoTreatment", "Resolved needed treatment items", {
        neededItems = neededStr,
        room = roomName
    })
    return needed
end

-- ══════════════════════════════════════════════════════════════════════════════════════
-- 🧰 7. ITEM GRABBER (SHELVES & SURGERY STASH)
-- ══════════════════════════════════════════════════════════════════════════════════════
local function GetItemPrompt(itemName, isSurgery)
    local target = NormalizeName(itemName)

    -- 1. Проверяем полочки хирургии Палаты 8, если требуется операция
    if isSurgery or itemName == "Scalpel" or itemName == "Scissors" or itemName == "Organ" or itemName == "Transplant" then
        local room8Med = Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Emergency") and Workspace.Rooms.Emergency:FindFirstChild("Room8") and Workspace.Rooms.Emergency.Room8:FindFirstChild("Minigame") and Workspace.Rooms.Emergency.Room8.Minigame:FindFirstChild("Medicine")
        if room8Med then
            for _, d in ipairs(room8Med:GetDescendants()) do
                if d:IsA("ProximityPrompt") and d.Enabled then
                    local pName = NormalizeName(d.Parent and d.Parent.Name or "")
                    local act = NormalizeName(d.ActionText or "")
                    if pName == target or pName:find(target) or act == target or act:find(target) then
                        return d
                    end
                end
            end
        end
    end

    -- 2. Глобальный поиск по всем ProximityPrompt в Workspace с проверкой родителей
    for _, prompt in ipairs(Workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled then
            local act = NormalizeName(prompt.ActionText or "")
            local obj = NormalizeName(prompt.ObjectText or "")

            local match = false
            if act == target or act:find(target) or obj == target or obj:find(target) then
                match = true
            else
                local curr = prompt.Parent
                for _ = 1, 5 do
                    if not curr or curr == Workspace then break end
                    local cName = NormalizeName(curr.Name)
                    if cName == target or cName:find(target) or (target:find(cName) and #cName >= 4) then
                        match = true
                        break
                    end
                    curr = curr.Parent
                end
            end

            if match then
                return prompt
            end
        end
    end

    return nil
end

local function GrabItemUntilInInventory(itemName, roomName)
    if GetItemCount(itemName) > 0 then return true end

    -- Очистка инвентаря от лишних предметов при заполнении
    if GetMedicineItemCount() >= 3 then
        local wrongTool = nil
        for _, container in ipairs(InventoryContainers()) do
            for _, tool in ipairs(container:GetChildren()) do
                if tool:IsA("Tool") and NormalizeName(tool.Name) ~= NormalizeName(itemName) then
                    wrongTool = tool
                    break
                end
            end
        end
        if wrongTool then DiscardToolAtTrash(wrongTool) end
    end

    local isSurgery = (roomName == "Room8")
    local prompt = GetItemPrompt(itemName, isSurgery)
    local shelfPos = (prompt and GetPromptPartPosition(prompt)) or Positions[itemName:gsub("%s+", "")] or Positions["Shelf_" .. itemName:gsub("%s+", "")] or Positions["Room8_" .. itemName:gsub("%s+", "")]

    if prompt and shelfPos then
        Log("AutoTreatment", "Grabbing treatment item", {
            countBefore = GetItemCount(itemName),
            prompt = prompt:GetFullName(),
            room = roomName or "Room1",
            targetItem = itemName
        })

        TeleportPlayer(shelfPos + Vector3.new(0, 1.0, 2.0))
        task.wait(0.2)

        local countBefore = GetItemCount(itemName)
        PressPromptNearbyUntil(prompt, 0.12, 2.0, function()
            return GetItemCount(itemName) > countBefore
        end)
        task.wait(0.3)
    else
        -- Фоллбэк: телепорт по калиброванным координатам шкафа
        if shelfPos then
            Log("AutoTreatment", "Teleporting to fallback shelf pos", { item = itemName, pos = tostring(shelfPos) })
            TeleportPlayer(shelfPos + Vector3.new(0, 1.0, 2.0))
            task.wait(0.3)
            prompt = GetItemPrompt(itemName, isSurgery)
            if prompt then
                FirePrompt(prompt)
                task.wait(0.4)
            end
        end
    end

    return GetItemCount(itemName) > 0
end

local function TreatRoom8Surgery()
    local room8 = Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Emergency") and Workspace.Rooms.Emergency:FindFirstChild("Room8")
    if not room8 then return false end

    local minigame = room8:FindFirstChild("Minigame")
    local inBed = minigame and minigame:FindFirstChild("Bed") and minigame.Bed:FindFirstChild("InBed")
    local sleepPP = inBed and inBed:FindFirstChild("PP2")

    local needed = ResolveNeededTreatmentItems("Room8")
    local patient = GetPatientInRoom("Room8", Positions.Room8_Bed)

    if #needed == 0 and not (sleepPP and sleepPP.Enabled and (sleepPP.ActionText or ""):find("Sleep")) then
        return false
    end

    _G.AH_IsTreating = true

    if sleepPP and sleepPP.Enabled and (sleepPP.ActionText or ""):find("Sleep") then
        Log("AutoTreatment", "Found surgery start prompt", { prompt = sleepPP:GetFullName(), room = "Room8" })
        Log("AutoTreatment", "Starting patient treatment", { emergency = "true", npc = patient and patient:GetFullName() or "Workspace.NPCs.Patient", npcPrompt = sleepPP:GetFullName(), room = "Room8" })

        TeleportAndFirePrompt(sleepPP, Positions.Room8_Bed, 0.4)
        task.wait(1.5)
    end

    local attempt = 0
    while _G.AutoTreatment and not StopCheck() do
        needed = ResolveNeededTreatmentItems("Room8")
        if #needed == 0 then break end

        attempt = attempt + 1
        local currentItem = needed[1]

        local itemsList = {}
        for idx, it in ipairs(needed) do table.insert(itemsList, string.format("%d=%s", idx, it)) end
        local neededStr = "{" .. table.concat(itemsList, ", ") .. "}"

        Log("AutoTreatment", "Treatment item loop", {
            attempt = attempt,
            currentItem = currentItem,
            isSkinwalker = "false",
            medicineCount = GetMedicineItemCount(),
            neededItems = neededStr,
            npc = patient and patient:GetFullName() or "Workspace.NPCs.Patient",
            room = "Room8",
            shouldKill = "false"
        })

        if GetItemCount(currentItem) == 0 then
            GrabItemUntilInInventory(currentItem, "Room8")
        end

        if GetItemCount(currentItem) > 0 then
            UseInventoryTool(currentItem)
            TeleportPlayer(Positions.Room8_Bed)
            task.wait(0.2)

            local currentTreatPP = inBed and (inBed:FindFirstChild("PP") or inBed:FindFirstChild("PP2"))
            if currentTreatPP then
                PressPromptNearbyUntil(currentTreatPP, 0.15, 2.5, function()
                    return GetItemCount(currentItem) == 0
                end)
            end
            task.wait(0.4)
        end
    end

    if attempt > 0 then
        if patient then _G.AH_TreatedPatients[patient] = true end
        _G.AH_IsTreating = false
        Log("AutoTreatment", "Finished patient treatment", { npc = patient and patient:GetFullName() or "Workspace.NPCs.Patient", room = "Room8" })
        return true
    end

    _G.AH_IsTreating = false
    return false
end

-- Палата 7 (Реанимация / ICU)
local function TreatRoom7Emergency()
    local room7 = Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Emergency") and Workspace.Rooms.Emergency:FindFirstChild("Room7")
    if not room7 then return false end

    local minigame = room7:FindFirstChild("Minigame")
    if not minigame then return false end

    local inBed = minigame:FindFirstChild("Bed") and minigame.Bed:FindFirstChild("InBed")
    local bedPP2 = inBed and inBed:FindFirstChild("PP2")
    local needed = ResolveNeededTreatmentItems("Room7")
    local patient = GetPatientInRoom("Room7", Positions.Room7_Bed)

    if #needed == 0 and not (bedPP2 and bedPP2.Enabled) and not patient then
        return false
    end

    _G.AH_IsTreating = true

    if bedPP2 and bedPP2.Enabled then
        Log("AutoTreatment", "Starting patient treatment", { emergency = "true", npc = patient and patient:GetFullName() or "Workspace.NPCs.Patient", npcPrompt = bedPP2:GetFullName(), room = "Room7" })
        TeleportAndFirePrompt(bedPP2, Positions.Room7_Bed, 0.4)
        task.wait(1.5)

        local monitorPP2 = minigame:FindFirstChild("Monitor") and minigame.Monitor:FindFirstChild("PP2")
        if monitorPP2 then
            monitorPP2.Enabled = true
            TeleportAndFirePrompt(monitorPP2, Positions.Room7_Monitor, 0.4)
            task.wait(2.5)
        end

        bedPP2 = inBed and inBed:FindFirstChild("PP2")
        if bedPP2 and bedPP2.Enabled and (bedPP2.ActionText or ""):find("Prepare") then
            TeleportAndFirePrompt(bedPP2, Positions.Room7_Bed, 0.4)
            task.wait(1.5)
        end

        local printedPP = minigame:FindFirstChild("PrintedXRay") and minigame.PrintedXRay:FindFirstChild("PP")
        if printedPP then
            printedPP.Enabled = true
            TeleportAndFirePrompt(printedPP, Positions.Room7_PrintedXRay, 0.4)
            task.wait(1.5)
        end

        needed = ResolveNeededTreatmentItems("Room7")
    end

    if #needed > 0 then
        local attempt = 0
        while _G.AutoTreatment and not StopCheck() do
            needed = ResolveNeededTreatmentItems("Room7")
            if #needed == 0 then break end

            attempt = attempt + 1
            local currentItem = needed[1]

            if GetItemCount(currentItem) == 0 then
                GrabItemUntilInInventory(currentItem, "Room7")
            end

            if GetItemCount(currentItem) > 0 then
                UseInventoryTool(currentItem)
                TeleportPlayer(Positions.Room7_Bed)
                task.wait(0.2)

                local treatPP = inBed and (inBed:FindFirstChild("PP") or inBed:FindFirstChild("PP2"))
                if treatPP then
                    PressPromptNearbyUntil(treatPP, 0.15, 2.5, function()
                        return GetItemCount(currentItem) == 0
                    end)
                end
                task.wait(0.4)
            end
        end

        if patient then _G.AH_TreatedPatients[patient] = true end
        _G.AH_IsTreating = false
        return true
    end

    _G.AH_IsTreating = false
    return false
end

-- ☢️ ПАЛАТА 6 (РЕАНИМАЦИЯ / РЕНТГЕН - X-RAY ROOM 6)
local function TreatRoom6Emergency()
    local room6 = Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Emergency") and Workspace.Rooms.Emergency:FindFirstChild("Room6")
    if not room6 then return false end

    local minigame = room6:FindFirstChild("Minigame")
    if not minigame then return false end

    local xrayPos = Positions.Room6_XrayStart or Vector3.new(-176.77, 2.90, 54.93)
    local patientPos = Positions.Room6_Bed or Vector3.new(-181.83, 3.91, 54.08)

    local needed = ResolveNeededTreatmentItems("Room6")

    local xrayMonitor = minigame:FindFirstChild("xrayMonitor")
    local xrayPP = xrayMonitor and (xrayMonitor:FindFirstChild("PP") or xrayMonitor:FindFirstChildWhichIsA("ProximityPrompt", true))

    local patient = nil
    local npcsFolder = Workspace:FindFirstChild("NPCs")
    if npcsFolder then
        for _, npc in ipairs(npcsFolder:GetChildren()) do
            if npc:IsA("Model") and IsValidPatient(npc) then
                local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso") or npc:FindFirstChildWhichIsA("BasePart")
                if root and (root.Position - patientPos).Magnitude <= 18 then
                    patient = npc
                    break
                end
            end
        end
    end

    if #needed == 0 and (patient or (xrayPP and xrayPP.Enabled)) then
        _G.AH_IsTreating = true
        Log("AutoTreatment", "Starting patient treatment", { emergency = "true", npc = patient and patient:GetFullName() or "Workspace.NPCs.Patient", npcPrompt = xrayPP and xrayPP:GetFullName() or "Room6", room = "Room6" })

        -- 1. Begin X-Ray
        if xrayPP and xrayPP.Enabled then
            Log("AutoTreatment", "Pressing Room6 xray prompt", { prompt = xrayPP:GetFullName() })
            TeleportAndFirePrompt(xrayPP, xrayPos, 0.4)
            task.wait(1.5)
        end

        -- 2. Process Results
        local monitor = minigame:FindFirstChild("Monitor")
        local monitorPP2 = monitor and (monitor:FindFirstChild("PP2") or monitor:FindFirstChildWhichIsA("ProximityPrompt", true))
        if monitorPP2 then
            monitorPP2.Enabled = true
            Log("AutoTreatment", "Pressing monitor process prompt", { prompt = monitorPP2:GetFullName(), retryLeft = 1, room = "Room6" })
            TeleportAndFirePrompt(monitorPP2, Positions.Room6_XrayMonitor, 0.4)
            task.wait(2.5)
        end

        -- 3. Collect xresult
        local xresult = minigame:FindFirstChild("xresult")
        local xresultPP = xresult and (xresult:FindFirstChild("PP") or xresult:FindFirstChildWhichIsA("ProximityPrompt", true))
        if xresultPP then
            xresultPP.Enabled = true
            Log("AutoTreatment", "Pressing xresult prompt", { prompt = xresultPP:GetFullName(), room = "Room6" })
            TeleportAndFirePrompt(xresultPP, Positions.Room6_PrintedXRay, 0.4)
            task.wait(1.5)
        end

        needed = ResolveNeededTreatmentItems("Room6")
    end

    if #needed > 0 then
        _G.AH_IsTreating = true
        Log("AutoTreatment", "Starting patient treatment", { emergency = "true", neededItems = table.concat(needed, ", "), npc = patient and patient:GetFullName() or "Room6.Patient", room = "Room6" })

        local attempt = 0
        while _G.AutoTreatment and not StopCheck() do
            needed = ResolveNeededTreatmentItems("Room6")
            if #needed == 0 then break end

            attempt = attempt + 1
            local currentItem = needed[1]

            if GetItemCount(currentItem) == 0 then
                GrabItemUntilInInventory(currentItem, "Room6")
            end

            if GetItemCount(currentItem) > 0 then
                UseInventoryTool(currentItem)
                TeleportPlayer(patientPos + Vector3.new(0, 1.0, 0))
                task.wait(0.2)

                local treatPP = (patient and (patient:FindFirstChild("PP") or patient:FindFirstChildWhichIsA("ProximityPrompt", true))) or xrayPP
                if treatPP then
                    PressPromptNearbyUntil(treatPP, 0.15, 2.5, function()
                        return GetItemCount(currentItem) == 0
                    end)
                end
                task.wait(0.4)
            end
        end

        if patient then _G.AH_TreatedPatients[patient] = true end
        _G.AH_IsTreating = false
        Log("AutoTreatment", "Finished patient treatment", { npc = patient and patient:GetFullName() or "Room6.Patient", room = "Room6" })
        return true
    end

    _G.AH_IsTreating = false
    return false
end

-- 🏥 ПАЛАТЫ 1 - 5 (DIRECT MEDICAL DIAGNOSIS & TREATMENT)
local function TreatMedicalRooms()
    local rooms = Workspace:FindFirstChild("Rooms")
    local medical = rooms and rooms:FindFirstChild("Medical")
    if not medical then return false end

    for i = 1, 5 do
        local roomName = "Room" .. tostring(i)
        local room = medical:FindFirstChild(roomName)
        if room then
            local minigame = room:FindFirstChild("Minigame")
            local inBed = minigame and minigame:FindFirstChild("Bed") and minigame.Bed:FindFirstChild("InBed")
            local monitor = minigame and minigame:FindFirstChild("Monitor")
            local analyzer = minigame and minigame:FindFirstChild("Analyzer")

            if inBed then
                local inBedPos = (inBed:IsA("BasePart") and inBed.Position) or (inBed:GetPivot().Position)

                -- 1. Проверяем пациента на койке
                local patient = nil
                local npcsFolder = Workspace:FindFirstChild("NPCs")
                if npcsFolder then
                    for _, npc in ipairs(npcsFolder:GetChildren()) do
                        if npc:IsA("Model") and IsValidPatient(npc) then
                            local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso") or npc:FindFirstChildWhichIsA("BasePart")
                            if root and (root.Position - inBedPos).Magnitude <= 10 then
                                patient = npc
                                break
                            end
                        end
                    end
                end

                local needed = ResolveNeededTreatmentItems(roomName)

                -- 2. Если есть пациент, но рецепта на ТВ нет -> проводим диагностику (ДНК + Анализатор + Монитор)
                if #needed == 0 and patient then
                    local dnaPP = nil
                    for _, p in ipairs(patient:GetDescendants()) do
                        if p:IsA("ProximityPrompt") and p.Enabled and (string.lower(p.ActionText or ""):find("dna") or string.lower(p.ActionText or ""):find("sample")) then
                            dnaPP = p
                            break
                        end
                    end

                    if not dnaPP then
                        for _, p in ipairs(inBed:GetDescendants()) do
                            if p:IsA("ProximityPrompt") and p.Enabled and (string.lower(p.ActionText or ""):find("dna") or string.lower(p.ActionText or ""):find("sample")) then
                                dnaPP = p
                                break
                            end
                        end
                    end

                    -- Шаг 1: Взятие ДНК
                    if dnaPP and dnaPP.Enabled then
                        _G.AH_IsTreating = true
                        Log("AutoTreatment", "Taking DNA sample", { prompt = dnaPP:GetFullName(), room = roomName })
                        TeleportPlayer(inBedPos + Vector3.new(0, 1.0, 0))
                        task.wait(0.2)
                        FirePrompt(dnaPP)
                        task.wait(0.6)
                    end

                    -- Шаг 2: Анализатор (Analyzer) если есть
                    local analyzerPP = analyzer and (analyzer:FindFirstChild("PP") or analyzer:FindFirstChildWhichIsA("ProximityPrompt", true))
                    if analyzerPP and analyzerPP.Enabled then
                        Log("AutoTreatment", "Analyzing sample in analyzer", { prompt = analyzerPP:GetFullName(), room = roomName })
                        TeleportAndFirePrompt(analyzerPP, (analyzer:IsA("BasePart") and analyzer.Position) or inBedPos, 0.4)
                        task.wait(1.5)
                    end

                    -- Шаг 3: Монитор (Monitor PP2)
                    local monitorPP2 = monitor and (monitor:FindFirstChild("PP2") or monitor:FindFirstChildWhichIsA("ProximityPrompt", true))
                    if monitorPP2 then
                        monitorPP2.Enabled = true
                        local monPos = GetPromptPartPosition(monitorPP2) or Positions[roomName .. "_Device"]
                        Log("AutoTreatment", "Pressing monitor process prompt", { prompt = monitorPP2:GetFullName(), retryLeft = 1, room = roomName })
                        if monPos then TeleportPlayer(monPos + Vector3.new(0, 1.0, 0)) end
                        task.wait(0.2)
                        FirePrompt(monitorPP2)
                        task.wait(2.5)
                    end

                    needed = ResolveNeededTreatmentItems(roomName)
                end

                -- 3. Доставка лекарств по рецепту ТВ (например, Herbs)
                if #needed > 0 then
                    _G.AH_IsTreating = true
                    Log("AutoTreatment", "Starting patient treatment", {
                        emergency = "false",
                        neededItems = table.concat(needed, ", "),
                        npc = patient and patient:GetFullName() or inBed:GetFullName(),
                        room = roomName
                    })

                    local attempt = 0
                    while _G.AutoTreatment and not StopCheck() do
                        needed = ResolveNeededTreatmentItems(roomName)
                        if #needed == 0 then break end

                        attempt = attempt + 1
                        local currentItem = needed[1]

                        local itemsList = {}
                        for idx, it in ipairs(needed) do table.insert(itemsList, string.format("%d=%s", idx, it)) end
                        local neededStr = "{" .. table.concat(itemsList, ", ") .. "}"

                        Log("AutoTreatment", "Treatment item loop", {
                            attempt = attempt,
                            currentItem = currentItem,
                            isSkinwalker = "false",
                            medicineCount = GetMedicineItemCount(),
                            neededItems = neededStr,
                            npc = patient and patient:GetFullName() or inBed:GetFullName(),
                            room = roomName,
                            shouldKill = "false"
                        })

                        if GetItemCount(currentItem) == 0 then
                            Log("Inventory", "Tool not found in inventory", { item = currentItem })
                            GrabItemUntilInInventory(currentItem, roomName)
                        end

                        if GetItemCount(currentItem) > 0 then
                            UseInventoryTool(currentItem)
                            TeleportPlayer(inBedPos + Vector3.new(0, 1.0, 0))
                            task.wait(0.2)

                            local treatPP = inBed:FindFirstChild("PP") or inBed:FindFirstChild("PP2") or inBed:FindFirstChildWhichIsA("ProximityPrompt", true)
                            if treatPP then
                                Log("AutoTreatment", "Delivering treatment item to bed", {
                                    prompt = treatPP:GetFullName(),
                                    room = roomName,
                                    targetItem = currentItem
                                })

                                PressPromptNearbyUntil(treatPP, 0.15, 2.5, function()
                                    return GetItemCount(currentItem) == 0
                                end)
                            end
                            task.wait(0.4)
                        end
                    end

                    if patient then _G.AH_TreatedPatients[patient] = true end
                    _G.AH_IsTreating = false
                    Log("AutoTreatment", "Finished patient treatment", { npc = patient and patient:GetFullName() or inBed:GetFullName(), room = roomName })
                    return true
                end
            end
        end
    end

    _G.AH_IsTreating = false
    return false
end

local function ExecuteTreatmentCycle()
    if not _G.AutoTreatment then return end

    if TreatRoom8Surgery() then return end
    if TreatRoom7Emergency() then return end
    if TreatRoom6Emergency() then return end
    if TreatMedicalRooms() then return end

    _G.AH_IsTreating = false
end

-- ☕ 9. AUTO BARNEY COFFEE
local function ProcessBarneyCoffee()
    if not _G.AutoGiveBarneyCoffee then return end
    local npcs = Workspace:FindFirstChild("NPCs")
    local barney = npcs and npcs:FindFirstChild("Barney")
    if not barney then return end

    local barneyPP = barney:FindFirstChild("PP") or barney:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not barneyPP or not barneyPP.Enabled then return end

    local act = NormalizeName(barneyPP.ActionText or "")
    if act:find("coffee") or act:find("give") or act:find("feed") then
        Log("AutoBarneyCoffee", "Barney requests coffee", { prompt = barneyPP:GetFullName() })
        GrabItemUntilInInventory("Coffee")
        if GetItemCount("Coffee") > 0 then
            UseInventoryTool("Coffee")
            TeleportPlayer(Positions.Barney)
            task.wait(0.2)
            PressPromptNearbyUntil(barneyPP, 0.15, 2.0, function()
                return GetItemCount("Coffee") == 0
            end)
        end
    end
end

-- 🚪 10. AUTO SHUTTER & ANOMALY EVALUATION
local function GetClosestCounterNpc()
    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return nil, false end

    local counterPos = Positions.CheckInCounter or Vector3.new(-103.91, 3.41, -0.40)
    local closestNpc = nil
    local minDistance = math.huge

    for _, npc in ipairs(npcs:GetChildren()) do
        if npc:IsA("Model") and IsValidPatient(npc) then
            local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso") or npc:FindFirstChildWhichIsA("BasePart")
            if root then
                local dist = (root.Position - counterPos).Magnitude
                if dist <= 25 then
                    if dist < minDistance then
                        closestNpc = npc
                        minDistance = dist
                    end
                end
            end
        end
    end

    if closestNpc then
        return closestNpc, IsNpcThreat(closestNpc)
    end
    return nil, false
end

local function EvaluateCounterThreats()
    if not _G.AutoAnomalyShutter and not _G.AutoBarneyShutter then return end

    local shutterPP = Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("ShutterButton") and Workspace.Misc.ShutterButton:FindFirstChild("PP")
    local counterNpc, isThreat = GetClosestCounterNpc()

    if counterNpc then
        Log("AutoShutter", "Evaluating counter NPC", { isThreat = tostring(isThreat), npc = counterNpc:GetFullName() })

        if isThreat then
            _G.HasActiveThreat = true
            if shutterPP and shutterPP.Enabled and not _G.IsShutterClosed then
                Log("AutoShutter", "Closed shutter for threat", { npc = counterNpc:GetFullName() })
                TeleportAndFirePrompt(shutterPP, Positions.ShutterButton, 0.3)
                _G.IsShutterClosed = true
                task.wait(0.5)
            end

            if _G.AutoAskLeaveAnomaly then
                local askPP = counterNpc:FindFirstChild("PP") or counterNpc:FindFirstChildWhichIsA("ProximityPrompt", true)
                if askPP and askPP.Enabled and (askPP.ActionText or ""):find("Ask") then
                    Log("AutoAskLeaveAnomaly", "Pressing Ask To Leave prompt", { npc = counterNpc:GetFullName(), prompt = askPP:GetFullName() })
                    TeleportAndFirePrompt(askPP, Positions.AskToLeave, 0.4)
                    task.wait(0.5)
                end
            end
        else
            _G.HasActiveThreat = false
            if shutterPP and shutterPP.Enabled and _G.IsShutterClosed then
                Log("AutoShutter", "Opening shutter for normal patient at check-in")
                TeleportAndFirePrompt(shutterPP, Positions.ShutterButton, 0.3)
                _G.IsShutterClosed = false
                task.wait(0.5)
            end
        end
    else
        _G.HasActiveThreat = false
        if shutterPP and shutterPP.Enabled and _G.IsShutterClosed then
            Log("AutoShutter", "Opening shutter after threat left check-in")
            TeleportAndFirePrompt(shutterPP, Positions.ShutterButton, 0.3)
            _G.IsShutterClosed = false
            task.wait(0.5)
        end
    end
end

-- 🏢 11. AUTO CHECK IN (ПОЛНЫЙ ЦИКЛ РЕГИСТРАЦИИ КЛИЕНТОВ)
local function GetPatientAtCounter()
    if _G.IsShutterClosed or _G.HasActiveThreat then return nil end

    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return nil end

    local counterSpot = Vector3.new(-103.91, 3.41, -0.40)
    for _, npc in ipairs(npcs:GetChildren()) do
        if npc:IsA("Model") and IsValidPatient(npc) then
            local isThreat = (npc:GetAttribute("Skinwalker") == true or npc:GetAttribute("Threat") == true or npc:GetAttribute("Anomaly") == true)
            if not isThreat then
                local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso") or npc:FindFirstChildWhichIsA("BasePart")
                if root then
                    local dist = (root.Position - counterSpot).Magnitude
                    if dist <= 25 then
                        return npc
                    end
                end
            end
        end
    end
    return nil
end

local function ExecuteCheckInCycle()
    if not _G.AutoCheckIn or _G.IsShutterClosed or _G.HasActiveThreat or _G.AH_IsTreating then return end

    local misc = Workspace:FindFirstChild("Misc")
    local checkIn = misc and misc:FindFirstChild("CheckIn")
    if not checkIn then return end

    local patient = GetPatientAtCounter()
    local pcPP = checkIn:FindFirstChild("Computer") and (checkIn.Computer:FindFirstChild("PP") or checkIn.Computer:FindFirstChildWhichIsA("ProximityPrompt", true))
    local formPP = checkIn:FindFirstChild("Form") and (checkIn.Form:FindFirstChild("PP") or checkIn.Form:FindFirstChildWhichIsA("ProximityPrompt", true))
    local camPP = checkIn:FindFirstChild("Camera") and (checkIn.Camera:FindFirstChild("PP") or checkIn.Camera:FindFirstChildWhichIsA("ProximityPrompt", true))
    local printerPP = checkIn:FindFirstChild("Printer") and (checkIn.Printer:FindFirstChild("PP") or checkIn.Printer:FindFirstChildWhichIsA("ProximityPrompt", true))
    local badgePP = checkIn:FindFirstChild("PrintedBadge") and (checkIn.PrintedBadge:FindFirstChild("PP") or checkIn.PrintedBadge:FindFirstChildWhichIsA("ProximityPrompt", true))

    if not patient and not (formPP and formPP.Enabled) and not (camPP and camPP.Enabled) and not (pcPP and pcPP.Enabled) and not (printerPP and printerPP.Enabled) and not (badgePP and badgePP.Enabled) then
        return
    end

    Log("AutoCheckIn", "Starting check-in cycle")

    -- 1. Stamp Forms
    if formPP and formPP.Enabled then
        TeleportAndFirePrompt(formPP, Positions.CheckInForm, 0.4)
        task.wait(0.4)
    end

    -- 2. Take Photo
    if camPP and camPP.Enabled then
        TeleportAndFirePrompt(camPP, Positions.CheckInCamera, 0.4)
        task.wait(0.4)
    end

    -- 3. Register on Computer
    if pcPP and pcPP.Enabled then
        local pcPos = GetPromptPartPosition(pcPP) or Positions.CheckInPC
        TeleportPlayer(pcPos + Vector3.new(0, 0, 1.5))
        task.wait(0.2)
        FirePrompt(pcPP)
        task.wait(0.5)
    end

    -- 4. Print Badge
    printerPP = checkIn:FindFirstChild("Printer") and (checkIn.Printer:FindFirstChild("PP") or checkIn.Printer:FindFirstChildWhichIsA("ProximityPrompt", true))
    if printerPP and printerPP.Enabled then
        Log("AutoCheckIn", "Printing badge", { attempt = 1, patient = patient and patient:GetFullName() or "Workspace.NPCs.Patient", prompt = printerPP:GetFullName() })
        TeleportAndFirePrompt(printerPP, Positions.CheckInPrinter, 0.4)
        task.wait(2.0)
    end

    -- 5. Take Badge
    badgePP = checkIn:FindFirstChild("PrintedBadge") and (checkIn.PrintedBadge:FindFirstChild("PP") or checkIn.PrintedBadge:FindFirstChildWhichIsA("ProximityPrompt", true))
    if badgePP and badgePP.Enabled then
        TeleportAndFirePrompt(badgePP, Positions.PrintedBadge, 0.4)
        task.wait(0.5)
    end

    -- 6. Give Badge to Patient
    if patient then
        local givePP = patient:FindFirstChild("PP") or patient:FindFirstChildWhichIsA("ProximityPrompt", true)
        if givePP and givePP.Enabled then
            TeleportAndFirePrompt(givePP, Positions.CheckInCounter, 0.4)
            task.wait(0.5)
        end
    end
end


