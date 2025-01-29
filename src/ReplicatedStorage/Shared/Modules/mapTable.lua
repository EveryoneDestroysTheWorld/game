--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

return function<CurrentItem, NewItem>(unmappedTable: {CurrentItem}, iterator: (item: CurrentItem, index: number) -> NewItem): {NewItem}

  local mappedTable = {};

  for index, item in unmappedTable do

    table.insert(mappedTable, iterator(item, index));

  end;

  return mappedTable;

end;