local function CreateMenu(s, tbl, onClicked, dontSort)
    tbl = tbl or {}

    if not dontSort then
        table.sort(tbl, function(a, b) return a.text < b.text end)
    end

    local margin = Nexus:Scale(6)
    s.Panel = vgui.Create("DButton")
    s.Panel:SetSize(ScrW(), ScrH())
    s.Panel:MakePopup()
    s.Panel:SetText("")
    s.Panel.DoClick = function(ss)
        ss:Remove()
    end
    s.Panel.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 210)
        surface.DrawRect(0, 0, w, h)
    end
    s.Panel.Think = function(ss)
        if not IsValid(s) then
            ss:Remove()
            return
        end

        ss:MoveToFront()
    end

    local x, y = s:LocalToScreen(0, s:GetTall() + margin)
    local panel = s.Panel:Add("DPanel")
    panel:SetSize(Nexus:Scale(200), Nexus:Scale(300))
    panel:SetPos(x, y)
    panel.Paint = function(s, w, h)
        draw.RoundedBox(margin, 0, 0, w, h, Nexus.Colors.Background)
    end

    local scroll = panel:Add("Nexus:ScrollPanel")
    scroll:Dock(FILL)

    surface.SetFont(Nexus:GetFont(20))

    local maxW = Nexus:Scale(200)

    local tall = 0
    for _, v in ipairs(tbl) do
        local button = scroll:Add("Nexus:Button")
        button:Dock(TOP)
        button:DockMargin(0, 0, margin, margin)
        button:SetTall(Nexus:Scale(35))
        button:SetText(v.text)
        button:SetSecondary()
        button.DoClick = function()
            s.Panel:Remove()
            onClicked(v.text, v.data)
        end

        local tw, th = surface.GetTextSize(v.text)
        maxW = math.max(maxW, tw)
        tall = tall + Nexus:Scale(35) + margin
    end

    maxW = maxW + margin * 4
    panel:SetWide(maxW)
    panel:SetTall(math.min(tall, Nexus:Scale(300)))
    return maxW
end

local PANEL = {}
function PANEL:Init()
    self.margin = Nexus:Scale(6)
    self:SetFont(Nexus:GetFont(25))
    self:SetTextColor(Color(120, 120, 120))
    self.Options = {}
    self.DontSort = false
    self.SelectedValue = nil
end

function PANEL:DoClick()
    local sortedOptions = self.Options
    if not self.DontSort then
        table.sort(sortedOptions, function(a, b) return a.text < b.text end)
    end

    CreateMenu(self, sortedOptions, function(val, data)
        self.Selected = val
        self:SetText(val)
        self.SelectedValue = data
        self:OnSelect(false, val)
    end, self.DontSort)
end

function PANEL:OnSelect(index, value)
end

function PANEL:AddChoice(text, data)
    table.insert(self.Options, {text = text, data = data})
end

function PANEL:SetDontSort(dontSort)
    self.DontSort = dontSort
end

function PANEL:GetValue()
    return self.SelectedValue
end

local col = Color(120, 120, 120)
function PANEL:Paint(w, h)
    draw.RoundedBox(self.margin, 0, 0, w, h, Nexus.Colors.Primary)
    draw.RoundedBox(self.margin, 2, 2, w - 4, h - 4, Nexus.Colors.Background)
    draw.SimpleText(self:GetText(), Nexus:GetFont(20), self.margin * 2 + 4, h / 2, col, 0, 1)
    draw.SimpleText("•", Nexus:GetFont(20), w - self.margin * 2 - 4, h / 2, col, TEXT_ALIGN_RIGHT, 1)
end
vgui.Register("Nexus:ComboBox", PANEL, "Nexus:Button")

