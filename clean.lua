-- ══════════════════════════════════════════════════════════════════════════════════
-- 🏥 AVERLIK HUB: ANIMAL HOSPITAL ULTIMATE 1-TO-1 SUITE (V21.0 DESIGNATED BED ENGINE)
-- ══════════════════════════════════════════════════════════════════════════════════

-- 🛑 SINGLETON SESSION LIFECYCLE GUARD
_G.AH_SessionCounter = (_G.AH_SessionCounter or 0) + 1
local MySession = _G.AH_SessionCounter
_G.AH_ActiveSession = MySession

local function IsSessionActive()
    return _G.AH_ActiveSession == MySession
end

local function StopCheck()
    return not IsSessionActive()
end

-- ⚙️ GLOBAL TOGGLES (DIRECTLY CONTROLLED BY GUI)
_G.AutoTreatment = _G.AutoTreatment ~= nil and _G.AutoTreatment or true
_G.AutoCheckIn = _G.AutoCheckIn ~= nil and _G.AutoCheckIn or true
_G.AutoAnomalyShutter = _G.AutoAnomalyShutter ~= nil and _G.AutoAnomalyShutter or true
_G.AutoBarneyShutter = _G.AutoBarneyShutter ~= nil and _G.AutoBarneyShutter or true
_G.AutoAskLeaveAnomaly = _G.AutoAskLeaveAnomaly ~= nil and _G.AutoAskLeaveAnomaly or true
_G.AutoKillAnomaly = _G.AutoKillAnomaly ~= nil and _G.AutoKillAnomaly or false
_G.AutoHelpPatient = _G.AutoHelpPatient ~= nil and _G.AutoHelpPatient or true
_G.AutoPutOutFire = _G.AutoPutOutFire ~= nil and _G.AutoPutOutFire or true
_G.AutoCleanSlime = _G.AutoCleanSlime ~= nil and _G.AutoCleanSlime or true
_G.AutoGiveBarneyCoffee = _G.AutoGiveBarneyCoffee ~= nil and _G.AutoGiveBarneyCoffee or true
_G.AutoFixCam = _G.AutoFixCam ~= nil and _G.AutoFixCam or true
_G.AutoTaser = _G.AutoTaser ~= nil and _G.AutoTaser or false
_G.AutoBuyShop = _G.AutoBuyShop ~= nil and _G.AutoBuyShop or false
_G.UnlockThirdPerson = _G.UnlockThirdPerson ~= nil and _G.UnlockThirdPerson or true
_G.AntiAFK = _G.AntiAFK ~= nil and _G.AntiAFK or true
_G.Fullbright = _G.Fullbright ~= nil and _G.Fullbright or false
_G.WalkSpeedValue = _G.WalkSpeedValue or 16
_G.LoopInterval = 0.15

-- 📌 RUNTIME STATE & DATASETS
_G.HasActiveThreat = false
local _AH_IsPerformingTask = false
local _AH_TreatedPatients = {}
local _AH_HandledCheckInPatients = {}
local _AH_PromptCooldowns = setmetatable({}, { __mode = "k" })
local _AH_LeavingNpcs = setmetatable({}, { __mode = "k" })

_G.AH_ItemList = {
    "Herbs", "Maple Syrup", "Eye Drops", "Pills", "Bandages",
    "Thermometer", "Cough Syrup", "Ointment", "Plaster", "First Aid Kit", "Medkit"
}
_G.AH_ItemSet = {}
for _, name in ipairs(_G.AH_ItemList) do _G.AH_ItemSet[name] = true end

_G.AH_SurgeryItemList = {
    "Scalpel", "Scissors", "Organ", "Transplant", "IV Drops", "Antibiotics", "Medkit", "Bandages", "Medicine"
}
_G.AH_SurgeryItemSet = {}
for _, name in ipairs(_G.AH_SurgeryItemList) do _G.AH_SurgeryItemSet[name] = true end

_G.AH_BlacklistedItemNames = {
    ["Chocolate bar"] = true,
    ["Chocolate"] = true,
    ["Coffee"] = true,
    ["Taser"] = true,
    ["Extinguisher"] = true
}

-- ══════════════════════════════════════════════════════════════════════════════════
-- 📍 1. STATIC PRECISE COORDINATES & ROOM DATA
-- ══════════════════════════════════════════════════════════════════════════════════
local Positions = {
    CheckInPC = Vector3.new(-97.68, 3.50, -2.50),
    CheckInForm = Vector3.new(-100.80, 4.41, 1.48),
    CheckInCamera = Vector3.new(-108.57, 4.65, -2.93),
    CheckInPrinter = Vector3.new(-97.68, 4.41, 3.63),
    CheckInBadge = Vector3.new(-97.68, 4.41, 3.63),
    CheckInCounter = Vector3.new(-103.91, 3.41, -0.40),
    ShutterButton = Vector3.new(-103.91, 5.00, 3.80),

    Barney = Vector3.new(-149.20, 3.46, -2.50),
    CoffeeMachine = Vector3.new(-123.83, 4.01, 10.33),
    Coffee = Vector3.new(-123.77, 3.80, 10.31),
    Trash = Vector3.new(-144.50, 3.46, -18.50),
    ExtinguisherStation = Vector3.new(-103.91, 4.00, 10.50),
    TaserStation = Vector3.new(-103.91, 4.00, 15.50),

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

    Room6_Bed = Vector3.new(-181.83, 3.91, 54.08),
    Room6_XrayStart = Vector3.new(-176.77, 2.90, 54.93),
    Room6_XrayMonitor = Vector3.new(-169.33, 4.73, 63.33),
    Room6_PrintedXRay = Vector3.new(-166.05, 3.65, 63.60),
    Room6_TV = Vector3.new(-166.08, 9.24, 64.89),

    Room7_Bed = Vector3.new(-106.53, 3.24, 52.13),
    Room7_Monitor = Vector3.new(-125.52, 4.78, 63.27),
    Room7_PrintedXRay = Vector3.new(-128.50, 4.78, 63.27),
    Room7_TV = Vector3.new(-100.79, 8.64, 51.97),

    Room8_Bed = Vector3.new(-144.89, 3.56, 99.59),
    Room8_Monitor = Vector3.new(-134.63, 4.78, 85.74),
    Room8_TV = Vector3.new(-144.93, 8.34, 114.49)
}

_G.AH_RoomData = {
    [1] = { Name = "Room1", Emergency = false, Position = Positions.Room1_Bed },
    [2] = { Name = "Room2", Emergency = false, Position = Positions.Room2_Bed },
    [3] = { Name = "Room3", Emergency = false, Position = Positions.Room3_Bed },
    [4] = { Name = "Room4", Emergency = false, Position = Positions.Room4_Bed },
    [5] = { Name = "Room5", Emergency = false, Position = Positions.Room5_Bed },
    [6] = { Name = "Room6", Emergency = true, Position = Positions.Room6_Bed },
    [7] = { Name = "Room7", Emergency = true, Position = Positions.Room7_Bed },
    [8] = { Name = "Room8", Emergency = true, Position = Positions.Room8_Bed }
}

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🔍 2. CORE UTILITIES & LOGGING ENGINE
-- ══════════════════════════════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
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
    return string.gsub(s, "%s+", "")
end

local function GetCharacter()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
    return char, root
end

local function TeleportPlayer(pos)
    if not pos or StopCheck() then return end
    local _, root = GetCharacter()
    if root then
        root.CFrame = CFrame.new(pos + Vector3.new(0, 1.2, 0))
    end
end

local function GetPromptPosition(prompt)
    if not prompt then return nil end
    local p = prompt.Parent
    if not p then return nil end
    if p:IsA("BasePart") then return p.Position end
    if p:IsA("Attachment") then return p.WorldPosition end
    if p:IsA("Model") then
        local pp = p.PrimaryPart or p:FindFirstChildWhichIsA("BasePart")
        if pp then return pp.Position end
        local ok, piv = pcall(function() return p:GetPivot() end)
        if ok and piv then return piv.Position end
    end
    local bp = p:FindFirstChildWhichIsA("BasePart", true)
    if bp then return bp.Position end
    return nil
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- ⚡ 3. BULLETPROOF PROXIMITY PROMPT ENGINE
-- ══════════════════════════════════════════════════════════════════════════════════
local function PressPP(prompt, holdTime)
    if not prompt or not prompt.Parent or not prompt.Enabled or StopCheck() then return false end

    local now = os.clock()
    local hold = (prompt:IsA("ProximityPrompt") and prompt.HoldDuration > 0 and (prompt.HoldDuration + 0.1)) or 0
    local waitTime = math.max(holdTime or 0.35, hold)

    if _AH_PromptCooldowns[prompt] and (now - _AH_PromptCooldowns[prompt] < waitTime) then
        return false
    end
    _AH_PromptCooldowns[prompt] = now

    Log("Prompt", "Firing proximity prompt", {
        actionText = prompt.ActionText,
        enabled = prompt.Enabled,
        prompt = prompt:GetFullName()
    })

    pcall(function()
        if type(fireproximityprompt) == "function" then
            fireproximityprompt(prompt)
            fireproximityprompt(prompt, 0)
            fireproximityprompt(prompt, 1, true)
        end
    end)

    pcall(function()
        if prompt.InputHoldBegin and prompt.InputHoldEnd then
            prompt:InputHoldBegin()
            task.wait(math.max(0.05, (prompt.HoldDuration or 0) + 0.05))
            prompt:InputHoldEnd()
        end
    end)

    return true
end

local function PressPromptNearby(prompt, waitAfter, offset, waitBefore)
    if not prompt or not prompt.Enabled or StopCheck() then return false end
    local pos = GetPromptPosition(prompt)
    if pos then
        TeleportPlayer(pos + (offset or Vector3.new(0, 1.0, 1.5)))
        task.wait(waitBefore or 0.15)
        if StopCheck() then return false end
    end
    local res = PressPP(prompt)
    task.wait(waitAfter or 0.3)
    return res
end

local function PressPromptNearbyUntil(prompt, interval, timeout, condition, offset)
    if not prompt or not prompt.Enabled or StopCheck() then return false end
    local pos = GetPromptPosition(prompt)
    if pos then
        TeleportPlayer(pos + (offset or Vector3.new(0, 1.0, 1.5)))
        task.wait(0.15)
        if StopCheck() then return false end
    end

    local start = os.clock()
    while prompt and prompt.Parent and os.clock() - start < (timeout or 3.0) and not StopCheck() do
        if condition and condition() then return true end
        if not prompt.Enabled then return true end

        PressPP(prompt, interval or 0.35)
        task.wait(interval or 0.25)
    end
    if condition then return condition() == true end
    return not (prompt and prompt.Parent and prompt.Enabled)
end

local treatmentOffset = Vector3.new(0, 1.5, 0)

local function PressTreatmentPromptNearbyUntil(prompt, interval, timeout, condition)
    if not prompt or not prompt.Enabled or StopCheck() then return false end
    local pos = GetPromptPosition(prompt)
    if pos then
        TeleportPlayer(pos + treatmentOffset)
        task.wait(0.1)
        if StopCheck() then return false end
    end

    local deadline = os.clock() + (timeout or 2.0)
    while prompt and prompt.Parent and os.clock() < deadline and not StopCheck() do
        if condition and condition() then return true end
        if not prompt.Enabled then return true end

        PressPP(prompt, interval or 0.25)
        task.wait(interval or 0.2)
    end
    if condition then return condition() == true end
    return not (prompt and prompt.Parent and prompt.Enabled)
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🎒 4. INVENTORY & TOOL CONTROL ENGINE
-- ══════════════════════════════════════════════════════════════════════════════════
local function InventoryParents()
    local list = {}
    local char = LocalPlayer.Character
    if char then table.insert(list, char) end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then table.insert(list, bp) end
    return list
end

local function GetInventoryTool(itemName)
    local target = NormalizeName(itemName)
    for _, container in ipairs(InventoryParents()) do
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") and NormalizeName(tool.Name) == target then
                return tool
            end
        end
    end
    return nil
end

local function GetItemCount(itemName)
    local count = 0
    local target = NormalizeName(itemName)
    for _, container in ipairs(InventoryParents()) do
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") and NormalizeName(tool.Name) == target then
                count = count + 1
            end
        end
    end
    return count
end

local function EquipToolOnly(tool)
    if not tool or not tool:IsA("Tool") then return false end
    local char = LocalPlayer.Character
    if char and tool.Parent == char then return true end
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:EquipTool(tool)
        task.wait(0.1)
        return true
    end
    return false
end

local function UseInventoryTool(itemName)
    local tool = GetInventoryTool(itemName)
    if not tool then return false end
    if not EquipToolOnly(tool) then return false end
    task.wait(0.05)
    pcall(function() tool:Activate() end)
    task.wait(0.1)
    return true
end

local function UnequipAllTools()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum:UnequipTools() end
end

local function DiscardToolAtTrash(tool)
    if not tool or StopCheck() then return end
    EquipToolOnly(tool)
    task.wait(0.05)

    local trash = Workspace:FindFirstChild("Trash")
    local trashPP = trash and (trash:FindFirstChild("PP") or trash:FindFirstChildWhichIsA("ProximityPrompt", true))
    local trashPos = (trashPP and GetPromptPosition(trashPP)) or Positions.Trash

    TeleportPlayer(trashPos)
    task.wait(0.15)

    if trashPP and trashPP.Enabled then
        PressPromptNearbyUntil(trashPP, 0.2, 1.5, function()
            return not tool.Parent or tool.Parent ~= LocalPlayer.Character
        end)
    end
end

local function GetWrongInventoryTool(targetItem)
    local target = NormalizeName(targetItem)
    for _, container in ipairs(InventoryParents()) do
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") and NormalizeName(tool.Name) ~= target and (_G.AH_ItemSet[tool.Name] or _G.AH_SurgeryItemSet[tool.Name] or _G.AH_BlacklistedItemNames[tool.Name]) then
                return tool
            end
        end
    end
    return nil
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🔍 5. EXACT ANCESTOR MODEL PROMPT INDEXER (FOXNAME ENGINE)
-- ══════════════════════════════════════════════════════════════════════════════════
local _AH_ItemIndexTable = {}
local _AH_IndexedOnce = false

local function GetBlacklistedContainer()
    local ok, res = pcall(function() return Workspace.Rooms.Emergency.Room8.Minigame.Medicine end)
    if ok and res then return res end
    return nil
end

local function IsDescendantOfBlacklist(prompt)
    local bl = GetBlacklistedContainer()
    if bl and prompt:IsDescendantOf(bl) then return true end
    local fullName = prompt:GetFullName()
    if fullName:find("Room8.Minigame.Medicine") or fullName:find("Emergency.Room8") then
        return true
    end
    return false
end

local function IndexTreatmentPrompt(prompt)
    if not prompt:IsA("ProximityPrompt") then return end
    local current = prompt.Parent
    while current and current ~= Workspace do
        local cName = current.Name
        if _G.AH_ItemSet[cName] and not _G.AH_BlacklistedItemNames[cName] and (current:IsA("Model") or current:IsA("BasePart")) then
            local tbl = _AH_ItemIndexTable[cName]
            if not tbl then tbl = {} _AH_ItemIndexTable[cName] = tbl end
            tbl[prompt] = true
            return
        end
        current = current.Parent
    end
end

local function InitTreatmentIndex()
    if _AH_IndexedOnce then return end
    _AH_IndexedOnce = true
    local all = Workspace:GetDescendants()
    for i = 1, #all do
        local obj = all[i]
        if obj:IsA("ProximityPrompt") then
            IndexTreatmentPrompt(obj)
        end
        if i % 400 == 0 then task.wait() end
    end
    Workspace.DescendantAdded:Connect(IndexTreatmentPrompt)
end

local function GetSurgeryItemPP(itemName)
    local ok, med = pcall(function() return Workspace.Rooms.Emergency.Room8.Minigame.Medicine end)
    if ok and med then
        for _, d in ipairs(med:GetDescendants()) do
            if d:IsA("ProximityPrompt") and d.Parent and d.Parent.Name == itemName then
                return d
            end
        end
    end
    return nil
end

local function GetItemPP(itemName)
    if not _G.AH_ItemSet[itemName] or _G.AH_BlacklistedItemNames[itemName] then return nil end
    InitTreatmentIndex()
    local promptSet = _AH_ItemIndexTable[itemName]
    if promptSet then
        for prompt in pairs(promptSet) do
            if prompt.Parent and prompt.Enabled and not IsDescendantOfBlacklist(prompt) then
                return prompt
            end
        end
    end
    return nil
end

local function GrabItemUntilInInventory(itemName, isSurgery)
    if GetItemCount(itemName) > 0 then return true end

    -- Очистка посторонних инструментов
    local wrong = GetWrongInventoryTool(itemName)
    if wrong then DiscardToolAtTrash(wrong) end

    local prompt = nil
    if isSurgery then
        prompt = GetSurgeryItemPP(itemName)
    else
        prompt = GetItemPP(itemName)
    end

    if prompt then
        Log("AutoTreatment", "Grabbing treatment item", { targetItem = itemName, prompt = prompt:GetFullName(), countBefore = GetItemCount(itemName) })
        local countBefore = GetItemCount(itemName)
        PressTreatmentPromptNearbyUntil(prompt, 0.12, 1.5, function() return GetItemCount(itemName) > countBefore end)
        local t = os.clock()
        while os.clock() - t < 1.5 and not StopCheck() do
            if GetItemCount(itemName) > countBefore then break end
            task.wait(0.03)
        end
        task.wait(0.1)
    else
        Log("AutoTreatment", "Prescription shelf prompt not found", { item = itemName })
    end

    return GetItemCount(itemName) > 0
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🛡️ 6. PURE FOXNAME THREAT DETECTION & SHUTTER ENGINE
-- ══════════════════════════════════════════════════════════════════════════════════
local function GetShutterPP()
    local misc = Workspace:FindFirstChild("Misc")
    local btn = misc and misc:FindFirstChild("ShutterButton")
    return btn and (btn:FindFirstChild("PP") or btn:FindFirstChildWhichIsA("ProximityPrompt", true))
end

local function IsShutterClosed()
    local pp = GetShutterPP()
    if not pp then return nil end
    return string.lower(tostring(pp.ActionText or "")) == "open"
end

local function SetShutterClosed(shouldBeClosed)
    local pp = GetShutterPP()
    if not pp or not pp.Enabled or StopCheck() then return false end
    local isClosed = IsShutterClosed()
    if isClosed == nil or isClosed == shouldBeClosed then return false end

    Log("AutoShutter", shouldBeClosed and "Closing shutter" or "Opening shutter")
    PressPromptNearby(pp, 0.35, Vector3.new(0, 1.0, 1.5), 0.15)
    return true
end

local function IsBarneyNpc(npc)
    if not npc then return false end
    return string.find(string.lower(npc.Name), "barney") ~= nil
end

local function IsValidPatient(npc)
    if not npc or not npc:IsA("Model") then return false end
    local name = npc.Name
    if name == "Barney" or name == "Cleaner" or name == "Guard" or name == "Security" then return false end
    return true
end

local function IsNpcThreat(npc)
    if not npc or not npc:IsA("Model") then return false end
    if _G.AutoBarneyShutter and IsBarneyNpc(npc) then return true end
    if _G.AutoAnomalyShutter and npc:GetAttribute("Skinwalker") == true then return true end
    return false
end

local function IsThreatLeaving(npc)
    if not npc or not npc:IsA("Model") then return false end
    if _AH_LeavingNpcs[npc] then return true end

    local hum = npc:FindFirstChildOfClass("Humanoid")
    if hum then
        for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
            local anim = track.Animation
            local animId = anim and anim.AnimationId or ""
            if animId:find("88351809285459") or (track.Priority == Enum.AnimationPriority.Action and not track.Looped) then
                _AH_LeavingNpcs[npc] = true
                return true
            end
        end
    end
    return false
end

local function HasNormalPatientAtCheckIn()
    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return false end

    local center = Positions.CheckInCounter
    for _, npc in ipairs(npcs:GetChildren()) do
        if npc:IsA("Model") and IsValidPatient(npc) and not IsNpcThreat(npc) then
            local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso") or npc:FindFirstChildWhichIsA("BasePart")
            if root and (root.Position - center).Magnitude <= 28 then
                return true
            end
        end
    end
    return false
end

local function HasThreatNearCheckIn()
    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return false end

    for _, npc in ipairs(npcs:GetChildren()) do
        if npc:IsA("Model") and IsNpcThreat(npc) and not IsThreatLeaving(npc) then
            local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso") or npc:FindFirstChildWhichIsA("BasePart")
            if root and (root.Position - Positions.CheckInCounter).Magnitude <= 32 then
                return true
            end
        end
    end
    return false
end

local function EvaluateShutterLogic()
    if not (_G.AutoBarneyShutter or _G.AutoAnomalyShutter) then
        if IsShutterClosed() == true then
            SetShutterClosed(false)
        end
        return
    end

    local threatNear = HasThreatNearCheckIn()

    if threatNear then
        _G.HasActiveThreat = true
        if IsShutterClosed() == false then
            Log("AutoShutter", "Closed shutter for active threat at check-in")
            SetShutterClosed(true)
        end
    else
        _G.HasActiveThreat = false
        if IsShutterClosed() == true then
            Log("AutoShutter", "Opening shutter: no active threats at counter")
            SetShutterClosed(false)
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 📺 7. TV PRESCRIPTION PARSER (FOXNAME EXACT UI & STATUS CHECK)
-- ══════════════════════════════════════════════════════════════════════════════════
local function GetRoomFolder(roomData)
    local rooms = Workspace:FindFirstChild("Rooms")
    if not rooms then return nil end
    return roomData.Emergency and rooms:FindFirstChild("Emergency") or rooms:FindFirstChild("Medical")
end

local function GetReportInventory(roomData)
    local folder = GetRoomFolder(roomData)
    local room = folder and folder:FindFirstChild(roomData.Name)
    local inv = room and room:FindFirstChild("Minigame") and room.Minigame:FindFirstChild("TV") and room.Minigame.TV:FindFirstChild("Screen") and room.Minigame.TV.Screen:FindFirstChild("UI") and room.Minigame.TV.Screen.UI:FindFirstChild("Report") and room.Minigame.TV.Screen.UI.Report:FindFirstChild("inv")
    return inv
end

local function GetNeededTreatmentItems(roomData)
    local needed = {}
    local inv = GetReportInventory(roomData)
    if inv then
        for _, itemGui in ipairs(inv:GetChildren()) do
            if itemGui:IsA("GuiObject") and itemGui.Visible then
                local isItem = _G.AH_ItemSet[itemGui.Name] or (roomData.Name == "Room8" and _G.AH_SurgeryItemSet[itemGui.Name])
                local check = itemGui:FindFirstChild("check")
                local isChecked = check and check.Visible == true
                if isItem and not isChecked then
                    table.insert(needed, itemGui.Name)
                end
            end
        end
    end
    return needed
end

local function IsRoomRecovering(roomData)
    local folder = GetRoomFolder(roomData)
    local room = folder and folder:FindFirstChild(roomData.Name)
    if not room then return false end

    local ok, healing, header = pcall(function()
        local ui = room.Minigame.TV.Screen.UI
        return ui.Healing, ui.Healing.header
    end)
    if ok and healing and header and healing.Visible then
        local text = string.lower(tostring(header.Text or ""))
        if text:find("patient") ~= nil and text:find("recover") ~= nil then
            return true
        end
    end
    return false
end

local function IsPatientAlreadyTreated(npc)
    if not npc then return true end
    local last = _AH_TreatedPatients[npc.Name]
    if last and (os.clock() - last < 25.0) then return true end
    return false
end

local function MarkPatientTreated(npc)
    if npc then _AH_TreatedPatients[npc.Name] = os.clock() end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🛏️ 8. DESIGNATED BED RESOLVER & PATIENT PLACEMENT
-- ══════════════════════════════════════════════════════════════════════════════════
local function GetBedPromptForPatient(patient)
    if not patient then return nil, nil end

    local desRoom = patient:GetAttribute("DesignatedRoom")
    local rooms = Workspace:FindFirstChild("Rooms")
    if not rooms then return nil, nil end

    -- 1. Точная доставка в назначенную палату (DesignatedRoom)
    if desRoom and typeof(desRoom) == "string" and desRoom ~= "" then
        local rFolder = rooms:FindFirstChild("Medical") and rooms.Medical:FindFirstChild(desRoom)
        if not rFolder and rooms:FindFirstChild("Emergency") then
            rFolder = rooms.Emergency:FindFirstChild(desRoom)
        end
        if rFolder then
            local mg = rFolder:FindFirstChild("Minigame")
            local bed = mg and mg:FindFirstChild("Bed")
            local inBed = bed and bed:FindFirstChild("InBed")
            if inBed then
                local pp2 = inBed:FindFirstChild("PP2") or inBed:FindFirstChild("PP") or inBed:FindFirstChildWhichIsA("ProximityPrompt", true)
                if pp2 and pp2.Enabled then
                    return pp2, GetPromptPosition(pp2) or (bed:FindFirstChildWhichIsA("BasePart") and bed:FindFirstChildWhichIsA("BasePart").Position)
                end
            end
            if bed then
                local pp = bed:FindFirstChildWhichIsA("ProximityPrompt", true)
                if pp and pp.Enabled then
                    return pp, GetPromptPosition(pp)
                end
            end
        end
    end

    -- 2. Поиск свободной койки (приоритет PP2)
    for _, cat in ipairs({"Medical", "Emergency"}) do
        local catFolder = rooms:FindFirstChild(cat)
        if catFolder then
            for _, r in ipairs(catFolder:GetChildren()) do
                local mg = r:FindFirstChild("Minigame")
                local bed = mg and mg:FindFirstChild("Bed")
                local inBed = bed and bed:FindFirstChild("InBed")
                if inBed then
                    local pp2 = inBed:FindFirstChild("PP2") or inBed:FindFirstChild("PP") or inBed:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if pp2 and pp2.Enabled then
                        return pp2, GetPromptPosition(pp2)
                    end
                end
            end
        end
    end

    return nil, nil
end

local function GetRoomBedPrompt(roomData, minigame, patient)
    if roomData.Name == "Room6" then
        return patient and (patient:FindFirstChild("PP") or patient:FindFirstChildWhichIsA("ProximityPrompt", true))
    end

    local bed = minigame:FindFirstChild("Bed")
    if bed then
        local inBed = bed:FindFirstChild("InBed")
        local p = inBed and (inBed:FindFirstChild("PP") or inBed:FindFirstChildWhichIsA("ProximityPrompt", true))
        if p and p.Enabled then return p end

        local p2 = bed:FindFirstChild("PP") or bed:FindFirstChildWhichIsA("ProximityPrompt", true)
        if p2 and p2.Enabled then return p2 end
    end

    if patient then
        local npPP = patient:FindFirstChild("PP") or patient:FindFirstChildWhichIsA("ProximityPrompt", true)
        if npPP and npPP.Enabled then return npPP end
    end

    return nil
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🏥 9. COMPLETE TREATMENT ENGINE (ATOMIC FULL ROOM COMPLETION)
-- ══════════════════════════════════════════════════════════════════════════════════
local function GetPatientInRoom(roomData)
    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return nil end

    for _, npc in ipairs(npcs:GetChildren()) do
        if npc:IsA("Model") and not npc:GetAttribute("IsVisitor") and (npc:GetAttribute("IsPatient") == true or npc:GetAttribute("Skinwalker") == true) then
            local desRoom = npc:GetAttribute("DesignatedRoom")
            if desRoom == roomData.Name then
                return npc
            end
            local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso") or npc:FindFirstChildWhichIsA("BasePart")
            if root and (root.Position - roomData.Position).Magnitude <= 28 then
                return npc
            end
        end
    end
    return nil
end

local function TreatSingleRoom(roomData)
    if not _G.AutoTreatment or StopCheck() then return false end

    if IsRoomRecovering(roomData) then return false end

    local folder = GetRoomFolder(roomData)
    local room = folder and folder:FindFirstChild(roomData.Name)
    if not room then return false end

    local minigame = room:FindFirstChild("Minigame")
    if not minigame then return false end

    local patient = GetPatientInRoom(roomData)
    local didAction = false

    -- 0. Если пациент возле палаты, но не на койке -> нажимаем PP2 (Place Patient in Bed)
    if patient and roomData.Name ~= "Room6" and patient:GetAttribute("InBed") ~= true then
        local inBed = minigame:FindFirstChild("Bed") and minigame.Bed:FindFirstChild("InBed")
        local placePP = inBed and inBed:FindFirstChild("PP2")
        if placePP and placePP.Enabled then
            Log("AutoTreatment", "Placing patient in room bed PP2", { room = roomData.Name, prompt = placePP:GetFullName() })
            PressTreatmentPromptNearbyUntil(placePP, 0.2, 2.5, function()
                return not placePP.Parent or not placePP.Enabled or (patient and patient:GetAttribute("InBed") == true)
            end)
            task.wait(0.2)
        end
    end

    -- 1. DNA Sample Prompt (на пациенте)
    if patient then
        for _, p in ipairs(patient:GetDescendants()) do
            if p:IsA("ProximityPrompt") and p.Enabled then
                local act = string.lower(p.ActionText or "")
                if act:find("sample") or act:find("dna") or act:find("take") or act:find("prepare") then
                    Log("AutoTreatment", "Taking DNA sample", { room = roomData.Name, prompt = p:GetFullName() })
                    PressPromptNearby(p, 0.4, Vector3.new(0, 1.0, 1.5), 0.2)
                    didAction = true
                    task.wait(0.3)
                    break
                end
            end
        end
    end

    -- 2. Analyzer Prompt (Rooms 1 - 5)
    local analyzer = minigame:FindFirstChild("Analyzer")
    local analyzerPP = analyzer and (analyzer:FindFirstChild("PP") or analyzer:FindFirstChildWhichIsA("ProximityPrompt", true))
    if analyzerPP and analyzerPP.Enabled then
        Log("AutoTreatment", "Analyzing sample in analyzer", { room = roomData.Name, prompt = analyzerPP:GetFullName() })
        PressPromptNearby(analyzerPP, 0.4, Vector3.new(0, 1.0, 1.5), 0.2)
        didAction = true
        task.wait(0.3)
    end

    -- 3. X-Ray Start Prompt (Room 6 xrayMonitor)
    local xrayMonitor = minigame:FindFirstChild("xrayMonitor")
    local xrayPP = xrayMonitor and (xrayMonitor:FindFirstChild("PP") or xrayMonitor:FindFirstChildWhichIsA("ProximityPrompt", true))
    if xrayPP and xrayPP.Enabled then
        Log("AutoTreatment", "Starting X-Ray scan", { room = roomData.Name, prompt = xrayPP:GetFullName() })
        PressPromptNearby(xrayPP, 0.4, Vector3.new(0, 1.0, 1.5), 0.2)
        didAction = true
        task.wait(0.3)
    end

    -- 4. Monitor Process Prompt (PP2)
    local monitor = minigame:FindFirstChild("Monitor")
    local monitorPP2 = monitor and (monitor:FindFirstChild("PP2") or monitor:FindFirstChildWhichIsA("ProximityPrompt", true))
    if monitorPP2 and monitorPP2.Enabled then
        Log("AutoTreatment", "Processing monitor results", { room = roomData.Name, prompt = monitorPP2:GetFullName() })
        PressPromptNearby(monitorPP2, 0.4, Vector3.new(0, 1.0, 1.5), 0.2)
        didAction = true
        task.wait(0.3)
    end

    -- 5. Printed X-Ray Result (xresult / PrintedXRay)
    local xresult = minigame:FindFirstChild("xresult") or minigame:FindFirstChild("PrintedXRay")
    local xresultPP = xresult and (xresult:FindFirstChild("PP") or xresult:FindFirstChildWhichIsA("ProximityPrompt", true))
    if xresultPP and xresultPP.Enabled then
        Log("AutoTreatment", "Taking X-Ray result", { room = roomData.Name, prompt = xresultPP:GetFullName() })
        PressPromptNearby(xresultPP, 0.4, Vector3.new(0, 1.0, 1.5), 0.2)
        didAction = true
        task.wait(0.3)
    end

    -- 6. Доставка медикаментов по рецепту (ATOMIC EXECUTION)
    local needed = GetNeededTreatmentItems(roomData)
    if #needed > 0 then
        Log("AutoTreatment", "Starting patient prescription delivery", {
            emergency = roomData.Emergency and "true" or "false",
            neededItems = table.concat(needed, ", "),
            npc = patient and patient:GetFullName() or (roomData.Name .. ".Patient"),
            room = roomData.Name
        })

        local attempt = 0
        local appliedAny = false

        while _G.AutoTreatment and not StopCheck() and attempt < 20 do
            if IsRoomRecovering(roomData) then
                Log("AutoTreatment", "Patient is recovering, completed", { room = roomData.Name })
                break
            end

            needed = GetNeededTreatmentItems(roomData)
            if #needed == 0 then
                task.wait(0.3)
                needed = GetNeededTreatmentItems(roomData)
                if #needed == 0 or IsRoomRecovering(roomData) then break end
            end

            attempt = attempt + 1
            local currentItem = needed[1]

            if _G.AutoKillAnomaly and patient and patient:GetAttribute("Skinwalker") == true then
                local allItems = roomData.Emergency and _G.AH_SurgeryItemList or _G.AH_ItemList
                for _, wrong in ipairs(allItems) do
                    local isWanted = false
                    for _, req in ipairs(needed) do if req == wrong then isWanted = true break end end
                    if not isWanted then currentItem = wrong break end
                end
            end

            if GetItemCount(currentItem) == 0 then
                GrabItemUntilInInventory(currentItem, roomData.Emergency)
            end

            if GetItemCount(currentItem) > 0 then
                UseInventoryTool(currentItem)
                task.wait(0.05)

                local targetPrompt = GetRoomBedPrompt(roomData, minigame, patient)
                if not targetPrompt then
                    task.wait(0.3)
                    targetPrompt = GetRoomBedPrompt(roomData, minigame, patient)
                end

                if targetPrompt and targetPrompt.Enabled then
                    Log("AutoTreatment", "Delivering treatment item to bed", { room = roomData.Name, targetItem = currentItem, prompt = targetPrompt:GetFullName() })
                    PressTreatmentPromptNearbyUntil(targetPrompt, 0.15, 2.5, function()
                        return GetItemCount(currentItem) == 0 or not targetPrompt.Parent or not targetPrompt.Enabled
                    end)

                    UnequipAllTools()
                    appliedAny = true

                    local waitTimeout = os.clock() + 3.0
                    while os.clock() < waitTimeout and not StopCheck() do
                        if IsRoomRecovering(roomData) then break end
                        local curNeeded = GetNeededTreatmentItems(roomData)
                        local stillInReport = false
                        for _, it in ipairs(curNeeded) do
                            if it == currentItem then stillInReport = true break end
                        end
                        if not stillInReport then
                            Log("AutoTreatment", "Item successfully applied and checked off TV", { item = currentItem, room = roomData.Name })
                            break
                        end
                        task.wait(0.2)
                    end
                else
                    Log("AutoTreatment", "Target bed/patient prompt not available", { room = roomData.Name })
                    task.wait(0.2)
                end
            else
                task.wait(0.3)
            end
        end

        local wrong = GetWrongInventoryTool("")
        if wrong then DiscardToolAtTrash(wrong) end

        if appliedAny or IsRoomRecovering(roomData) then
            if patient then MarkPatientTreated(patient) end
            Log("AutoTreatment", "Finished patient treatment", { npc = patient and patient:GetFullName() or (roomData.Name .. ".Patient"), room = roomData.Name })
        end

        return true
    end

    return didAction
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🏢 10. COMPLETE RECEPTION ENGINE (ATOMIC ZERO-INTERRUPT FLOW)
-- ══════════════════════════════════════════════════════════════════════════════════
local function GetCheckInStations()
    local stations = {}
    local misc = Workspace:FindFirstChild("Misc")
    if misc then
        for _, name in ipairs({"CheckIn", "CheckIn2"}) do
            local s = misc:FindFirstChild(name)
            if s then table.insert(stations, s) end
        end
    end
    return stations
end

local function IsRecentlyHandledCheckInPatient(npc)
    if not npc then return true end
    local last = _AH_HandledCheckInPatients[npc.Name]
    if last and (os.clock() - last < 20.0) then return true end
    return false
end

local function MarkCheckInPatientHandled(npc)
    if npc then
        _AH_HandledCheckInPatients[npc.Name] = os.clock()
    end
end

local function GetPatientAtCounter()
    if IsShutterClosed() == true or _G.HasActiveThreat then return nil, nil end

    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return nil, nil end

    for _, station in ipairs(GetCheckInStations()) do
        local pc = station:FindFirstChild("Computer")
        local center = (pc and GetPromptPosition(pc)) or Positions.CheckInCounter

        for _, npc in ipairs(npcs:GetChildren()) do
            if npc:IsA("Model") and IsValidPatient(npc) and not IsRecentlyHandledCheckInPatient(npc) then
                if not IsNpcThreat(npc) then
                    local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso") or npc:FindFirstChildWhichIsA("BasePart")
                    if root and (root.Position - center).Magnitude <= 28 then
                        return npc, station
                    end
                end
            end
        end
    end

    return nil, nil
end

local function GetNpcTalkPrompt(npc)
    if not npc then return nil end
    for _, p in ipairs(npc:GetDescendants()) do
        if p:IsA("ProximityPrompt") and string.find(string.lower(p.ActionText or ""), "talk") and p.Enabled then
            return p
        end
    end
    return nil
end

local function GetNpcCheckInPrompt(npc)
    if not npc or IsBarneyNpc(npc) or npc:GetAttribute("Skinwalker") == true then return nil end
    local talk = GetNpcTalkPrompt(npc)
    if talk then return talk end

    for _, p in ipairs(npc:GetDescendants()) do
        if p:IsA("ProximityPrompt") and p.Enabled then
            local act = string.lower(tostring(p.ActionText or ""))
            if act ~= "" and not act:find("carry") and not act:find("help") and not act:find("faint") then
                return p
            end
        end
    end
    return nil
end

local function FinishPatientCheckIn(patient)
    if not patient or StopCheck() then return false end
    local prompt = GetNpcCheckInPrompt(patient)
    if not prompt or not prompt.Enabled then return false end

    Log("AutoCheckIn", "Giving badge / talking to finish check-in", { patient = patient:GetFullName(), prompt = prompt:GetFullName() })

    local pPos = GetPromptPosition(prompt) or (patient:FindFirstChild("HumanoidRootPart") and patient.HumanoidRootPart.Position)
    if pPos then
        TeleportPlayer(pPos + Vector3.new(0, 1.2, 1.5))
        task.wait(0.15)
    end

    local pressed = PressPP(prompt, 0.4)
    if pressed then
        pcall(function()
            patient:SetAttribute("CompletedCheckIn", LocalPlayer.Name)
            patient:SetAttribute("FoxnameCheckInPromptHandled", true)
        end)
        MarkCheckInPatientHandled(patient)
        Log("AutoCheckIn", "Successfully finished check-in for patient", { patient = patient:GetFullName() })
        return true
    end
    return false
end

local function ExecuteCheckInCycle()
    if not _G.AutoCheckIn or IsShutterClosed() == true or _G.HasActiveThreat or StopCheck() then
        return false
    end

    local patient, checkIn = GetPatientAtCounter()
    if not patient or not checkIn then return false end

    -- Проверка на StalkerMonster и StrangePaper
    local npcs = Workspace:FindFirstChild("NPCs")
    if npcs and npcs:FindFirstChild("StalkerMonster") then
        local strangePaper = Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("StrangePaper")
        local spPP = strangePaper and strangePaper:FindFirstChildWhichIsA("ProximityPrompt", true)
        if spPP and spPP.Enabled then
            Log("AutoCheckIn", "Interacting with StrangePaper for StalkerMonster")
            PressPromptNearby(spPP, 0.3, Vector3.new(0, 1.0, 1.5), 0.15)
        end
    end

    Log("AutoCheckIn", "Starting check-in cycle for patient", { patient = patient:GetFullName() })

    local maxSteps = 10
    local step = 0
    while not StopCheck() and step < maxSteps do
        step = step + 1

        -- 1. Если NPC уже готов завершить регистрацию -> говорим сразу!
        if FinishPatientCheckIn(patient) then return true end

        -- 2. Готовый напечатанный бейджик на стойке
        for _, bName in ipairs({"PrintedBadge", "PatientBadgeBase", "VisitorBadgeBase"}) do
            local b = checkIn:FindFirstChild(bName)
            local bPP = b and (b:FindFirstChild("PP") or b:FindFirstChildWhichIsA("ProximityPrompt", true))
            if bPP and bPP.Enabled then
                Log("AutoCheckIn", "Taking printed badge from desk", { prompt = bPP:GetFullName() })
                PressPromptNearby(bPP, 0.25, Vector3.new(0, 1.0, 1.5), 0.15)
                task.wait(0.2)
                if FinishPatientCheckIn(patient) then return true end
            end
        end

        local didAnyAction = false

        -- 3. Бланк (Form)
        local form = checkIn:FindFirstChild("Form")
        local formPP = form and (form:FindFirstChild("PP") or form:FindFirstChildWhichIsA("ProximityPrompt", true))
        if formPP and formPP.Enabled then
            Log("AutoCheckIn", "Stamping Form", { prompt = formPP:GetFullName() })
            PressPromptNearby(formPP, 0.3, Vector3.new(0, 1.0, 1.5), 0.15)
            didAnyAction = true
            task.wait(0.15)
            if FinishPatientCheckIn(patient) then return true end
        end

        -- 4. Фотоаппарат (Camera)
        local cam = checkIn:FindFirstChild("Camera")
        local camPP = cam and (cam:FindFirstChild("PP") or cam:FindFirstChildWhichIsA("ProximityPrompt", true))
        if camPP and camPP.Enabled then
            Log("AutoCheckIn", "Taking Photo", { prompt = camPP:GetFullName() })
            PressPromptNearby(camPP, 0.3, Vector3.new(0, 1.0, 1.5), 0.15)
            didAnyAction = true
            task.wait(0.15)
            if FinishPatientCheckIn(patient) then return true end
        end

        -- 5. Компьютер (Computer)
        local pc = checkIn:FindFirstChild("Computer")
        local pcPP = pc and (pc:FindFirstChild("PP") or pc:FindFirstChildWhichIsA("ProximityPrompt", true))
        if pcPP and pcPP.Enabled then
            Log("AutoCheckIn", "Processing computer registration", { prompt = pcPP:GetFullName() })
            PressPromptNearby(pcPP, 0.3, Vector3.new(0, 1.0, 1.5), 0.15)
            didAnyAction = true
            task.wait(0.2)
            if FinishPatientCheckIn(patient) then return true end
        end

        -- 6. Принтер (Printer)
        local printer = checkIn:FindFirstChild("Printer")
        local printerPP = printer and (printer:FindFirstChild("PP") or printer:FindFirstChildWhichIsA("ProximityPrompt", true))
        if printerPP and printerPP.Enabled then
            Log("AutoCheckIn", "Printing Badge", { prompt = printerPP:GetFullName() })
            PressPromptNearby(printerPP, 0.35, Vector3.new(0, 1.0, 1.5), 0.15)
            didAnyAction = true

            local waitDeadline = os.clock() + 3.0
            while os.clock() < waitDeadline and not StopCheck() do
                for _, bName in ipairs({"PrintedBadge", "PatientBadgeBase", "VisitorBadgeBase"}) do
                    local b = checkIn:FindFirstChild(bName)
                    local bPP = b and (b:FindFirstChild("PP") or b:FindFirstChildWhichIsA("ProximityPrompt", true))
                    if bPP and bPP.Enabled then
                        Log("AutoCheckIn", "Taking printed badge from desk", { prompt = bPP:GetFullName() })
                        PressPromptNearby(bPP, 0.25, Vector3.new(0, 1.0, 1.5), 0.15)
                        task.wait(0.2)
                        if FinishPatientCheckIn(patient) then return true end
                        break
                    end
                end
                if FinishPatientCheckIn(patient) then return true end
                task.wait(0.15)
            end
        end

        if FinishPatientCheckIn(patient) then return true end
        if not didAnyAction then break end
        task.wait(0.15)
    end

    if FinishPatientCheckIn(patient) then return true end
    return false
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🚪 11. AUTO ASK LEAVE ANOMALY
-- ══════════════════════════════════════════════════════════════════════════════════
local function AutoAskLeaveAnomaly()
    if not _G.AutoAskLeaveAnomaly or StopCheck() then return false end

    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return false end

    for _, npc in ipairs(npcs:GetChildren()) do
        if npc:IsA("Model") and npc:GetAttribute("Skinwalker") == true then
            for _, p in ipairs(npc:GetDescendants()) do
                if p:IsA("ProximityPrompt") and p.Enabled then
                    local act = string.lower(p.ActionText or "")
                    if act:find("ask to leave") or act:find("leave") or act:find("dismiss") then
                        Log("AutoAskLeaveAnomaly", "Asking anomaly to leave", { npc = npc:GetFullName() })
                        PressPromptNearby(p, 0.4, Vector3.new(0, 1.0, 1.5), 0.2)
                        _AH_LeavingNpcs[npc] = true
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🧯 12. AUTO PUT OUT FIRE (PATIENTS & ROOMS)
-- ══════════════════════════════════════════════════════════════════════════════════
local function EquipExtinguisher()
    if GetItemCount("Extinguisher") > 0 then
        return UseInventoryTool("Extinguisher")
    end

    local misc = Workspace:FindFirstChild("Misc")
    local extStation = misc and misc:FindFirstChild("ExtinguisherStation")
    local extPP = extStation and extStation:FindFirstChildWhichIsA("ProximityPrompt", true)
    if extPP and extPP.Enabled then
        Log("AutoPutOutFire", "Grabbing Extinguisher from station")
        PressPromptNearby(extPP, 0.3, Vector3.new(0, 1.0, 1.5), 0.15)
        return UseInventoryTool("Extinguisher")
    end
    return false
end

local function AutoPutOutFire()
    if not _G.AutoPutOutFire or StopCheck() then return false end

    local firesExtinguished = 0

    local npcs = Workspace:FindFirstChild("NPCs")
    if npcs then
        for _, npc in ipairs(npcs:GetChildren()) do
            local firePP = npc:FindFirstChild("FirePP") or npc:FindFirstChildWhichIsA("ProximityPrompt", true)
            if firePP and firePP.Enabled then
                local act = string.lower(firePP.ActionText or "")
                if act:find("fire") or act:find("extinguish") or act:find("burn") then
                    EquipExtinguisher()
                    Log("AutoPutOutFire", "Extinguishing burning patient", { npc = npc:GetFullName() })
                    PressPromptNearby(firePP, 0.3, Vector3.new(0, 1.0, 1.5), 0.15)
                    firesExtinguished = firesExtinguished + 1
                end
            end
        end
    end

    local rooms = Workspace:FindFirstChild("Rooms")
    if rooms then
        for _, p in ipairs(rooms:GetDescendants()) do
            if p:IsA("ProximityPrompt") and p.Enabled then
                local act = string.lower(p.ActionText or "")
                if act:find("put out fire") or act:find("extinguish") then
                    EquipExtinguisher()
                    Log("AutoPutOutFire", "Extinguishing fire in room", { prompt = p:GetFullName() })
                    PressPromptNearby(p, 0.3, Vector3.new(0, 1.0, 1.5), 0.15)
                    firesExtinguished = firesExtinguished + 1
                end
            end
        end
    end

    if firesExtinguished > 0 then
        UnequipAllTools()
        return true
    end

    return false
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 📹 13. AUTO FIX SECURITY CAMERAS
-- ══════════════════════════════════════════════════════════════════════════════════
local function AutoFixCam()
    if not _G.AutoFixCam or StopCheck() then return false end

    local cams = Workspace:FindFirstChild("Cameras") or (Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("Cameras"))
    if not cams then return false end

    for _, p in ipairs(cams:GetDescendants()) do
        if p:IsA("ProximityPrompt") and p.Enabled then
            local act = string.lower(p.ActionText or "")
            if act:find("fix") or act:find("repair") or act:find("cam") then
                Log("AutoFixCam", "Fixing security camera", { prompt = p:GetFullName() })
                PressPromptNearby(p, 0.35, Vector3.new(0, 1.0, 1.5), 0.2)
                return true
            end
        end
    end
    return false
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- ⚡ 14. AUTO TASER ANOMALIES
-- ══════════════════════════════════════════════════════════════════════════════════
local function EquipTaser()
    if GetItemCount("Taser") > 0 then
        return UseInventoryTool("Taser")
    end

    local misc = Workspace:FindFirstChild("Misc")
    local tStation = misc and misc:FindFirstChild("TaserStation")
    local tPP = tStation and tStation:FindFirstChildWhichIsA("ProximityPrompt", true)
    if tPP and tPP.Enabled then
        Log("AutoTaser", "Grabbing Taser from station")
        PressPromptNearby(tPP, 0.3, Vector3.new(0, 1.0, 1.5), 0.15)
        return UseInventoryTool("Taser")
    end
    return false
end

local function AutoTaserAnomalies()
    if not _G.AutoTaser or StopCheck() then return false end

    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return false end

    for _, npc in ipairs(npcs:GetChildren()) do
        if npc:IsA("Model") and IsNpcThreat(npc) and not IsThreatLeaving(npc) then
            local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso")
            if root then
                EquipTaser()
                Log("AutoTaser", "Zapping anomaly with taser", { npc = npc:GetFullName() })
                TeleportPlayer(root.Position + Vector3.new(0, 1.0, 3.0))
                task.wait(0.2)
                UseInventoryTool("Taser")
                task.wait(0.3)
                UnequipAllTools()
                return true
            end
        end
    end
    return false
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- ☕ 15. AUTO BARNEY COFFEE
-- ══════════════════════════════════════════════════════════════════════════════════
local function ProcessBarneyCoffee()
    if not _G.AutoGiveBarneyCoffee or StopCheck() then return end

    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return end

    local barney = nil
    for _, npc in ipairs(npcs:GetChildren()) do
        if npc:IsA("Model") and IsBarneyNpc(npc) then
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

    if GetItemCount("Coffee") > 0 then
        UseInventoryTool("Coffee")
        PressPromptNearby(barneyPP, 0.3, Vector3.new(0, 1.0, 1.5), 0.2)
        UnequipAllTools()
        return
    end

    local cm = Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("CoffeeMachine")
    local coffeePP = cm and cm:FindFirstChild("Coffee") and (cm.Coffee:FindFirstChild("PP") or cm.Coffee:FindFirstChildWhichIsA("ProximityPrompt", true))
    if coffeePP and coffeePP.Enabled then
        Log("AutoCoffee", "Brewing coffee for Barney")
        PressPromptNearby(coffeePP, 0.3, Vector3.new(0, 1.0, 1.5), 0.2)
        if GetItemCount("Coffee") > 0 then
            UseInventoryTool("Coffee")
            PressPromptNearby(barneyPP, 0.3, Vector3.new(0, 1.0, 1.5), 0.2)
            UnequipAllTools()
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🧼 16. AUTO CLEAN SLIME
-- ══════════════════════════════════════════════════════════════════════════════════
local function CleanSlimePuddles()
    if not _G.AutoCleanSlime or StopCheck() then return end

    local puddles = Workspace:FindFirstChild("Puddles") or Workspace:FindFirstChild("Slime") or Workspace:FindFirstChild("Misc")
    if not puddles then return end

    for _, p in ipairs(puddles:GetDescendants()) do
        if p:IsA("ProximityPrompt") and p.Enabled then
            local act = string.lower(p.ActionText or "")
            if act:find("clean") or act:find("mop") or act:find("wipe") or act:find("sponge") then
                Log("AutoCleanSlime", "Cleaning slime puddle", { prompt = p:GetFullName() })
                PressPromptNearby(p, 0.2, Vector3.new(0, 1.0, 1.5), 0.15)
                break
            end
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🛒 17. AUTO BUY SHOP
-- ══════════════════════════════════════════════════════════════════════════════════
local function AutoBuyShopItems()
    if not _G.AutoBuyShop or StopCheck() then return end
    local shop = Workspace:FindFirstChild("Shop") or (Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("Shop"))
    if not shop then return end

    for _, p in ipairs(shop:GetDescendants()) do
        if p:IsA("ProximityPrompt") and p.Enabled then
            Log("AutoShop", "Buying shop item", { prompt = p:GetFullName() })
            PressPromptNearby(p, 0.2, Vector3.new(0, 1.0, 1.5), 0.15)
            break
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🚑 18. AUTO HELP FAINTED PATIENTS (PICKUP & DESIGNATED BED PLACEMENT)
-- ══════════════════════════════════════════════════════════════════════════════════
local function AutoHelpFaintedPatients()
    if not _G.AutoHelpPatient or StopCheck() then return false end

    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return false end

    for _, npc in ipairs(npcs:GetChildren()) do
        if npc:IsA("Model") and IsValidPatient(npc) then
            local helpPP = nil
            for _, p in ipairs(npc:GetDescendants()) do
                if p:IsA("ProximityPrompt") and p.Enabled then
                    local act = string.lower(tostring(p.ActionText or ""))
                    if act:find("carry") or act:find("help") or act:find("revive") or act:find("faint") or p.Name == "FaintedPP" then
                        helpPP = p
                        break
                    end
                end
            end

            if helpPP and helpPP.Enabled then
                Log("AutoHelpPatient", "Helping/carrying fainted patient", { npc = npc:GetFullName(), prompt = helpPP:GetFullName() })
                PressPromptNearby(helpPP, 0.35, Vector3.new(0, 1.0, 1.5), 0.15)
                task.wait(0.2)

                local bedPP, bedPos = GetBedPromptForPatient(npc)
                if bedPP and bedPos then
                    Log("AutoHelpPatient", "Placing patient in designated bed", {
                        npc = npc:GetFullName(),
                        designatedRoom = tostring(npc:GetAttribute("DesignatedRoom")),
                        bed = bedPP:GetFullName()
                    })
                    PressTreatmentPromptNearbyUntil(bedPP, 0.2, 2.5, function()
                        return npc:GetAttribute("InBed") == true or not bedPP.Parent or not bedPP.Enabled
                    end)
                end
                return true
            end
        end
    end
    return false
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🌐 19. THIRD PERSON & SERVER UTILITIES
-- ══════════════════════════════════════════════════════════════════════════════════
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")

local function ApplyThirdPerson(enabled)
    if enabled then
        pcall(function()
            LocalPlayer.CameraMinZoomDistance = 0.5
            LocalPlayer.CameraMaxZoomDistance = 128
            LocalPlayer.CameraMode = Enum.CameraMode.Classic
        end)
    else
        pcall(function()
            LocalPlayer.CameraMinZoomDistance = 0.5
            LocalPlayer.CameraMaxZoomDistance = 0.5
            LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
        end)
    end
end

ApplyThirdPerson(_G.UnlockThirdPerson)

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
-- 🎨 20. NATIVE OBSIDIAN LUXURY GUI ENGINE & KEYBINDS (P: MOUSE, G: TOGGLE GUI)
-- ══════════════════════════════════════════════════════════════════════════════════
local GuiParent = nil
pcall(function() GuiParent = gethui and gethui() end)
if not GuiParent then
    pcall(function() GuiParent = CoreGui end)
end
if not GuiParent then
    GuiParent = LocalPlayer:WaitForChild("PlayerGui")
end

local oldGui = GuiParent:FindFirstChild("AverlikHub_AnimalHospital")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AverlikHub_AnimalHospital"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = GuiParent

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 560, 0, 390)
MainFrame.Position = UDim2.new(0.5, -280, 0.5, -195)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 17, 23)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(45, 55, 75)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Color3.fromRGB(20, 24, 33)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🏥 Averlik Hub | Animal Hospital v21.0 [P: Мышь | G: Меню]"
Title.TextColor3 = Color3.fromRGB(240, 245, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local dragging, dragInput, dragStart, startPos
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ⌨️ KEYBINDS ENGINE (P: UNLOCK MOUSE, G: TOGGLE GUI)
local _MouseUnlocked = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- Клавиша P: Разблокировка курсора мыши
    if input.KeyCode == Enum.KeyCode.P then
        _MouseUnlocked = not _MouseUnlocked
        if _MouseUnlocked then
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            UserInputService.MouseIconEnabled = true
            Log("Keybind", "Mouse cursor unlocked (Default mode)")
        else
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            Log("Keybind", "Mouse cursor locked (LockCenter mode)")
        end
    end

    -- Клавиша G: Открыть / Закрыть меню
    if input.KeyCode == Enum.KeyCode.G then
        MainFrame.Visible = not MainFrame.Visible
        Log("Keybind", "Toggled GUI visibility: " .. tostring(MainFrame.Visible))
    end
end)

RunService.RenderStepped:Connect(function()
    if _MouseUnlocked and UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
end)

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 150, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarList = Instance.new("UIListLayout")
SidebarList.Padding = UDim.new(0, 6)
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Parent = Sidebar

local SidebarPad = Instance.new("UIPadding")
SidebarPad.PaddingTop = UDim.new(0, 10)
SidebarPad.PaddingLeft = UDim.new(0, 10)
SidebarPad.PaddingRight = UDim.new(0, 10)
SidebarPad.Parent = Sidebar

local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -150, 1, -42)
ContentArea.Position = UDim2.new(0, 150, 0, 42)
ContentArea.BackgroundColor3 = Color3.fromRGB(15, 17, 23)
ContentArea.BorderSizePixel = 0
ContentArea.Parent = MainFrame

local TabFrames = {}
local TabButtons = {}

local function CreateTab(name, icon)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 34)
    tabBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 38)
    tabBtn.BorderSizePixel = 0
    tabBtn.Text = " " .. icon .. " " .. name
    tabBtn.TextColor3 = Color3.fromRGB(170, 185, 210)
    tabBtn.Font = Enum.Font.GothamMedium
    tabBtn.TextSize = 12
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Parent = Sidebar

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = tabBtn

    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.ScrollBarThickness = 4
    tabContent.ScrollBarImageColor3 = Color3.fromRGB(55, 65, 90)
    tabContent.Visible = false
    tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabContent.Parent = ContentArea

    local contentList = Instance.new("UIListLayout")
    contentList.Padding = UDim.new(0, 8)
    contentList.SortOrder = Enum.SortOrder.LayoutOrder
    contentList.Parent = tabContent

    local contentPad = Instance.new("UIPadding")
    contentPad.PaddingTop = UDim.new(0, 12)
    contentPad.PaddingBottom = UDim.new(0, 12)
    contentPad.PaddingLeft = UDim.new(0, 14)
    contentPad.PaddingRight = UDim.new(0, 14)
    contentPad.Parent = tabContent

    TabFrames[name] = tabContent
    TabButtons[name] = tabBtn

    tabBtn.MouseButton1Click:Connect(function()
        for tName, f in pairs(TabFrames) do
            f.Visible = (tName == name)
            local b = TabButtons[tName]
            if tName == name then
                b.BackgroundColor3 = Color3.fromRGB(40, 75, 140)
                b.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                b.BackgroundColor3 = Color3.fromRGB(24, 28, 38)
                b.TextColor3 = Color3.fromRGB(170, 185, 210)
            end
        end
    end)

    return tabContent
end

local function AddToggle(parentTab, title, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 38)
    frame.BackgroundColor3 = Color3.fromRGB(22, 26, 36)
    frame.BorderSizePixel = 0
    frame.Parent = parentTab

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = title
    label.TextColor3 = Color3.fromRGB(230, 235, 245)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 44, 0, 22)
    switch.Position = UDim2.new(1, -54, 0.5, -11)
    switch.BackgroundColor3 = defaultVal and Color3.fromRGB(50, 168, 82) or Color3.fromRGB(45, 50, 65)
    switch.BorderSizePixel = 0
    switch.Text = ""
    switch.Parent = frame

    local sCorner = Instance.new("UICorner")
    sCorner.CornerRadius = UDim.new(1, 0)
    sCorner.Parent = switch

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = defaultVal and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.BorderSizePixel = 0
    circle.Parent = switch

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(1, 0)
    cCorner.Parent = circle

    local isEnabled = defaultVal
    switch.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        TweenService:Create(switch, TweenInfo.new(0.2), {
            BackgroundColor3 = isEnabled and Color3.fromRGB(50, 168, 82) or Color3.fromRGB(45, 50, 65)
        }):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {
            Position = isEnabled and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        }):Play()
        callback(isEnabled)
    end)
end

local function AddButton(parentTab, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(30, 42, 65)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(235, 240, 255)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 12
    btn.Parent = parentTab

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = Color3.fromRGB(45, 75, 120) }):Play()
        task.wait(0.1)
        TweenService:Create(btn, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(30, 42, 65) }):Play()
        callback()
    end)
end

local function AddSlider(parentTab, title, minVal, maxVal, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 48)
    frame.BackgroundColor3 = Color3.fromRGB(22, 26, 36)
    frame.BorderSizePixel = 0
    frame.Parent = parentTab

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 0, 20)
    label.Position = UDim2.new(0, 12, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = title .. ": " .. tostring(defaultVal)
    label.TextColor3 = Color3.fromRGB(230, 235, 245)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -24, 0, 8)
    sliderBg.Position = UDim2.new(0, 12, 0, 30)
    sliderBg.BackgroundColor3 = Color3.fromRGB(40, 48, 65)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame

    local sCorner = Instance.new("UICorner")
    sCorner.CornerRadius = UDim.new(1, 0)
    sCorner.Parent = sliderBg

    local fill = Instance.new("Frame")
    local pct = (defaultVal - minVal) / (maxVal - minVal)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(60, 120, 230)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg

    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(1, 0)
    fCorner.Parent = fill

    local sliding = false
    local function Update(input)
        local posX = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(posX, 0, 1, 0)
        local val = math.floor(minVal + (maxVal - minVal) * posX)
        label.Text = title .. ": " .. tostring(val)
        callback(val)
    end

    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            Update(input)
        end
    end)

    sliderBg.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            Update(input)
        end
    end)
end

-- Создаем страницы и контролы
local TabAuto = CreateTab("Автоматизация", "⚡")
local TabSafe = CreateTab("Защита", "🛡️")
local TabMisc = CreateTab("Утилиты", "🌐")

-- Вкладка: Автоматизация
AddToggle(TabAuto, "🏥 Авто-Лечение (Палаты 1 - 8)", _G.AutoTreatment, function(v) _G.AutoTreatment = v end)
AddToggle(TabAuto, "🏢 Авто-Регистрация (Ресепшен)", _G.AutoCheckIn, function(v) _G.AutoCheckIn = v end)
AddToggle(TabAuto, "🚑 Спасение упавших пациентов", _G.AutoHelpPatient, function(v) _G.AutoHelpPatient = v end)
AddToggle(TabAuto, "🧯 Авто-Тушение пожаров", _G.AutoPutOutFire, function(v) _G.AutoPutOutFire = v end)
AddToggle(TabAuto, "🧼 Авто-Уборка слизи", _G.AutoCleanSlime, function(v) _G.AutoCleanSlime = v end)
AddToggle(TabAuto, "📹 Авто-Починка камер", _G.AutoFixCam, function(v) _G.AutoFixCam = v end)
AddToggle(TabAuto, "🛒 Авто-Покупка в магазине", _G.AutoBuyShop, function(v) _G.AutoBuyShop = v end)

-- Вкладка: Защита и Безопасность
AddToggle(TabSafe, "🛑 Авто-Шторка от Аномалий", _G.AutoAnomalyShutter, function(v) _G.AutoAnomalyShutter = v end)
AddToggle(TabSafe, "🚪 Авто-Шторка от Барни", _G.AutoBarneyShutter, function(v) _G.AutoBarneyShutter = v end)
AddToggle(TabSafe, "🗣️ Выгонять аномалии (Ask To Leave)", _G.AutoAskLeaveAnomaly, function(v) _G.AutoAskLeaveAnomaly = v end)
AddToggle(TabSafe, "☠️ Устранять скинвокеров (Летальные)", _G.AutoKillAnomaly, function(v) _G.AutoKillAnomaly = v end)
AddToggle(TabSafe, "⚡ Авто-Тазер аномалий", _G.AutoTaser, function(v) _G.AutoTaser = v end)
AddToggle(TabSafe, "☕ Кофе для Барни", _G.AutoGiveBarneyCoffee, function(v) _G.AutoGiveBarneyCoffee = v end)

-- Вкладка: Утилиты и Сервер
AddButton(TabMisc, "🔄 Rejoin (Перезайти на сервер)", RejoinServer)
AddButton(TabMisc, "🌐 Server Hop (Случайный сервер)", ServerHop)
AddButton(TabMisc, "👥 Server Hop (Сервер с малым онлайном)", ServerHopLowPlayer)
AddToggle(TabMisc, "🛡️ Anti-AFK (Защита от кика)", _G.AntiAFK, function(v) _G.AntiAFK = v end)
AddToggle(TabMisc, "💡 Fullbright (Яркий свет)", _G.Fullbright, ToggleFullbright)
AddToggle(TabMisc, "🎥 Разблокировка 3-го лица", _G.UnlockThirdPerson, ApplyThirdPerson)
AddSlider(TabMisc, "Скорость бега", 16, 120, 16, function(v)
    _G.WalkSpeedValue = v
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = v end
end)

TabButtons["Автоматизация"].BackgroundColor3 = Color3.fromRGB(40, 75, 140)
TabButtons["Автоматизация"].TextColor3 = Color3.fromRGB(255, 255, 255)
TabFrames["Автоматизация"].Visible = true

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🔄 21. AUTONOMOUS PRIORITY SCHEDULER (ATOMIC TASK MUTEX LOCK)
-- ══════════════════════════════════════════════════════════════════════════════════
local function RunTaskExclusively(taskName, taskFunc)
    if _AH_IsPerformingTask or StopCheck() then return false end
    _AH_IsPerformingTask = true
    local ok, res = pcall(taskFunc)
    _AH_IsPerformingTask = false
    if not ok then
        Log("TaskError", taskName .. " failed: " .. tostring(res))
    end
    return res == true
end

task.spawn(function()
    Log("Loop", "Averlik Hub Animal Hospital Engine Started", { sessionId = MySession, loopInterval = _G.LoopInterval })

    local nextUrgentCheck = 0
    local nextGeneralTreatment = 0

    while IsSessionActive() do
        task.wait(_G.LoopInterval or 0.15)

        if not IsSessionActive() then break end

        -- WalkSpeed
        if _G.WalkSpeedValue and _G.WalkSpeedValue ~= 16 then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed ~= _G.WalkSpeedValue then hum.WalkSpeed = _G.WalkSpeedValue end
        end

        local now = os.clock()

        -- 1. СРОЧНОЕ ЛЕЧЕНИЕ РЕАНИМАЦИЙ (Палаты 8, 7, 6)
        if _G.AutoTreatment and now >= nextUrgentCheck and not _AH_IsPerformingTask then
            nextUrgentCheck = now + 0.35
            for _, idx in ipairs({8, 7, 6}) do
                local roomData = _G.AH_RoomData[idx]
                if RunTaskExclusively("UrgentTreatment_" .. roomData.Name, function() return TreatSingleRoom(roomData) end) then
                    break
                end
            end
        end

        -- 2. ВЫГОН АНОМАЛИЙ (Ask to leave)
        if _G.AutoAskLeaveAnomaly and not _AH_IsPerformingTask then
            RunTaskExclusively("AutoAskLeaveAnomaly", AutoAskLeaveAnomaly)
        end

        -- 3. ТУШЕНИЕ ПОЖАРОВ (Без прерывания)
        if _G.AutoPutOutFire and not _AH_IsPerformingTask then
            RunTaskExclusively("AutoPutOutFire", AutoPutOutFire)
        end

        -- 4. ТАЗЕР АНОМАЛИЙ
        if _G.AutoTaser and not _AH_IsPerformingTask then
            RunTaskExclusively("AutoTaserAnomalies", AutoTaserAnomalies)
        end

        -- 5. ОБЩЕЕ ЛЕЧЕНИЕ (Палаты 1 - 8)
        if _G.AutoTreatment and now >= nextGeneralTreatment and not _AH_IsPerformingTask then
            nextGeneralTreatment = now + 0.6
            for idx = 1, 8 do
                local roomData = _G.AH_RoomData[idx]
                if RunTaskExclusively("GeneralTreatment_" .. roomData.Name, function() return TreatSingleRoom(roomData) end) then
                    break
                end
            end
        end

        -- 6. УМНАЯ ШТОРКА (Только при реальных скинвокерах и Барни, открытие при уходе)
        if not _AH_IsPerformingTask then
            pcall(EvaluateShutterLogic)
        end

        -- 7. РЕСЕПШЕН (Регистрация посетителей от начала до конца)
        if _G.AutoCheckIn and not _G.HasActiveThreat and IsShutterClosed() ~= true and not _AH_IsPerformingTask then
            RunTaskExclusively("AutoCheckIn", ExecuteCheckInCycle)
        end

        -- 8. СПАСЕНИЕ УПАВШИХ ПАЦИЕНТОВ (Точная доставка на койку назначенной палаты)
        if _G.AutoHelpPatient and not _AH_IsPerformingTask then
            RunTaskExclusively("AutoHelpPatient", AutoHelpFaintedPatients)
        end

        -- 9. ПОЧИНКА КАМЕР
        if _G.AutoFixCam and not _AH_IsPerformingTask then
            RunTaskExclusively("AutoFixCam", AutoFixCam)
        end

        -- 10. КОФЕ ДЛЯ БАРНИ
        if _G.AutoGiveBarneyCoffee and not _AH_IsPerformingTask then
            RunTaskExclusively("AutoGiveBarneyCoffee", ProcessBarneyCoffee)
        end

        -- 11. УБОРКА СЛИЗИ
        if _G.AutoCleanSlime and not _AH_IsPerformingTask then
            RunTaskExclusively("AutoCleanSlime", CleanSlimePuddles)
        end

        -- 12. МАГАЗИН
        if _G.AutoBuyShop and not _AH_IsPerformingTask then
            RunTaskExclusively("AutoBuyShop", AutoBuyShopItems)
        end
    end

    if ScreenGui and ScreenGui.Parent then
        ScreenGui:Destroy()
    end
    Log("Loop", "Session gracefully stopped", { sessionId = MySession })
end)
