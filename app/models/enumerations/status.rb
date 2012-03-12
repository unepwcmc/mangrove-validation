class Status < EnumerateIt::Base
  associate_values(
    :original => 0,
    :validated => 1,
    :user_edits => 2
  )
end
