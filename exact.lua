-- ══════════════════════════════════════════════════════════════════════════════════
-- 🏥 AVERLIK HUB: ANIMAL HOSPITAL ULTIMATE EXACT FOXNAME ENGINE (V32.0 1-TO-1 CANONICAL)
-- ══════════════════════════════════════════════════════════════════════════════════

-- 🛑 SINGLETON SESSION LIFECYCLE GUARD
_G.AH_SessionCounter = (_G.AH_SessionCounter or 0) + 1
local MySession = _G.AH_SessionCounter
_G.AH_ActiveSession = MySession

local function IsSessionActive()
    return _G.AH_ActiveSession == MySession
end

local function StopCheck()
    return not IsSessionActive() or not (
        _G.AutoBarneyShutter or _G.AutoAnomalyShutter or _G.AutoCheckIn or
        _G.AutoTreatment or _G.AutoHelpPatient or _G.AutoBuyShop or
        _G.AutoAskLeaveAnomaly or _G.AutoCleanSlime or _G.AutoPutOutFire or
        _G.AutoCoffee or _G.AutoFixCam or _G.AutoGiveBarneyCoffee or _G.AutoTaser
    )
end

-- ⚙️ GLOBAL CONFIGURATION & TOGGLES
_G.AutoTreatment = _G.AutoTreatment ~= nil and _G.AutoTreatment or true
_G.AutoCheckIn = _G.AutoCheckIn ~= nil and _G.AutoCheckIn or true
_G.AutoCoffee = _G.AutoCoffee ~= nil and _G.AutoCoffee or true
_G.CoffeeSanityThreshold = _G.CoffeeSanityThreshold or 40
_G.SanityThreshold = _G.CoffeeSanityThreshold
_G.AutoGiveBarneyCoffee = _G.AutoGiveBarneyCoffee ~= nil and _G.AutoGiveBarneyCoffee or true
_G.AutoAnomalyShutter = _G.AutoAnomalyShutter ~= nil and _G.AutoAnomalyShutter or true
_G.AutoBarneyShutter = _G.AutoBarneyShutter ~= nil and _G.AutoBarneyShutter or true
_G.AutoAskLeaveAnomaly = _G.AutoAskLeaveAnomaly ~= nil and _G.AutoAskLeaveAnomaly or true
_G.AutoKillAnomaly = _G.AutoKillAnomaly ~= nil and _G.AutoKillAnomaly or false
_G.AutoHelpPatient = _G.AutoHelpPatient ~= nil and _G.AutoHelpPatient or true
_G.AutoPutOutFire = _G.AutoPutOutFire ~= nil and _G.AutoPutOutFire or true
_G.AutoCleanSlime = _G.AutoCleanSlime ~= nil and _G.AutoCleanSlime or true
_G.AutoFixCam = _G.AutoFixCam ~= nil and _G.AutoFixCam or true
_G.AutoTaser = _G.AutoTaser ~= nil and _G.AutoTaser or false
_G.AutoBuyShop = _G.AutoBuyShop ~= nil and _G.AutoBuyShop or false
_G.AutoTaserTargets = _G.AutoTaserTargets or { ANOMALY = true }
_G.DebugMode = _G.DebugMode ~= nil and _G.DebugMode or false
_G.UnlockThirdPerson = _G.UnlockThirdPerson ~= nil and _G.UnlockThirdPerson or true
_G.AntiAFK = _G.AntiAFK ~= nil and _G.AntiAFK or true
_G.Fullbright = _G.Fullbright ~= nil and _G.Fullbright or false
_G.WalkSpeedValue = _G.WalkSpeedValue or 16

-- 📦 DATASETS & CONSTANTS
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

_G.AH_TreatedPatients = _G.AH_TreatedPatients or {}

-- Exact Ailment Asset Map for Direct Burn/Ailment Icons
local AilmentAssetMap = {
    ["139637091303873"] = "Eye Drops",
    ["118311058179090"] = "IV Drops",
    ["88750936127655"]  = "Medkit",
    ["138334905913311"] = "Thermometer",
    ["75884870805308"]  = "Ointment",
    ["125453071439049"] = "Bandages",
    ["135236061613718"] = "Medicine",
    ["113912761080559"] = "Maple Syrup",
    ["120895273610611"] = "Cough Syrup",
    ["94559086254344"]  = "Herbs",
    ["132258407294719"] = "Antibiotics",
    ["102550407034117"] = "Organ",
    ["137637637347521"] = "Transplant",
    ["93721219255457"]  = "Scalpel",
    ["97305931082100"]  = "Scissors"
}

-- 3D Coordinates from Animal Hospital Structure
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

    Room1_Bed = Vector3.new(-168.22, 3.19, -41.90),
    Room2_Bed = Vector3.new(-121.37, 3.19, -58.74),
    Room3_Bed = Vector3.new(-168.22, 3.19, -81.10),
    Room4_Bed = Vector3.new(-121.28, 3.19, -98.24),
    Room5_Bed = Vector3.new(-153.42, 3.19, -114.74),
    Room6_Bed = Vector3.new(-181.83, 3.91, 54.08),
    Room7_Bed = Vector3.new(-106.53, 3.24, 52.13),
    Room8_Bed = Vector3.new(-144.89, 3.56, 99.59)
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
-- 🔍 CORE UTILITIES & STATE CONTAINERS
-- ══════════════════════════════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

local function LogError(prefix, msg, tbl, isCritical)
    local t = os.date("%X")
    local extra = ""
    if tbl then
        local parts = {}
        for k, v in pairs(tbl) do
            table.insert(parts, string.format("%s=%s", tostring(k), tostring(v)))
        end
        if #parts > 0 then extra = " | " .. table.concat(parts, " | ") end
    end
    warn(string.format("[%s] [%s] %s%s", t, prefix, msg, extra))
end

local function GetCharacter()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
    return char, root
end

local function TeleportTo(pos)
    if not pos or StopCheck() then return end
    local _, root = GetCharacter()
    if root then
        root.CFrame = CFrame.new(pos)
    end
end

local function GetNpcSnapshot()
    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return false, {} end
    return true, npcs:GetChildren()
end

local function LockCamera() end
local function UnlockCamera() end

local _AH_PromptCooldowns = setmetatable({}, { __mode = "k" })

local function PressPP(prompt, holdTime)
    if not (prompt and prompt.Parent and prompt.Enabled) or StopCheck() then return false end

    local now = os.clock()
    local hold = (prompt:IsA("ProximityPrompt") and prompt.HoldDuration > 0 and (prompt.HoldDuration + 0.1)) or 0
    local waitTime = math.max(holdTime or 0.35, hold)

    if _AH_PromptCooldowns[prompt] and (now - _AH_PromptCooldowns[prompt] < waitTime) then
        return false
    end
    _AH_PromptCooldowns[prompt] = now

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

local function WaitForPath(getter, timeout)
    local deadline = os.clock() + (timeout or 5)
    while os.clock() < deadline and not StopCheck() do
        local ok, res = pcall(getter)
        if ok and res then return res end
        task.wait(0.2)
    end
    return nil
end

local function GetNpcFromPart(part)
    local current = part
    while current and current ~= Workspace do
        if current.Parent and current.Parent.Name == "NPCs" then
            return current
        end
        current = current.Parent
    end
    return nil
end

local function RaycastDetectNpc()
    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return nil end
    local _, root = GetCharacter()
    local origin = root and root.Position
    if not origin then return nil end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    params.FilterDescendantsInstances = { npcs }
    local dirs = { Vector3.new(0, 0, -1), Vector3.new(1, 0, 0), Vector3.new(-1, 0, 0), Vector3.new(0, 0, 1) }
    for _, dir in ipairs(dirs) do
        local result = Workspace:Raycast(origin, dir * 70, params)
        if result and result.Instance then
            local npc = GetNpcFromPart(result.Instance)
            if npc then return npc end
        end
    end
    return nil
end

local function HitboxDetectNpc()
    local _, root = GetCharacter()
    local origin = root and root.Position
    if not origin then return nil end
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return nil end
    params.FilterDescendantsInstances = { npcs }
    local parts = Workspace:GetPartBoundsInBox(CFrame.new(origin), Vector3.new(16, 16, 22), params)
    for _, p in ipairs(parts) do
        local npc = GetNpcFromPart(p)
        if npc then return npc end
    end
    return nil
end

-- 🌟 CANONICAL ATTRIBUTE VALIDATION FROM FOXNAME HUB
local function IsValidPatient(npc)
    if not npc or not npc:IsA("Model") then return false end
    if npc:GetAttribute("IsVisitor") == true then return true end
    if npc:GetAttribute("Skinwalker") == true then return true end
    if npc:GetAttribute("IsPatient") == true then return true end
    if CollectionService and (CollectionService:HasTag(npc, "VisitorAtCheckIn") or CollectionService:HasTag(npc, "VisitorAtCheckIn2")) then
        return true
    end
    return false
end

local function IsBarneyNpc(npc)
    return npc and string.find(string.lower(tostring(npc.Name or "")), "barney") ~= nil
end

local function IsNormalCheckInPatient(npc)
    return npc and not IsBarneyNpc(npc) and npc:GetAttribute("Skinwalker") ~= true and IsValidPatient(npc)
end

local function GetPromptPosition(prompt)
    if not prompt then return nil end
    local parent = prompt.Parent
    if not parent then return nil end
    if parent:IsA("BasePart") then return parent.Position end
    if parent:IsA("Attachment") then return parent.WorldPosition end
    if parent:IsA("Model") then
        local bp = parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart")
        if bp then return bp.Position end
        local ok, piv = pcall(function() return parent:GetPivot() end)
        if ok and piv then return piv.Position end
    end
    local bp = parent:FindFirstChildWhichIsA("BasePart", true)
    if bp then return bp.Position end
    return nil
end

local function PressPromptNearby(prompt, waitAfter, offset, waitBefore)
    if not (prompt and prompt.Enabled) or StopCheck() then return false end
    local pos = GetPromptPosition(prompt)
    if pos then
        TeleportTo(pos + (offset or Vector3.new(0, 1, 2.5)))
        task.wait(waitBefore or 0.2)
        if StopCheck() then return false end
    end
    local res = PressPP(prompt)
    task.wait(waitAfter or 0.3)
    return res
end

local function PressPromptNearbyUntil(prompt, interval, timeout, condition, customPos, offset, waitBefore)
    if not (prompt and prompt.Enabled) or StopCheck() then return false end
    local pos = customPos or GetPromptPosition(prompt)
    if pos then
        TeleportTo(pos + (offset or Vector3.new(0, 1, 2.5)))
        task.wait(waitBefore or 0.15)
        if StopCheck() then return false end
    end
    local deadline = os.clock() + (timeout or 3.0)
    while prompt and prompt.Parent and os.clock() < deadline and not StopCheck() do
        if condition and condition() then return true end
        if not prompt.Enabled then return true end
        PressPP(prompt, interval or 0.35)
        task.wait(interval or 0.25)
    end
    if condition then return condition() == true end
    return not (prompt and prompt.Parent and prompt.Enabled)
end

local treatmentOffset = Vector3.new(0, 1.5, 0)

local function PressTreatmentPromptNearby(prompt, waitAfter, waitBefore)
    return PressPromptNearby(prompt, waitAfter, treatmentOffset, waitBefore)
end

local function PressTreatmentPromptNearbyUntil(prompt, interval, timeout, condition, customPos, waitBefore)
    return PressPromptNearbyUntil(prompt, interval, timeout, condition, customPos, treatmentOffset, waitBefore)
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🏢 CHECK-IN & RECEPTION ENGINE (CANONICAL FOXNAME FLOW)
-- ══════════════════════════════════════════════════════════════════════════════════
local function GetCheckInRoots()
    local misc = Workspace:FindFirstChild("Misc")
    if not misc then return {} end
    local roots = {}
    for _, name in ipairs({"CheckIn", "CheckIn2"}) do
        local s = misc:FindFirstChild(name)
        if s then table.insert(roots, s) end
    end
    return roots
end

local function GetCheckInPosition(station)
    if not station then return Vector3.new(-104, 3, 0) end
    local cam = station:FindFirstChild("Camera")
    local handle = cam and cam:FindFirstChild("Handle")
    if handle and handle:IsA("BasePart") then return handle.Position end
    local pc = station:FindFirstChild("Computer")
    local pcPart = pc and pc:FindFirstChildWhichIsA("BasePart")
    if pcPart then return pcPart.Position end
    return Vector3.new(-104, 3, 0)
end

local function IsNearAnyCheckIn(pos, maxDist)
    if not pos then return false end
    for _, s in ipairs(GetCheckInRoots()) do
        local sp = GetCheckInPosition(s)
        if (pos - sp).Magnitude <= (maxDist or 35) then
            return true
        end
    end
    return false
end

local function GetNearestCheckInRoot(pos, maxDist)
    if not pos then return nil end
    local nearest, minDist = nil, maxDist or 35
    for _, s in ipairs(GetCheckInRoots()) do
        local d = (pos - GetCheckInPosition(s)).Magnitude
        if d < minDist then
            nearest = s
            minDist = d
        end
    end
    return nearest
end

local function GetCheckInStationForNpc(npc)
    if not npc then return nil end
    local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso")
    return root and GetNearestCheckInRoot(root.Position, 25)
end

local function GetNpcTalkPrompt(npc, enabledOnly)
    if not npc then return nil end
    for _, p in ipairs(npc:GetDescendants()) do
        if p:IsA("ProximityPrompt") and string.find(string.lower(p.ActionText or ""), "talk") then
            if not enabledOnly or p.Enabled then return p end
        end
    end
    return nil
end

local function GetNpcCheckInPrompt(npc, enabledOnly)
    if not npc or IsBarneyNpc(npc) or npc:GetAttribute("Skinwalker") == true then return nil end
    local talk = GetNpcTalkPrompt(npc, enabledOnly)
    if talk then return talk end
    for _, p in ipairs(npc:GetDescendants()) do
        if p:IsA("ProximityPrompt") and (not enabledOnly or p.Enabled) then
            local act = string.lower(tostring(p.ActionText or ""))
            if act ~= "" and not act:find("carry") and not act:find("help") and not act:find("faint") and not act:find("burn") then
                return p
            end
        end
    end
    return nil
end

local function IsNpcAtCheckInCounter(npc, station)
    if not npc then return false end
    local root = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso")
    if not root then return false end
    local pos = GetCheckInPosition(station)
    return (root.Position - pos).Magnitude <= 14.0
end

local function IsCheckInFriendlyNpc(npc, station)
    return npc and not IsBarneyNpc(npc) and npc:GetAttribute("Skinwalker") ~= true and
        (IsValidPatient(npc) or GetCheckInStationForNpc(npc) == station)
end

local function FindCheckInTakePrompt(container)
    if not container then return nil end
    for _, p in ipairs(container:GetDescendants()) do
        if p:IsA("ProximityPrompt") and p.Enabled and string.find(string.lower(p.ActionText or ""), "take") then
            return p
        end
    end
    local pp = container:FindFirstChild("PP") or container:FindFirstChildWhichIsA("ProximityPrompt", true)
    if pp and pp.Enabled then return pp end
    return nil
end

local function GetCheckInBadgePP()
    local misc = Workspace:FindFirstChild("Misc")
    if not misc then return nil end
    for _, s in ipairs(GetCheckInRoots()) do
        for _, name in ipairs({"PatientBadgeBase", "VisitorBadgeBase", "PrintedBadge"}) do
            local item = s:FindFirstChild(name)
            local p = item and FindCheckInTakePrompt(item)
            if p then return p end
        end
    end
    for _, name in ipairs({"PatientBadgeBase", "VisitorBadgeBase", "PrintedBadge"}) do
        local item = misc:FindFirstChild(name, true)
        local p = item and FindCheckInTakePrompt(item)
        if p then return p end
    end
    return nil
end

local function GetPrintedBadgePP(station)
    local roots = station and {station} or GetCheckInRoots()
    for _, s in ipairs(roots) do
        local pb = s:FindFirstChild("PrintedBadge")
        local p = pb and FindCheckInTakePrompt(pb)
        if p then return p end
    end
    return nil
end

local function WaitForPrintedBadgePP(timeout, station)
    local deadline = os.clock() + (timeout or 2.5)
    while os.clock() < deadline and not StopCheck() do
        local p = GetPrintedBadgePP(station)
        if p then return p end
        task.wait(0.15)
    end
    return nil
end

local _AH_HandledCheckIn = setmetatable({}, { __mode = "k" })

local function IsRecentlyHandledCheckInPatient(npc)
    if not npc then return true end
    local last = _AH_HandledCheckIn[npc]
    if last and (os.clock() - last < 20.0) then return true end
    return false
end

local function FindCheckInNpcPrompt()
    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return nil, nil end
    for _, station in ipairs(GetCheckInRoots()) do
        for _, npc in ipairs(npcs:GetChildren()) do
            if IsCheckInFriendlyNpc(npc, station) and not IsRecentlyHandledCheckInPatient(npc) and IsNpcAtCheckInCounter(npc, station) then
                local prompt = GetNpcCheckInPrompt(npc, true)
                return npc, prompt, station
            end
        end
    end
    return nil, nil, nil
end

local function HasNormalPatientAtCheckIn()
    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return false end
    for _, station in ipairs(GetCheckInRoots()) do
        for _, npc in ipairs(npcs:GetChildren()) do
            if IsNormalCheckInPatient(npc) and not IsRecentlyHandledCheckInPatient(npc) and IsNpcAtCheckInCounter(npc, station) then
                return true
            end
        end
    end
    return false
end

local function HasAnyNpcAtCheckInCounter()
    local patient, prompt, station = FindCheckInNpcPrompt()
    return patient ~= nil
end

local function IsCheckInPrinterPrompt(prompt)
    if not prompt then return false end
    local current, depth = prompt.Parent, 0
    while current and depth < 4 do
        if current.Name == "Printer" then return true end
        current = current.Parent
        depth = depth + 1
    end
    return false
end

local function IsCheckInMonitorPrompt(prompt)
    if not prompt then return false end
    local current, depth = prompt.Parent, 0
    while current and depth < 4 do
        if current.Name == "Computer" or current.Name == "Monitor" then return true end
        current = current.Parent
        depth = depth + 1
    end
    return false
end

local function GetCheckInRootForPrompt(prompt)
    if not prompt then return nil end
    local current = prompt.Parent
    while current and current ~= Workspace do
        if current.Name == "CheckIn" or current.Name == "CheckIn2" then
            return current
        end
        current = current.Parent
    end
    return nil
end

local _AH_BlockedPrinterPrompts = {}
local _AH_PromptPressCounts = {}
local _AH_SkippedPrompts = {}
local _AH_DisabledPrompts = {}

local function ClearBlockedPrinterPrompts()
    _AH_BlockedPrinterPrompts = {}
end

local function GetContainerCheckStepHighlight(prompt)
    if not prompt then return nil end
    local current, depth = prompt.Parent, 0
    while current and current.Parent and depth < 5 do
        if current.Parent.Name == "CheckIn" or current.Parent.Name == "CheckIn2" then
            return current:FindFirstChild("CheckStepHighlight")
        end
        current = current.Parent
        depth = depth + 1
    end
    return nil
end

local function IsCheckInPromptCandidate(prompt)
    if not (prompt:IsA("ProximityPrompt") and prompt.Enabled) then return false end
    if IsCheckInPrinterPrompt(prompt) and _AH_BlockedPrinterPrompts[prompt] then return false end
    local hl = GetContainerCheckStepHighlight(prompt)
    if hl and not hl.Enabled then return false end
    local isPhoto = prompt.Name == "Photo" or (prompt.Parent and prompt.Parent.Name == "Photo")
    return not isPhoto
end

local function ForEachEnabledCheckInPrompt(stepNames, callback, specificStation)
    local stations = specificStation and {specificStation} or GetCheckInRoots()
    for _, s in ipairs(stations) do
        for _, sName in ipairs(stepNames or {}) do
            local container = s:FindFirstChild(sName)
            if container then
                for _, desc in ipairs(container:GetDescendants()) do
                    if IsCheckInPromptCandidate(desc) then
                        local res = callback(desc)
                        if res then return res end
                    end
                end
                if IsCheckInPromptCandidate(container) then
                    local res = callback(container)
                    if res then return res end
                end
            end
        end
        for _, desc in ipairs(s:GetDescendants()) do
            if IsCheckInPromptCandidate(desc) then
                local res = callback(desc)
                if res then return res end
            end
        end
    end
    return nil
end

local function ResetCheckInPromptSkips()
    _AH_SkippedPrompts = {}
end

local function GetFirstEnabledCheckInPrompt(stepNames, allowSkipped, station)
    return ForEachEnabledCheckInPrompt(stepNames, function(p)
        if allowSkipped or not _AH_SkippedPrompts[p] then
            return p
        end
    end, station)
end

local function GetOtherEnabledCheckInPrompt(prompt, stepNames, station)
    return ForEachEnabledCheckInPrompt(stepNames, function(p)
        if p ~= prompt and not _AH_SkippedPrompts[p] then
            return p
        end
    end, station)
end

local function ResolveCheckInPrompt(stepNames, station)
    local p = GetFirstEnabledCheckInPrompt(stepNames, false, station)
    if p then return p end
    p = GetFirstEnabledCheckInPrompt(stepNames, true, station)
    if p then
        ResetCheckInPromptSkips()
        Log("AutoCheckIn", "Reset check-in prompt skip list; no unskipped prompts remain")
    end
    return p
end

local function RunCheckInCycle()
    if not _G.AutoCheckIn or StopCheck() then return false end

    local patient, patientPrompt, station = FindCheckInNpcPrompt()
    if not patient then return false end

    Log("AutoCheckIn", "Starting check-in cycle", { patient = patient.Name, station = station and station.Name })
    LockCamera()

    local npcs = Workspace:FindFirstChild("NPCs")
    local stalker = npcs and npcs:FindFirstChild("StalkerMonster")
    if stalker then
        local misc = Workspace:FindFirstChild("Misc")
        local paper = misc and misc:FindFirstChild("StrangePaper")
        if paper then
            local pp = paper:FindFirstChildWhichIsA("ProximityPrompt", true)
            if pp and pp.Enabled then
                Log("AutoCheckIn", "Interacting with StrangePaper for StalkerMonster")
                PressPromptNearby(pp, 0.5, Vector3.new(0, 3, 0), 0.2)
            end
        end
    end

    local steps = {"Form", "Camera", "Computer", "Printer", "PrintedBadge", "PatientBadgeBase", "VisitorBadgeBase"}
    local targetStation = station
    local didAnyAction = false

    if patient and IsNormalCheckInPatient(patient) and (_G.AutoAnomalyShutter or _G.AutoBarneyShutter) then
        if npcs then
            for _, other in ipairs(npcs:GetChildren()) do
                local oStation = GetCheckInStationForNpc(other)
                if other ~= patient and oStation and oStation ~= station and other:GetAttribute("Skinwalker") == true then
                    targetStation = nil
                    Log("AutoCheckIn", "Using shared check-in prompts while skipping anomaly talk", { patient = patient.Name, anomaly = other.Name })
                    break
                end
            end
        end
    end

    if patient then
        local attempts = 0
        while not StopCheck() and attempts < 10 do
            attempts = attempts + 1
            if patient:GetAttribute("Skinwalker") == true and _G.AutoAnomalyShutter then
                Log("AutoCheckIn", "Aborting check-in because patient is an anomaly", { npc = patient.Name })
                break
            end

            patientPrompt = GetNpcCheckInPrompt(patient, true)
            local canTalk = (_G.AutoAnomalyShutter or _G.AutoBarneyShutter) and IsNormalCheckInPatient(patient) and patientPrompt
            local nextPrompt = ResolveCheckInPrompt(steps, targetStation)

            if not nextPrompt and station and station.Name == "CheckIn2" then
                local misc = Workspace:FindFirstChild("Misc")
                local defaultStation = misc and misc:FindFirstChild("CheckIn")
                nextPrompt = ResolveCheckInPrompt(steps, defaultStation)
            end

            if not nextPrompt and not targetStation then
                nextPrompt = GetPrintedBadgePP() or GetCheckInBadgePP()
            end

            -- If patient talk prompt is immediately ready -> complete checkin
            if canTalk and patientPrompt and patientPrompt.Enabled then
                local pos = GetPromptPosition(patientPrompt)
                if pos then
                    TeleportTo(pos + Vector3.new(0, 3, 0))
                    task.wait(0.5)
                end
                if PressPP(patientPrompt, 0.4) then
                    didAnyAction = true
                    pcall(function()
                        patient:SetAttribute("CompletedCheckIn", LocalPlayer.Name)
                        patient:SetAttribute("FoxnameCheckInPromptHandled", true)
                    end)
                    _AH_HandledCheckIn[patient] = os.clock()
                end
                break
            end

            if nextPrompt then
                if patient:GetAttribute("Skinwalker") == true and _G.AutoAnomalyShutter then
                    break
                end

                if IsCheckInPrinterPrompt(nextPrompt) then
                    local rootS = GetCheckInRootForPrompt(nextPrompt)
                    local printedBadge = nil
                    for attempt = 1, 2 do
                        if not (nextPrompt.Parent and nextPrompt.Enabled) or StopCheck() then break end
                        Log("AutoCheckIn", "Printing badge", { patient = patient.Name, prompt = nextPrompt:GetFullName(), attempt = attempt })
                        didAnyAction = PressPromptNearby(nextPrompt, 0.25, Vector3.new(0, 3, 0), 0.5) or didAnyAction
                        printedBadge = WaitForPrintedBadgePP(2.5, rootS)
                        if printedBadge then break end
                    end
                    if printedBadge then
                        Log("AutoCheckIn", "Taking printed badge", { patient = patient.Name, prompt = printedBadge:GetFullName() })
                        didAnyAction = PressPromptNearby(printedBadge, 0.25, Vector3.new(0, 3, 0), 0.2) or didAnyAction
                        _AH_BlockedPrinterPrompts[nextPrompt] = true
                    else
                        _AH_BlockedPrinterPrompts[nextPrompt] = true
                        LogError("AutoCheckIn", "Printer did not produce a badge; waiting for monitor", { patient = patient.Name, prompt = nextPrompt:GetFullName() })
                    end
                elseif nextPrompt.Name == "Form" or (nextPrompt.Parent and nextPrompt.Parent.Name == "Form") then
                    patient:SetAttribute("GivenForm", true)
                    local pos = GetPromptPosition(nextPrompt)
                    if pos then
                        TeleportTo(pos + Vector3.new(0, 3, 0))
                        task.wait(0.5)
                    end
                    didAnyAction = PressPP(nextPrompt, 0.4) or didAnyAction
                    task.wait(0.2)
                else
                    local pos = GetPromptPosition(nextPrompt)
                    if pos then
                        TeleportTo(pos + Vector3.new(0, 3, 0))
                        task.wait(0.5)
                    end
                    local pressed = PressPP(nextPrompt, 0.4)
                    didAnyAction = pressed or didAnyAction
                    if pressed and IsCheckInMonitorPrompt(nextPrompt) then
                        ClearBlockedPrinterPrompts()
                    end
                    task.wait(0.2)
                end
            end

            patientPrompt = GetNpcCheckInPrompt(patient, true)
            if patientPrompt and patientPrompt.Enabled then
                if patient:GetAttribute("Skinwalker") == true and _G.AutoAnomalyShutter then break end
                local pos = GetPromptPosition(patientPrompt)
                if pos then
                    TeleportTo(pos + Vector3.new(0, 3, 0))
                    task.wait(0.5)
                end
                if PressPP(patientPrompt, 0.4) then
                    didAnyAction = true
                    pcall(function()
                        patient:SetAttribute("CompletedCheckIn", LocalPlayer.Name)
                        patient:SetAttribute("FoxnameCheckInPromptHandled", true)
                    end)
                    _AH_HandledCheckIn[patient] = os.clock()
                end
                break
            end

            if not nextPrompt and not patientPrompt then break end
            task.wait(0.1)
        end
    end

    if not didAnyAction then
        local orphan = GetPrintedBadgePP() or GetCheckInBadgePP()
        if orphan and orphan.Parent and orphan.Enabled then
            Log("AutoCheckIn", "Picking up orphaned badge (no NPC in cycle)", { prompt = orphan:GetFullName() })
            didAnyAction = PressPromptNearby(orphan, 0.25, Vector3.new(0, 3, 0), 0.2) or didAnyAction
            ClearBlockedPrinterPrompts()
        end
    end

    UnlockCamera()
    return didAnyAction
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🎒 INVENTORY & PHARMACY INDEXER
-- ══════════════════════════════════════════════════════════════════════════════════
local _AH_ItemIndexTable = {}
local _AH_IndexedOnce = false

local function IndexTreatmentPrompt(prompt)
    if not prompt:IsA("ProximityPrompt") then return end
    local current = prompt.Parent
    while current and current ~= Workspace do
        if _G.AH_ItemSet[current.Name] and not _G.AH_BlacklistedItemNames[current.Name] and (current:IsA("Model") or current:IsA("BasePart")) then
            local tbl = _AH_ItemIndexTable[current.Name]
            if not tbl then tbl = {} _AH_ItemIndexTable[current.Name] = tbl end
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

local function GetItemPP(itemName)
    InitTreatmentIndex()
    local promptSet = _AH_ItemIndexTable[itemName]
    if promptSet then
        for prompt in pairs(promptSet) do
            if prompt.Parent and prompt.Enabled then
                return prompt
            end
        end
    end
    return nil
end

local function GetSurgeryItemPP(itemName)
    local ok, med = pcall(function() return Workspace.Rooms.Emergency.Room8.Minigame.Medicine end)
    if ok and med then
        for _, d in ipairs(med:GetDescendants()) do
            if d:IsA("ProximityPrompt") and d.Parent and d.Parent.Name == itemName and d.Enabled then
                return d
            end
        end
    end
    return nil
end

local function ForEachTool(containers, callback)
    for _, c in ipairs(containers or {}) do
        for _, t in ipairs(c:GetChildren()) do
            if t:IsA("Tool") then
                local res = callback(t)
                if res then return res end
            end
        end
    end
    return nil
end

local function InventoryParents()
    local list = {}
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then table.insert(list, bp) end
    local char = LocalPlayer.Character
    if char then table.insert(list, char) end
    return list
end

local function GetInventoryTool(itemName)
    return ForEachTool(InventoryParents(), function(tool)
        if tool.Name == itemName then return tool end
    end)
end

local function GetItemCount(itemName)
    local count = 0
    ForEachTool(InventoryParents(), function(tool)
        if tool.Name == itemName then count = count + 1 end
    end)
    return count
end

local function GetMedicineItemCount()
    local count = 0
    ForEachTool(InventoryParents(), function(tool)
        if _G.AH_ItemSet[tool.Name] or _G.AH_SurgeryItemSet[tool.Name] or _G.AH_BlacklistedItemNames[tool.Name] then
            count = count + 1
        end
    end)
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

local function GetWrongInventoryTool(targetItem)
    return ForEachTool(InventoryParents(), function(tool)
        if tool.Name ~= targetItem and (_G.AH_ItemSet[tool.Name] or _G.AH_SurgeryItemSet[tool.Name] or _G.AH_BlacklistedItemNames[tool.Name]) then
            return tool
        end
    end)
end

local function DiscardToolAtTrash(tool, roomData)
    if not tool or StopCheck() then return end
    EquipToolOnly(tool)
    task.wait(0.05)
    local trash = Workspace:FindFirstChild("Trash")
    local trashPP = trash and (trash:FindFirstChild("PP") or trash:FindFirstChildWhichIsA("ProximityPrompt", true))
    if trashPP and trashPP.Enabled then
        PressPromptNearbyUntil(trashPP, 0.2, 1.5, function()
            return not tool.Parent or tool.Parent ~= LocalPlayer.Character
        end, nil, Vector3.new(0, 1.5, -2), 0.1)
    end
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🩹 TREATMENT DIAGNOSTIC & PRESCRIPTION PARSER (FOXNAME 1-TO-1)
-- ══════════════════════════════════════════════════════════════════════════════════
local _AH_RoomCooldowns = {}

local function IsRecentlyTreated(npc)
    if not npc then return true end
    local last = _G.AH_TreatedPatients[npc] or _G.AH_TreatedPatients[npc.Name]
    if last and (os.clock() - last < 25.0) then return true end
    return false
end

local function MarkPatientTreated(npc)
    if npc then
        _G.AH_TreatedPatients[npc] = os.clock()
        _G.AH_TreatedPatients[npc.Name] = os.clock()
    end
end

local function IsTakeDnaSamplePrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return false end
    local act = string.lower(prompt.ActionText or "")
    return act:find("take") ~= nil and act:find("sample") ~= nil
end

local function ScanNpcPrompts(npc)
    local result = { Talk = nil, CheckIn = nil, Help = nil, AskLeave = nil, First = nil }
    if not npc then return result end
    for _, p in ipairs(npc:GetDescendants()) do
        if p:IsA("ProximityPrompt") and p.Enabled then
            if not result.First then result.First = p end
            local act = string.lower(tostring(p.ActionText or ""))
            if act:find("talk") then
                result.Talk = p
            elseif act:find("check") or act:find("badge") or act:find("register") then
                result.CheckIn = p
            elseif act:find("help") or act:find("carry") or act:find("revive") or act:find("faint") then
                result.Help = p
            elseif act:find("leave") or act:find("dismiss") or act:find("ask") then
                result.AskLeave = p
            end
        end
    end
    return result
end

local function GetFirstEnabledNpcPrompt(npc)
    return ScanNpcPrompts(npc).First
end

local function GetTakeDnaSamplePrompt(npc)
    if not npc then return nil end
    for _, p in ipairs(npc:GetDescendants()) do
        if p:IsA("ProximityPrompt") and p.Enabled and IsTakeDnaSamplePrompt(p) then
            return p
        end
    end
    return nil
end

local function IsItemChecked(itemGui)
    local check = itemGui:FindFirstChild("check")
    if not check then return false end
    local ok, vis = pcall(function() return check.Visible end)
    return ok and vis == true
end

local function GetRoomFolder(roomData)
    return roomData.Emergency and Workspace.Rooms.Emergency or Workspace.Rooms.Medical
end

local function IsTreatmentReportItem(roomData, itemName)
    return _G.AH_ItemSet[itemName] or (roomData.Name == "Room8" and _G.AH_SurgeryItemSet[itemName])
end

local function GetReportInventory(roomData, waitForIt)
    local folder = GetRoomFolder(roomData)
    if waitForIt then
        return WaitForPath(function()
            return folder[roomData.Name].Minigame.TV.Screen.UI.Report.inv
        end, 5)
    end
    local ok, inv = pcall(function()
        return folder[roomData.Name].Minigame.TV.Screen.UI.Report.inv
    end)
    return ok and inv or nil
end

local function GetNeededTreatmentItems(roomData)
    local inv = GetReportInventory(roomData, true)
    if StopCheck() or not inv then return {} end
    local needed = {}
    for _, child in ipairs(inv:GetChildren()) do
        if child:IsA("GuiObject") and child.Visible and IsTreatmentReportItem(roomData, child.Name) and not IsItemChecked(child) then
            table.insert(needed, child.Name)
        end
    end
    Log("AutoTreatment", "Resolved needed treatment items", { room = roomData.Name, neededItems = table.concat(needed, ", ") })
    return needed
end

local function CountNeededTreatmentItems(roomData, fastCheck)
    local inv = GetReportInventory(roomData, not fastCheck)
    if (not fastCheck and StopCheck()) or not inv then return 0 end
    local count = 0
    for _, child in ipairs(inv:GetChildren()) do
        if child:IsA("GuiObject") and child.Visible and IsTreatmentReportItem(roomData, child.Name) then
            count = count + 1
        end
    end
    return count
end

local function GetMonitorIllnessCount(roomData)
    local folder = GetRoomFolder(roomData)
    local ok, label = pcall(function()
        return folder[roomData.Name].Minigame.Monitor.Screen.UI.Report.illnesses
    end)
    if not ok or not label then return 0 end
    local text, count = label.Text or "", 0
    for line in text:gmatch("[^\n]+") do
        if line:match("^%s*%-") then
            count = count + 1
        end
    end
    return count
end

local function IsRoomRecovering(roomData)
    local folder = GetRoomFolder(roomData)
    local ok, healing, header = pcall(function()
        local ui = folder[roomData.Name].Minigame.TV.Screen.UI
        return ui.Healing, ui.Healing.header
    end)
    if not ok or not healing or not header then return false end
    local cur = header
    while cur and cur ~= folder do
        if cur:IsA("GuiObject") and cur.Visible == false then return false end
        cur = cur.Parent
    end
    local text = string.lower(tostring(header.Text or ""))
    return text:find("patient") ~= nil and text:find("recover") ~= nil
end

local function FindPromptByAction(parent, actionWord, enabledOnly)
    if not parent then return nil end
    actionWord = string.lower(actionWord or "")
    for _, p in ipairs(parent:GetDescendants()) do
        if p:IsA("ProximityPrompt") and string.find(string.lower(p.ActionText or ""), actionWord) then
            if not enabledOnly or p.Enabled then return p end
        end
    end
    return nil
end

local function WaitForEnabledPrompt(prompt, timeout)
    local deadline = os.clock() + (timeout or 10)
    while prompt and prompt.Parent and os.clock() < deadline and not StopCheck() do
        if prompt.Enabled then return prompt end
        task.wait(0.1)
    end
    if prompt and prompt.Parent and prompt.Enabled then return prompt end
    return nil
end

local function GetMonitorProcessPrompt(minigame, enabledOnly)
    local monitor = minigame and minigame:FindFirstChild("Monitor")
    if not monitor then return nil end
    local p = FindPromptByAction(monitor, "process", enabledOnly) or monitor:FindFirstChild("PP2")
    if p and (not enabledOnly or p.Enabled) then return p end
    return nil
end

local function GetRoom6XrayPrompt(minigame)
    local mon = minigame and minigame:FindFirstChild("xrayMonitor")
    local pp = mon and mon:FindFirstChild("PP")
    if pp and pp:IsA("ProximityPrompt") then return pp end
    return nil
end

local function GetPrintedXRayPrompt(minigame)
    if not minigame then return nil end
    local xray = minigame:FindFirstChild("PrintedXRay") or minigame:FindFirstChild("PrintedXRay", true)
    local pp = xray and (xray:FindFirstChild("PP") or xray:FindFirstChildWhichIsA("ProximityPrompt", true))
    if pp and pp.Enabled then return pp end
    local xres = minigame:FindFirstChild("xresult") or minigame:FindFirstChild("xresult", true)
    local pp2 = xres and (xres:FindFirstChild("PP") or xres:FindFirstChildWhichIsA("ProximityPrompt", true))
    if pp2 and pp2.Enabled then return pp2 end
    return pp or pp2
end

local function GetMonitorPromptForRoom(roomData, minigame)
    local rNum = tonumber((roomData.Name or ""):match("%d+"))
    if rNum and rNum >= 1 and rNum <= 5 then
        local monPP = GetMonitorProcessPrompt(minigame, false)
        if monPP and not monPP.Enabled then monPP.Enabled = true end
        return monPP
    end
    if rNum and rNum >= 6 and rNum <= 7 then
        local monPP = WaitForPath(function() return GetMonitorProcessPrompt(minigame, false) end, 6)
        if monPP and not monPP.Enabled then monPP.Enabled = true end
        return monPP
    end
    return WaitForPath(function() return GetMonitorProcessPrompt(minigame, true) end, 6)
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🏥 FULL PATIENT TREATMENT CYCLE (EXACT FOXNAME ae FUNCTION)
-- ══════════════════════════════════════════════════════════════════════════════════
local function ExecutePatientTreatment(patient, patientPrompt, roomData)
    if not patient or not patient.Parent then return false end

    local pRoot = patient:FindFirstChild("HumanoidRootPart") or patient:FindFirstChild("Torso")
    if not pRoot then return false end

    -- Verify patient is physically in this room or already in bed
    local pDist = (pRoot.Position - roomData.Position).Magnitude
    local pInBed = patient:GetAttribute("InBed") == true
    if not pInBed and pDist > 24 then
        Log("AutoTreatment", "Patient is still walking to room; skipping for now", { room = roomData.Name, dist = math.floor(pDist) })
        _AH_RoomCooldowns[roomData.Name] = os.clock() + 3.0
        return false
    end

    Log("AutoTreatment", "Starting patient treatment", {
        room = roomData.Name,
        npc = patient and patient:GetFullName() or "nil",
        npcPrompt = patientPrompt and patientPrompt:GetFullName() or "nil",
        emergency = roomData.Emergency == true
    })

    -- Room 6: wait for patient to reach X-ray area
    if roomData.Name == "Room6" then
        Log("AutoTreatment", "Waiting for Room6 patient to reach xray area", { npc = patient and patient.Name, room = roomData.Name })
        local start = os.clock()
        while os.clock() - start < 15 and not StopCheck() do
            if not patient then break end
            local root = patient:FindFirstChild("HumanoidRootPart")
            if root and (root.Position - roomData.Position).Magnitude <= 20 then break end
            task.wait(0.5)
        end
        task.wait(2)
        local mg = Workspace.Rooms.Emergency and Workspace.Rooms.Emergency.Room6:FindFirstChild("Minigame")
        if mg then
            local xrayPP = GetRoom6XrayPrompt(mg)
            if xrayPP and xrayPP.Enabled then
                Log("AutoTreatment", "Pressing Room6 xray prompt", { prompt = xrayPP:GetFullName() })
                PressTreatmentPromptNearbyUntil(xrayPP, 0.3, 4.0, function()
                    return not xrayPP.Parent or not xrayPP.Enabled or CountNeededTreatmentItems(roomData, true) > 0
                end)
            end
        end
    end

    local folder = GetRoomFolder(roomData)
    local room = folder and folder:FindFirstChild(roomData.Name)
    local minigame = room and room:FindFirstChild("Minigame")
    if not minigame then
        LogError("AutoTreatment", "Minigame not found for room; skipping patient", { room = roomData.Name })
        return
    end

    local rNum = tonumber((roomData.Name or ""):match("%d+"))

    -- DNA Sample prompt on patient
    local dnaPP = GetTakeDnaSamplePrompt(patient) or (IsTakeDnaSamplePrompt(patientPrompt) and patientPrompt)
    if not roomData.Emergency and dnaPP and dnaPP.Enabled then
        Log("AutoTreatment", "Taking DNA sample", { room = roomData.Name, npc = patient and patient.Name, prompt = dnaPP:GetFullName() })
        PressTreatmentPromptNearby(dnaPP, 0.5)
        task.wait(0.3)
        if StopCheck() then return end

        -- Insert DNA sample into Analyzer (Rooms 1 - 5)
        local analyzer = minigame:FindFirstChild("Analyzer") or minigame:FindFirstChild("Analyser")
        local analyzerPP = analyzer and (analyzer:FindFirstChild("PP") or analyzer:FindFirstChildWhichIsA("ProximityPrompt", true))
        if analyzerPP and analyzerPP.Enabled then
            Log("AutoTreatment", "Inserting sample into DNA Analyzer", { room = roomData.Name, prompt = analyzerPP:GetFullName() })
            PressTreatmentPromptNearby(analyzerPP, 0.4, 0.2)
            task.wait(0.4)
        end
    end

    -- Rooms 1 - 5: enable monitor prompt in executor
    if not roomData.Emergency and rNum and rNum >= 1 and rNum <= 5 then
        local monPP = GetMonitorProcessPrompt(minigame, false)
        if monPP and not monPP.Enabled then
            Log("AutoTreatment", "Enabling medical monitor process prompt", { room = roomData.Name, prompt = monPP:GetFullName() })
            monPP.Enabled = true
        end
    end

    -- Bed PP2 prompt
    local bedPP2 = minigame:FindFirstChild("Bed") and minigame.Bed:FindFirstChild("InBed") and minigame.Bed.InBed:FindFirstChild("PP2")
    if bedPP2 and bedPP2.Enabled then
        Log("AutoTreatment", "Pressing bed prompt", { room = roomData.Name, prompt = bedPP2:GetFullName() })
        if roomData.Name == "Room8" then
            PressTreatmentPromptNearbyUntil(bedPP2, 0.25, 3.0, function()
                return not bedPP2.Parent or not bedPP2.Enabled or CountNeededTreatmentItems(roomData, true) > 0
            end)
        else
            PressTreatmentPromptNearbyUntil(bedPP2, 0.25, 3.0, function()
                return not bedPP2.Parent or not bedPP2.Enabled or (patient and patient:GetAttribute("InBed") == true)
            end)
        end
    end

    -- Monitor / X-Ray / Bed Prep Cycle (Rooms 1 - 7)
    if roomData.Name ~= "Room8" then
        local retriesLeft = 1
        local tvHasFrames = false
        local expectedCount = 0

        while retriesLeft >= 0 and not StopCheck() do
            local hasReportItems = CountNeededTreatmentItems(roomData, true) > 0
            if roomData.Name == "Room6" or roomData.Name == "Room7" then
                local xresultPP = GetPrintedXRayPrompt(minigame)
                if xresultPP and xresultPP.Enabled then
                    Log("AutoTreatment", "xresult already ready before monitor press, pressing it", { room = roomData.Name, prompt = xresultPP:GetFullName() })
                    PressTreatmentPromptNearbyUntil(xresultPP, 0.35, 5.0, function()
                        return not xresultPP.Parent or not xresultPP.Enabled
                    end)
                    task.wait(0.3)
                    if StopCheck() then return end
                    hasReportItems = CountNeededTreatmentItems(roomData, true) > 0
                end
            end

            if not hasReportItems then
                local monPP = GetMonitorPromptForRoom(roomData, minigame)
                if not monPP then
                    monPP = GetMonitorProcessPrompt(minigame, false)
                    if monPP then monPP.Enabled = true end
                end
                if StopCheck() then return end

                -- ONLY press computer/monitor if patient is actually in bed or room 6!
                local patientInBed = patient:GetAttribute("InBed") == true or roomData.Name == "Room6"
                if monPP and patientInBed then
                    Log("AutoTreatment", "Pressing monitor process prompt", { room = roomData.Name, prompt = monPP:GetFullName(), retryLeft = retriesLeft })
                    if retriesLeft == 0 then
                        local mPos = GetPromptPosition(monPP)
                        local cam = Workspace.CurrentCamera
                        if cam and mPos then cam.CFrame = CFrame.lookAt(cam.CFrame.Position, mPos) end
                    end
                    if StopCheck() then return end

                    if monPP.Enabled then
                        if PressTreatmentPromptNearby(monPP, 0.3, 0.5) and roomData.Name == "Room6" then
                            local xPP = GetRoom6XrayPrompt(minigame)
                            if xPP and xPP.Enabled then
                                xPP.Enabled = false
                                Log("AutoTreatment", "Disabled Room6 xray prompt after monitor process", { prompt = xPP:GetFullName() })
                            end
                        end

                        if roomData.Name == "Room7" then
                            local bed = minigame:FindFirstChild("Bed")
                            local inBed = bed and bed:FindFirstChild("InBed")
                            local prepPP = inBed and inBed:FindFirstChild("PP2")
                            if prepPP then
                                if not prepPP.Enabled then
                                    Log("AutoTreatment", "Room7: waiting for BedPP2 to become enabled", { prompt = prepPP:GetFullName() })
                                    local conn
                                    local becameEnabled = false
                                    conn = prepPP:GetPropertyChangedSignal("Enabled"):Connect(function() becameEnabled = true end)
                                    local deadline = os.clock() + 12
                                    while not becameEnabled and os.clock() < deadline and not StopCheck() do
                                        task.wait(0.05)
                                    end
                                    conn:Disconnect()
                                end
                                if prepPP.Enabled and not StopCheck() then
                                    Log("AutoTreatment", "Room7: pressing BedPP2 (Prepare Patient)", { prompt = prepPP:GetFullName() })
                                    PressTreatmentPromptNearbyUntil(prepPP, 0.25, 3.0, function()
                                        return not prepPP.Parent or not prepPP.Enabled
                                    end)
                                end
                            end
                        end
                    end
                end

                local monWait = os.clock() + 4.0
                while os.clock() < monWait and not StopCheck() do
                    if GetMonitorIllnessCount(roomData) > 0 then break end
                    if (roomData.Name == "Room6" or roomData.Name == "Room7") and GetPrintedXRayPrompt(minigame) and GetPrintedXRayPrompt(minigame).Enabled then
                        break
                    end
                    task.wait(0.25)
                end
            end

            task.wait(0.6)
            if StopCheck() then return end

            if roomData.Name == "Room6" or roomData.Name == "Room7" then
                local xres = GetPrintedXRayPrompt(minigame)
                if not (xres and xres.Enabled) then
                    xres = WaitForPath(function() return GetPrintedXRayPrompt(minigame) end, 10)
                end
                if xres then
                    Log("AutoTreatment", "Pressing xresult prompt", { room = roomData.Name, prompt = xres:GetFullName() })
                    PressTreatmentPromptNearbyUntil(xres, 0.35, 5.0, function()
                        return not xres.Parent or not xres.Enabled
                    end)
                end
            end

            local illnessWait = os.clock() + 8.5
            expectedCount = 0
            while os.clock() < illnessWait and not StopCheck() do
                expectedCount = GetMonitorIllnessCount(roomData)
                if expectedCount > 0 then break end
                task.wait(0.25)
            end

            if StopCheck() then return end

            if expectedCount == 0 then
                if retriesLeft > 0 then
                    LogError("AutoTreatment", "Monitor did not show illnesses after 8.5s; retrying once", { room = roomData.Name, retryLeft = retriesLeft })
                    retriesLeft = retriesLeft - 1
                    task.wait(1)
                else
                    LogError("AutoTreatment", "Monitor did not show illnesses after 8.5s; skipping patient", { room = roomData.Name })
                    _AH_RoomCooldowns[roomData.Name] = os.clock() + 5.0
                    return false
                end
            else
                local tvWait = os.clock() + 10.0
                while os.clock() < tvWait and not StopCheck() do
                    if CountNeededTreatmentItems(roomData, true) >= expectedCount then
                        tvHasFrames = true
                        break
                    end
                    task.wait(0.25)
                end
                if StopCheck() then return end
                if tvHasFrames then break end
                if retriesLeft > 0 then
                    LogError("AutoTreatment", "TV report does not have enough frames after 10s; retrying once", { room = roomData.Name, expectedFrames = expectedCount, retryLeft = retriesLeft })
                    retriesLeft = retriesLeft - 1
                    task.wait(1)
                else
                    LogError("AutoTreatment", "TV report does not have enough frames after 10s; skipping patient", { room = roomData.Name })
                    _AH_RoomCooldowns[roomData.Name] = os.clock() + 5.0
                    return false
                end
            end
        end
    else
        -- Room 8 Surgery start wait
        local surgWait = os.clock() + 10.0
        local surgStarted = false
        while os.clock() < surgWait and not StopCheck() do
            local items = GetNeededTreatmentItems(roomData)
            if #items > 0 then surgStarted = true break end
            task.wait(0.25)
        end
        if not surgStarted then
            LogError("AutoTreatment", "Surgery did not start after 10s; no items in report", { room = roomData.Name })
            if patient then _G.AH_TreatedPatients[patient] = os.clock() end
            return
        end
    end

    -- Target prompt on patient or bed
    local targetPrompt = WaitForPath(function()
        if roomData.Name == "Room6" then
            return patient and (patient:FindFirstChild("PP") or patient:FindFirstChildWhichIsA("ProximityPrompt", true))
        end
        return minigame.Bed.InBed.PP
    end, 5)

    if StopCheck() then return end

    local attempts = 0
    while not StopCheck() do
        if not patient or not patient.Parent then break end
        if roomData.Name == "Room6" then
            local root = patient:FindFirstChild("HumanoidRootPart")
            if not root or (root.Position - roomData.Position).Magnitude > 25 then break end
        else
            if patient:GetAttribute("InBed") ~= true then break end
        end

        local needed = GetNeededTreatmentItems(roomData)
        if #needed == 0 then
            if roomData.Name == "Room8" then
                local sWait = os.clock() + 8.0
                local gotMore = false
                while os.clock() < sWait and not StopCheck() do
                    needed = GetNeededTreatmentItems(roomData)
                    if #needed > 0 then gotMore = true break end
                    task.wait(0.25)
                end
                if not gotMore then break end
            else
                break
            end
        end

        -- Room 8 Surgery final 3 items optimization
        if roomData.Name == "Room8" and #needed == 3 then
            pcall(function()
                game.StarterGui:SetCore("SendNotification", { Title = "Surgery Ending", Text = "Delivering last 3 treatments.", Duration = 6 })
            end)
            local itemCounts = {}
            for _, name in ipairs(needed) do itemCounts[name] = (itemCounts[name] or 0) + 1 end
            for name, reqCount in pairs(itemCounts) do
                local deadline = os.clock() + 8.0
                while GetItemCount(name) < reqCount and not StopCheck() and os.clock() < deadline do
                    if GetMedicineItemCount() >= 3 then
                        local wrong = GetWrongInventoryTool(name)
                        if wrong then DiscardToolAtTrash(wrong, roomData) end
                    end
                    local sPP = GetSurgeryItemPP(name)
                    if sPP then
                        local countBefore = GetItemCount(name)
                        PressTreatmentPromptNearbyUntil(sPP, 0.12, 1.2, function() return GetItemCount(name) > countBefore end)
                        local t = os.clock()
                        while os.clock() - t < 0.8 and not StopCheck() do
                            if GetItemCount(name) > countBefore then break end
                            task.wait(0.03)
                        end
                        task.wait(0.1)
                    else
                        break
                    end
                end
            end
            for _, name in ipairs(needed) do
                if StopCheck() then return end
                if GetItemCount(name) > 0 then
                    if targetPrompt then
                        local pos = GetPromptPosition(targetPrompt)
                        if pos then TeleportTo(pos + treatmentOffset) task.wait(0.05) end
                    end
                    task.wait(0.05)
                    UseInventoryTool(name)
                    if targetPrompt then
                        local readyPP = WaitForEnabledPrompt(targetPrompt, 10)
                        if readyPP then
                            PressTreatmentPromptNearbyUntil(readyPP, 0.15, 1.5, function() return GetItemCount(name) == 0 end)
                        end
                    end
                end
            end
            break
        end

        attempts = attempts + 1
        if attempts > 20 then
            LogError("AutoTreatment", "Exceeded maximum item grab attempts; skipping rest", { room = roomData.Name, attempts = attempts })
            break
        end

        local currentItem = needed[1]
        local isSkinwalker = patient:GetAttribute("Skinwalker") == true
        local inBed = patient:GetAttribute("InBed") == true
        local shouldKill = isSkinwalker and inBed and _G.AutoKillAnomaly

        local targetItem = currentItem
        if shouldKill then
            local all = roomData.Name == "Room8" and _G.AH_SurgeryItemList or _G.AH_ItemList
            for _, item in ipairs(all) do
                local wanted = false
                for _, req in ipairs(needed) do if req == item then wanted = true break end end
                if not wanted then targetItem = item break end
            end
        end

        if GetMedicineItemCount() >= 3 and GetItemCount(targetItem) == 0 then
            local wrong = GetWrongInventoryTool(targetItem)
            if wrong then DiscardToolAtTrash(wrong, roomData) end
        end

        local equipped = UseInventoryTool(targetItem)
        if not equipped then
            if GetItemCount(targetItem) == 0 then
                local itemPP = roomData.Name == "Room8" and GetSurgeryItemPP(targetItem) or GetItemPP(targetItem)
                if itemPP then
                    Log("AutoTreatment", "Grabbing treatment item", { room = roomData.Name, targetItem = targetItem, prompt = itemPP:GetFullName(), countBefore = GetItemCount(targetItem) })
                    local countBefore = GetItemCount(targetItem)
                    PressTreatmentPromptNearbyUntil(itemPP, 0.12, 1.2, function() return GetItemCount(targetItem) > countBefore end)
                    local t = os.clock()
                    while os.clock() - t < 1.5 and not StopCheck() do
                        if GetItemCount(targetItem) > countBefore then break end
                        task.wait(0.03)
                    end
                    task.wait(0.1)
                end
            end

            if StopCheck() then return end
            task.wait(0.05)

            if GetItemCount(targetItem) > 0 then
                equipped = UseInventoryTool(targetItem)
            else
                LogError("AutoTreatment", "Grabbed wrong item or did not receive target item; retrying", { room = roomData.Name, targetItem = targetItem })
                local wrong = GetWrongInventoryTool(targetItem)
                if wrong then DiscardToolAtTrash(wrong, roomData) end
                task.wait(0.5)
            end
        end

        if not equipped then
            task.wait(0.1)
        else
            if StopCheck() then return end
            if targetPrompt then
                local pos = GetPromptPosition(targetPrompt)
                if pos then TeleportTo(pos + treatmentOffset) task.wait(0.05) end
                local readyPP = WaitForEnabledPrompt(targetPrompt, 10)
                if readyPP then
                    Log("AutoTreatment", "Delivering treatment item to bed", { room = roomData.Name, targetItem = targetItem, prompt = readyPP:GetFullName() })
                    PressTreatmentPromptNearbyUntil(readyPP, 0.15, 1.5, function()
                        return GetItemCount(targetItem) == 0 or not readyPP.Parent or not readyPP.Enabled
                    end)
                end
            end
        end

        task.wait(0.05)
        if StopCheck() then return end
        if shouldKill then task.wait(0.5) break end

        local verifyWait = os.clock() + 5.0
        while os.clock() < verifyWait and not StopCheck() do
            local curNeeded = GetNeededTreatmentItems(roomData)
            local stillNeeds = false
            for _, n in ipairs(curNeeded) do if n == currentItem then stillNeeds = true break end end
            if not stillNeeds then break end
            task.wait(0.25)
        end
    end

    if StopCheck() then return end

    -- Discard remaining tools at trash
    local trashPP = WaitForPath(function() return Workspace.Trash.PP end, 4)
    if trashPP then
        local discardCount = 0
        while discardCount < 10 and not StopCheck() do
            local tool = ForEachTool(InventoryParents(), function(t)
                if _G.AH_ItemSet[t.Name] or _G.AH_SurgeryItemSet[t.Name] or _G.AH_BlacklistedItemNames[t.Name] then
                    return t
                end
            end)
            if not tool then break end
            DiscardToolAtTrash(tool, roomData)
            discardCount = discardCount + 1
        end
    end

    if patient then
        MarkPatientTreated(patient)
    end
    _AH_RoomCooldowns[roomData.Name] = os.clock() + 4.0
    Log("AutoTreatment", "Finished patient treatment", { room = roomData.Name, npc = patient and patient.Name or "unknown" })
    return true
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🏥 EXACT FOXNAME MULTI-TIER PATIENT FINDERS & ROOM SCHEDULER
-- ══════════════════════════════════════════════════════════════════════════════════
local function GetRoomPrimaryPrompt(roomName)
    local numStr = tostring(roomName or ''):match('%d+')
    local rNum = tonumber(numStr)
    if not rNum then return nil end
    local folder = rNum <= 5 and Workspace.Rooms.Medical or Workspace.Rooms.Emergency
    local room = folder:FindFirstChild(roomName)
    if not room then return nil end
    local mg = room:FindFirstChild('Minigame')
    if not mg then return nil end
    if roomName == 'Room6' then
        local xmon = mg:FindFirstChild('xrayMonitor')
        return xmon and xmon:FindFirstChild('PP')
    end
    local bed = mg:FindFirstChild('Bed')
    if not bed then return nil end
    local inBed = bed:FindFirstChild('InBed')
    if not inBed then return nil end
    return inBed:FindFirstChild('PP2') or inBed:FindFirstChild('PP') or inBed:FindFirstChildWhichIsA('ProximityPrompt', true)
end

-- 🎯 FOXNAME ag: Find patient for room name who has an enabled prompt
local function FindPatientByRoomName(roomName)
    local ok, npcs = GetNpcSnapshot()
    if not ok then return nil, nil end
    local primaryPP = GetRoomPrimaryPrompt(roomName)
    if not primaryPP then return nil, nil end
    local roomPos = GetPromptPosition(primaryPP)
    if not roomPos then return nil, nil end

    for _, npc in ipairs(npcs) do
        if not npc:GetAttribute('IsVisitor') then
            if (npc:GetAttribute('IsPatient') == true or npc:GetAttribute('Skinwalker') == true) and not IsRecentlyTreated(npc) then
                local root = npc:FindFirstChild('HumanoidRootPart') or npc:FindFirstChild('Torso')
                if root then
                    local isDes = npc:GetAttribute('DesignatedRoom') == roomName
                    local inBed = npc:GetAttribute('InBed') == true
                    local delta = root.Position - roomPos
                    local distSq = delta:Dot(delta)
                    -- 0x310 is 784 (28 studs), 0xe1 is 225 (15 studs)
                    if not IsNearAnyCheckIn(root.Position, 25) and ((isDes and (inBed or distSq < 784)) or distSq < 225) then
                        local pp = npc:FindFirstChild('PP') or GetFirstEnabledNpcPrompt(npc)
                        if pp and pp.Enabled then
                            return npc, pp
                        end
                    end
                end
            end
        end
    end
    return nil, nil
end

-- 🎯 FOXNAME ah: Find patient who needs a DNA sample taken
local function FindDnaPatientForRoom(roomData)
    local ok, npcs = GetNpcSnapshot()
    if not ok then return nil, nil end
    local primaryPP = GetRoomPrimaryPrompt(roomData.Name)
    local roomPos = primaryPP and GetPromptPosition(primaryPP) or roomData.Position
    local bestNpc, bestPP, bestScore = nil, nil, -1

    for _, npc in ipairs(npcs) do
        if not npc:GetAttribute('IsVisitor') then
            if npc:GetAttribute('IsPatient') == true or npc:GetAttribute('Skinwalker') == true then
                local dnaPP = GetTakeDnaSamplePrompt(npc)
                if dnaPP and dnaPP.Enabled then
                    local isDes = npc:GetAttribute('DesignatedRoom') == roomData.Name
                    local inBed = npc:GetAttribute('InBed') == true
                    local root = npc:FindFirstChild('HumanoidRootPart') or npc:FindFirstChild('Torso')
                    local delta = root and roomPos and (root.Position - roomPos)
                    local isNear = delta and delta:Dot(delta) <= 1225 -- 35 studs
                    if (isDes or isNear) and root and not IsNearAnyCheckIn(root.Position, 25) then
                        local score = 0
                        if isDes then score = score + 4 end
                        if inBed then score = score + 2 end
                        if isNear then score = score + 1 end
                        if score > bestScore then
                            bestNpc, bestPP, bestScore = npc, dnaPP, score
                        end
                    end
                end
            end
        end
    end
    return bestNpc, bestPP
end

local function IsVisibleHighlight(h)
    if not h or not h:IsA("Highlight") or h.Enabled == false then return false end
    local ft = h.FillTransparency == nil or h.FillTransparency < 1
    local ot = h.OutlineTransparency == nil or h.OutlineTransparency < 1
    return ft or ot
end

local function IsLightBlueTreatmentColor(c)
    if not c then return false end
    return math.abs(c.R * 255 - 85) <= 15 and math.abs(c.G * 255 - 250) <= 15 and math.abs(c.B * 255 - 255) <= 15
end

local function HasReadyPatientHighlight(npc)
    if not npc then return false end
    local ok, res = pcall(function()
        for _, obj in ipairs(npc:GetDescendants()) do
            if IsVisibleHighlight(obj) then
                if IsLightBlueTreatmentColor(obj.FillColor) or IsLightBlueTreatmentColor(obj.OutlineColor) then
                    return true
                end
                return true
            end
        end
        return false
    end)
    return ok and res == true
end

-- 🎯 FOXNAME ai: Find patient who needs treatment items applied
local function FindTreatmentPatientForRoom(roomData)
    local ok, npcs = GetNpcSnapshot()
    if not ok then return nil, nil end
    local hasWork = (GetMonitorIllnessCount(roomData) > 0) or (CountNeededTreatmentItems(roomData, true) > 0)
    local rName = roomData.Name
    local primaryPP = GetRoomPrimaryPrompt(rName)
    local roomPos = primaryPP and GetPromptPosition(primaryPP) or roomData.Position
    local bestNpc, bestPP, bestScore = nil, nil, -1

    for _, npc in ipairs(npcs) do
        if not npc:GetAttribute('IsVisitor') then
            if (npc:GetAttribute('IsPatient') == true or npc:GetAttribute('Skinwalker') == true) and not IsRecentlyTreated(npc) then
                local isDes = npc:GetAttribute('DesignatedRoom') == rName
                local hasHl = HasReadyPatientHighlight(npc)
                local inBed = npc:GetAttribute('InBed') == true
                local root = npc:FindFirstChild('HumanoidRootPart') or npc:FindFirstChild('Torso')
                local delta = root and roomPos and (root.Position - roomPos)
                local isNear = delta and delta:Dot(delta) <= 1225 -- 35 studs
                if root and not IsNearAnyCheckIn(root.Position, 25) and ((isDes and (inBed or isNear)) or (isNear and hasHl) or (isNear and hasWork and inBed)) then
                    local pp = npc:FindFirstChild('PP') or GetFirstEnabledNpcPrompt(npc)
                    local score = 0
                    if isDes then score = score + 4 end
                    if hasHl then score = score + 3 end
                    if hasWork then score = score + 2 end
                    if inBed then score = score + 1 end
                    if pp and pp.Enabled and score > bestScore then
                        bestNpc, bestPP, bestScore = npc, pp, score
                    end
                end
            end
        end
    end
    return bestNpc, bestPP
end

-- 🎯 FOXNAME aj / ak: Room 8 surgery prompts
local function GetRoom8SurgeryStartPrompt(rName)
    rName = rName or 'Room8'
    local ok, pp = pcall(function() return Workspace.Rooms.Emergency[rName].Minigame.Bed.InBed.PP2 end)
    if ok and pp and pp:IsA('ProximityPrompt') and pp.Enabled then return pp end
    return nil
end

local function GetRoom8SurgeryMidPrompt(rName)
    rName = rName or 'Room8'
    local ok, pp = pcall(function() return Workspace.Rooms.Emergency[rName].Minigame.Bed.InBed.PP end)
    if ok and pp and pp:IsA('ProximityPrompt') and pp.Enabled then return pp end
    return nil
end

-- 🎯 FOXNAME al: Find patient specifically for surgery prompt
local function FindSurgeryPatient(roomData, prompt)
    local p, pp = FindTreatmentPatientForRoom(roomData)
    if p then return p, pp or prompt end
    p, pp = FindPatientByRoomName(roomData.Name)
    if p then return p, pp or prompt end

    local ok, npcs = GetNpcSnapshot()
    if not ok then return nil, nil end
    local roomPos = GetPromptPosition(prompt) or roomData.Position
    local bestNpc, bestScore = nil, -1

    for _, npc in ipairs(npcs) do
        if not npc:GetAttribute('IsVisitor') then
            if (npc:GetAttribute('IsPatient') == true or npc:GetAttribute('Skinwalker') == true) and not IsRecentlyTreated(npc) then
                local root = npc:FindFirstChild('HumanoidRootPart') or npc:FindFirstChild('Torso')
                local isDes = npc:GetAttribute('DesignatedRoom') == roomData.Name
                local inBed = npc:GetAttribute('InBed') == true
                local delta = root and roomPos and (root.Position - roomPos)
                local isNear = delta and delta:Dot(delta) <= 1600 -- 40 studs (0x640)
                if root and not IsNearAnyCheckIn(root.Position, 25) and ((isDes and (inBed or isNear)) or (inBed and isNear) or isNear) then
                    local score = 0
                    if isDes then score = score + 4 end
                    if inBed then score = score + 3 end
                    if isNear then score = score + 1 end
                    if score > bestScore then
                        bestNpc, bestScore = npc, score
                    end
                end
            end
        end
    end
    if bestNpc then
        return bestNpc, bestNpc:FindFirstChild('PP') or GetFirstEnabledNpcPrompt(bestNpc) or prompt
    end
    return nil, nil
end

-- Legacy wrapper for any external callers
local function FindPatientForRoom(roomData)
    local p, pp = FindDnaPatientForRoom(roomData)
    if not p then p, pp = FindTreatmentPatientForRoom(roomData) end
    if not p then p, pp = FindPatientByRoomName(roomData.Name) end
    return p, pp
end

local function AutoTreatmentCoordinator(urgentOnly)
    if not _G.AutoTreatment or StopCheck() then return false end

    -- 1. Check for burning patients (FirePP)
    local ok, npcs = GetNpcSnapshot()
    if ok then
        for _, npc in ipairs(npcs) do
            if StopCheck() then return false end
            local firePP = npc:FindFirstChild('FirePP')
            local root = npc:FindFirstChild('HumanoidRootPart')
            local counterUI = root and root:FindFirstChild('Counter') and root.Counter:FindFirstChild('UI')
            local img = counterUI and counterUI:FindFirstChild('Image')

            if firePP and firePP.Enabled then
                if firePP.ActionText ~= 'Treat Burns' then
                    Log('AutoTreatment', 'Pressing FirePP (Extinguish)', { npc = npc.Name, actionText = firePP.ActionText })
                    PressTreatmentPromptNearbyUntil(firePP, 0.25, 3.0, function()
                        return not firePP.Parent or not firePP.Enabled or firePP.ActionText == 'Treat Burns'
                    end)
                    task.wait(0.5)
                    return true
                else
                    local assetId = img and img.Image ~= '' and string.match(img.Image, '%d+')
                    local remedyItem = nil
                    if assetId then
                        for mapId, name in pairs(AilmentAssetMap) do
                            if string.find(mapId, assetId) or string.find(assetId, mapId) then
                                remedyItem = name
                                break
                            end
                        end
                    end

                    if remedyItem then
                        Log('AutoTreatment', 'Patient needs treat burns item', { npc = npc.Name, item = remedyItem })
                        if GetItemCount(remedyItem) == 0 then
                            local itemPP = GetItemPP(remedyItem)
                            if itemPP then
                                local countBefore = GetItemCount(remedyItem)
                                PressTreatmentPromptNearbyUntil(itemPP, 0.12, 1.2, function() return GetItemCount(remedyItem) > countBefore end)
                                local t = os.clock()
                                while os.clock() - t < 0.8 and not StopCheck() do
                                    if GetItemCount(remedyItem) > countBefore then break end
                                    task.wait(0.03)
                                end
                                task.wait(0.1)
                            end
                        end

                        if GetItemCount(remedyItem) > 0 then
                            UseInventoryTool(remedyItem)
                            task.wait(0.2)
                            Log('AutoTreatment', 'Treating burning patient with item', { npc = npc.Name, item = remedyItem })
                            PressTreatmentPromptNearbyUntil(firePP, 0.25, 3.0, function()
                                return not firePP.Parent or not firePP.Enabled or GetItemCount(remedyItem) == 0 or firePP.ActionText ~= 'Treat Burns'
                            end)
                            task.wait(0.5)
                            return true
                        end
                    end
                end
            end
        end
    end

    -- 2. Iterate rooms according to exact Foxname order: {6, 7, 8} if urgent, {6, 7, 8, 1, 2, 3, 4, 5} if normal
    local roomOrder = urgentOnly and {6, 7, 8} or {6, 7, 8, 1, 2, 3, 4, 5}

    for _, rIdx in ipairs(roomOrder) do
        RunService.Heartbeat:Wait()
        if not _G.AutoTreatment or StopCheck() then return false end

        local roomData = _G.AH_RoomData[rIdx]
        local patient, patientPrompt = nil, nil

        if roomData.Name == 'Room8' then
            local startPP = GetRoom8SurgeryStartPrompt(roomData.Name)
            local midPP = GetRoom8SurgeryMidPrompt(roomData.Name)
            if startPP then
                Log('AutoTreatment', 'Found surgery start prompt', { room = roomData.Name, prompt = startPP:GetFullName() })
                patient, patientPrompt = FindSurgeryPatient(roomData, startPP)
                if not patient then
                    Log('AutoTreatment', 'No surgery patient found; pressing start prompt', { room = roomData.Name, prompt = startPP:GetFullName() })
                    PressTreatmentPromptNearbyUntil(startPP, 0.25, 3.0, function()
                        return not startPP.Parent or not startPP.Enabled or CountNeededTreatmentItems(roomData, true) > 0
                    end)
                    return true
                end
            elseif midPP then
                Log('AutoTreatment', 'Found mid-surgery Apply Treatment prompt', { room = roomData.Name, prompt = midPP:GetFullName() })
                patient, patientPrompt = FindSurgeryPatient(roomData, midPP)
                if not patient then patient, patientPrompt = FindPatientByRoomName(roomData.Name) end
                if not patientPrompt then patientPrompt = midPP end
            else
                patient, patientPrompt = FindDnaPatientForRoom(roomData)
            end
        elseif roomData.Name == 'Room6' or roomData.Name == 'Room7' then
            local startPP = nil
            if roomData.Name == 'Room7' then
                startPP = GetRoom8SurgeryStartPrompt(roomData.Name)
            else
                local ok, xmonPP = pcall(function() return Workspace.Rooms.Emergency.Room6.Minigame.xrayMonitor.PP end)
                if ok and xmonPP and xmonPP:IsA('ProximityPrompt') and xmonPP.Enabled then startPP = xmonPP end
            end

            local folder = roomData.Emergency and Workspace.Rooms.Emergency or Workspace.Rooms.Medical
            local rModel = folder:FindFirstChild(roomData.Name)
            local mg = rModel and rModel:FindFirstChild('Minigame')
            local xresultPP = GetPrintedXRayPrompt(mg)
            local pRoom, pRoomPP = FindPatientByRoomName(roomData.Name)

            if roomData.Name == 'Room6' and not startPP and pRoom then
                local dna = GetTakeDnaSamplePrompt(pRoom)
                if dna and dna.Enabled then startPP = dna end
            end

            if startPP then
                patientPrompt = startPP
                patient = pRoom
            elseif xresultPP and xresultPP.Enabled then
                patientPrompt = xresultPP
                patient = pRoom
                Log('AutoTreatment', 'xresult is enabled for room, treating room', { room = roomData.Name, npc = patient and patient.Name, prompt = patientPrompt:GetFullName() })
            elseif pRoom then
                patient = pRoom
                patientPrompt = pRoomPP
            end
        else
            -- ROOMS 1 - 5 (MEDICAL ROOMS)
            patient, patientPrompt = FindDnaPatientForRoom(roomData)
            if not patient then
                patient, patientPrompt = FindTreatmentPatientForRoom(roomData)
            end
            if not patient then
                patient, patientPrompt = FindPatientByRoomName(roomData.Name)
            end
        end

        -- Inactive recovery room skip (exact Foxname J(bf))
        if not patient and not patientPrompt and IsRoomRecovering(roomData) then
            Log('AutoTreatment', 'Skipping inactive recovery room', { room = roomData.Name })
        elseif patient or (patientPrompt and (roomData.Name == 'Room6' or roomData.Name == 'Room7')) then
            if not IsRoomRecovering(roomData) then
                Log('AutoTreatment', 'Found patient for room (or start prompt)', { room = roomData.Name, npc = patient and patient.Name, prompt = patientPrompt and patientPrompt:GetFullName() })
                local ok, res = pcall(ExecutePatientTreatment, patient, patientPrompt, roomData)
                if not ok then
                    LogError('AutoTreatment', 'Patient treatment cycle crashed', { error = res, room = roomData.Name }, true)
                    if patient then _G.AH_TreatedPatients[patient] = os.clock() end
                    return false
                end
                return res == true
            end
        end
    end

    return false
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🛡️ SHUTTER LOGIC ENGINE (CANONICAL aB WITH LEAVING DETECTION)
-- ══════════════════════════════════════════════════════════════════════════════════
local function GetShutterButtonPP()
    local misc = Workspace:FindFirstChild("Misc")
    local btn = misc and misc:FindFirstChild("ShutterButton")
    return btn and (btn:FindFirstChild("PP") or btn:FindFirstChildWhichIsA("ProximityPrompt", true))
end

local function IsShutterClosed()
    local pp = GetShutterButtonPP()
    if not pp then return nil end
    return string.lower(tostring(pp.ActionText or "")) == "open"
end

local function SetShutterClosed(shouldBeClosed)
    local pp = GetShutterButtonPP()
    if not pp or not pp.Enabled or StopCheck() then return false end
    local isClosed = IsShutterClosed()
    if isClosed == nil or isClosed == shouldBeClosed then return false end
    return PressPromptNearby(pp, 0.45)
end

local function IsThreatNpc(npc)
    return npc and ((_G.AutoBarneyShutter and IsBarneyNpc(npc)) or (_G.AutoAnomalyShutter and npc:GetAttribute("Skinwalker") == true))
end

local LeavingAnimationIds = { ["rbxassetid://88351809285459"] = true }
local _AH_SeenAnims = setmetatable({}, { __mode = "k" })
local _AH_ThreatState = {}

local function IsThreatLeaving(npc)
    if not npc or npc:GetAttribute("Skinwalker") ~= true then return false end
    local hum = npc:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
        local anim = track.Animation
        local animId = anim and anim.AnimationId or ""
        local isKnown = LeavingAnimationIds[animId] == true
        local isAction = track.Priority == Enum.AnimationPriority.Action and not track.Looped
        if isKnown or isAction then
            if not _AH_SeenAnims[track] then
                _AH_SeenAnims[track] = true
                Log("AutoShutter", "Detected anomaly leave animation", { npc = npc.Name, animId = animId })
            end
            return true
        end
    end
    return false
end

local function GetCounterNpcAndThreat()
    local ok, npcs = GetNpcSnapshot()
    local btn = Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("ShutterButton") and Workspace.Misc.ShutterButton:FindFirstChild("Button")
    if not ok or not btn then return nil, false end
    local closestNpc, closestDist, isThreat = nil, 35, false
    for _, npc in ipairs(npcs) do
        local root = npc:FindFirstChild("HumanoidRootPart")
        if root then
            local dist = (root.Position - btn.Position).Magnitude
            local threat = IsThreatNpc(npc)
            if dist < closestDist then
                closestNpc = npc
                closestDist = dist
                isThreat = threat
            end
        end
    end
    return closestNpc, isThreat
end

local function CloseShutterForThreat()
    if not (_G.AutoBarneyShutter or _G.AutoAnomalyShutter) then return false end
    local npc, isThreat = GetCounterNpcAndThreat()
    local now = os.clock()
    if not npc then return false end

    local root = npc:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    local state = _AH_ThreatState[npc]
    if not state then
        local btn = Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("ShutterButton") and Workspace.Misc.ShutterButton:FindFirstChild("Button")
        state = {
            Pos = root.Position,
            Time = now,
            Distance = btn and (root.Position - btn.Position).Magnitude or nil,
            ClosedByScript = false,
            Leaving = false
        }
        _AH_ThreatState[npc] = state
        return false
    end

    local btn = Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("ShutterButton") and Workspace.Misc.ShutterButton:FindFirstChild("Button")
    local dist = btn and (root.Position - btn.Position).Magnitude or nil
    local closed = IsShutterClosed() == true

    if isThreat and IsThreatLeaving(npc) then
        state.Leaving = true
    elseif isThreat and IsBarneyNpc(npc) and closed and dist and state.Distance and dist > state.Distance + 0.3 then
        state.Leaving = true
        Log("AutoShutter", "Detected Barney moving away from shutter", { npc = npc.Name, distance = dist })
    end
    state.Distance = dist

    if state.Leaving then
        if closed then
            Log("AutoShutter", "Opening shutter for departing threat", { npc = npc.Name })
            SetShutterClosed(false)
        end
        return true
    end

    local moved = (root.Position - state.Pos).Magnitude
    if moved > 0.15 then
        state.Pos = root.Position
        state.Time = now
        if isThreat then
            if not closed and SetShutterClosed(true) then
                Log("AutoShutter", "Closed shutter for moving threat", { npc = npc.Name })
                state.ClosedByScript = true
                return true
            end
            return false
        end
        if state.ClosedByScript then
            state.ClosedByScript = false
            _AH_ThreatState[npc] = nil
            return SetShutterClosed(false)
        end
        return false
    end

    if isThreat and now - state.Time >= 0.6 then
        if not closed then
            if SetShutterClosed(true) then
                Log("AutoShutter", "Closed shutter for threat", { npc = npc.Name })
                state.ClosedByScript = true
                return true
            end
        end
    elseif not isThreat and closed then
        _AH_ThreatState[npc] = nil
        Log("AutoShutter", "Opening shutter after non-threat/movement", { npc = npc.Name })
        return SetShutterClosed(false)
    end
    return false
end

local function OpenShutterIfSafe()
    if not (_G.AutoBarneyShutter or _G.AutoAnomalyShutter) then return false end
    if IsShutterClosed() ~= true then return false end
    if HasNormalPatientAtCheckIn() then
        Log("AutoShutter", "Opening shutter for normal patient at check-in")
        return SetShutterClosed(false)
    end
    local npc, isThreat = GetCounterNpcAndThreat()
    if not npc or not isThreat then
        Log("AutoShutter", "Opening shutter: counter area clear")
        return SetShutterClosed(false)
    end
    return false
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🚪 AUTO ASK LEAVE ANOMALY
-- ══════════════════════════════════════════════════════════════════════════════════
local _AH_AskLeaveCooldowns = {}

local function AutoAskLeaveAnomaly()
    if not _G.AutoAskLeaveAnomaly or StopCheck() then return false end
    local ok, npcs = GetNpcSnapshot()
    if not ok then return false end

    for _, npc in ipairs(npcs) do
        local p = ScanNpcPrompts(npc).AskLeave
        if p and p.Parent and p.Enabled then
            local now = os.clock()
            if not _AH_AskLeaveCooldowns[p] or now - _AH_AskLeaveCooldowns[p] >= 6.0 then
                _AH_AskLeaveCooldowns[p] = now
                Log("AutoAskLeaveAnomaly", "Pressing Ask To Leave prompt", { npc = npc.Name, prompt = p:GetFullName() })
                PressPromptNearby(p, 0.5)
                return true
            end
        end
    end
    return false
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🧯 AUTO PUT OUT FIRE
-- ══════════════════════════════════════════════════════════════════════════════════
local _AH_LastFireCheck = 0

local function AutoPutOutFire()
    if not _G.AutoPutOutFire or StopCheck() then return false end
    local now = os.clock()
    if now < _AH_LastFireCheck then return false end
    _AH_LastFireCheck = now + 0.75

    local rooms = Workspace:FindFirstChild("Rooms")
    if not rooms then return false end

    for _, cat in ipairs(rooms:GetChildren()) do
        for _, room in ipairs(cat:GetChildren()) do
            for _, p in ipairs(room:GetDescendants()) do
                if p:IsA("ProximityPrompt") and p.Enabled and string.find(string.lower(p.ActionText or ""), "put out fire") then
                    Log("AutoPutOutFire", "Putting out fire in room", { room = room.Name, prompt = p:GetFullName() })
                    PressPromptNearbyUntil(p, 0.25, 3.0, function() return not p.Parent or not p.Enabled end)
                    return true
                end
            end
        end
    end
    return false
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- ☕ COFFEE ENGINE (SANITY AUTO-COFFEE & BARNEY 2-SIP DELIVERY)
-- ══════════════════════════════════════════════════════════════════════════════════
local _AH_LastCoffeeGrab = 0
local _AH_LastBarneyCoffee = 0

local function IsCoffeeMachineReady(machine)
    if not machine then return false end
    local coffee = machine:FindFirstChild("Coffee")
    local pp = coffee and (coffee:FindFirstChild("PP") or coffee:FindFirstChildWhichIsA("ProximityPrompt", true))
    if not (pp and pp.Enabled) then return false end
    local status = machine:FindFirstChild("status", true)
    if status and status:IsA("TextLabel") then
        return string.find(string.lower(status.Text), "ready") ~= nil
    end
    return true
end

local function GetReadyCoffeePrompt()
    local misc = Workspace:FindFirstChild("Misc")
    local cm1 = misc and misc:FindFirstChild("CoffeeMachine")
    local cm2 = Workspace:FindFirstChild("CoffeeMachine2")
    if cm1 and IsCoffeeMachineReady(cm1) then return cm1.Coffee.PP end
    if cm2 and IsCoffeeMachineReady(cm2) then return cm2.Coffee.PP end
    return nil
end

local function DrinkCoffeeSips(tool, sips)
    if not tool or not tool:IsA("Tool") then return false end
    local char, root = GetCharacter()
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    hum:EquipTool(tool)
    task.wait(0.1)
    for i = 1, (sips or 1) do
        if not tool or not tool.Parent then break end
        Log("AutoCoffee", "Drinking coffee sip", { sip = i, totalSips = sips })
        pcall(function() tool:Activate() end)
        if i < (sips or 1) then task.wait(1.5) end
    end
    task.wait(0.2)
    return true
end

local function AutoCoffeeSanity()
    if not _G.AutoCoffee or StopCheck() then return false end
    local now = os.clock()
    if now - _AH_LastCoffeeGrab < 5.0 then return false end

    local sanity = LocalPlayer:GetAttribute("Sanity")
    if typeof(sanity) == "string" then sanity = tonumber(sanity) end
    local threshold = _G.CoffeeSanityThreshold or _G.SanityThreshold or 40

    if sanity and sanity < threshold then
        local tool = GetInventoryTool("Coffee")
        if not tool then
            local coffeePP = GetReadyCoffeePrompt()
            if coffeePP then
                Log("AutoCoffee", "Sanity low, grabbing ready coffee", { sanity = sanity, threshold = threshold })
                PressPromptNearby(coffeePP, 0.4, Vector3.new(0, 1.5, 0), 0.2)
                task.wait(0.2)
                tool = GetInventoryTool("Coffee")
            end
        end

        if tool then
            _AH_LastCoffeeGrab = os.clock()
            Log("AutoCoffee", "Drinking coffee for sanity", { sanity = sanity })
            DrinkCoffeeSips(tool, 3)
            return true
        end
    end
    return false
end

local function AutoGiveBarneyCoffee()
    if not _G.AutoGiveBarneyCoffee or StopCheck() then return false end
    local now = os.clock()
    if now - _AH_LastBarneyCoffee < 3.0 then return false end

    local npcs = Workspace:FindFirstChild("NPCs")
    if not npcs then return false end

    local barney, barneyPP = nil, nil
    for _, npc in ipairs(npcs:GetChildren()) do
        if npc.Name == "Barney" then
            local pp = npc:FindFirstChildWhichIsA("ProximityPrompt", true)
            if pp and pp.Enabled then
                barney = npc
                barneyPP = pp
                break
            end
        end
    end

    if barney and barneyPP then
        Log("AutoBarneyCoffee", "Found Barney needing coffee", { npc = barney.Name, prompt = barneyPP:GetFullName() })
        local tool = GetInventoryTool("Coffee")
        if not tool then
            local coffeePP = GetReadyCoffeePrompt()
            if coffeePP then
                Log("AutoBarneyCoffee", "Grabbing coffee for Barney", { prompt = coffeePP:GetFullName() })
                PressPromptNearby(coffeePP, 0.4, Vector3.new(0, 1.5, 0), 0.2)
                task.wait(0.2)
                tool = GetInventoryTool("Coffee")
            else
                return false
            end
        end

        if tool then
            -- 🌟 ВЫПИВАЕМ 2 РАЗА ПЕРЕД ПЕРЕДАЧЕЙ БАРНИ
            Log("AutoBarneyCoffee", "Drinking coffee 2 times before giving to Barney")
            DrinkCoffeeSips(tool, 2)

            tool = GetInventoryTool("Coffee")
            if not tool then
                Log("AutoBarneyCoffee", "Coffee fully consumed during sips")
                return true
            end

            EquipToolOnly(tool)
            task.wait(0.15)
            _AH_LastBarneyCoffee = os.clock()
            Log("AutoBarneyCoffee", "Giving coffee to Barney", { prompt = barneyPP:GetFullName() })
            PressPromptNearby(barneyPP, 0.4, Vector3.new(0, 1.5, 0), 0.2)
            task.wait(0.2)
            return true
        end
    end
    return false
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🚑 AUTO HELP FAINTED PATIENTS
-- ══════════════════════════════════════════════════════════════════════════════════
local _AH_LastHelpCheck = 0

local function AutoHelpPatient()
    if not _G.AutoHelpPatient or StopCheck() then return false end
    local now = os.clock()
    if now < _AH_LastHelpCheck then return false end
    _AH_LastHelpCheck = now + 0.5

    local ok, npcs = GetNpcSnapshot()
    if not ok then return false end

    for _, npc in ipairs(npcs) do
        if not npc:GetAttribute("IsVisitor") then
        if npc:GetAttribute("IsPatient") == true or npc:GetAttribute("Skinwalker") == true or npc:GetAttribute("AlwaysFaints") == true then
            local helpPP = ScanNpcPrompts(npc).Help
            if helpPP and helpPP.Parent and helpPP.Enabled then
                Log("AutoHelpPatient", "Found help prompt for fainted patient", { npc = npc.Name, prompt = helpPP:GetFullName() })
                if PressPromptNearby(helpPP, 0.45) then return true end
            end
        end
        end
    end
    return false
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🛒 AUTO BUY SHOP
-- ══════════════════════════════════════════════════════════════════════════════════
local _AH_LastShopCheck = 0

local function AutoBuyShop()
    if not _G.AutoBuyShop or StopCheck() then return false end
    local now = os.clock()
    if now < _AH_LastShopCheck then return false end
    _AH_LastShopCheck = now + 1.0

    local shop = Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("ShopItems")
    if not shop then return false end

    for _, item in ipairs(shop:GetChildren()) do
        if StopCheck() or not _G.AutoBuyShop then return true end
        local pp = item:FindFirstChildWhichIsA("ProximityPrompt", true)
        if pp and pp.Enabled then
            Log("AutoBuyShop", "Buying shop item", { item = item.Name, prompt = pp:GetFullName() })
            PressPromptNearby(pp, 0.35, Vector3.new(0, 1.5, 0), 0.15)
            return true
        end
    end
    return false
end

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🧵 BACKGROUND WORKERS (CAMERAS, SLIME, TASER)
-- ══════════════════════════════════════════════════════════════════════════════════
local _AH_LastSlimeTime = 0
local _AH_LastCamTime = 0

local function AutoCleanSlimeTask()
    if not _G.AutoCleanSlime or StopCheck() then return end
    local now = os.clock()
    if now - _AH_LastSlimeTime < 1.5 then return end

    local slime = Workspace:FindFirstChild("Misc") and Workspace.Misc:FindFirstChild("Slime")
    local pp = slime and (slime:FindFirstChild("PP") or slime:FindFirstChildWhichIsA("ProximityPrompt", true))
    if pp and pp.Enabled then
        _AH_LastSlimeTime = now
        Log("AutoCleanSlime", "Cleaning slime", { prompt = pp:GetFullName() })
        PressPromptNearbyUntil(pp, 0.35, 3.0, function() return not slime.Parent or not pp.Parent or not pp.Enabled end)
    end
end

local function AutoFixCamTask()
    if not _G.AutoFixCam or StopCheck() then return end
    local now = os.clock()
    if now - _AH_LastCamTime < 3.0 then return end

    local misc = Workspace:FindFirstChild("Misc")
    local cams = misc and (misc:FindFirstChild("Cameras") or misc:FindFirstChild("Cameras2"))
    if not cams then return end

    for _, p in ipairs(cams:GetDescendants()) do
        if p:IsA("ProximityPrompt") and p.Enabled then
            _AH_LastCamTime = now
            Log("AutoFixCam", "Fixing camera", { prompt = p:GetFullName() })
            PressPromptNearby(p, 0.45)
            break
        end
    end
end

-- Worker 1: Cameras and Slime
task.spawn(function()
    while IsSessionActive() do
        if StopCheck() then break end
        pcall(AutoCleanSlimeTask)
        pcall(AutoFixCamTask)
        task.wait(0.1)
    end
end)

-- Worker 2: AutoTaser with Remote
task.spawn(function()
    while IsSessionActive() do
        if StopCheck() then break end
        if _G.AutoTaser then
            local utilNet = ReplicatedStorage:FindFirstChild("Util") and ReplicatedStorage.Util:FindFirstChild("Net")
            local taserRemote = utilNet and utilNet:FindFirstChild("RE/TaserFired")
            local npcs = Workspace:FindFirstChild("NPCs")
            local misc = Workspace:FindFirstChild("Misc")
            local tStation = misc and misc:FindFirstChild("TaserStation")
            local tMain = tStation and tStation:FindFirstChild("Main")
            local tPP = tMain and tMain:FindFirstChild("PP")

            if taserRemote and npcs and tPP then
                for _, npc in ipairs(npcs:GetChildren()) do
                    if not _G.AutoTaser or StopCheck() then break end
                    local isSkin = npc:GetAttribute("Skinwalker") == true
                    local isTasered = npc:GetAttribute("FoxnameTasered")
                    if isSkin and (not isTasered or (type(isTasered) == "number" and os.clock() - isTasered > 15)) then
                        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local origCF = root and root.CFrame
                        local hasTaser = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Taser")) or
                                         (LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Taser"))

                        if not hasTaser and root and tMain then
                            root.CFrame = tMain.CFrame * CFrame.new(0, 0, 3)
                            task.wait(0.4)
                            pcall(function() fireproximityprompt(tPP) end)
                            task.wait(0.2)
                        end

                        local bpTaser = LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Taser")
                        if bpTaser and LocalPlayer.Character then bpTaser.Parent = LocalPlayer.Character end

                        for _ = 1, 50 do
                            if not _G.AutoTaser or StopCheck() then break end
                            task.wait(0.05)
                            pcall(function() taserRemote:FireServer(npc) end)
                        end

                        if npc and npc.Parent then npc:SetAttribute("FoxnameTasered", os.clock()) end
                        if root and origCF and not hasTaser then
                            root.CFrame = origCF
                            task.wait(0.1)
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- ══════════════════════════════════════════════════════════════════════════════════
-- 🌐 THIRD PERSON & UTILITIES
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
-- 🎨 NATIVE OBSIDIAN LUXURY GUI & KEYBINDS
-- ══════════════════════════════════════════════════════════════════════════════════
local GuiParent = nil
pcall(function() GuiParent = gethui and gethui() end)
if not GuiParent then pcall(function() GuiParent = CoreGui end) end
if not GuiParent then GuiParent = LocalPlayer:WaitForChild("PlayerGui") end

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
Title.Text = "🏥 Averlik Hub | Animal Hospital v32.0 [P: Мышь | G: Меню]"
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

-- Create Tabs & Controls
local TabAuto = CreateTab("Автоматизация", "⚡")
local TabSafe = CreateTab("Защита", "🛡️")
local TabMisc = CreateTab("Утилиты", "🌐")

-- Вкладка: Автоматизация
AddToggle(TabAuto, "🏥 Авто-Лечение (Палаты 1 - 8)", _G.AutoTreatment, function(v) _G.AutoTreatment = v end)
AddToggle(TabAuto, "🏢 Авто-Регистрация (Ресепшен)", _G.AutoCheckIn, function(v) _G.AutoCheckIn = v end)
AddToggle(TabAuto, "☕ Авто-Кофе (Пополнение рассудка)", _G.AutoCoffee, function(v) _G.AutoCoffee = v end)
AddSlider(TabAuto, "Порог рассудка для кофе (%)", 20, 90, 40, function(v) _G.CoffeeSanityThreshold = v _G.SanityThreshold = v end)
AddToggle(TabAuto, "☕ Кофе для Барни (2 глотка перед отдачей)", _G.AutoGiveBarneyCoffee, function(v) _G.AutoGiveBarneyCoffee = v end)
AddToggle(TabAuto, "🚑 Спасение упавших пациентов", _G.AutoHelpPatient, function(v) _G.AutoHelpPatient = v end)
AddToggle(TabAuto, "🧯 Авто-Тушение пожаров", _G.AutoPutOutFire, function(v) _G.AutoPutOutFire = v end)
AddToggle(TabAuto, "🧼 Авто-Уборка слизи", _G.AutoCleanSlime, function(v) _G.AutoCleanSlime = v end)
AddToggle(TabAuto, "📹 Авто-Починка камер", _G.AutoFixCam, function(v) _G.AutoFixCam = v end)
AddToggle(TabAuto, "🛒 Авто-Покупка в магазине", _G.AutoBuyShop, function(v) _G.AutoBuyShop = v end)

-- Вкладка: Защита
AddToggle(TabSafe, "🛑 Авто-Шторка от Аномалий", _G.AutoAnomalyShutter, function(v) _G.AutoAnomalyShutter = v end)
AddToggle(TabSafe, "🚪 Авто-Шторка от Барни", _G.AutoBarneyShutter, function(v) _G.AutoBarneyShutter = v end)
AddToggle(TabSafe, "🗣️ Выгонять аномалии (Ask To Leave)", _G.AutoAskLeaveAnomaly, function(v) _G.AutoAskLeaveAnomaly = v end)
AddToggle(TabSafe, "☠️ Устранять скинвокеров (Летальные)", _G.AutoKillAnomaly, function(v) _G.AutoKillAnomaly = v end)
AddToggle(TabSafe, "⚡ Авто-Тазер аномалий", _G.AutoTaser, function(v) _G.AutoTaser = v end)

-- Вкладка: Утилиты
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
-- 🔄 1-TO-1 CANONICAL COORDINATED PRIORITY LOOP (FOXNAME HEARTBEAT ENGINE)
-- ══════════════════════════════════════════════════════════════════════════════════
local _AH_TaskCooldowns = {}

local function RunPriorityTask(taskName, enabled, taskFunc, crashMessage)
    if not enabled then return false end
    local ok, res = pcall(taskFunc)
    if not ok then
        local now = os.clock()
        if now - (_AH_TaskCooldowns[taskName] or 0) >= 3.0 then
            _AH_TaskCooldowns[taskName] = now
            LogError(taskName, crashMessage or "Cycle crashed", { error = res }, true)
        end
    elseif res then
        task.wait(0.1)
        return true
    end
    return false
end

task.spawn(function()
    Log("Loop", "Averlik Hub Animal Hospital Engine Started", { sessionId = MySession })

    local nextUrgentCheck = 0
    local nextGeneralTreatment = 0
    local nextHeartbeatLog = 0

    while IsSessionActive() do
        local taskExecuted = false
        repeat
            RunService.Heartbeat:Wait()
            if StopCheck() then break end

        -- WalkSpeed
        if _G.WalkSpeedValue and _G.WalkSpeedValue ~= 16 then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed ~= _G.WalkSpeedValue then hum.WalkSpeed = _G.WalkSpeedValue end
        end

        local now = os.clock()

        -- Heartbeat debug log
        if _G.DebugMode and now - nextHeartbeatLog >= 2.0 then
            nextHeartbeatLog = now
            Log("Loop", "Coordinated loop heartbeat", {
                autoCheckIn = _G.AutoCheckIn,
                autoTreatment = _G.AutoTreatment,
                autoBuyShop = _G.AutoBuyShop,
                autoHelpPatient = _G.AutoHelpPatient,
                autoAskLeaveAnomaly = _G.AutoAskLeaveAnomaly,
                autoCleanSlime = _G.AutoCleanSlime,
                autoBarneyShutter = _G.AutoBarneyShutter,
                autoAnomalyShutter = _G.AutoAnomalyShutter,
                autoGiveBarneyCoffee = _G.AutoGiveBarneyCoffee
            })
        end

        -- 1. URGENT TREATMENT (Rooms 8, 7, 6) every 0.25s
        if _G.AutoTreatment and now >= nextUrgentCheck then
            nextUrgentCheck = now + 0.25
            if RunPriorityTask("AutoTreatment", true, function() return AutoTreatmentCoordinator(true) end, "Urgent cycle crashed") then
                taskExecuted = true break
            end
        end

        -- 2. AUTO ASK LEAVE ANOMALY
        if RunPriorityTask("AutoAskLeaveAnomaly", _G.AutoAskLeaveAnomaly, AutoAskLeaveAnomaly) then
            taskExecuted = true break
        end

        -- 3. CHECK-IN (HAS NORMAL PATIENT AT CHECK-IN)
        local hasDeskPatient = _G.AutoCheckIn and HasNormalPatientAtCheckIn()
        if hasDeskPatient then
            local ok, res = pcall(RunCheckInCycle)
            if not ok then
                LogError("AutoCheckIn", "Cycle crashed", { error = res }, true)
            elseif res then
                task.wait(0.1)
                taskExecuted = true break
            end
        end

        -- 4. SMART SHUTTER (CLOSE FOR THREAT / OPEN IF SAFE)
        if not hasDeskPatient then
            if RunPriorityTask("AutoShutter", _G.AutoBarneyShutter or _G.AutoAnomalyShutter, CloseShutterForThreat, "Closed shutter priority crashed") then
                taskExecuted = true break
            end
            if RunPriorityTask("AutoShutter", _G.AutoBarneyShutter or _G.AutoAnomalyShutter, OpenShutterIfSafe) then
                taskExecuted = true break
            end
        end

        -- 5. AUTO PUT OUT FIRE (PRIORITY)
        if RunPriorityTask("AutoPutOutFire", _G.AutoPutOutFire, AutoPutOutFire, "Priority cycle crashed") then
            taskExecuted = true break
        end

        -- 6. GENERAL TREATMENT (Rooms 1 - 8) every 0.75s
        if _G.AutoTreatment and now >= nextGeneralTreatment then
            nextGeneralTreatment = now + 0.75
            if RunPriorityTask("AutoTreatment", true, function() return AutoTreatmentCoordinator(false) end) then
                taskExecuted = true break
            end
        end

        -- 7. CHECK-IN FALLBACK (When counter area is clear of threats and an NPC is at the counter)
        if _G.AutoCheckIn and not hasDeskPatient and HasAnyNpcAtCheckInCounter() then
            local threatNear = false
            if _G.AutoAnomalyShutter or _G.AutoBarneyShutter then
                local ok, npcs = GetNpcSnapshot()
                if ok then
                    for _, npc in ipairs(npcs) do
                        if IsThreatNpc(npc) then
                            local root = npc:FindFirstChild("HumanoidRootPart")
                            if root and IsNearAnyCheckIn(root.Position, 30) then
                                threatNear = true
                                break
                            end
                        end
                    end
                end
            end
            if not threatNear then
                local ok, res = pcall(RunCheckInCycle)
                if not ok then
                    LogError("AutoCheckIn", "Cycle crashed", { error = res }, true)
                elseif res then
                    task.wait(0.1)
                    taskExecuted = true break
                end
            end
        end

        -- 8. HELP FAINTED PATIENTS
        if RunPriorityTask("AutoHelpPatient", _G.AutoHelpPatient, AutoHelpPatient) then
            taskExecuted = true break
        end

        -- 9. COFFEE FOR SANITY
        if RunPriorityTask("AutoCoffee", _G.AutoCoffee, AutoCoffeeSanity) then
            taskExecuted = true break
        end

        -- 10. BUY SHOP
        if RunPriorityTask("AutoBuyShop", _G.AutoBuyShop, AutoBuyShop) then
            taskExecuted = true break
        end

        -- 11. PUT OUT FIRE (GENERAL)
        if RunPriorityTask("AutoPutOutFire", _G.AutoPutOutFire, AutoPutOutFire) then
            taskExecuted = true break
        end

        -- 12. COFFEE FOR BARNEY
        if RunPriorityTask("AutoGiveBarneyCoffee", _G.AutoGiveBarneyCoffee, AutoGiveBarneyCoffee) then
            taskExecuted = true break
        end

        until true

        if StopCheck() then break end
        if not taskExecuted then
            task.wait(0.15)
        end
    end

    if ScreenGui and ScreenGui.Parent then
        ScreenGui:Destroy()
    end
    Log("Loop", "Session gracefully stopped", { sessionId = MySession })
end)
