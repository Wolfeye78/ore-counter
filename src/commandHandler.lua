
local db = library.getLinkByName(Databank)

-- Clear databank
function commandHandler(_, text)
    if text == "clear" then
        db.clear()
        system.print(" - - Databank cleared! - - ")
    else
        system.print("Command not recognized!")
    end
end