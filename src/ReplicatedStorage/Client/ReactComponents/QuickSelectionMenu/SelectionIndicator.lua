--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local types = require(script.Parent.types);
local React = require(ReplicatedStorage.Shared.Packages.react);

local function SelectionIndicator(properties: types.ControlGuideProperties)

  local buttonComponents = {};

  for index, option in properties.options do

    local isSelectedOption = properties.selectedOption and properties.selectedOption.key == option.key;

    table.insert(buttonComponents, React.createElement("TextButton", {
      key = option.key;
      Text = "";
      Size = UDim2.new(0, if isSelectedOption then 6 else 5, 0, if isSelectedOption then 6 else 5);
      BackgroundColor3 = if isSelectedOption then Color3.new(1, 1, 1) else Color3.new(0, 0, 0);
      BackgroundTransparency = if isSelectedOption then 0 else 0.6;
      BorderSizePixel = 0;
      LayoutOrder = index;
      [React.Event.Activated] = function()

        properties.onSelectionChanged(option);

      end;
    }, {
      UICorner = React.createElement("UICorner", {
        CornerRadius = UDim.new(1, 0);
      });
    }));

  end;

  return React.createElement("Frame", {
    AutomaticSize = Enum.AutomaticSize.XY;
    BackgroundTransparency = 1;
    LayoutOrder = 2;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      Padding = UDim.new(0, 5);
      FillDirection = Enum.FillDirection.Horizontal;
      SortOrder = Enum.SortOrder.LayoutOrder;
      HorizontalAlignment = Enum.HorizontalAlignment.Center;
      VerticalAlignment = Enum.VerticalAlignment.Center;
    });
    ButtonComponents = React.createElement(React.Fragment, {}, buttonComponents);
  });

end;

return SelectionIndicator;