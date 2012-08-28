namespace :usasearch do
  namespace :forms do
    desc "import forms"
    task :import => :environment do
      rocis_hash = RocisData.new.to_hash
      SsaForm.new(rocis_hash).import
      UscisForm.new(rocis_hash).import
    end
  end
end
