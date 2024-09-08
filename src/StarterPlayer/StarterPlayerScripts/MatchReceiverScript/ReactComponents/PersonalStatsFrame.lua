--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local StatBlockFrame = require(script.Parent.StatBlockFrame);

local function PersonalStatsFrame()

  return React.createElement("Frame", {
    BackgroundTransparency = 1;
    Size = UDim2.new();
    AutomaticSize = Enum.AutomaticSize.XY;
  }, {
    DestructionStatBlockFrame = React.createElement(StatBlockFrame, {
      headerText = "Destruction";
    });
    KnockoutsStatBlockFrame = React.createElement(StatBlockFrame, {
      headerText = "Knockouts"
    });
    WipeoutsStatBlockFrame = React.createElement(StatBlockFrame, {
      headerText = "Wipeouts"
    });
    RevivalsStatBlockFrame = React.createElement(StatBlockFrame, {
      headerText = "Revivals"
    });
    ActiveTimeStatBlockFrame = React.createElement(StatBlockFrame, {
      headerText = "Active time";
    });
  });

end;

return PersonalStatsFrame;