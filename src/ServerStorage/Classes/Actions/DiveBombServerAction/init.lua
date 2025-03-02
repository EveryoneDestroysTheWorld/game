--!strict
-- Programmers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney) and Hati (hati_bati)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local TweenService = game:GetService("TweenService");

local damageFramework = require(ServerStorage.Modules.DamageFramework);
local DiveBombClientAction = require(ReplicatedStorage.Client.Classes.Actions.DiveBombClientAction);
local IDiveBombServerAction = require(ServerStorage.Interfaces.IDiveBombServerAction);
local IServerContestant = require(ServerStorage.Interfaces.IServerContestant);
local IServerRound = require(ServerStorage.Interfaces.IServerRound);
local ParalysisServerEffect = require(ServerStorage.Classes.Effects.ParalysisServerEffect);

local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);

type IServerContestant = IServerContestant.IServerContestant;
type IServerRound = IServerRound.IServerRound;
type IDiveBombServerAction = IDiveBombServerAction.IDiveBombServerAction;

local DiveBombServerAction = {
	id = DiveBombClientAction.id;
	name = DiveBombClientAction.name;
	description = DiveBombClientAction.description;
};

function DiveBombServerAction.new(contestant: IServerContestant, round: IServerRound): IDiveBombServerAction

	local animationTracks = {};

	local function activate(self: IDiveBombServerAction, coordinates: Vector3, shouldUseTarget: boolean)

		if contestant and contestant.character and contestant.currentHealth > 0 and contestant.currentStamina >= 20 then

			-- Reduce the player's stamina.
			contestant:setCurrentStamina(math.max(0, contestant.currentStamina - 10), {
				actionID = self.id;
			});
			
			local primaryPart = contestant.character.PrimaryPart;
			assert(primaryPart, "Action requires the character to have a primary part.");

			local flightConstraint = primaryPart:FindFirstChild("FlightConstraint");
			if flightConstraint then
	
				local function startAttack()

					local flightConstraint = primaryPart:FindFirstChild("FlightConstraint");
				
					if flightConstraint then
				
						flightConstraint:Destroy()
				
					end
					
					primaryPart.CFrame = CFrame.lookAt((primaryPart.CFrame.Position), (coordinates * Vector3.new(1,0,1) + Vector3.new(0,primaryPart.CFrame.Position.Y, 0)));
				
					--perhaps some of this could be client side
					local animData = Vector3.new(0.1,1,1)
					animationTracks["Right"]:Play(animData.X,animData.Y,animData.Z);
					animationTracks["Left"]:Play(animData.X,animData.Y,animData.Z);
					animationTracks["Player"]:Play(animData.X,animData.Y,animData.Z);
				
					local part = Instance.new("Part");
					part.Parent = workspace.Terrain;
					part.Anchored = true
					part.CanCollide = false
					part.Transparency = 1;
				
					local rigidConstraint = Instance.new("RigidConstraint");
					rigidConstraint.Parent = part;
					rigidConstraint.Attachment0 = Instance.new("Attachment", part);
				
					part.CFrame = primaryPart.CFrame
					rigidConstraint.Attachment1 = primaryPart:FindFirstChild("RootAttachment") :: Attachment;
				
					local expectedPos;
				
					for i = 1, 5 do
				
						expectedPos = part.Position + (( part.CFrame.LookVector * -1 + Vector3.new(0,1/5,0)) * (5-i)) + ((part.CFrame.LookVector + Vector3.new(0,1/5,0)) * (i))
						local tween = TweenService:Create(part, TweenInfo.new(0.75/5, Enum.EasingStyle.Linear), {Position = expectedPos})
						tween:Play()
						task.wait(0.75/5);
				
					end
					animationTracks["Right"]:AdjustSpeed(1.5);
					animationTracks["Left"]:AdjustSpeed(1.5);
					animationTracks["Player"]:AdjustSpeed(1.5);
					
					local travelTime = 8/15
					local tween = TweenService:Create(part, TweenInfo.new(travelTime, Enum.EasingStyle.Linear), {
						Position = coordinates + Vector3.new(0, 0, 0);
					});
					tween:Play();
					task.wait(travelTime*0.8);
				
					local data = {
						size = 15;
					}
					damageFramework.explosionEvent(coordinates, data, round:getContestants(), self, function(possibleContestant)
					
						if possibleContestant ~= contestant then
				
							local paralysisEffect = ParalysisServerEffect.new({
								contestant = contestant;
							});
				
							contestant:addEffect(paralysisEffect);
							task.wait(1);
				
							contestant:removeEffect(paralysisEffect);
				
						end;
				
					end);
				
					task.wait(travelTime*0.2);
					
					animationTracks["Right"]:AdjustSpeed(1);
					animationTracks["Left"]:AdjustSpeed(1);
					animationTracks["Player"]:AdjustSpeed(1);
					task.wait(0.2)
					part:Destroy();
				
				end;

				startAttack();
	
			else
	
				local function groundDash()

					local character = contestant.character;
					assert(character);

					if shouldUseTarget then 

						local objectValue = character:FindFirstChild("Target") :: ObjectValue;
						if objectValue.Value and objectValue.Value:IsA("Model") and objectValue.Value.PrimaryPart then

							coordinates = objectValue.Value.PrimaryPart.Position;

						end;

					end

					local targetCoords
					local originalCoords = coordinates;
					primaryPart.CFrame = CFrame.lookAt((primaryPart.CFrame.Position), (coordinates * Vector3.new(1,0,1) + Vector3.new(0,primaryPart.CFrame.Position.Y, 0)));
					if (coordinates - primaryPart.Position).Magnitude > 50 then
						
						coordinates = (primaryPart.CFrame * CFrame.new(Vector3.new(0,0,-1 * (50)))).Position
						targetCoords = coordinates
						originalCoords = targetCoords
					else
						targetCoords = coordinates
						coordinates = CFrame.lookAt(coordinates, primaryPart.Position) * CFrame.new(Vector3.new(0,0,10)).Position
					end

					--perhaps some of this could be client side
					local animData = Vector3.new(0.2,1,3)
					animationTracks["Right"]:Play(animData.X,animData.Y,animData.Z);
					animationTracks["Left"]:Play(animData.X,animData.Y,animData.Z);
					animationTracks["Player"]:Play(animData.X,animData.Y,animData.Z);
					
					local part = Instance.new("Part");
					part.Parent = workspace.Terrain;
					part.Anchored = true
					part.CanCollide = false
					part.Transparency = 1;
					task.wait(0.1)
					local rigidConstraint = Instance.new("RigidConstraint");
					rigidConstraint.Parent = part;
					rigidConstraint.Attachment0 = Instance.new("Attachment", part);

					part.CFrame = primaryPart.CFrame
					rigidConstraint.Attachment1 = primaryPart:FindFirstChild("RootAttachment") :: Attachment;
					
					animationTracks["Right"]:AdjustSpeed(2);
					animationTracks["Left"]:AdjustSpeed(2);
					animationTracks["Player"]:AdjustSpeed(2);
					
					local travelTime = 8/15
					local tween = TweenService:Create(part, TweenInfo.new(travelTime, Enum.EasingStyle.Linear), {
						Position = coordinates + Vector3.new(0, 1, 0);
					});
					tween:Play();
					task.wait(travelTime*0.6);
					local data = {}
					damageFramework.explosionEvent(originalCoords, data, round:getContestants(), self);
					task.wait(travelTime*0.4);

					
					animationTracks["Right"]:AdjustSpeed(1);
					animationTracks["Left"]:AdjustSpeed(1);
					animationTracks["Player"]:AdjustSpeed(1);
					task.wait(0.2)
					part:Destroy();

				end;

				groundDash();
			
			end
	
		end

	end;

	local function breakdown(self: IDiveBombServerAction)

		if self.remoteFunction then

			self.remoteFunction:Destroy();
	
		end
	
		if contestant.player then
	
			ReplicatedStorage.Shared.Functions.BreakdownAction:InvokeClient(contestant.player, self.id);
	
		end;

	end;

	local action: IDiveBombServerAction = {
		attributes = {};
		contestantID = contestant.id;
		description = DiveBombServerAction.description;
		id = DiveBombServerAction.id;
		name = DiveBombServerAction.name;
		activate = activate;
		breakdown = breakdown;
	};

	if contestant.character then

		local function preloadAnimations(char: Model)

			local humanoid = char:FindFirstChild("Humanoid") :: Humanoid;
			local wingProp = (humanoid.Parent :: Instance):FindFirstChild("WingProp") :: Model;
			local wingsPropRight = wingProp:FindFirstChild("WingsPropRight") :: Instance;
			local wingsPropLeft = wingProp:FindFirstChild("WingsPropLeft") :: Instance;
			local animationAssets: {[string]: {animator: Animator; assetID: number}} = {
				Left = {
					animator = wingsPropLeft:FindFirstChild("Animator") :: Animator;
					assetID = 95242287519828;
				};
				Right = {
					animator = wingsPropRight:FindFirstChild("Animator") :: Animator;
					assetID = 89949470467953;
				};
				Player = {
					animator = humanoid:FindFirstChild("Animator") :: Animator;
					assetID = 85718382304634;
				};
			}
		
			local animationTracks = {};
			for key, data in pairs(animationAssets) do
		
				local animation = Instance.new("Animation");
				animation.AnimationId = `rbxassetid://{data.assetID};`
				animationTracks[key] = data.animator:LoadAnimation(animation);
		
			end;
		
			return animationTracks;
		
		end

		animationTracks = preloadAnimations(contestant.character);

	end;

	local player = contestant.player;
	if player then

		action.remoteFunction = createInventoryRemoteFunction(player, "Action", `{player.UserId}_{action.id}`, function(coordinates, shouldUseTarget)
		
			assert(typeof(coordinates) == "Vector3");
			assert(typeof(shouldUseTarget) == "boolean");

			action:activate(coordinates, shouldUseTarget);

		end);

		ReplicatedStorage.Shared.Functions.InitializeAction:InvokeClient(player, action.id);

	end

	return action;

end;

return DiveBombServerAction;
