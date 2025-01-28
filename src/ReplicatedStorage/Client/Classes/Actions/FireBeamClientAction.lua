--!strict
-- Programmer: Hati (hati_bati)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");
local ClientAction = require(script.Parent.Parent.ClientAction);
local React = require(ReplicatedStorage.Shared.Packages.react);
local HUDButton = require(ReplicatedStorage.Client.ReactComponents.HUDButton);

type ClientAction = ClientAction.ClientAction;

local FireBeamAction = {
	id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
	iconImage = "rbxassetid://17771917538";
	name = "Fire Beam";
	description = "Charge by holding down while flying, and release to fire a beam that lights the ground on fire.";
};

function FireBeamAction.new(): ClientAction

	local player = Players.LocalPlayer;
	local remoteName: string;
	local _remoteEvent: RemoteEvent;
	local updateTask: thread?;

	local function breakdown(self: ClientAction)

		ContextActionService:UnbindAction("ActivateFireBeam");
		ReplicatedStorage.Client.Functions.DestroyHUDButton:Invoke("Action", self.id);

	end;
	
	local function activate(self: ClientAction)

		ReplicatedStorage.Shared.Functions.ActionFunctions:FindFirstChild(remoteName):InvokeServer();

	end;

	local function initialize(self: ClientAction)

		local remoteEvent = ReplicatedStorage.Shared.Events.ActionEvents:WaitForChild(remoteName);
		assert(remoteEvent:IsA("RemoteEvent"));

		remoteEvent.OnClientEvent:Connect(function(shouldActivateUpdateTask)
	
			if shouldActivateUpdateTask then

				updateTask = updateTask or task.spawn(function()

					while task.wait() do

						remoteEvent:FireServer(Players.LocalPlayer:GetMouse().Hit.Position); -- TODO: Fix for mobile and gamepad devices.

					end;
				
				end);

			else

				if updateTask then

					task.cancel(updateTask);
					updateTask = nil;
					
				end;

			end;

		end);

		_remoteEvent = remoteEvent;

		ReplicatedStorage.Client.Functions.AddHUDButton:Invoke("Action", React.createElement(HUDButton, {
			type = "Action";
      key = self.id;
			onActivate = function()

				self:activate("Input");

			end;
			shortcutCharacter = "1";
			iconImage = "rbxassetid://17771917538";
		}));

		remoteName = `{player.UserId}_{self.id}`;

	--	ContextActionService:BindActionAtPriority("ActivateFireBeam", checkJump, false, 2, Enum.UserInputType.MouseButton1);

	end;

	return ClientAction.new({
		id = FireBeamAction.id;
		iconImage = FireBeamAction.iconImage;
		name = FireBeamAction.name;
		description = FireBeamAction.description;
		activate = activate;
		breakdown = breakdown;
		initialize = initialize;
	});

end

return FireBeamAction;