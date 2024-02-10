local table_insert = table.insert

local RandomPairs = RandomPairs
local tonumber = tonumber

LambdaPersonalities = {}
LambdaPersonalityConVars = {}
-- Creates a "Personality" type for the specific function. Every Personality gets created with a chance that will be tested with every other chances ordered from highest to lowest
-- Personalities are called when a Lambda Player is idle and wants to test a chance

local presettbl = {
    [ "Random" ] = "random",
    [ "Builder" ] = "builder",
    [ "Fighter" ] = "fighter",
    [ "Custom" ] = "custom",
    [ "Custom Random" ] = "customrandom"
}

CreateLambdaConvar( "lambdaplayers_personality_preset", "random", true, true, true, "The preset Lambda Personalities should use. Set this to Custom to make use of the chance sliders", nil, nil, { type = "Combo", options = presettbl, name = "Personality Preset", category = "Lambda Player Settings" } )

function LambdaCreatePersonalityType( personalityname, func )
    local convar = CreateLambdaConvar( "lambdaplayers_personality_" .. personalityname .. "chance", 30, true, true, true, "The chance " .. personalityname .. " will be executed. Personality Preset should be set to Custom for this slider to effect newly spawned Lambda Players!", 0, 100, { type = "Slider", decimals = 0, name = personalityname .. " Chance", category = "Lambda Player Settings" } )
    table_insert( LambdaPersonalities, { personalityname, func } )
    table_insert( LambdaPersonalityConVars, { personalityname, convar } )
end


local function Chance_Build( self )
    self:PreventWeaponSwitch( true )

    for index, buildtable in RandomPairs( LambdaBuildingFunctions ) do
        if !buildtable[ 2 ]:GetBool() then continue end

        local name = buildtable[ 1 ]
        if LambdaRunHook( "LambdaOnUseBuildFunction", self, name ) == true then break end

        local result
        local ok, msg = pcall( function() result = buildtable[ 3 ]( self ) end )

        if !ok and name != "entity" and name != "npc" then ErrorNoHaltWithStack( name .. " Building function had a error! If this is from a addon, report it to the author!", msg ) end
        if result then self:DebugPrint( "Used a building function: " .. name ) break end
    end

    self:PreventWeaponSwitch( false )
end



local function Chance_Tool( self )
    self:SwitchWeapon( "toolgun" )
    if self.l_Weapon != "toolgun" then return end

    self.l_IsUsingTool = true
    self:PreventWeaponSwitch( true )

    local find = self:FindInSphere( nil, 400, function( ent ) if self:HasVPhysics( ent ) and self:CanSee( ent ) and self:HasPermissionToEdit( ent ) then return true end end )
    local target = find[ LambdaRNG( #find ) ]

    -- Loops through random tools and only stops if a tool tells us it actually got used by returning true
    for index, tooltable in RandomPairs( LambdaToolGunTools ) do
        if !tooltable[ 2 ]:GetBool() then continue end -- If the tool is allowed

        local name = tooltable[ 1 ]
        if LambdaRunHook( "LambdaOnToolUse", self, name ) == true then break end

        local result
        local ok, msg = pcall( function() result = tooltable[ 3 ]( self, target ) end )

        if !ok then ErrorNoHaltWithStack( name .. " Tool had a error! If this is from a addon, report it to the author!", msg ) end
        if result then self:DebugPrint( "Used " .. name .. " Tool" ) break end
    end

    self.l_IsUsingTool = false
    self:PreventWeaponSwitch( false )
end

local function Chance_Combat( self )
    local rndCombat = LambdaRNG( 3 )
    if rndCombat == 1 then
        self:SetState( "HealUp", "FindTarget" )
    elseif rndCombat == 2 then
        self:SetState( "ArmorUp", "FindTarget" )
    else
        self:SetState( "FindTarget" )
    end
end

local ignorePlys = GetConVar( "ai_ignoreplayers" )
local function Chance_Friendly( self )
    if self:InCombat() or self:IsPanicking() or !self:CanEquipWeapon( "gmod_medkit" ) then return end

    local nearbyEnts = self:FindInSphere( nil, 1000, function( ent )
        if !LambdaIsValid( ent ) or !ent.Health or !ent:IsNPC() and !ent:IsNextBot() and ( !ent:IsPlayer() or !ent:Alive() or ignorePlys:GetBool() ) then return false end
        return ( ent:Health() < ent:GetMaxHealth() and self:CanSee( ent ) )
    end )

    if #nearbyEnts == 0 then return end
    self:SetState( "HealSomeone", nearbyEnts[ LambdaRNG( #nearbyEnts ) ] )
end

CreateLambdaConsoleCommand( "lambdaplayers_cmd_opencustompersonalitypresetpanel", function( ply )
    local tbl = {}
    tbl[ "lambdaplayers_personality_voicechance" ] = 30
    tbl[ "lambdaplayers_personality_textchance" ] = 30
    for k, v in ipairs( LambdaPersonalityConVars ) do
        tbl[ v[ 2 ]:GetName() ] = ( tonumber( v[ 2 ]:GetDefault() ) or 30  )
    end
    LAMBDAPANELS:CreateCVarPresetPanel( "Custom Personality Preset Editor", tbl, "custompersonalities", true )
end, true, "Opens a panel to allow you to create custom preset personalities and load them", { name = "Custom Personality Presets", category = "Lambda Player Settings" } )


LambdaCreatePersonalityType( "Build", Chance_Build )
LambdaCreatePersonalityType( "Tool", Chance_Tool )
LambdaCreatePersonalityType( "Combat", Chance_Combat )
LambdaCreatePersonalityType( "Friendly", Chance_Friendly )

LambdaCreatePersonalityType( "Cowardly" )

CreateLambdaConvar( "lambdaplayers_personality_voicechance", 30, true, true, true, "The chance Voice will be executed. Personality Preset should be set to Custom for this slider to effect newly spawned Lambda Players!", 0, 100, { type = "Slider", decimals = 0, name = "Voice Chance", category = "Lambda Player Settings" } )
CreateLambdaConvar( "lambdaplayers_personality_textchance", 30, true, true, true, "The chance Text will be executed. Personality Preset should be set to Custom for this slider to effect newly spawned Lambda Players!", 0, 100, { type = "Slider", decimals = 0, name = "Text Chance", category = "Lambda Player Settings" } )