Prefix = "Counter" --export: All elements that should be included must have this prefix in the name.
Databank = "Values" --export: The element name of the databank that stores all data from the counters.

local Core = library.getCoreUnit()
local Db = library.getLinkByName(Databank)
local RawTime = system.getUtcTime()
local ElementName = ""
local ElementId = ""
local IndustryInfo = {}
local TotalUnitsProduced = 0
--local DeltaUnitsProduced = 0

All_Elements_Ids = Core.getElementIdList()

--Db.clear()

-- Get the first part of a string, case insensitive
function starts_with(String,Start)
    return string.sub(string.lower(String),1,string.len(string.lower(Start))) == string.lower(Start)
end

-- Create a matrix of element id's and names, but only for names starting with the prefix
local AllCountersData = {}
local AllCountersData_Key = 0
for i in pairs(All_Elements_Ids) do
    ElementId = All_Elements_Ids[i]
    ElementName = Core.getElementNameById(ElementId)
    if starts_with(ElementName, Prefix) then
        AllCountersData_Key = AllCountersData_Key + 1
        AllCountersData[AllCountersData_Key] = {}
        AllCountersData[AllCountersData_Key][1] = ElementId
        IndustryInfo = Core.getElementIndustryInfoById(ElementId)
        TotalUnitsProduced = IndustryInfo.unitsProduced
        AllCountersData[AllCountersData_Key][2] = TotalUnitsProduced
    end
end
--[[
-- Check if production is reset because of element restart
if Db.getNbKeys() > 0 then
    local LastDbLine = json.decode(Db.getStringValue(Db.getNbKeys()))
    for i in pairs(AllCountersData) do
        if LastDbLine[2][i][2] > TotalUnitsProduced then
            DeltaUnitsProduced = TotalUnitsProduced
        else
            DeltaUnitsProduced = TotalUnitsProduced - LastDbLine[i][2]
        end
    end
end
]]

-- Format RawTime to "date time".

-- Write to Databank
local NewDbLine = {RawTime, AllCountersData}
Db.setStringValue(Db.getNbKeys() + 1,json.encode(NewDbLine))

-- Print to screen for debugging
system.print(" - - - - - - - - - - - - - - - - - - -")
system.print("Data from databank:")
local DbLine = {}
for i=1, Db.getNbKeys() do
    DbLine = json.decode(Db.getStringValue(i))
    system.print("---- Time: " .. DbLine[1])
    for j in pairs(DbLine[2]) do
        system.print("Id: " .. DbLine[2][j][1] .. " --- " .. "Produced: " .. DbLine[2][j][2])
    end

end