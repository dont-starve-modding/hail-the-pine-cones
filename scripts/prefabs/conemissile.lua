local assets=
{
    Asset("ANIM", "anim/conemissile.zip"),
    Asset("ANIM", "anim/swap_conemissile.zip"),
 
    Asset("ATLAS", "images/inventoryimages/conemissile.xml"),
    Asset("IMAGE", "images/inventoryimages/conemissile.tex"),
}
local prefabs = 
{
}
local function fn()
 
    local function OnEquip(inst, owner)
        owner.AnimState:OverrideSymbol("swap_object", "swap_conemissile", "conemissile")
        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")
    end
 
    local function OnUnequip(inst, owner)
        owner.AnimState:Hide("ARM_carry")
        owner.AnimState:Show("ARM_normal")
    end
	
	local function OnFinished(inst)
		-- inst.AnimState:PlayAnimation("used")
		-- inst:ListenForEvent("animover", function() inst:Remove() end)
	end

	local function OnDropped(inst)
		-- inst.AnimState:PlayAnimation("idle")
	end

	local function OnThrown(inst, owner, target)
		if target ~= owner then
			owner.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_throw")
		end
		if math.random() <= TUNING.CONEMISSILE_MISS_PERCENT then
			inst.components.weapon:SetDamage(0)
		end
		-- inst.AnimState:PlayAnimation("spin_loop", true)
	end
	
	local function OnHit(inst, owner, target)

		if inst.components.weapon.damage == 0 then
			GetPlayer().components.talker:Say("Fail")
			inst.components.weapon.damage = TUNING.CONEMISSILE_DAMAGE
		else
			local impactfx = SpawnPrefab("impact")
			if impactfx then
				local follower = impactfx.entity:AddFollower()
				follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0 )
				impactfx:FacePoint(inst.Transform:GetWorldPosition())
			end
			if math.random() > TUNING.CONEMISSILE_RELOOT_PERCENT  then
				inst:Remove()
			end
		end
		
		-- reeuip
		
		if GetPlayer().components.inventory and TUNING.CONEMISSILE_REEQUIP then
			local item = GetPlayer().components.inventory:FindItem(function(item) 
				if item.prefab and item.prefab == "conemissile" then
					return true
				end
			end)
			if item then
				GetPlayer().components.inventory:Equip(item)
			end
		end
	end
 
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
     
    anim:SetBank("conemissile")
    anim:SetBuild("conemissile")
    anim:PlayAnimation("idle")
 
    inst:AddComponent("inspectable")
     
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "conemissile"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/conemissile.xml"
	
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.CONEMISSILE_STACK_SIZE
     
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( OnEquip )
    inst.components.equippable:SetOnUnequip( OnUnequip )
	
	inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.CONEMISSILE_DAMAGE)
    inst.components.weapon:SetRange(TUNING.CONEMISSILE_DISTANCE, TUNING.CONEMISSILE_DISTANCE+2)
	
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(TUNING.CONEMISSILE_SPEED)
    inst.components.projectile:SetCanCatch(false)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnThrownFn(OnThrown)
 
    return inst
end
return  Prefab("common/inventory/conemissile", fn, assets, prefabs)