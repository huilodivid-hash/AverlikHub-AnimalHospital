-- ══════════════════════════════════════════════════════════════════════════════════
-- 🏥 AVERLIK HUB: ANIMAL HOSPITAL DYNAMIC ADAPTIVE SUITE (V4.0 SMART PERCEPTION)
-- ══════════════════════════════════════════════════════════════════════════════════

-- 🛑 BULLETPROOF SINGLETON SESSION ENGINE
_G.AH_SessionCounter = (_G.AH_SessionCounter or 0) + 1
local MySession = _G.AH_SessionCounter
_G.AH_ActiveSession = MySession

local function IsSessionActive()
    return _G.AH_ActiveSession == MySession
end

local function StopCheck()
    return not IsSessionActive()
end

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

-- 📌 RUNTIME STATE & ADAPTIVE MEMORY
_G.HasActiveThreat = false
_G.AH_IsTreating = false
_G.AH_TreatedPatients = setmetatable({}, { __mode = "k" })
local _AH_PromptCooldowns = setmetatable({}, { __mode = "k" })
local _AH_RoomCooldowns = {}

-- ══════════════════════════════════════════════════════════════════════════════════
-- 📍 1. PRECISE MILLIMETER COORDINATES (EXTRACTED FROM GAME DUMP)
-- ══════════════════════════════════════════════════════════════════════════════════
local Positions = {
    -- Регистрация
    CheckInPC = Vector3.new(-97.68, 3.50, -2.50),
    CheckInForm = Vector3.new(-100.80, 4.41, 1.48),
    CheckInCamera = Vector3.new(-108.57, 4.65, -2.93),
    CheckInPrinter = Vector3.new(-97.68, 4.41, 3.63),
    CheckInBadge = Vector3.new(-97.68, 4.41, 3.63),
    PrintedBadge = Vector3.new(-97.68, 4.41, 3.63),
    CheckInCounter = Vector3.new(-103.91, 3.41, -0.40),
    ShutterButton = Vector3.new(-103.91, 5.00, 3.80),
    AskToLeave = Vector3.new(-103.91, 3.41, -0.40),

    -- Барни и Кофе
    Barney = Vector3.new(-149.20, 3.46, -2.50),
    CoffeeMachine = Vector3.new(-123.83, 4.01, 10.33),
    Coffee = Vector3.new(-123.77, 3.80, 10.31),
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
-- 🔍 2. CORE UTILITIES & LOGGING ENGINE
-- ══════════════════════════════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local function Log(prefix, msg, tbl)
    local t = os.date("%X")
    local extra = ""
    if tbl then
        local parts = {}
        for k, v in pairs(tbl) do
            table.insert(parts, string.format("%s=%s", tostring(k), tostring(v)))
        end
        if #parts > 0 then extra = " | " .. table.concat(parts, " | ") end
    end
    print(string.format("[%s] [%s] %s%s", t, prefix, msg, extra))
end

local function NormalizeName(str)
    if not str then return "" end
    local s = string.lower(tostring(str))
    s = string.gsub(s, "%s+", "")
    return s
end

local function GetPromptPartPosition(prompt)
    if not prompt then return nil end
    local p = prompt.Parent
    if not p then return nil end
    if p:IsA("BasePart") then return p.Position end
    if p:IsA("Attachment") then return p.WorldPosition end
    if p:IsA("Model") then
        local pp = p.PrimaryPart or p:FindFirstChildWhichIsA("BasePart")
        if pp then return pp.Position end
        return p:GetPivot().Position
    end
    local bp = p:FindFirstChildWhichIsA("BasePart", true)
    if bp then return bp.Position end
    return nil
end

local function TeleportPlayer(pos)
    if not pos or StopCheck() then return end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(pos + Vector3.new(0, 1.2, 0))
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- ⚡ 3. DYNAMIC PROXIMITY PROMPT INTERACTION ENGINE
-- ══════════════════════════════════════════════════════════════════════════════════
local function FirePrompt(prompt, minHold)
    if not prompt or not prompt.Parent or not prompt.Enabled or StopCheck() then return false end

    local now = os.clock()
    local hold = (prompt:IsA("ProximityPrompt") and prompt.HoldDuration > 0 and (prompt.HoldDuration + 0.1)) or 0
    local requiredWait = math.max(minHold or 0.35, hold)

    if _AH_PromptCooldowns[prompt] and (now - _AH_PromptCooldowns[prompt] < requiredWait) then
        return false
    end
    _AH_PromptCooldowns[prompt] = now

    Log("Prompt", "Firing proximity prompt", {
        actionText = prompt.ActionText,
        enabled = prompt.Enabled,
        prompt = prompt:GetFullName()
    })

    if type(fireproximityprompt) == "function" then
        pcall(fireproximityprompt, prompt)
        return true
    elseif prompt.InputHoldBegin and prompt.InputHoldEnd then
        task.spawn(function()
            prompt:InputHoldBegin()
            task.wait(math.max(0.1, (prompt.HoldDuration or 0) + 0.05))
            prompt:InputHoldEnd()
        end)
        return true
    end
    return false
end

local function TeleportAndFirePrompt(prompt, fallbackPos, minHold, waitAfter)
    if not prompt or not prompt.Enabled or StopCheck() then return false end
    local targetPos = GetPromptPartPosition(prompt) or fallbackPos
    if targetPos then
        TeleportPlayer(targetPos)
        task.wait(0.12)
    end
    local res = FirePrompt(prompt, minHold)
    if waitAfter then task.wait(waitAfter) end
    return res
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🎒 4. INVENTORY & TOOL CONTROL ENGINE
-- ══════════════════════════════════════════════════════════════════════════════════
local function InventoryContainers()
    local list = {}
    local char = LocalPlayer.Character
    if char then table.insert(list, char) end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then table.insert(list, bp) end
    return list
end

local function GetItemCount(itemName)
    local count = 0
    local target = NormalizeName(itemName)
    for _, container in ipairs(InventoryContainers()) do
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") and NormalizeName(tool.Name) == target then
                count = count + 1
            end
        end
    end
    return count
end

local function UseInventoryTool(itemName)
    local target = NormalizeName(itemName)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local bp = LocalPlayer:FindFirstChild("Backpack")

    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and NormalizeName(tool.Name) == target then
                return tool
            end
        end
    end

    if bp and hum then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") and NormalizeName(tool.Name) == target then
                hum:EquipTool(tool)
                task.wait(0.1)
                return tool
            end
        end
    end
    return nil
end

local function UnequipAllTools()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum:UnequipTools() end
end

local function DiscardToolAtTrash(tool)
    if not tool or StopCheck() then return end
    local trash = Workspace:FindFirstChild("Trash")
    local trashPP = trash and (trash:FindFirstChild("PP") or trash:FindFirstChildWhichIsA("ProximityPrompt", true))
    local trashPos = (trashPP and GetPromptPartPosition(trashPP)) or Positions.Trash

    TeleportPlayer(trashPos)
    task.wait(0.12)

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum and tool.Parent ~= char then hum:EquipTool(tool) task.wait(0.08) end

    if trashPP and trashPP.Enabled then
        FirePrompt(trashPP, 0.3)
    end
    task.wait(0.15)
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🔍 5. DYNAMIC ITEM PROMPT DISCOVERY (SMART SHELF SCANNER)
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

    -- 2. Быстрый поиск в папках медикаментов
    local searchContainers = {}
    local modelItems = Workspace:FindFirstChild("Model") and Workspace.Model:FindFirstChild("Items")
    if modelItems then table.insert(searchContainers, modelItems) end
    local directItems = Workspace:FindFirstChild("Items")
    if directItems then table.insert(searchContainers, directItems) end
    local misc = Workspace:FindFirstChild("Misc")
    if misc then table.insert(searchContainers, misc) end

    for _, container in ipairs(searchContainers) do
        for _, prompt in ipairs(container:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                local act = NormalizeName(prompt.ActionText or "")
                local obj = NormalizeName(prompt.ObjectText or "")
                local pName = NormalizeName(prompt.Parent and prompt.Parent.Name or "")

                if pName == target or pName:find(target) or act == target or act:find(target) or obj == target or obj:find(target) then
                    return prompt
                end
            end
        end
    end

    return nil
end

local function GrabItemUntilInInventory(itemName, roomName)
    if GetItemCount(itemName) > 0 then return true end

    -- Очистить лишний инвентарь
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

        TeleportPlayer(shelfPos + Vector3.new(0, 1.0, 1.2))
        task.wait(0.15)

        local countBefore = GetItemCount(itemName)
        FirePrompt(prompt, 0.3)

        local t = os.clock()
        while os.clock() - t < 1.2 and not StopCheck() do
            if GetItemCount(itemName) > countBefore then break end
            task.wait(0.05)
        end
    end

    return GetItemCount(itemName) > 0
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🛡️ 6. THREAT DETECTION & SHUTTER ENGINE
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
    local currentlyClosed = IsShutterClosed()
    if currentlyClosed == shouldBeClosed then return end

    local btn = Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("ShutterButton")
    local pp = btn and (btn:FindFirstChild("PP") or btn:FindFirstChildWhichIsA("ProximityPrompt", true))
    if pp and pp.Enabled then
        if shouldBeClosed then
            Log("AutoShutter", "Closed shutter for threat", { npc = reasonNpc and reasonNpc:GetFullName() or "Unknown" })
        else
            Log("AutoShutter", "Opening shutter for normal patients")
        end
        TeleportAndFirePrompt(pp, Positions.ShutterButton, 0.3)
        task.wait(0.2)
    end
end

local function IsBarney(npc)
    if not npc then return false end
    local name = string.lower(npc.Name)
    return name:find("barney") ~= nil
end

local function IsNpcThreat(npc)
    if not npc or not npc:IsA("Model") then return false end
    if IsBarney(npc) then return _G.AutoBarneyShutter == true end
    if not _G.AutoAnomalyShutter then return false end

    if npc:GetAttribute("Skinwalker") == true or npc:GetAttribute("Anomaly") == true or npc:GetAttribute("IsThreat") == true then
        return true
    end

    local name = string.lower(npc.Name)
    if name:find("stalker") or name:find("monster") or name:find("anomaly") or name:find("skinwalker") then
        return true
    end

    for _, desc in ipairs(npc:GetDescendants()) do
        if desc:IsA("StringValue") or desc:IsA("BoolValue") then
            local dName = string.lower(desc.Name)
            if (dName:find("threat") or dName:find("anomaly") or dName:find("skinwalker")) and desc.Value then
                return true
            end
        end
    end
    return false
end

local function EvaluateCounterThreats()
    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return end

    local counterPos = Positions.CheckInCounter
    local threatFound = false
    local threatNpc = nil

    for _, npc in ipairs(npcs:GetChildren()) do
        if npc:IsA("Model") then
            local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso") or npc:FindFirstChildWhichIsA("BasePart")
            if root and (root.Position - counterPos).Magnitude <= 28 then
                if IsNpcThreat(npc) then
                    threatFound = true
                    threatNpc = npc
                    break
                end
            end
        end
    end

    _G.HasActiveThreat = threatFound
    if threatFound then
        SetShutterState(true, threatNpc)
    else
        SetShutterState(false)
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 📺 7. TV PRESCRIPTION PARSER & PATIENT STATUS
-- ══════════════════════════════════════════════════════════════════════════════════
local function ResolveNeededTreatmentItems(roomName)
    local items = {}
    local rooms = Workspace:FindFirstChild("Rooms")
    if not rooms then return items end

    local rNum = tonumber(roomName:match("%d+"))
    local folder = (rNum and rNum >= 6) and rooms:FindFirstChild("Emergency") or rooms:FindFirstChild("Medical")
    local room = folder and folder:FindFirstChild(roomName)
    local tv = room and room:FindFirstChild("Minigame") and room.Minigame:FindFirstChild("TV")

    if tv then
        for _, desc in ipairs(tv:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Visible then
                local text = desc.Text
                if text and text ~= "" then
                    for item in string.gmatch(text, "([^,\n\r]+)") do
                        local cleaned = string.gsub(item, "^%s*(.-)%s*$", "%1")
                        cleaned = string.gsub(cleaned, "^[%-%*•]%s*", "")
                        local norm = NormalizeName(cleaned)
                        if #cleaned > 1 and not norm:find("status") and not norm:find("report") and not norm:find("patient") and not norm:find("recovering") and not norm:find("healthy") then
                            table.insert(items, cleaned)
                        end
                    end
                end
            end
        end
    end
    return items
end

local function IsRoomRecovering(room)
    if not room then return false end
    local tv = room:FindFirstChild("Minigame") and room.Minigame:FindFirstChild("TV")
    if tv then
        for _, desc in ipairs(tv:GetDescendants()) do
            if desc:IsA("TextLabel") and desc.Visible then
                local text = string.lower(desc.Text or "")
                if text:find("recovering") or text:find("stable") or text:find("healthy") or text:find("discharged") or text:find("cured") then
                    return true
                end
            end
        end
    end
    return false
end

local function IsValidPatient(npc)
    if not npc or not npc:IsA("Model") then return false end
    local name = npc.Name
    if name == "Barney" or name == "Cleaner" or name == "Guard" or name == "Security" then return false end
    return true
end

local function IsPatientAlreadyTreated(npc)
    if not npc then return true end
    local last = _G.AH_TreatedPatients[npc]
    if last and (os.clock() - last < 20.0) then return true end
    return false
end

local function MarkPatientTreated(npc)
    if npc then _G.AH_TreatedPatients[npc] = os.clock() end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🏥 8. DYNAMIC ADAPTIVE TREATMENT ENGINE (ROOMS 1 - 8)
-- ══════════════════════════════════════════════════════════════════════════════════
local function GetPatientInRoom(roomName, centerPos)
    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return nil end
    for _, npc in ipairs(npcs:GetChildren()) do
        if npc:IsA("Model") and IsValidPatient(npc) and not IsPatientAlreadyTreated(npc) then
            local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso") or npc:FindFirstChildWhichIsA("BasePart")
            if root and (root.Position - centerPos).Magnitude <= 28 then
                return npc
            end
        end
    end
    return nil
end

local function ProcessSingleRoom(roomName, isEmergency)
    if not _G.AutoTreatment or StopCheck() then return false end

    -- Проверка кулдауна комнаты
    if (_AH_RoomCooldowns[roomName] and (os.clock() - _AH_RoomCooldowns[roomName] < 4.0)) then
        return false
    end

    local rooms = Workspace:FindFirstChild("Rooms")
    local folder = isEmergency and rooms:FindFirstChild("Emergency") or rooms:FindFirstChild("Medical")
    local room = folder and folder:FindFirstChild(roomName)
    if not room or IsRoomRecovering(room) then return false end

    local minigame = room:FindFirstChild("Minigame")
    if not minigame then return false end

    local bedCenter = Positions[roomName .. "_Bed"] or Positions[roomName .. "_Device"] or room:GetPivot().Position
    local patient = GetPatientInRoom(roomName, bedCenter)
    local inBed = minigame:FindFirstChild("Bed") and minigame.Bed:FindFirstChild("InBed")
    local bedPP = inBed and (inBed:FindFirstChild("PP") or inBed:FindFirstChild("PP2") or inBed:FindFirstChildWhichIsA("ProximityPrompt", true))

    -- 🔍 1. ДИНАМИЧЕСКИЙ АНАЛИЗ АКТИВНЫХ ПРОМПТОВ В ПАЛАТЕ
    -- А) Взятие ДНК образца (DNA / Prepare Prompt)
    if patient then
        for _, p in ipairs(patient:GetDescendants()) do
            if p:IsA("ProximityPrompt") and p.Enabled then
                local act = string.lower(p.ActionText or "")
                if act:find("sample") or act:find("dna") or act:find("take") or act:find("prepare") then
                    Log("AutoTreatment", "Taking DNA sample", { room = roomName, prompt = p:GetFullName() })
                    TeleportAndFirePrompt(p, bedCenter, 0.4, 0.4)
                    return true
                end
            end
        end
    end

    -- Б) Анализатор (Analyzer)
    local analyzer = minigame:FindFirstChild("Analyzer")
    local analyzerPP = analyzer and (analyzer:FindFirstChild("PP") or analyzer:FindFirstChildWhichIsA("ProximityPrompt", true))
    if analyzerPP and analyzerPP.Enabled then
        Log("AutoTreatment", "Analyzing sample in analyzer", { room = roomName, prompt = analyzerPP:GetFullName() })
        TeleportAndFirePrompt(analyzerPP, Positions[roomName .. "_Device"], 0.4, 0.4)
        return true
    end

    -- В) Рентген запуск (Room 6 xrayMonitor)
    local xrayMonitor = minigame:FindFirstChild("xrayMonitor")
    local xrayPP = xrayMonitor and (xrayMonitor:FindFirstChild("PP") or xrayMonitor:FindFirstChildWhichIsA("ProximityPrompt", true))
    if xrayPP and xrayPP.Enabled then
        Log("AutoTreatment", "Starting X-Ray scan", { room = roomName, prompt = xrayPP:GetFullName() })
        TeleportAndFirePrompt(xrayPP, Positions.Room6_XrayStart, 0.4, 0.4)
        return true
    end

    -- Г) Монитор результатов (Monitor PP2)
    local monitor = minigame:FindFirstChild("Monitor")
    local monitorPP2 = monitor and (monitor:FindFirstChild("PP2") or monitor:FindFirstChildWhichIsA("ProximityPrompt", true))
    if monitorPP2 and monitorPP2.Enabled then
        Log("AutoTreatment", "Pressing monitor process prompt", { room = roomName, prompt = monitorPP2:GetFullName() })
        TeleportAndFirePrompt(monitorPP2, Positions[roomName .. "_Device"] or Positions[roomName .. "_Monitor"], 0.4, 0.4)
        return true
    end

    -- Д) Забор готового снимка (xresult / PrintedXRay)
    local xresult = minigame:FindFirstChild("xresult") or minigame:FindFirstChild("PrintedXRay")
    local xresultPP = xresult and (xresult:FindFirstChild("PP") or xresult:FindFirstChildWhichIsA("ProximityPrompt", true))
    if xresultPP and xresultPP.Enabled then
        Log("AutoTreatment", "Pressing xresult prompt", { room = roomName, prompt = xresultPP:GetFullName() })
        TeleportAndFirePrompt(xresultPP, Positions[roomName .. "_PrintedXRay"], 0.4, 0.4)
        return true
    end

    -- 🔍 2. ДОСТАВКА МЕДИКАМЕНТОВ ПО РЕЦЕПТУ ТВ
    local needed = ResolveNeededTreatmentItems(roomName)
    if #needed > 0 then
        _G.AH_IsTreating = true
        Log("AutoTreatment", "Starting patient treatment", {
            emergency = isEmergency and "true" or "false",
            neededItems = table.concat(needed, ", "),
            npc = patient and patient:GetFullName() or (roomName .. ".Patient"),
            room = roomName
        })

        local attempt = 0
        local appliedAny = false

        while _G.AutoTreatment and not StopCheck() and attempt < 12 do
            if IsRoomRecovering(room) then
                Log("AutoTreatment", "Patient is recovering, stopping treatment", { room = roomName })
                break
            end

            needed = ResolveNeededTreatmentItems(roomName)
            if #needed == 0 then
                task.wait(0.3)
                needed = ResolveNeededTreatmentItems(roomName)
                if #needed == 0 or IsRoomRecovering(room) then break end
            end

            attempt = attempt + 1
            local currentItem = needed[1]

            if GetItemCount(currentItem) == 0 then
                GrabItemUntilInInventory(currentItem, roomName)
            end

            if GetItemCount(currentItem) > 0 then
                UseInventoryTool(currentItem)
                local treatPP = (patient and (patient:FindFirstChild("PP") or patient:FindFirstChildWhichIsA("ProximityPrompt", true))) or bedPP
                local treatPos = (treatPP and GetPromptPartPosition(treatPP)) or bedCenter

                TeleportPlayer(treatPos + Vector3.new(0, 1.0, 1.0))
                task.wait(0.15)

                if treatPP and treatPP.Enabled then
                    FirePrompt(treatPP, 0.35)
                    task.wait(0.3)
                    UnequipAllTools()
                    appliedAny = true

                    local waitTimeout = os.clock() + 3.0
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
                        task.wait(0.2)
                    end
                end
            else
                task.wait(0.4)
            end
        end

        for _, container in ipairs(InventoryContainers()) do
            for _, tool in ipairs(container:GetChildren()) do
                if tool:IsA("Tool") then DiscardToolAtTrash(tool) end
            end
        end

        if appliedAny or IsRoomRecovering(room) then
            if patient then MarkPatientTreated(patient) end
            Log("AutoTreatment", "Finished patient treatment", { npc = patient and patient:GetFullName() or (roomName .. ".Patient"), room = roomName })
        else
            _AH_RoomCooldowns[roomName] = os.clock()
        end

        _G.AH_IsTreating = false
        return true
    end

    return false
end

local function ExecuteTreatmentCycle()
    if not _G.AutoTreatment or _G.HasActiveThreat then return false end

    -- Приоритет реанимаций (Палаты 8, 7, 6)
    for _, r in ipairs({"Room8", "Room7", "Room6"}) do
        if ProcessSingleRoom(r, true) then return true end
    end

    -- Терапевтические палаты (Палаты 1 - 5)
    for i = 1, 5 do
        local r = "Room" .. tostring(i)
        if ProcessSingleRoom(r, false) then return true end
    end

    return false
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🏢 9. DYNAMIC SMART RECEPTION PIPELINE (SEQUENTIAL ZERO-SPAM PIPELINE)
-- ══════════════════════════════════════════════════════════════════════════════════
_G.AH_IsCheckingIn = false
local _AH_HandledPatients = setmetatable({}, { __mode = "k" })

local function GetPatientAtCounter()
    if IsShutterClosed() or _G.HasActiveThreat then return nil end

    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return nil end

    local counterSpot = Positions.CheckInCounter
    for _, npc in ipairs(npcs:GetChildren()) do
        if npc:IsA("Model") and IsValidPatient(npc) and not _AH_HandledPatients[npc] and not IsPatientAlreadyTreated(npc) then
            if not IsNpcThreat(npc) then
                local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso") or npc:FindFirstChildWhichIsA("BasePart")
                if root and (root.Position - counterSpot).Magnitude <= 28 then
                    return npc
                end
            end
        end
    end
    return nil
end

local function GetNpcTalkPrompt(npc)
    if not npc then return nil end
    for _, p in ipairs(npc:GetDescendants()) do
        if p:IsA("ProximityPrompt") and p.Enabled then
            local act = string.lower(tostring(p.ActionText or ""))
            if act:find("talk") or act:find("speak") or act:find("badge") or act:find("give") or act:find("interact") or act == "" then
                return p
            end
        end
    end
    return nil
end

local function GetNpcCheckInPrompt(npc)
    if not npc or IsBarney(npc) or npc.Name == "Cleaner" or npc.Name == "Guard" then return nil end
    local talk = GetNpcTalkPrompt(npc)
    if talk then return talk end

    for _, p in ipairs(npc:GetDescendants()) do
        if p:IsA("ProximityPrompt") and p.Enabled then
            local act = string.lower(tostring(p.ActionText or ""))
            if not act:find("carry") and not act:find("help") and not act:find("faint") then
                return p
            end
        end
    end
    return nil
end

local function EquipBadgeIfInInventory()
    for _, c in ipairs(InventoryContainers()) do
        for _, t in ipairs(c:GetChildren()) do
            if t:IsA("Tool") and (string.lower(t.Name):find("badge") or string.lower(t.Name):find("card") or string.lower(t.Name):find("id")) then
                UseInventoryTool(t.Name)
                return t
            end
        end
    end
    return nil
end

local function HasBadgeInInventory()
    return EquipBadgeIfInInventory() ~= nil
end

local function DeliverBadgeToPatient(patient)
    if not patient then return false end
    EquipBadgeIfInInventory()

    local pPos = (patient:FindFirstChild("HumanoidRootPart") and patient.HumanoidRootPart.Position) or patient:GetPivot().Position
    TeleportPlayer(pPos + Vector3.new(0, 1.0, 1.5))
    task.wait(0.2)

    local npcPrompt = GetNpcCheckInPrompt(patient)
    if npcPrompt and npcPrompt.Enabled then
        Log("AutoCheckIn", "Giving badge to patient", { patient = patient:GetFullName() })
        FirePrompt(npcPrompt, 0.4)
        task.wait(0.25)
    end

    UnequipAllTools()
    _AH_HandledPatients[patient] = os.clock()
    MarkPatientTreated(patient)
    Log("AutoCheckIn", "Successfully finished check-in for patient", { patient = patient:GetFullName() })
    return true
end

local function ExecuteCheckInCycle()
    if not _G.AutoCheckIn or IsShutterClosed() or _G.HasActiveThreat or _G.AH_IsTreating or _G.AH_IsCheckingIn or StopCheck() then
        return false
    end

    local misc = Workspace:FindFirstChild("Misc")
    local checkIn = misc and misc:FindFirstChild("CheckIn")
    if not checkIn then return false end

    local patient = GetPatientAtCounter()
    if not patient then return false end

    _G.AH_IsCheckingIn = true

    -- 1. Если бейджик уже на руках
    if HasBadgeInInventory() then
        DeliverBadgeToPatient(patient)
        _G.AH_IsCheckingIn = false
        return true
    end

    -- 2. Готовый бейджик на стойке
    for _, bName in ipairs({"PrintedBadge", "PatientBadgeBase", "VisitorBadgeBase"}) do
        local b = checkIn:FindFirstChild(bName)
        local bPP = b and (b:FindFirstChild("PP") or b:FindFirstChildWhichIsA("ProximityPrompt", true))
        if bPP and bPP.Enabled then
            Log("AutoCheckIn", "Taking printed badge from desk", { prompt = bPP:GetFullName() })
            TeleportPlayer(GetPromptPartPosition(bPP) or Positions.CheckInBadge)
            task.wait(0.15)
            FirePrompt(bPP, 0.3)
            task.wait(0.2)
            DeliverBadgeToPatient(patient)
            _G.AH_IsCheckingIn = false
            return true
        end
    end

    -- 3. Бланк регистрации (Form)
    local form = checkIn:FindFirstChild("Form")
    local formPP = form and (form:FindFirstChild("PP") or form:FindFirstChildWhichIsA("ProximityPrompt", true))
    if formPP and formPP.Enabled then
        Log("AutoCheckIn", "Stamping Form", { prompt = formPP:GetFullName() })
        TeleportPlayer(GetPromptPartPosition(formPP) or Positions.CheckInForm)
        task.wait(0.15)
        FirePrompt(formPP, 0.35)
        task.wait(0.3)
    end

    -- 4. Фотоаппарат (Camera)
    local cam = checkIn:FindFirstChild("Camera")
    local camPP = cam and (cam:FindFirstChild("PP") or cam:FindFirstChildWhichIsA("ProximityPrompt", true))
    if camPP and camPP.Enabled then
        Log("AutoCheckIn", "Taking Photo", { prompt = camPP:GetFullName() })
        TeleportPlayer(GetPromptPartPosition(camPP) or Positions.CheckInCamera)
        task.wait(0.15)
        FirePrompt(camPP, 0.35)
        task.wait(0.3)
    end

    -- 5. Компьютер (Computer — нажимаем ОДИН РАЗ и ждем принтер)
    local pc = checkIn:FindFirstChild("Computer")
    local pcPP = pc and (pc:FindFirstChild("PP") or pc:FindFirstChildWhichIsA("ProximityPrompt", true))
    if pcPP and pcPP.Enabled then
        Log("AutoCheckIn", "Processing computer registration", { prompt = pcPP:GetFullName() })
        TeleportPlayer(GetPromptPartPosition(pcPP) or Positions.CheckInPC)
        task.wait(0.15)
        FirePrompt(pcPP, 0.6)

        -- Ожидание готовности принтера / бейджика без спама
        local waitDeadline = os.clock() + 3.0
        while os.clock() < waitDeadline and not StopCheck() do
            local printer = checkIn:FindFirstChild("Printer")
            local prPP = printer and (printer:FindFirstChild("PP") or printer:FindFirstChildWhichIsA("ProximityPrompt", true))
            if prPP and prPP.Enabled then break end

            local foundBadge = false
            for _, bName in ipairs({"PrintedBadge", "PatientBadgeBase", "VisitorBadgeBase"}) do
                local b = checkIn:FindFirstChild(bName)
                local bPP = b and (b:FindFirstChild("PP") or b:FindFirstChildWhichIsA("ProximityPrompt", true))
                if bPP and bPP.Enabled then foundBadge = true break end
            end
            if foundBadge then break end
            task.wait(0.15)
        end
    end

    -- 6. Принтер (Printer — нажимаем и забираем бейджик)
    local printer = checkIn:FindFirstChild("Printer")
    local printerPP = printer and (printer:FindFirstChild("PP") or printer:FindFirstChildWhichIsA("ProximityPrompt", true))
    if printerPP and printerPP.Enabled then
        Log("AutoCheckIn", "Printing Badge", { prompt = printerPP:GetFullName() })
        TeleportPlayer(GetPromptPartPosition(printerPP) or Positions.CheckInPrinter)
        task.wait(0.15)
        FirePrompt(printerPP, 0.35)

        -- Ожидание появления готового бейджика на столе
        local waitBadge = os.clock() + 2.5
        while os.clock() < waitBadge and not StopCheck() do
            for _, bName in ipairs({"PrintedBadge", "PatientBadgeBase", "VisitorBadgeBase"}) do
                local b = checkIn:FindFirstChild(bName)
                local bPP = b and (b:FindFirstChild("PP") or b:FindFirstChildWhichIsA("ProximityPrompt", true))
                if bPP and bPP.Enabled then
                    Log("AutoCheckIn", "Taking printed badge from desk", { prompt = bPP:GetFullName() })
                    TeleportPlayer(GetPromptPartPosition(bPP) or Positions.CheckInBadge)
                    task.wait(0.15)
                    FirePrompt(bPP, 0.3)
                    task.wait(0.2)
                    break
                end
            end
            if HasBadgeInInventory() then break end
            task.wait(0.15)
        end
    end

    -- 7. Вручение бейджика клиенту
    DeliverBadgeToPatient(patient)
    _G.AH_IsCheckingIn = false
    return true
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- ☕ 10. AUTO BARNEY COFFEE
-- ══════════════════════════════════════════════════════════════════════════════════
local function ProcessBarneyCoffee()
    if not _G.AutoGiveBarneyCoffee or _G.AH_IsTreating or StopCheck() then return end

    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return end

    local barney = nil
    for _, npc in ipairs(npcs:GetChildren()) do
        if npc:IsA("Model") and IsBarney(npc) then
            barney = npc
            break
        end
    end
    if not barney then return end

    local barneyPP = nil
    for _, p in ipairs(barney:GetDescendants()) do
        if p:IsA("ProximityPrompt") and p.Enabled then
            barneyPP = p
            break
        end
    end
    if not barneyPP then return end

    -- Если кофе уже на руках
    if GetItemCount("Coffee") > 0 then
        UseInventoryTool("Coffee")
        TeleportAndFirePrompt(barneyPP, Positions.Barney, 0.4, 0.3)
        UnequipAllTools()
        return
    end

    -- Налить кофе
    local cm = Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("CoffeeMachine")
    local coffeePP = cm and cm:FindFirstChild("Coffee") and (cm.Coffee:FindFirstChild("PP") or cm.Coffee:FindFirstChildWhichIsA("ProximityPrompt", true))
    if coffeePP and coffeePP.Enabled then
        Log("AutoCoffee", "Brewing coffee for Barney")
        TeleportAndFirePrompt(coffeePP, Positions.CoffeeMachine, 1.6, 0.3)
        if GetItemCount("Coffee") > 0 then
            UseInventoryTool("Coffee")
            TeleportAndFirePrompt(barneyPP, Positions.Barney, 0.4, 0.3)
            UnequipAllTools()
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🧼 11. AUTO CLEAN SLIME
-- ══════════════════════════════════════════════════════════════════════════════════
local function CleanSlimePuddles()
    if not _G.AutoCleanSlime or _G.AH_IsTreating or StopCheck() then return end

    local puddles = Workspace:FindFirstChild("Puddles") or Workspace:FindFirstChild("Slime") or Workspace:FindFirstChild("Misc")
    if not puddles then return end

    for _, p in ipairs(puddles:GetDescendants()) do
        if p:IsA("ProximityPrompt") and p.Enabled then
            local act = string.lower(p.ActionText or "")
            if act:find("clean") or act:find("mop") or act:find("wipe") or act:find("sponge") then
                Log("AutoCleanSlime", "Cleaning slime puddle", { prompt = p:GetFullName() })
                TeleportAndFirePrompt(p, GetPromptPartPosition(p), 0.35, 0.2)
                break
            end
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🛒 12. AUTO BUY SHOP
-- ══════════════════════════════════════════════════════════════════════════════════
local function AutoBuyShopItems()
    if not _G.AutoBuyShop or _G.AH_IsTreating or StopCheck() then return end
    local shop = Workspace:FindFirstChild("Shop") or (Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("Shop"))
    if not shop then return end

    for _, p in ipairs(shop:GetDescendants()) do
        if p:IsA("ProximityPrompt") and p.Enabled then
            Log("AutoShop", "Buying shop item", { prompt = p:GetFullName() })
            TeleportAndFirePrompt(p, GetPromptPartPosition(p), 0.35, 0.2)
            break
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🚑 13. AUTO HELP FAINTED PATIENTS (PICKUP & BED DELIVERY)
-- ══════════════════════════════════════════════════════════════════════════════════
local function FindEmptyBedPrompt()
    local rooms = Workspace:FindFirstChild("Rooms")
    if not rooms then return nil, nil end

    local medical = rooms:FindFirstChild("Medical")
    if medical then
        for i = 1, 5 do
            local r = medical:FindFirstChild("Room" .. tostring(i))
            if r and not IsRoomRecovering(r) then
                local inBed = r:FindFirstChild("Minigame") and r.Minigame:FindFirstChild("Bed") and r.Minigame.Bed:FindFirstChild("InBed")
                local bedPP = inBed and (inBed:FindFirstChild("PP") or inBed:FindFirstChild("PP2") or inBed:FindFirstChildWhichIsA("ProximityPrompt", true))
                if bedPP and bedPP.Enabled then
                    return bedPP, GetPromptPartPosition(bedPP) or Positions["Room" .. tostring(i) .. "_Bed"]
                end
            end
        end
    end

    local emergency = rooms:FindFirstChild("Emergency")
    if emergency then
        for _, rName in ipairs({"Room6", "Room7", "Room8"}) do
            local r = emergency:FindFirstChild(rName)
            if r and not IsRoomRecovering(r) then
                local inBed = r:FindFirstChild("Minigame") and r.Minigame:FindFirstChild("Bed") and r.Minigame.Bed:FindFirstChild("InBed")
                local bedPP = inBed and (inBed:FindFirstChild("PP") or inBed:FindFirstChild("PP2") or inBed:FindFirstChildWhichIsA("ProximityPrompt", true))
                if bedPP and bedPP.Enabled then
                    return bedPP, GetPromptPartPosition(bedPP) or Positions[rName .. "_Bed"]
                end
            end
        end
    end

    return nil, nil
end

local function AutoHelpFaintedPatients()
    if not _G.AutoHelpPatient or _G.AH_IsTreating or StopCheck() then return end

    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return end

    for _, npc in ipairs(npcs:GetChildren()) do
        if npc:IsA("Model") and IsValidPatient(npc) then
            for _, p in ipairs(npc:GetDescendants()) do
                if p:IsA("ProximityPrompt") and p.Enabled then
                    local act = string.lower(p.ActionText or "")
                    if act:find("help") or act:find("carry") or act:find("revive") or act:find("faint") then
                        Log("AutoHelpPatient", "Helping fainted patient", { npc = npc:GetFullName() })
                        TeleportAndFirePrompt(p, GetPromptPartPosition(p), 0.35, 0.2)

                        -- Доставка на свободную койку
                        local bedPP, bedPos = FindEmptyBedPrompt()
                        if bedPP and bedPos then
                            Log("AutoHelpPatient", "Delivering patient to empty bed", { bed = bedPP:GetFullName() })
                            TeleportAndFirePrompt(bedPP, bedPos, 0.35, 0.3)
                        end
                        return
                    end
                end
            end
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🌐 14. SERVER UTILITIES (SERVER HOP, REJOIN, ANTI-AFK, FULLBRIGHT, SPEED)
-- ══════════════════════════════════════════════════════════════════════════════════
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")

local function RejoinServer()
    Log("Teleport", "Rejoining current server...")
    if #Players:GetPlayers() <= 1 then
        LocalPlayer:Kick("\n[Averlik Hub] Перезаходим на сервер...")
        task.wait(0.5)
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
end

local function ServerHop()
    Log("Teleport", "Searching for public servers to hop...")
    local sfUrl = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"
    local req = game:HttpGet(sfUrl)
    local data = HttpService:JSONDecode(req)

    if data and data.data then
        for _, server in ipairs(data.data) do
            if type(server) == "table" and server.id ~= game.JobId and server.playing < server.maxPlayers and server.playing > 0 then
                Log("Teleport", "Hopping to server: " .. server.id)
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                return
            end
        end
    end
    Log("Teleport", "No server found, rejoining...")
    RejoinServer()
end

local function ServerHopLowPlayer()
    Log("Teleport", "Searching for low-player server...")
    local sfUrl = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"
    local req = game:HttpGet(sfUrl)
    local data = HttpService:JSONDecode(req)

    if data and data.data then
        local candidates = {}
        for _, server in ipairs(data.data) do
            if type(server) == "table" and server.id ~= game.JobId and server.playing < server.maxPlayers and server.playing > 0 then
                table.insert(candidates, server)
            end
        end
        table.sort(candidates, function(a, b) return a.playing < b.playing end)
        if #candidates > 0 then
            Log("Teleport", "Hopping to low player server: " .. candidates[1].id .. " (" .. candidates[1].playing .. " players)")
            TeleportService:TeleportToPlaceInstance(game.PlaceId, candidates[1].id, LocalPlayer)
            return
        end
    end
    RejoinServer()
end

-- Anti-AFK
task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        if _G.AntiAFK ~= false and IsSessionActive() then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
            Log("AntiAFK", "Anti-AFK pulse sent to prevent kick")
        end
    end)
end)

-- Fullbright
local _origLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient
}

local function ToggleFullbright(enabled)
    if enabled then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = _origLighting.Brightness
        Lighting.ClockTime = _origLighting.ClockTime
        Lighting.FogEnd = _origLighting.FogEnd
        Lighting.GlobalShadows = _origLighting.GlobalShadows
        Lighting.Ambient = _origLighting.Ambient
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🎨 15. OBSIDIAN LUXURY UI (RAYFIELD DESIGN SYSTEM)
-- ══════════════════════════════════════════════════════════════════════════════════
local Rayfield = nil
pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if Rayfield then
    local Window = Rayfield:CreateWindow({
        Name = "🏥 Averlik Hub | Animal Hospital",
        LoadingTitle = "Averlik Hub v4.0",
        LoadingSubtitle = "by Averlik Dev Team",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "AverlikHub",
            FileName = "AnimalHospital"
        },
        KeySystem = false
    })

    local MainTab = Window:CreateTab("⚡ Автоматизация", 4483362458)
    local SafeTab = Window:CreateTab("🛡️ Защита и Барни", 4483362458)
    local MiscTab = Window:CreateTab("🌐 Утилиты и Сервер", 4483362458)

    MainTab:CreateSection("🏥 Медицина и Пациенты")

    MainTab:CreateToggle({
        Name = "🏥 Авто-Лечение (Палаты 1 - 8)",
        CurrentValue = _G.AutoTreatment,
        Flag = "AutoTreatment",
        Callback = function(Value) _G.AutoTreatment = Value end,
    })

    MainTab:CreateToggle({
        Name = "🏢 Авто-Регистрация (Ресепшен)",
        CurrentValue = _G.AutoCheckIn,
        Flag = "AutoCheckIn",
        Callback = function(Value) _G.AutoCheckIn = Value end,
    })

    MainTab:CreateToggle({
        Name = "🚑 Спасение упавших пациентов (Укладка на койку)",
        CurrentValue = _G.AutoHelpPatient,
        Flag = "AutoHelpPatient",
        Callback = function(Value) _G.AutoHelpPatient = Value end,
    })

    MainTab:CreateToggle({
        Name = "🧼 Авто-Уборка слизи (Лужи)",
        CurrentValue = _G.AutoCleanSlime,
        Flag = "AutoCleanSlime",
        Callback = function(Value) _G.AutoCleanSlime = Value end,
    })

    MainTab:CreateToggle({
        Name = "🛒 Авто-Покупка в магазине",
        CurrentValue = _G.AutoBuyShop,
        Flag = "AutoBuyShop",
        Callback = function(Value) _G.AutoBuyShop = Value end,
    })

    SafeTab:CreateSection("🛡️ Защита и Шторка")

    SafeTab:CreateToggle({
        Name = "🛑 Авто-Шторка от Аномалий (Скинвокеры)",
        CurrentValue = _G.AutoAnomalyShutter,
        Flag = "AutoAnomalyShutter",
        Callback = function(Value) _G.AutoAnomalyShutter = Value end,
    })

    SafeTab:CreateToggle({
        Name = "🚪 Авто-Шторка от Барни",
        CurrentValue = _G.AutoBarneyShutter,
        Flag = "AutoBarneyShutter",
        Callback = function(Value) _G.AutoBarneyShutter = Value end,
    })

    SafeTab:CreateToggle({
        Name = "☕ Кофе для Барни",
        CurrentValue = _G.AutoGiveBarneyCoffee,
        Flag = "AutoGiveBarneyCoffee",
        Callback = function(Value) _G.AutoGiveBarneyCoffee = Value end,
    })

    MiscTab:CreateSection("🌐 Сервер и Персонаж")

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
        Name = "🛡️ Anti-AFK (Защита от кика)",
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
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🔄 16. MAIN HIGH-PRECISION AUTOMATION LOOP
-- ══════════════════════════════════════════════════════════════════════════════════
task.spawn(function()
    Log("Loop", "Averlik Hub Animal Hospital Dynamic Engine Started", { sessionId = MySession, loopInterval = _G.LoopInterval })

    while IsSessionActive() do
        task.wait(_G.LoopInterval or 0.15)

        if not IsSessionActive() then break end

        -- 1. Оценка угроз и шторки
        pcall(EvaluateCounterThreats)

        -- 2. Спасение упавших пациентов (поднятие и доставка в койку)
        pcall(AutoHelpFaintedPatients)

        -- 3. Приоритетное адаптивное лечение во всех палатах (1 - 8)
        pcall(ExecuteTreatmentCycle)

        -- 4. Адаптивная регистрация клиентов на ресепшене
        pcall(ExecuteCheckInCycle)

        -- 5. Кофе для Барни
        pcall(ProcessBarneyCoffee)

        -- 6. Уборка слизи
        pcall(CleanSlimePuddles)

        -- 7. Авто-покупка в магазине
        pcall(AutoBuyShopItems)
    end

    Log("Loop", "Session gracefully stopped", { sessionId = MySession })
end)
