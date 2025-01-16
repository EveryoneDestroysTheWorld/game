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
  }, {
    UICorner = React.createElement("UICorner", {
      CornerRadius = UDim.new(1, 0);
    });
  });

end;

return ContestantSelectionButton;