require 'yaml'
require 'octokit'

class OctoFun
  CONF = YAML.load_file('octofun.yml').freeze

  def initialize(use_token = false)
    user = CONF['user']
    params = use_token ? { access_token: user['token'] } : { login: user['name'], password: user['password'] }
    @client = Octokit::Client.new(params)
  end

  def copy_issues(**options)
    from = CONF['repo']['from']
    to = CONF['repo']['to']
    issues = @client.list_issues from, options

    p "There are #{issues.count} issues in #{from} repo"

    count = 0
    issues.each do |issue|
      begin
        @client.create_issue(to, issue.title, issue.body)
        p "Copy #{issue.title} issue to #{to} repo"
        count += 1
      rescue StandardError => e
        p "Failed copy #{issue.title} to #{to} repo becouse of #{e}"
        next
      end
    end

    p "Complete copy #{count} issues to #{to} repo"
  end
end

p 'Start OctoFun proses'

OctoFun.new.copy_issues

p 'End OctoFun proses'
