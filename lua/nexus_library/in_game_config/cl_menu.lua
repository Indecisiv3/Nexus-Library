local PANEL = {}
function PANEL:Init()
    self.margin = Nexus:Scale(10)

    self.Navbar = self:Add("Nexus:Navbar")
    self.Navbar:Dock(TOP)
    self.Navbar:DockMargin(self.margin, self.margin, self.margin, 0)

    for _, data in ipairs(Nexus.Addons) do
        self.Navbar:AddItem(data.name, function()
            self:SelectContent(data)
        end)

        self:SelectContent(data)
    end
end

function PANEL:SelectContent(data)
    if IsValid(self.content) then self.content:Remove() end

    self.content = self:Add("Nexus:ScrollPanel")
    self.content:Dock(FILL)
    self.content:DockMargin(self.margin, self.margin, self.margin, self.margin)

    for _, v in ipairs(data.Elements or {}) do
        if v.id == "label" then
            self:AddLabel(v.text, v.margin)
        elseif v.id == "button-row" then
            local row = self:AddRow()

            for int, buttonDATA in ipairs(v.data.buttons or {}) do
                local button = row:Add("Nexus:Button")
                button:Dock(LEFT)
                button:DockMargin(0, 0, self.margin, 0)
                button:SetColor(buttonDATA.color or Nexus.Colors.Primary)
                button:SetText(buttonDATA.text or "")
                button:AutoWide()
                button.DoClick = function()
                    net.Start("Nexus:IGC:V2:UpdateValue")
                        net.WriteString(v.id)
                        net.WriteString(v.data.id)
                        net.WriteUInt(int, 4)
                    net.SendToServer()
                end
            end
        end
    end
end

function PANEL:AddRow()
    local panel = self.content:Add("DPanel")
    panel:Dock(TOP)
    panel:DockMargin(0, 0, 0, self.margin)
    panel:SetTall(Nexus:Scale(50))
    panel.Paint = nil

    return panel
end

function PANEL:AddLabel(text, margin)
    local label = self.content:Add("DLabel")
    label:Dock(TOP)
    label:DockMargin(0, 0, 0, margin or self.margin)
    label:SetText(text)
    label:SetFont(Nexus:GetFont(25))
    label:SetTextColor(Nexus:GetTextColor(Nexus.Colors.Background))
    label:SizeToContents()

    return label
end
vgui.Register("Nexus:Config:MenuV2", PANEL, "EditablePanel")

RunConsoleCommand("nexus_config")