require 'command/base'

require 'command/text'
require 'command/value'
require 'command/comment'

require 'command/define'
require 'command/include'

require 'command/block'
require 'command/stackable'
require 'command/case'
require 'command/filter'
require 'command/if'
require 'command/loop'

require 'command/unknown'

# TODO: Add Modifiable and Closable (included by Stackable, ...?)
# TODO: Should certain classes like Block and Stackable inherit from Array or maybe
#       include Addable or something?
# TODO: Rename Stackable to Stacking