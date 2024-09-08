--!strict
-- Programmers: Christian Toney (Christian_Toney)

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local TeamFrame = require(script.Parent.TeamFrame);

local function RoundResultsWindow()

  local function getDestructionBlocks()

    local destructionBlocks = {};

    for i = 1, 20 do

      table.insert(destructionBlocks, React.createElement("Frame", {
        BorderSizePixel = 0;
        Size = UDim2.new(0, 20, 1, 0);
      }))

    end;

    return destructionBlocks;

  end;

  return React.createElement("Frame", {
    Size = UDim2.new(1, 0, 1, 0);
    BackgroundColor3 = Color3.new();
    BackgroundTransparency = 0.1;
    BorderSizePixel = 0;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
    });
    Header = React.createElement("Frame", {
      BackgroundTransparency = 1;
      LayoutOrder = 1;
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
        Size = UDim2.new(0.5, 0, 1, 0);
      }, {
        PersonalRoundStatus = React.createElement("TextLabel", {
          Text = "WIN";
          Size = UDim2.new();
          AutomaticSize = Enum.AutomaticSize.XY;
          BackgroundTransparency = 1;
        });
        DestructionPercentage = React.createElement("Frame", {
          BackgroundTransparency = 1;
          Size = UDim2.new(1, 0, 0, 0);
          AutomaticSize = Enum.AutomaticSize.Y;
        }, getDestructionBlocks());
        DestructionTextLabel = React.createElement("TextLabel", {
          Text = `% DESTROYED BY TEAM`
        });
      });
    });
    Content = React.createElement("Frame", {
      BackgroundTransparency = 1;
      LayoutOrder = 2;
    }, {
      PersonalStatsFrame = React.createElement("Frame");
      LeaderboardFrame = React.createElement("Frame", {}, {
        AllyTeamFrame = React.createElement(TeamFrame);
        EnemyTeamFrame = React.createElement(TeamFrame);
      });
    });
    ControlsFrame = React.createElement("Frame", {
      BackgroundTransparency = 1;
      LayoutOrder = 3;
      Size = UDim2.new(1, 0, 0, 30);
    }, {

    });
  })

end;

return RoundResultsWindow;