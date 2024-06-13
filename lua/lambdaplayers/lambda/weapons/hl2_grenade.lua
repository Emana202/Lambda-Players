local IsValid = IsValid
local CurTime = CurTime

local ents_Create = ents.Create

table.Merge( _LAMBDAPLAYERSWEAPONS, {

    grenade = {
        model = "models/weapons/w_grenade.mdl",
        origin = "Half-Life 2",
        prettyname = "Grenade",
        holdtype = "grenade",
        killicon = "npc_grenade_frag",
        bonemerge = true,
        keepdistance = 500,
        attackrange = 1000,
        dropentity = "weapon_frag",

        OnAttack = function( self, wepent, target )
            local grenade = ents_Create( "npc_grenade_frag" )
            if !IsValid( grenade ) then return end

            self.l_WeaponUseCooldown = CurTime() + LambdaRNG( 1.8, 2.25, false )

            self:RemoveGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE )
            self:AddGesture( ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE )

            grenade:SetPos( self:GetPos() + self:GetUp() * 60 + self:GetForward() * 20 + self:GetRight() * -10 )
            grenade:Fire( "SetTimer", 3, 0 )
            grenade:SetSaveValue( "m_hThrower", self )
            grenade:SetOwner( self )
            grenade:Spawn()
            grenade:SetHealth( 30 )

            local throwForce = 1200
            local throwDir = self:GetForward()
            local throwSnd = "WeaponFrag.Throw"
            if IsValid( target ) then
                throwDir = ( target:GetPos() - grenade:GetPos() ):GetNormalized()
                if self:IsInRange( target, 350 ) then
                    throwForce = 400
                    throwSnd = "WeaponFrag.Roll"
                end
            end
            wepent:EmitSound( throwSnd )

            local phys = grenade:GetPhysicsObject()
            if IsValid( phys ) then
                phys:ApplyForceCenter( throwDir * throwForce )
                phys:AddAngleVelocity( Vector( 600, LambdaRNG( -1200, 1200) ) )
            end

            return true
        end,

        islethal = true,
    }

})