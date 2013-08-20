class Date
  def downtimestamp
    (self.to_time + 11.hours).to_i * 1000
  end
end
