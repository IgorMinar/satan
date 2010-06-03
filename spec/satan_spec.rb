require 'satan'
require 'satan_mocks'
require 'timeout'

describe Satan do

  it "should do service restart and not kill service processes if a failure occurs and the restart kills Satan within the 'restart_grace' period" do
    temps = [10, 10, 20, 30, 40, 45, 60, 70, 100, 23, 500, 320, 120, 40, 30]
    satan = nil
    timed_out = false

    begin
      Timeout::timeout(1) {

        Satan.watch do |s|
          satan = s
          s.name = 'test satan instance'
          s.fmri = 'webserver'
          s.debug = true
          s.interval = 0
          s.contact = 'foo@bar'
          s.restart_grace = 2.seconds

          s.kill_if do |proc|
            proc.daemon = 'wserver'

            proc.condition :warp_core_temp do |temp|
              temp.above = 50
              temp.times = 5
              temp.test_values = temps
            end
          end
        end

      }
    rescue Timeout::Error
      timed_out = true
    end

    satan.email[:subject].should == "[SATAN] Restarted webserver on testhost"
    satan.email[:message].should == "[SATAN] Restarted webserver on testhost\n\nDaemon:\twserver\nRule:\tWarpCoreTempRule\nWarp core overheating! Temp: 120"
    satan.email[:address].should == "foo@bar"
    temps.should == [40, 30]
    satan.restarted.should == true
    satan.restarted_fmri == satan.fmri
    satan.killed.should == nil
    satan.killed_pids.should == nil
    timed_out.should == true
  end


  it "should attempt service restart and then kill service processes if a failure occurs and restart doesn't occur within the 'restart_grace' period" do
    temps = [10, 10, 20, 30, 40, 45, 60, 70, 100, 23, 500, 320, 120, 40, 30]
    satan = nil

    Satan.watch do |s|
      satan = s
      s.name = 'test satan instance'
      s.fmri = 'webserver'
      s.debug = true
      s.interval = 0
      s.contact = 'foo@bar'
      s.restart_grace = 0.seconds

      s.kill_if do |proc|
        proc.daemon = 'wserver'
        
        proc.condition :warp_core_temp do |temp|
          temp.above = 50
          temp.times = 5
          temp.test_values = temps
        end
      end
    end

    satan.email[:subject].should == "[SATAN] Restarted webserver on testhost"
    satan.email[:message].should == "[SATAN] Restarted webserver on testhost\n\nDaemon:\twserver\nRule:\tWarpCoreTempRule\nWarp core overheating! Temp: 120"
    satan.email[:address].should == "foo@bar"
    temps.should == [40, 30]
    satan.restarted.should == true
    satan.restarted_fmri == satan.fmri
    satan.killed.should == true
    satan.killed_pids.should == "452 453 454 455"
  end
end