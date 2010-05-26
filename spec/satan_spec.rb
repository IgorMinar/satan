require 'satan'
require 'satan_mocks'

describe Satan do
  before(:each) do
    @satan = Satan.new
  end

  it "should kill monitored process due to failures" do
    temps = [10, 10, 20, 30, 40, 45, 60, 70, 100, 23, 500, 320, 120, 40, 30]
    satan = nil

    Satan.watch do |s|
      satan = s
      s.name = 'test satan instance'
      s.fmri = 'webserver'
      s.safe_mode = true
      s.debug = true
      s.interval = 0
      s.contact = 'foo@bar'
      s.restart_grace = 20

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
    satan.email[:message].should == "[SATAN] Restarted webserver on testhost\n\nCommand:\twserver\nRule:\tWarpCoreTempRule\nWarp core overheating! Temp: 120"
    satan.email[:address].should == "foo@bar"
    temps.should == [40, 30]
  end
end