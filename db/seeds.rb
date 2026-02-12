profiles = [
	{ name: "Affonso Lima", github_url: "https://github.com/AffonsoLima" },
	{ name: "Affonso Giesel", github_url: "https://github.com/AffonsoGiesel" }
]

profiles.each do |attrs|
	profile = Profile.find_or_initialize_by(github_url: attrs[:github_url])
	profile.assign_attributes(attrs)
	profile.save!
	puts "Seeded #{profile.name} (#{profile.github_url})"
end

puts "Seeds finalizados. Execute bin/rails db:seed para carregar os perfis." if $PROGRAM_NAME.end_with?("rails")
