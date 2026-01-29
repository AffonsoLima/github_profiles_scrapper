class ProfileBlueprint < Blueprinter::Base
  identifier :id

  fields :name,
         :github_username,
         :short_github_url,
         :followers,
         :following,
         :stars,
         :contributions_last_year,
         :avatar_url,
         :location,
         :organizations
end
