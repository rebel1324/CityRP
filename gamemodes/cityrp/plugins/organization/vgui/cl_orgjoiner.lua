
    local WIDTH, HEIGHT = math.Clamp(ScrW() * .5, 400, 800), math.max(ScrW() * .3, 480)
    local PANEL = {}
        local no = function() end

        function PANEL:Init()
            nut.gui.orgjoin = self

            self:SetSize(self:GetParent():GetSize())

            self.descpanel = self:Add("DPanel")
            self.descpanel:Dock(TOP)
            self.descpanel:SetTall(20)
            self.descpanel:DockMargin(10, 5, 10, 5)
            self.descpanel.Paint = no
            
            self.desc = self.descpanel:Add("DLabel")
            self.desc:Dock(FILL)
            self.desc:SetFont("nutSmallFont")
            self.desc:SetContentAlignment(4)
            self.desc:SetText(L"orgJoinDesc")

            self.content = self:Add("DScrollPanel")
            self.content:Dock(FILL)
            self.content:SetTall(20)
            self.content:DockMargin(5, 5, 5, 5)
	        self.content:SetPaintBackgroundEnabled(true)
	        self.content:SetPaintBorderEnabled(true)
            self.content:SetPaintBackground(true)
            self.content:DockPadding(10, 5, 10, 5)

            local org = LocalPlayer():getChar():getOrganizationInfo()
            if (org) then
                self:Remove()
                return
            end

            self:updateOrgs()
        end

        function PANEL:updateOrgs()
            for id, orgObj in pairs(nut.org.loaded) do
                local org = self.content:Add("nutOrganization")
                org:Dock(TOP)
                org:setInfo(orgObj, self)
            end
        end
    vgui.Register("nutOrgJoiner", PANEL, "EditablePanel")

    PANEL = {}
        function PANEL:Init()
            self:SetTall(40)

            self.meme = self:Add("DPanel")
            self.meme:Dock(LEFT)
            self.meme:DockMargin(0, 0, 0, 0)
            self.meme:SetWide(35)
            self.meme.Paint = function(p, w, h)
                nut.util.drawText("", w/2 + 3, h/2 + 3, color_white, 1, 1, "nutOrgIcons")
            end

            self.name = self:Add("DLabel")
            self.name:Dock(FILL)
            self.name:SetFont("nutMediumFont")
            self.name:SetContentAlignment(4)
            self.name:DockMargin(10, 0, 10, 0)
            self.name:SetText("Group Name")

            self.join = self:Add("DButton")
            self.join:Dock(RIGHT)
            self.join:SetWide(100)
            self.join:SetTextColor(color_white)
            self.join:SetFont("nutSmallFont")
            self.join:DockMargin(0, 5, 10, 5)
            self.join:SetText(L"orgJoin")
        end

        local col = Color(0, 0, 0, 150)
        function PANEL:Paint(w, h)
            surface.SetDrawColor(col)
            surface.DrawRect(0, 0, w, h)
        end

        function PANEL:setInfo(org, parent)
            if (org) then
                self.name:SetText(org:getName())
            end

            self.join.DoClick = function()
                netstream.Start("nutOrgJoin", org.id)
                parent:Remove()
            end
        end
    vgui.Register("nutOrganization", PANEL, "DPanel")
