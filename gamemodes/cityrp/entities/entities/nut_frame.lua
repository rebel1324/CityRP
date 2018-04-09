AddCSLuaFile()
ENT.Type = "anim"
ENT.PrintName = "Frame"
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
        self:SetModel("models/props_c17/Frame002a.mdl")
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
    local function renderCode(self, ent, w, h)
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