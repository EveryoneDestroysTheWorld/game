--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2025 Beastslash LLC

local function mergeTable<Table1, Table2>(table1: Table1, table2: Table2): Table1 & Table2
  
  local finalTable: any = table1 :: Table1 & Table2;

  for key, value in table2 :: any do

    finalTable[key] = value;

  end;

  return finalTable;

end;

return mergeTable;