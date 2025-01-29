--!strict
-- Programmers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local BeastSlashClientAction = require(ReplicatedStorage.Client.Classes.Actions.BeastSlashClientAction);
local displayObjects = ReplicatedStorage.Shared.InGameDisplayObjects;
local types = require(ServerStorage.Modules.types);
local melee = require(script.Framework);

local animateSprite = require(ReplicatedStorage.Shared.Modules.animateSprite);
local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);
local preloadAnimations = require(ServerStorage.Modules.preloadAnimations);

local MeleeServerAction = {
	id = BeastSlashClientAction.id;
	name = BeastSlashClientAction.name;
	description = BeastSlashClientAction.description;
	__index = {} :: types.MeleeServerAction;
};

function meleeAttackEffect(character, combo)

	local effect = displayObjects.ChargedAttackEffect:Clone()
	effect.Parent = character
	effect.Root.CFrame = character.HumanoidRootPart.CFrame
	effect.Root.RigidConstraint.Attachment1 = character.HumanoidRootPart.RootAttachment

	if combo == 1 then

		effect.Right:Destroy()

	elseif combo == 2 then

		effect.Left:Destroy()

	end

	for _, item in effect:GetChildren() do

		if item.Name ~= "Root" then

			for _, child in item:GetChildren() do

				if child:IsA("SurfaceGui") then

					local data = {
						frameRate = 45,
						sprite = child.Sprite,
						spriteSheet = "6x5"
					}

					coroutine.wrap(animateSprite)(data, 1)

				end

			end

		end

		task.delay(1.2, function()

			effect:Destroy()

		end)
		
	end
end

function MeleeServerAction.new(properties: types.ServerActionConstructorProperties): types.MeleeServerAction

	local overwrittenProperties = {
		name = MeleeServerAction.name;
		id = MeleeServerAction.id;
		description = MeleeServerAction.description;
		contestant = properties.contestant;
		round = properties.round;
	};

  local action = (setmetatable(overwrittenProperties, MeleeServerAction) :: any) :: types.MeleeServerAction;

	local animations = {
		Melee1 = 77919655263406;
		Melee2 = 101769847900220;
		Melee3 = 136026551879479;
	};

	local character = action.contestant.character;
	assert(character);
	local humanoid = character:FindFirstChild("Humanoid") :: Humanoid;
	local animator = humanoid:FindFirstChild("Animator") :: Animator;
	action.animationTracks = preloadAnimations(humanoid, animator, animations);

	if action.contestant.player then

		action.remoteFunction = createInventoryRemoteFunction(action.contestant.player, "Action", `{action.contestant.player.UserId}_{action.id}`, function()
    
      action:activate();

    end);

	end

	return action;

end;

function MeleeServerAction.__index:activate()

	local character = self.contestant.character;
	assert(character);

	if self.contestant and self.contestant.currentHealth > 0 then

		local primaryPart = character.PrimaryPart :: BasePart;

		if not primaryPart:FindFirstChild("FlightConstraint") then

			local meleeData = {
				animName = "Melee",
				maxCombo = 3,
				animations = self.animationTracks,
				contestant = self.contestant,
				actionID = self.id;
			};

			melee.KeyDown(meleeData, meleeAttackEffect, self.round, "DK");

		end

	end

end;

function MeleeServerAction.__index:breakdown()

	if self.remoteFunction then

		self.remoteFunction:Destroy();

	end

end

return MeleeServerAction;