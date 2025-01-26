--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local SelectionListContainer = require(script.SelectionListContainer);
local ControlGuide = require(script.ControlGuide);
local React = require(ReplicatedStorage.Shared.Packages.react);
local Fonts = require(ReplicatedStorage.Client.Fonts);

export type QuickSelectMenuOption = {
  key: unknown;
  labelText: string;
  iconImage: string;
  onConfirmed: () -> ();
}

export type QuickSelectionMenuProperties = {
  options: {QuickSelectMenuOption};
  selectionKey: unknown?;
  onSelectionConfirmed: (selection: QuickSelectMenuOption) -> ();
}

local function QuickSelectionMenu(properties: QuickSelectionMenuProperties)

  local selectedOption: QuickSelectMenuOption?, setSelectedOption = React.useState(nil :: QuickSelectMenuOption?);

  return React.createElement("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5);
    AutomaticSize = Enum.AutomaticSize.Y;
    BackgroundTransparency = 1;
    Position = UDim2.new(0.5, 0, 0.5, 0);
    Size = UDim2.new(0.5, 0, 0, 0);
  }, {
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
    SelectionListContainer = React.createElement(SelectionListContainer, {
      selectedOption = selectedOption;
      onSelectionChanged = setSelectedOption;
      onSelectionConfirmed = properties.onSelectionConfirmed;
    });
    ControlGuide = React.createElement(ControlGuide, {
      options = properties.options;
      selectionKey = properties.selectionKey;
      onSelectionChanged = setSelectedOption;
      onSelectionConfirmed = properties.onSelectionConfirmed;
    });
  });

end;

return QuickSelectionMenu;