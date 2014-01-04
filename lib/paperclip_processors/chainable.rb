#
# Chainable.rb
#
# Allows you to chain Paperclip styles.
# Created by Ed McManus for Yardsale Inc. on 5/12/2012
# 
#
# *********************************************************************
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
#
# Example - Optimized processing pipeline
# *********************************************************************
#
#  Copy to #{Rails.root}/lib/paperclip_processors/
#  Use OrderedHash prior to MRI 1.9.
#
#  has_attached_file :image,
#    :styles => {
#      :large => {
#        :geometry => "1000x1000^",
#        :format => :jpg,
#      },
#      :medium => {
#        :geometry => "640x640^",
#        :format => :jpg,
#        :chain_to => :large,
#        :processors => [:chainable, :thumbnail],
#      }
#      :small => {
#        :geometry => "160x160^",
#        :format => :jpg,
#        :chain_to => :medium,
#        :processors => [:chainable, :thumbnail],
#      }
#   }
#

# Chainable is a dummy processor that replaces the chain's accumulator value
# with the output of another style.
module Paperclip
  class Chainable < Processor
    def initialize file, options = {}, attachment = nil
      super attachment.queued_for_write.fetch(options[:chain_to], file), options, attachment
    end
    def make
      @file
    end
  end
end
