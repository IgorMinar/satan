require 'satan'
require 'satan_mocks'

describe WatchedProcess do

  before(:each) do
    @process = WatchedProcess.new('simpleapp')
  end


  it "should get initialized" do
    @process.fmri.should == "simpleapp"
    @process.rules == []
  end


  it "should extract the pid for single process service" do
    @process.pid.should == 323
  end


  it "should extract the pid for multiprocess service" do
    process = WatchedProcess.new(:webserver)
    process.daemon = 'wserver'
    process.pid.should == 453
  end
  
end