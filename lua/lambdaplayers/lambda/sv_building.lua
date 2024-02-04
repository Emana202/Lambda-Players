
local IsValid = IsValid
local CreateEnt = ents.Create
local ipairs = ipairs
local table_insert = table.insert
local table_remove = table.remove
local tobool = tobool
local Angle = Angle
local caneditworld = GetConVar( "lambdaplayers_building_caneditworld" )
local caneditnonworld = GetConVar( "lambdaplayers_building_caneditnonworld" )



-- Building Helper functions --

-- Removes every entity we spawned
function ENT:CleanSpawnedEntities()
    self:DebugPrint( "cleaned up all their entities" )
    for k, v in ipairs( self.l_SpawnedEntities ) do
        if IsValid( v ) then v:Remove() self.l_SpawnedEntities[ k ] = nil end
    end
end

-- Removes the last entity we spawned
function ENT:UndoLastSpawnedEnt()
    local ent = self.l_SpawnedEntities[ 1 ]
    table_remove( self.l_SpawnedEntities, 1 )
    if IsValid( ent ) then ent:Remove() self:DebugPrint( "undone", ent ) self:EmitSound( "buttons/button15.wav", 60 ) end
end

-- If we are able to do whatever on the specified entity
function ENT:HasPermissionToEdit( ent )
    if !ent:GetPhysicsObject():IsValid() then return false end
    if ent.IsLambdaPlayer then return false end
    if ent.LambdaOwner == self then return true end
    if caneditworld:GetBool() and ent:CreatedByMap() then return true end
    local creator = ent:GetCreator()
    if IsValid( creator ) and creator:IsPlayer() then return tobool( creator:GetInfoNum( "lambdaplayers_building_canedityourents", 0 ) ) end 
    if caneditnonworld:GetBool() and !ent:CreatedByMap() then return true end
    return false
end

-- Returns if the entity is a physics object
function ENT:HasVPhysics( ent )
    return !ent:IsNPC() and !ent:IsPlayer() and !ent:IsNextBot() and IsValid( ent:GetPhysicsObject() )
end

-- Building Functions --

-- Spawns a prop to where we are looking
function ENT:SpawnProp()
    if !self:IsUnderLimit( "Prop" ) then return end

    local trace = self:GetEyeTrace()
    local mdl = LambdaPlayerProps[ LambdaRNG( #LambdaPlayerProps ) ]

    if !mdl then return end

    self:EmitSound( "ui/buttonclickrelease.wav", 60 )

    local prop = CreateEnt( "prop_physics" )
    prop:SetPos( trace.HitPos )
    prop:SetAngles( Angle( 0, self:GetAngles()[ 2 ], 0 ) )
    prop:SetModel( mdl )
    prop.LambdaOwner = self
    prop.IsLambdaSpawned = true
    prop:Spawn()
    DoPropSpawnedEffect( prop ) -- Make the prop do the spawn effect

    local mins = prop:GetModelBounds()
    local proppos = prop:GetPos()
    proppos[ 3 ] = proppos[ 3 ] - mins[ 3 ]
    prop:SetPos( proppos )

    if GetConVar( "lambdaplayers_building_alwaysfreezelargeprops" ):GetBool() and prop:GetModelRadius() > 150 then
        local phys = prop:GetPhysicsObject()
        if IsValid( phys ) then phys:EnableMotion( false ) end
    end

    if GetConVar( "lambdaplayers_building_freezeprops" ):GetBool() then
        if LambdaRNG( 2 ) == 1 then
            local phys = prop:GetPhysicsObject()
            if IsValid( phys ) then phys:EnableMotion( false ) end
        else
            self:SimpleTimer( 10, function()  
                if !IsValid( prop ) then return end
                local phys = prop:GetPhysicsObject()
                if IsValid( phys ) then phys:EnableMotion( false ) end
            end, true)
        end
    end

    self:DebugPrint( "spawned a prop ", prop )

    self:ContributeEntToLimit( prop, "Prop" )
    table_insert( self.l_SpawnedEntities, 1, prop )

    return prop
end


local function GetRandomNPCClassname()
    local npclist = LAMBDAFS:ReadFile( "lambdaplayers/npclist.json", "json" )
    if !npclist then return end
    return npclist[ LambdaRNG( #npclist ) ]
end


function ENT:SpawnNPC()
    if !self:IsUnderLimit( "NPC" ) then return end

    self:EmitSound( "ui/buttonclickrelease.wav", 60 )

    local trace = self:GetEyeTrace()
    local class = GetRandomNPCClassname()
    if !class then return end

    -- Internal function located at autorun_includes/server/building_npccreation.lua
    local NPC = LambdaInternalSpawnNPC( self, trace.HitPos, trace.HitNormal, class, false )
    
    if !IsValid( NPC ) then return end

    NPC.LambdaOwner = self
    NPC.IsLambdaSpawned = true

    self:DebugPrint( "spawned a NPC ", class )

    self:ContributeEntToLimit( NPC, "NPC" )
    table_insert( self.l_SpawnedEntities, 1, NPC )

    return NPC
end

function ENT:SpawnEntity()
    if !self:IsUnderLimit( "Entity" ) then return end

    self:EmitSound( "ui/buttonclickrelease.wav", 60 )

    local entlist = LAMBDAFS:ReadFile( "lambdaplayers/entitylist.json", "json" )
    local trace = self:GetEyeTrace()
    local class = entlist[ LambdaRNG( #entlist ) ]

    if !class then return end

    -- function located at autorun_includes/server/building_entitycreation.lua
    local entity = LambdaSpawn_SENT( self, class, trace )
    
    if !IsValid( entity ) then return end

    entity.LambdaOwner = self
    entity.IsLambdaSpawned = true

    self:DebugPrint( "spawned a Entity ", class )

    self:ContributeEntToLimit( entity, "Entity" )
    table_insert( self.l_SpawnedEntities, 1, entity )

    return entity
end



------