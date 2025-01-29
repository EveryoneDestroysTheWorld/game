--!strict
-- Programmers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local Players = game:GetService("Players");

local player = Players.LocalPlayer;

function searchForLockOnTarget(character: Model, previousTargets: {Instance}): Model?
	
	local target

	local Oparams = OverlapParams.new()
	local validTargets = {}
	Oparams.FilterType = Enum.RaycastFilterType.Include
	for i, item in ipairs(workspace:GetChildren()) do
		if item:IsA("Model") and item:FindFirstChild("Humanoid") and item.Name ~= Players.LocalPlayer.Name then
			table.insert(validTargets,item.HumanoidRootPart)
		end
	end

  -- Use the character's head if this function is being used by a bot.
  local head = character:FindFirstChild("Head");
  assert(player or (head and head:IsA("BasePart")));
  local cameraCFrame = if player then workspace.CurrentCamera.CFrame else CFrame.new(head.Position, head.Rotation);

	Oparams.FilterDescendantsInstances = validTargets
	local possibleTargets = workspace:GetPartBoundsInRadius(Players.LocalPlayer.Character.HumanoidRootPart.Position, 100, Oparams)
	if #possibleTargets > 0 then
		if #possibleTargets > 1 then

			local RParams = RaycastParams.new()
			RParams.FilterType = Enum.RaycastFilterType.Include
			local exclude = possibleTargets
			local raycastResult
			local size = 20
			repeat 
				local rayorgin
				if size < 20 then
					rayorgin = cameraCFrame.Rotation + (Vector3.new(0, 4, 0) + Players.LocalPlayer.Character.HumanoidRootPart.Position)
					size += 20
				else
					size += 20
					rayorgin = cameraCFrame;
				end

				local rayDirection = (rayorgin * CFrame.new(Vector3.new(0, 20, -size))).Position
				rayDirection -= rayorgin.Position
				RParams.FilterDescendantsInstances = exclude
				raycastResult = workspace:Blockcast(rayorgin, Vector3.new(size,size,size), rayDirection, RParams)


				if raycastResult then
					if table.find(previousTargets, raycastResult.Instance) then
						--print(raycastResult.Instance.Parent.Name .. " was targeted previously, searching for new target")
						local i = 0
						repeat
							i+= 1
							if raycastResult then
								table.remove(exclude, table.find(exclude, raycastResult.Instance))

								if i >= #possibleTargets then
									--print("All possible targets were targeted previously, resetting previous targets")
									previousTargets = {}
									exclude = possibleTargets
								end
								RParams.FilterDescendantsInstances = exclude
								raycastResult = workspace:Blockcast(rayorgin, Vector3.new(size,size,size), rayDirection, RParams)
							end
							task.wait()
						until raycastResult and not table.find(previousTargets, raycastResult.Instance) or i > #possibleTargets * 2
					end

				end
				if not raycastResult then
					task.wait()
				end

			until raycastResult or size > 200
			if raycastResult then
			target = raycastResult.Instance:FindFirstAncestorOfClass("Model")
			end
		else
			target = possibleTargets[1]:FindFirstAncestorOfClass("Model")
		end
		if target then
		table.insert(previousTargets, target.HumanoidRootPart)
		end
	else
		--warn("no valid targets")
	end

	return target

end

return searchForLockOnTarget;