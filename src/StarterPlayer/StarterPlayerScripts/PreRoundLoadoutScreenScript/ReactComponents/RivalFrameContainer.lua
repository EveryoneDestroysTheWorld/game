--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local RivalFrame = require(script.Parent.RivalFrame);
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;

local function RivalFrameContainer(props: {onTransitionEnd: () -> (); rivalContestants: {ClientContestant}})

  local rivals = {};
  for rivalNumber, enemyContestant in props.rivalContestants do

    local quadrants = {2, 1, 4, 3};
    rivals[`Rival{rivalNumber}`] = React.createElement(RivalFrame, {quadrant = `Q{quadrants[rivalNumber]}`; contestant = enemyContestant})

  end;

  return React.createElement("Frame", {
    Size = UDim2.new(1, 0, 1, 0);
    BackgroundTransparency = 1;
    BorderSizePixel = 0;
  }, rivals);

end;

return RivalFrameContainer;