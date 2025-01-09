--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);

local round = ClientRound.fromServerRound();
if round.status ~= "Active" then

  round.onStarted:Wait();

end;

local sound = Instance.new("Sound");
sound.Name = "MatchMusic";
sound.SoundId = "rbxassetid://1837700487";
sound.Looped = true;

local equalizer = Instance.new("EqualizerSoundEffect");
equalizer.LowGain = 0;
equalizer.MidGain = -10;
equalizer.Parent = sound;

local reverb = Instance.new("ReverbSoundEffect");
reverb.WetLevel = -12;
reverb.Parent = sound;

sound.Parent = workspace;
sound:Play();

round.onEnded:Wait();

sound:Destroy();