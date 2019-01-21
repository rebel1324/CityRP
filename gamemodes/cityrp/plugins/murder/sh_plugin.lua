PLUGIN.name = "Detective Evidence"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "you've got murdered, congrats"

function PLUGIN:PlayerDeath(victim, inflictor, attacker)
    -- do not count law death
    if (IsValid(attacker) and attacker:IsPlayer()) then
        local char = attacker:getChar()

        if (char) then
            local class = char:getClass()
            local classData = nut.class.list[class]
            
            if (classData and classData.law) then
                return
            end
        end
        -- do not count natural death
        if (game.GetWorld() == attacker) then
            return
        end
    else
        return
    end

    -- do not count suicide
    if (attacker == victim) then
        return
    end

    if (IsPurge) then
        return
    end

    local ent = ents.Create("nut_evidence")
    ent.victim = victim
    ent.attacker = attacker
    ent.inflictor = inflictor
    ent:SetPos(victim:GetPos())
    ent:Spawn()
end

function PLUGIN:OnPlayerReportItem(item, reporter, attacker)
    if (IsValid(attacker)) then
        attacker:wanted(true, "사설 탐정의 고발!", attacker)
    end

    if (IsValid(reporter)) then
        local char = reporter:getChar()

        if (char) then
            char:giveMoney(1500)
        end
    end
end
