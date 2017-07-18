local PANEL = {}
    function PANEL:Init()
        self:SetTall(64)
        
        local function assignClick(panel)   
            panel.OnMousePressed = function()
                self.pressing = -1
                self:onClick()
            end
            panel.OnMouseReleased = function()
                if (self.pressing) then
                    self.pressing = nil
                end
            end
        end

        self.icon = self:Add("SpawnIcon")
        self.icon:SetSize(128, 64)
        self.icon:InvalidateLayout(true)
        self.icon:Dock(LEFT)
        self.icon.PaintOver = function(this, w, h)
        end
        assignClick(self.icon) 

        self.price = self:Add("DLabel")
        self.price:Dock(RIGHT)
        self.price:SetMouseInputEnabled(true)
        self.price:SetCursor("hand")
        self.price:SetExpensiveShadow(1, Color(0, 0, 60))
        self.price:SetContentAlignment(5)
        self.price:SetFont("nutMediumFont")
        self.price:SetWide(64)
        assignClick(self.price) 

        self.label = self:Add("DLabel")
        self.label:Dock(FILL)
        self.label:SetMouseInputEnabled(true)
        self.label:SetCursor("hand")
        self.label:SetExpensiveShadow(1, Color(0, 0, 60))
        self.label:SetContentAlignment(5)
        self.label:SetFont("nutMediumFont")
        assignClick(self.label) 
    end

    function PANEL:onClick()
        nut.command.send("buyentity", self.class)
    end

    function PANEL:setNumber(number)
        self.price:SetText(number)
    end

    function PANEL:setEntity(data)
        if (data.model) then
            local model = data.model
            if (type(model):lower() == "table") then
                model = table.Random(model)
            end

            self.icon:SetModel(model)
        else
            self.icon:SetModel("models/props_junk/meathook001a.mdl")
        end

        self.label:SetText(L(data.name))   
        self.data = data 
        self.class = data.class
        self:setNumber(data.price)
    end
vgui.Register("nutEntitiesPanel", PANEL, "DPanel")

PANEL = {}
    function PANEL:Init()
    	nut.gui.entities = self

    	self:SetSize(self:GetParent():GetSize())

        self.list = vgui.Create("DPanelList", self)
        self.list:Dock(FILL)
        self.list:EnableVerticalScrollbar()
        self.list:SetSpacing(5)
        self.list:SetPadding(5)

        self.entityPanels = {}
        self:loadEntities()
    end

    function PANEL:loadEntities()
        self.list:Clear()
        
        for k, v in pairs(nut.bent.list) do
            if (v.condition(LocalPlayer())) then
                local panel = vgui.Create("nutEntitiesPanel", self.list)
                panel:setEntity(v)
                table.insert(self.entityPanels, panel)

                self.list:AddItem(panel)
            end
        end
    end
vgui.Register("nutEntities", PANEL, "EditablePanel")

hook.Add("CreateMenuButtons", "nutEntities", function(tabs)
	tabs["bentities"] = function(panel)
		if (hook.Run("BuildEntitiesMenu", panel) != false) then
			panel:Add("nutEntities")
		end
	end
end)