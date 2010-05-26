require 'satan'

describe Integer do  

  it "should convert from pretty names to base units" do
    12.percent.should == 12
    1.byte.should == 1
    12.bytes.should == 12
    1.kilobyte.should == 1024.bytes
    12.kilobytes.should == 12 * 1.kilobytes
    1.megabyte.should == 1024.kilobytes
    12.megabytes.should == 12 * 1024.kilobytes
    1.gigabyte.should == 1024.megabytes
    12.gigabytes.should == 12 * 1.gigabyte
    1.second.should == 1
    12.seconds.should == 12
    1.minute.should == 60.seconds
    12.minutes.should == 12 * 1.minute
    1.hour.should == 60.minutes
    12.hours.should == 12 * 1.hour
    1.day.should == 24.hours
    12.days.should == 12 * 1.day
    1.week.should == 7 * 1.day
    12.weeks.should == 12 * 1.week
    1.month.should == 4.weeks
    12.months.should == 12 * 1.month
    1.year.should == 12.months
    12.years.should == 12 * 1.year
  end

  
  it "should convert to a pretty string with KB/MB/GB appropriately" do
    23.bytes.to_size.should == "23B"
    12.kilobytes.to_size.should == "12.00KB"
    1.megabyte.to_size.should == "1.00MB"
    1.gigabyte.to_size.should == "1.00GB"
    1.megabyte * 1024 * 5 == "0.50GB"
  end
end

