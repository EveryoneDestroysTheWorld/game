--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local Button = require(ReplicatedStorage.Client.ReactComponents.Button);
local Players = game:GetService("Players");
local SearchBox = require(script.Parent.SearchBox);
local TweenService = game:GetService("TweenService");

type RoundTimerProps = {
  round: ClientRound;
  shouldOpen: boolean;
  onClose: () -> ();
}

local function ArchetypeSelectorScreen(props: RoundTimerProps)

  local query, setQuery = React.useState("");
  local selection, setSelection = React.useState(nil :: string?);

  React.useEffect(function(): ()
  
    if props.shouldOpen then

      -- Run animations.

    else

      props.onClose();

      -- local tween = TweenService:Create(instance, tweenInfo, propertyTable);

      -- tween.Completed:Once(props.onClose);

      -- return function()

      --   tween:Cancel();

      -- end;

    end;

  end, {props.onClose :: unknown, props.shouldOpen})

  return React.createElement("Frame", {
    BackgroundColor3 = Color3.new();
    BorderSizePixel = 0;
    BackgroundTransparency = 0.6;
    Size = UDim2.new(1, 0, 1, 0);
  }, {
    SearchBox = React.createElement(SearchBox, {
      onChange = function(newQuery: string)
        
        setQuery(newQuery);

      end;
    });
  });

end;

return ArchetypeSelectorScreen;