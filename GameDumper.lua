-- ══════════════════════════════════════════════════════════════════════════════════════
-- 💾 ANIMAL HOSPITAL COMPLETE HIERARCHY & STRUCTURE DUMPER
-- ══════════════════════════════════════════════════════════════════════════════════════

local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function SerializeInstance(inst, depth, maxDepth)
    if not inst or (depth and depth > (maxDepth or 6)) then return nil end

    local node = {
        name = inst.Name,
        className = inst.ClassName,
        path = inst:GetFullName()
    }

    -- Record Position for BaseParts / Models
    if inst:IsA("BasePart") then
        local p = inst.Position
        node.position = { x = math.round(p.X*100)/100, y = math.round(p.Y*100)/100, z = math.round(p.Z*100)/100 }
    elseif inst:IsA("Model") then
        local ok, cf = pcall(function() return inst:GetPivot() end)
        if ok and cf then
            local p = cf.Position
            node.position = { x = math.round(p.X*100)/100, y = math.round(p.Y*100)/100, z = math.round(p.Z*100)/100 }
        end
    end

    -- Record ProximityPrompt properties
    if inst:IsA("ProximityPrompt") then
        node.prompt = {
            actionText = inst.ActionText,
            objectText = inst.ObjectText,
            enabled = inst.Enabled,
            holdDuration = inst.HoldDuration,
            maxDistance = inst.MaxActivationDistance
        }
    end

    -- Record Attributes
    local attrs = inst:GetAttributes()
    if next(attrs) ~= nil then
        node.attributes = attrs
    end

    -- Record Children
    local children = {}
    for _, child in ipairs(inst:GetChildren()) do
        local serialized = SerializeInstance(child, (depth or 0) + 1, maxDepth)
        if serialized then
            table.insert(children, serialized)
        end
    end
    if #children > 0 then
        node.children = children
    end

    return node
end

local function GenerateTextTree(inst, indent)
    indent = indent or ""
    local line = indent .. inst.Name .. " [" .. inst.ClassName .. "]"
    if inst:IsA("ProximityPrompt") then
        line = line .. " (Prompt: '" .. inst.ActionText .. "', Enabled=" .. tostring(inst.Enabled) .. ")"
    elseif inst:IsA("BasePart") then
        local p = inst.Position
        line = line .. string.format(" (Pos: %.1f, %.1f, %.1f)", p.X, p.Y, p.Z)
    end
    local out = { line }
    for _, child in ipairs(inst:GetChildren()) do
        local childLines = GenerateTextTree(child, indent .. "  ")
        for _, cl in ipairs(childLines) do
            table.insert(out, cl)
        end
    end
    return out
end

print("💾 Начало дампа структуры игры...")

local dumpData = {
    GameId = game.GameId,
    PlaceId = game.PlaceId,
    Time = os.date("%Y-%m-%d %H:%M:%S"),
    Rooms = Workspace:FindFirstChild("Rooms") and SerializeInstance(Workspace.Rooms, 0, 8),
    Items = Workspace:FindFirstChild("Model") and Workspace.Model:FindFirstChild("Items") and SerializeInstance(Workspace.Model.Items, 0, 5),
    Misc = Workspace:FindFirstChild("Misc") and SerializeInstance(Workspace.Misc, 0, 6),
    NPCs = Workspace:FindFirstChild("NPCs") and SerializeInstance(Workspace.NPCs, 0, 5)
}

-- 1. JSON Dump
local jsonStr = HttpService:JSONEncode(dumpData)
if writefile then
    writefile("AnimalHospital_StructureDump.json", jsonStr)
    print("✅ Полный JSON-дамп сохранен: %LOCALAPPDATA%\\Madium\\Workspace\\AnimalHospital_StructureDump.json")
end

-- 2. Clean Text Tree for Rooms
if Workspace:FindFirstChild("Rooms") then
    local treeLines = GenerateTextTree(Workspace.Rooms, "")
    if writefile then
        writefile("AnimalHospital_RoomsTree.txt", table.concat(treeLines, "\n"))
        print("✅ Дерево комнат сохранено: %LOCALAPPDATA%\\Madium\\Workspace\\AnimalHospital_RoomsTree.txt")
    end
end

-- 3. Also try saveinstance if available
if type(saveinstance) == "function" then
    print("💾 Выполняется полный saveinstance() всей игры...")
    pcall(function()
        saveinstance({
            noscripts = false,
            mode = "optimized"
        })
    end)
    print("✅ Карта сохранена в файл .rbxl в папку workspace!")
end

print("🎉 Все дампы успешно созданы!")
