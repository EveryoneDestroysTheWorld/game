--!strict
-- Programmer: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local UserInputService = game:GetService("UserInputService");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");
local RunService = game:GetService("RunService");

local HUDService = require(ReplicatedStorage.Client.Modules.HUDService);
local targetingFramework = require(ReplicatedStorage.Client.Modules.EasyTargetingFramework);
local SharedTypes = require(ReplicatedStorage.Client.Modules.SharedTypes);

local TarBombClientAction = {
	id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
	iconImage = "rbxassetid://17771917538";
	name = "Tar Bomb";
	description = "Launch a projectile at the target location which explodes after a small amount of time, spreading tar onto nearby targets. Tar covered targets are slowed and take flat additional damage from all sources.";
};

function TarBombClientAction.new(): SharedTypes.TarBombClientAction

	local player = Players.LocalPlayer;
	local remoteName = `{player.UserId}_{TarBombClientAction.id}`
	local remoteEvent = ReplicatedStorage.Shared.Events.ActionEvents:WaitForChild(remoteName);
	local action: SharedTypes.TarBombClientAction = {
		id = TarBombClientAction.id;
		iconImage = TarBombClientAction.iconImage;
		name = TarBombClientAction.name;
		description = TarBombClientAction.description;
		remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName);
		remoteEvent = remoteEvent;
		attributes = {
			isCharging = false;
		};
		activate = function(self: SharedTypes.TarBombClientAction)

			local shouldCharge = self.attributes.isCharging;
			self.remoteFunction:InvokeServer(shouldCharge, Players.LocalPlayer:GetMouse().Hit.Position);

		end;
		breakdown = function(self: SharedTypes.TarBombClientAction)

			ContextActionService:UnbindAction("ActivateTarBomb");
			HUDService:removeHUDButton("Action", self.id);
		
		end
	}

	HUDService:addHUDButton({
		type = "Action";
		key = action.id;
		onActivate = function()

			action:activate();

		end;
		shortcutCharacter = "1";
		iconImage = "rbxassetid://73246050129377";
	});

	local ignoreInput = false;

	remoteEvent.OnClientEvent:Connect(function(eventType: "CoordinateRequest" | "Exhausted" | "Completed")
	
		if eventType == "CoordinateRequest" then

			action.attributes.updateTask = action.attributes.updateTask or task.spawn(function()

				while RunService.RenderStepped:Wait() do

					local mousePosition = UserInputService:GetMouseLocation();
					local unitRay = workspace.CurrentCamera:ViewportPointToRay(mousePosition.X, mousePosition.Y)
					local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000);
					local position = if raycastResult then raycastResult.Position else unitRay.Direction * 1000;
					remoteEvent:FireServer(position);

				end;
			
			end);

		else

			targetingFramework.displayTarget("Release");
			if action.attributes.updateTask then

				task.cancel(action.attributes.updateTask);
				action.attributes.updateTask = nil;

			end;

			if eventType == "Exhausted" then

				ignoreInput = true;

			end;

		end;

	end);

	local function checkJump(_, inputState: Enum.UserInputState)

		if inputState == Enum.UserInputState.Begin then
			
			targetingFramework.displayTarget("Start");
			action.attributes.isCharging = true;
			action:activate();

		elseif inputState == Enum.UserInputState.End then

			if ignoreInput then

				ignoreInput = false;

			else

				targetingFramework.displayTarget("Release")
				action:activate();

			end;

		end

	end;

	ContextActionService:BindActionAtPriority("ActivateTarBomb", checkJump, false, 2, Enum.KeyCode.One);

	-- TODO: This needs to be handled on the server.
	workspace.Terrain.ChildAdded:Connect(function(child)

		if child.Name == "TarBomb" then

			task.wait(0.2)
			child.Touched:Once(function(touched)

				child.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

			end)
		end
	
	end)

	return action;

end

return TarBombClientAction;