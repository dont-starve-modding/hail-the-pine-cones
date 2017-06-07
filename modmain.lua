



------------ CONFIGURATION ----------------

-- set this to false if you do not want to enable automatic "recharging"
TUNING.CONEMISSILE_REEQUIP = true


-------------------------------------------



PrefabFiles = {
    "conemissile",
}

STRINGS = GLOBAL.STRINGS
RECIPETABS = GLOBAL.RECIPETABS
Recipe = GLOBAL.Recipe
Ingredient = GLOBAL.Ingredient
TECH = GLOBAL.TECH

STRINGS.NAMES.CONEMISSILE = "Cone Missile"

STRINGS.RECIPE_DESC.CONEMISSILE = "Neither sharp, nor streamlined."

STRINGS.CHARACTERS.GENERIC.DESCRIBE.CONEMISSILE = "Monsters flee spotting the holy cone weapons!"

local conemissile = GLOBAL.Recipe("conemissile",{ Ingredient("pinecone", 1) },                     
RECIPETABS.WAR, TECH.NONE )
conemissile.atlas = "images/inventoryimages/conemissile.xml"

-- onhit damage
TUNING.CONEMISSILE_DAMAGE = 12
-- projectile speed
TUNING.CONEMISSILE_SPEED = 30
-- max throw distance
TUNING.CONEMISSILE_DISTANCE = 5
-- missing chance
TUNING.CONEMISSILE_MISS_PERCENT = 0.2
-- reloot chance
-- every missed conemissile is going to drop (reloot). All in all reloot chance is: ALL_RELOOT_PERCENT = MISS_PERCENT + (1-MISS_PERCENT)*RELOOT_PERCENT (default(20%, 60%) = 68%) 
TUNING.CONEMISSILE_RELOOT_PERCENT = 0.6

-- how many conemissiles can be on one inventory slot
TUNING.CONEMISSILE_STACK_SIZE = 5

-- pinecone time to regrow on evergreens
TUNING.CONE_REGROW_TIME = TUNING.TOTAL_DAY_TIME * 5
-- extra pinecones!
TUNING.EVERGREEN_EXTRA_PINECONE_PICK_PERCENT = 0.2


-- for balancing
-- from .33, .15
TUNING.LEIF_PINECONE_CHILL_CHANCE_CLOSE = .2
TUNING.LEIF_PINECONE_CHILL_CHANCE_FAR = .075

-- from base=0.75*day_time
TUNING.PINECONE_GROWTIME = {base=1*TUNING.TOTAL_DAY_TIME, random=0.25*TUNING.TOTAL_DAY_TIME}



 local function evergreenonpickedfn(inst, picker)
	if(math.random() <= TUNING.EVERGREEN_EXTRA_PINECONE_PICK_PERCENT) then
		inst.components.lootdropper:SpawnLootPrefab("pinecone")
	end
 end

local function evergreenpostinit(inst)
	
	-- evergreens are pickable
	inst:AddComponent("pickable")
	-- sounds like picking up berries
	inst.components.pickable.picksound = "dontstarve/wilson/harvest_berries"
	
	-- find pinecones
	inst.components.pickable:SetUp("pinecone", TUNING.CONE_REGROW_TIME)

	inst.components.pickable.onpickedfn = evergreenonpickedfn
	inst.components.pickable.fertilizable = false
		
	if inst.components.growable.stage == 3 and inst.build ~= "sparse" then
		inst.components.pickable.canbepicked = true
	else
		inst.components.pickable.canbepicked = false
	end
	
	-- save current onfinish method for wrapper
	local onfinishfn = inst.components.workable.onfinish
	
	-- overwrite with wrapper
	inst.components.workable:SetOnFinishCallback(
		--wrapper
		function(inst, chopper) 
			-- stumps dont have cones anymore
			inst.components.pickable.canbepicked = false
			
			onfinishfn(inst, chopper)
		end
	)
	
	-- save current stage fn for wrapper
	local growtallfn = inst.components.growable.stages[3].fn

	-- overwrite with wrapper
	inst.components.growable.stages[3].fn = (
		-- wrapper
		function(inst)
			-- trees growing tall sprout some cones
			if(inst.components.pickable ~= nil) then
				inst.components.pickable.canbepicked = true
			end
			
			growtallfn(inst)
		end
	)
	
	-- save current stage fn for wrapper
	local growoldfn = inst.components.growable.stages[4].fn

	-- overwrite with wrapper
	inst.components.growable.stages[4].fn = (
		-- wrapper
		function(inst)
			-- trees growing old dont have cones to farm anymore
			if(inst.components.pickable ~= nil) then
				inst.components.pickable.canbepicked = false
			end
			
			growoldfn(inst)
		end
	)
	
	--[[if inst.components.burnable then
		-- save current stage fn for wrapper
		local onburntfn = inst.components.burnable.onburnt

		-- overwrite with wrapper
		inst.components.burnable:SetOnBurnt(
			-- wrapper
			function(inst)
				-- burned trees dont drop random pinecones anymore
				
				onburntfn(inst)
			end
		)
	end]]
end

local function pineconepostinit(inst)
	-- pinecones burn with intensity located between tiny and small
	inst.components.fuel.fuelvalue = (TUNING.TINY_FUEL + TUNING.SMALL_FUEL)*0.5
	
end

AddPrefabPostInit("evergreen", evergreenpostinit)
AddPrefabPostInit("pinecone", pineconepostinit)