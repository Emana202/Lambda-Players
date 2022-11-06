local util_Effect = util.Effect
local random = math.random
table.Merge( _LAMBDAPLAYERSWEAPONS, {

    stunstick = {
        model = "models/weapons/w_stunbaton.mdl",
        origin = "Half Life: 2",
        prettyname = "Stunstick",
        holdtype = "melee",
        ismelee = true,
        bonemerge = true,
        keepdistance = 10,
        attackrange = 50,
        
        -- Custom effect similar to player stunstick
        Draw = function( lambda, wepent )
            if IsValid( wepent ) then
            
                local stunstickGlow = Material("effects/blueflare1")
                local size = random(4, 6)
                local drawPos = ( wepent:GetPos() - wepent:GetForward() * 12 - wepent:GetRight() + wepent:GetUp() )
                local color = Color(255, 255, 255)

                render.SetMaterial( stunstickGlow )
                render.DrawSprite( drawPos, size*2, size*2, color)

            end
        end,
        
        OnEquip = function( lambda, wepent )
            wepent:EmitSound("Weapon_StunStick.Activate")
        end,

        damage = 10,
        rateoffire = 0.8,
        attackanim = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE,
        attacksnd = "Weapon_StunStick.Swing",
        hitsnd = "weapons/stunstick/stunstick_fleshhit*2*.wav",
        
        -- Emit sparks on hit
        callback = function( self, wepent, target )
            
            local effect = EffectData()
                effect:SetOrigin(target:GetPos()+target:OBBCenter())
                effect:SetMagnitude(1)
                effect:SetScale(2)
                effect:SetRadius(4)
            util_Effect( "StunstickImpact", effect, true, true)

            return false
        end,

        islethal = true,
    }

})