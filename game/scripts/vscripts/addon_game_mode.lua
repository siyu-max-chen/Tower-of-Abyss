-- Generated from template

if ToAGame == nil then
	_G.ToAGame = class({});	-- 关键，这里是全局创建
end

require('game/init');

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]

	--- Load and precache particles data from key-value file
	for particleName, table in pairs(Data:getDataTable('PARTICLE')) do
		if Particle:isParticleArray(particleName) then
			for subName, subTable in pairs(table.PATHS) do
				PrecacheResource( 'particle', subTable.PATH, context );
				print(subTable.PATH);
			end
		else
			PrecacheResource( 'particle', table.PATH, context );
			print(table.PATH);
		end
	end

	--- Load and precache sound data from key-value file
	for _, soundPath in pairs(Data:getDataTable('SOUND')) do
		PrecacheResource( 'soundfile', soundPath, context );
	end
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = ToAGame()
	GameRules.AddonTemplate:InitGameMode()
end

require('game/events');
require('game/filter');

function ToAGame:InitGameMode()
	print( "Template addon is loaded." )
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, "GlobalThink", 2 );
	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(ToAGame, "OrderFilter"), self);
	GameRules:GetGameModeEntity():SetAbilityTuningValueFilter(Dynamic_Wrap(ToAGame, "AbilityFilter"), self);
	-- GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(ToAGame, 'DamageFilter'), self);

	_G.DUMMY_UNIT = CreateUnitByName("npc_creep_test_enemy", Vector(0, 800, 0), true, nil, nil, 3);
	CreateUnitByName("npc_creep_test_enemy", Vector(-200, 600, 0), true, nil, nil, 3);
	CreateUnitByName("npc_creep_test_enemy", Vector(-200, 1000, 0), true, nil, nil, 3);
	-- CreateUnitByName("npc_creep_test_enemy", Vector(200, 600, 0), true, nil, nil, 3);
	-- CreateUnitByName("npc_creep_test_enemy", Vector(200, 1000, 0), true, nil, nil, 3);

	ListenToGameEvent('npc_spawned', Dynamic_Wrap(ToAGame, 'OnNPCSpawned'), self);

	Cache:_initialize();
end

-- Evaluate the state of the game
function ToAGame:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end