--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local types = require(script.Parent.types);
local React = require(ReplicatedStorage.Shared.Packages.react);

local function SelectionList(properties: types.SelectionListProperties)

  local buttonComponents = {};
  local selectionIndex = 1;

  for index, option in properties.options do

    if properties.selectedOption and option.key == properties.selectedOption.key then

      selectionIndex = index;

    end;

    table.insert(buttonComponents, React.createElement("TextButton", {
      key = option.key;
      BackgroundColor3 = Color3.fromRGB(17, 20, 42);
      BackgroundTransparency = 0.6;
      BorderSizePixel = 0;
      Size = UDim2.new(1, 0, 1, 0);
      LayoutOrder = index;
      SizeConstraint = Enum.SizeConstraint.RelativeYY;
      Text = "";
      [React.Event.Activated] = function()

        properties.onSelectionConfirmed(option);

      end;
    }, {
      ImageLabel = React.createElement("ImageLabel", {
        Image = option.iconImage;
        Size = UDim2.new(1, 0, 1, 0);
        BackgroundTransparency = 1;
      });
    }))

  end;

  local ySizeOffset = 50;
  local xPadding = 15;

  return React.createElement("CanvasGroup", {
    AutomaticSize = Enum.AutomaticSize.X;
    BackgroundTransparency = 1;
    LayoutOrder = 3;
    Position = UDim2.new(0.5, 0, 0.5, 0);
    Size = UDim2.new(0.5, 0, 0, ySizeOffset);
  }, {
    UIGradient = React.createElement("UIGradient", {
      Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1);
        NumberSequenceKeypoint.new(0.05, 0.75);
        NumberSequenceKeypoint.new(0.051, 0); -- Roblox currently doesn't support holding the line between points. Consider fixing this in the future if they change it.
        NumberSequenceKeypoint.new(0.0949, 0); -- See above.
        NumberSequenceKeypoint.new(0.95, 0.75);
        NumberSequenceKeypoint.new(1, 1);
      })
    });
    ScrollingFrame = React.createElement("ScrollingFrame", {
      BackgroundTransparency = 1;
      Size = UDim2.new(1, 0, 1, 0);
      CanvasSize = UDim2.new(1, ySizeOffset * (#properties.options - 1) + xPadding * (#properties.options - 1), 0, 0);
      CanvasPosition = Vector2.new(ySizeOffset * (selectionIndex - 1) + xPadding * (selectionIndex - 1), 0);
      ScrollingDirection = Enum.ScrollingDirection.X;
      ScrollBarThickness = 0; -- ControlGuide should make up for accessibility. The scrollbar doesn't look right on the UI.
    }, {
      UIListLayout = React.createElement("UIListLayout", {
        Padding = UDim.new(0, xPadding);
        FillDirection = Enum.FillDirection.Horizontal;
        SortOrder = Enum.SortOrder.LayoutOrder;
        HorizontalAlignment = Enum.HorizontalAlignment.Center;
        VerticalAlignment = Enum.VerticalAlignment.Center;
      });
      ButtonComponents = React.createElement(React.Fragment, {}, buttonComponents);
    })
  });

end;

return SelectionList;