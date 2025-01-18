--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;
local Fonts = require(ReplicatedStorage.Client.Fonts);

export type TeamProgressBarContainerProperties = {
  LayoutOrder: number;
  percentage: number;
  isLastTeam: boolean;
  didTeamWin: boolean;
};

local function TeamProgressBarContainer(properties: TeamProgressBarContainerProperties)

  local unknownTeamColor = Color3.new(1, 1, 1);

  local teamColors = {
    Color3.fromRGB(73, 255, 200);
    Color3.fromRGB(255, 115, 105);
  };

  local teamColor = teamColors[properties.LayoutOrder] or unknownTeamColor;
  
  return React.createElement("Frame", {
    BackgroundColor3 = teamColor;
    BackgroundTransparency = if properties.didTeamWin then 0 else 0.6;
    Size = UDim2.new(properties.percentage, 0, 1, 0);
    LayoutOrder = properties.LayoutOrder;
  }, {
    UIGradient = React.createElement("UIGradient", {
      Transparency = (
        if properties.isLastTeam then
          NumberSequence.new(0.325, 1)
        elseif properties.LayoutOrder == 1 then
          NumberSequence.new(1, 0.325)
        else
          NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.325), 
            NumberSequenceKeypoint.new(0.5, 1), 
            NumberSequenceKeypoint.new(1, 0.325)
          })
      );
      Color = (
        if properties.isLastTeam then 
          ColorSequence.new(teamColor, Color3.new(1, 1, 1))
        elseif properties.LayoutOrder == 1 then
          ColorSequence.new(teamColor, Color3.new(1, 1, 1))
        else
          ColorSequence.new({
            ColorSequenceKeypoint.new(0, teamColor),
            ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, teamColor)
          })
      );
    });
    UIStroke = React.createElement("UIStroke", {
      Color = teamColor;
      Thickness = 0.5;
      Transparency = if properties.didTeamWin then 0 else 0.7;
    });
    TextLabel = React.createElement("TextLabel", {
      AutomaticSize = Enum.AutomaticSize.XY;
      BackgroundTransparency = 1;
      AnchorPoint = Vector2.new(if properties.LayoutOrder == 1 then 0 elseif properties.isLastTeam then 1 else 0.5, 0.5);
      Position = UDim2.new(if properties.LayoutOrder == 1 then 0 elseif properties.isLastTeam then 1 else 0.5, if properties.LayoutOrder == 1 then 5 elseif properties.isLastTeam then -5 else 0, 0.5, 0);
      Text = `{math.floor(properties.percentage * 100)}%`;
      TextColor3 = Color3.new(1, 1, 1);
      TextSize = 14;
      FontFace = Fonts.Regular;
      TextTransparency = if properties.didTeamWin then 0 else 0.3;
    });
  });

end;

return TeamProgressBarContainer;