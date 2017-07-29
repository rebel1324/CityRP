FindMetaTable("Entity").CollisionRulesChanged = function(self)
    local cg = self:GetCollisionGroup()
    self:SetCollisionGroup(cg==COLLISION_GROUP_DEBRIS and COLLISION_GROUP_WEAPON or COLLISION_GROUP_DEBRIS)
    self:SetCollisionGroup(cg)
end