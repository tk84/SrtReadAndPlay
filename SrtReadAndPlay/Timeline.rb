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

  def release
    view = nil
    @model = nil
    @selectCallback = nil
  end

  def finalize
    super
    p 'TimelineController finalize'
  end

  def tableView aTableView, objectValueForTableColumn:aTableColumn, row:rowIndex
#    @model.getOne aTableColumn.identifier, rowIndex
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
#    @table = table

    @dbFile = NSTemporaryDirectory() + MyFunction.uniqid + '.db'
    @db = SQLite3::Database.new(@dbFile)
    p @dbFile

    create_table

    records.each do |record|
      record[:uniqid] = MyFunction.uniqid
      insert_into record
    end

    create_temp_table
    refresh_tmp_table
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

  def one id, index
    row(index).fetch(id.to_s, 'unknown')
  end

  def row index
    columns, row, *kipple = @db.execute2 <<'EOF', index:index
SELECT
  begin_time AS btime,
  end_time AS etime,
  caption
FROM master
LIMIT :index, 1
EOF

# #    puts "index:#{index}, columns:#{columns}, rows:#{rows}"
     Hash[*[columns,row].transpose.flatten(1)]
  end

  def count
    @db.get_first_value <<'EOF'
SELECT count(sequence) FROM master;
EOF
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
    @db.execute <<'EOF'
CREATE TEMP TABLE label (
  uniqid TEXT,
  rowIndex INTEGER,
  beginLabel TEXT,
  endLabel TEXT,
  textLabel TEXT
);
EOF
  end

  def refresh_tmp_table
    order = 'sequence ASC'      # (sequence DESC|RANDOM())

    master = @db.query(<<'EOF', order:order)
SELECT * FROM master
ORDER BY :order
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

      @db.execute(<<'EOF', data)
INSERT INTO label VALUES (?, ?, ?, ?, ?);
EOF
    end
  end

  def insert_into record
    @db.execute <<'EOF', record
INSERT INTO master VALUES (:uniqid, :seq, :btime, :etime, :caption);
EOF
  end

  def region tableView
    indexSet = tableView.selectedRowIndexes
    [one(:btime, indexSet.firstIndex), one(:etime, indexSet.lastIndex)]

#    [@table[:btime][indexSet.firstIndex], @table[:etime][indexSet.lastIndex]]
  end

  def self.makeModel url
    model = false

    if FileTest.file? url.path and FileTest.readable? url.path
      File.open url.path, 'r' do |file|
        # table = {btime:[], etime:[], text:[], bmsec:[], emsec:[],
        #   beginLabel:[], endLabel:[], textLabel:[], seq:[]}
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

  #             table[:btime].
  #               push((Regexp.last_match(2).to_f * 60 * 60) +
  #               (Regexp.last_match(3).to_f * 60) +
  #               (Regexp.last_match(4).to_f * 1) +
  #               (Regexp.last_match(5).to_f / 1000))
  #             table[:etime].
  #               push((Regexp.last_match(6).to_f * 60 * 60) +
  #               (Regexp.last_match(7).to_f * 60) +
  #               (Regexp.last_match(8).to_f * 1) +
  #               (Regexp.last_match(9).to_f / 1000))
  #             table[:beginLabel].
  #               push(Regexp.last_match(2) + ':' +
  #               Regexp.last_match(3) + ':' +
  #               Regexp.last_match(4) + '.' +
  #               Regexp.last_match(5))
  #             table[:endLabel].
  #               push(Regexp.last_match(6) + ':' +
  #               Regexp.last_match(7) + ':' +
  #               Regexp.last_match(8) + '.' +
  #               Regexp.last_match(9))
  #             table[:textLabel].
  #               push(Regexp.last_match(10).chomp.
  # #gsub(/(<[^>]*>|\s)/, ' ').
  #               gsub(/\s+/, ' ').
  #               gsub(/(^\s|\s$)/, ''))
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

