this_dir = File.dirname(__FILE__)

require this_dir+'/command/base'

require this_dir+'/command/text'
require this_dir+'/command/value'
require this_dir+'/command/comment'

require this_dir+'/command/define'
require this_dir+'/command/include'

require this_dir+'/command/block'
require this_dir+'/command/stackable'
require this_dir+'/command/case'
require this_dir+'/command/filter'
require this_dir+'/command/if'
require this_dir+'/command/loop'

require this_dir+'/command/unknown'