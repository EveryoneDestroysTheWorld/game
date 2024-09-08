--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;
local ContestantCardFrame = require(script.Parent.ContestantCardFrame);

export type TeamFrameProperties = {
  contestants: {ClientContestant};
}

local function TeamFrame(props: TeamFrameProperties)

  local function createContestantCardFrames()

    local frames = {};

    for _, contestant in props.contestants do

      table.insert(frames, React.createElement(ContestantCardFrame, {
        contestant = contestant;
      }));

    end;

    return frames;

  end;

  return React.createElement("Frame", {

  }, {
    UIListLayout = React.createElement("UIListLayout", {
      Padding = UDim.new(0, 5);
    });
    ContestantCardList = React.createElement(React.Fragment, {}, createContestantCardFrames);
  });

end;

return TeamFrame;