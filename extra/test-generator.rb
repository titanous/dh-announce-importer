require 'rubygems'
require 'fastercsv'
require 'random_data'

data = [%w(Name Email Phone)]

1.upto(100) do |n|
  data << ["#{Random.firstname} #{Random.lastname}", Random.email, Random.phone]
end

FasterCSV.open("test1.csv", "w") do |csv|
  data.each { |row| csv << row }
end
