# -*- coding: utf-8 -*-
#
#  Timeline.rb
#  SrtReadAndPlay
#
#  Created by Hiroyuki Takahashi on 11/10/21.
#  Copyright 2011年 __MyCompanyName__. All rights reserved.
#

class TimelineController < NSViewController
  attr_accessor :model

  def tableView aTableView, objectValueForTableColumn:aTableColumn, row:rowIndex
    #puts "#{aTableColumn.identifier} #{rowIndex}"
    #'monday'
    @model.getOne aTableColumn.identifier, rowIndex
  end

  def numberOfRowsInTableView aTableView
    @model.numberOfRows
  end
end

class TimelineModel
  def initialize table
    @table = table
  end

  def self.makeModel url
    model = false

    if FileTest.file? url.path and FileTest.readable? url.path
      File.open url.path, 'r' do |file|
        table = {btime:[], etime:[], text:[], bmsec:[], emsec:[]}
        section = ''

        file.each_line do |line|
          if line =~ /^(\r\n|\n)/ then
            if section =~ /(?:^|\r?\n)(\d+)\r?\n(\d{2}:\d{2}:\d{2}),(\d{3}) --> (\d{2}:\d{2}:\d{2}),(\d{3})\r?\n(.*)/m then
              # seq:Regexp.last_match(1),
              table[:btime].push(Regexp.last_match(2) + ','  + Regexp.last_match(3))
              table[:etime].push(Regexp.last_match(4) + ','  + Regexp.last_match(5))
              table[:text].push Regexp.last_match(6).chomp
              table[:bmsec].push Regexp.last_match(3)
              table[:emsec].push Regexp.last_match(5)
            end
            section = ''
          else
            section << line
          end
        end

        model = self.new table ? table[:emsec].count >= 1
      end
    end

    model
  end

  def getOne hash, index
    @table[hash.to_sym][index]
  end

  def numberOfRows
    @table[:text].count
  end
end

