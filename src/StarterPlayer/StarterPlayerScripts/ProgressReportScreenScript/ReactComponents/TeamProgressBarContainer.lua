--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;

export type TeamProgressBarContainerProperties = {
  LayoutOrder: number;
  percentage: number;
};

local function TeamProgressBarContainer(properties: TeamProgressBarContainerProperties)

  return React.createElement("Frame", {
    BackgroundColor3 = Color3.new();
    BackgroundTransparency = 0.6;
    Size = UDim2.new(1, 0, 0, 30);
    LayoutOrder = 1;
  }, {
    UIGradient = React.createElement("UIGradient");
    UIStroke = React.createElement("UIStroke");
    TextLabel = React.createElement("TextLabel", {
      AutomaticSize = Enum.AutomaticSize.XY;
      BackgroundTransparency = 1;
      AnchorPoint = Vector2.new(0.5, 0.5);
    });
  });

end;

return TeamProgressBarContainer;