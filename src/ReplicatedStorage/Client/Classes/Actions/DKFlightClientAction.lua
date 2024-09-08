--!strict
-- Writer: Hati ---- Heavily modified edit of ExplosivePunch
-- Designer: Christian Toney (Sudobeast)
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");
local ClientAction = require(script.Parent.Parent.ClientAction);
local React = require(ReplicatedStorage.Shared.Packages.react);
local ActionButton = require(script.Parent.Parent.Parent.ReactComponents.ActionButton);
type ClientAction = ClientAction.ClientAction;

local TakeFlightAction = {
  ID = 6;
  iconImage = "rbxassetid://17771917538";
  name = "Take Flight";
  description = "You are great at flying! I'm suprised those wings can carry you.";
};

function TakeFlightAction.new(): ClientAction

  local player = Players.LocalPlayer;
  local remoteName: string;

  local function breakdown(self: ClientAction)

    ContextActionService:UnbindAction("ActivateTakeFlight");

  end;

  local function activate(self: ClientAction)

    ReplicatedStorage.Shared.Functions.ActionFunctions:FindFirstChild(remoteName):InvokeServer();

  end;

  local action = ClientAction.new({
    ID = TakeFlightAction.ID;
    iconImage = TakeFlightAction.iconImage;
    name = TakeFlightAction.name;
    description = TakeFlightAction.description;
    activate = activate;
    breakdown = breakdown;
  });
local allowedToToggle = true
  ReplicatedStorage.Client.Functions.AddActionButton:Invoke(React.createElement(ActionButton, {
    onActivate = function()
      action:activate();
      allowedToToggle = false
task.wait(1)
allowedToToggle = true

    end;
    shortcutCharacter = "L";
    iconImage = "rbxassetid://17771917538";
  }));
  
  remoteName = `{player.UserId}_{action.ID}`;
local debounce = false
  local function checkJump(_, inputState: Enum.UserInputState)
		if inputState == Enum.UserInputState.Begin and allowedToToggle == true then
			if debounce == false then
				debounce = true
        task.wait(0.4)
        if debounce == true and Players.LocalPlayer.Character.Humanoid.Jump == true  then
          debounce = false
				action:activate();
        end
			else
        debounce = false
				action:activate();
			end


		end;

	end;

  ContextActionService:BindActionAtPriority("ActivateTakeFlight", checkJump, false, 2, Enum.KeyCode.Space);

  return action;

end

return TakeFlightAction;
