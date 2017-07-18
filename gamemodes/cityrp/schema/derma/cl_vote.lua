local PANEL = {}

function PANEL:Init()
	self:SetSize(500, 150)	

	local sw, sh = ScrW(), ScrH()
	local ww, wh = self:GetSize()
	self:SetPos(sw/2 - ww/2, sh - wh - 100)
	self:SetTitle("Vote (F2 to activate)")
	local seconds = 10
	self.setTime = CurTime() + seconds
	self.id = 0

	self.name = self:Add("DLabel")
	self.name:DockMargin(2, 2, 2, 2)
	self.name:Dock(TOP)
	local x, y = self.name:GetSize()
	self.name:SetSize(x, y + 20)
	self.name:SetFont("nutChatFont")
	self.name:SetTextColor(color_white)
	self.name:SetContentAlignment(5)
	self.name:SetText("Starting Vote.")
	self.name:SetExpensiveShadow(1, Color(0, 0, 0, 150))

	self.buttons = self:Add("DPanel")
	self.buttons:DockMargin(2, 2, 2, 2)
	self.buttons:Dock(FILL)
	self.buttons.Paint = function()
		local w, h = self.buttons:GetSize()
		local p = (self.setTime - CurTime()) / seconds
		draw.RoundedBox(0, 0, h-2, w*p, 2, color_white)

		if (p < 0) then
			self:Close()
		end
	end

	self.a = self.buttons:Add("DButton")
	self.a:DockMargin(22, 12, 2, 20)
	self.a:Dock(LEFT)
	self.a:SetSize(120,0)
	self.a:SetTextColor(color_white)
	self.a:SetText(L"yes")
	self.a.DoClick = function()
		self:sendResult(1)
	end

	self.b = self.buttons:Add("DButton")
	self.b:DockMargin(22, 12, 22, 20)
	self.b:Dock(RIGHT)
	self.b:SetSize(120,0)
	self.b:SetTextColor(color_white)
	self.b:SetText(L"no")
	self.b.DoClick = function()
		self:sendResult(0)
	end

	if (nut.vote) then
		local voteID = self.id
		nut.vote.list[voteID] = self
	end
end

function PANEL:OnClose()
	local voteID = self.id

	if (nut.vote.list[voteID]) then
		nut.vote.list[voteID] = nil
	end
end

function PANEL:OnRemove()
	local voteID = self.id
	
	if (nut.vote.list[voteID]) then
		nut.vote.list[voteID] = nil
	end
end

function PANEL:sendResult(yes)
	netstream.Start("nutVote", self.id, yes)

	self:Remove()
end
vgui.Register("voteRequired", PANEL, "DFrame")

netstream.Hook("voteRequired", function(id, title)
	local voteWindow = vgui.Create("voteRequired")

	voteWindow.id = id
	voteWindow.name:SetText(L(title))
end)