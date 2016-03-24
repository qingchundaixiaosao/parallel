require './spec/cases/helper'
require "active_record"
require "sqlite3"
STDOUT.sync = true


ActiveRecord::Schema.verbose = false
ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => ":memory:"
)

class User < ActiveRecord::Base
end

# create tables
unless User.table_exists?
  ActiveRecord::Schema.define(:version => 1) do
    create_table :users do |t|
      t.string :name
    end
  end
end

User.delete_all

3.times { User.create!(:name => "X") }

print "Parent: "
puts User.first.name

print "Parallel (threads): "
Parallel.each([1], in_threads: 1) do
  puts User.all.map(&:name).join
end

print "\nParent: "
puts User.first.name

print "Parallel (fork): "
Parallel.each([1], in_processes: 1) do
  puts User.all.map(&:name).join
end
ActiveRecord::Base.connection.reconnect!

print "\nParent: "
puts User.first.name
