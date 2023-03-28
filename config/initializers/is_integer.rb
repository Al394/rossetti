class String
  def is_int?
     /\A[-+]?\d+\z/ === self
  end
end
