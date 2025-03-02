--!strict
-- Programmers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local TweenService = game:GetService("TweenService");

local displayObjects = ReplicatedStorage.Shared.InGameDisplayObjects;
local TarBombClientAction = require(ReplicatedStorage.Client.Classes.Actions.TarBombClientAction);
local IServerContestant = require(ServerStorage.Interfaces.IServerContestant);
local IServerRound = require(ServerStorage.Interfaces.IServerRound);
local ITarBombServerAction = require(ServerStorage.Interfaces.ITarBombServerAction);
local TarBomb = require(script.TarBomb);

local animateSprite = require(ReplicatedStorage.Shared.Modules.animateSprite);
local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);
local mergeTable = require(ReplicatedStorage.Shared.Modules.mergeTable);
local preloadAnimations = require(ServerStorage.Modules.preloadAnimations);

type ITarBombServerAction = ITarBombServerAction.ITarBombServerAction;
type IServerContestant = IServerContestant.IServerContestant;
type IServerRound = IServerRound.IServerRound;

local TarBombServerAction = {
	id = TarBombClientAction.id;
	name = TarBombClientAction.name;
	description = TarBombClientAction.description;
};

function TarBombServerAction.new(contestant: IServerContestant, round: IServerRound): ITarBombServerAction

	local animationTracks = {};
	local startChargeTimeMilliseconds: number? = nil;
	local maxChargeDurationMilliseconds = 2000;

	local function activate(self: ITarBombServerAction, shouldCharge: boolean, coordinates: Vector3?, shouldUseTarget: boolean?, shouldBypassStaminaCheck: boolean?)

		local draconicKnightTargetModel = contestant.attributes.draconicKnightTargetModel
		if shouldUseTarget and typeof(draconicKnightTargetModel) == "Model" and draconicKnightTargetModel.PrimaryPart then 

			coordinates = draconicKnightTargetModel.PrimaryPart.Position;

		end

		assert(contestant.currentStamina >= 20 or shouldBypassStaminaCheck);

		local character = contestant.character;
		assert(character);

		local primaryPart = character.PrimaryPart;
		assert(primaryPart);

		if shouldCharge then

			warn("charge")
			assert(character.PrimaryPart);
			local fireBreathChargeGUI = displayObjects:FindFirstChild("ChargeMeter"):Clone()

			fireBreathChargeGUI.Parent = primaryPart
			fireBreathChargeGUI.Adornee = primaryPart

			local data = {
				frameRate = 64/2,
				sprite = fireBreathChargeGUI.Sprite,
				spriteSheet = "8x8"
			}

			coroutine.wrap(animateSprite)(data, 1)

			local originalChargeTime = DateTime.now().UnixTimestampMillis;
			startChargeTimeMilliseconds = originalChargeTime;

			task.spawn(function()

				while task.wait(0.05) and startChargeTimeMilliseconds == originalChargeTime do

					if contestant.currentStamina <= 0 then

						local coordinates = Vector3.zero;
						if self.remoteFunction and contestant.player then
							
							coordinates = self.remoteFunction:InvokeClient(contestant.player);
							if typeof(coordinates) ~= "Vector3" then

								startChargeTimeMilliseconds = nil;
								error("Coordinates must be a Vector3.");

							end;

						end;

						self:activate(false, coordinates, nil, true)
						break;

					else

						contestant:setCurrentStamina(contestant.currentStamina - 1, {
							actionID = self.id;
							contestantID = contestant.id;
						});

					end;

				end;

			end);

			task.delay(maxChargeDurationMilliseconds / 1000, function()

				if startChargeTimeMilliseconds == originalChargeTime then

					task.delay(1/15, function()
					
						local highlight = Instance.new("Highlight", primaryPart.Parent)
						highlight.Name = "FullyChargedHighlight"
						highlight.OutlineTransparency = 1
						highlight.FillTransparency = 1
			
						while startChargeTimeMilliseconds == originalChargeTime do
			
							local tween = TweenService:Create(highlight, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 1, true), {FillTransparency = 0.7})
							tween:Play()
							task.wait(1)
			
						end

						highlight:Destroy();
			
					end)

				end;
			
			end);

		else

			warn("fire")
			assert(coordinates);
			local charge = 0;
			if startChargeTimeMilliseconds then

				local goalTime = startChargeTimeMilliseconds + maxChargeDurationMilliseconds;
				local queryTime = math.min(goalTime, DateTime.now().UnixTimestampMillis);
				charge = math.min((maxChargeDurationMilliseconds - (goalTime - queryTime)) / maxChargeDurationMilliseconds, 1) * 100;
				startChargeTimeMilliseconds = nil;
			
			end;

			-- Reduce the player's stamina.
			contestant:setCurrentStamina(math.max(0, contestant.currentStamina - 10 - charge), {
				actionID = self.id;
				contestantID = contestant.id;
			});
			local size = 2 + charge / 10

			local sourcePart = character:FindFirstChild("Head") or character.PrimaryPart;
			assert(sourcePart and sourcePart:IsA("BasePart"));

			TarBomb.new(sourcePart, coordinates, true, size, nil, round:getContestants(), {
				contestantID = contestant.id;
				actionID = self.id;
			});

		end;

	end;

	local function breakdown(self: ITarBombServerAction)

		if self.remoteFunction then

			self.remoteFunction:Destroy();
	
		end
	
		if contestant.player then
	
			ReplicatedStorage.Shared.Functions.BreakdownAction:InvokeClient(contestant.player, self.id);
	
		end;

	end;

	local action: ITarBombServerAction = {
		attributes = {};
		contestantID = contestant.id;
		description = TarBombServerAction.description;
		id = TarBombServerAction.id;
		name = TarBombServerAction.name;
		activate = activate;
		breakdown = breakdown;
	};

	local character = contestant.character;
	if character then

		local humanoid = character:FindFirstChild("Humanoid") :: Humanoid;
		local wingProp = (humanoid.Parent :: Instance):FindFirstChild("WingProp") :: Model;
		local wingsPropRight = wingProp:FindFirstChild("WingsPropRight") :: Instance;
		local wingsPropLeft = wingProp:FindFirstChild("WingsPropLeft") :: Instance;

		animationTracks = mergeTable(animationTracks, preloadAnimations(wingsPropLeft:FindFirstChild("Animator") :: Animator, {
			left = 95242287519828
		}));

		animationTracks = mergeTable(animationTracks, preloadAnimations(wingsPropRight:FindFirstChild("Animator") :: Animator, {
			right = 89949470467953
		}));

		animationTracks = mergeTable(animationTracks, preloadAnimations(humanoid:FindFirstChild("Animator") :: Animator, {
			player = 85718382304634
		}));

	end;

	local player = contestant.player;
	if player then

		local remoteFunction = createInventoryRemoteFunction(player, "Action", `{player.UserId}_{action.id}`, function(shouldCharge: boolean, coordinates: Vector3?, shouldUseTarget: boolean?)

			assert(typeof(shouldCharge) == "boolean");
			assert(not coordinates or typeof(coordinates) == "Vector3");
			assert(not shouldUseTarget or typeof(coordinates) == "boolean");

			return action:activate(shouldCharge, coordinates, shouldUseTarget);

		end);

		action.remoteFunction = remoteFunction;

		ReplicatedStorage.Shared.Functions.InitializeAction:InvokeClient(player, action.id);

	end

	return action;

end;

return TarBombServerAction;
