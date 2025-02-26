--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local NameHeadBar = require(ReplicatedStorage.Client.ReactComponents.NameHeadBar);
local HealthHeadBar = require(ReplicatedStorage.Client.ReactComponents.HealthHeadBar);

type HeadBarContainerProps = {
  contestantID: number;
  roundID: string;
}

local function HeadBarContainer(props: HeadBarContainerProps)

  return React.createElement(React.Fragment, {}, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      Padding = UDim.new(0.1, 0);
    });
    NameHeadBar = React.createElement(NameHeadBar, {
      contestantID = props.contestantID;
      roundID = props.roundID;
    });
    HealthHeadBar = React.createElement(HealthHeadBar, {
      contestantID = props.contestantID;
      roundID = props.roundID;
    });
  });

end

return HeadBarContainer;