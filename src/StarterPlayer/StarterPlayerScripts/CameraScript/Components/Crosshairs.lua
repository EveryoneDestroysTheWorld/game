--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);

local function Crosshairs()

  return React.createElement("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5);
    BackgroundTransparency = 1;
    Position = UDim2.new(0.5, 0, 0.5, 0);
    Size = UDim2.new(0, 20, 0, 20);
  }, {
    UICorner = React.createElement("UICorner", {
      CornerRadius = UDim.new(1, 0);
    });
    UIStroke = React.createElement("UIStroke", {
      Transparency = 0.8;
      Color = Color3.new(1, 1, 1);
    });
  });

end;

return Crosshairs;