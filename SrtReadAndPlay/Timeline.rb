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
#    @model.label aTableColumn.identifier, rowIndex
    @model.tableView aTableColumn.identifier, rowIndex
  end

  def numberOfRowsInTableView aTableView
#    @model.count
    @model.numberOfRowsInTableView
  end

  def selectRow sender
    selectCallback.call @model.region sender if selectCallback
  end
end

class TimelineModel
  def initialize records
    @db = SQLite3::Database.new(':memory:')

    # dbfunc
    @db.create_function 'ftime_to_srtime', 1 do |func, ftime|
      h = ftime / 3600
      ftime %= 3600
      m = ftime / 60
      ftime %= 60
      s = ftime
      ftime -= ftime.truncate

      func.result = '%02d:%02d:%02d,%03d' % [h,m,s,(ftime*1000)]
    end

    # dbfunc
    @db.create_function 'oneline', 1 do |func, text|
      newtext = text.
        # gsub(/(<[^>]*>|\s)/, ' ').
        gsub(/\s+/, ' ').
        gsub(/(^\s|\s$)/, '')

      func.result = newtext
    end

    @ext = Tk84::Extsource.instance
    @ext.parser:sql, Tk84::Extsource::Sql
    @ext.source:sql, :all, File.dirname(__FILE__)+'/all.sql'


    # 本データテーブル
    @db.execute @ext.sql:all,:create_master

    records.each do |record|
      record[:uniqid] = Tk84::MyFunction.uniqid
      @db.execute @ext.sql(:all,:insert_into_master), record
    end

    # 表示用データテーブル
    @db.execute @ext.sql:all,:create_label
    refresh_tmp_table 0

  end

  def finalize
    super
    @db.close if @db
  end

  def time_format ftime
    h = ftime / 3600
    ftime %= 3600
    m = ftime / 60
    ftime %= 60
    s = ftime
    ftime -= ftime.truncate

    '%02d:%02d:%02d,%03d' % [h,m,s,(ftime*1000)]
  end

  def label id, index
    p "label referenced #{Time.now}"
    @db.get_first_value @ext.sql(:all,:select_first_value,id:id), index:index
  end

  def count
    @db.get_first_value @ext.sql:all,:count_rows
  end

  def tableView id, index
    if not @tableViewResult or @tableViewResult.closed?
      @tableViewResult = @db.query @ext.sql:all,:table_view
      @tableViewIndex = 0
    end

    puts "index:#{index},@tableViewIndex:#{@tableViewIndex}"

    if index < @tableViewIndex
      @tableViewResult.reset
      @tableViewIndex = 0
    end

    if index > @tableViewIndex
      (index - @tableViewIndex).times do |i|
        @tableViewResult.next
      end
    end

    @tableViewIndex = index + 1

    @db.results_as_hash = true
    result = @tableViewResult.first
    @db.results_as_hash = false

    p result

    result[id]
  end

  def numberOfRowsInTableView
    if not @numberOfRowsResult or @numberOfRowsResult.closed?
      p 'numberOfRowsInTableView create'
      @numberOfRowsResult = @db.query @ext.sql:all,:number_of_rows
    else
      p 'numberOfRowsInTableView still open'
      @numberOfRowsResult.reset
    end

    @numberOfRowsResult.first.first
  end

  def refresh_tmp_table order_param
    master = @db.query(
                 @ext.sql(:all,:select_all_from_master) +
                 case order_param
                 when 1 then @ext.sql:all,order_sequence_desc
                 when 2 then @ext.sql:all,order_random
                 else @ext.sql:all,:order_sequence_asc
                 end)

    uniqid = 0;
    btime = 2;
    etime = 3;
    caption = 4;

    rowIndex = 0
    master.each do |row|
      data = []
      data << row[uniqid]
      data << rowIndex
      rowIndex += 1
      data << time_format(row[btime])
      data << time_format(row[etime])
      data << row[caption].
        # gsub(/(<[^>]*>|\s)/, ' ').
        gsub(/\s+/, ' ').
        gsub(/(^\s|\s$)/, '')

      @db.execute @ext.sql(:all,:insert_into_label), data
    end
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

    if FileTest.file? url.path and FileTest.readable? url.path
      File.open url.path, 'r' do |file|
        records = []
        section = ''

        file.each_line do |line|
          line = NKF.nkf('--utf8', line)

          # ファイル終端の処理
          if file.eof?
            section << line
            line = "\n"
          end

          if line =~ /^(\r\n|\n)/ then
            if section =~ /(?:^|\r?\n)(\d+)\r?\n(\d{2}):(\d{2}):(\d{2}),(\d{3}) --> (\d{2}):(\d{2}):(\d{2}),(\d{3})\r?\n(.*)/m then
              records << {
                seq:Regexp.last_match(1).to_i,
                btime:((Regexp.last_match(2).to_f * 60 * 60) +
                  (Regexp.last_match(3).to_f * 60) +
                  (Regexp.last_match(4).to_f * 1) +
                  (Regexp.last_match(5).to_f / 1000)),
                etime:((Regexp.last_match(6).to_f * 60 * 60) +
                  (Regexp.last_match(7).to_f * 60) +
                  (Regexp.last_match(8).to_f * 1) +
                  (Regexp.last_match(9).to_f / 1000)),
                caption:Regexp.last_match(10).chomp
              }
            end
            section = ''
          else
            section << line
          end
        end

        model = self.new records if records.count
      end
    end

    model
  end
end

