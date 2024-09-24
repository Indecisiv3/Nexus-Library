if SERVER then
    // to make the sh_builder happy
    function Nexus:Scale(number) end
end

Nexus.Addons = Nexus.Addons or {}

local BUILDER = {}
BUILDER.Elements = {}
function BUILDER:Start()
    local data = table.Copy(BUILDER)
    data.name = "Addon ID"

    return data
end

function BUILDER:SetName(str)
    self.name = str

    return self
end

function BUILDER:AddLabel(tbl)
    tbl = tbl or {}
    tbl.text = tbl.text or ""

    table.Add(self.Elements, {{id = "label", text = tbl.text, margin = tbl.margin}})

    return self
end

function BUILDER:AddButtons(tbl)
    tbl = tbl or {}

    if tbl.label then
        self:AddLabel({text = tbl.label, margin = Nexus:Scale(5)})
    end

    table.Add(self.Elements, {{id = "button-row", data = tbl}})

    return self
end

function BUILDER:End()
    for k, v in ipairs(Nexus.Addons) do
        if v.name == self.name then
            table.remove(Nexus.Addons, k)
            break
        end
    end

    table.Add(Nexus.Addons, {self})
end

Nexus.Builder = BUILDER

local addon = Nexus.Builder:Start()
    :SetName("Leaderboards")
    :AddLabel({text = "Just a label"})

    :AddButtons({
        id = "nexus-example-buttonRow",
        defaultValue = 10,
        dontNetwork = false, // set to true so things such as db details dont get networked

        label = "Button Row",
        buttons = {
            {text = "Button #1", value = 1},
            {text = "Button #2", value = 2, color = Nexus.Colors.Secondary},
            {text = "Button #3", value = 3, color = Nexus.Colors.Green},
            {text = "Long Button #4", value = 4, color = Nexus.Colors.Red},
        },
        onChange = function(value)
            print("Value has been changed", value)
        end,
    })
:End()