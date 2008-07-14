require 'ZenWeb/GenericRenderer'

class PageNavRenderer < GenericRenderer
  def render(content)
    # I know there's a quicker way to do this, but I'm in a hurry.
    this_url = @document.url
    doc_order = @sitemap.doc_order
    this_index = doc_order.index(this_url)
    forward = backward = " "

    last_url = doc_order[this_index - 1]
    last_page = @sitemap.documents[last_url]
    if last_page and File.dirname(last_url) == File.dirname(this_url)
      title = last_page.title
      url = File.basename(last_url)
      backward = "<p>&lt;- <a href='#{url}'>#{title}</a></p>\n"
    end

    next_url = doc_order[this_index + 1]
    next_page = @sitemap.documents[next_url]
    if next_page and File.dirname(next_url) == File.dirname(this_url)
      title = next_page.title
      url = File.basename(next_url)
      forward = "<p><a href='#{url}'>#{title}</a>- &gt;</p>\n"
    end

    push("<table width='100%' border='0'><tr>\n")
    push("<td>#{backward}</td>\n")
    push("<td align='right'>#{forward}</td>\n")
    push("</tr></table>\n")

    push(content)

    return self.result
  end
end

