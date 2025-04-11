Rails.application.config.to_prepare do
  # Patch uniquement les classes utilisées par Administrate
  if defined?(Administrate::ApplicationController)
    ActiveSupport.on_load(:active_record) do
      unless ActiveRecord::Relation.instance_methods.include?(:per)
        ActiveRecord::Relation.class_eval do
          def page(num)
            Kaminari::PaginatableArray.new(self).page(num)
          end

          def per(num)
            Kaminari::PaginatableArray.new(self).per(num)
          end
        end
      end
    end
  end
end
