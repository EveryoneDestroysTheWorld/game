--!strict
-- Programmers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designer: Hati (hati_bati)
-- © 2024 – 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");
local types = require(ServerStorage.Modules.types);

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

function damageFramework.explosionEvent(coordinates: Vector3, data: OptionalExplosionData, action: types.DiveBombServerAction | types.TarBombServerAction, callback: ((victim: types.ServerContestant) -> ())?)

	local defaults: ExplosionData = {
		size = 5,
		knockback = 100,
		playerDamage = 5,
		objectDamage = 5,
		damageFallOff = true,
		knockUpAmount = 1
	}

	local size = data.size or defaults.size;
	local explosion = Instance.new("Explosion");
	explosion.BlastPressure = 0;
	explosion.BlastRadius = 1 + size;
	explosion.DestroyJointRadiusPercent = 0;
	explosion.Position = coordinates;
	explosion.Parent = workspace;
	local queriedModels = {};
	explosion.Hit:Connect(function(basePart)

		-- Damage any parts or contestants that get hit.
		local model = basePart:FindFirstAncestorOfClass("Model")
		if model and model:FindFirstChild("Humanoid") and model.PrimaryPart then

			for i, possibleTargetContestant in action.contestant.round.contestants do
				
				local character = possibleTargetContestant.character;
				if not character or table.find(queriedModels, character) then

					continue;

				end;

				task.spawn(function()

					local primaryPart = if character then character.PrimaryPart else nil;
					if character and primaryPart and character == model then

						table.insert(queriedModels, character);
						if possibleTargetContestant.id == action.contestant.id then

							size = size / 3

						end

						local distanceFromExplosion = 1
						local DamageFalloff = data.damageFallOff or defaults.damageFallOff;
						if DamageFalloff then

							distanceFromExplosion = ((primaryPart.Position - coordinates).Magnitude);

						else

							--print("No damage falloff")
							
						end

						local knockback = data.knockback or defaults.knockback;
						if knockback > 0 then
							
							local knockUp = data.knockUpAmount or defaults.knockUpAmount;
							local direction = (primaryPart.Position - coordinates) / (primaryPart.Position - coordinates).Magnitude * Vector3.new(1.3, 0.5, 1.3) + Vector3.new(0,knockUp,0)
							createKnockback(primaryPart, distanceFromExplosion * knockback, direction)
						
						end
						
						possibleTargetContestant:updateHealth(possibleTargetContestant.currentHealth - (data.playerDamage or defaults.playerDamage) * math.max((size + 1 - distanceFromExplosion) / (1 + size), 0), {
							contestantID = action.contestant.id;
							actionID = if action then action.id else nil;
						});

						if callback then

							callback(possibleTargetContestant);

						end;
						
					end

				end);

			end

		end;
		
		local basePartCurrentDurability = basePart:GetAttribute("CurrentDurability") :: number?;
		if basePartCurrentDurability and basePartCurrentDurability > 0 then

		ServerStorage.Functions.ModifyPartCurrentDurability:Invoke(basePart, basePartCurrentDurability - (data.objectDamage or defaults.objectDamage), {
			contestantID = action.contestant.id;
			actionID = action.id;
		});

		end;

	end);

end

return damageFramework