--!strict
-- Programmers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designer: Hati (hati_bati)
-- © 2024 – 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");
local types = require(ServerStorage.Classes.types);

local damageFramework = {};

local function createKnockback(primaryPart: BasePart, force: number, direction: Vector3): ()

	local rootAttachment = primaryPart:FindFirstChild("RootAttachment");
	if not rootAttachment or not rootAttachment:IsA("Attachment") then

		return;

	end;

	local knockback = Instance.new("LinearVelocity");
	knockback.Parent = primaryPart;
	knockback.ForceLimitMode = Enum.ForceLimitMode.PerAxis;
	knockback.MaxAxesForce = direction * 9999;
	knockback.Attachment0 = rootAttachment;
	knockback.VectorVelocity = direction * force;

	task.delay(0.1, function()
		knockback:Destroy()
	end);

end

export type ExplosionData = {
	size: number,
	knockback: number,
	playerDamage: number,
	objectDamage: number,
	damageFallOff: boolean,
	knockUpAmount: number,
};

export type OptionalExplosionData = {
	size: number?;
	knockback: number?;
	playerDamage: number?;
	objectDamage: number?;
	damageFallOff: number?;
	knockUpAmount: number?;
}

function damageFramework.explosionEvent(coords: Vector3, data: OptionalExplosionData, round: types.ServerRound, contestant: types.ServerContestant, action: types.ServerAction?)

	local defaults: ExplosionData = {
		size = 5,
		knockback = 100,
		playerDamage = 5,
		objectDamage = 5,
		damageFallOff = true,
		knockUpAmount = 1,
	}

	local size = data["Size"] or defaults["Size"]
	local validTargets = {};
	local explosion = Instance.new("Explosion");
	explosion.BlastPressure = 0;
	explosion.BlastRadius = 1 + size;
	explosion.DestroyJointRadiusPercent = 0;
	explosion.Position = coords;
	explosion.Parent = workspace;
	explosion.Hit:Connect(function(basePart)

		-- Damage any parts or contestants that get hit.
		local model = basePart:FindFirstAncestorOfClass("Model")
		if model and model:FindFirstChild("Humanoid") then

			table.insert(validTargets, model.Name)

		end;
		
		local basePartCurrentDurability = basePart:GetAttribute("CurrentDurability") :: number?;
		if basePartCurrentDurability and basePartCurrentDurability > 0 then

		ServerStorage.Functions.ModifyPartCurrentDurability:Invoke(basePart, basePartCurrentDurability - (data["ObjectDamage"] or defaults["ObjectDamage"]), {
			contestantID = contestant.id;
		});

		end;

	end);

	task.delay(0.1, function()

		if #validTargets > 0 then
				
			for i, possibleTargetContestant in round.contestants do

				local targetIndex = table.find(validTargets, contestant.name);
				local character = contestant.character;
				local primaryPart = if character then character.PrimaryPart else nil;
				if character and primaryPart and targetIndex and contestant["name"] == validTargets[targetIndex] then

					if possibleTargetContestant.id == contestant.id then

						size = size/3

					end

					local distanceFromExplosion = 1
					local DamageFalloff = data.damageFallOff or defaults.damageFallOff;
					if DamageFalloff then

						distanceFromExplosion -= ((primaryPart.Position - coords).Magnitude / size);

					else

						--print("No damage falloff")
						
					end

					local knockback = data.knockback or defaults.knockback;
					if knockback > 0 then
						
						local knockUp = data.knockUpAmount or defaults.knockUpAmount;
						local direction = (primaryPart.Position - coords) / (primaryPart.Position - coords).Magnitude * Vector3.new(1.3, 0.5, 1.3) + Vector3.new(0,knockUp,0)
						createKnockback(primaryPart, distanceFromExplosion * knockback, direction)
					
					end
					
					contestant:updateHealth(contestant.currentHealth - (data["PlayerDamage"] or defaults["PlayerDamage"]) * distanceFromExplosion, {
						contestant = contestant;
						actionID = if action then action.id else nil;
					});
					
				end
			end
		end

	end);

end

return damageFramework