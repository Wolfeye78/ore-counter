prefix = "Counter" --export: All elements that should be included must have this prefix in the name.
databank = "Values" --export: The element name of the databank that stores all data from the counters.

local core = library.getCoreUnit()
local db = library.getLinkByName(databank)
local RawTime = system.getUtcTime()
local ElementName = ""
local ElementId = ""
local IndustryInfo = {}
local UnitsProduced = 0

All_Elements_Ids = core.getElementIdList()

-- Get the first part of a string
function starts_with(String,Start)
    return string.sub(string.lower(String),1,string.len(string.lower(Start))) == string.lower(Start)
end

-- Create a matrix of element id's and names, but only for names starting with the prefix
Counters = {}
for i in pairs(All_Elements_Ids) do
    ElementId = All_Elements_Ids[i]
    ElementName = core.getElementNameById(ElementId)
    if starts_with(ElementName,prefix) then
        Counters[i] = {}
        Counters[i][1] = RawTime
        Counters[i][2] = ElementId
        Counters[i][3] = ElementName
        IndustryInfo = core.getElementIndustryInfoById(ElementId)
        UnitsProduced = IndustryInfo.unitsProduced
        Counters[i][4] = UnitsProduced

    end
end

-- Format RawTime to "date time".

-- Convert to json
local dataAsJson = json.encode(Counters)

-- Write to Databank
db.clear()
db.setStringValue(db.getNbKeys() + 1,dataAsJson)

-- Print to screen for debugging
system.print(" - - - - - - - - - - - - - - - - - - -")
--[[system.print("Data from table:")
for i in pairs(Counters) do
    system.print("Time: " .. Counters[i][1])
    system.print("Id: " .. Counters[i][2])
    system.print("Name: " .. Counters[i][3])
    system.print("Produced: " .. Counters[i][4])
end
]]
system.print("Data from databank:")
for i=1,db.getNbKeys() do
    local dataAsTable = json.decode(db.getStringValue(i))
    for j in pairs(dataAsTable) do
        system.print("Time: " .. dataAsTable[j][1])
        system.print("Id: " .. dataAsTable[j][2])
        system.print("Name: " .. dataAsTable[j][3])
        system.print("Produced: " .. dataAsTable[j][4])
    end

end


--Industry = core.getElementIndustryInfoById(5)
--system.print(Industry.unitsProduced)