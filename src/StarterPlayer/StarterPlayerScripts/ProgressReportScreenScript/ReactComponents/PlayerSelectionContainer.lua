--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;
local TeamSelectionContainer = require(script.Parent.TeamSelectionContainer);
local Fonts = require(ReplicatedStorage.Client.Modules.Fonts);

export type PlayerSelectionContainerProperties = {
  teams: {
    [number]: {ClientContestant}
  };
  selectedContestant: ClientContestant?;
  onSelectedContestantChanged: (contestant: ClientContestant) -> ();
}

local function PlayerSelectionContainer(properties: PlayerSelectionContainerProperties)

  local teamContainers, setTeamContainers = React.useState({});
  React.useEffect(function()
  
    local newTeamContainers = {};
    for teamID, members in properties.teams do

      table.insert(newTeamContainers, React.createElement(TeamSelectionContainer, {
        key = teamID;
        LayoutOrder = if teamID == 1 then teamID else 3;
        members = members;
        selectedContestant = properties.selectedContestant;
        onSelectedContestantChanged = function(contestant)

          properties.onSelectedContestantChanged(contestant);

        end;
      }));

    end;
    setTeamContainers(newTeamContainers);

  end, {properties.teams :: unknown, properties.selectedContestant, properties.onSelectedContestantChanged});

  return React.createElement("Frame", {
    BackgroundTransparency = 1;
    Size = UDim2.new(1, 0, 0, 20);
    AutomaticSize = Enum.AutomaticSize.Y;
    LayoutOrder = 2;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween;
      VerticalAlignment = Enum.VerticalAlignment.Center;
      FillDirection = Enum.FillDirection.Horizontal;
    });
    SelectedPlayerName = if properties.selectedContestant then
      React.createElement("TextLabel", {
        BackgroundTransparency = 1;
        TextColor3 = Color3.new(1, 1, 1);
        FontFace = Fonts.Bold;
        TextSize = 14;
        LayoutOrder = 2;
        Text = properties.selectedContestant.name
      })
    else nil;
    TeamContainerList = React.createElement(React.Fragment, {}, teamContainers);
  });

end;

return PlayerSelectionContainer;