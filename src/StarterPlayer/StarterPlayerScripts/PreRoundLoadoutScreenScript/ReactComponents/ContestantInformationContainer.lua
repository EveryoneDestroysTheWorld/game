--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ContestantFrame = require(script.Parent.ContestantFrame);
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;

local function ContestantInformationContainer(props: {teams: {{ClientContestant}}})

  local teamIndex, setTeamIndex = React.useState(1);
  local contestantIndex, setContestantIndex = React.useState(1);

  React.useEffect(function()
  
    if props.teams[teamIndex] then

      task.delay(0.5, function()
      
        if props.teams[teamIndex][contestantIndex + 1] then

          setContestantIndex(contestantIndex + 1);

        else
          
          setTeamIndex(teamIndex + 1);
          setContestantIndex(1);

        end;

      end);

    else

      ReplicatedStorage.Shared.Events.MatchupPreviewCompleted:FireServer();

    end;

  end, {props.teams :: any, teamIndex, contestantIndex});

  local teamComponents = {};
  for teamID, contestantList in props.teams do

    local teamMemberComponents = {}
    for index, contestant in contestantList do

      table.insert(teamMemberComponents, React.createElement(ContestantFrame, {contestant = contestant; index = index; currentContestantIndex = contestantIndex; currentTeamIndex = teamIndex}));

    end;

    table.insert(teamComponents, React.createElement("Frame", {
      AutomaticSize = Enum.AutomaticSize.XY;
      BackgroundTransparency = 1;
    }, {
      UIListLayout = React.createElement("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder;
        FillDirection = Enum.FillDirection.Horizontal;
        HorizontalAlignment = Enum.HorizontalAlignment.Center;
        VerticalAlignment = Enum.VerticalAlignment.Center;
        Padding = UDim.new(0, 5);
      });
      TeamComponents = React.createElement(React.Fragment, {}, teamMemberComponents);
    }));

  end;

  local selectedContestant = if props.teams[teamIndex] then props.teams[teamIndex][contestantIndex] else nil;

  return React.createElement("Frame", {
    Size = UDim2.new(1, 0, 1, 0);
    BackgroundTransparency = 1;
    BorderSizePixel = 0;
  }, {
    ContestantList = React.createElement("Frame", {
      AnchorPoint = Vector2.new(0.5, 0.5);
      Position = UDim2.new(0.5, 0, 0.5, 0);
      BackgroundTransparency = 1;
      AutomaticSize = Enum.AutomaticSize.XY;
      Size = UDim2.new();
      ZIndex = 2;
    }, {
      UIListLayout = React.createElement("UIListLayout", {
        HorizontalAlignment = Enum.HorizontalAlignment.Center;
        VerticalAlignment = Enum.VerticalAlignment.Center;
        SortOrder = Enum.SortOrder.LayoutOrder;
        FillDirection = Enum.FillDirection.Horizontal;
        Padding = UDim.new(0, 50);
      });
      TeamComponents = React.createElement(React.Fragment, {}, teamComponents);
    });
    SelectedContestantInfo = if selectedContestant then React.createElement("Frame", {
      AnchorPoint = Vector2.new(0, 1);
      Position = UDim2.new(0, 30, 1, -30);
      AutomaticSize = Enum.AutomaticSize.XY;
      BackgroundTransparency = 1;
    }, {
      UIListLayout = React.createElement("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder;
      });
      DisplayNameLabel = React.createElement("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.XY;
        Text = selectedContestant.name;
        BackgroundTransparency = 1;
        TextColor3 = Color3.new(0, 0, 0);
        LayoutOrder = 1;
        FontFace = Font.fromId(11702779517, Enum.FontWeight.Bold);
        TextSize = 16;
      });
    }) else nil;
  });

end;

return ContestantInformationContainer;