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

  def finalize
    super
    p 'TimelineController finalize'
  end

  def tableView aTableView, objectValueForTableColumn:aTableColumn, row:rowIndex
    @model.field aTableColumn.identifier, rowIndex
  end

  def numberOfRowsInTableView aTableView
    @model.count
  end

  def selectRow sender
    selectCallback.call @model.region sender if selectCallback
  end
end

class TimelineModel
  def initialize records

    @db = SQLite3Connection.new
    @db.initWithPath ':memory:', flags:KSQLite3OpenCreate | KSQLite3OpenReadWrite

    @db.create_function 'oneline' do |text|
      text.
        # gsub(/(<[^>]*>|\s)/, ' ').
        gsub(/\s+/, ' ').
        gsub(/(^\s|\s$)/, '')
    end

    @db.create_function 'ftime_to_srtime' do |ftime|
      h = ftime / 3600
      ftime %= 3600
      m = ftime / 60
      ftime %= 60
      s = ftime
      ftime -= ftime.truncate

      '%02d:%02d:%02d,%03d' % [h,m,s,(ftime*1000)]
    end

    # 外部データ読み込み
    @ext = Tk84::Extsource.new
    @ext.parser:sql, Tk84::Parser::Sql
    @ext.source:sql, :select, "#{File.dirname(__FILE__)}/select.sql"
    @ext.source:sql, :create, "#{File.dirname(__FILE__)}/create.sql"
    @ext.soruce:sql, :insert, "#{File.dirname(__FILE__)}/insert.sql"


    # 本データテーブル
    @db.execute @ext.sql:create,:master

    records.each do |record|
      record[:uniqid] = Tk84::MyFunction.uniqid

      # ハッシュキーをシンボルから文字列に変換
      record.each_pair {|key,value| record[key.to_s] = record.delete key if key.is_a? Symbol }

      @db.execute(@ext.sql(:insert,:master),
          withDictionaryBindings:record)
    end

    # 表示用データテーブル
    @db.execute @ext.sql:create,:label
    refresh_tmp_table 0

  end

  def finalize
    super
    @db.close if @db
  end

  def field id, index
    index += 1

    if @label_index != index
      @label_index = index
      @label_stmt =
        @db.query @ext.sql(:all,:select_label_row), 'index'=>@label_index
      @label_stmt.step
    end

    @label_stmt.objectWithColumnName(id)
  end

  def count
    @db.get_first_value @ext.sql:all,:select_label_count
  end

  def refresh_tmp_table order_param
    @db.execute @ext.sql:insert,:label_from_master
  end

  # 選択されている行から最も小さい最初時間と最も大きい最後時間を抽出
  def region tableView
    min_btime = Float::MAX
    max_etime = 0
    tableView.selectedRowIndexes.
      enumerateIndexesUsingBlock Proc.new {|idx, stop|

      btime, etime = @db.get_first_row @ext.sql(:all,:get_times_from_master_by_uniqid),
      @db.get_first_value(@ext.sql(:all,:get_uniqid_from_label), idx)

      min_btime = btime if min_btime > btime
      max_etime = etime if max_etime < etime
    }

    [min_btime, max_etime]
  end

  def self.makeModel url
    model = false
    ext = Tk84::Extsource.new
    ext.parser:srt, Tk84::Parser::Srt
    ext.source:srt,:srt,url
    records = ext.srt:srt
    model = self.new records if records.count
    model
  end
end

