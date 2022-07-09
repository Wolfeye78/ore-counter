Prefix = "Counter" --export: All elements that should be included must have this prefix in the name.
Databank = "Values" --export: The element name of the databank that stores all data from the counters.

local Core = library.getCoreUnit()
local Db = library.getLinkByName(Databank)
local RawTime = system.getUtcTime()

All_Elements_Ids = Core.getElementIdList()

--Db.clear()

-- Get the first part of a string, case insensitive
local function starts_with(String,Start)
    return string.sub(string.lower(String),1,string.len(string.lower(Start))) == string.lower(Start)
end

-- Check if production is reset because of element restart
local function DeltaUnitsProduced (unitId, currentCount)
    local TotalUnitsProduced = json.decode(Db.getStringValue("TotalProduced")) or {}
    local result = 0

    local previousCount = TotalUnitsProduced[unitId] or 0

    if currentCount > previousCount then
        result = currentCount - previousCount
    else
        result = currentCount
    end

    return result
end

local function getUnitsProducedById(id)
    return Core.getElementIndustryInfoById(id).unitsProduced
end

-- Create a matrix of element id's and names, but only for names starting with the prefix
local AllCounters = {}
local AllCountersProduced = {}
local AllCountersData_Key = 0

for i in ipairs(All_Elements_Ids) do
    local ElementId = All_Elements_Ids[i]
    local ElementName = Core.getElementNameById(ElementId)
    if starts_with(ElementName, Prefix) then
        AllCountersData_Key = AllCountersData_Key + 1
        AllCounters[AllCountersData_Key] = {
            id = ElementId,
            delta = DeltaUnitsProduced(ElementId, currentCount)
        }

        AllCountersProduced[ElementId] = currentCount
    end
end

-- Format RawTime to "date time"

-- Write data to new line in Databank
local NewDbLine = { RawTime, AllCounters }
Db.setStringValue(Db.getNbKeys() + 1,json.encode(NewDbLine))
Db.setStringValue("TotalProduced",json.encode(AllCountersProduced))

-- Print to screen for debugging
system.print(" - - - - - - - - - - - - - - - - - - -")
system.print("List of records:")


for _, key in pairs(Db.getKeyList()) do
    if key ~= "TotalProduced" then
        local data = json.decode(Db.getStringValue(key))
        system.print("---- Time: " .. data[1])
        for j in pairs(data[2]) do
            system.print("Id: " .. data[2][j].id .. " --- " .. "Delta: " .. data[2][j].delta)
        end
    end
end

system.print("List of max values:")
local data = json.decode(Db.getStringValue("TotalProduced"))
for id, value in pairs(data) do
    system.print("Id: " .. id .. " --- " .. "Produced: :" .. value)
end
--
--for i=1,#DbLines do
--    system.print("Id: " .. DbLines[i][1] .. " --- " .. "Produced: :" .. DbLines[i][2])
--end
