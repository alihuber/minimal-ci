require 'sinatra'
require 'json'
require 'data_mapper'
require 'haml'


class CI < Sinatra::Application
  set :haml, :format => :html5

  configure do
    DataMapper.setup(:default, "sqlite://#{Dir.pwd.to_s}/db.sqlite3")
    class Build
      include DataMapper::Resource
      property :id, Serial
      property :output, Text
      property :passed, Boolean
      property :date, String
    end
    DataMapper.finalize
    DataMapper.auto_upgrade!
  end

  get "/" do
    @builds = Build.all
    haml :index
  end

  get "/build/:id" do |n|
    build = Build.get(n)
    build.output
  end

  post "/start_build" do
    @url = params[:url] if params[:url]
    if params[:payload]
      github_push = JSON.parse(params[:payload])
      @url = github_push["repository"]["url"] + ".git"
    end
    @new_build = Build.create(:date => Time.now.to_s)
    @build_output = ""
    @success = true
    @project_folder = @url.slice(@url.rindex("/")+1..-5)
    stream do |out|
      out << "Cloning git repository #{@url}... <br>"
      out << run_command(out) { "git clone #{@url}"}

      out << "<br><br>Running bundle install... <br>"
      out << run_command(out) { "cd #{@project_folder}; bundle install" }

      out << "<br><br>Running rake db:migrate... <br>"
      out << run_command(out) { "cd #{@project_folder}; rake db:migrate" }

      out << "<br><br>Running rake/tests... <br>"
      out << run_command(out) { "cd #{@project_folder}; rake" }

      out << "<br><br>Removing project dir... Build FINISHED!<br>"
      out << run_command(out) { "rm -rf #{@project_folder}"}
      @new_build.update(:output => @build_output)
    end
  end

  def run_command(stream, &blk)
    cmd = 'vagrant ssh -c ' + "'" + blk.call +  "'"
    output = `#{cmd}`
    @success = check_ret
    @new_build.update(:passed => @success)
    output.gsub!(/\n/, "<br>")
    @build_output << output
    stream << output
  end

  def check_ret; return false if $?.to_i != 0; true;  end

end
