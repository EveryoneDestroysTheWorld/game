--!strict
local ContextActionService = game:GetService("ContextActionService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
local ArchetypeSelectorScreen = require(script.ReactComponents.ArchetypeSelectorScreen);
local Players = game:GetService("Players");

local round = ClientRound.fromServerRound();

local function setupGUI()

  local gui: ScreenGui? = nil;
  local root;

  local function toggleMenu(shouldEnable: boolean)

    if shouldEnable and not gui then

      local newGUI = Instance.new("ScreenGui");
      gui = newGUI;
      newGUI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui");
      newGUI.Name = "ArchetypeSelectorGUI";
      newGUI.DisplayOrder = 1;
      newGUI.ScreenInsets = Enum.ScreenInsets.None;
      root = ReactRoblox.createRoot(newGUI);

    end;

    if root then

      root:render(React.createElement(ArchetypeSelectorScreen, {
        round = round;
        shouldOpen = shouldEnable;
        onClose = function()

          if gui then

            gui:Destroy();
            gui = nil;

          end;

        end;
      }));

    end;

  end;
  
  local function checkKeybind(actionName, inputState: Enum.UserInputState)
  
    if inputState == Enum.UserInputState.Begin then
  
      toggleMenu(not gui);
  
    end;
  
  end;
  
  ContextActionService:BindAction("ToggleArchetypeMenu", checkKeybind, false, Enum.KeyCode.H);
  script.ToggleSelector.OnInvoke = function()

    toggleMenu(not gui);

  end;

  round.onEnded:Once(function()

    script.ToggleSelector.OnInvoke = nil;
    ContextActionService:UnbindAction("ToggleArchetypeMenu");

  end);

end;

-- Ensure that the round is active.
if round.status == "Active" then

  setupGUI();

else

  round.onStarted:Once(setupGUI);

end;