local function GetElementInfo(configID)
    for _, addon in ipairs(Nexus.Addons or {}) do
        local data = addon.Elements
        for _, v in ipairs(data) do
            if v.data and v.data.id == configID then
                return v.data
            end
        end
    end

    return false
end

local fileCache = util.JSONToTable(file.Read("nexus_server_settings.txt", "DATA") or "") or {}
function Nexus:SetValue(id, value)
    fileCache[id] = value
    file.Write("nexus_server_settings.txt", util.TableToJSON(fileCache))
end

function Nexus:GetValue(addon, id)
    if not id then
        if fileCache[addon] then
            return fileCache[addon]
        end

        local info = GetElementInfo(addon)
        return info and info.defaultValue or false
    end

    // v1 support
    local data = file.Read("nexus_settings.txt", "DATA") or ""
    data = util.JSONToTable(data) or {}

    if data[addon] and data[addon][id] then
        return data[addon][id]
    end

    return Nexus.Config.Addons[addon].Options[id].default
end

util.AddNetworkString("Nexus:IGC:V2:UpdateValue")
util.AddNetworkString("Nexus:IGC:V2:NetworkValue")
net.Receive("Nexus:IGC:V2:UpdateValue", function(len, ply)
    local elementType = net.ReadString()

    if not Nexus.Admins[ply:GetUserGroup()] then return end

    if elementType == "button-row" then
        local configID = net.ReadString()
        local int = net.ReadUInt(4)

        local info = GetElementInfo(configID)
        local value = info.buttons[int].value or info.buttons[int].text
        Nexus:SetValue(configID, value)

        info.onChange(value)

        if not info.dontNetwork then
            net.Start("Nexus:IGC:V2:NetworkValue")
            net.WriteString(elementType)
            net.WriteString(configID)
            net.WriteType(value)
            net.Broadcast()
        end
    end
end)

util.AddNetworkString("Nexus:IGC:v2:NetworkFull")
hook.Add("Nexus:FullyLoaded", "Nexus:IGC:v2:Loaded", function(ply)
    local copy = table.Copy(fileCache)
    local completeDATA = {}
    
    for id, value in pairs(copy) do
        local info = GetElementInfo(id)
        if not info.dontNetwork then
            completeDATA[id] = value
        end
    end

    local compressedData = util.Compress(util.TableToJSON(completeDATA))

    net.Start("Nexus:IGC:v2:NetworkFull")
    net.WriteUInt(#compressedData, 32)
    net.WriteData(compressedData, #compressedData)
    net.Send(ply)
end)