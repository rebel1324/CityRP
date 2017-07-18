do
	if (SERVER) then
		netstream.Hook("feedbackScreen", function(client)
			client:ConCommand("say 공지를 읽었습니다!")
		end)
	else
		local scrSize = 10
		SCREEN_1 = SCREEN_1 or LuaScreen()
		SCREEN_1.pos = Vector(-2082.439331, -4103.122070, -190.380630)
		SCREEN_1.ang = Angle(0, 180, 0)
		SCREEN_1.noClipping = false
		SCREEN_1.w = 16*scrSize
		SCREEN_1.h = 9*scrSize
		SCREEN_1.scale = .17

		-- Create Text Markup Object.
		timer.Simple(1, function()
			MRKPOBJ = nut.markup.parse(
					[[
<font=nutBigFont><color=200, 200, 80>행복한 라크 RP서버에 오신걸 환영합니다.</font>
<font=nutMediumFont>REALKALLOS / BLACK TEA 가 운영하는 서버입니다</color>

반드시 나가기전에 이 내용을 보아 게임 플레이상에 불이익을 받지 않도록 노력해주시길 바랍니다. <color=255, 80, 80>이 글을 읽지않고 생긴 모든 피해는 서버 및 어드민이 책임지지 않으며 전적으로 모든 책임은 플레이어에게 있음을 알립니다.</color>

이 글은 위쪽 테두리에서 아래쪽 테두리로 조준을 하여 천천히 스크롤해서 읽어 내려갈 수 있습니다. 
그리고 클릭을 하여 주변사람들에게 이 글을 읽었다는 것을 알릴 수 있습니다.

이 서버는 NutScript 1.1을 기반으로 돌아가고 있으며, 예전 DarkRP기반 라크 RP 서버와는 많은 경험의 차이가 생길 수 있습니다. 
이로인하여 생긴 버그나 기타 게임플레이상의 문제점에 대해서 언제든지 어드민이나 개발자에게 피드백을 준다면 모두 같이 재미있는 게리모드 RP 서버를 만들 수 있습니다.
버그를 악용하거나 알리지 않고 게임내에서 부당한 이득을 챙긴 경우에는 본 서버 및 계열 서버에서 영구히 추방당할 수 있습니다.

중력건이 없는건, 새로운 손 SWEP이 있기 때문입니다. 손을 들고 오른쪽 클릭을 하면 시체나 물건을 들어서 옮길 수 있습니다. 
그리고 든 상태로 왼쪽 클릭을 하면 그 물건을 던질 수 있습니다. 

F1를 눌러서 RP 메뉴를 열 수 있습니다. '직업'란에서 당신의 직업을 바꿀 수 있고, 아이템의 구매는 아이템 상점에서 가능합니다. 기계 상점에서는 따로 설치하는 기계를 구매할 수 있으며, 이곳에서 구매한 물품은 인벤토리에 다시 넣을 수 없습니다.
F1의 인벤토리에는 많은 유용한 아이템을 넣어서 RP에 필요한 일을 진행 할 수 있습니다. 
새롭고 강력한 아이템을 만들기 위해서는 설계도가 필요한데, 설계도는 랜덤한 찬스로 얻을 수 있습니다.
<color=80, 255, 80>Cheers for very good schema of NutScript 1.1.</color>
					]]
			, SCREEN_1:getWide() - 20)
		end)

		SCREEN_1.scrollAmount = 0
		SCREEN_1.scrollPos = 0
		SCREEN_1.scrollTargetPos = 0
		SCREEN_1.renderCode = function(scr, ent, wide, tall)
			draw.RoundedBox(0, 0, 0, wide, tall, Color(0, 0, 0, 150))

			SCREEN_1.scrollAmount = math.max(MRKPOBJ:getHeight() - tall + 20, 0)

			if (scr.hasFocus) then
				local mx, my = scr:mousePos()
				local prec = my/tall
				SCREEN_1.scrollTargetPos = (prec) * -SCREEN_1.scrollAmount
			else
				SCREEN_1.scrollTargetPos = (math.Clamp(((RealTime() / tall*10) % 1.7) - .2, 0, 1) * -SCREEN_1.scrollAmount)
			end

			SCREEN_1.scrollPos = Lerp(FrameTime()*7, SCREEN_1.scrollPos, SCREEN_1.scrollTargetPos)
			if (MRKPOBJ) then
				MRKPOBJ:draw(15, SCREEN_1.scrollPos + 10, 3, 2)
			end
		end
		SCREEN_1.onMouseClick = function(self, key)
			if (key) then
				netstream.Start("feedbackScreen")
			end
		end
	end
end

do
	if (SERVER) then
	else
	
	end
end


do
	if (SERVER) then
	else
		
	end
end

if (CLIENT) then
	hook.Add("Think", "LUASCREEN_GO", function()
		SCREEN_1:think()
		SCREEN_2:think()
		SCREEN_3:think()
	end)
	
	hook.Add("PostDrawTranslucentRenderables", "LUASCREEN_GO", function()
		SCREEN_1:render()
		SCREEN_2:render()
		SCREEN_3:render()
	end)
else
	hook.Add("Think", "aaoa", function()
	end)
	
	hook.Add("PostDrawTranslucentRenderables", "aaoa", function()
	end)
end