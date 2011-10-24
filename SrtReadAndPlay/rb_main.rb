# -*- coding: utf-8 -*-
#
#  rb_main.rb
#  SrtReadAndPlay
#
#  Created by Hiroyuki Takahashi on 11/10/21.
#  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
#

# Loading the Cocoa framework. If you need to load more frameworks, you can
# do that here too.
framework 'Cocoa'

# Loading all the Ruby project files.
main = File.basename(__FILE__, File.extname(__FILE__))
dir_path = NSBundle.mainBundle.resourcePath.fileSystemRepresentation
# Dir.glob(File.join(dir_path, '*.{rb,rbo}')).map { |x| File.basename(x, File.extname(x)) }.uniq.each do |path|
#   if path != main
#     require(path)
#   end
# end

require 'AppDelegate'
require 'Timeline'
require 'Media'
require 'MyFunction'
require 'nkf'
require 'sqlite3'


# Starting the Cocoa main loop.
NSApplicationMain(0, nil)
