require 'ZenWeb/GenericRenderer'

# Hands content off to the RedCloth text formatter for rendering.
#
# + Set Attributes in the 'RedClothAttributes' metadata.
#     + filter_html   -- HTML not created by RedCloth is escaped
#     + filter_styles -- style markup specifier is disabled
# + See http://www.whytheluckystiff.net/ruby/redcloth/
class RedClothRenderer < GenericRenderer
  require 'redcloth'
  
  def render(content)
    attributes = []
    if @document.metadata.has_key?('RedClothAttributes')
      attributes = @document['RedClothAttributes']
    end
    rc = RedCloth::new(content, attributes)
    return rc.to_html(:textile)
  end
end
