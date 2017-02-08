module HammerCLIForeman
  module ComputeResources
    module Default
      class ComputeAttributes
        def name
          'default'
        end

        def fields(dsl)
          dsl.build do
            field :text_attributes, _('Attributes'), Fields::LongText
            collection :nics_attributes, _("Network interfaces"), :hide_blank => true do
              field :text_attributes, _('Attributes'), Fields::LongText
            end
            collection :volumes_attributes, _("Volumes"), :hide_blank => true do
              field :text_attributes, _('Attributes'), Fields::LongText
            end
          end
        end

        def transform_attributes(attrs)
          attrs['text_attributes'] = to_text(attrs.reject{ |k| ['nics_attributes', 'volumes_attributes'].include? k })
          attrs['nics_attributes'] = add_text_attributes(attrs['nics_attributes'])
          attrs['volumes_attributes'] = add_text_attributes(attrs['volumes_attributes'])
          attrs
        end

        protected

        def add_text_attributes(attribute_hash)
          return unless attribute_hash
          attribute_hash.values.map do |attr|
            attr['text_attributes'] = to_text(attr)
            attr
          end
        end

        def to_text(data)
          data.to_yaml.gsub(/^---$/, '').strip
        end
      end
    end
  end
end
