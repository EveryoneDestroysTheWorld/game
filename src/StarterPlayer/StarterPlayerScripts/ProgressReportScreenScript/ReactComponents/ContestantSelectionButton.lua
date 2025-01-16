--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;

export type PlayerSelectionContainerProperties = {
  members: {ClientContestant};
  selectedContestant: ClientContestant?;
  onSelected: () -> ();
  isSelected: boolean;
  didWin: boolean;
  LayoutOrder: number;
}

local function ContestantSelectionButton(properties: PlayerSelectionContainerProperties)

  return React.createElement("TextButton", {
    BackgroundTransparency = 0.6;
    BorderSizePixel = 0;
    Size = UDim2.new(1, if properties.isSelected then 5 else 0, 1, if properties.isSelected then 5 else 0);
    SizeConstraint = Enum.SizeConstraint.RelativeYY;
    BackgroundColor3 = Color3.new(1, 1, 1);
    [React.Event.Activated] = function()

      properties.onSelected();

    end;
    Text = "";
  }, {
    UICorner = React.createElement("UICorner", {
      CornerRadius = UDim.new(1, 0);
    });
    WinIndicator = if properties.didWin then
      React.createElement("ImageLabel", {
        BackgroundTransparency = 1;
        Size = UDim2.new(1, -5, 1, -5);
        Position = UDim2.new(0, 10, 0, -10);
        Rotation = 30;
        Image = "rbxassetid://125480383929162";
      })
    else nil;
  });

end;

return ContestantSelectionButton;