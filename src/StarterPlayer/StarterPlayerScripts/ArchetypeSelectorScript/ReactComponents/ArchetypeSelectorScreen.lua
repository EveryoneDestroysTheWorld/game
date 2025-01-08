--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local Button = require(ReplicatedStorage.Client.ReactComponents.Button);
local Players = game:GetService("Players");
local SearchBox = require(script.Parent.SearchBox);

type RoundTimerProps = {
  round: ClientRound;
}

local function ArchetypeSelectorScreen(props: RoundTimerProps)

  local query, setQuery = React.useState("");
  local selection, setSelection = React.useState(nil :: string?);

  return React.createElement("Frame", {
    AnchorPoint = Vector2.new(0.5, 1);
    BackgroundTransparency = 1;
    AutomaticSize = Enum.AutomaticSize.Y;
    Position = UDim2.new(0.5, 0, 1, -30);
    Size = UDim2.new(0, 200, 0, 0);
  }, {
    SearchBox = React.createElement(SearchBox, {
      onChange = function(newQuery: string)
        
        setQuery(newQuery);

      end;
    });
  });

end;

return ArchetypeSelectorScreen;