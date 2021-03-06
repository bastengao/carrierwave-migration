namespace :carrierwave do
  desc "migrate to new storage from file"
  task :from_file, [:model_class, :attribute] => :environment do |t, args|
    model_class, attribute = args.model_class, args.attribute
    model_class.constantize.all.each do |model|
      puts "migrate: #{model_class} #{model.id}"
      if model.try(attribute).present?
        attr = model.try(attribute)
        filename = File.basename(attr.path)
        file = Rails.root.join('public', store_dir(model, attribute), filename)
        File.open(file) do |f|
          model.public_send("#{attribute}=", f)
        end
        model.save!
      end
    end
  end

  # TODO:  独立出 public/uploads 目录, 和 store_dir 策略
  def store_dir(model, attribute)
    "uploads/#{model.class.to_s.underscore}/#{attribute}/#{model.id}"
  end
end
