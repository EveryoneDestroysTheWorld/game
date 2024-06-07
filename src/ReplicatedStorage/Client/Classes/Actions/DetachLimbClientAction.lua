--!strict
-- Writer: Christian Toney (Sudobeast)
-- Designer: Christian Toney (Sudobeast)
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientAction = require(script.Parent.Parent.ClientAction);
type ClientAction = ClientAction.ClientAction;
local RunService = game:GetService("RunService");

local DetachLimbAction = {
  ID = 2;
  name = "Detach Limb";
  description = "Detach a limb of your choice. It only hurts a little bit.";
};

type LimbSelectionButtonProps = {
  onActivate: () -> ();
  shortcutCharacter: string;
}

local function LimbSelectionButton(props: LimbSelectionButtonProps)

  local function onActivate()

    props.onActivate();

  end;

  return React.createElement("TextButton", {
    [React.Event.Activated] = onActivate;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
    });
    IconContainerFrame = React.createElement("Frame", {
      BackgroundTransparency = 0.9;
      BorderSizePixel = 0;
      LayoutOrder = 1;
      Size = UDim2.new(1, 0, 1, -10);
    }, {
      UIStroke = React.createElement("UIStroke", {});
      IconImageLabel = React.createElement("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5);
        Position = UDim2.new(0.5, 0, 0.5, 0);
        Size = UDim2.new(1, -10, 1, -10);
        BackgroundTransparency = 1;
      });
    });
    ShortcutCharacterLabel = React.createElement("TextLabel", {
      BackgroundTransparency = 1;
      Size = UDim2.new(1, 0, 0, 10);
      LayoutOrder = 2;
      Text = props.shortcutCharacter;
    });
  });

end;

type LimbSelectionWindowProps = {
  onLimbSelect = (limbName: string) -> ();
};

local function LimbSelectionWindow(props: LimbSelectionWindowProps)

  local buttonComponents = {};
  local limbInfo = {
    {name = "Torso"; shortcutCharacter = "1";}
    {name = "Head"; shortcutCharacter = "2";}
  };
  for _, limb in ipairs({}) do

    table.insert(buttonComponents, React.createElement(LimbSelectionButton, {
      onActivate = function()

        props.onLimbSelect(limb.name);

      end;
    }));

  end;

  return React.createElement(React.StrictMode, {}, {
    Container = React.createElement("Frame", {}, {
      React.createElement("UIListLayout", {
        Name = "UIListLayout";
        Padding = UDim.new(0, 15);
        SortOrder = Enum.SortOrder.LayoutOrder;
      });
      buttonComponents;
    });
  });

end;

function DetachLimbAction.new(): ClientAction

  -- Set up the UI.
  local player = Players.LocalPlayer;
  local limbSelectorGUI: ScreenGui = Instance.new("ScreenGui");
  limbSelectorGUI.Name = "LimbSelectorGUI";
  limbSelectorGUI.Parent = player:WaitForChild("PlayerGui");
  limbSelectorGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
  limbSelectorGUI.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets;
  limbSelectorGUI.ResetOnSpawn = false;
  limbSelectorGUI.DisplayOrder = 1;
  limbSelectorGUI.Enabled = true;

  local function breakdown(self: ClientAction)

    limbFindingEvent:Disconnect();
    limbSelectionEvent:Disconnect();

  end;

  local function activate(self: ClientAction)

    if selectedLimb then

      ReplicatedStorage.Shared.Functions:FindFirstChild(`{player.UserId}_{DetachLimbAction.ID}`):InvokeServer();

    end;

  end;

  local action = ClientAction.new({
    ID = DetachLimbAction.ID;
    name = DetachLimbAction.name;
    description = DetachLimbAction.description;
    activate = activate;
    breakdown = breakdown;
  });

  -- Listen for events.
  ContextActionService:BindAction("Select Limb", function() end, false, Enum.KeyCode.J, Enum.KeyCode.K);
  ContextActionService:BindAction("Detach Limb", function() activate(action) end, false, Enum.UserInputType.MouseButton2);

  return action;

end

return DetachLimbAction;
