local function CreateMenu(s, tbl, onClicked, dontSort)
    tbl = tbl or {}

    if not dontSort then
        table.sort(tbl)
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
        button:SetText(v)
        button:SetSecondary()
        button.DoClick = function()
            s.Panel:Remove()
            onClicked(v)
        end

        local tw, th = surface.GetTextSize(v)
        maxW = math.max(maxW, tw)
        tall = tall + Nexus:Scale(35) + margin
    end

    maxW = maxW + margin*4
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
end

function PANEL:DoClick()
	CreateMenu(self, self.Options, function(val)
		self.Selected = val
		self:SetText(val)
		self:OnSelect(false, val)
	end, self.DontSort)
end

function PANEL:SetDontSort(bool)
    self.DontSort = bool
end

function PANEL:OnSelect(index, value)
end

function PANEL:AddChoice(a)
	table.insert(self.Options, a)
end

local col = Color(120, 120, 120)
function PANEL:Paint(w, h)
    draw.RoundedBox(self.margin, 0, 0, w, h, Nexus.Colors.Primary)
	draw.RoundedBox(self.margin, 2, 2, w-4, h-4, Nexus.Colors.Background)
	draw.SimpleText(self:GetText(), Nexus:GetFont(20), self.margin*2+4, h/2, col, 0, 1)
	draw.SimpleText("•", Nexus:GetFont(20), w - self.margin*2 - 4, h/2, col, TEXT_ALIGN_RIGHT, 1)
end
vgui.Register("Nexus:ComboBox", PANEL, "Nexus:Button")