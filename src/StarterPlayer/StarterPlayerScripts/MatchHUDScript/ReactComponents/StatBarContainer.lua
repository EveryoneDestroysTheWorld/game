--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local StatBar = require(script.Parent.StatBar);
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;

export type StatBarContainerProperties = {
  contestant: ClientContestant;
}

local function StatBarContainer(props: StatBarContainerProperties)

  return React.createElement("Frame", {
    AnchorPoint = Vector2.new(0.5, 1);
    Position = UDim2.new(0.5, 0, 1, -15);
    AutomaticSize = Enum.AutomaticSize.XY;
    Size = UDim2.new();
    BackgroundTransparency = 1;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      FillDirection = Enum.FillDirection.Horizontal;
      Padding = UDim.new(0, 5);
    });
    HealthBar = React.createElement(StatBar, {
      type = "Health";
      contestant = props.contestant;
    });
    StaminaBar = React.createElement(StatBar, {
      type = "Stamina";
      contestant = props.contestant;
    });
  });

end;

return StatBarContainer;