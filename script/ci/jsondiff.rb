require 'json'
require 'yaml'

Config = YAML.load(File.read("_config.yml"))

baseUrl = Config['url']
urlsToPurge = { }
urls = []
File.readlines('deploy/filenames.diff').each do |line|
  urls.push("#{baseUrl}/#{line.chomp}")
end
urlsToPurge['files'] = urls

File.open('urls_to_purge.json', 'w') do |file|
  file.write JSON.generate(urlsToPurge)
end
