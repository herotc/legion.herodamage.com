require 'rubygems'
require 'bundler/setup'
require 'json'
require 'active_support'
require 'active_support/all'
require 'yaml'

# Config = YAML.load(File.read("_config.yml"))

collectionsDir = "collections"
reportDir = "report"
simCollections = {
  'Combinator' => 'combinations',
  'Relics' => 'relics',
  'Trinkets' => 'trinkets',
  'Races' => 'races'
}
wowClasses = ['death_knight', 'demon_hunter', 'druid', 'hunter', 'mage', 'monk', 'paladin', 'priest', 'rogue', 'shaman', 'warlock', 'warrior']
langs = ['en', 'fr']

# Empty each collections
simCollections.each do |simType, simColection|
  wowClasses.each do |wowClass|
    FileUtils.rm_f Dir.glob("#{collectionsDir}/_#{wowClass}-#{simColection}/*")
  end
end

# Generate the new views
reports = Dir.glob("#{reportDir}/*.json")
reportsCount = reports.length * langs.length
reportsProcessed = 0
puts "Starting to generate views for #{reportsCount} potential reports."

# Load the locale fallback
localeFallback = JSON.parse(File.read("_data/en/locale.json"))
# Merger to override recursively keys, credits to jekyll-polyglot gem
merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }

langs.each do |lang|
  # Load the locale infos then merge it with the fallback
  localeFile = "_data/#{lang}/locale.json"
  if File.exist?(localeFile)
    locale = JSON.parse(File.read(localeFile))
    locale = localeFallback.merge(locale, &merger)
  else
    locale = localeFallback
  end
  localeLS = locale['layouts']['simulations'] # Shortcut to simulations layouts

  reports.each do |file|
    reportFilename = file.gsub("#{reportDir}/", '').gsub(".json", '')
    reportFile = "#{reportDir}/#{reportFilename}.json"

    # TODO: Use a progress bar to avoid making really long log and let it with a --verbose arg
    # puts "#{reportsProcessed + 1}/#{reportsCount} - Generating #{reportFilename} view."
    # Report Infos
    filenameParts = reportFilename.split('-', 2)
    #Variation name starts after first hyphen, format nicely
    gearVariationRaw = filenameParts[1]
    reportInfosRaw = filenameParts[0].split('_')
    reportInfos = {
      'type' => reportInfosRaw[0].gsub('Simulation', 's'),
      'fightstyle' => reportInfosRaw[1],
      'tier' => reportInfosRaw[2],
      'class' => reportInfosRaw[3],
      'spec' => reportInfosRaw[4],
      'suffix' => reportInfosRaw[5],
      'gearvariation' => gearVariationRaw ? gearVariationRaw.split('_').join(' ') : nil
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
    reportFancyCollection = "#{localeLS['collections'][reportInfos['type']]}"
    reportFancyFightstyle = "#{localeLS['fightstyles'][reportInfos['fightstyle']]}"
    reportFancyTier = "#{localeLS['tiers'][reportInfos['tier']]}"
    reportFancyTierExpanded = "#{localeLS['tiersExpanded'][reportInfos['tier']]}"
    if reportInfos['type'] == "Combinator" && reportInfos['tier'] == 'T21' # Combinator does have tier distinction
      reportFancyTier += " Mythic"
      reportFancyTierExpanded += " Mythic"
    end
    reportSpecWithSuffix = "#{reportInfos['spec']}"
    if reportInfos['suffix']
      reportSpecWithSuffix += " #{reportInfos['suffix']}"
    end

    # Meta Infos
    json = JSON.parse(File.read(reportFile))['metas']
    simc = {
      'buildDate' => json['build_date'].gsub('  ', ' '),
      'targetError' => json['options']['target_error'],
      'buildTimestamp' => json['build_timestamp'],
      'resultTimestamp' => json['result_timestamp']
    }
    wow = {
      'build' => json['options']['dbc'][json['options']['dbc']['version_used']]['build_level'],
      'version' => json['options']['dbc'][json['options']['dbc']['version_used']]['wow_version']
    }

    # Views Infos
    viewName = "#{reportInfos['fightstyle']}-#{reportInfos['tier']}-#{reportInfos['class'].gsub('_', '-')}-#{reportSpecWithSuffix.gsub(' ', '-')}"
    viewName += "-#{gearVariationRaw.gsub('_', '-').gsub('+', '-')}" if gearVariationRaw
    viewName = viewName.downcase

    # Front matter output
    front = {
      'lang' => " #{lang}",
      'slug' => " #{viewName}",
      'title' => " #{reportFancyTier} #{reportFancyFightstyle} #{reportFancyCollection} Simulations - #{reportSpecWithSuffix}",
      'description' => " #{reportInfos['type']} results of the #{reportFancyTierExpanded} #{reportFancyFightstyle} simulations for the #{reportInfos['class'].gsub('_', ' ')} #{reportSpecWithSuffix}.",
      'fightstyle' => " #{reportFancyFightstyle}",
      'tier' => " #{reportFancyTier}",
      'class' => " #{reportInfos['class'].gsub('_', ' ')}",
      'spec' => " #{reportSpecWithSuffix}"
    }

    if reportInfos['gearvariation']
      front['gearvariation'] = " #{reportInfos['gearvariation']}"
    end

    if ['Relics', 'Trinkets', 'Races'].include?(reportInfos['type'])
      front['templateDPS'] = " #{json['player']['collected_data']['dps']['mean'].round(0)}"
      player = {
        'talentsName' => [],
        'legendariesName' => []
      }
      # TODO: Also get encoded talents from simc (to add in simc report)
      json['player']['talents'].each do |talent|
        player['talentsName'].push("\"#{talent['name']}\"")
      end
      # TODO: Remove legendaries at 970 once everything will be at 1000
      # TODO: Blacklist pantheon trinkets
      # TODO: Use bnet api to retrieve localized item name & quality
      json['player']['gear'].each do |slot, item|
        if (reportInfos['tier'] != 'T21' && item['ilevel'] >= 970) || item['ilevel'] >= 1000
          player['legendariesName'].push("\"#{item['name'].gsub('_', ' ').titleize}\"")
        end
      end
      front['talents'] = "\n  - #{player['talentsName'].join("\n  - ")}"
      front['legendaries'] = "\n  - #{player['legendariesName'].join("\n  - ")}"
    end

    # Write crucibleweight string if it exists
    if reportInfos['type'] == "Relics" && json['crucibleweight']
      front['crucibleweight'] = " #{json['crucibleweight']}"
    end

    front['reportfile'] = " #{reportFile}"
    front['targeterror'] = " #{simc['targetError']}"
    front['lastupdate'] = " #{simc['buildDate']}"
    front['buildtimestamp'] = " #{simc['buildTimestamp']}"
    front['resulttimestamp'] = " #{simc['resultTimestamp']}"
    front['build'] = " #{wow['version']} ##{wow['build']}"

    if ['Relics', 'Trinkets', 'Races'].include?(reportInfos['type'])
      front['charttitle'] = " #{wow['version']} #{reportSpecWithSuffix} #{reportInfos['type']} (#{reportInfos['tier']} SimC Profile, #{simc['buildDate']})"
    end

    # Special hotfix for T19 Relics to hide NC T2 traits
    if reportInfos['type'] == "Relics" && reportInfos['tier'] == 'T19'
      front['chartStyleClass'] = ' half-height'
    end


    # Write the view
    viewDir = "#{collectionsDir}/_#{reportInfos['class']}-#{simCollections[reportInfos['type']]}"
    viewDir = viewDir.downcase
    if !Dir.exist?(viewDir)
      Dir.mkdir viewDir
    end
    viewFile = "#{viewDir}/#{viewName}"
    viewFile += "-#{lang}"
    viewFile += '.html'
    File.open(viewFile, 'w') do |view|
      view.puts "---"
      front.each do |key, value|
        if key == 'reportfile'
          view.puts
        end
        view.puts "#{key}:#{value}"
      end
      view.puts "---"
    end

    # Reports counter
    reportsProcessed += 1
  end
end

reportsSkipped = reportsCount - reportsProcessed
puts "Generated #{reportsProcessed}/#{reportsCount} views, #{reportsSkipped} skipped."
