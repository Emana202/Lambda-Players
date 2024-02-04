local IsValid = IsValid
local table_insert = table.insert


local VectorRand = VectorRand
local coroutine = coroutine
local Trace = util.TraceLine

LambdaBuildingFunctions = {}

-- This system is pretty much the same exact as the toolgun system
-- Adds a function to the list of building functions Lambda Players can use
-- These functions will be under the Build Chance

-- This function has its args different from the toolgun system since that could be many things that could be considered building. So the developer needs to ability to customize the setting name and description
function AddBuildFunctionToLambdaBuildingFunctions( spawnname, settingname, desc, func )
    local convar = CreateLambdaConvar( "lambdaplayers_building_allow" .. spawnname, 1, true, false, false, desc, 0, 1, { type = "Bool", name = settingname, category = "Building" } )
    table_insert( LambdaBuildingFunctions, { spawnname, convar, func } )
end


local function SpawnAProp( self )
    if !self:IsUnderLimit( "Prop" ) then return end

    for i=1, LambdaRNG( 4 ) do
        if !self:IsUnderLimit( "Prop" ) then return end

        self:LookTo( self:GetPos() + VectorRand( -100, 100 ), 2 )
        coroutine.wait( LambdaRNG( 0.2, 1, true ) )

        self:SpawnProp()

        coroutine.wait( LambdaRNG( 0.2, 1, true ) )

    end

    return true -- Just like for toolguns, we return true to let the for loop know we completed what we wanted to do and it can break
end

-- Spawns a prop and picks it up the Physgun if we can use the physgun
local function SpawnAPropandPickUp( self )
    if !self:IsUnderLimit( "Prop" ) or !self:CanEquipWeapon( "physgun" ) then return end
    self:PreventWeaponSwitch( false )

    self:SwitchWeapon( "physgun" )

    self:LookTo( self:GetPos() + VectorRand( -100, 100 ), 2 )
    coroutine.wait( LambdaRNG( 0.2, 1, true ) )

    local prop = self:SpawnProp()
    self:LookTo( prop, 2 )
    coroutine.wait( LambdaRNG( 0.2, 1, true ) )

    self:UseWeapon( prop )

    return true
end


local function SpawnNPC( self )
    if !self:IsUnderLimit( "NPC" ) then return end
    
    self:LookTo( self:WorldSpaceCenter() + VectorRand( -200, 200 ), 2 )

    local npc = self:SpawnNPC()
    if !IsValid( npc ) then return end

    coroutine.wait( LambdaRNG( 0.2, 1, true ) )

    return true
end


local function SpawnEntity( self )
    if !self:IsUnderLimit( "Entity" ) then return end
    
    self:LookTo( self:WorldSpaceCenter() + VectorRand( -200, 200 ), 2 )

    coroutine.wait( LambdaRNG( 0.2, 1, true ) )

    local entity = self:SpawnEntity()
    if !IsValid( entity ) then return end

    coroutine.wait( LambdaRNG( 0.2, 1, true ) )

    return true
end

local spraytbl = { collisiongroup = COLLISION_GROUP_WORLD }
local function Spray( self )
    if #LambdaPlayerSprays == 0 or CurTime() <= self.l_NextSprayUseTime then return end
    self.l_NextSprayUseTime = ( CurTime() + 10 )

    local targetpos = self:WorldSpaceCenter() + VectorRand( -200, 200 )
    self:LookTo( targetpos, 1 )
    coroutine.wait( LambdaRNG( 0.2, 0.6, true ) )

    spraytbl.start = self:WorldSpaceCenter()
    spraytbl.endpos = targetpos
    spraytbl.filter = self

    local trace = Trace( spraytbl )
    if !trace.Hit then return end

    LambdaPlayers_Spray( LambdaPlayerSprays[ LambdaRNG( #LambdaPlayerSprays ) ], trace.HitPos, trace.HitNormal )
    self:EmitSound( "player/sprayer.wav", 65 )

    coroutine.wait( LambdaRNG( 0.2, 0.6, true ) )
    return true
end


AddBuildFunctionToLambdaBuildingFunctions( "prop", "Allow Prop Spawning", "If Lambda Players are allowed to spawn props", SpawnAProp )
AddBuildFunctionToLambdaBuildingFunctions( "npc", "Allow NPC Spawning", "If Lambda Players are allowed to spawn NPCs", SpawnNPC )
AddBuildFunctionToLambdaBuildingFunctions( "entity", "Allow Entity Spawning", "If Lambda Players are allowed to spawn Entities", SpawnEntity )
AddBuildFunctionToLambdaBuildingFunctions( "spray", "Allow Sprays", "If Lambda Players are allowed to place Sprays", Spray )
table_insert( LambdaBuildingFunctions, { "prop", GetConVar( "lambdaplayers_building_allowprop" ), SpawnAPropandPickUp } ) -- Pretty much made this be connected to the prop spawning option
