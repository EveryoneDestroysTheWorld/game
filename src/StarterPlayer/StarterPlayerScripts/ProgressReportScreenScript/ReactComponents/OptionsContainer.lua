--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local OptionButton = require(script.Parent.OptionButton);
local React = require(ReplicatedStorage.Shared.Packages.react);

local function OptionsContainer()

  local isReturnButtonEnabled, setIsReturnButtonEnabled = React.useState(true);

  return React.createElement("Frame", {
    BackgroundTransparency = 1;
    Size = UDim2.new(1, 0, 0, 0);
    LayoutOrder = 2;
    BorderSizePixel = 0;
    AutomaticSize = Enum.AutomaticSize.Y;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      HorizontalAlignment = Enum.HorizontalAlignment.Right;
      FillDirection = Enum.FillDirection.Horizontal;
      Padding = UDim.new(0, 15);
      VerticalAlignment = Enum.VerticalAlignment.Bottom;
    });
    ReturnToOriginalPlaceButton = React.createElement(OptionButton, {
      text = "Return to Arena";
      isDisabled = not isReturnButtonEnabled;
      keyboardText = "Return";
      keyCodes = {Enum.KeyCode.Return, Enum.KeyCode.KeypadEnter};
      onActivated = function()

        setIsReturnButtonEnabled(false);
        ReplicatedStorage.Shared.Functions.TeleportToArena:InvokeServer();

      end;
    });
  });

end;

return OptionsContainer;