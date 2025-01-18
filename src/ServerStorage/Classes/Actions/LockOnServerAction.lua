--!strict
-- Programmer: Hati (hati_bati)
-- © 2024 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");
local ClientAction = require(ReplicatedStorage.Client.Classes.Actions.LockOnClientAction);
local InsertService = game:GetService("InsertService");
local ServerAction = require(script.Parent.Parent.ServerAction);
type ServerAction = ServerAction.ServerAction;
local React = require(ReplicatedStorage.Shared.Packages.react);
local HUDButton = require(ReplicatedStorage.Client.ReactComponents.HUDButton);

local LockOnAction = {
	ID = ClientAction.ID;
	name = ClientAction.name;
	description = ClientAction.description;
};

local function getDataFromClient(player: Player): Vector3

	local event = Instance.new("RemoteEvent")
	local connect
	connect = event.OnServerEvent:Connect(function(_: Player, data: Instance)
		connect:Disconnect();
		if data then
			event:SetAttribute("Target", data.Name);
			local targetValue = player.Character:FindFirstChild("Target") or Instance.new("ObjectValue", player.Character)
			targetValue.Name = "Target"
			targetValue.Value = data
		else
			event:SetAttribute("Target", "nil");
			local targetValue = player.Character:FindFirstChild("Target") or Instance.new("ObjectValue", player.Character)
			targetValue.Name = "Target"
			targetValue.Value = nil
		end
	end)

	event.Name = "LockOnData"
	event.Parent = player

	--coords request sent to player
	event.AttributeChanged:Wait()

	--coords recieved by player
	return

end


function LockOnAction.new(): ServerAction

	local function activate(self: ServerAction)

	end;

	local executeActionRemoteFunction: RemoteFunction? = nil;

	local function breakdown()

		if executeActionRemoteFunction then

			executeActionRemoteFunction:Destroy();

		end

	end;

	local function initialize(self: ServerAction, newContestant: ServerContestant, newRound: ServerRound)
		contestant = newContestant;
		round = newRound;

		assert(contestant.character);
		local humanoid = contestant.character:FindFirstChild("Humanoid") :: Humanoid;
		if contestant.player then

			local remoteFunction = Instance.new("RemoteFunction");
			remoteFunction.Name = `{contestant.player.UserId}_{self.ID}`;
			remoteFunction.OnServerInvoke = function(player)

				if player == contestant.player then
					local target = getDataFromClient(player)
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
		contestant = contestant;

	end;

	local loadedAsset = InsertService:LoadAsset(121257423066226)
		loadedAsset.TargetingFrame.Parent = ReplicatedStorage.Client.InGameDisplayObjects
		loadedAsset:Destroy()

	return ServerAction.new({
		name = LockOnAction.name;
		ID = LockOnAction.ID;
		description = LockOnAction.description;
		breakdown = breakdown;
		activate = activate;
		initialize = initialize;
	});

end;


return LockOnAction;