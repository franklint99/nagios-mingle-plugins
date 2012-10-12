module MingleNagiosChecks

  class BaseCheck
    def log(message)
      puts message if @verbose
    end

    def alert_for_range?(range_string, value)
      if range_string =~ /^[\d]+$/
        return !(0..range_string.to_i).include?(value)
      end

      if range_string =~ /^[\d]+:$/
        return value < range_string.gsub(":", "").to_i
      end

      if range_string =~ /^~:[\d]+$/
        return value > range_string.gsub(/^~:/, "").to_i
      end

      if range_string =~ /^(\@)?([\d]+:[\d]+)$/
        invert_range = !($1.nil?)
        start, finish = $2.split(":").map(&:to_i)

        return (start..finish).include?(value) if invert_range
        return !(start..finish).include?(value)
      end

      raise "Failed to parse range #{range_string.inspect}"
    end
  end

end
