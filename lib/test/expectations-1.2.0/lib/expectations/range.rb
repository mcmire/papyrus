class Range
  
  def expectations_equal_to(other)
    self === other || self == other
  end
  
end