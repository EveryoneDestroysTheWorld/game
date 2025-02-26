--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientContestant = require(ReplicatedStorage.Client.Interfaces.ClientContestant);

type HealthHeadBarProps = {
  roundID: string;
  contestantID: number;
}

local function HealthHeadBar(props: HealthHeadBarProps)

  local contestantName, setContestantName = React.useState("");

  React.useEffect(function()

    task.spawn(function()
    
      local contestant = ReplicatedStorage.Shared.Functions.GetContestant:InvokeServer(props.roundID, props.contestantID) :: ClientContestant.ClientContestant;
      setContestantName(contestant.name);

    end);

  end, {props.contestantID :: unknown, props.roundID});

  return React.createElement("TextLabel", {
    Size = UDim2.new(1, 0, 0.8, 0);
    FontFace = Font.fromId(11702779517, Enum.FontWeight.Bold);
    Text = contestantName;
    TextScaled = true;
    BorderSizePixel = 0;
    BackgroundTransparency = 1;
    TextColor3 = Color3.new(1, 1, 1);
    TextYAlignment = Enum.TextYAlignment.Bottom;
    LayoutOrder = 1;
  }, {
    UISizeConstraint = React.createElement("UISizeConstraint", {
      MaxSize = Vector2.new(math.huge, 24);
    });
  });

end

return HealthHeadBar;