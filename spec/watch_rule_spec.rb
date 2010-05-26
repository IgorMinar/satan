require 'satan'

describe WatchRule do
  before(:each) do
    @rule = WatchRule.new
    @rule.name = "Test Rule"
  end

  it "should initialize a rule with default values" do
    @rule.name.should == "Test Rule"
    @rule.times.should == 1
    @rule.failures.should == 0
    @rule.violated.should == false
  end

  it "should allow times to be redefined" do
    @rule.times = 23
    @rule.times.should == 23
  end

  it "should not increase the failure count if test passes" do
    wrule = WarpCoreTempRule.new
    wrule.above = 50
    wrule.test_values = [23]

    wrule.failures.should == 0
    wrule.test
    wrule.failures.should == 0
  end


  it "should increase the failure count if test fails" do
    wrule = WarpCoreTempRule.new
    wrule.above = 50
    wrule.test_values = [70]

    wrule.failures.should == 0
    wrule.test
    wrule.failures.should == 1
  end


  it "should decrease the failure count if test succeeds, but should not go negative" do
    wrule = WarpCoreTempRule.new
    wrule.above = 50
    wrule.test_values = [70, 30, 20, 80]

    wrule.test
    wrule.failures.should == 1

    wrule.test
    wrule.failures.should == 0

    wrule.test
    wrule.failures.should == 0

    wrule.test
    wrule.failures.should == 1
  end


  it "should flag the rule as violated if failure count reaches the 'times' limit" do
    wrule = WarpCoreTempRule.new
    wrule.test_values = [70, 80, 90]
    wrule.above = 50
    wrule.times = 3

    wrule.violated.should == false

    wrule.test
    wrule.violated.should == false

    wrule.test
    wrule.violated.should == false

    wrule.test
    wrule.violated.should == true
  end
end


describe CpuRule do

  before(:each) do
    @rule = CpuRule.new
    @rule.above = 50.percent
    @rule.failures.should == 0
  end

  it "should pass when CPU usage is below threashold" do
    @rule.pid = 1
    @rule.test
    @rule.failures.should == 0
  end

  it "should fail when CPU usage above threashold" do
    @rule.pid = 2
    @rule.test
    @rule.failures.should == 1
  end
end


describe MemoryRule do

  before(:each) do
    @rule = MemoryRule.new
    @rule.above = 200.megabytes
    @rule.failures.should == 0
  end

  it "should pass when memory usage is below threashold" do
    @rule.pid = 2
    @rule.test
    @rule.failures.should == 0
  end

  it "should fail when memory usage above threashold" do
    @rule.pid = 1
    @rule.test
    @rule.failures.should == 1
  end
end


describe JvmFreeHeapRule do

  before(:each) do
    @rule = JvmFreeHeapRule.new
    @rule.below = 100.megabytes
  end

  it "should know how to parse max size of the old generation" do
    @rule.og_max(1).should == 481728.kilobytes
    @rule.og_max(2).should == 64768.kilobytes
  end

  it "should know how to parse current size of the old generation" do
    @rule.og_current(1).should == 256334.kilobytes
    @rule.og_current(2).should == 19942.kilobytes
  end

  it "should pass when the free heap space is under defined threashold" do
    @rule.pid = 1
    @rule.test
    @rule.failures.should == 0
  end

  it "should fail when the free heap space is above defined threashold" do
    @rule.pid = 2
    @rule.test
    @rule.failures.should == 1
  end
end


PS_OUT = {
  1 => "  PID %CPU    RSS ARGS
12790   2.7 707020 java",
  2 => "  PID %CPU    RSS ARGS
12791  92.7 107020 httpd"
}

module PsParser
  def ps_for_pid(pid)
    PS_OUT[pid]
  end
end

JSTAT_GCCAPACITY_OUT = {
  1 => " NGCMN    NGCMX     NGC     S0C   S1C       EC      OGCMN      OGCMX       OGC         OC      PGCMN    PGCMX     PGC       PC     YGC    FGC
21248.0  42560.0  42560.0 4224.0 4224.0  34112.0    11520.0   481728.0   445536.0   445536.0  32768.0 204800.0 186116.0 186116.0   3391    20",
  2 => " NGCMN    NGCMX     NGC     S0C   S1C       EC      OGCMN      OGCMX       OGC         OC      PGCMN    PGCMX     PGC       PC     YGC    FGC
21248.0  21248.0  21248.0 2624.0 2624.0  16000.0    62656.0    64768.0    62656.0    62656.0  21248.0  86016.0  35364.0  35364.0     29     1"
}

JSTAT_GC_OUT = {
  1 => " S0C    S1C    S0U    S1U      EC       EU        OC         OU       PC     PU    YGC     YGCT    FGC    FGCT     GCT
4224.0 4224.0 2362.2  0.0   34112.0   8821.9   445536.0   256334.7  186116.0 111760.6   3424   48.890  20     12.063   60.952",
  2 => " S0C    S1C    S0U    S1U      EC       EU        OC         OU       PC     PU    YGC     YGCT    FGC    FGCT     GCT
2624.0 2624.0  0.0   520.5  16000.0   6198.3   62656.0    19942.9   35364.0 26002.8     29   14.438   1      0.201   14.639"
}

class JvmFreeHeapRule
  def jstat_gccapacity_for_pid(pid)
    JSTAT_GCCAPACITY_OUT[pid]
  end

  def jstat_gc_for_pid(pid)
    JSTAT_GC_OUT[pid]
  end
end