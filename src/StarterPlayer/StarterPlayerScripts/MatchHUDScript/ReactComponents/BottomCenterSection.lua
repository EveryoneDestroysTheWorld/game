--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local ArchetypeStatsContainer = require(script.Parent.ArchetypeStatsContainer);

type RoundTimerProps = {
  round: ClientRound;
}

local function BottomCenterSection(props: RoundTimerProps)

  return React.createElement("Frame", {
    BackgroundTransparency = 1;
  }, {
    ArchetypeStatsContainer = React.createElement(ArchetypeStatsContainer, {round = props.round});

    -- Create a background gradient so that it is easier to see the stats and archetype information.
    BackgroundGradientFrame = React.createElement("Frame", {
      AnchorPoint = Vector2.new(0, 1);
      Position = UDim2.new(0, 0, 1, 0);
      Size = UDim2.new(1, 0, 0, 100);
      BackgroundColor3 = Color3.new();
      BorderSizePixel = 0;
    }, {
      UIGradient = React.createElement("UIGradient", {
        Color = ColorSequence.new(Color3.new());
        Rotation = -90;
        Transparency = NumberSequence.new({
          NumberSequenceKeypoint.new(0, 0.45);
          NumberSequenceKeypoint.new(1, 1);
        })
      });
    })
  });

end;

return BottomCenterSection;