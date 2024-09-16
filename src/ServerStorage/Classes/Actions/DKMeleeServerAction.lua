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
local displayObjects = ReplicatedStorage.Client.InGameDisplayObjects

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

local function startAttack(primaryPart, animations, combo: number, round, contestant, buttonDown)
	local wasChargedAttack = false
	local animationName = `Melee{combo + 1}`;
	print("Animating " .. combo)
	--perhaps some of this could be clientside
	animations["Melee1"]:Stop(0.3)
	animations["Melee2"]:Stop(0.3)
	animations["Melee3"]:Stop(0.3)
	local animData = Vector3.new(0.1, 1, 0.6)
	animations[animationName]:Play(animData.X,animData.Y,animData.Z)
	local connection

	local linearVelocity = Instance.new("LinearVelocity", primaryPart)
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Line;
	linearVelocity.LineVelocity = -5
	linearVelocity.MaxForce = math.huge
	--linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0;
	local attachment = Instance.new("Attachment", primaryPart)
	--attachment.Axis = Vector3.new(0, 0, -1)
	linearVelocity.LineDirection = primaryPart.CFrame.LookVector
	linearVelocity.Attachment0 = attachment

	local tween = TweenService:Create(linearVelocity, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {LineVelocity = 22})
	tween:Play()
	if buttonDown.Value then

		connection = buttonDown.Changed:connect(function()
			connection:Disconnect()
			connection = nil
			tween:Cancel()
			animations["Melee1"]:AdjustSpeed(1)
			animations["Melee2"]:AdjustSpeed(1)
			animations["Melee3"]:AdjustSpeed(1)
		end)
	else
		animations["Melee1"]:AdjustSpeed(1)
		animations["Melee2"]:AdjustSpeed(1)
		animations["Melee3"]:AdjustSpeed(1)
	end
	if combo == 3 then
		task.wait(0.3)
	end
	tween.Completed:Connect(function()
		local tween = TweenService:Create(linearVelocity, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {LineVelocity = 22})
		tween:Play()
		task.wait(0.3)
		if connection then
			connection:Disconnect()
			wasChargedAttack = true
		end
		local tween = TweenService:Create(linearVelocity, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {LineVelocity = 0})
		tween:Play()
		task.delay(0.2, function()

			linearVelocity:Destroy()
			attachment:Destroy()
			if wasChargedAttack then
				print("That was a charged attack!!")
			else
				print("That was a regular attack")
			end
		end);
		task.delay(0.5, function()

			animations[animationName]:AdjustWeight(0.01, 0.5)

		end);

	end);




	--damageEvent(primaryPart, round, contestant)

	return
end

local function flyingAttackCharge(primaryPart, anims)
	print("charging the fire breath")
	local fireBreathChargeGUI = displayObjects:FindFirstChild("ChargeMeter"):Clone()
	fireBreathChargeGUI.Parent = primaryPart
	fireBreathChargeGUI.Adornee = primaryPart


	local animateSprite = require(displayObjects.SpriteAnimator)
	local data = {
		FrameRate = 64/2,
		Sprite = fireBreathChargeGUI.Sprite,
		SpriteSheet = "8x8"
	}
	coroutine.wrap(animateSprite.animateSprite)(data, 1)


	local fireBreathCharge = primaryPart.Parent:FindFirstChild("ButtonDown")
	fireBreathCharge:SetAttribute("Charge", 0)
	
	local connection
	connection = fireBreathCharge.Changed:Connect(function()
		connection:Disconnect()
		fireBreathCharge = nil
	end)
	repeat 
		fireBreathCharge:SetAttribute("Charge", fireBreathCharge:GetAttribute("Charge") + 5)
		task.wait(0.1) 
	until not fireBreathCharge or fireBreathCharge:GetAttribute("Charge") >= 100
	if fireBreathCharge then
		print("Fully Charged")
		task.delay(1/15, function()
			local highlight = Instance.new("Highlight", primaryPart.Parent)
			highlight.Name = "FullyChargedHighlight"
			highlight.OutlineTransparency = 1
			highlight.FillTransparency = 1
			local con
			con = fireBreathCharge.AttributeChanged:Connect(function()
				highlight:Destroy()
				con:Disconnect()
			end)

			repeat
			local tween = TweenService:Create(highlight, TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 1, true), {FillTransparency = 0.7})
			tween:Play()
			task.wait(1)
			until not primaryPart.Parent:FindFirstChild("FullyChargedHighlight")
		end)
	end
end

local function getDataFromClient(player: Player, toggle): Vector3
	local connection
	local event = player:FindFirstChild("FireBreathCoords")
	if not event then
		event = Instance.new("RemoteEvent", player)
		event.Name = "FireBreathCoords"
	end
	connection = event.OnServerEvent:Connect(function(_: Player, data: Vector3)
		event:SetAttribute("Coords", data);
	end)
	event:FireClient(player)
	event.AttributeChanged:Wait()
	connection:Disconnect()
	return event:GetAttribute("Coords") :: Vector3, connection;

end

local function flyingAttackFire(primaryPart, anims, combo, _round, _contestant)
	print("firing the fire breath")
	local coords, eventCon = getDataFromClient(_contestant.player);
	local fireBreathCharge = primaryPart.Parent:FindFirstChild("ButtonDown")

	local animateSprite = require(displayObjects.SpriteAnimator)
	local data = {
		FrameRate = 128,
		Sprite = primaryPart.ChargeMeter.Sprite,
		SpriteSheet = "8x8"
	}
	
	if fireBreathCharge:GetAttribute("Charge") >= 15 then
		local fireBeamProp = displayObjects:FindFirstChild("FireBeamProp"):Clone()
		fireBeamProp.Parent = primaryPart.Parent
		fireBeamProp.Root.Position = primaryPart.Parent.Head.FaceCenterAttachment.WorldPosition
		fireBeamProp.AlignPosition.Attachment1 = primaryPart.Parent.Head.FaceCenterAttachment
		local putOnPlayer = fireBeamProp.PutOnPlayer.HumanoidRootPart:GetChildren()
		for i, item in ipairs(putOnPlayer) do
			item.Parent = primaryPart
		end
		fireBeamProp.PutOnPlayer:Destroy()
		
		task.delay(0.1, function()
			repeat
				coords = getDataFromClient(_contestant.player);
				task.wait(0.2)
			until fireBreathCharge:GetAttribute("Charge") <= 0
		end)

		local fireWallProps = {}
		fireBeamProp.Target.Position = coords

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
				rate = fireWallProps[#fireWallProps - 1].Size.Z 
			end
			local distance = (fireBeamProp.Particles.Atch.WorldPosition - fireBeamProp.Target.Position).Magnitude * 4
			local tween1 = TweenService:Create(fireBeamProp.Target, TweenInfo.new(0.2, Enum.EasingStyle.Linear), {Position = coords})
			tween1:Play()
			
			fireBeamProp.Particles.Fire.Speed = NumberRange.new(distance,distance)
			coroutine.wrap(animateSprite.animateSprite)(data, fireBreathCharge:GetAttribute("Charge")/100)
			fireBreathCharge:SetAttribute("Charge", fireBreathCharge:GetAttribute("Charge") - rate)
			task.wait(0.2) 
		until fireBreathCharge:GetAttribute("Charge") <= 0
		
		fireBreathCharge:SetAttribute("Charge", 0)
		fireBeamProp.Particles:Destroy()
		fireBeamProp.Root:Destroy()
		fireBeamProp.Target.FireAfter:Destroy()


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
			fireBeamProp.Target.FireAfter.Rate = 0
			for i, item in ipairs(fireWallProps) do
				item.FireAfter.Rate = 0
			end
			task.wait(2)
			fireBeamProp:Destroy()
		end)
	end
	coroutine.wrap(animateSprite.animateSprite)(data, 0)
	task.delay(1, function()
	primaryPart.ChargeMeter:Destroy()
	end)
	print("FireBreathEnded")
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
	local buttonDown
	local shouldRepeat: boolean;

	local function activate(self: ServerAction)

		if not _contestant.character:FindFirstChild("ButtonDown") then
			buttonDown = Instance.new("BoolValue", _contestant.character)
			buttonDown.Name = "ButtonDown"
		end
		if _contestant and _contestant.character then
			if not buttonDown.Value then
				buttonDown.Value = true
			else
				buttonDown.Value = false
			end

			local primaryPart = _contestant.character.PrimaryPart :: BasePart;
			if not primaryPart:FindFirstChild("FlightConstraint") then
				if buttonDown.Value then
					if debounce then
						shouldRepeat = true
					else
						repeat
							shouldRepeat = false;
							if not debounce then

								if _contestant.currentStamina >= 5 then

									debounce = true;

									-- Reduce the player's stamina.
									_contestant:updateStamina(math.max(0, _contestant.currentStamina - 5));
									if combo == 2 then
										task.delay(1.05, function()
											debounce = false;
										end);
									else
										task.delay(0.75, function()
											debounce = false;
										end);
									end

									startAttack(primaryPart, anims, combo, _round, _contestant, buttonDown)
									combo += 1

									local storedCombo = combo
									if combo == 3 then 
										combo = 0 
										task.wait(0.3)
									else
										task.delay(2, function()

											if combo == storedCombo then

												combo = 0

											end

										end);

									end
									task.wait(0.75)
								end

							end


						until not shouldRepeat;
					end
				end
			else
				if buttonDown.Value then
					flyingAttackCharge(primaryPart, anims)
				else

					flyingAttackFire(primaryPart, anims, combo, _round, _contestant)
				end
			end
		end
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