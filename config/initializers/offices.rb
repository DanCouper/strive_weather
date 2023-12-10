# NOTE: Development tool ONLY. Delete this + config/offices.yml
#       once the model & Db table has been added.
OFFICES = YAML.load_file("#{Rails.root}/config/offices.yml").map { |office| office.symbolize_keys }
