--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;
local ContestantSelectionButton = require(script.Parent.ContestantSelectionButton);

export type PlayerSelectionContainerProperties = {
  members: {ClientContestant};
  selectedContestant: ClientContestant?;
  onSelectedContestantChanged: (contestant: ClientContestant) -> ();
  LayoutOrder: number;
  didWin: boolean;
}

local function TeamSelectionContainer(properties: PlayerSelectionContainerProperties)

  local contestantButtons, setContestantButtons = React.useState({});
  React.useEffect(function()
  
    local newTeamContainers = {};
    for _, contestant in properties.members do

      table.insert(newTeamContainers, React.createElement(ContestantSelectionButton, {
        key = contestant.id;
        contestant = contestant;
        isSelected = properties.selectedContestant == contestant;
        onSelected = function()

          properties.onSelectedContestantChanged(contestant);

        end;
      }));

    end;
    setContestantButtons(newTeamContainers);

  end, {properties.members :: unknown, properties.selectedContestant, properties.onSelectedContestantChanged});

  return React.createElement("Frame", {
    BackgroundTransparency = 1;
    Size = UDim2.new(1, 0, 0, 20);
    AutomaticSize = Enum.AutomaticSize.Y;
    LayoutOrder = properties.LayoutOrder;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      VerticalAlignment = Enum.VerticalAlignment.Center;
      FillDirection = Enum.FillDirection.Horizontal;
      HorizontalAlignment = if properties.LayoutOrder == 1 then Enum.HorizontalAlignment.Left else Enum.HorizontalAlignment.Right;
      Padding = UDim.new(0, 5);
    });
    UIFlexItem = React.createElement("UIFlexItem", {
      FlexMode = Enum.UIFlexMode.Fill;
    });
    ContestantButtonList = React.createElement(React.Fragment, {}, contestantButtons);
  });

end;

return TeamSelectionContainer;