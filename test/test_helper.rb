require "bundler"
Bundler.require(:default, :test)

require "minitest/spec"
require "minitest/autorun"
require "active_record"
require "./lib/moargration"
require "uri"

database_config = {
  :adapter  => "postgresql",
  :host     => "localhost",
  :database => "moargration_test",
  :min_messages => "warning"
}
Sequel.connect(database_config)
ActiveRecord::Base.establish_connection(database_config)

ActiveRecord::Base.connection.execute "DROP TABLE IF EXISTS samples"
ActiveRecord::Base.connection.execute "CREATE TABLE samples ( id integer UNIQUE, f1 text, f2 text, f3 text)"
ActiveRecord::Base.connection.execute "DROP TABLE IF EXISTS users"
ActiveRecord::Base.connection.execute "CREATE TABLE users ( id integer UNIQUE, f1 text, f2 text, f3 text)"

module ActiveRecord
  class Sample < ActiveRecord::Base
  end

  class User < ActiveRecord::Base
  end
end

module Sequel
  class Sample < Sequel::Model
  end

  class User < Sequel::Model
  end
end

# enable the hack, before setting up models
ENV["MOARGRATION_IGNORE"] = ""
Moargration.hack_active_record!
Moargration.hack_sequel!
