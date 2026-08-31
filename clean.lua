-- ══════════════════════════════════════════════════════════════════════════════════
-- 🏥 AVERLIK HUB: ANIMAL HOSPITAL ULTIMATE MASTER SUITE (V3.0 HYPER-REACTIVE)
-- ══════════════════════════════════════════════════════════════════════════════════

-- ⚙️ GLOBAL TOGGLES & SETTINGS
_G.AutoCheckIn = _G.AutoCheckIn ~= nil and _G.AutoCheckIn or true
_G.AutoAnomalyShutter = _G.AutoAnomalyShutter ~= nil and _G.AutoAnomalyShutter or true
_G.AutoBarneyShutter = _G.AutoBarneyShutter ~= nil and _G.AutoBarneyShutter or true
_G.AutoAskLeaveAnomaly = _G.AutoAskLeaveAnomaly ~= nil and _G.AutoAskLeaveAnomaly or true
_G.AutoTreatment = _G.AutoTreatment ~= nil and _G.AutoTreatment or true
_G.AutoGiveBarneyCoffee = _G.AutoGiveBarneyCoffee ~= nil and _G.AutoGiveBarneyCoffee or true
_G.AutoCleanSlime = _G.AutoCleanSlime ~= nil and _G.AutoCleanSlime or true
_G.AutoBuyShop = _G.AutoBuyShop ~= nil and _G.AutoBuyShop or false
_G.AutoHelpPatient = _G.AutoHelpPatient ~= nil and _G.AutoHelpPatient or true
_G.AutoKillSkinwalker = _G.AutoKillSkinwalker ~= nil and _G.AutoKillSkinwalker or true
_G.LoopInterval = 0.15

-- 📌 RUNTIME STATE
_G.IsShutterClosed = false
_G.HasActiveThreat = false
_G.AH_IsTreating = false
_G.AH_TreatedPatients = {}

-- ══════════════════════════════════════════════════════════════════════════════════
-- 📍 1. PRECISE MILLIMETER COORDINATES (EXTRACTED FROM GAME DUMP)
-- ══════════════════════════════════════════════════════════════════════════════════
local Positions = {
    -- Регистрация
    CheckInPC = Vector3.new(-97.68, 3.50, -2.50),
    CheckInForm = Vector3.new(-100.80, 4.41, 1.48),
    CheckInCamera = Vector3.new(-96.65, 4.41, 1.63),
    CheckInPrinter = Vector3.new(-97.68, 4.41, 3.63),
    CheckInBadge = Vector3.new(-97.68, 4.41, 3.63),
    PrintedBadge = Vector3.new(-97.68, 4.41, 3.63),
    CheckInCounter = Vector3.new(-103.91, 3.41, -0.40),
    ShutterButton = Vector3.new(-103.91, 5.00, 3.80),
    AskToLeave = Vector3.new(-103.91, 3.41, -0.40),

    -- Барни и Кофе
    Barney = Vector3.new(-149.20, 3.46, -2.50),
    CoffeeMachine = Vector3.new(-142.10, 3.46, -15.20),
    Coffee = Vector3.new(-142.10, 3.46, -15.20),
    Trash = Vector3.new(-144.50, 3.46, -18.50),

    -- Палаты 1 - 5 (Терапия)
    Room1_Bed = Vector3.new(-168.22, 3.19, -41.90),
    Room1_Device = Vector3.new(-180.76, 4.74, -45.91),
    Room1_TV = Vector3.new(-168.22, 8.67, -37.67),

    Room2_Bed = Vector3.new(-121.37, 3.19, -58.74),
    Room2_Device = Vector3.new(-108.74, 4.74, -54.71),
    Room2_TV = Vector3.new(-121.29, 8.67, -63.27),

    Room3_Bed = Vector3.new(-168.22, 3.19, -81.10),
    Room3_Device = Vector3.new(-180.76, 4.74, -85.12),
    Room3_TV = Vector3.new(-168.22, 8.67, -76.87),

    Room4_Bed = Vector3.new(-121.28, 3.19, -98.24),
    Room4_Device = Vector3.new(-108.74, 4.74, -92.52),
    Room4_TV = Vector3.new(-121.29, 8.67, -102.47),

    Room5_Bed = Vector3.new(-153.42, 3.19, -114.74),
    Room5_Device = Vector3.new(-149.41, 4.74, -127.28),
    Room5_TV = Vector3.new(-157.65, 8.67, -114.73),

    -- Палата 6 (Рентген / X-Ray)
    Room6_Bed = Vector3.new(-181.83, 3.91, 54.08),
    Room6_XrayStart = Vector3.new(-176.77, 2.90, 54.93),
    Room6_XrayMonitor = Vector3.new(-169.33, 4.73, 63.33),
    Room6_PrintedXRay = Vector3.new(-166.05, 3.65, 63.60),
    Room6_TV = Vector3.new(-166.08, 9.24, 64.89),

    -- Палата 7 (Реанимация / ICU)
    Room7_Bed = Vector3.new(-106.53, 3.24, 52.13),
    Room7_Monitor = Vector3.new(-125.52, 4.78, 63.27),
    Room7_PrintedXRay = Vector3.new(-128.50, 4.78, 63.27),
    Room7_TV = Vector3.new(-100.79, 8.64, 51.97),

    -- Палата 8 (Хирургия)
    Room8_Bed = Vector3.new(-144.89, 3.56, 99.59),
    Room8_Monitor = Vector3.new(-134.63, 4.78, 85.74),
    Room8_TV = Vector3.new(-144.93, 8.34, 114.49),
    Room8_Scalpel = Vector3.new(-147.20, 3.56, 102.50),
    Room8_Scissors = Vector3.new(-147.20, 3.56, 101.50),
    Room8_Organ = Vector3.new(-147.20, 3.56, 100.50),
    Room8_Transplant = Vector3.new(-147.20, 3.56, 99.50),

    -- Шкафы с медикаментами
    Shelf_Herbs = Vector3.new(-137.12, 3.46, -57.82),
    Shelf_MapleSyrup = Vector3.new(-137.12, 3.46, -60.82),
    Shelf_EyeDrops = Vector3.new(-137.12, 3.46, -63.82),
    Shelf_Pills = Vector3.new(-137.12, 3.46, -66.82),
    Shelf_Bandages = Vector3.new(-137.12, 3.46, -69.82),
    Shelf_Thermometer = Vector3.new(-137.12, 3.46, -72.82),
    Shelf_CoughSyrup = Vector3.new(-137.12, 3.46, -75.82),
    Shelf_Ointment = Vector3.new(-137.12, 3.46, -78.82),
    Shelf_Plaster = Vector3.new(-137.12, 3.46, -81.82),
    Shelf_FirstAidKit = Vector3.new(-137.12, 3.46, -84.82)
}

-- ══════════════════════════════════════════════════════════════════════════════════
-- 📜 2. LOGGING ENGINE
-- ══════════════════════════════════════════════════════════════════════════════════
local function Log(category, message, details)
    local dt = os.date("%H:%M:%S")
    local str = string.format("[%s] [%s] %s", dt, category, message)
    if details then
        local pairsArr = {}
        for k, v in pairs(details) do
            table.insert(pairsArr, string.format("%s=%s", tostring(k), tostring(v)))
        end
        if #pairsArr > 0 then
            str = str .. " | " .. table.concat(pairsArr, " | ")
        end
    end
    print(str)
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🔍 3. ANOMALY & THREAT RECOGNITION (100% ACCURATE GAME ENGINE TAGS)
-- ══════════════════════════════════════════════════════════════════════════════════
local function IsValidPatient(npc)
    if not npc or not npc:IsA("Model") then return false end
    local name = string.lower(npc.Name)
    if name:find("barney") or name == "cleaner" or name == "guard" then return false end
    return true
end

local function IsBarney(npc)
    if not npc or not npc:IsA("Model") then return false end
    return string.find(string.lower(npc.Name), "barney") ~= nil
end

local function IsNpcThreat(npc)
    if not npc or not npc:IsA("Model") then return false end

    if IsBarney(npc) then
        return _G.AutoBarneyShutter == true
    end

    if _G.AutoAnomalyShutter then
        if npc:GetAttribute("Skinwalker") == true or npc:GetAttribute("Threat") == true or npc:GetAttribute("Anomaly") == true then
            return true
        end
        local name = string.lower(npc.Name)
        if name:find("skinwalker") or name:find("slimewalker") or name:find("anomaly") then
            return true
        end
    end

    return false
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🏃 4. MOVEMENT & PROXIMITY ENGINE
-- ══════════════════════════════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetRootPart()
    local char = GetCharacter()
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChildWhichIsA("BasePart"))
end

local function TeleportPlayer(targetPos)
    local root = GetRootPart()
    if root and targetPos then
        root.CFrame = CFrame.new(targetPos + Vector3.new(0, 1.0, 0))
    end
end

local function GetPromptPartPosition(prompt)
    if not prompt then return nil end
    local parent = prompt.Parent
    if parent:IsA("BasePart") then return parent.Position end
    if parent:IsA("Model") then
        local prim = parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart")
        if prim then return prim.Position end
        return parent:GetPivot().Position
    end
    if parent:IsA("Attachment") then return parent.WorldPosition end
    return nil
end

local function FirePrompt(prompt, holdTime)
    if not prompt or not prompt.Enabled then return end
    prompt.HoldDuration = 0
    if fireproximityprompt then
        fireproximityprompt(prompt, holdTime or 0)
    end
    if prompt.InputHoldBegin and prompt.InputHoldEnd then
        prompt:InputHoldBegin()
        task.wait(holdTime or 0.05)
        prompt:InputHoldEnd()
    end
end

local function TeleportAndFirePrompt(prompt, fallbackPos, waitAfter)
    if not prompt or not prompt.Enabled then return false end
    local targetPos = GetPromptPartPosition(prompt) or fallbackPos
    if targetPos then
        TeleportPlayer(targetPos)
        task.wait(0.15)
    end
    FirePrompt(prompt)
    if waitAfter then task.wait(waitAfter) end
    return true
end

local function PressPromptNearbyUntil(prompt, interval, timeout, condition)
    local start = os.clock()
    while os.clock() - start < timeout do
        if not prompt or not prompt.Parent or not prompt.Enabled then break end
        if condition and condition() then break end
        FirePrompt(prompt)
        task.wait(interval or 0.15)
    end
end

local function StopCheck()
    return not _G.AutoTreatment and not _G.AutoCheckIn
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🎒 5. INVENTORY & TOOL CONTROL ENGINE
-- ══════════════════════════════════════════════════════════════════════════════════
local function NormalizeName(str)
    if not str then return "" end
    local s = string.lower(tostring(str))
    s = string.gsub(s, "%s+", "")
    s = string.gsub(s, "[_%-%.]", "")
    return s
end

local function InventoryContainers()
    local containers = {}
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then table.insert(containers, backpack) end
    local char = LocalPlayer.Character
    if char then table.insert(containers, char) end
    return containers
end

local function FindToolInInventory(itemName)
    local target = NormalizeName(itemName)
    for _, container in ipairs(InventoryContainers()) do
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") then
                local toolNorm = NormalizeName(tool.Name)
                if toolNorm == target or toolNorm:find(target) or (target:find(toolNorm) and #toolNorm >= 4) then
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
                local toolNorm = NormalizeName(tool.Name)
                if toolNorm == target or toolNorm:find(target) or (target:find(toolNorm) and #toolNorm >= 4) then
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
                count = count + 1
            end
        end
    end
    return count
end

local function UnequipAllTools()
    local char = GetCharacter()
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:UnequipTools()
        task.wait(0.1)
    end
end

local function UseInventoryTool(itemName)
    local char = GetCharacter()
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end

    local tool = FindToolInInventory(itemName)
    if tool then
        if tool.Parent ~= char then
            humanoid:UnequipTools()
            task.wait(0.1)
            humanoid:EquipTool(tool)
            task.wait(0.2)
        end
        return true
    end
    return false
end

local function DiscardToolAtTrash(tool)
    if not tool then return end
    Log("Inventory", "Discarding tool at trash", { tool = tool.Name })
    TeleportPlayer(Positions.Trash)
    task.wait(0.2)
    local trashBin = Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("Trash")
    local trashPP = trashBin and (trashBin:FindFirstChild("PP") or trashBin:FindFirstChildWhichIsA("ProximityPrompt", true))
    if trashPP then
        FirePrompt(trashPP)
        task.wait(0.3)
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 📺 6. TV REPORT & RECOVERY DETECTION ENGINE (AUTHENTIC GAME MATCHING)
-- ══════════════════════════════════════════════════════════════════════════════════
local AssetToItemMap = {
    ['rbxassetid://139637091303873'] = 'Eye Drops',
    ['rbxassetid://118311058179090'] = 'IV Drops',
    ['rbxassetid://88750936127655'] = 'Medkit',
    ['rbxassetid://138334905913311'] = 'Thermometer',
    ['rbxassetid://75884870805308'] = 'Ointment',
    ['rbxassetid://125453071439049'] = 'Bandages',
    ['rbxassetid://135236061613718'] = 'Medicine',
    ['rbxassetid://113912761080559'] = 'Maple Syrup',
    ['rbxassetid://120895273610611'] = 'Cough Syrup',
    ['rbxassetid://94559086254344'] = 'Herbs',
    ['rbxassetid://132258407294719'] = 'Antibiotics',
    ['rbxassetid://102550407034117'] = 'Organ',
    ['rbxassetid://137637637347521'] = 'Transplant',
    ['rbxassetid://93721219255457'] = 'Scalpel',
    ['rbxassetid://97305931082100'] = 'Scissors'
}

local function GetRoomFolder(roomName)
    local rooms = Workspace:FindFirstChild("Rooms")
    if not rooms then return nil end
    local num = tonumber(tostring(roomName):match("%d+"))
    if num and num >= 6 then
        return rooms:FindFirstChild("Emergency")
    else
        return rooms:FindFirstChild("Medical")
    end
end

local function IsItemChecked(guiItem)
    if not guiItem then return false end
    local check = guiItem:FindFirstChild("check") or guiItem:FindFirstChild("Check") or guiItem:FindFirstChild("tick") or guiItem:FindFirstChild("Tick")
    if check and check:IsA("GuiObject") then
        local ok, vis = pcall(function() return check.Visible end)
        if ok and vis == true then return true end
    end
    return false
end

local function IsRoomRecovering(room)
    if not room then return false end
    local roomFolder = GetRoomFolder(room.Name)
    if not roomFolder then return false end

    local ok, healing, header = pcall(function()
        local ui = room.Minigame.TV.Screen.UI
        return ui.Healing, ui.Healing.header
    end)
    if ok and healing and header then
        local curr = header
        local visible = true
        while curr and curr ~= roomFolder do
            if curr:IsA("GuiObject") and curr.Visible == false then
                visible = false
                break
            end
            curr = curr.Parent
        end
        if visible then
            local text = string.lower(tostring(header.Text or ""))
            if (text:find("patient") and text:find("recover")) or text:find("heal") or text:find("recovering") then
                return true
            end
        end
    end

    local minigame = room:FindFirstChild("Minigame")
    local tv = minigame and minigame:FindFirstChild("TV")
    local ui = tv and tv:FindFirstChild("Screen") and tv.Screen:FindFirstChild("UI")
    if ui then
        local h = ui:FindFirstChild("Healing")
        if h and h:IsA("GuiObject") and h.Visible then return true end
        local f = ui:FindFirstChild("Failed")
        if f and f:IsA("GuiObject") and f.Visible then return true end
    end

    return false
end

local function ResolveNeededTreatmentItems(roomName)
    local needed = {}
    local roomFolder = GetRoomFolder(roomName)
    if not roomFolder then return needed end

    local room = roomFolder:FindFirstChild(roomName)
    if not room or IsRoomRecovering(room) then
        return needed
    end

    local tv = room:FindFirstChild("Minigame") and room.Minigame:FindFirstChild("TV")
    local reportInv = tv and tv:FindFirstChild("Screen") and tv.Screen:FindFirstChild("UI") and tv.Screen.UI:FindFirstChild("Report") and tv.Screen.UI.Report:FindFirstChild("inv")

    if reportInv then
        for _, child in ipairs(reportInv:GetChildren()) do
            if child:IsA("GuiObject") and child.Visible then
                if not IsItemChecked(child) then
                    local matched = nil
                    if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                        matched = AssetToItemMap[child.Image]
                    end
                    if not matched then
                        local icon = child:FindFirstChildWhichIsA("ImageLabel", true)
                        if icon then matched = AssetToItemMap[icon.Image] end
                    end
                    if not matched then
                        matched = child.Name
                    end
                    if matched and not table.find(needed, matched) then
                        table.insert(needed, matched)
                    end
                end
            end
        end
    end

    return needed
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🧰 7. UNIVERSAL SHELF RESOLVER & STRICT SINGLE-ITEM GRABBER
-- ══════════════════════════════════════════════════════════════════════════════════
local function GetItemPrompt(itemName, isSurgery)
    local target = NormalizeName(itemName)

    -- 1. Хирургия Палаты 8
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

    -- 2. Глобальный поиск по предкам ProximityPrompt
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

            if match then return prompt end
        end
    end

    return nil
end

local function GrabItemUntilInInventory(itemName, roomName)
    if GetItemCount(itemName) > 0 then return true end

    for _, container in ipairs(InventoryContainers()) do
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") and NormalizeName(tool.Name) ~= NormalizeName(itemName) then
                DiscardToolAtTrash(tool)
            end
        end
    end

    local isSurgery = (roomName == "Room8")
    local prompt = GetItemPrompt(itemName, isSurgery)
    local shelfPos = (prompt and GetPromptPartPosition(prompt)) or Positions[itemName:gsub("%s+", "")] or Positions["Shelf_" .. itemName:gsub("%s+", "")] or Positions["Room8_" .. itemName:gsub("%s+", "")]

    if prompt and shelfPos then
        Log("AutoTreatment", "Grabbing single treatment item", {
            countBefore = GetItemCount(itemName),
            prompt = prompt:GetFullName(),
            room = roomName or "Room1",
            targetItem = itemName
        })

        TeleportPlayer(shelfPos + Vector3.new(0, 1.0, 1.5))
        task.wait(0.25)

        local countBefore = GetItemCount(itemName)
        FirePrompt(prompt)

        local t = os.clock()
        while os.clock() - t < 1.5 and not StopCheck() do
            if GetItemCount(itemName) > countBefore then break end
            task.wait(0.05)
        end
        task.wait(0.2)
    end

    return GetItemCount(itemName) > 0
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🩺 8. MULTI-WARD SAFE TREATMENT ENGINE (WITH COMPLETE PATIENT CACHE SAFETY)
-- ══════════════════════════════════════════════════════════════════════════════════
local function IsPatientAlreadyTreated(npc)
    if not npc then return false end
    local t = _G.AH_TreatedPatients[npc]
    if t then
        if type(t) == "boolean" and t == true then return true end
        if type(t) == "number" and os.clock() < t then return true end
    end
    return false
end

local function MarkPatientTreated(npc)
    if not npc then return end
    _G.AH_TreatedPatients[npc] = os.clock() + 45.0
end

local function GetPatientInRoom(roomName, bedPos)
    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return nil end

    for _, npc in ipairs(npcs:GetChildren()) do
        if npc:IsA("Model") and IsValidPatient(npc) then
            if not IsPatientAlreadyTreated(npc) then
                local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso") or npc:FindFirstChildWhichIsA("BasePart")
                if root then
                    local dist = (root.Position - bedPos).Magnitude
                    if dist <= 12 then
                        return npc
                    end
                end
            end
        end
    end
    return nil
end

-- Палата 8 (Хирургия)
local function TreatRoom8Surgery()
    local room8 = Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Emergency") and Workspace.Rooms.Emergency:FindFirstChild("Room8")
    if not room8 or IsRoomRecovering(room8) then return false end

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
        if IsRoomRecovering(room8) then
            Log("AutoTreatment", "Patient is recovering, stopping surgery", { room = "Room8" })
            break
        end

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
                FirePrompt(currentTreatPP)
                task.wait(0.4)
                UnequipAllTools()

                local waitTimeout = os.clock() + 4.0
                while os.clock() < waitTimeout and not StopCheck() do
                    if IsRoomRecovering(room8) then break end
                    local curNeeded = ResolveNeededTreatmentItems("Room8")
                    local stillInReport = false
                    for _, it in ipairs(curNeeded) do
                        if it == currentItem then stillInReport = true break end
                    end
                    if not stillInReport then
                        Log("AutoTreatment", "Item successfully applied and checked off TV", { item = currentItem, room = "Room8" })
                        break
                    end
                    task.wait(0.25)
                end
            end
        end
    end

    if attempt > 0 or IsRoomRecovering(room8) then
        if patient then MarkPatientTreated(patient) end
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
    if not room7 or IsRoomRecovering(room7) then return false end

    local minigame = room7:FindFirstChild("Minigame")
    if not minigame then return false end

    local inBed = minigame and minigame:FindFirstChild("Bed") and minigame.Bed:FindFirstChild("InBed")
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
            if IsRoomRecovering(room7) then
                Log("AutoTreatment", "Patient is recovering, stopping ICU treatment", { room = "Room7" })
                break
            end

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
                    FirePrompt(treatPP)
                    task.wait(0.4)
                    UnequipAllTools()

                    local waitTimeout = os.clock() + 4.0
                    while os.clock() < waitTimeout and not StopCheck() do
                        if IsRoomRecovering(room7) then break end
                        local curNeeded = ResolveNeededTreatmentItems("Room7")
                        local stillInReport = false
                        for _, it in ipairs(curNeeded) do
                            if it == currentItem then stillInReport = true break end
                        end
                        if not stillInReport then
                            Log("AutoTreatment", "Item successfully applied and checked off TV", { item = currentItem, room = "Room7" })
                            break
                        end
                        task.wait(0.25)
                    end
                end
            end
        end

        if patient then MarkPatientTreated(patient) end
        _G.AH_IsTreating = false
        return true
    end

    _G.AH_IsTreating = false
    return false
end

-- ☢️ ПАЛАТА 6 (РЕАНИМАЦИЯ / РЕНТГЕН - X-RAY ROOM 6)
local function TreatRoom6Emergency()
    local room6 = Workspace:FindFirstChild("Rooms") and Workspace.Rooms:FindFirstChild("Emergency") and Workspace.Rooms.Emergency:FindFirstChild("Room6")
    if not room6 or IsRoomRecovering(room6) then return false end

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
            if npc:IsA("Model") and IsValidPatient(npc) and not IsPatientAlreadyTreated(npc) then
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
            if IsRoomRecovering(room6) then
                Log("AutoTreatment", "Patient is recovering, stopping X-Ray treatment", { room = "Room6" })
                break
            end

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
                    FirePrompt(treatPP)
                    task.wait(0.4)
                    UnequipAllTools()

                    local waitTimeout = os.clock() + 4.0
                    while os.clock() < waitTimeout and not StopCheck() do
                        if IsRoomRecovering(room6) then break end
                        local curNeeded = ResolveNeededTreatmentItems("Room6")
                        local stillInReport = false
                        for _, it in ipairs(curNeeded) do
                            if it == currentItem then stillInReport = true break end
                        end
                        if not stillInReport then
                            Log("AutoTreatment", "Item successfully applied and checked off TV", { item = currentItem, room = "Room6" })
                            break
                        end
                        task.wait(0.25)
                    end
                end
            end
        end

        if patient then MarkPatientTreated(patient) end
        _G.AH_IsTreating = false
        Log("AutoTreatment", "Finished patient treatment", { npc = patient and patient:GetFullName() or "Room6.Patient", room = "Room6" })
        return true
    end

    _G.AH_IsTreating = false
    return false
end

-- 🏥 ПАЛАТЫ 1 - 5 (DIRECT MEDICAL DIAGNOSIS & CACHE PROTECTION)
local function TreatMedicalRooms()
    local rooms = Workspace:FindFirstChild("Rooms")
    local medical = rooms and rooms:FindFirstChild("Medical")
    if not medical then return false end

    for i = 1, 5 do
        local roomName = "Room" .. tostring(i)
        local room = medical:FindFirstChild(roomName)
        if room and not IsRoomRecovering(room) then
            local minigame = room:FindFirstChild("Minigame")
            local inBed = minigame and minigame:FindFirstChild("Bed") and minigame.Bed:FindFirstChild("InBed")
            local monitor = minigame and minigame:FindFirstChild("Monitor")
            local analyzer = minigame and minigame:FindFirstChild("Analyzer")

            if inBed then
                local inBedPos = (inBed:IsA("BasePart") and inBed.Position) or (inBed:GetPivot().Position)

                local patient = nil
                local npcsFolder = Workspace:FindFirstChild("NPCs")
                if npcsFolder then
                    for _, npc in ipairs(npcsFolder:GetChildren()) do
                        if npc:IsA("Model") and IsValidPatient(npc) and not IsPatientAlreadyTreated(npc) then
                            local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso") or npc:FindFirstChildWhichIsA("BasePart")
                            if root and (root.Position - inBedPos).Magnitude <= 10 then
                                patient = npc
                                break
                            end
                        end
                    end
                end

                local needed = ResolveNeededTreatmentItems(roomName)

                -- Если есть НЕОБРАБОТАННЫЙ пациент, но рецепта на ТВ нет -> проводим диагностику
                if #needed == 0 and patient and not IsPatientAlreadyTreated(patient) and not IsRoomRecovering(room) then
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

                    -- Взятие ДНК
                    if dnaPP and dnaPP.Enabled then
                        _G.AH_IsTreating = true
                        Log("AutoTreatment", "Taking DNA sample", { prompt = dnaPP:GetFullName(), room = roomName })
                        TeleportPlayer(inBedPos + Vector3.new(0, 1.0, 0))
                        task.wait(0.2)
                        FirePrompt(dnaPP)
                        task.wait(0.6)
                    end

                    -- Анализатор (Analyzer)
                    local analyzerPP = analyzer and (analyzer:FindFirstChild("PP") or analyzer:FindFirstChildWhichIsA("ProximityPrompt", true))
                    if analyzerPP and analyzerPP.Enabled then
                        Log("AutoTreatment", "Analyzing sample in analyzer", { prompt = analyzerPP:GetFullName(), room = roomName })
                        TeleportAndFirePrompt(analyzerPP, (analyzer:IsA("BasePart") and analyzer.Position) or inBedPos, 0.4)
                        task.wait(1.5)
                    end

                    -- Монитор (Monitor PP2)
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

                -- Доставка лекарств по рецепту ТВ (например, Herbs)
                if #needed > 0 and patient and not IsPatientAlreadyTreated(patient) then
                    _G.AH_IsTreating = true
                    Log("AutoTreatment", "Starting patient treatment", {
                        emergency = "false",
                        neededItems = table.concat(needed, ", "),
                        npc = patient:GetFullName(),
                        room = roomName
                    })

                    local attempt = 0
                    while _G.AutoTreatment and not StopCheck() do
                        if IsRoomRecovering(room) then
                            Log("AutoTreatment", "Patient is recovering, stopping treatment", { room = roomName })
                            break
                        end

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
                            npc = patient:GetFullName(),
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

                                FirePrompt(treatPP)
                                task.wait(0.4)
                                UnequipAllTools()

                                local waitTimeout = os.clock() + 4.0
                                while os.clock() < waitTimeout and not StopCheck() do
                                    if IsRoomRecovering(room) then break end
                                    local curNeeded = ResolveNeededTreatmentItems(roomName)
                                    local stillInReport = false
                                    for _, it in ipairs(curNeeded) do
                                        if it == currentItem then stillInReport = true break end
                                    end
                                    if not stillInReport then
                                        Log("AutoTreatment", "Item successfully applied and checked off TV", { item = currentItem, room = roomName })
                                        break
                                    end
                                    task.wait(0.25)
                                end
                            end
                        end
                    end

                    for _, container in ipairs(InventoryContainers()) do
                        for _, tool in ipairs(container:GetChildren()) do
                            if tool:IsA("Tool") then
                                DiscardToolAtTrash(tool)
                            end
                        end
                    end

                    if patient then MarkPatientTreated(patient) end
                    _G.AH_IsTreating = false
                    Log("AutoTreatment", "Finished patient treatment", { npc = patient:GetFullName(), room = roomName })
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

-- ══════════════════════════════════════════════════════════════════════════════════
-- ☕ 9. AUTO BARNEY COFFEE
-- ══════════════════════════════════════════════════════════════════════════════════
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

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🚪 10. AUTO SHUTTER & ANOMALY EVALUATION (STATE-AWARE PROMPT LOGIC)
-- ══════════════════════════════════════════════════════════════════════════════════
local function IsShutterClosed()
    local btn = Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("ShutterButton")
    local pp = btn and (btn:FindFirstChild("PP") or btn:FindFirstChildWhichIsA("ProximityPrompt", true))
    if pp then
        local act = string.lower(tostring(pp.ActionText or ""))
        return act:find("open") ~= nil
    end
    return false
end

local function SetShutterState(shouldBeClosed, reasonNpc)
    local btn = Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("ShutterButton")
    local pp = btn and (btn:FindFirstChild("PP") or btn:FindFirstChildWhichIsA("ProximityPrompt", true))
    if not pp or not pp.Enabled then return false end

    local currentlyClosed = IsShutterClosed()
    if currentlyClosed == shouldBeClosed then
        return false
    end

    if shouldBeClosed then
        Log("AutoShutter", "Closed shutter for threat", { npc = reasonNpc and reasonNpc:GetFullName() or "Unknown" })
    else
        Log("AutoShutter", "Opening shutter for normal patients")
    end

    local pPos = GetPromptPartPosition(pp) or Positions.ShutterButton
    TeleportPlayer(pPos + Vector3.new(0, 1.0, 1.5))
    task.wait(0.15)
    FirePrompt(pp)
    task.wait(0.5)
    return true
end

local function GetClosestCounterNpc()
    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return nil, false end

    local counterPos = Positions.CheckInCounter or Vector3.new(-103.91, 3.41, -0.40)
    local closestNpc = nil
    local minDistance = math.huge

    for _, npc in ipairs(npcs:GetChildren()) do
        if npc:IsA("Model") and (IsValidPatient(npc) or IsBarney(npc)) then
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

    local counterNpc, isThreat = GetClosestCounterNpc()

    if counterNpc then
        if isThreat then
            _G.HasActiveThreat = true
            SetShutterState(true, counterNpc)

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
            SetShutterState(false, counterNpc)
        end
    else
        _G.HasActiveThreat = false
        if IsShutterClosed() then
            SetShutterState(false)
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🏢 11. AUTO CHECK IN (ACCURATE PIPELINE WITH PROMPT RETRY & SMOOTH STEPPING)
-- ══════════════════════════════════════════════════════════════════════════════════
local function GetPatientAtCounter()
    if IsShutterClosed() or _G.HasActiveThreat then return nil end

    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return nil end

    local counterSpot = Vector3.new(-103.91, 3.41, -0.40)
    for _, npc in ipairs(npcs:GetChildren()) do
        if npc:IsA("Model") and IsValidPatient(npc) and not IsPatientAlreadyTreated(npc) then
            if not IsNpcThreat(npc) then
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

local function GetNpcCheckInPrompt(npc)
    if not npc or IsBarney(npc) or npc.Name == "Cleaner" or npc.Name == "Guard" then return nil end
    for _, p in ipairs(npc:GetDescendants()) do
        if p:IsA("ProximityPrompt") and p.Enabled then
            local act = string.lower(tostring(p.ActionText or ""))
            if act ~= "" and not act:find("carry") and not act:find("help") and not act:find("ask") then
                return p
            end
        end
    end
    return nil
end

local function ExecuteCheckInCycle()
    if not _G.AutoCheckIn or IsShutterClosed() or _G.HasActiveThreat or _G.AH_IsTreating then return false end

    local misc = Workspace:FindFirstChild("Misc")
    local checkIn = misc and misc:FindFirstChild("CheckIn")
    if not checkIn then return false end

    local patient = GetPatientAtCounter()
    if not patient then return false end

    -- 1. Проверяем бейдж в руках/инвентаре для передачи пациенту
    local npcPrompt = GetNpcCheckInPrompt(patient)
    if npcPrompt and npcPrompt.Enabled then
        for _, c in ipairs(InventoryContainers()) do
            for _, t in ipairs(c:GetChildren()) do
                if t:IsA("Tool") and (string.lower(t.Name):find("badge") or string.lower(t.Name):find("card") or string.lower(t.Name):find("id")) then
                    UseInventoryTool(t.Name)
                    break
                end
            end
        end

        Log("AutoCheckIn", "Handing badge to patient", { patient = patient:GetFullName(), prompt = npcPrompt:GetFullName() })
        local root = patient:FindFirstChild("HumanoidRootPart") or patient:FindFirstChild("Torso") or patient:FindFirstChildWhichIsA("BasePart")
        if root then TeleportPlayer(root.Position + Vector3.new(0, 1.0, 2.0)) end
        task.wait(0.2)
        FirePrompt(npcPrompt)
        task.wait(0.4)
        UnequipAllTools()
        MarkPatientTreated(patient)
        return true
    end

    -- 2. Проверяем готовый бейдж на стойке (PatientBadgeBase, VisitorBadgeBase, PrintedBadge)
    for _, bName in ipairs({"PatientBadgeBase", "VisitorBadgeBase", "PrintedBadge"}) do
        local b = checkIn:FindFirstChild(bName)
        local bPP = b and (b:FindFirstChild("PP") or b:FindFirstChildWhichIsA("ProximityPrompt", true))
        if bPP and bPP.Enabled then
            Log("AutoCheckIn", "Taking printed badge from desk", { prompt = bPP:GetFullName() })
            local bPos = GetPromptPartPosition(bPP) or Positions.CheckInBadge
            TeleportPlayer(bPos + Vector3.new(0, 1.0, 1.5))
            task.wait(0.2)
            FirePrompt(bPP)
            task.wait(0.3)

            npcPrompt = GetNpcCheckInPrompt(patient)
            if npcPrompt and npcPrompt.Enabled then
                for _, c in ipairs(InventoryContainers()) do
                    for _, t in ipairs(c:GetChildren()) do
                        if t:IsA("Tool") then
                            UseInventoryTool(t.Name)
                            break
                        end
                    end
                end
                Log("AutoCheckIn", "Giving taken badge to patient", { patient = patient:GetFullName() })
                local root = patient:FindFirstChild("HumanoidRootPart") or patient:FindFirstChild("Torso") or patient:FindFirstChildWhichIsA("BasePart")
                if root then TeleportPlayer(root.Position + Vector3.new(0, 1.0, 2.0)) end
                task.wait(0.2)
                FirePrompt(npcPrompt)
                task.wait(0.4)
                UnequipAllTools()
                MarkPatientTreated(patient)
            end
            return true
        end
    end

    -- 3. Принтер (Printer)
    local printer = checkIn:FindFirstChild("Printer")
    local printerPP = printer and (printer:FindFirstChild("PP") or printer:FindFirstChildWhichIsA("ProximityPrompt", true))
    if printerPP and printerPP.Enabled then
        Log("AutoCheckIn", "Printing badge", { prompt = printerPP:GetFullName() })
        TeleportAndFirePrompt(printerPP, Positions.CheckInPrinter, 0.4)
        task.wait(1.5)
        return true
    end

    -- 4. Компьютер (Computer)
    local pc = checkIn:FindFirstChild("Computer")
    local pcPP = pc and (pc:FindFirstChild("PP") or pc:FindFirstChildWhichIsA("ProximityPrompt", true))
    if pcPP and pcPP.Enabled then
        Log("AutoCheckIn", "Registering on computer", { prompt = pcPP:GetFullName() })
        TeleportAndFirePrompt(pcPP, Positions.CheckInPC, 0.4)

        -- Ожидаем завершения регистрации на компьютере (пока не появится принтер или бейдж)
        local t = os.clock()
        while os.clock() - t < 3.0 and not StopCheck() do
            local pr = checkIn:FindFirstChild("Printer")
            local prPP = pr and (pr:FindFirstChild("PP") or pr:FindFirstChildWhichIsA("ProximityPrompt", true))
            if prPP and prPP.Enabled then break end
            local bdg = checkIn:FindFirstChild("PatientBadgeBase") or checkIn:FindFirstChild("VisitorBadgeBase") or checkIn:FindFirstChild("PrintedBadge")
            local bdgPP = bdg and (bdg:FindFirstChild("PP") or bdg:FindFirstChildWhichIsA("ProximityPrompt", true))
            if bdgPP and bdgPP.Enabled then break end
            task.wait(0.2)
        end
        return true
    end

    -- 5. Фотоаппарат (Camera)
    local cam = checkIn:FindFirstChild("Camera")
    local camPP = cam and (cam:FindFirstChild("PP") or cam:FindFirstChildWhichIsA("ProximityPrompt", true))
    if camPP and camPP.Enabled then
        Log("AutoCheckIn", "Taking patient photo", { prompt = camPP:GetFullName() })
        TeleportAndFirePrompt(camPP, Positions.CheckInCamera, 0.4)
        task.wait(0.5)
        return true
    end

    -- 6. Бланк (Form)
    local form = checkIn:FindFirstChild("Form")
    local formPP = form and (form:FindFirstChild("PP") or form:FindFirstChildWhichIsA("ProximityPrompt", true))
    if formPP and formPP.Enabled then
        Log("AutoCheckIn", "Stamping check-in form", { prompt = formPP:GetFullName() })
        TeleportAndFirePrompt(formPP, Positions.CheckInForm, 0.4)
        task.wait(0.5)
        return true
    end

    return false
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🧼 12. AUTO CLEAN SLIME
-- ══════════════════════════════════════════════════════════════════════════════════
local function CleanSlimePuddles()
    if not _G.AutoCleanSlime or _G.AH_IsTreating then return end

    local puddles = Workspace:FindFirstChild("Puddles") or Workspace:FindFirstChild("Slime") or Workspace:FindFirstChild("Misc")
    if not puddles then return end

    for _, p in ipairs(puddles:GetDescendants()) do
        if p:IsA("ProximityPrompt") and p.Enabled and (string.lower(p.ActionText or ""):find("clean") or string.lower(p.ObjectText or ""):find("slime") or string.lower(p.Parent.Name):find("slime")) then
            Log("AutoCleanSlime", "Cleaning slime puddle", { prompt = p:GetFullName() })
            TeleportAndFirePrompt(p, nil, 0.3)
            task.wait(0.4)
            break
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🛒 13. AUTO BUY SHOP
-- ══════════════════════════════════════════════════════════════════════════════════
local function AutoBuyShopItems()
    if not _G.AutoBuyShop or _G.AH_IsTreating then return end

    local shop = Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("Shop")
    if not shop then return end

    for _, prompt in ipairs(shop:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") and prompt.Enabled and (string.lower(prompt.ActionText or ""):find("buy") or string.lower(prompt.ActionText or ""):find("purchase")) then
            FirePrompt(prompt)
            task.wait(0.3)
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🚑 14. AUTO HELP PATIENT
-- ══════════════════════════════════════════════════════════════════════════════════
local function AutoHelpFaintedPatients()
    if not _G.AutoHelpPatient or _G.AH_IsTreating then return end

    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return end

    for _, npc in ipairs(npcs:GetChildren()) do
        if npc:IsA("Model") and IsValidPatient(npc) then
            for _, prompt in ipairs(npc:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.Enabled and (string.lower(prompt.ActionText or ""):find("help") or string.lower(prompt.ActionText or ""):find("carry") or string.lower(prompt.ActionText or ""):find("lift")) then
                    Log("AutoHelpPatient", "Helping fainted patient", { npc = npc:GetFullName(), prompt = prompt:GetFullName() })
                    TeleportAndFirePrompt(prompt, nil, 0.4)
                    task.wait(0.5)
                    break
                end
            end
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🔄 15. MAIN COORDINATED AUTOMATION LOOP
-- ══════════════════════════════════════════════════════════════════════════════════
task.spawn(function()
    Log("Loop", "Averlik Hub Animal Hospital Engine Started", { loopInterval = _G.LoopInterval })

    while true do
        task.wait(_G.LoopInterval)

        local s, err = pcall(function()
            -- 1. Оценка угроз и шторки
            EvaluateCounterThreats()

            -- 2. Приоритетное лечение во всех палатах (1 - 8)
            ExecuteTreatmentCycle()

            -- 3. Регистрация клиентов
            ExecuteCheckInCycle()

            -- 4. Кофе для Барни
            ProcessBarneyCoffee()

            -- 5. Уборка слизи
            CleanSlimePuddles()

            -- 6. Помощь упавшим пациентам
            AutoHelpFaintedPatients()

            -- 7. Авто-покупка в магазине
            AutoBuyShopItems()
        end)

        if not s then
            Log("Error", "Loop iteration exception", { error = tostring(err) })
        end
    end
end)

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🌐 15. SERVER UTILITIES (SERVER HOP, REJOIN, ANTI-AFK, FULLBRIGHT, SPEED)
-- ══════════════════════════════════════════════════════════════════════════════════
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")

local function RejoinServer()
    Log("Teleport", "Rejoining current server...")
    if #Players:GetPlayers() <= 1 then
        LocalPlayer:Kick("\n[Averlik Hub] Перезаходим на сервер...")
        task.wait(0.2)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
end

local function ServerHop()
    Log("Teleport", "Searching for a new public server...")
    local placeId = game.PlaceId
    local servers = {}
    local req = request or http_request or (syn and syn.request) or (http and http.request)
    if req then
        local url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", tostring(placeId))
        local s, response = pcall(function() return req({ Url = url, Method = "GET" }) end)
        if s and response and response.Body then
            local body = HttpService:JSONDecode(response.Body)
            if body and body.data then
                for _, server in ipairs(body.data) do
                    if type(server) == "table" and server.maxPlayers > server.playing and server.id ~= game.JobId then
                        table.insert(servers, server.id)
                    end
                end
            end
        end
    end

    if #servers > 0 then
        local target = servers[math.random(1, #servers)]
        Log("Teleport", "Teleporting to server", { target = target })
        TeleportService:TeleportToPlaceInstance(placeId, target, LocalPlayer)
    else
        Log("Teleport", "Fallback normal teleport...")
        TeleportService:Teleport(placeId, LocalPlayer)
    end
end

local function ServerHopLowPlayer()
    Log("Teleport", "Searching for a low player server...")
    local placeId = game.PlaceId
    local servers = {}
    local req = request or http_request or (syn and syn.request) or (http and http.request)
    if req then
        local url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", tostring(placeId))
        local s, response = pcall(function() return req({ Url = url, Method = "GET" }) end)
        if s and response and response.Body then
            local body = HttpService:JSONDecode(response.Body)
            if body and body.data then
                for _, server in ipairs(body.data) do
                    if type(server) == "table" and server.maxPlayers > server.playing and server.id ~= game.JobId and server.playing >= 1 then
                        table.insert(servers, server)
                    end
                end
            end
        end
    end

    table.sort(servers, function(a, b) return a.playing < b.playing end)

    if #servers > 0 then
        Log("Teleport", "Teleporting to lowest player server", { players = servers[1].playing, target = servers[1].id })
        TeleportService:TeleportToPlaceInstance(placeId, servers[1].id, LocalPlayer)
    else
        TeleportService:Teleport(placeId, LocalPlayer)
    end
end

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    if _G.AntiAFK ~= false then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- Fullbright
local OriginalBrightness = Lighting.Brightness
local OriginalClockTime = Lighting.ClockTime
local OriginalFogEnd = Lighting.FogEnd
local OriginalGlobalShadows = Lighting.GlobalShadows
local OriginalAmbient = Lighting.Ambient

local function ToggleFullbright(value)
    if value then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = OriginalBrightness
        Lighting.ClockTime = OriginalClockTime
        Lighting.FogEnd = OriginalFogEnd
        Lighting.GlobalShadows = OriginalGlobalShadows
        Lighting.Ambient = OriginalAmbient
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🎨 17. RAYFIELD OBSIDIAN USER INTERFACE (SAFE-LOADED)
-- ══════════════════════════════════════════════════════════════════════════════════
local Rayfield = nil
pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if Rayfield then
    local Window = Rayfield:CreateWindow({
        Name = "🏥 Averlik Hub | Animal Hospital",
        LoadingTitle = "Averlik Hub",
        LoadingSubtitle = "by Averlik AI",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "AverlikHub",
            FileName = "AnimalHospital"
        },
        Discord = {
            Enabled = false,
            Invite = "",
            RememberJoins = true
        },
        KeySystem = false
    })

    local MainTab = Window:CreateTab("🏥 Автоматизация", 4483362458)
    local ThreatTab = Window:CreateTab("🛡️ Защита", 4483362458)
    local TeleportTab = Window:CreateTab("📍 Телепорт", 4483362458)
    local MiscTab = Window:CreateTab("⚙️ Разное / Утилиты", 4483362458)

    MainTab:CreateToggle({
        Name = "Авто-Лечение (Палаты 1-8)",
        CurrentValue = _G.AutoTreatment,
        Flag = "AutoTreatment",
        Callback = function(Value) _G.AutoTreatment = Value end,
    })

    MainTab:CreateToggle({
        Name = "Авто-Регистрация (Ресепшен)",
        CurrentValue = _G.AutoCheckIn,
        Flag = "AutoCheckIn",
        Callback = function(Value) _G.AutoCheckIn = Value end,
    })

    MainTab:CreateToggle({
        Name = "Кофе для Барни",
        CurrentValue = _G.AutoGiveBarneyCoffee,
        Flag = "AutoGiveBarneyCoffee",
        Callback = function(Value) _G.AutoGiveBarneyCoffee = Value end,
    })

    MainTab:CreateToggle({
        Name = "Уборка слизи",
        CurrentValue = _G.AutoCleanSlime,
        Flag = "AutoCleanSlime",
        Callback = function(Value) _G.AutoCleanSlime = Value end,
    })

    MainTab:CreateToggle({
        Name = "Помощь пациентам",
        CurrentValue = _G.AutoHelpPatient,
        Flag = "AutoHelpPatient",
        Callback = function(Value) _G.AutoHelpPatient = Value end,
    })

    ThreatTab:CreateToggle({
        Name = "Шторка от Аномалий",
        CurrentValue = _G.AutoAnomalyShutter,
        Flag = "AutoAnomalyShutter",
        Callback = function(Value) _G.AutoAnomalyShutter = Value end,
    })

    ThreatTab:CreateToggle({
        Name = "Прогонять Аномалии (Ask To Leave)",
        CurrentValue = _G.AutoAskLeaveAnomaly,
        Flag = "AutoAskLeaveAnomaly",
        Callback = function(Value) _G.AutoAskLeaveAnomaly = Value end,
    })

    -- Телепорты
    for roomName, pos in pairs({
        ["Регистрация"] = Positions.CheckInPC,
        ["Барни"] = Positions.Barney,
        ["Палата 1"] = Positions.Room1_Bed,
        ["Палата 2"] = Positions.Room2_Bed,
        ["Палата 3"] = Positions.Room3_Bed,
        ["Палата 4"] = Positions.Room4_Bed,
        ["Палата 5"] = Positions.Room5_Bed,
        ["Палата 6 (Рентген)"] = Positions.Room6_Bed,
        ["Палата 7 (Реанимация)"] = Positions.Room7_Bed,
        ["Палата 8 (Хирургия)"] = Positions.Room8_Bed,
        ["Шкаф Травы (Herbs)"] = Positions.Shelf_Herbs
    }) do
        TeleportTab:CreateButton({
            Name = "Телепорт: " .. roomName,
            Callback = function() TeleportPlayer(pos) end,
        })
    end

    -- Утилиты и Сервер
    MiscTab:CreateButton({
        Name = "🔄 Rejoin (Перезайти на этот же сервер)",
        Callback = RejoinServer,
    })

    MiscTab:CreateButton({
        Name = "🌐 Server Hop (Случайный сервер)",
        Callback = ServerHop,
    })

    MiscTab:CreateButton({
        Name = "👥 Server Hop (Сервер с малым онлайном)",
        Callback = ServerHopLowPlayer,
    })

    MiscTab:CreateToggle({
        Name = "🛡️ Anti-AFK (Защита от кика 20 мин)",
        CurrentValue = true,
        Flag = "AntiAFK",
        Callback = function(Value) _G.AntiAFK = Value end,
    })

    MiscTab:CreateToggle({
        Name = "💡 Fullbright (Яркий свет)",
        CurrentValue = false,
        Flag = "Fullbright",
        Callback = ToggleFullbright,
    })

    MiscTab:CreateSlider({
        Name = "Скорость бега (WalkSpeed)",
        Range = {16, 120},
        Increment = 1,
        Suffix = " studs/s",
        CurrentValue = 16,
        Flag = "WalkSpeed",
        Callback = function(Value)
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = Value end
        end,
    })

    MiscTab:CreateSlider({
        Name = "Сила прыжка (JumpPower)",
        Range = {50, 250},
        Increment = 5,
        Suffix = " power",
        CurrentValue = 50,
        Flag = "JumpPower",
        Callback = function(Value)
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.JumpPower = Value end
        end,
    })
end