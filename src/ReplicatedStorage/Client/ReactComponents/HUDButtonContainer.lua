--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);

local function HUDButtonContainer(props)

  local isActionList = props.type == "Action";

  return React.createElement("Frame", {
    AnchorPoint = Vector2.new(if isActionList then 1 else 0, 1);
    Position = UDim2.new(if isActionList then 1 else 0, if isActionList then -15 else 15, 1, -15);
    Size = UDim2.new();
    AutomaticSize = Enum.AutomaticSize.XY;
    BackgroundTransparency = 1;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      Padding = UDim.new(0, 5);
      FillDirection = Enum.FillDirection.Horizontal;
    });
    HUDButtonList = React.createElement(React.Fragment, {}, props.children);
  });

end;

return HUDButtonContainer;