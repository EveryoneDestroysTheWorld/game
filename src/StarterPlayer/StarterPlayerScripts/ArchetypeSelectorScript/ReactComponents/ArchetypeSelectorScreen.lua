--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local SearchBox = require(script.Parent.SearchBox);
local SearchResultList = require(script.Parent.SearchResultList);
local Lighting = game:GetService("Lighting");
local ReactRoblox = require(ReplicatedStorage.Shared.Packages["react-roblox"]);
local GuiService = game:GetService("GuiService");

type RoundTimerProps = {
  round: ClientRound;
  shouldOpen: boolean;
  onClose: () -> ();
  archetypeIDs: {string};
}

local function ArchetypeSelectorScreen(props: RoundTimerProps)

  local query, setQuery = React.useState("");

  React.useEffect(function(): ()
  
    task.spawn(function()

      GuiService.TouchControlsEnabled = not props.shouldOpen;

      if props.shouldOpen then


      else

        ReplicatedStorage.Client.Functions.ToggleHUD:Invoke(true);

        props.onClose();

      end;

    end);

  end, {props.onClose :: unknown, props.shouldOpen});

  return React.createElement("Frame", {
    BackgroundColor3 = Color3.new();
    BorderSizePixel = 0;
    BackgroundTransparency = 0.6;
    Size = UDim2.new(1, 0, 1, 0);
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      Padding = UDim.new(0, 5);
    });
    UIPadding = React.createElement("UIPadding", {
      PaddingLeft = UDim.new(0, 30);
      PaddingRight = UDim.new(0, 30);
      PaddingTop = UDim.new(0, 30);
      PaddingBottom = UDim.new(0, 30);
    });
    SearchBox = React.createElement(SearchBox, {
      onChange = function(newQuery: string)
        
        setQuery(newQuery);

      end;
    });
    SearchResultList = React.createElement(SearchResultList, {
      archetypeIDs = props.archetypeIDs;
      query = query;
    });
    ArchetypeSelectorBlur = ReactRoblox.createPortal({
      React.createElement("BlurEffect", {
        Size = 12;
      });
    }, Lighting);
    ArchetypeSelectorColorCorrection = ReactRoblox.createPortal({
      React.createElement("ColorCorrectionEffect", {
        Saturation = -1;
      });
    }, Lighting);
  });

end;

return ArchetypeSelectorScreen;