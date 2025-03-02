--!strict
-- Programmer: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local TweenService = game:GetService("TweenService");

local displayObjects = ReplicatedStorage.Shared.InGameDisplayObjects;
local FireBeamClientAction = require(ReplicatedStorage.Client.Classes.Actions.FireBeamClientAction);
local IFireBeamServerAction = require(ServerStorage.Interfaces.IFireBeamServerAction);
local IServerContestant = require(ServerStorage.Interfaces.IServerContestant);
local IServerRound = require(ServerStorage.Interfaces.IServerRound);

local createInventoryRemoteEvent = require(ServerStorage.Modules.createInventoryRemoteEvent);
local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);
local animateSprite = require(ReplicatedStorage.Shared.Modules.animateSprite);
local calculateCharge = require(ServerStorage.Modules.calculateCharge);

type IServerContestant = IServerContestant.IServerContestant;
type IServerRound = IServerRound.IServerRound;
type IFireBeamServerAction = IFireBeamServerAction.IFireBeamServerAction;

local FireBeamServerAction = {
	id = FireBeamClientAction.id;
	name = FireBeamClientAction.name;
	description = FireBeamClientAction.description;
};

function FireBeamServerAction.new(contestant: IServerContestant, round: IServerRound): IFireBeamServerAction

	local coordinates = Vector3.zero;
	local charge = 0;
	local startChargeTimeMilliseconds: number?;
	local maxChargeDurationMilliseconds = 2000;

	local function activate(self: IFireBeamServerAction, shouldCharge: boolean)

		local character = contestant.character;
		assert(character);
	
		local primaryPart = character.PrimaryPart;
		assert(primaryPart);
	
		local isContestantFlying = not not primaryPart:FindFirstChild("FlightConstraint");
		assert(isContestantFlying);
	
		if shouldCharge then
	
			local function chargeAttack(): ()

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
			
						local player = contestant.player;
						if contestant.currentStamina <= 0 then
			
							if self.remoteEvent and player then
			
								self.remoteEvent:FireClient(player);
			
							end;
			
							self:activate(false);
							break;
			
						else
			
							if self.remoteEvent and player then
			
								self.remoteEvent:FireClient(player, true);
			
							end;
			
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
			
			end

			chargeAttack()
	
		else
	
			local function fireAttack()

				if not startChargeTimeMilliseconds then
			
					return;
			
				end;
			
				local chargeMeter = primaryPart:FindFirstChild("ChargeMeter") :: Instance;
			
				local data = {
					frameRate = 128,
					sprite = chargeMeter:FindFirstChild("Sprite") :: ImageLabel,
					spriteSheet = "8x8"
				}
			
				charge = calculateCharge(startChargeTimeMilliseconds, maxChargeDurationMilliseconds) * 100;
			
				if charge >= 15 then
			
					local character = primaryPart.Parent;
					assert(character);
			
					local head = character:FindFirstChild("Head");
					assert(head);
			
					local faceCenterAttachment = head:FindFirstChild("FaceCenterAttachment");
					assert(faceCenterAttachment and faceCenterAttachment:IsA("Attachment"));
			
					if self.remoteEvent and contestant.player then
			
						self.remoteEvent:FireClient(contestant.player, true);
			
					end;
			
					local fireBeamProp = displayObjects:FindFirstChild("FireBeamProp"):Clone()
					fireBeamProp.Parent = primaryPart.Parent
					fireBeamProp.Root.Position = faceCenterAttachment.WorldPosition
					fireBeamProp.AlignPosition.Attachment1 = faceCenterAttachment
					local putOnPlayer = fireBeamProp.PutOnPlayer.HumanoidRootPart:GetChildren()
					for _, item in putOnPlayer do
			
						item.Parent = primaryPart
			
					end
					fireBeamProp.PutOnPlayer:Destroy()
			
					local fireWallProps = {}
					fireBeamProp.Target.Position = coordinates;
					fireBeamProp.Target.CanTouch = true
					fireBeamProp.Target.Size = Vector3.new(4,4,4)
					local damageConnect = {}
					local connectDebounce = {}
			
					local function setOnFire(model: Model)
			
						local existingFireDebuffProp = model:FindFirstChild("FireDebuffProp");
						if existingFireDebuffProp then 
			
							existingFireDebuffProp:SetAttribute("Duration", 6)
							
						else
							
							local humanoidRootPart = model:FindFirstChild("HumanoidRootPart");
							if humanoidRootPart then
			
								local newFireDebuffProp = displayObjects.FireDebuffProp:Clone();
								newFireDebuffProp.Parent = model
								newFireDebuffProp.RigidConstraint.Attachment1 = humanoidRootPart:FindFirstChild("RootAttachment")
								newFireDebuffProp:SetAttribute("Duration", 6)
								newFireDebuffProp.Highlight.Adornee = model
						
								task.delay(1/30, function()
			
									while newFireDebuffProp:GetAttribute("Duration") ~= 0 and task.wait(1) do
										
										newFireDebuffProp:SetAttribute("Duration", newFireDebuffProp:GetAttribute("Duration") :: number - 1)
										for _, contestant in round:getContestants() do
			
											if contestant.character and contestant.character == model then
			
												--print(contestant)
			
												contestant:setCurrentHealth(contestant.currentHealth - 4, {
													contestantID = contestant.id;
													actionID = self.id;
												});
												
											end
			
										end
			
									end 
			
									newFireDebuffProp:Destroy()
			
								end)
			
							end;
			
						end
			
					end
			
					damageConnect[1] = fireBeamProp.Target.Touched:Connect(function(touched)
			
						if not connectDebounce["All"] then
			
							connectDebounce["All"] = true
							task.delay(1/30, function()
			
								connectDebounce["All"] = false
			
							end)
			
							local model = touched:FindFirstAncestorOfClass("Model")
							if not connectDebounce[model] then
			
								connectDebounce[model] = true
								task.delay(0.5, function()
								
									connectDebounce[model] = false
								
								end)
								setOnFire(model)
							
							end
						
						end
					
					end)
					
					repeat
			
						local rate = 6
						fireWallProps[#fireWallProps + 1] = fireBeamProp.Target:Clone()
						fireWallProps[#fireWallProps].Parent = fireBeamProp
						fireWallProps[#fireWallProps].Name = tostring(#fireWallProps)
						if #fireWallProps >= 2 then
			
							fireWallProps[#fireWallProps - 1].CFrame = CFrame.lookAt(fireWallProps[#fireWallProps - 1].Position, fireWallProps[#fireWallProps].Position)
							fireWallProps[#fireWallProps - 1].Position = (fireWallProps[#fireWallProps - 1].Position + fireWallProps[#fireWallProps].Position) / 2
							fireWallProps[#fireWallProps - 1].Size = Vector3.new(1,1,((fireWallProps[#fireWallProps - 1].Position - fireWallProps[#fireWallProps].Position).Magnitude)*2)
							fireWallProps[#fireWallProps - 1].FireAfter.Rate = fireWallProps[#fireWallProps - 1].Size.Z
							rate += fireWallProps[#fireWallProps - 1].Size.Z / 2
			
							damageConnect[#damageConnect] = fireWallProps[#fireWallProps - 1].Touched:Connect(function(touched)
			
								if not connectDebounce["All"] then
			
									connectDebounce["All"] = true
									task.delay(1/30, function()
			
										connectDebounce["All"] = false
			
									end)
			
									local model = touched:FindFirstAncestorOfClass("Model")
									if not connectDebounce[model] then
			
										connectDebounce[model] = true
										task.delay(0.5, function()
			
											connectDebounce[model] = false
			
										end)
										setOnFire(model)
			
									end
			
								end
			
							end)
			
						end
						local distance = (fireBeamProp.Particles.Atch.WorldPosition - fireBeamProp.Target.Position).Magnitude * 4
						local tween1 = TweenService:Create(fireBeamProp.Target, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {Position = coordinates or Vector3.zero})
						tween1:Play()
			
						fireBeamProp.Particles.Fire.Speed = NumberRange.new(distance, distance);
						coroutine.wrap(animateSprite)(data, charge / 100)
						charge -= rate;
			
						task.wait(0.2)
			
					until charge <= 0
			
					startChargeTimeMilliseconds = nil;
					fireBeamProp.Particles:Destroy()
					fireBeamProp.Root:Destroy()
					fireBeamProp.Target.FireAfter.Rate = 0
			
					fireWallProps[#fireWallProps - 1].CFrame = CFrame.lookAt(fireWallProps[#fireWallProps - 1].Position, fireBeamProp.Target.Position)
					fireWallProps[#fireWallProps - 1].Position = (fireWallProps[#fireWallProps - 1].Position + fireBeamProp.Target.Position) / 2
					fireWallProps[#fireWallProps - 1].Size = Vector3.new(3,3,((fireWallProps[#fireWallProps - 1].Position - fireBeamProp.Target.Position).Magnitude)*2)
			
					task.delay(1/15, function()
			
						local tween = TweenService:Create(fireBeamProp.Target, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Position = Vector3.new(fireBeamProp.Target.Position.X,primaryPart.Position.Y,fireBeamProp.Target.Position.Z)})
						tween:Play()
						task.wait(0.5)
			
						for i, item in ipairs(putOnPlayer) do
			
							item:Destroy()
			
						end
			
					end)
			
					task.delay(5, function()
			
						for i, item in ipairs(fireWallProps) do
							item.FireAfter.Rate = 0
						end
			
						task.wait(2)
						fireBeamProp:Destroy()
			
						for i, con in ipairs(damageConnect) do
			
							con:Disconnect()
			
						end
			
					end)
				
				end
				
				if self.remoteEvent and contestant.player then
			
					self.remoteEvent:FireClient(contestant.player, false);
			
				end;
			
				coroutine.wrap(animateSprite)(data, 0)
			
				task.delay(1, function()
			
					chargeMeter:Destroy()
			
				end)
			
			end

			fireAttack();
	
		end
	
	end

	local function breakdown(self: IFireBeamServerAction)

		if self.remoteFunction then
	
			self.remoteFunction:Destroy();
	
		end
	
		if self.remoteEvent then
	
			self.remoteEvent:Destroy();
	
		end;
	
		if contestant.player then
	
			ReplicatedStorage.Shared.Functions.BreakdownAction:InvokeClient(contestant.player, self.id);
	
		end;
	
	end

	local action = {
		attributes = {};
		contestantID = contestant.id;
		description = FireBeamClientAction.description;
		name = FireBeamClientAction.name;
		id = FireBeamClientAction.id;
		activate = activate;
		breakdown = breakdown;
	};

	local player = contestant.player;
	if player then

		local remoteID = `{player.UserId}_{action.id}`;
		action.remoteFunction = createInventoryRemoteFunction(player, "Action", remoteID, function(shouldCharge: boolean)
    
			assert(not shouldCharge or typeof(shouldCharge) == "boolean");
      action:activate(shouldCharge);

    end);

		local remoteEvent = createInventoryRemoteEvent(player, "Action", remoteID);
		remoteEvent.OnServerEvent:Connect(function(player: Player, coordinates: Vector3)
		
			assert(player == contestant.player);
			assert(typeof(coordinates) == "Vector3");
			action.coordinates = coordinates;

		end);
		action.remoteEvent = remoteEvent;

		ReplicatedStorage.Shared.Functions.InitializeAction:InvokeClient(player, action.id);

	end

	return action;

end

return FireBeamServerAction;