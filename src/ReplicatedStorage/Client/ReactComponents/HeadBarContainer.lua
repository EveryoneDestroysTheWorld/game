local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);
local NameHeadBar = require(ReplicatedStorage.Client.ReactComponents.NameHeadBar);
local HealthHeadBar = require(ReplicatedStorage.Client.ReactComponents.HealthHeadBar);

type HeadBarContainerProps = {
  contestant: ClientContestant.ClientContestant;
}

local function HeadBarContainer(props: HeadBarContainerProps)
  
  return React.createElement(React.Fragment, {}, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      Padding = UDim.new(0.1, 0);
    });
    NameHeadBar = React.createElement(NameHeadBar);
    HealthHeadBar = React.createElement(HealthHeadBar);
  });

end

return HeadBarContainer;