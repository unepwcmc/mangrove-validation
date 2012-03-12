class Actions < EnumerateIt::Base
  associate_values(
    :validate => 0,
    :add => 1,
    :delete => 2
  )
end
