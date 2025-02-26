--!strict
-- Programmers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local BeastSlashClientAction = require(ReplicatedStorage.Client.Classes.Actions.BeastSlashClientAction);
local displayObjects = ReplicatedStorage.Shared.InGameDisplayObjects;
local IBeastSlashServerAction = require(ServerStorage.Interfaces.IBeastSlashServerAction);
local IServerRound = require(ServerStorage.Interfaces.IServerRound);
local IServerContestant = require(ServerStorage.Interfaces.IServerContestant);
local melee = require(script.Framework);

local animateSprite = require(ReplicatedStorage.Shared.Modules.animateSprite);
local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);
local preloadAnimations = require(ServerStorage.Modules.preloadAnimations);

type IBeastSlashServerAction = IBeastSlashServerAction.IBeastSlashServerAction;
type IServerRound = IServerRound.IServerRound;
type IServerContestant = IServerContestant.IServerContestant;

local BeastSlashServerAction = {
	id = BeastSlashClientAction.id;
	name = BeastSlashClientAction.name;
	description = BeastSlashClientAction.description;
};

function BeastSlashServerAction.new(round: IServerRound, contestant: IServerContestant): IBeastSlashServerAction

	local function activate(self: IBeastSlashServerAction)

		local character = contestant:getCharacter();
		assert(character);
	
		if contestant and contestant.currentHealth > 0 then
	
			local primaryPart = character.PrimaryPart :: BasePart;
	
			if not primaryPart:FindFirstChild("FlightConstraint") then
	
				local meleeData = {
					animName = "Melee",
					maxCombo = 3,
					animations = self.attributes.animationTracks,
					contestant = contestant,
				};

				local function meleeAttackEffect(character, combo)

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
	
				melee.KeyDown(self, meleeData, meleeAttackEffect, round, "DK");
	
			end
	
		end
	
	end;

	local function breakdown(self: IBeastSlashServerAction)

		if self.remoteFunction then
	
			self.remoteFunction:Destroy();
	
		end
	
		if contestant.player then
	
			ReplicatedStorage.Shared.Functions.BreakdownAction:InvokeClient(contestant.player, self.id);
	
		end;
	
	end;

	local animations = {
		Melee1 = 77919655263406;
		Melee2 = 101769847900220;
		Melee3 = 136026551879479;
	};

	local character = contestant:getCharacter();
	assert(character);
	local humanoid = character:FindFirstChild("Humanoid") :: Humanoid;
	local animator = humanoid:FindFirstChild("Animator") :: Animator;
	local animationTracks = preloadAnimations(animator, animations);

	local action: IBeastSlashServerAction = {
		id = BeastSlashServerAction.id;
		name = BeastSlashServerAction.name;
		description = BeastSlashServerAction.description;
		attributes = {
			animationTracks = animationTracks;
		};
		contestantID = contestant.id;
		activate = activate;
		breakdown = breakdown;
	};

	local player = contestant.player;
	if player then

		action.remoteFunction = createInventoryRemoteFunction(player, "Action", `{player.UserId}_{BeastSlashServerAction.id}`, function()
    
      action:activate();

    end);

		ReplicatedStorage.Shared.Functions.InitializeAction:InvokeClient(player, action.id);

	end

	return action;

end;

return BeastSlashServerAction;