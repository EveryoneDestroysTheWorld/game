--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local TweenService = game:GetService("TweenService");
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;
local Players = game:GetService("Players");

local function ContestantFrame(props: {contestant: ClientContestant; index: number; currentContestantIndex: number; currentTeamIndex: number;})

  local frameRef = React.useRef(nil :: Frame?);

  local shade = React.useState(math.random(2, 33));
  local didPresent, setDidPresent = React.useState(false);
  
  local isShowingTeam = props.contestant.teamID and props.currentTeamIndex >= props.contestant.teamID;
  local shouldPresent = (props.currentContestantIndex >= props.index or (props.contestant.teamID and props.currentTeamIndex > props.contestant.teamID)) and (not props.contestant.teamID or isShowingTeam);

  React.useEffect(function()

    if shouldPresent and not didPresent then

      task.spawn(function()

        setDidPresent(true);
        local frame = frameRef.current;
        if frame then

          local originalPosition = frame.Position;
          for i = 1, 10 do

            local rumbleIntensity = 2;
            TweenService:Create(frame, TweenInfo.new(0.02), {
              Position = UDim2.new(frame.Position.X.Scale, math.random(0, rumbleIntensity) * (if math.random(0, 100) > 50 then -1 else 1), frame.Position.Y.Scale, math.random(0, rumbleIntensity) * (if math.random(0, 100) > 50 then -1 else 1));
            }):Play();
            task.wait(0.02);

          end;

          TweenService:Create(frame, TweenInfo.new(0.02), {
            Position = originalPosition;
          }):Play();

        end;

      end);

    end;

  end, {shouldPresent});

  local avatarImage: string? = nil;
  if props.contestant.player then

    local userId = props.contestant.player.UserId
    local thumbType = Enum.ThumbnailType.HeadShot
    local thumbSize = Enum.ThumbnailSize.Size420x420
    avatarImage = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

  end;

  local sound = React.useState(`rbxassetid://{({"9001303285", "8595980577", "12221967", "157167203", "1905367471", "9117969687", "4809574295", "3125624765"})[math.random(1, 8)]}`);

  return React.createElement("Frame", {
    BackgroundTransparency = 1;
    Size = UDim2.new(0, 30, 0, 30);
    SizeConstraint = Enum.SizeConstraint.RelativeYY;
    LayoutOrder = props.index;
  }, {
    ContestantMusic = React.createElement("Sound", {
      Playing = props.currentContestantIndex == props.index and (not props.contestant.teamID or props.contestant.teamID == props.currentTeamIndex);
      SoundId = sound;
      Volume = 0.3;
    });
    Frame = React.createElement("Frame", {
      BackgroundTransparency = if shouldPresent then 0 else 1;
      BackgroundColor3 = Color3.fromRGB(shade, shade, shade);
      BorderSizePixel = 0;
      ref = frameRef;
      Size = UDim2.new(1, 0, 1, 0);
      ClipsDescendants = true;
    }, {
      AvatarImageLabel = if avatarImage then
        React.createElement("ImageLabel", {
          BackgroundTransparency = 1;
          Image = avatarImage;
          Size = UDim2.new(1, 0, 1, 0);
        }, {
          UICorner = React.createElement("UICorner", {
            CornerRadius = UDim.new(1, 0);
          });
        })
      else nil;
      UICorner = React.createElement("UICorner", {
        CornerRadius = UDim.new(1, 0);
      });
    })
  });

end;

return ContestantFrame;