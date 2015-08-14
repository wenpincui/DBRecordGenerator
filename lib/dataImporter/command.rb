require 'optparse'
require "tiny_tds"

module DataImporter
  class Command

    COMMAND_REGEX = /^[a-zA-Z]*/
    attr_reader :parameters, :help, :operation

    def initialize(args)
      @parameters = {}
      @operation = '' << args[0] if args[0] =~ COMMAND_REGEX
      @opt_parser = OptionParser.new do |opt|
        opt.banner = 'Usage: dbscriptomate COMMAND [OPTIONS]'
        opt.separator ''
        opt.separator 'Commands'
        opt.separator '     setupdb:    will setup the database for initial user. A journaling table will be created'
        opt.separator '     migrate:    run all the migration files'
        opt.separator '     generate:   generate a new migration script'
        opt.separator ''
        opt.separator 'Options'

        opt.on('-h', '--host [HOST]', String, 'the IP address or machine name of where the database is running') do |host|
          @parameters[:host] = host
        end

        opt.on('-n', '--dbname [DBNAME]', String, 'the database against which we need to run the scripts') do |dbname|
          @parameters[:dbname] = dbname
        end

        opt.on('-u', '--username [USERNAME]', String,'username used to connect to the database') do |username|
          @parameters[:username] = username
        end

        opt.on('-p', '--password [PASSWORD]', String,'password of the user used to connect to the database') do |password|
          @parameters[:password] = password
        end

        opt.on('-o', '--port [PORT]', String,'the port used to connect to the database') do |port|
          @parameters[:port] = port
        end

        opt.on('-s', '--sql [SQL]', String,'the file store sql procedure') do |sql|
          @parameters[:sql] = sql
        end

        opt.on('-c', '--count [COUNT]', String,'count of db records, in MB unit') do |count|
          @parameters[:count] = count
        end

        opt.on_tail('-?', '--help', 'Show this message') do
          puts opt
          exit
        end
      end
      @help = @opt_parser.help
      parse! args
    end

    def random_str()
      return (0...10240).map { ('a'..'z').to_a[rand(26)] }.join
    end

    def execute()
      runner = SQLRunner.new(@parameters[:username], @parameters[:password], @parameters[:host], @parameters[:dbname])
      count = @parameters[:count].to_i

      File.open(@parameters[:sql], "r") do |infile|
        while (line = infile.gets)
          runner.run_sql(line)
        end
      end if @parameters.has_key?(:sql)

      runner.run_sql("create table hugedb.dbo.hugetable0 (id int, name text)")


      1000.times do |cnt| # ~10M
        text = random_str()
        sql = "insert into hugetable0 (id, name) values (#{cnt}, \'#{text}\')"
        runner.run_sql(sql)
      end

      (1..count-1).each do |cnt|
        puts "10M data inserted"
        runner.run_sql("create table hugedb.dbo.hugetable#{cnt} (id int, name text)")
        runner.run_sql("INSERT INTO hugedb.dbo.hugetable#{cnt} (id, name) SELECT id,name FROM hugedb.dbo.hugetable0")
      end
    end

    def parse!(args)
      @opt_parser.parse! args
    end

    class SQLRunner
      attr_reader :username, :password, :host, :database

      def initialize(username, password, host, database)
        @username = username
        @password = password
        @host = host
        @database = database

        @client =
          TinyTds::Client.new(:username => @username,
                              :password => @password,
                              :host => @host,
                              :database => @database)
      end

      def run_sql(contents)
        result = @client.execute(contents)
        result.cancel
      end
    end
  end
end
