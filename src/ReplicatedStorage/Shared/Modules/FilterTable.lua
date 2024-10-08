--!strict
return function<Item>(unfilteredTable: {Item}, iterator: (item: Item) -> boolean): {Item}

  local filteredTable = {};

  for _, item in unfilteredTable do

    if iterator(item) then

      table.insert(unfilteredTable, item);

    end;

  end;

  return filteredTable;

end;