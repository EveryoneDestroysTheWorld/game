--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);

local function OptionsContainer()

  return React.createElement("Frame", {
    BackgroundTransparency = 0.6;
    BackgroundColor3 = Color3.new();
    Size = UDim2.new(1, 0, 1, 0);
    BorderSizePixel = 0;
  }, {
    UIListLayout = React.createElement("UIListLayout");
    UIPadding = React.createElement("UIPadding");
    
    OptionsContainer = React.createElement(OptionsContainer);
  });

end;

return OptionsContainer;