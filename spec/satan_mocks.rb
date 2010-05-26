SVCS_OUT = {
    :webserver => "online         Sep_17   svc:/network/webserver
               Sep_17        452 wdog
               Sep_17        453 wserver
               Sep_17        454 logger",
    :simpleapp => "online         Sep_17   svc:/applications/simpleapp
               Sep_17        323 simpleapp"
}


module SvcsParser
  def pids_for_fmri
    SVCS_OUT[self.fmri.to_sym]
  end
end


class Satan
  attr_reader :email
  
  def send_email(subject, message, address)
    @email = { :subject => subject, :message => message, :address => address }
  end

  def hostname
    "testhost"
  end
end



class WarpCoreTempRule < WatchRule
  attr_accessor :above, :test_values

  def test()
    @last_val = self.test_values.shift
    self.passed(@last_val < self.above)
  end

  def message
    "Warp core overheating! Temp: #{@last_val}"
  end
end