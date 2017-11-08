require 'rubygems'
require 'bundler/setup'
require 'json'
require 'active_support'
require 'active_support/all'
require 'yaml'

Config = YAML.load(File.read("_config.yml"))

dataFolder = "data"
metaFolder = "data/meta"
simCollections = {
  'Combinator' => 'combinations',
  'Relics' => 'relics',
  'Trinkets' => 'trinkets'
}

# TODO: Make cleaner fancy things
fancyCollection = {
  'Combinator' => 'Combinations',
  'Relics' => 'Relics',
  'Trinkets' => 'Trinkets'
}
fancyFightstyles = {
  '1T' => 'Single Target',
  '2T' => 'Dual Target',
  '3T' => 'Triple Target',
  '1T_Adds' => 'Single Target w/ Adds',
  'Mistress' => 'Mistress',
}
fancyTier = {
  'T19' => 'T19',
  'T20' => 'T20',
  'T21' => 'T21',
  'T21H' => 'T21 Heroic',
}
fancyTierExpanded = {
  'T19' => 'Tier 19',
  'T20' => 'Tier 20',
  'T21' => 'Tier 21',
  'T21H' => 'Tier 21 Heroic',
}

# Empty each collections
simCollections.each do |key, value|
  if value != '_combinations' # Do not empty combinations views for now
    FileUtils.rm_f Dir.glob("value/*")
  end
end

# Generate the new views
Dir.glob("#{dataFolder}/*.csv").each do |file|
  reportFilename = file.gsub("#{dataFolder}/", '').gsub(".csv", '')
  csvFile = "#{dataFolder}/#{reportFilename}.csv"
  metaFile = "#{metaFolder}/#{reportFilename}.json"

  if File.exist?(metaFile)
    # Report Infos
    reportInfosRaw = reportFilename.split('_')
    reportInfos = {
      'type' => reportInfosRaw[0].gsub('Simulation', 's'),
      'fightstyle' => reportInfosRaw[1],
      'tier' => reportInfosRaw[2],
      'class' => reportInfosRaw[3],
      'spec' => reportInfosRaw[4],
      'suffix' => reportInfosRaw[5]
    }
    # Hotfix for SimC Class/Spec separated by an underscore
    if reportInfosRaw[4] == 'Beast' && reportInfosRaw[5] == 'Mastery'
      reportInfos['spec'] += " #{reportInfosRaw[5]}"
      reportInfos['suffix'] = reportInfosRaw[6]
    elsif (reportInfosRaw[3] == 'Death' && reportInfosRaw[4] == 'Knight') || (reportInfosRaw[3] == 'Demon' && reportInfosRaw[4] == 'Hunter')
      reportInfos['class'] += "_#{reportInfosRaw[4]}"
      reportInfos['spec'] = reportInfosRaw[5]
      reportInfos['suffix'] = reportInfosRaw[6]
    end
    reportFancyCollection = "#{fancyCollection[reportInfos['type']]}"
    reportFancyFightstyle = "#{fancyFightstyles[reportInfos['fightstyle']]}"
    reportFancyTier = "#{fancyTier[reportInfos['tier']]}"
    reportFancyTierExpanded = "#{fancyTierExpanded[reportInfos['tier']]}"
    if reportInfos['type'] == "Combinator" && reportInfos['tier'] == 'T21' # Combinator does have tier distinction
      reportFancyTier += " Mythic"
      reportFancyTierExpanded += " Mythic"
    end
    reportSpecWithSuffix = "#{reportInfos['spec']}"
    if reportInfos['suffix']
      reportSpecWithSuffix += " #{reportInfos['suffix']}"
    end

    # Meta Infos
    json = JSON.parse(File.read(metaFile))
    simc = {
      'buildDate' => json['build_date'].gsub('  ', ' '),
      'targetError' => json['options']['target_error']
    }
    wow = {
      'build' => json['options']['dbc'][json['options']['dbc']['version_used']]['build_level'],
      'version' => json['options']['dbc'][json['options']['dbc']['version_used']]['wow_version']
     }


    # Front matter output
    front = {
      'title' => " #{reportFancyTier} #{reportFancyFightstyle} #{reportFancyCollection} Simulations - #{reportSpecWithSuffix}",
      'description' => " #{reportInfos['type']} results of the #{reportFancyTierExpanded} #{reportFancyFightstyle} simulations for the #{reportInfos['class'].gsub('_', ' ')} #{reportSpecWithSuffix}.",
      'fightstyle' => " #{reportFancyFightstyle}",
      'tier' => " #{reportFancyTier}",
      'class' => " #{reportInfos['class'].gsub('_', ' ')}",
      'spec' => " #{reportSpecWithSuffix}"
    }

    if reportInfos['type'] == "Relics" || reportInfos['type'] == "Trinkets"
      player = {
        'talentsName' => [],
        'legendariesName' => []
      }
      # TODO: Also get encoded talents from simc (to add in simc report)
      json['player']['talents'].each do |talent|
        player['talentsName'].push(talent['name'])
      end
      # TODO: Remove legendaries at 970 once everything will be at 1000
      # TODO: Blacklist pantheon trinkets
      # TODO: Use bnet api to retrieve localized item name & quality
      json['player']['gear'].each do |slot, item|
        if (reportInfos['tier'] != 'T21' && item['ilevel'] >= 970) || item['ilevel'] >= 1000
          player['legendariesName'].push(item['name'].gsub('_', ' ').titleize)
        end
      end
      front['talents'] = "\n  - #{player['talentsName'].join("\n  - ")}"
      front['legendaries'] = "\n  - #{player['legendariesName'].join("\n  - ")}"
    end

    front['csvfile'] = " #{csvFile}"
    front['targeterror'] = " #{simc['targetError']}"
    front['lastupdate'] = " #{simc['buildDate']}"
    front['build'] = " #{wow['version']} ##{wow['build']}"

    if reportInfos['type'] == "Relics" || reportInfos['type'] == "Trinkets"
      front['charttitle'] = " #{wow['version']} #{reportSpecWithSuffix} #{reportInfos['type']} (#{reportInfos['tier']} SimC Profile, #{simc['buildDate']})"
    end

    # Special hotfix for T19 Relics to hide NC T2 traits
    if reportInfos['type'] == "Relics" && reportInfos['tier'] == 'T19'
      front['chartclass'] = ' half-height'
    end


    # Write the view
    if Config['repository'] == 'Ravenholdt-TC/ravenholdt-tc.github.io'
      viewDirectory = "_#{simCollections[reportInfos['type']]}"
    elsif Config['repository'] == 'SimCMinMax/herodamage'
      viewDirectory = "_#{reportInfos['class']}-#{simCollections[reportInfos['type']]}"
    end
    if !Dir.exist?(viewDirectory)
      Dir.mkdir viewDirectory
    end
    viewFile = "#{viewDirectory}/#{reportInfos['fightstyle']}-#{reportInfos['tier']}-#{reportInfos['class'].gsub('_', '-')}-#{reportSpecWithSuffix.gsub(' ', '-')}.html"
    File.open(viewFile.downcase, 'w') do |view|
      view.puts "---"
      front.each do |key, value|
        if key == 'csvfile'
          view.puts
        end
        view.puts "#{key}:#{value}"
      end
      view.puts "---"
    end
  else
    puts "No meta corresponding to #{reportFilename} report."
  end
end

puts 'Done! Press enter to quit...'
gets
