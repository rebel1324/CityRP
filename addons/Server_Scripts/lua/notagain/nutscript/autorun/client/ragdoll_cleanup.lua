local gmod_ragdoll_fadetime = CreateClientConVar( "gmod_ragdoll_fadetime", 10.0, true, false )
local Tag="ragdoll_cleanup"
local white={
	["gib"]=true,
	["class C_ClientRagdoll"]=true,
}

local RagdollEntities = {}
local added
local function Think()

	local proc
	for ragdoll,_ in pairs(RagdollEntities) do
		proc = true
		if not ragdoll:IsValid() then
			RagdollEntities[ ragdoll ]= nil
			return
		end
			
		if ( !ragdoll.m_flFadeTime ) then

			ragdoll.m_flFadeTime	= CurTime() + gmod_ragdoll_fadetime:GetFloat()
			ragdoll.m_angLastAng	= ragdoll:GetAngles()
			ragdoll.m_vecLastPos	= ragdoll:GetPos()

		elseif ( ragdoll.m_flFadeTime <= CurTime() or
				 ragdoll.m_angLastAng ~= ragdoll:GetAngles() or
				 ragdoll.m_vecLastPos ~= ragdoll:GetPos() ) then

			if ( ragdoll.m_angLastAng == ragdoll:GetAngles() and
				 ragdoll.m_vecLastPos == ragdoll:GetPos() ) then

				ragdoll.m_bFadeOut		= true

			else

				ragdoll.m_flFadeTime	= nil

			end

		end

		if ( ragdoll.m_bFadeOut ) then

			local c = ragdoll:GetColor()
			c.a = math.Clamp( c.a - 2, 0, 255 )

			if ( c.a <= 0 ) then

				ragdoll:Remove()

				continue

			end

			ragdoll:SetColor( c )
			ragdoll:SetRenderMode(RENDERMODE_TRANSALPHA)

		end

	end
	if not proc then
		hook.Remove("Think",Tag)
		added = false
	end
end


local function OnEntityCreated(e)
	if not e or not e:IsValid() then return end
	local c = e:GetClass()
	if not white[c] then return end
	RagdollEntities[e]=true
	if not added then
		hook.Add( "Think", Tag, Think)
		added = true
	end
end
hook.Add("OnEntityCreated",Tag,OnEntityCreated)

for k,v in pairs(ents.FindByClass( "class C_ClientRagdoll" ) ) do
OnEntityCreated(v)
end

for k,v in pairs(ents.FindByClass( "gib" ) ) do
OnEntityCreated(v)
end

