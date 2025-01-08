
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local Button = require(ReplicatedStorage.Client.ReactComponents.Button);

export type ArchetypeSelectorProperties = {

}

local function ArchetypeSelector(properties: ArchetypeSelectorProperties)

  return React.createElement("Frame", {
    LayoutOrder = 2;
    AutomaticSize = Enum.AutomaticSize.XY;
    BackgroundTransparency = 1;
  }, {
    ArchetypeCategorySelector = React.createElement(Button, {
      LayoutOrder = 1;
      Text = "FAVORITES";
    });
  });

end;

return ArchetypeSelector;