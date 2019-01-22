
-- ORGANIZATION MANAGER
surface.CreateFont("nutOrgIcons", {
	font = "nsicons",
	size = 20,
	extended = true,
	weight = 500
})

local fsize = ScreenScale(150)
surface.CreateFont("nutSpinner", {
    font = "nsicons",
    extended = true,
    size = fsize,
    weight = 500
})

local gradient2 = nut.util.getMaterial("vgui/gradient-u")

local no = function() end
local txtentry = function(self, w, h)
    surface.SetDrawColor(ColorAlpha(color_black, 25))
    surface.DrawRect(0, 0, w, h)
    surface.SetMaterial(gradient2)
    surface.SetDrawColor(ColorAlpha(color_black, 75))
    surface.DrawTexturedRect(0, 0, w, h)
    surface.SetDrawColor(ColorAlpha(color_white, 77))
    surface.DrawOutlinedRect(0, 0, w, h)
    
    self:SetFontInternal( self.m_FontName )
    derma.SkinHook( "Paint", "TextEntry", self, w, h )
end

-- ORGANIZATION CREATOR

local PANEL = {}
    function PANEL:Init()
        nut.gui.orgcreate = self
        self:SetSize(self:GetParent():GetSize())
        self.hipanel = self:Add("DPanel")
        self.hipanel:Dock(TOP)
        self.hipanel:SetTall(20)
        self.hipanel:DockMargin(10, 5, 10, 5)
        self.hipanel.Paint = no
        
        self.hi = self.hipanel:Add("DLabel")
        self.hi:Dock(FILL)
        self.hi:SetFont("nutSmallFont")
        self.hi:SetContentAlignment(4)
        self.hi:SetText(L"orgCreateInfo")
        
        self.content = self:Add("DPanel")
        self.content:Dock(FILL)
        self.content:DockMargin(10, 5, 10, 5)
        self.content.Paint = no
        local inputLabel = self.content:Add("DLabel")
        inputLabel:Dock(TOP)
        inputLabel:SetFont("nutBigFont")
        inputLabel:SetContentAlignment(4)
        inputLabel:SetTextColor(color_white)
        inputLabel:SetText(L"orgTitle")
        inputLabel:SetTall(40)
        self.name = self.content:Add("DTextEntry")
        self.name:Dock(TOP)
        self.name:DockMargin(0, 8, 0, 8)
        self.name:SetFont("nutMediumFont")
        self.name:SetTall(35)
        self.name:SetTextColor(color_white)
        self.name:SetDrawBorder( false )
        self.name:SetPaintBackground( false )
        self.name.Paint = txtentry
        
        local inputLabel = self.content:Add("DLabel")
        inputLabel:Dock(TOP)
        inputLabel:SetFont("nutBigFont")
        inputLabel:SetTextColor(color_white)
        inputLabel:SetContentAlignment(4)
        inputLabel:SetText(L"orgDesc")
        inputLabel:SetTall(40)
        self.desc = self.content:Add("DTextEntry")
        self.desc:Dock(TOP)
        self.desc:DockMargin(0, 8, 0, 8)
        self.desc:SetFont("nutMediumFont")
        self.desc:SetTall(35)
        self.desc:SetTextColor(color_white)
        self.desc:SetDrawBorder( false )
        self.desc:SetPaintBackground( false )
        self.desc.Paint = txtentry
        self.confirmpanel = self.content:Add("DPanel")
        self.confirmpanel:Dock(TOP)
        self.confirmpanel:SetTall(50)
        self.confirmpanel:DockMargin(10, 5, 10, 5)
        self.confirmpanel.Paint = no
        
        self.confirm = self.confirmpanel:Add("DButton")
        self.confirm:Dock(RIGHT)
        self.confirm:SetTextColor(color_white)
        self.confirm:SetFont("nutBigFont")
        self.confirm:SetText(L"finish")
        self.confirm:SetWide(120)
        self.confirm.Paint = no
        self.confirm.DoClick = function()
            local name, desc = self.name:GetText(), self.desc:GetText()
            if (!name) then
                nut.util.notifyLocalized("invalid", L"name")
                return
            elseif (!desc) then
                nut.util.notifyLocalized("invalid", L"desc")
                return
            end
            
            if (name and name:len() < 8) then
                nut.util.notifyLocalized("tooShortInput", L"name")
                return
            elseif (desc and desc:len() < 16) then
                nut.util.notifyLocalized("tooShortInput", L"desc")
                return
            end
            self:Remove()
            self:GetParent():Add("nutOrgLoading")
            netstream.Start("nutOrgCreate", {
                name = self.name:GetText(),
                desc = self.desc:GetText(),
            })
        end
        self.back = self.confirmpanel:Add("DButton")
        self.back:Dock(RIGHT)
        self.back:SetTextColor(color_white)
        self.back:SetFont("nutBigFont")
        self.back:SetText(L"return")
        self.back:SetWide(120)
        self.back.Paint = no
        self.back.DoClick = function()
            self:Remove()
            self:GetParent():Add("nutOrgJoiner")
        end
    end
vgui.Register("nutOrgCreate", PANEL, "EditablePanel")

local TYPE_BUTTON = 0
local TYPE_NUMSLIDER = 1
local TYPE_TOGGLE = 2
local TYPE_TEXT = 3
local TYPE_NUMBER = 4
local WIDTH, HEIGHT = math.max(ScrW() * .5, 500), math.max(ScrW() * .3, 480)

local PANEL = {}

    function PANEL:Init()
        if (IsValid(nut.gui.orgloading)) then
            self:Remove()
            return
        end
        nut.gui.orgloading = self
        self:SetSize(self:GetParent():GetSize())
    end

    function PANEL:Paint(w, h)
        local a, b = self:LocalToScreen(0, 0)
        local mat = Matrix()
        mat:Translate(Vector(w/2, h/2))
        mat:Translate(Vector(a, b))
        mat:Rotate( Angle( 0, math.floor((RealTime()*75)/8)*45, 0 ) )
        mat:Translate(Vector(-a, -b))
        mat:Translate(Vector(-fsize, -fsize)*.5)
        nut.util.drawText(L"orgWaitSignal", w/2, h/3*1, nil, 1, 1, "nutBigFont")	
        cam.PushModelMatrix( mat )
            nut.util.drawText("", fsize*.5, fsize*.5, nil, 1, 1, "nutSpinner")	
        cam.PopModelMatrix()
    end
vgui.Register("nutOrgLoading", PANEL, "EditablePanel")

PANEL = {}
    local panelInfo = {
        "orgInfo",
        "memberInfo",
        "perkInfo",
        "config",
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
        self.curnum = num
        self.catname:SetText(L(panelInfo[num]))
        self.content:Clear()
        local org = self.org
        local con = self.content
        if (num == 1) then 
            -- basic organization info
            --[[
            local noticeBar = con:Add("nutNoticeBar")
            noticeBar:Dock(TOP)
            noticeBar:setType(7)
            noticeBar:setText(L("orgNameDescTip"))
            noticeBar:DockMargin(5, 5, 5, 5)]]
            local orgLevel = con:Add("DLabel")
            orgLevel:Dock(TOP)
            orgLevel:SetFont("nutMediumFont")
            orgLevel:SetContentAlignment(4)
            orgLevel:DockMargin(10, 5, 10, 5)
            orgLevel:SetText(L("orgLevel", org:getData("level", 0)))
            orgLevel:SetTall(25)
            local orgMoney = con:Add("DLabel")
            orgMoney:Dock(TOP)
            orgMoney:SetFont("nutMediumFont")
            orgMoney:SetContentAlignment(4)
            orgMoney:DockMargin(10, 5, 10, 5)
            orgMoney:SetText(L("orgMoney", org:getData("fund", 0)))
            orgMoney:SetTall(25)
            local orgExp = con:Add("DLabel")
            orgExp:Dock(TOP)
            orgExp:SetFont("nutMediumFont")
            orgExp:SetContentAlignment(4)
            orgExp:DockMargin(10, 5, 10, 5)
            orgExp:SetText(L("orgExp", org:getData("exp", 0)))
            orgExp:SetTall(25)
            local orgNextExp = con:Add("DLabel")
            orgNextExp:Dock(TOP)
            orgNextExp:SetFont("nutMediumFont")
            orgNextExp:SetContentAlignment(4)
            orgNextExp:DockMargin(10, 5, 10, 5)
            orgNextExp:SetText(L("orgNextExp", org:getData("exp", 0)))
            orgNextExp:SetTall(25)
            local orgMembers = con:Add("DLabel")
            orgMembers:Dock(TOP)
            orgMembers:SetFont("nutMediumFont")
            orgMembers:SetContentAlignment(4)
            orgMembers:DockMargin(10, 5, 10, 5)
            orgMembers:SetText(L("orgTotalMembers", org:getMemberCount()))
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
                        member:setInfo(myID, charID, dec, tostring(name))
                    end
                end
            end
        elseif (num == 3) then
            -- perk management
        elseif (num == 4) then
            local quit = con:Add("nutOrgConfig")
            quit:Dock(TOP)
            quit:setup(TYPE_BUTTON, L"orgExitDesc", L"orgExit", function()
                self:Remove()
                self:GetParent():Add("nutOrgLoading")
                netstream.Start("nutOrgExit")
            end)    
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
netstream.Hook("nutOrgUpdateManager", function()
    if (IsValid(nut.gui.orgman)) then
        local num = nut.gui.orgman.curnum

        if (num) then
            nut.gui.orgman:setupContent(num)
        end
    end
end)

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
        self.rankText = self:Add("DLabel")
        self.rankText:Dock(RIGHT)
        self.rankText:SetWide(200)
        self.rankText:SetFont("nutMediumFont")
        self.rankText:SetContentAlignment(6)
        self.rankText:DockMargin(10, 0, 10, 0)
    end

    local col = Color(0, 0, 0, 150)
    function PANEL:Paint(w, h)
        surface.SetDrawColor(col)
        surface.DrawRect(0, 0, w, h)
    end

    function PANEL:setInfo(charID, targetID, rank, name)
        self.rankText:SetText(L(ORGANIZATION_RANK_NAME[rank]))
        self.name:SetText(name)
        self.charID = charID
        self.rank = rank
        self.name = name
        self.targetID = targetID

        self.kick.DoClick = function()
            netstream.Start("nutOrgKick", targetID)
        end
        self.ban.DoClick = function()
            netstream.Start("nutOrgBan", targetID)
        end
        self.setrank.DoClick = function()
            local menu = DermaMenu()
                for rankID, rankLang in SortedPairs(ORGANIZATION_RANK_NAME) do
                    if (rankID == ORGANIZATION_OWNER) then continue end
                    
                    menu:AddOption(L(rankLang), function()
                        netstream.Start("nutOrgAssign", targetID, rankID)
                    end)
                end
			menu:Open()
        end
    end
vgui.Register("nutOrgMember", PANEL, "DPanel")

PANEL = {}
    function PANEL:Init()
        self:SetTall(40)
    end

    local col = Color(0, 0, 0, 150)
    function PANEL:Paint(w, h)
        surface.SetDrawColor(col)
        surface.DrawRect(0, 0, w, h)
    end

    function PANEL:setup(...)
        local args = {...}
        local t = args[1]
        if (t) then
            if (t == TYPE_BUTTON) then
                local label = self:Add("DLabel")
                label:Dock(FILL)
                label:SetText(args[2])
                label:SetFont("nutMediumFont")
                label:DockMargin(10, 5, 10, 5)
                local btn = self:Add("DButton")
                btn:Dock(RIGHT)
                btn:SetText(args[3])
                btn:SetWide(100)
                btn:SetTextColor(color_white)
                btn:SetFont("nutSmallFont")
                btn:DockMargin(10, 5, 10, 5)
                btn.DoClick = args[4]
            end
        end
    end
vgui.Register("nutOrgConfig", PANEL, "DPanel")
-- ORGANIZATION JOIN

local WIDTH, HEIGHT = math.Clamp(ScrW() * .5, 400, 800), math.max(ScrW() * .3, 480)
local PANEL = {}
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
        local create = self.content:Add("nutOrgConfig")
        create:Dock(TOP)
        create:setup(TYPE_BUTTON, L"orgCreateDesc", L"orgCreate", function()
            self:Remove()
            self:GetParent():Add("nutOrgCreate")
        end)    
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
            parent:GetParent():Add("nutOrgLoading")
        end
    end
vgui.Register("nutOrganization", PANEL, "DPanel")
