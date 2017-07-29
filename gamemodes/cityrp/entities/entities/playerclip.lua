AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
	self.obb = self:GetNWVector("obb")

	self:InitCollision()
end

hook.Add("PlayerAuthed", "clip.clinit", function(ply)
	for k, v in ipairs(ents.FindByClass("brush_playerclip")) do
		v:InitCollision()
	end
end)

function ENT:InitCollision()
	self.obb = self:GetNWVector("obb")
	self:DrawShadow(false)
	self:SetCollisionBounds(-self.obb, self.obb)
	self:SetSolid(SOLID_BBOX)
	self:SetMoveType(0)
	self:SetCustomCollisionCheck(true)
    self:SetSolidFlags(FSOLID_MAX_BITS)

	if CLIENT then
		self:SetRenderBounds(-self.obb, self.obb)
	end
end

hook.Add("ShouldCollide", "clip.colide", function(a, b)
   
	if a:GetClass() == "brush_playerclip" then
		return false
	end
end)


function ENT:Draw()
end


function ENT:BuildMeshObj()
	self.meshobj = Mesh()

	local origin = self:GetPos()
	local up = self:GetUp()
	local right = self:GetRight()
	local forward = self:GetForward()

	local sizex = math.abs(self.obb.y)
	local sizey = math.abs(self.obb.x)
	local sizez = math.abs(self.obb.z)

	local scale = 4
	local uv = 1
	local fou = sizex / sizez * scale
	local fov = 1 * scale
	local riu = sizey / sizez * scale
	local riv = 1 * scale
	local upu = sizey / sizex * scale / 2
	local upv = 1 * scale / 2

	local verts = { -- A table of 3 vertices that form a triangle
		-- down
		{ pos = origin - right*sizex + forward*sizey - up*sizez, u = 0, v = 0, normal = -up }, -- -+
		{ pos = origin - right*sizex - forward*sizey - up*sizez, u = upu, v = 0, normal = -up }, -- --
		{ pos = origin + right*sizex - forward*sizey - up*sizez, u = upu, v = upv, normal = -up }, -- +-

		{ pos = origin - right*sizex + forward*sizey - up*sizez, u = upu, v = upv, normal = -up }, -- -+
		{ pos = origin + right*sizex - forward*sizey - up*sizez, u = upu, v = 0, normal = -up }, -- +-
		{ pos = origin + right*sizex + forward*sizey - up*sizez, u = 0, v = 0, normal = -up }, -- ++

		-- up
		{ pos = origin - right*sizex + forward*sizey + up*sizez, u = 0, v = 0, normal = up }, -- -+
		{ pos = origin + right*sizex + forward*sizey + up*sizez, u = 0, v = upv, normal = up }, -- ++
		{ pos = origin + right*sizex - forward*sizey + up*sizez, u = upu, v = upv, normal = up }, -- +-

		{ pos = origin + right*sizex - forward*sizey + up*sizez, u = upu, v = upv, normal = up }, -- +-
		{ pos = origin - right*sizex - forward*sizey + up*sizez, u = upu, v = 0, normal = up }, -- --
		{ pos = origin - right*sizex + forward*sizey + up*sizez, u = 0, v = 0, normal = up }, -- -+

		-- forward
		{ pos = origin + right*sizex + forward*sizey + up*sizez, u = fou, v = fov, normal = forward }, -- ++
		{ pos = origin - right*sizex + forward*sizey + up*sizez, u = 0, v = fov, normal = forward }, -- -+
		{ pos = origin - right*sizex + forward*sizey - up*sizez, u = 0, v = 0, normal = forward }, -- --
		
		{ pos = origin - right*sizex + forward*sizey - up*sizez, u = 0, v = 0, normal = forward }, -- --
		{ pos = origin + right*sizex + forward*sizey - up*sizez, u = fou, v = 0, normal = forward }, -- +-
		{ pos = origin + right*sizex + forward*sizey + up*sizez, u = fou, v = fov, normal = forward }, -- ++

		-- backward
		{ pos = origin + right*sizex - forward*sizey + up*sizez, u = fou, v = fov, normal = -forward }, -- ++
		{ pos = origin - right*sizex - forward*sizey - up*sizez, u = 0, v = 0, normal = -forward }, -- --
		{ pos = origin - right*sizex - forward*sizey + up*sizez, u = 0, v = fov, normal = -forward }, -- -+
		
		{ pos = origin - right*sizex - forward*sizey - up*sizez, u = 0, v = 0, normal = -forward }, -- --
		{ pos = origin + right*sizex - forward*sizey + up*sizez, u = fou, v = fov, normal = -forward }, -- ++
		{ pos = origin + right*sizex - forward*sizey - up*sizez, u = fou, v = 0, normal = -forward }, -- +-
	
		-- left
		{ pos = origin - right*sizex + forward*sizey + up*sizez, u = riu, v = riv, normal = -right }, -- ++
		{ pos = origin - right*sizex - forward*sizey + up*sizez, u = 0, v = riv, normal = -right }, -- -+
		{ pos = origin - right*sizex - forward*sizey - up*sizez, u = 0, v = 0, normal = -right }, -- --
		
		{ pos = origin - right*sizex - forward*sizey - up*sizez, u = 0, v = 0, normal = -right }, -- --
		{ pos = origin - right*sizex + forward*sizey - up*sizez, u = riu, v = 0, normal = -right }, -- +-
		{ pos = origin - right*sizex + forward*sizey + up*sizez, u = riu, v = riv, normal = -right }, -- ++
		
		-- right
		{ pos = origin + right*sizex + forward*sizey + up*sizez, u = riu, v = riv, normal = right }, -- ++
		{ pos = origin + right*sizex - forward*sizey - up*sizez, u = 0, v = 0, normal = right }, -- --
		{ pos = origin + right*sizex - forward*sizey + up*sizez, u = 0, v = riv, normal = right }, -- -+
	
		{ pos = origin + right*sizex - forward*sizey - up*sizez, u = 0, v = 0, normal = right }, -- --
		{ pos = origin + right*sizex + forward*sizey + up*sizez, u = riu, v = riv, normal = right }, -- ++
		{ pos = origin + right*sizex + forward*sizey - up*sizez, u = riu, v = 0, normal = right }, -- +-
	}

	self.meshobj:BuildFromTriangles( verts ) -- Load the vertices into the IMesh object
end

function ENT:DrawTranslucent()
	self.obb = self:GetNWVector("obb")
	self:SetRenderBounds(-self.obb, self.obb)
	self:SetCollisionBounds(-self.obb, self.obb)
		
	if self.obb then
		self:BuildMeshObj()
	end

	if self.meshobj then
		render.SetMaterial(Material("effects/com_shield003a"))
		self.meshobj:Draw()
    else
		self:BuildMeshObj()
	end
end

function ENT:StartTouch(ent)
    if (!ent:IsPlayer() and !ent:IsWorld()) then
        ent:Remove()
    else
        if (ent:IsPlayer()) then
            local dir = self:GetPos() - ent:GetPos()
            dir:Normalize()
            dir.z = 0

            ent:SetPos(ent:GetPos() - dir *10)
        end
    end
end

function ENT:EndTouch(ent)
end

function ENT:KeyValue( key, value )
end

function ENT:OnRemove()
end

function ENT:AcceptInput( inputName, activator, called, data )
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end