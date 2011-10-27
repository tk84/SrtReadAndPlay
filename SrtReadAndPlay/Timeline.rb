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
    @model.label aTableColumn.identifier, rowIndex
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
    @dbFile = NSTemporaryDirectory() + Tk84::MyFunction.uniqid + '.db'
    #    @db = SQLite3::Database.new(@dbFile)
    @db = SQLite3::Database.new(':memory:')
    p @dbFile


    # 本データテーブル
    create_table
    records.each do |record|
      record[:uniqid] = Tk84::MyFunction.uniqid
      insert_into record
    end

    # 表示用データテーブル
    create_temp_table
    refresh_tmp_table 0
  end

  def finalize
    super
    @db.close if @db
    File.delete @dbFile if @dbFile
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
    @db.get_first_value(<<"EOF",  index:index)
SELECT #{id} FROM label
WHERE rowIndex = :index
EOF
  end

  def count
    @db.get_first_value 'SELECT count(uniqid) FROM label;'
  end

  def create_table
    @db.execute_batch <<'EOF'
CREATE TABLE master (
  uniqid TEXT,
  sequence INTEGER,
  begin_time REAL,
  end_time REAL,
  caption TEXT
);

CREATE UNIQUE INDEX uniqid ON master (uniqid);
CREATE UNIQUE INDEX time ON master (begin_time, end_time);
EOF
  end

  def create_temp_table
    @db.execute_batch <<'EOF'
CREATE TEMP TABLE label (
  uniqid TEXT,
  rowIndex INTEGER,
  beginLabel TEXT,
  endLabel TEXT,
  textLabel TEXT
);

CREATE UNIQUE INDEX uniqid ON label (uniqid);
CREATE UNIQUE INDEX rowIndex ON label (rowIndex);
EOF
  end

  def refresh_tmp_table order_param
    order =
      case order_param
      when 1 then 'sequence DESC'
      when 2 then 'RANDOM()'
      else 'sequence ASC'
      end

    master = @db.query <<"EOF"
SELECT * FROM master
ORDER BY #{order}
EOF

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

      @db.execute 'INSERT INTO label VALUES (?, ?, ?, ?, ?);', data
    end
  end

  def get_uniqid_from_label rowIndex
    @db.get_first_value 'SELECT uniqid FROM label WHERE rowIndex = ?', rowIndex
  end

  def get_times_from_master_by_uniqid uniqid
    @db.get_first_row 'SELECT begin_time, end_time FROM master WHERE uniqid = ?', uniqid
  end

  def insert_into record
    @db.execute <<'EOF', record
INSERT INTO master VALUES (:uniqid, :seq, :btime, :etime, :caption);
EOF
  end

  # 選択されている行から最も小さい最初時間と最も大きい最後時間を抽出
  def region tableView
    min_btime = Float::MAX
    max_etime = 0
    tableView.selectedRowIndexes.
      enumerateIndexesUsingBlock Proc.new {|idx, stop|
      btime, etime = get_times_from_master_by_uniqid(get_uniqid_from_label(idx))
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

