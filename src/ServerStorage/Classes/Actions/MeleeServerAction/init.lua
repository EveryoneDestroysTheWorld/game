--!strict
-- Programmers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local MeleeClientAction = require(ReplicatedStorage.Client.Classes.Actions.MeleeClientAction);
local displayObjects = ReplicatedStorage.Client.InGameDisplayObjects;
local types = require(ServerStorage.Classes.types);
local melee = require(script.Framework);

local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);

local MeleeServerAction = {
	id = MeleeClientAction.id;
	name = MeleeClientAction.name;
	description = MeleeClientAction.description;
	__index = {} :: types.MeleeServerAction;
};

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

function meleeAttackEffect(character, combo)
	local effect = displayObjects.DraconicKnight.ChargedAttackEffect:Clone()
	effect.Parent = character
	effect.Root.CFrame = character.HumanoidRootPart.CFrame
	effect.Root.RigidConstraint.Attachment1 = character.HumanoidRootPart.RootAttachment
	local animateSprite = require(displayObjects.SpriteAnimator)
	if combo == 1 then
		effect.Right:Destroy()
	elseif combo == 2 then
		effect.Left:Destroy()
	end
	for i, item in ipairs(effect:GetChildren()) do
		if item.Name ~= "Root" then
			for i, child in ipairs(item:GetChildren()) do
				if child:IsA("SurfaceGui") then
					local data = {
						FrameRate = 45,
						Sprite = child.Sprite,
						SpriteSheet = "6x5"
					}
					coroutine.wrap(animateSprite.animateSprite)(data, 1)
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
		Melee1 = "77919655263406";
		Melee2 = "101769847900220";
		Melee3 = "136026551879479";
	};

	assert(contestant.character);
	local humanoid = contestant.character:FindFirstChild("Humanoid") :: Humanoid;
	anims = preloadAnims(humanoid, animations);

	if action.contestant.player then

		action.remoteFunction = createInventoryRemoteFunction(action.contestant.player, "Action", `{action.contestant.player.UserId}_{action.id}`, function()
    
      action:activate();

    end);

	end

	return action;

end;

function MeleeServerAction.__index:activate()

	if not self.contestant.character:FindFirstChild("ButtonDown") then

		self.buttonDown = Instance.new("BoolValue", self.contestant.character)
		self.buttonDown.Name = "ButtonDown"

	end

	if self.contestant and self.contestant.character and self.contestant.currentHealth > 0 then

		self.buttonDown.Value = not self.buttonDown.Value;

		local primaryPart = self.contestant.character.PrimaryPart :: BasePart;

		if not primaryPart:FindFirstChild("FlightConstraint") then

			local meleeData = {
				animName = "Melee",
				maxCombo = 3,
				Animations = anims,
				Contestant = self.contestant,
				actionID = 8
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