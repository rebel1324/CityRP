AddCSLuaFile()
ENT.Base = "nut_vnd_food"
ENT.PrintName = "Drink Vendor"
ENT.Author = "Black Tea"
ENT.Category = "NutScript - CityRP"
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.vending = true
ENT.item = "sodacan"
ENT.model = "models/rebel1324/sodavendor.mdl"

if (SERVER) then
else
    local w, h = 920, 500

    -- customizable functions
    function ENT:drawThink()
        -- Draw Model.
        local blurRender = nut.blur3d2d.get(self:EntIndex())

        if (blurRender) then
            blurRender.pos = self.pos
            blurRender.ang = self.ang
            blurRender.scale = (self.curScale) * .04
        end
    end

    function ENT:declarePanels()
        local itemTable = nut.item.list[self.item]
        local name

        if (itemTable) then
            name = itemTable.name
        end

        nut.blur3d2d.add(self:EntIndex(), Vector(), Angle(), .15, function(isOverlay)
            local text = L("purchaseItem", name)

            if (isOverlay) then
                -- stencil overlay (something you want to draw)
                local tx, ty = nut.util.drawText(text, 0, h * -.1, color_white, 1, 4, "nutBlurText", 100)
                nut.util.drawText(nut.currency.get(self:GetNW2Int("price")), 0, h * .01, color_white, 1, 4, "nutBlurSubText", 100)
                nut.util.drawText("", 0, h * .05, color_white, 1, 5, "nutBlurIcon", 100)
            else
                surface.SetFont("nutBlurText")
                local sizex = surface.GetTextSize(text)
                -- stencil background (blur area)
                local w = sizex + 200
                local x, y = -w / 2, -h / 2
                surface.SetDrawColor(0, 91, 0, 55)
                surface.DrawRect(x, y, w, h)
            end
        end)
    end

    function ENT:adjustPosition()
        -- make a copy of the angle.
        local rotAng = self.ang * 1
        -- Shift the Rendering Position.
        self.pos = self.pos + rotAng:Up() * 30
        self.pos = self.pos + rotAng:Right() * 0
        self.pos = self.pos + rotAng:Forward() * 25
        -- Rotate the Rendering Angle.
        self.ang = rotAng
        self.ang:RotateAroundAxis(self:GetUp(), 90)
        self.ang:RotateAroundAxis(self:GetForward(), 0)
        self.ang:RotateAroundAxis(self:GetRight(), -80)
    end
end