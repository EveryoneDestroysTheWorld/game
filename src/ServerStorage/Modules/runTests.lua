--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- © 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");

export type TestCaseResults = {
  [string]: TestCaseResults | boolean;
}

export type TestCase = {
  [string]: TestCase | () -> boolean;
}

--[[
  Runs every ".test.lua" file in ServerStorage and returns a dictionary of the results.
]]
local function runTests(): TestCaseResults
  
  local testResults: TestCaseResults = {};
  
  for _, instance in ServerStorage:GetDescendants() do
  
    if instance:IsA("ModuleScript") and #instance.Name >= #".test" and instance.Name:sub(#instance.Name + 1 - #".test") == ".test" then
    
      local initialGroup = require(instance) :: TestCase;
      local groups: {TestCase} = {initialGroup :: TestCase};
      local nameGroups: {string} = {};
      local closestGroup = testResults;
      while #groups >= 1 do
        
        local shouldGoUp = true;
  
        for caseName, caseValue in groups[#groups] do
  
          if closestGroup[caseName] then
  
            continue;
  
          elseif typeof(caseValue) == "table" then
  
            closestGroup[caseName] = {};
            closestGroup = closestGroup[caseName] :: TestCaseResults;
  
            table.insert(groups, caseValue);
            table.insert(nameGroups, caseName);
  
            shouldGoUp = false;
            break;
  
          elseif typeof(caseValue) == "function" then
  
            xpcall(function()
            
              closestGroup[caseName] = caseValue();

            end, function(message)

              warn(message);
              debug.traceback();
              closestGroup[caseName] = false;
            
            end);
            
          else
  
            error(`Test "{caseName}" is not a valid test. It must be a table or a function.`, 0);
  
          end;
  
        end;
  
        if shouldGoUp then
  
          table.remove(groups, 1);
          table.remove(nameGroups, 1);
  
          local newClosestGroup = testResults;
          for _, name in nameGroups do
  
            newClosestGroup = newClosestGroup[name] :: TestCaseResults;
  
          end;
  
        end;
  
      end;
  
    end;
  
  end;

  return testResults;
  
end;

return runTests;