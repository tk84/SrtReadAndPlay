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
  attr_accessor :selectCallback

  def awakeFromNib
  end

  def tableView aTableView, objectValueForTableColumn:aTableColumn, row:rowIndex
    @model.getOne aTableColumn.identifier, rowIndex
  end

  def numberOfRowsInTableView aTableView
    @model.numberOfRows
  end

  def selectRow sender
    selectCallback.call @model.region sender.selectedRow if selectCallback
  end
end

class TimelineModel
  def initialize table
    @table = table
  end

  def region index
    [@table[:btime][index], @table[:etime][index]]
  end

  def self.makeModel url
    model = false

    if FileTest.file? url.path and FileTest.readable? url.path
      File.open url.path, 'r' do |file|
        table = {btime:[], etime:[], text:[], bmsec:[], emsec:[],
          beginLabel:[], endLabel:[], textLabel:[], seq:[]}
        section = ''

        file.each_line do |line|
          if line =~ /^(\r\n|\n)/ then
            if section =~ /(?:^|\r?\n)(\d+)\r?\n(\d{2}):(\d{2}):(\d{2}),(\d{3}) --> (\d{2}):(\d{2}):(\d{2}),(\d{3})\r?\n(.*)/m then
              table[:seq].push Regexp.last_match 1
              table[:btime].push (
                            (Regexp.last_match(2).to_f * 60 * 60) +
                            (Regexp.last_match(3).to_f * 60) +
                            (Regexp.last_match(4).to_f * 1) +
                            (Regexp.last_match(5).to_f / 1000))
              table[:etime].push (
                            (Regexp.last_match(6).to_f * 60 * 60) +
                            (Regexp.last_match(7).to_f * 60) +
                            (Regexp.last_match(8).to_f * 1) +
                            (Regexp.last_match(9).to_f / 1000))
              table[:textLabel].push Regexp.last_match(10).chomp
              table[:beginLabel].push (
                            Regexp.last_match(2) + ':' +
                            Regexp.last_match(3) + ':' +
                            Regexp.last_match(4) + '.' +
                            Regexp.last_match(5))
              table[:endLabel].push (
                            Regexp.last_match(6) + ':' +
                            Regexp.last_match(7) + ':' +
                            Regexp.last_match(8) + '.' +
                            Regexp.last_match(9))
            end
            section = ''
          else
            section << line
          end
        end

        model = self.new table if table[:textLabel].count >= 1
      end
    end

    model
  end

  def getOne hash, index
    @table[hash.to_sym][index]
  end

  def numberOfRows
    @table.fetch(@table.keys.first, []).count
  end
end

