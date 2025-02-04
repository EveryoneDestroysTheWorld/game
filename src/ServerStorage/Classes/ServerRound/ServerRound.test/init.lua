--!strict

local canStart = require(script.canStart);

return {
  ServerRound = {
    ["can start"] = canStart
  }
}