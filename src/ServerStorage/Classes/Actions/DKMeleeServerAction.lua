--!strict
-- Writer: Hati ---- Heavily modified edit of RocketFeet
-- Designer: Christian Toney (Sudobeast)
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TweenService = game:GetService("TweenService")
local ServerContestant = require(script.Parent.Parent.ServerContestant);
type ServerContestant = ServerContestant.ServerContestant;
local ServerAction = require(script.Parent.Parent.ServerAction);
type ServerAction = ServerAction.ServerAction;
local MeleeClientAction = require(ReplicatedStorage.Client.Classes.Actions.DKMeleeClientAction);
local ServerRound = require(script.Parent.Parent.ServerRound);
type ServerRound = ServerRound.ServerRound;
local ServerStorage = game:GetService("ServerStorage");

local MeleeServerAction = {
	ID = MeleeClientAction.ID;
	name = MeleeClientAction.name;
	description = MeleeClientAction.description;
};


local function damageEvent(primaryPart, round, contestant)
	print("creating Explosion")
	local explosion = Instance.new("Explosion", primaryPart);
	explosion.BlastPressure = 0;
	explosion.BlastRadius = 5;
	explosion.DestroyJointRadiusPercent = 0;
	explosion.Position = primaryPart.Position;
	local hitContestants = {};
	explosion.Hit:Connect(function(basePart)

		-- Damage any parts or contestants that get hit.
		for _, possibleEnemyContestant in ipairs(round.contestants) do

			task.spawn(function()

				local possibleEnemyCharacter = possibleEnemyContestant.character;
				if possibleEnemyContestant ~= contestant and not table.find(hitContestants, possibleEnemyContestant) and possibleEnemyCharacter and basePart:IsDescendantOf(possibleEnemyCharacter) then

					table.insert(hitContestants, possibleEnemyContestant);
					local enemyHumanoid = possibleEnemyCharacter:FindFirstChild("Humanoid");
					if enemyHumanoid then

						local currentHealth = enemyHumanoid:GetAttribute("CurrentHealth") :: number?;
						if currentHealth then

							local newHealth = currentHealth - 15;
							possibleEnemyContestant:updateHealth(newHealth, {
								contestant = contestant;
								actionID = MeleeServerAction.ID;
							});

						end

					end;

				end;

			end);

		end;

		local basePartCurrentDurability = basePart:GetAttribute("CurrentDurability") :: number?;
		if basePartCurrentDurability and basePartCurrentDurability > 0 then

			ServerStorage.Functions.ModifyPartCurrentDurability:Invoke(basePart, basePartCurrentDurability - 35, contestant);

		end;

	end);




end

local function startAttack(primaryPart, animations, combo, round, contestant)
	combo = "Melee" .. tostring(combo + 1)
	print("Animating " .. combo)
	--perhaps some of this could be clientside
	animations["Melee1"]:Stop(0.3)
	animations["Melee2"]:Stop(0.3)
	animations["Melee3"]:Stop(0.3)
	local animData = Vector3.new(0.1,1,1)
	animations[combo]:Play(animData.X,animData.Y,animData.Z)


	local linearVelocity = Instance.new("LinearVelocity", primaryPart)
	linearVelocity.VelocityConstraintMode = "Line"
	linearVelocity.LineVelocity = -5
	linearVelocity.MaxForce = math.huge
	linearVelocity.RelativeTo = "Attachment0"
	local attachment = Instance.new("Attachment", primaryPart)
	attachment.Axis = Vector3.new(0,0,-1)
	linearVelocity.Attachment0 = attachment

	local tween = TweenService:Create(linearVelocity, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {LineVelocity = 22})
	tween:Play()

	task.delay(0.5, function()
		local tween = TweenService:Create(linearVelocity, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {LineVelocity = 0})
		tween:Play()
		task.delay(0.2, function()
			linearVelocity:Destroy()
			attachment:Destroy()
		end);


	end);
	task.delay(1, function()

		animations[combo]:AdjustWeight(0.01,0.5)

	end);


	--damageEvent(primaryPart, round, contestant)

	return
end


local function preloadAnims(char, animations)

	local humanoid = char.Humanoid


	local animator = humanoid:FindFirstChild("Animator")
	local anims = {}

	for i, anim in animations do
		local v = anim:split(", ")
		anims[v[1]] = Instance.new("Animation");
		anims[v[1]].AnimationId = "rbxassetid://" .. v[2];
		anims[v[1]] = animator:LoadAnimation(anims[v[1]]);

	end

	return anims
end


function MeleeServerAction.new(contestant: ServerContestant, round: ServerRound, data): ServerAction

	local combo = 0
	local animations = {
		"Melee1, 77919655263406",
		"Melee2, 101769847900220",
		"Melee3, 136026551879479",
	};

	local anims = preloadAnims(contestant.character, animations)
	local humanoid = contestant.character.Humanoid
	local action: ServerAction = nil;
	local debounce = Instance.new("StringValue", contestant.character)
	debounce.Name = "MeleeAttackDebounce"
	debounce.Value = "False"
	local function activate()

		if contestant.character then
			if not contestant.character.HumanoidRootPart:FindFirstChild("FlightConstraint") then
				if debounce.Value == "False" then
					if humanoid:GetAttribute("CurrentStamina") >= 5 then
						-- Reduce the player's stamina.
						humanoid:SetAttribute("CurrentStamina", humanoid:GetAttribute("CurrentStamina") - 5)
						debounce.Value = "True"
						task.delay(0.66, function()

							debounce.Value = "False"

						end);
						print("meleeing")
						startAttack(contestant.character.HumanoidRootPart, anims, combo, round, contestant)
						combo += 1
						local storedCombo = combo
						if combo == 3 then combo = 0 else
							task.wait(2)
							if combo == storedCombo then
								combo = 0
							end
						end
					end
				elseif debounce.Value == "True" then
					debounce.Value = "NoFurtherInputs"
					debounce.Changed:Wait()
					activate()
				end
			end
		end;

	end;


	local executeActionRemoteFunction: RemoteFunction? = nil;

	local function breakdown()

		if executeActionRemoteFunction then

			executeActionRemoteFunction:Destroy();

		end



	end;




	action = ServerAction.new({
		name = MeleeServerAction.name;
		ID = MeleeServerAction.ID;
		description = MeleeServerAction.description;
		breakdown = breakdown;
		activate = activate;
	});

	if contestant.player then

		local remoteFunction = Instance.new("RemoteFunction");
		remoteFunction.Name = `{contestant.player.UserId}_{action.ID}`;
		remoteFunction.OnServerInvoke = function(player)

			if player == contestant.player then



				action:activate();

			else

				-- That's weird.
				error("Unauthorized.");

			end

		end;
		remoteFunction.Parent = ReplicatedStorage.Shared.Functions.ActionFunctions;
		executeActionRemoteFunction = remoteFunction;

	end

	return action;

end;




return MeleeServerAction;