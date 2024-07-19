--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);

type HealthHeadBarProps = {
  contestant: ClientContestant.ClientContestant;
}

local function HealthHeadBar(props: HealthHeadBarProps)

  local contestantName, setContestantName = React.useState(props.contestant.name);

  React.useEffect(function()

    setContestantName(props.contestant.name);

  end, {props.contestant});

  return React.createElement("TextLabel", {
    Size = UDim2.new(1, 0, 0.8, 0);
    FontFace = Font.fromId(11702779517, Enum.FontWeight.Bold);
    Text = contestantName;
    TextScaled = true;
    BorderSizePixel = 0;
    BackgroundTransparency = 1;
    TextYAlignment = Enum.TextYAlignment.Bottom;
    LayoutOrder = 1;
  }, {
    UISizeConstraint = React.createElement("UISizeConstraint", {
      MaxSize = Vector2.new(math.huge, 24);
    });
  });

end

return HealthHeadBar;