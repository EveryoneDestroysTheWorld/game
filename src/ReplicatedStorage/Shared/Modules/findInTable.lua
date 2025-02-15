--!strict
return function<Item>(list: {Item}, iterator: (item: Item) -> boolean): Item?

  for _, item in list do

    if iterator(item) then

      return item;

    end;

  end;

  return;

end;
