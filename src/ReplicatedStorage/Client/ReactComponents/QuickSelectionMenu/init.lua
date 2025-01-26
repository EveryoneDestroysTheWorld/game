--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local SelectionList = require(script.SelectionList);
local ControlGuide = require(script.ControlGuide);
local SelectionIndicator = require(script.SelectionIndicator);
local types = require(script.types);
local React = require(ReplicatedStorage.Shared.Packages.react);
local Fonts = require(ReplicatedStorage.Client.Fonts);

local function QuickSelectionMenu(properties: types.QuickSelectionMenuProperties)

  local selectedOption: types.QuickSelectMenuOption?, setSelectedOption = React.useState(nil :: types.QuickSelectMenuOption?);

  return React.createElement("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5);
    AutomaticSize = Enum.AutomaticSize.Y;
    BackgroundTransparency = 1;
    Position = UDim2.new(0.5, 0, 0.5, 0);
    Size = UDim2.new(0.5, 0, 0, 0);
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      Padding = UDim.new(0, 10);
      SortOrder = Enum.SortOrder.LayoutOrder;
    });
    SelectionNameTextLabel = if selectedOption then
      React.createElement("TextLabel", {
        LayoutOrder = 1;
        FontFace = Fonts.Bold;
        TextColor3 = Color3.new(1, 1, 1);
        BackgroundTransparency = 1;
        TextSize = 14;
        Text = selectedOption.labelText;
      })
    else nil;
    SelectionIndicator = React.createElement(SelectionIndicator, {
      selectedOption = selectedOption;
      options = properties.options;
      onSelectionChanged = setSelectedOption;
    });
    SelectionListContainer = React.createElement(SelectionList, {
      selectedOption = selectedOption;
      options = properties.options;
      onSelectionChanged = setSelectedOption;
      onSelectionConfirmed = properties.onSelectionConfirmed;
    });
    ControlGuide = React.createElement(ControlGuide, {
      options = properties.options;
      selectedOption = selectedOption;
      onSelectionChanged = setSelectedOption;
      onSelectionConfirmed = properties.onSelectionConfirmed;
    });
  });

end;

return QuickSelectionMenu;