require 'json'
require 'yaml'

Config = YAML.load(File.read("_config.yml"))

baseUrl = Config['url']
urlsToPurge = { }
urls = []
File.readlines('deploy/filenames.diff').each do |line|
  relativeUrl = line.chomp
  # Complete filename version, i.e.: https://www.herodamage.com/blog/index.html
  urls.push("#{baseUrl}/#{relativeUrl}")
  # Extensionless filename version for html files, i.e.: https://www.herodamage.com/blog/index
  if relativeUrl.include? '.html'
    urls.push("#{baseUrl}/#{relativeUrl.gsub(".html", '')}")
  end
  # Indexless version, i.e.: https://www.herodamage.com/blog/
  if relativeUrl.include? 'index.html'
    urls.push("#{baseUrl}/#{relativeUrl.gsub("index.html", '')}")
  end
  # Indexless version without trailing slash, i.e.: https://www.herodamage.com/blog
  if relativeUrl.include? '/index.html'
    urls.push("#{baseUrl}/#{relativeUrl.gsub("/index.html", '')}")
  end
end
urlsToPurge['files'] = urls

File.open('urls_to_purge.json', 'w') do |file|
  file.write JSON.generate(urlsToPurge)
end
