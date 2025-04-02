#!/usr/bin/env ruby
require 'yaml'

Dir.glob('_posts/*.md').each do |file|
  next if file.include?('ejemplo-entrevista-tech.md')
  
  content = File.read(file)
  if content.start_with?('---')
    parts = content.split('---', 3)
    if parts.length >= 3
      front_matter = YAML.load(parts[1]) || {}
      unless front_matter['categories']
        front_matter['categories'] = 'article'
        new_content = "---\n#{front_matter.to_yaml}---#{parts[2]}"
        File.write(file, new_content)
        puts "Updated #{file}"
      end
    end
  end
end
