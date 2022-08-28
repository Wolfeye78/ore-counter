Prefix = "Counter" --export: All elements that should be included must have this prefix in the name.
Databank = "Values" --export: The element name of the databank that stores all data from the counters.

local time = require("time")
local command = require("commandHandler")

local core = library.getCoreUnit()
local db = library.getLinkByName(Databank)

All_Elements_Ids = core.getElementIdList()


-- Commands from lua console
system:onEvent("onInputText", commandHandler)


-- Get the first part of a string, case insensitive
local function starts_with(String,Start)
    return string.sub(string.lower(String),1,string.len(string.lower(Start))) == string.lower(Start)
end

-- Check if production is reset because of element restart
local function deltaUnitsProduced (unitId, currentCount)
    local totalUnitsProduced = json.decode(db.getStringValue("TotalProduced")) or {}
    local result = 0
    local previousCount = totalUnitsProduced[unitId] or 0

    if currentCount > previousCount then
        result = currentCount - previousCount
    else
        result = currentCount
    end
    return result
end

local function getUnitsProducedById(id)
    return core.getElementIndustryInfoById(id).unitsProduced
end

-- Create a matrix of element ids and names, but only for names starting with the prefix
local allCounters = {}
local allCountersProduced = {}
local allCountersData_Key = 0

for i in ipairs(All_Elements_Ids) do
    local elementId = All_Elements_Ids[i]
    local elementName = core.getElementNameById(elementId)
    if starts_with(elementName, Prefix) then
        local currentCount = getUnitsProducedById(elementId)
        allCountersData_Key = allCountersData_Key + 1
        allCounters[allCountersData_Key] = {
            id = elementId,
            delta = deltaUnitsProduced(elementId, currentCount)
        }
        allCountersProduced[elementId] = currentCount
    end
end

time = getTime()

-- Write data to new line in Databank
local newDbLine = { time, allCounters }
db.setStringValue(db.getNbKeys() + 1,json.encode(newDbLine))
db.setStringValue("TotalProduced",json.encode(allCountersProduced))

-- Print to screen for debugging
system.print(" - - - - - - - - - - - - - - - - - - -")
system.print("List of records:")

for _, key in pairs(db.getKeyList()) do
    if key ~= "TotalProduced" then
        local data = json.decode(db.getStringValue(key))
        system.print("---- Time: " .. data[1])
        for j in pairs(data[2]) do
            system.print("Id: " .. data[2][j].id .. " --- " .. "Delta: " .. data[2][j].delta)
        end
    end
end

system.print("List of max values:")
local data = json.decode(db.getStringValue("TotalProduced"))
for id, value in pairs(data) do
    system.print("Id: " .. id .. " --- " .. "Produced: :" .. value)
end
