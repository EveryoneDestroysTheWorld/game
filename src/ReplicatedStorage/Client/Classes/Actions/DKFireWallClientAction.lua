--!strict
-- Programmer: Hati (hati_bati)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");
local ClientAction = require(script.Parent.Parent.ClientAction);
local React = require(ReplicatedStorage.Shared.Packages.react);
local HUDButton = require(ReplicatedStorage.Client.ReactComponents.HUDButton);

type ClientAction = ClientAction.ClientAction;

local FireBeamAction = {
	ID = 10;
	iconImage = "rbxassetid://17771917538";
	name = "Fire Beam";
	description = "Charge by holding down while flying, and release to fire a beam that lights the ground on fire.";
};

local function waitForServerResponse()
	local connection: RBXScriptConnection;

	connection = Players.LocalPlayer.ChildAdded:Connect(function(child: Instance)

		if child:IsA("RemoteEvent") and child.Name == "FireBreathCoords" then

			--set up data requests recieved from server
			connection:Disconnect()
			connection = child.OnClientEvent:Connect(function()
				child:FireServer(Players.LocalPlayer:GetMouse().Hit.Position)
			end)
			--sent data back to server

		end

	end)
	
	return connection

end

function FireBeamAction.new(): ClientAction

	local player = Players.LocalPlayer;
	local remoteName: string;

	local function breakdown(self: ClientAction)

		ContextActionService:UnbindAction("ActivateFireBeam");
		ReplicatedStorage.Client.Functions.DestroyHUDButton:Invoke("Action", self.ID);

	end;
	local connection
	local function activate(self: ClientAction)
		ReplicatedStorage.Shared.Functions.ActionFunctions:FindFirstChild(remoteName):InvokeServer();
	end;

	local function initialize(self: ClientAction)

		local allowedToToggle = true
		ReplicatedStorage.Client.Functions.AddHUDButton:Invoke("Action", React.createElement(HUDButton, {
			type = "Action";
			onActivate = function()

				self:activate("Input");

			end;
			shortcutCharacter = "1";
			iconImage = "rbxassetid://17771917538";
		}));

		remoteName = `{player.UserId}_{self.ID}`;
		local debounce = false
		local function checkJump(_, inputState: Enum.UserInputState)
			if inputState == Enum.UserInputState.Begin then
			elseif inputState == Enum.UserInputState.End then
			end
		end;

		ContextActionService:BindActionAtPriority("ActivateFireBeam", checkJump, false, 2, Enum.UserInputType.MouseButton2);

	end;

	return ClientAction.new({
		ID = FireBeamAction.ID;
		iconImage = FireBeamAction.iconImage;
		name = FireBeamAction.name;
		description = FireBeamAction.description;
		activate = activate;
		breakdown = breakdown;
		initialize = initialize;
	});

end

return FireBeamAction;