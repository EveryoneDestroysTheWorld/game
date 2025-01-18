--!strict
-- Programmer: Hati (hati_bati)
-- Designer: Hati (hati_bati)
-- © 2024 Beastslash LLC
damageFramework = {}
ServerStorage = game:GetService("ServerStorage")

local function createKnockback(character, force, direction)
	local knockback = Instance.new("LinearVelocity", character.PrimaryPart)
	knockback.ForceLimitMode = "PerAxis"
	knockback.MaxAxesForce = direction * 9999
	knockback.Attachment0 = character.PrimaryPart.RootAttachment
	knockback.VectorVelocity = direction * force
	task.delay(0.1, function()
		knockback:Destroy()
	end)
end


function damageFramework.explosionEvent(coords: Vector3, data: Array, round: ServerRound, contestant: ServerContestant)
	local ownerName = contestant
    local defaults = {
        ["Size"] = 5,
        ["Knockback"] = 100,
        ["PlayerDamage"] = 5,
        ["ObjectDamage"] = 5,
        ["DamageFalloff"] = true,
        ["KnockbackOwner?"] = false,
		["DamageOwner?"] = true,
		["KnockUpAmount"] = 1,
    }
	local explosion = Instance.new("Explosion", workspace.Terrain);
	local size = data["Size"] or defaults["Size"]
	explosion.BlastPressure = 0;
	explosion.BlastRadius = 1 + size;
	explosion.DestroyJointRadiusPercent = 0;
	explosion.Position = coords;
	local validTargets = {};
	explosion.Hit:Connect(function(basePart)
		-- Damage any parts or contestants that get hit.
		local model = basePart:FindFirstAncestorOfClass("Model")
		if model and model:FindFirstChild("Humanoid") then
			table.insert(validTargets, model.Name)
		end;
		
		local basePartCurrentDurability = basePart:GetAttribute("CurrentDurability") :: number?;
		if basePartCurrentDurability and basePartCurrentDurability > 0 then

		ServerStorage.Functions.ModifyPartCurrentDurability:Invoke(basePart, basePartCurrentDurability - (data["ObjectDamage"] or defaults["ObjectDamage"]), contestant);

		end;

	end);
	task.delay(0.1, function()
	if #validTargets > 0 then
			
		for i, contestant in ipairs(round.contestants) do
			if contestant["name"] == validTargets[table.find(validTargets, contestant["name"])] then
				if contestant["name"] == player then
					size = size/3
				end
                local distanceFromExplosion = 1
                local DamageFalloff = data["DamageFallOff"] or defaults["DamageFallOff"]
                if DamageFalloff == true then
                    distanceFromExplosion -= ((contestant.character.PrimaryPart.Position - coords).Magnitude / size)
				else
					--print("No damage falloff")
				end
				local knockback = data["Knockback"] or defaults["Knockback"]
				if knockback > 0 then
				--	print(contestant)
					local knockUp = data["KnockUpAmount"] or defaults["KnockUpAmount"]
					local direction = (contestant.character.PrimaryPart.Position - coords) / (contestant.character.PrimaryPart.Position - coords).Magnitude * Vector3.new(1.3,0.5,1.3)  + Vector3.new(0,knockUp,0)
				--	print(direction)
					createKnockback(contestant.character, distanceFromExplosion * knockback, direction)
				end
				contestant:updateHealth(contestant.currentHealth - (data["PlayerDamage"] or defaults["PlayerDamage"]) * distanceFromExplosion, {
					contestant = contestant;
					actionID = actionID;
				});
				
			end
		end
	end
end)
end






return damageFramework