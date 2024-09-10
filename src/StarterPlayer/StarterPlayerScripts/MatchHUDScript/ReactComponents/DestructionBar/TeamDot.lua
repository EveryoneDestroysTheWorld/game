--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local CircleUICorner = require(ReplicatedStorage.Client.ReactComponents.CircleUICorner);
local Colors = require(ReplicatedStorage.Client.Colors);

export type TeamDotProperties = {
  teamNumber: number;
}

local function TeamDot(props: TeamDotProperties)

  return React.createElement("Frame", {
    BackgroundColor3 = if props.teamNumber == 1 then Colors.DemoDemonsOrange else Colors.DemoDemonsRed;
    BackgroundTransparency = 0.2;
    Size = UDim2.new(0, 10, 0, 10);
    BorderSizePixel = 0;
    LayoutOrder = props.teamNumber + (props.teamNumber - 1);
  }, {
    UICorner = React.createElement(CircleUICorner);
    CircleFilling = React.createElement("Frame", {
      BackgroundColor3 = Color3.new(1, 1, 1);
      AnchorPoint = Vector2.new(0.5, 0.5);
      Position = UDim2.new(0.5, 0, 0.5, 0);
      Size = UDim2.new(0, 5, 0, 5);
      BorderSizePixel = 0;
    }, {
      CircleUICorner = React.createElement(CircleUICorner);
    });
  });

end;

return TeamDot;