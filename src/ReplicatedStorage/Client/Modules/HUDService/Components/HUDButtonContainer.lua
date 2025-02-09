--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local React = require(ReplicatedStorage.Shared.Packages.react);
local HUDButton = require(script.Parent.HUDButton);
local HUDServiceTypes = require(script.Parent.Parent.types);

export type HUDButtonContainerProperties = {
  type: "Action" | "Item";
  buttonPropertiesList: {HUDServiceTypes.HUDButtonProperties};
}

local function HUDButtonContainer(properties: HUDButtonContainerProperties)

  local isActionList = properties.type == "Action";
  local buttons = {};

  for _, propertyList in properties.buttonPropertiesList do

    table.insert(buttons, React.createElement(HUDButton, propertyList));

  end;

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
      SortOrder = Enum.SortOrder.LayoutOrder;
    });
    HUDButtonList = React.createElement(React.Fragment, {}, buttons);
  });

end;

return HUDButtonContainer;