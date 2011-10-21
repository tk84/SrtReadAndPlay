# -*- coding: utf-8 -*-
#
#  Timeline.rb
#  SrtReadAndPlay
#
#  Created by Hiroyuki Takahashi on 11/10/21.
#  Copyright 2011年 __MyCompanyName__. All rights reserved.
#


class TimelineController
  def tableView aTableView, objectValueForTableColumn:aTableColumn, row:rowIndex
    #puts "#{aTableColumn.identifier} #{rowIndex}"
    'monday'
  end

  def numberOfRowsInTableView aTableView
    puts 'pee'
    10
  end
end

class TimelineModel
  def init
    if super
      p 'super'
    end
  end
end
