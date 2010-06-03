SVCS_OUT = {
    :webserver => "online         Sep_17   svc:/network/webserver
               Sep_17        452 wdog
               Sep_17        453 wserver
               Sep_17        454 wserver
               Sep_17        455 logger",
    :simpleapp => "online         Sep_17   svc:/applications/simpleapp
               Sep_17        323 simpleapp"
}

PARGS_OUT = {
    453 => "/app/foo/webserver/lib/amd64/webservd -d /app/foo/webserver/https-foo/config " +
          "-r /app/foo/webserver -t /tmp/https-foo-f569c523 -u webservd " +
          "-s '/usr/sbin/svcadm enable -s svc:/network/http:https-foo'",
    454 => "/app/foo/webserver/lib/amd64/webservd -d /app/foo/webserver/https-foo/config " +
          "-r /app/foo/webserver -t /tmp/https-foo-f569c523 -u webservd " +
          "-s '/usr/sbin/svcadm enable -s svc:/network/http:https-foo'"
}

PS_OUT = {
  1 => "  PID %CPU    RSS     USER    GROUP
12790   2.7 707020 webservd webservd",
  2 => "  PID %CPU    RSS     USER    GROUP
12791  92.7 107020 webservd webservd",
  453 => "  PID %CPU    RSS     USER    GROUP
12790   2.7 707020 root root",
  454 => "  PID %CPU    RSS     USER    GROUP
12791  92.7 107020 webservd webservd"
}

module SvcsParser
  def pids_for_fmri
    SVCS_OUT[self.fmri.to_sym]
  end
end

module PsParser
  def args_for_pid(pid)
    PARGS_OUT[pid]
  end

  def ps_for_pid(pid)
    PS_OUT[pid]
  end
end


class Satan
  attr_reader :email, :restarted, :restarted_fmri, :killed, :killed_pids
  
  def send_email(subject, message, address)
    @email = { :subject => subject, :message => message, :address => address }
  end

  def hostname
    "testhost"
  end

  def svcadm_restart(fmri)
    @restarted = true
    @restarted_fmri = fmri
  end

  def kill(pids)
    @killed = true
    @killed_pids = pids
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