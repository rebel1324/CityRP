
    -- ORGANIZATION MANAGER
	surface.CreateFont("nutOrgIcons", {
		font = "nsicons",
		size = 20,
		extended = true,
		weight = 500
    })
    
    local WIDTH, HEIGHT = math.max(ScrW() * .5, 500), math.max(ScrW() * .3, 480)
    local PANEL = {}
        local no = function() end
        
        local panelInfo = {
            "orgInfo",
            "memberInfo",
            "perkInfo",
            "assetInfo",
        }

        local function nav(self)
            local p = self.parent
            p.nav = (p.nav + self.dir)
            p:setupContent(p.nav%#panelInfo + 1)
        end

        function PANEL:Init()
            nut.gui.orgman = self

            self:SetSize(self:GetParent():GetSize())

            self.namepanel = self:Add("DPanel")
            self.namepanel:Dock(TOP)
            self.namepanel:SetTall(36)
            self.namepanel:DockMargin(10, 0, 10, 0)
            self.namepanel:SetCursor( "hand" )
            self.namepanel.Paint = no

            self.name = self.namepanel:Add("DLabel")
            self.name:Dock(FILL)
            self.name:SetFont("nutBigFont")
            self.name:SetContentAlignment(4)

            self.descpanel = self:Add("DPanel")
            self.descpanel:Dock(TOP)
            self.descpanel:SetTall(20)
            self.descpanel:DockMargin(10, 5, 10, 5)
            self.descpanel:SetCursor( "hand" )
            self.descpanel.Paint = no
            
            self.desc = self.descpanel:Add("DLabel")
            self.desc:Dock(FILL)
            self.desc:SetFont("nutSmallFont")
            self.desc:SetContentAlignment(4)

            self.category = self:Add("DPanel")
            self.category:Dock(TOP)
            self.category:SetTall(30)
            self.category:DockMargin(10, 5, 10, 0)
            self.category:SetCursor( "hand" )
            self.category.Paint = no
            
            self.catname = self.category:Add("DLabel")
            self.catname:Dock(FILL)
            self.catname:SetFont("nutMediumFont")
            self.catname:SetContentAlignment(4)
            
            self.catright = self.category:Add("DButton")
            self.catright:Dock(RIGHT)
            self.catright:SetFont("nutOrgIcons")
            self.catright:SetText("")
            self.catright:SetWide(30)
            self.catright.Paint = no
            self.catright.dir = 1
            self.catright.parent = self
            self.catright.DoClick = nav
            self.catright:SetTextColor(color_white)

            self.catleft = self.category:Add("DButton")
            self.catleft:Dock(RIGHT)
            self.catleft:SetFont("nutOrgIcons")
            self.catleft:SetText("")
            self.catleft:SetWide(30)
            self.catleft.Paint = no
            self.catleft.dir = -1
            self.catleft.parent = self
            self.catleft.DoClick = nav
            self.catleft:SetTextColor(color_white)

            self.content = self:Add("DScrollPanel")
            self.content:Dock(FILL)
            self.content:SetTall(20)
            self.content:DockMargin(5, 5, 5, 5)
	        self.content:SetPaintBackgroundEnabled(true)
	        self.content:SetPaintBorderEnabled(true)
            self.content:SetPaintBackground(true)
            self.content:DockPadding(10, 5, 10, 5)

            local org = LocalPlayer():getChar():getOrganizationInfo()
            self:SetOrganization(org)
        end
            
        function PANEL:Think()

        end

        function PANEL:setupContent(num)
            self.catname:SetText(L(panelInfo[num]))
            self.content:Clear()
            local org = self.org

            local con = self.content
            if (num == 1) then 
                -- basic organization info
                local noticeBar = con:Add("nutNoticeBar")
                noticeBar:Dock(TOP)
                noticeBar:setType(7)
                noticeBar:setText(L("orgNameDescTip"))
                noticeBar:DockMargin(5, 5, 5, 5)

                local orgLevel = con:Add("DLabel")
                orgLevel:Dock(TOP)
                orgLevel:SetFont("nutMediumFont")
                orgLevel:SetContentAlignment(4)
                orgLevel:DockMargin(10, 5, 10, 5)
                orgLevel:SetText(L"orgLevel")
                orgLevel:SetTall(25)

                local orgMoney = con:Add("DLabel")
                orgMoney:Dock(TOP)
                orgMoney:SetFont("nutMediumFont")
                orgMoney:SetContentAlignment(4)
                orgMoney:DockMargin(10, 5, 10, 5)
                orgMoney:SetText(L"orgMoney")
                orgMoney:SetTall(25)

                local orgExp = con:Add("DLabel")
                orgExp:Dock(TOP)
                orgExp:SetFont("nutMediumFont")
                orgExp:SetContentAlignment(4)
                orgExp:DockMargin(10, 5, 10, 5)
                orgExp:SetText(L"orgExp")
                orgExp:SetTall(25)

                local orgNextExp = con:Add("DLabel")
                orgNextExp:Dock(TOP)
                orgNextExp:SetFont("nutMediumFont")
                orgNextExp:SetContentAlignment(4)
                orgNextExp:DockMargin(10, 5, 10, 5)
                orgNextExp:SetText(L"orgNextExp")
                orgNextExp:SetTall(25)

                local orgMembers = con:Add("DLabel")
                orgMembers:Dock(TOP)
                orgMembers:SetFont("nutMediumFont")
                orgMembers:SetContentAlignment(4)
                orgMembers:DockMargin(10, 5, 10, 5)
                orgMembers:SetText(L("orgTotalMembers", 1))
                orgMembers:SetTall(25)
            elseif (num == 2) then 
                for i = ORGANIZATION_MEMBER, ORGANIZATION_OWNER do
                    local dec = ORGANIZATION_OWNER - i

                    local rankMembers = org.members[dec]
                    if (rankMembers) then
                        for charID, name in pairs(rankMembers) do
                            local member = con:Add("nutOrgMember")
                            member:Dock(TOP)

                            local myID = LocalPlayer():getChar():getID()
                            member:setInfo(myID, charID, dec, name)
                        end
                    end
                end
            elseif (num == 3) then
                -- perk management
            elseif (num == 4) then
                -- asset management
            end
        end

        function PANEL:SetOrganization(org)
            if (org) then
                self.org = org
                self.name:SetText(org and org:getName() or "noName")
                self.desc:SetText(org and org:getData("desc") or L"noDesc")

                self.nav = 0
                self:setupContent(self.nav + 1)
                
	            self.name:SetMouseInputEnabled(true)
	            self.name:SetCursor("hand")
                self.name.DoClick = function()
					Derma_StringRequest(L("enterOrgName"), L("enterOrgNameDesc"), "", function(text)
                        netstream.Start("nutOrgChangeValue", "name", text)
					end)
                end
                
	            self.desc:SetMouseInputEnabled(true)
	            self.desc:SetCursor("hand")
                self.desc.DoClick = function()
                    Derma_StringRequest(L("enterOrgName"), L("enterOrgNameDesc"), "", function(text)
                        netstream.Start("nutOrgChangeValue", "desc", text)
					end)
                end
            else
                self:Close()
            end
        end
    vgui.Register("nutOrgManager", PANEL, "EditablePanel")

    PANEL = {}
        function PANEL:Init()
            self:SetTall(40)

            self.meme = self:Add("DPanel")
            self.meme:Dock(LEFT)
            self.meme:DockMargin(0, 0, 0, 0)
            self.meme:SetWide(35)
            self.meme.Paint = function(p, w, h)
                if (self.rank >= ORGANIZATION_OWNER) then
		            nut.util.drawText("", w/2 + 3, h/2 + 3, color_white, 1, 1, "nutOrgIcons")
                elseif ((self.rank < ORGANIZATION_OWNER and self.rank >= ORGANIZATION_MODERATOR)) then
		            nut.util.drawText("", w/2 + 4, h/2 + 1, color_white, 1, 1, "nutOrgIcons")
                else
		            nut.util.drawText("", w/2 + 3, h/2, color_white, 1, 1, "nutOrgIcons")
                end
            end

            self.name = self:Add("DLabel")
            self.name:Dock(FILL)
            self.name:SetFont("nutMediumFont")
            self.name:SetContentAlignment(4)
            self.name:DockMargin(10, 0, 10, 0)
            self.name:SetText("Member")

            self.kick = self:Add("DButton")
            self.kick:Dock(RIGHT)
            self.kick:SetFont("nutSmallFont")
            self.kick:DockMargin(0, 5, 10, 5)
            self.kick:SetText(L"orgKick")

            self.ban = self:Add("DButton")
            self.ban:Dock(RIGHT)
            self.ban:SetFont("nutSmallFont")
            self.ban:DockMargin(0, 5, 5, 5)
            self.ban:SetText(L"orgBan")

            self.setrank = self:Add("DButton")
            self.setrank:Dock(RIGHT)
            self.setrank:SetFont("nutSmallFont")
            self.setrank:DockMargin(5, 5, 5, 5)
            self.setrank:SetText(L"orgSetRank")

            self.rank = self:Add("DLabel")
            self.rank:Dock(RIGHT)
            self.rank:SetWide(200)
            self.rank:SetFont("nutMediumFont")
            self.rank:SetContentAlignment(6)
            self.rank:DockMargin(10, 0, 10, 0)
        end

        local col = Color(0, 0, 0, 150)
        function PANEL:Paint(w, h)
            surface.SetDrawColor(col)
            surface.DrawRect(0, 0, w, h)
        end

        function PANEL:setInfo(charID, targetID, rank, name)
            self.rank:SetText(L(ORGANIZATION_RANK_NAME[rank]))
            self.name:SetText(name)
            self.charID = charID
            self.rank = rank
            self.name = name
            self.targetID = targetID
        end
    vgui.Register("nutOrgMember", PANEL, "DPanel")
