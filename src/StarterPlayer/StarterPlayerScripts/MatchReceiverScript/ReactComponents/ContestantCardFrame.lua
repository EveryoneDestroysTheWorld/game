--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;

export type ContestantCardFrameProperties = {
  contestant: ClientContestant;
}

local function ContestantCardFrame(props: ContestantCardFrameProperties)

  React.useEffect(function()
  
    
    
  end, {});

  return React.createElement("Frame", {
    
  }, {
    DestructionPercentageFrame = React.createElement("Frame", {
      
    });
    ContentFrame = React.createElement("Frame", {
      Size = UDim2.new(1, 0, 1, 0);
      BackgroundTransparency = 1;
    }, {
      ContestantNameLabel = React.createElement("TextLabel", {
        BackgroundTransparency = 1;
        Text = props.contestant.name;
        AutomaticSize = Enum.AutomaticSize.X;
        Size = UDim2.new();
      })
    });
  })

end;

return ContestantCardFrame;