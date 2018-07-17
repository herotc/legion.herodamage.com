require 'json'
require 'yaml'

Config = YAML.load(File.read("_config.yml"))

baseUrl = Config['url']
jsonFiles = [ ]
urls = [ ]

# Convert every changed files into urls
File.readlines('deploy/filenames.diff').each do |line|
  # Make a new jsonFile each time we go past 450 urls
  if urls.length > 450
    jsonFiles.push({ 'files' => urls })
    urls = [ ]
  end

  relativeUrl = line.chomp
  # Complete filename version, i.e.: https://legion.herodamage.com/blog/index.html
  urls.push("#{baseUrl}/#{relativeUrl}")
  # Extensionless filename version for html files, i.e.: https://legion.herodamage.com/blog/index
  if relativeUrl.include? '.html'
    urls.push("#{baseUrl}/#{relativeUrl.gsub(".html", '')}")
  end
  # Indexless version, i.e.: https://legion.herodamage.com/blog/
  if relativeUrl.include? 'index.html'
    urls.push("#{baseUrl}/#{relativeUrl.gsub("index.html", '')}")
  end
  # Indexless version without trailing slash, i.e.: https://legion.herodamage.com/blog
  if relativeUrl.include? '/index.html'
    urls.push("#{baseUrl}/#{relativeUrl.gsub("/index.html", '')}")
  end
  # Dirty hotfix for the homepage
  if relativeUrl == 'index.html'
    urls.push("#{baseUrl}")
  end
end
jsonFiles.push({ 'files' => urls })

jsonFiles.each_with_index do |hash, index|
  filename = "urls_to_purge_#{index+1}.json"
  puts filename
  puts JSON.pretty_generate(hash)
  File.open(filename, 'w') do |file|
    file.write JSON.generate(hash)
  end
end
