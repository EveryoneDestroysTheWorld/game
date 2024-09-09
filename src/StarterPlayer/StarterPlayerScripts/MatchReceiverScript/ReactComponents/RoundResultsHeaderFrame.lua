local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local Colors = require(ReplicatedStorage.Client.Colors);

export type RoundResultsHeaderFrameProperties = {
  round: ClientRound;
}

local function RoundResultsHeaderFrame(props: RoundResultsHeaderFrameProperties)

  local round = props.round;
  local function getDestructionBlocks()

    local destructionBlocks = {};

    for i = 1, 20 do

      table.insert(destructionBlocks, React.createElement("Frame", {
        BackgroundColor3 = Colors.DemoDemonsGreen;
        BorderSizePixel = 0;
        Size = UDim2.new(0, 7, 1, 3);
        LayoutOrder = i;
      }))

    end;

    return destructionBlocks;

  end;

  return React.createElement("Frame", {
    BackgroundTransparency = 1;
    LayoutOrder = 1;
    Size = UDim2.new(1, 0, 0, 0);
    AutomaticSize = Enum.AutomaticSize.Y;
  }, {
    LeftSection = React.createElement("Frame", {
      BackgroundTransparency = 1;
      Size = UDim2.new(0.5, 0, 1, 0);
    }, {
      GameModeName = React.createElement("TextLabel", {
        BackgroundTransparency = 1;
        AutomaticSize = Enum.AutomaticSize.XY;
        Text = "TURF WAR";
      });
      StageName = React.createElement("TextLabel", {
        BackgroundTransparency = 1;
        AutomaticSize = Enum.AutomaticSize.XY;
        Text = "Prototype Stage";
      });
    });
    RightSection = React.createElement("Frame", {
      AnchorPoint = Vector2.new(1, 0);
      Position = UDim2.new(1, 0, 0, 0);
      BackgroundTransparency = 1;
      Size = UDim2.new(0.5, 0, 1, 0);
    }, {
      PersonalRoundStatus = React.createElement("TextLabel", {
        Text = "DRAW";
        Size = UDim2.new();
        AutomaticSize = Enum.AutomaticSize.XY;
        BackgroundTransparency = 1;
      });
      DestructionPercentage = React.createElement("Frame", {
        BackgroundTransparency = 1;
        Size = UDim2.new(0, 0, 0, 3);
        AutomaticSize = Enum.AutomaticSize.X;
      }, {
        UICorner = React.createElement("UICorner", {
          CornerRadius = UDim.new(0, 5);
        });
        UIListLayout = React.createElement("UIListLayout", {
          SortOrder = Enum.SortOrder.LayoutOrder;
          FillDirection = Enum.FillDirection.Horizontal;
          Padding = UDim.new(0, 1);
        });
        Blocks = React.createElement(React.Fragment, {}, getDestructionBlocks());
      });
      DestructionTextLabel = React.createElement("TextLabel", {
        Text = `0% DESTROYED BY TEAM`
      });
    });
  });

end;

return RoundResultsHeaderFrame;