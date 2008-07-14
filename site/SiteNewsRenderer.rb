require 'ZenWeb/GenericRenderer'

class SiteNewsRenderer < GenericRenderer
  require 'yaml'

  def render(content)
    newsfile = 'news.yml'
    newsitems = YAML.load(File.open(newsfile).read())
    limit = @document['NewsLimit']

    if newsitems
      newsitems.each do |item|
        push("\n<div class='newsitem'>\n\nh3. #{item['title']}\n\np(date). #{item['date']}\n\n#{item['content']}\n</div>\n")
        if limit
          limit -= 1
          break if limit == 0
        end
      end
    end

    return self.result
  end
end
