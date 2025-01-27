--!strict
-- Programmer: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local TweenService = game:GetService("TweenService");

local FireBeamClientAction = require(ReplicatedStorage.Client.Classes.Actions.FireBeamClientAction);
local types = require(ServerStorage.Classes.types);

local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);

local FireBeamServerAction = {
	id = FireBeamClientAction.id;
	name = FireBeamClientAction.name;
	description = FireBeamClientAction.description;
	__index = {} :: types.FireBeamServerAction;
};

function FireBeamServerAction.new(properties: types.ServerActionConstructorProperties): types.FireBeamServerAction

	local overwrittenProperties = {
		name = FireBeamServerAction.name;
		id = FireBeamServerAction.id;
		description = FireBeamServerAction.description;
		contestant = properties.contestant;
	};
	
  local action = (setmetatable(overwrittenProperties, FireBeamServerAction) :: any) :: types.FireBeamServerAction;

	assert(action.contestant.character);
	if action.contestant.player then

		action.remoteFunction = createInventoryRemoteFunction(action.contestant.player, "Action", `{action.contestant.player.UserId}_{action.id}`, function()
    
      action:activate();

    end);

	end

	return action;

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

local function flyingAttackCharge(primaryPart, anims)
	local fireBreathChargeGUI = displayObjects.DraconicKnight:FindFirstChild("ChargeMeter"):Clone()
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

local function setOnFire(model, round, contestant)
	local fireDebuffProp = model:FindFirstChild("FireDebuffProp")
	if fireDebuffProp then 
		fireDebuffProp:SetAttribute("Duration", 6)
	elseif model:FindFirstChild("HumanoidRootPart") then
		fireDebuffProp = displayObjects.DraconicKnight:FindFirstChild("FireDebuffProp"):Clone()
		fireDebuffProp.Parent = model
		fireDebuffProp.RigidConstraint.Attachment1 = model.HumanoidRootPart:FindFirstChild("RootAttachment") or nil
		fireDebuffProp:SetAttribute("Duration", 6)
		fireDebuffProp.Highlight.Adornee = model

		task.delay(1/30, function()
			repeat
				task.wait(1)
				fireDebuffProp:SetAttribute("Duration", fireDebuffProp:GetAttribute("Duration") - 1)
				--print(round.contestants)
				--print(model.Name)
				for i, contestant in ipairs(round.contestants) do
					if contestant["name"] == model.Name then
						--print(contestant)
						contestant:updateHealth(contestant.currentHealth - 4, {
							contestant = contestant;
							actionID = MeleeServerAction.ID;
						});
					end
				end
			until fireDebuffProp:GetAttribute("Duration") == 0
			fireDebuffProp:Destroy()
		end)
	else
	--	print("Object is not a humanoid")
	end
end

local function flyingAttackFire(primaryPart, anims, combo, round, contestant)
	local coords, eventCon = getDataFromClient(contestant.player);
	local fireBreathCharge = primaryPart.Parent:FindFirstChild("ButtonDown")

	local animateSprite = require(displayObjects.SpriteAnimator)
	local data = {
		FrameRate = 128,
		Sprite = primaryPart.ChargeMeter.Sprite,
		SpriteSheet = "8x8"
	}

	if fireBreathCharge:GetAttribute("Charge") >= 15 then
		local fireBeamProp = displayObjects.DraconicKnight:FindFirstChild("FireBeamProp"):Clone()
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
				coords = getDataFromClient(contestant.player);
				task.wait(0.2)
			until fireBreathCharge:GetAttribute("Charge") <= 0
		end)

		local fireWallProps = {}
		fireBeamProp.Target.Position = coords
		fireBeamProp.Target.CanTouch = true
		fireBeamProp.Target.Size = Vector3.new(4,4,4)
		local damageConnect = {}
		local connectDebounce = {}
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
					setOnFire(model, round, contestant)
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
							setOnFire(model, round, contestant)
						end
					end
				end)


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
	coroutine.wrap(animateSprite.animateSprite)(data, 0)
	task.delay(1, function()
		primaryPart.ChargeMeter:Destroy()
	end)
  
	--print("FireBreathEnded")

end

function FireBeamServerAction.__index:activate(coordinates: Vector3)

	if buttonDown.Value then

		flyingAttackCharge(primaryPart, anims);

	else

		flyingAttackFire(primaryPart, anims, combo, round, contestant);

	end

end

function FireBeamServerAction.__index:breakdown()

	if self.remoteFunction then

		self.remoteFunction:Destroy();

	end

end

return FireBeamServerAction;