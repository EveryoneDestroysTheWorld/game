--!strict
-- Programmer: Hati (hati_bati)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 Beastslash LLC

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

local function startAttack(primaryPart, animations, combo: number, round, contestant)

	local animationName = `Melee{combo + 1}`;
	print("Animating " .. combo)
	--perhaps some of this could be clientside
	animations["Melee1"]:Stop(0.3)
	animations["Melee2"]:Stop(0.3)
	animations["Melee3"]:Stop(0.3)
	local animData = Vector3.new(0.1, 1, 1)
	animations[animationName]:Play(animData.X,animData.Y,animData.Z)

	local linearVelocity = Instance.new("LinearVelocity", primaryPart)
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Line;
	linearVelocity.LineVelocity = -5
	linearVelocity.MaxForce = math.huge
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0;
	local attachment = Instance.new("Attachment", primaryPart)
	attachment.Axis = Vector3.new(0, 0, -1)
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

		animations[animationName]:AdjustWeight(0.01, 0.5)

	end);


	--damageEvent(primaryPart, round, contestant)

	return
end


local function preloadAnims(humanoid: Humanoid, animations: {[string]: string})

	local animator = humanoid:FindFirstChild("Animator") :: Animator;
	local anims: {[string]: AnimationTrack} = {}

	for animationName, assetID in pairs(animations) do

		local animation = Instance.new("Animation");
		animation.AnimationId = `rbxassetid://{assetID}`;
		anims[animationName] = animator:LoadAnimation(animation);

	end

	return anims;

end

function MeleeServerAction.new(): ServerAction

	local _contestant: ServerContestant? = nil;
	local _round: ServerRound? = nil;
	local combo: number = 0;
	local _humanoid: Humanoid? = nil;
	local anims: {[string]: AnimationTrack} = {};
	local debounce = false;

	local function activate(self: ServerAction)

		if _contestant and _contestant.character then

			local primaryPart = _contestant.character.PrimaryPart :: BasePart;
			local shouldRepeat: boolean;
			repeat

				shouldRepeat = false;
				if not primaryPart:FindFirstChild("FlightConstraint") then

					if not debounce then

						if _contestant.currentStamina >= 5 then
							
							debounce = true;

							-- Reduce the player's stamina.
							_contestant:updateStamina(math.max(0, _contestant.currentStamina - 5));
							task.delay(0.66, function()

								debounce = false;

							end);

							startAttack(primaryPart, anims, combo, _round, _contestant)
							combo += 1

							local storedCombo = combo
							if combo == 3 then combo = 0 else

								task.wait(2)

								if combo == storedCombo then

									combo = 0

								end

							end
							
						end

					end
					
				end

			until not shouldRepeat;

		end;

	end;

	local executeActionRemoteFunction: RemoteFunction? = nil;

	local function breakdown()

		if executeActionRemoteFunction then

			executeActionRemoteFunction:Destroy();

		end

	end;

	local function initialize(self: ServerAction, contestant: ServerContestant)

		local animations = {
			Melee1 = "77919655263406";
			Melee2 = "101769847900220";
			Melee3 = "136026551879479";
		};
	
		assert(contestant.character);
		local humanoid = contestant.character:FindFirstChild("Humanoid") :: Humanoid;
		anims = preloadAnims(humanoid, animations);

		if contestant.player then

			local remoteFunction = Instance.new("RemoteFunction");
			remoteFunction.Name = `{contestant.player.UserId}_{self.ID}`;
			remoteFunction.OnServerInvoke = function(player)
	
				if player == contestant.player then

					self:activate();
	
				else
	
					-- That's weird.
					error("Unauthorized.");
	
				end
	
			end;
			remoteFunction.Parent = ReplicatedStorage.Shared.Functions.ActionFunctions;
			executeActionRemoteFunction = remoteFunction;
	
		end

		_humanoid = humanoid;
		_contestant = contestant;

	end;

	return ServerAction.new({
		name = MeleeServerAction.name;
		ID = MeleeServerAction.ID;
		description = MeleeServerAction.description;
		breakdown = breakdown;
		activate = activate;
		initialize = initialize;
	});

end;

return MeleeServerAction;