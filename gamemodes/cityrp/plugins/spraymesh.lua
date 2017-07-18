PLUGIN.name = "Mesh Spray"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "This plugin allows you to spray images."

SprayMesh = {}
SprayMesh.Settings = {}
SprayMesh.Players = {} --stores steamid keys that contain url and delay/immediate vars serverside, and a meshdata var clientside

local settings = SprayMesh.Settings
settings.defaulturl = "http://i.imgur.com/bFMDdbZ.png" -- 라크 알피 디폴드.
settings.antigifurl = "http://i.imgur.com/bFMDdbZ.png"
settings.printdebug = false --print the time that a new mesh took to generate to all client consoles?
settings.delay = 3 --seconds between spraying per player
settings.res = 20 --mesh resolution (default: 20); this controls how many points make up the mesh grid, such as 20x20, which affects how smooth or jagged the mesh cuts off or wraps around the map diagonally
settings.coorddist = 3 --units between points (default: 2); resXcoorddist = the dimensions (size) of all player sprays
--tip: try to keep res as 10x the coord dist, and remember that the maximum res is 105 before this breaks
settings.shownames = false --don't touch this, it gets temporarily turned on by a console command

local variants = {
	"http://www.",
	"https://www.",
	"http://",
	"https://",
	"www.",
	"",
}
local sites = {
	"i%.imgur%.com",
	"youtube%.com",
	"%w+%.gfycat%.com",
}
local extensions = {
	"png","jpg","jpeg","bmp", --gif removed because it RUINS the framerate to have 20 unique gifs open (webms are much friendlier)
}
local extensionsanim = {
	"webm","gifv",
}
local function geturlinfo(url)
	local siteid, extension, extensionstable
	for k, v in pairs(variants) do
		for z, x in pairs(sites) do
			if string.find(url,"^"..v..x.."/",0,false) then --using patterns for *.gfycat.com, hopefully nothing blows up
				siteid = z --http://www.gammon.com.au/scripts/doc.php?lua=string.find
				break
			end
		end
	end
	if siteid then
		local found
		for k, v in pairs(extensions) do
			if string.find(url,"%."..v.."$",0,false) then
				extension = v
				extensionstable = extensions
				found = true
				break
			end
		end
		if !found then
			for k, v in pairs(extensionsanim) do
				if string.find(url,"%."..v.."$",0,false) then
					extension = v
					extensionstable = extensionsanim
					found = true
					break
				end
			end
		end
	end
	return siteid,extension,extensionstable
end
local function sanitizeurl(url)
	local ban = [=[{}[]:'",<>()]=]
	local bad = string.Explode("",ban,false)
	for k, v in pairs(bad) do
		url = string.Replace(url,v,"") --gsub uses patterns that conflict with the special characters
	end
	return url
end
local function fixurl(url,ply) --note: double slashes aka // break getting the client convar; everything after // is gone; http://abc = http:
	if (url:find("http://")) then
		ply:notify("http:// is not allowed.")
	end

	if url == nil || type(url) != "string" || url == "" then url = settings.defaulturl end
	if url != sanitizeurl(url) then url = settings.defaulturl end
	local allowed = false
	local siteid,extension,extensionstable = geturlinfo(url)

	if siteid == 1 then --imgur
		if extension != nil then
			allowed = true
		end
	elseif siteid == 2 then --youtube
		if ply == nil || ply:IsAdmin() || ply:IsSuperAdmin() then
			allowed = true
		end
	elseif siteid != nil then --gfycat
		allowed = true
	end

	if !allowed then
		if settings.printdebug then print("INVALID URL: "..url) end
		url = settings.defaulturl
	end
	print(url)
	return url
end

nut.command.add("spraymesh", {
	syntax = "<URL>",
	onRun = function(client, arguments)
		local url = table.concat(arguments, "")

		local char = client:getChar()
		local spray = char:getInv():hasItem("spraycan")
		if (!char or !spray) then
			client:notify("스프레이를 가지고 있어야 합니다.")
			return false
		else
			spray:remove()
		end

		if client && client != NULL && client.SteamID then
			if settings.printdebug then print("playerspray") end
			local clientID = client:SteamID()
			SprayMesh.Players[clientID] = SprayMesh.Players[clientID] || {}
			if (!SprayMesh.Players[clientID].delay || SprayMesh.Players[clientID].immediate) && client:Alive() then
				local tr = client:GetEyeTrace()
				if tr.Hit && tr.Entity:IsWorld() then
					SprayMesh.SendSpray(tr.HitPos, tr.HitNormal, client, url)
				end
			end
		end
	end,
	alias = {"스프레이", "그림"}
})

if SERVER then
	AddCSLuaFile()
	util.AddNetworkString("SprayMesh_SendSpray")
	util.AddNetworkString("SprayMesh_SendURL")

	function SprayMesh.SendSpray(hitpos, hitnormal, ply, url)
		if ply && ply != NULL && ply.SteamID then
			local plyID = ply:SteamID()
			net.Start("SprayMesh_SendSpray")
				net.WriteVector(hitpos)
				net.WriteVector(hitnormal)
				net.WriteEntity(ply)
				SprayMesh.Players[plyID] = SprayMesh.Players[plyID] || {}
				SprayMesh.Players[plyID].url = fixurl(url or settings.defaulturl, ply)
				if settings.printdebug then print("sending spray: "..SprayMesh.Players[plyID].url) end
				net.WriteString(SprayMesh.Players[plyID].url)
			net.Broadcast()
		end
	end
else
	CreateClientConVar("SprayMesh_URL",settings.defaulturl,true,true)
	CreateClientConVar("SprayMesh_EnableVideos",0,true,false)

	net.Receive("SprayMesh_SendSpray",function(length)
		local hitpos, hitnormal, ply, url = net.ReadVector(), net.ReadVector(), net.ReadEntity(), net.ReadString()
		if settings.printdebug then print("receiving spray: "..url) end
		SprayMesh.PlaceSpray(hitpos,hitnormal,ply,url)
	end)
	function SprayMesh.Instructions()
		chat.AddText("타인에게 불쾌감을 주는 스프레이를 뿌리면 불이익을 받을 수 있습니다.")
	end

	concommand.Add("SprayMesh_Help",function(ply,cmd,args,argstr)
		SprayMesh.Instructions()
	end)

	concommand.Add("SprayMesh_ShowNames",function(ply,cmd,args,argstr)
		settings.shownames = true
		local t = CurTime()
		settings.shownamestime = CurTime()
		timer.Simple(10,function()
			if t == settings.shownamestime then --easy way to allow overlapping commands
				settings.shownames = false
			end
		end)
	end)
	
	--url material solver
	SprayMesh.imats = {}
	local imats = SprayMesh.imats
	local htmlpanels = {} --where panels are during loading
	local htmlpanelsanim = {} --where panels are for animation, after loading
	local nospraymat = CreateMaterial("SprayMesh_nospraymat","UnlitGeneric",{
		["$basetexture"] = "models/shadertest/shader5",
		["$vertexcolor"] = 1, --allows custom coloring
		["$vertexalpha"] = 1, --allows custom coloring
		["$model"] = 1, --???
	})
	local function generatehtmlpanel(url,urloriginal,callback)
		if !string.find(url,"^http://",0,false) then url = "http://"..url end
		local c = {} --persisting container, for cutting short anims but also drawing an overlay
		c.panel = vgui.Create("DHTML")
		local panel = c.panel
		local size = 512
		panel:SetSize(size,size)
		panel:SetAllowLua(false)
		function panel:ConsoleMessage(msg) end
		panel:SetAlpha(0)
		panel:SetMouseInputEnabled(false)
		panel:SetScrollbars(false)
		SprayMesh.HTMLHandlers.Get(url,size,c)
		c.origurl = urloriginal
		c.callback = callback
		c.RT = GetRenderTarget(url,size,size)
		function c:fancydraw()
			if !self.finalimat then return end
			if settings.shownames || (self.animkilled && GetConVarNumber("SprayMesh_EnableVideos") != -1) then --convar -1 = don't show names or warnings, only the last unkilled frame
				self.finalimat:SetTexture("$basetexture",self.RT) --this makes the spray invisible/black for animkilled sprays...
			else 
				self.finalimat:SetTexture("$basetexture",self.htmlmat:GetName()) --fps saver, or when not disabling video or showing names
				return
			end
			local oldw, oldh, oldrt = ScrW(), ScrH(), render.GetRenderTarget()
			render.SetRenderTarget(self.RT)
			render.SetViewPort(0,0,size,size)
			cam.Start2D()
				local spraytex
				if !self.animkilled then
					--tried to find a way around this, but the best solution requires turning on the info BEFORE spraying during it
					--and that spams the console with MISSING Vgui material __vgui_texture_num
					--otherwise it appears solid black, and spams the console that way
					--so, when the anim is killed, a black box will be drawn without spam (the "best solution" still works, but isn't very useful)
					surface.SetDrawColor(255,255,255,255)
					spraytex = surface.GetTextureID(self.htmlmat:GetName())
				else
					surface.SetDrawColor(0,0,0,255)
					spraytex = surface.GetTextureID("models/shadertest/shader5")
				end
				surface.SetTexture(spraytex)
				surface.DrawTexturedRect(0,0,size,size)
				surface.SetDrawColor(255,255,255,255)
				
				if settings.shownames then
					surface.SetFont("TargetID")
					surface.SetTextColor(255,105,0,255)
					local plys = self.plynamesassociated || {}
					for k, v in pairs(plys) do
						if IsValid(v) || type(v) == "table" then --table for debug
							surface.SetTextPos(10,15*k)
							if v && v != NULL && v.SteamID then
								surface.DrawText(v:Nick().." ("..v:SteamID()..")")
							end
						end
					end
					surface.SetTextPos(10,15*33)
					surface.DrawText(urloriginal)
				end
				
				if self.animkilled && GetConVarNumber("SprayMesh_EnableVideos") != -1 then
					surface.SetFont("TargetID")
					surface.SetTextColor(255,100,100,255)
					surface.SetTextPos(25,175)
					surface.DrawText("This spray is a video, but you have videos turned off.")
					surface.SetTextPos(25,175+15)
					surface.DrawText("If you just set them to on, you must rejoin before this")
					surface.SetTextPos(25,175+15*2)
					surface.DrawText("spray will become visible.")
					surface.SetTextPos(25,175+15*5)
					surface.DrawText("Use SprayMesh_Help in the console for more information.")
				end
			cam.End2D()
			render.SetRenderTarget(oldrt)
			render.SetViewPort(0,0,oldw,oldh)
		end
		table.insert(htmlpanels,c)
	end
	local function generatehtmltexture(url,replacemat,callback)
		--[[how to use:
			MyNewImaterial = generatehtmltexture(url,replacemat,function(imat)
				custom callback code, for when the image is fully loaded and the replacemat has been applied
				imat argument is the loaded imaterial
			end)
			replacemat is a table pointer, and needs to contain an imaterial key
		]]
		if settings.printdebug then print("generating texture for: "..url) end
		if imats[url] == nil then
			imats[url] = {} --pending table
			table.insert(imats[url],{replacemat,callback})
			generatehtmlpanel(url.."?uniquerequest="..os.time()..CurTime(),url,function(imat)
				--the uniquerequest guff is to stop the game from ever using its internal cache of web resources, because it returns bonkers sizes at random
				if type(imats[url]) == "table" then --should be
					for k, v in pairs(imats[url]) do
						v[1].imaterial = imat
						if v[2] then v[2](imat) end
						if settings.printdebug then print("finished; replacing dummy texture") end
					end
					imats[url] = imat
				end
			end)
			if settings.printdebug then print("generating, giving dummy texture") end
			return nospraymat
		elseif type(imats[url]) == "table" then --pending table; texture is still generating
			if settings.printdebug then print("generated texture is currently pending...") end
			table.insert(imats[url],{replacemat,callback})
			return nospraymat
		else
			if settings.printdebug then print("generated texture already exists") end
			return imats[url]
		end
	end
	hook.Add("Think","SprayMeshGenerate",function()
		for k, v in pairs(htmlpanels) do
			local htmlmat = v.panel:GetHTMLMaterial()
			if v && htmlmat then 
				if settings.printdebug then print("FINISHED") end
				local w, h = ScrW(), ScrH()
				local scalex, scaley = 1, h/w
				if w < h then scalex, scaley = w/h, 1 end
				local uid = string.Replace(htmlmat:GetName(),"__vgui_texture_","")
				local finalimat = CreateMaterial("spraymesh_"..uid,"UnlitGeneric",{
					["$basetexture"]=htmlmat:GetName(), 
					--["$basetexturetransform"]="center 0 0 scale "..scalex.." "..scaley.." rotate 0 translate 0 0", 
					["$vertexcolor"] = 1,
					["$vertexalpha"] = 1,
					["$model"]=1
				})
				v.callback(finalimat)
				
				timer.Simple(1,function()
					if GetConVarNumber("SprayMesh_EnableVideos") == 0 && IsValid(v.panel) then
						local siteid,extension,extensionstable = geturlinfo(v.origurl)
						if siteid == 2 || extensionstable == extensionsanim then
							v.panel:Remove()
							v.animkilled = true
						end
					end
				end)
				table.remove(htmlpanels,k)
				table.insert(htmlpanelsanim,v)
				v.finalimat = finalimat
				v.htmlmat = htmlmat
				break
			else
				if settings.printdebug then print("GENERATING...") end
			end
		end
	end)
	hook.Add("Think","SprayMeshAnimate",function()
		for k, v in pairs(htmlpanelsanim) do
			if v then 
				if v.animonerun then
					v:animonerun(v.panel)
					v.animonerun = nil
				end
				if v.animthink then
					v:animthink(v.panel)
				end
				if v.origurl then
					v.plynamesassociated = {}
					for z, x in pairs(SprayMesh.Players) do --not player get all because debug
						if SprayMesh.Players[z] != nil  && SprayMesh.Players[z].meshdata != nil then
							if SprayMesh.Players[z].meshdata.url == v.origurl then
								table.insert(v.plynamesassociated,x.ply) --table.ply for debug
							end
						end
					end
					if #v.plynamesassociated == 0 then imats[v.origurl] = nil end
					if imats[v.origurl] == nil then
						v.panel:Remove()
						v = nil
						table.remove(htmlpanelsanim,k)
						break
					end
				else
					table.remove(htmlpanelsanim,k)
					break
				end
			else
				table.remove(htmlpanelsanim,k)
				break
			end
		end
		for k, v in pairs(SprayMesh.Players) do --optimizer
			local keep = false
			for z, x in pairs(player.GetAll()) do
				if x && x != NULL && x.SteamID then
					if k == x:SteamID() then
						keep = true
					end
				end
			end
			if !keep then
				local t = SprayMesh.Players[k]
				if v.origurl then
					imats[v.origurl] = nil
				end
				t = nil
				break
			end
		end
	end)
	hook.Add("HUDPaint","SprayMeshAnimate",function()
		for k, v in pairs(htmlpanelsanim) do
			if v then 
				if v.fancydraw then
					v:fancydraw()
				end
			else
				table.remove(htmlpanelsanim,k)
				break
			end
		end
	end)
	
	local function copyvert(copy,u,v,norm,bnorm,tang)
		u = u || 0; v = v || 0; norm = norm || 1; bnorm = bnorm || Vector(0,0,0); tang = tang || 1
		local t = table.Copy(copy)
		t.u, t.v, t.normal, t.bitnormal, t.tangent = u, v, norm, bnorm, tang
		return t
	end
	-- D C = ix+0,iy+1 ix+1,iy+1
	-- A B = ix+0,iy+0 ix+1,iy+0
	local function addsquaretopoints(x,y,points,coords) --bottom left corner coord
		--[[local _a = copyvert(coords[x+0][y+0],0,0) --repeating texture per square
		local _b = copyvert(coords[x+1][y+0],1,0) --probably also needs a y flip
		local _c = copyvert(coords[x+1][y+1],1,1)
		local _d = copyvert(coords[x+0][y+1],0,1)]]
		local rm1 = settings.res-1
		local __a = coords[x+0][y+0]
		local __b = coords[x+1][y+0]
		local __c = coords[x+1][y+1]
		local __d = coords[x+0][y+1]
		if __a.bad then __a = coords[x+0][math.Clamp(y+1,0,settings.res-1)] end
		if __b.bad then __b = coords[x+1][math.Clamp(y+1,0,settings.res-1)] end
		if __c.bad then __c = coords[x+1][math.Clamp(y+0,0,settings.res-1)] end
		if __d.bad then __d = coords[x+0][math.Clamp(y+0,0,settings.res-1)] end
		if __a.bad then __a = coords[math.Clamp(x+1,0,settings.res-1)][math.Clamp(y+1,0,settings.res-1)] end --probably could simply replace the other but eh
		if __b.bad then __b = coords[math.Clamp(x+0,0,settings.res-1)][math.Clamp(y+1,0,settings.res-1)] end
		if __c.bad then __c = coords[math.Clamp(x+0,0,settings.res-1)][math.Clamp(y+0,0,settings.res-1)] end
		if __d.bad then __d = coords[math.Clamp(x+1,0,settings.res-1)][math.Clamp(y+0,0,settings.res-1)] end
		local _a = copyvert(__a,(x+0)/rm1,1-((y+0)/rm1)) --stretch texture over all squares
		local _b = copyvert(__b,(x+1)/rm1,1-((y+0)/rm1))
		local _c = copyvert(__c,(x+1)/rm1,1-((y+1)/rm1))
		local _d = copyvert(__d,(x+0)/rm1,1-((y+1)/rm1))
		table.insert(points,_a)--adccba
		table.insert(points,_d)
		table.insert(points,_c)
		table.insert(points,_c)
		table.insert(points,_b)
		table.insert(points,_a)
	end
	local i = 0
	local function fakespray(ii,newurl)
		newurl = newurl || false
		local tr = LocalPlayer():GetEyeTrace()
		local url = "youtube.com/watch?v=SyfxIryiD8A"
		if newurl then url = url.."?i="..i end
		local fakeply = {}
		fakeply.name = "bob_"..i
		i = i+1
		function fakeply:Nick()
			return self.name
		end
		function fakeply:SteamID()
			return "STEAM_"..self:Nick()
		end
		SprayMesh.PlaceSpray(tr.HitPos+Vector(0,-50*ii,0),tr.HitNormal,fakeply,url)
	end
	local function fakespraymulti(newurl) --delocalize for testing optimization
		for ii = 1, 20 do
			fakespray(ii,newurl)
		end
	end
	function SprayMesh.PlaceSpray(hitpos,hitnormal,ply,url)
		if ply == LocalPlayer() && (url == settings.defaulturl || url == "http://"..settings.defaulturl || url == "https://"..settings.defaulturl) then
			SprayMesh.Instructions()
		end
		if ply == nil || ply == NULL || ply.SteamID == nil then return end
		sound.Play("SprayCan.Paint",hitpos,60,100,.3)
		local timestart = os.time()
		local pos = hitpos+hitnormal --one unit out
		local points = {}
		local coords = {}
		for ix = 0, settings.res-1 do
			coords[ix] = {}
			for iy = 0, settings.res-1 do
				coords[ix][iy] = {}
				local coord = coords[ix][iy]
				local tangang = hitnormal:Angle()
				coord.pos = pos+(-(tangang:Right()*ix)+(tangang:Up()*iy))*settings.coorddist
				coord.pos = coord.pos+(tangang:Right()*settings.coorddist*settings.res/2)-(tangang:Up()*settings.coorddist*settings.res/2)
				if !(ix == 0 && iy == 0) then
					local testtr = util.TraceLine({
						start = coord.pos+hitnormal*15,
						endpos = coord.pos-hitnormal*15,
						filter = function(ent)
							if ent:IsWorld() then
								return true
							end
						end
					})
					if !testtr.Hit || !testtr.HitWorld then
						if ix == 0 then
							coord.pos = coords[ix][iy-1].pos
						else
							coord.pos = coords[ix-1][iy].pos
						end
						coord.bad = true
					else
						coord.pos = testtr.HitPos+hitnormal
					end
				end
				coord.u, coord.v = 0, 0
				coord.bitnormal = 1
				coord.tangent = 1
				coord.normal = hitnormal
				local lcol = render.GetLightColor(coord.pos)*638
				local basec = 20
				coord.color = Color(lcol.x+basec,lcol.y+basec,lcol.z+basec,255)
			end
		end
		for ix = 0, settings.res-2 do
			for iy = 0, settings.res-2 do
				addsquaretopoints(ix,iy,points,coords)
			end
		end
		local meshdata = {}
		meshdata.mesh = Mesh()
		meshdata.mesh:BuildFromTriangles(points)
		meshdata.imaterial = generatehtmltexture(url, meshdata)
		if ply == nil || ply == NULL || ply.SteamID == nil then return end
		local plyID = ply:SteamID()
		SprayMesh.Players[plyID] = SprayMesh.Players[plyID] || {}
		if SprayMesh.Players[plyID].meshdata then
			if SprayMesh.Players[plyID].meshdata.mesh then
				if SprayMesh.Players[plyID].meshdata.mesh != NULL then
					SprayMesh.Players[plyID].meshdata.mesh:Destroy()
				end
			end
		end
		SprayMesh.Players[plyID].meshdata = meshdata
		SprayMesh.Players[plyID].meshdata.url = url
		SprayMesh.Players[plyID].ply = ply --for debug
		if settings.printdebug then print("Spray mesh created in: "..os.time()-timestart.."s") end
	end
	
	function SprayMesh.RemoveSprays() --removes all fully loaded sprays
		for k, v in pairs(htmlpanelsanim) do
			imats[v.origurl] = nil
			v.panel:Remove()
		end
		for k, v in pairs(SprayMesh.Players) do
			if v.meshdata && v.meshdata.mesh then v.meshdata.mesh:Destroy() v.meshdata.mesh = nil end
		end
		htmlpanelsanim = {}
	end
	concommand.Add("SprayMesh_Clear",function(ply,cmd,args,argstr)
		SprayMesh.RemoveSprays()
	end)
	
	hook.Add("PostDrawOpaqueRenderables","SprayMesh",function()
		for k, v in pairs(SprayMesh.Players) do
			if v.meshdata && v.meshdata.mesh && v.meshdata.mesh != NULL then
				render.SetMaterial(v.meshdata.imaterial)
				v.meshdata.mesh:Draw()
			end
		end
	end)
	
	SprayMesh.HTMLHandlers = {}
	function SprayMesh.HTMLHandlers.Get(url,size,panelcontainer)
		local siteid,extension,extensionstable = geturlinfo(url)
		if siteid == 1 || siteid == 3 then --imgur/gfycat
			url = string.Explode("?",url,false)[1] --remove uniquerequest garbage (youtube handler does it differently)
			siteid, extension, extensionstable = geturlinfo(url) --needs redoing for the extension
			if extensionstable == extensions then
				SprayMesh.HTMLHandlers.imgurregular(url,size,panelcontainer)
			elseif extensionstable == extensionsanim then
				return SprayMesh.HTMLHandlers.imguranim(url,size,panelcontainer)
			end
		elseif siteid == 2 then --youtube
			return SprayMesh.HTMLHandlers.youtube(url,size,panelcontainer)
		end
		return SprayMesh.HTMLHandlers.imgurregular(url,size,panelcontainer)
	end
	function SprayMesh.HTMLHandlers.imgurregular(url,size,panelcontainer) --now with antigif!
		panelcontainer.panel:SetHTML([[
			<!DOCTYPE html>
			<html>
				<head>
					<meta charset="UTF-8">
					<title>title</title>
					<style type = "text/css">
						html {
							overflow: hidden;
						}
					</style>
				</head>
				<body scroll="no">
					<div id='sprayimage'></div>
					<script>
						//thanks to http://www.andygup.net/tag/magic-number/
						var imageContainer = document.getElementById('sprayimage');
						function getImageType(arrayBuffer){
							var type = "";
							var dv = new DataView(arrayBuffer,0,5);
							var nume1 = dv.getUint8(0,true);
							var nume2 = dv.getUint8(1,true);
							var hex = nume1.toString(16) + nume2.toString(16) ;
							switch(hex){
								case "8950":
									type = "image/png";
									break;
								case "4749":
									type = "image/gif";
									break;
								case "424d":
									type = "image/bmp";
									break;
								case "ffd8":
									type = "image/jpeg";
									break;
								default:
									type = null;
									break;
							}
							return type;
						}
						function getImageFromServer(path,callback){
							var xhr = new XMLHttpRequest();
							xhr.path = path;
							xhr.open("GET",path,true);
							xhr.responseType = "arraybuffer";
							xhr.onload = function(e){
								if(this.status == 200){
									var imageType = getImageType(this.response);
									callback(imageType);
								}
								else{
									//console.log("Problem retrieving image " + JSON.stringify(e))
									callback("NIL");
								}
							}
							xhr.send();
						}
						function makeimage(){
							var src = "]]..url..[[";
							getImageFromServer(src,function(imageType){
								console.log("Image Type: "+imageType);
								if (imageType == "image/gif") {src = "]]..settings.antigifurl..[["};
								var sprayImage = document.createElement('img');
								sprayImage.src = src;
								imageContainer.appendChild(sprayImage);
								sprayImage.onload = function(){
									if (sprayImage.naturalHeight > sprayImage.naturalWidth) {
										sprayImage.style.height = "]]..size..[[px";
										sprayImage.style.width = "auto";
									}else{
										sprayImage.style.height = "auto";
										sprayImage.style.width = "]]..size..[[px";
									}
								}
							});
						};
						makeimage();
					</script>
				</body>
			</html>]]
		)
	end
	function SprayMesh.HTMLHandlers.imguranim(url,size,panelcontainer) 
	url = string.gsub(url,"gifv$","webm") --i don't think mp4 is supported by source, RIP
	panelcontainer.panel:SetHTML([[
		<!DOCTYPE html>
		<html>
			<head>
				<meta charset="UTF-8">
				<title>title</title>
				<style type = "text/css">
					html {
						overflow: hidden;
					}
				</style>
			</head>
			<body scroll="no">
				<video id="sprayimage" onload="fiximage()" src="]]..url..[[" style="width:100%;height:auto" autoplay loop muted/>
				<script>
					function fiximage(){
						var img = document.getElementById("sprayimage");
						if (img.height > img.width) {
							img.style.height = "]]..size..[[px";
							img.style.width = "auto";
						}
					};
				</script>
			</body>
		</html>]])
	end
	function SprayMesh.HTMLHandlers.youtube(url,size,panelcontainer)
		--animonerun runs once before animthink and is then destroyed
		--animthink can create new animonerun functions if so desired
		panelcontainer.animonerun = function(pan)
			
		end
		function panelcontainer:animthink(pan)
			if pan && IsValid(pan) && pan != NULL then
				pan:RunJavascript("fixvideo();")
			end
		end
		local id = url
		local strippers = {"https://","http://","www.","youtube.com/","","watch%?","v=","/v/","/embed/"} --watch%? = escaping the ? from patterns
		for k, v in pairs(strippers) do
			id = string.gsub(id,v,"")
		end
		id = string.Explode("&",id,false)[1]
		id = string.Explode("?",id,false)[1]
		--local link = "http://www.youtube.com/v/"..id.."&loop=1&version=3&autoplay=1&playlist="..id.."&enablejsapi=1"
		local link = "https://www.youtube.com/embed/"..id.."?rel=0&amp;controls=0&autoplay=1&enablejsapi=1&showinfo=0&loop=1&version=3&playlist="..id..";showinfo=0"
		panelcontainer.panel:SetHTML([[
		<!DOCTYPE html>
		<html>
			<head>
				<meta charset="UTF-8">
				<title>title</title>
				<style type = "text/css">
					html {
						overflow: hidden;
					}
				</style>
			</head>
			<body scroll="no">
				<iframe id="sprayvideo" onload="fixvideo()" width="512" height="288" src="]]..link..[[" frameborder="0" allowfullscreen></iframe>
				<script>
					function callPlayer(func, args) {
						var iframe = document.getElementById("sprayvideo");
						var src = iframe.getAttribute("src");
						if (src) {
							if (src.indexOf("youtube.com/embed") != -1) {
								iframe.contentWindow.postMessage(JSON.stringify({
									"event": "command",
									"func": func,
									"args": args || []
								}), "*");
							}
						}
					};
					function fixvideo(){
						callPlayer("mute");
					};
				</script>
			</body>
		</html>]])
	end
end