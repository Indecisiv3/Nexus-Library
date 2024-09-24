concommand.Add("nexus_config", function()
    local frame = Nexus.UIBuilder:Start()
    :CreateFrame({
        id = "nexus_config_v2",
        title = "Nexus Addons",
        size = {w = Nexus:Scale(1000), h = Nexus:Scale(800)},
    })
    :AddIconButton({
        icon = "1U08KCx",
        DoClick = function()
            // v1 support
            local oldBuilder = Nexus.UIBuilder:Start()
            :CreateFrame({
                id = "nexus_config",
                title = "Nexus Addons (v1)",
                size = {w = Nexus:Scale(1000), h = Nexus:Scale(800)},
            })
    
            local panel = oldBuilder:GetLastPanel():Add("Nexus:IGC:Menu")
            panel:Dock(FILL)
        end
    })
    
    local panel = frame:GetLastPanel():Add("Nexus:Config:MenuV2")
    panel:Dock(FILL)
end)

Nexus.DataCache = Nexus.DataCache or {}
net.Receive("Nexus:IGC:v2:NetworkFull", function()
    local data = net.ReadUInt(32)
    data = net.ReadData(data)
    data = util.Decompress(data)
    data = util.JSONToTable(data)

    Nexus.DataCache = data
end)

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

function Nexus:GetValue(id)
    if Nexus.DataCache[id] then
        return Nexus.DataCache[id]
    end

    local info = GetElementInfo(id)
    return info and info.defaultValue or false
end

net.Receive("Nexus:IGC:V2:NetworkValue", function()
    local elementType = net.ReadString()
    if elementType == "button-row" then
        local id = net.ReadString()
        local value = net.ReadType()
        Nexus.DataCache[id] = value
    end
end)