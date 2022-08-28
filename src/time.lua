-- Format RawTime to "date time"
function getTime(hoursOffset)
    local hoursOffset = hoursOffset or 0
    local unixTime = math.floor(system.getUtcTime() + hoursOffset*3600)

    local hours = math.floor(unixTime / 3600 % 24)
    local minutes = math.floor(unixTime / 60 % 60)
    local seconds = math.floor(unixTime % 60)

    unixTime = math.floor(unixTime / 86400) + 719468
    local era = math.floor(unixTime / 146097)
    local doe = math.floor(unixTime - era * 146097)
    local yoe = math.floor((doe - doe / 1460 + doe / 36524 - doe / 146096) / 365)
    local year = math.floor(yoe + era * 400)
    local doy = doe - math.floor((365 * yoe + yoe / 4 - yoe / 100))
    local mp = math.floor((5 * doy + 2) / 153)

    local day = math.ceil(doy - (153 * mp + 2) / 5 + 1)
    local month = math.floor(mp + (mp < 10 and 3 or -9))
    year = year + (month <= 2 and 1 or 0)

    return string.format("%02d/%02d/%04d %02d:%02d:%02d",day, month, year, hours, minutes, seconds)
end