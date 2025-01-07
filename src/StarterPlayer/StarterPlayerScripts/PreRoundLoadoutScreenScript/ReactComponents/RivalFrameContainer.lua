--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local RivalFrame = require(script.Parent.RivalFrame);

local function RivalFrameContainer(props: {onTransitionEnd: () -> ()})

  return React.createElement("Frame", {
    Size = UDim2.new(1, 0, 1, 0);
    BackgroundTransparency = 1;
    BorderSizePixel = 0;
  }, {
    Rival1 = React.createElement(RivalFrame, {quadrant = "Q2"});
    Rival2 = React.createElement(RivalFrame, {quadrant = "Q1"});
    Rival3 = React.createElement(RivalFrame, {quadrant = "Q4"});
    Rival4 = React.createElement(RivalFrame, {quadrant = "Q3"});
  });

end;

return RivalFrameContainer;