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

local BeastSlashServerAction = {
	id = BeastSlashClientAction.id;
	name = BeastSlashClientAction.name;
	description = BeastSlashClientAction.description;
	__index = {
		name = BeastSlashClientAction.name;
		id = BeastSlashClientAction.id;
		description = BeastSlashClientAction.description
	} :: types.BeastSlashServerAction;
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

function BeastSlashServerAction.new(properties: types.ServerActionConstructorProperties): types.BeastSlashServerAction

	local overwrittenProperties = {
		contestant = properties.contestant;
	};

  local action = (setmetatable(overwrittenProperties, BeastSlashServerAction) :: any) :: types.BeastSlashServerAction;

	local animations = {
		Melee1 = 77919655263406;
		Melee2 = 101769847900220;
		Melee3 = 136026551879479;
	};

	local character = action.contestant.character;
	assert(character);
	local humanoid = character:FindFirstChild("Humanoid") :: Humanoid;
	local animator = humanoid:FindFirstChild("Animator") :: Animator;
	action.animationTracks = preloadAnimations(animator, animations);

	local player = action.contestant.player;
	if player then

		action.remoteFunction = createInventoryRemoteFunction(player, "Action", `{player.UserId}_{action.id}`, function()
    
      action:activate();

    end);

		ReplicatedStorage.Shared.Functions.InitializeAction:InvokeClient(player, action.id);

	end

	return action;

end;

function BeastSlashServerAction.__index:activate()

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
			};

			melee.KeyDown(self, meleeData, meleeAttackEffect, self.contestant.round, "DK");

		end

	end

end;

function BeastSlashServerAction.__index:breakdown()

	if self.remoteFunction then

		self.remoteFunction:Destroy();

	end

	if self.contestant.player then

    ReplicatedStorage.Shared.Functions.BreakdownAction:InvokeClient(self.contestant.player, self.id);

  end;

end

return BeastSlashServerAction;