AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Law Board"
ENT.Author = "Black Tea"
ENT.Category = "NutScript - CityRP"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_BOTH

if (SERVER) then
    function ENT:SpawnFunction(client, trace, class)
        local entity = ents.Create(class)
        entity:SetPos(trace.HitPos)
        entity:SetAngles(trace.HitNormal:Angle())
        entity:Spawn()
        entity:Activate()

        return entity
    end

    function ENT:Initialize()
        self:SetModel("models/props/cs_assault/billboard.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetUseType(SIMPLE_USE)
        self:DrawShadow(false)
        local physObj = self:GetPhysicsObject()

        if (IsValid(physObj)) then
            physObj:EnableMotion(false)
            physObj:Sleep()
        end
    end

    function ENT:OnRemove()
    end
    -- This fuction is 3D2D Rendering Code.
    -- This function called when client clicked(Pressed USE, Primary/Secondary Attack).
    -- Creates new Touchable Screen Object for this Entity.
    -- Initialize some variables for this Touchable Screen Object.
    -- Make the local "renderCode" function as the Touchable Screen Object's 3D2D Screen Rendering function.
    -- Make the local "onMouseClick" function as the Touchable Screen Object's Input event.
    -- Draw Model.
    -- Render 3D2D Screen.
    -- Shift the Rendering Position.
    -- Rotate the Rendering Angle.
    -- Update the Rendering Position and angle of the Touchable Screen Object.
    -- fuckoff
    -- If The Screen has no Focus(If player is not touching it), Increase Idle Screen's Alpha.
else
    local gradient = nut.util.getMaterial("vgui/gradient-d")
    local gradient2 = nut.util.getMaterial("vgui/gradient-u")
    local oldTime = RealTime()
    local curTime = 0

    surface.CreateFont("nutLawTitle", {
        font = "Arial",
        extended = true,
        size = 66,
        weight = 1000
    })

    surface.CreateFont("nutLawSubTitle", {
        font = "Arial",
        extended = true,
        size = 44,
        weight = 1000
    })

    surface.CreateFont("nutLawContent", {
        font = "Arial",
        extended = true,
        size = 32,
        weight = 500
    })

    local function renderCode(self, ent, w, h)
        surface.SetDrawColor(0, 0, 0)
        surface.DrawRect(0, 0, w, h)
        local scale = 1 / self.scale
        nut.util.drawText(L"lotl", scale * 8, scale * 14, color_white, 3, 1, "nutFedTitle")
        nut.util.drawText(L"lotlSub", scale * 8, scale * 24, color_white, 3, 1, "nutFedSubTitle")
        surface.SetDrawColor(255, 255, 255)
        local bdw = w * 0.94
        surface.DrawRect(w / 2 - bdw / 2, scale * 35, bdw, 5)
        local laws = SCHEMA.laws

        for i = 1, 10 do
            nut.util.drawText(i .. ". " .. laws[i] or "", scale * 12, scale * 44 + (i - 1) * scale * 7, color_white, 3, 1, "nutLawContent")
        end
    end

    local function onMouseClick(self, key)
    end

    function ENT:Initialize()
        self.screen = nut.screen.new(400, 200, .3)
        self.screen.noClipping = false
        self.screen.fadeAlpha = 1
        self.screen.idxAlpha = {}
        self.screen.renderCode = renderCode
        self.screen.onMouseClick = onMouseClick
    end

    function ENT:Draw()
        self:DrawModel()
    end

    local pos, ang, renderAng
    local mc = math.Clamp

    function ENT:DrawTranslucent()
        local dist = LocalPlayer():GetPos():Distance(self:GetPos())

        if (dist < 1024) then
            self.screen:render()
        end
    end

    function ENT:Think()
        pos = self:GetPos()
        ang = self:GetAngles()
        pos = pos + ang:Up() * 0
        pos = pos + ang:Right() * 0
        pos = pos + ang:Forward() * 1
        renderAng = Angle(ang[1], ang[2], ang[3])
        renderAng:RotateAroundAxis(self:GetForward(), 0)
        renderAng:RotateAroundAxis(self:GetRight(), 0)
        renderAng:RotateAroundAxis(self:GetUp(), 0)
        self.screen.pos = pos
        self.screen.ang = renderAng
        self.screen.ent = self
        self.screen.w, self.screen.h, self.screen.scale = 225, 120, .2
        self.screen.renderCode = renderCode

        if (self.screen.hasFocus) then
            self.screen.fadeAlpha = mc(self.screen.fadeAlpha - FrameTime() * 4, 0, 1)
        else
            self.screen.fadeAlpha = mc(self.screen.fadeAlpha + FrameTime() * 2, 0, 1)
        end
    end
end