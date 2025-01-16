--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ContextActionService = game:GetService("ContextActionService");

local React = require(ReplicatedStorage.Shared.Packages.react);
local Fonts = require(ReplicatedStorage.Client.Fonts);

export type OptionButtonProperties = {
  onActivated: () -> ();
  isDisabled: boolean;
  text: string;
  keyboardText: string;
  keyCodes: {Enum.KeyCode};
}

local function OptionButton(properties: OptionButtonProperties)

  local function activate()

    if not properties.isDisabled then

      properties.onActivated();

    end;

  end;

  React.useEffect(function()

    local function checkKeybind(_, inputState: Enum.UserInputState)

      if inputState == Enum.UserInputState.Begin then

        activate();

      end;

    end;
  
    local actionName = `ActivateOptionButton-{properties.keyboardText}`;
    ContextActionService:BindAction(actionName, checkKeybind, false, table.unpack(properties.keyCodes));

    return function()

      ContextActionService:UnbindAction(actionName)

    end;

  end, {properties.keyCodes});

  return React.createElement("TextButton", {
    BackgroundTransparency = 1;
    AutomaticSize = Enum.AutomaticSize.XY;
    BorderSizePixel = 0;
    Text = "";
    [React.Event.Activated] = function()

      activate();

    end;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      FillDirection = Enum.FillDirection.Horizontal;
      Padding = UDim.new(0, 5);
      VerticalAlignment = Enum.VerticalAlignment.Center;
    });
    KeyboardTextLabel = React.createElement("TextLabel", {
      AutomaticSize = Enum.AutomaticSize.XY;
      Text = properties.keyboardText:upper();
      TextSize = 14;
      LayoutOrder = 1;
      TextColor3 = Color3.new(1, 1, 1);
      FontFace = Fonts.Regular;
      BackgroundColor3 = Color3.new();
      BackgroundTransparency = 0.6;
    }, {
      UICorner = React.createElement("UICorner", {
        CornerRadius = UDim.new(0, 5);
      });
      UIPadding = React.createElement("UIPadding", {
        PaddingLeft = UDim.new(0, 5);
        PaddingTop = UDim.new(0, 5);
        PaddingBottom = UDim.new(0, 5);
        PaddingRight = UDim.new(0, 5);
      });
    });
    TextLabel = React.createElement("TextLabel", {
      AutomaticSize = Enum.AutomaticSize.XY;
      Text = properties.text:upper();
      TextSize = 14;
      LayoutOrder = 2;
      BackgroundTransparency = 1;
      TextColor3 = Color3.new(1, 1, 1);
      FontFace = Fonts.Regular;
    });
  });

end;

return OptionButton;