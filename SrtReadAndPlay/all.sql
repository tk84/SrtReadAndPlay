--:create_master
CREATE TABLE master (
  uniqid TEXT,
  sequence INTEGER,
  begin_time REAL,
  end_time REAL,
  caption TEXT
);

CREATE UNIQUE INDEX uniqid ON master (uniqid);
CREATE UNIQUE INDEX time ON master (begin_time, end_time);

--:create_label
CREATE TEMPORARY TABLE label (
  uniqid TEXT,
  rowIndex INTEGER PRIMARY KEY AUTOINCREMENT,
  beginLabel TEXT,
  endLabel TEXT,
  textLabel TEXT
);

CREATE UNIQUE INDEX uniqid ON label (uniqid);
CREATE UNIQUE INDEX rowIndex ON label (rowIndex);

--:insert_label_from_master
INSERT INTO label (uniqid, beginLabel, endLabel, textLabel)
SELECT
  uniqid,
  -- begin_time AS beginLabel,
  -- end_time AS endLabel,
  -- caption AS textLabel
  ftime_to_srtime(begin_time) AS beginLabel,
  ftime_to_srtime(end_time) AS endLabel,
  oneline(caption) AS textLabel
FROM master
;

--:table_view
SELECT
  -- ftime_to_srtime(begin_time) AS beginLabel,
  -- ftime_to_srtime(end_time) AS endLabel,
  oneline(caption) AS textLabel
FROM master
;

--:column_beginLabel
SELECT ftime_to_srtime(begin_time) AS beginLabel FROM master
WHERE sequence = :index
--:column_endLabel
SELECT ftime_to_srtime(end_time) AS endLabel FROM master
WHERE sequence = :index
--:column_textLabel
SELECT oneline(caption) AS textLabel FROM master
WHERE sequence = :index

--:select_label_row
SELECT * FROM label WHERE rowIndex = :index;




--:select_all_from_master
SELECT * FROM master

--:order_sequence_desc
ORDER BY sequence DESC
--:order_random
ORDER BY RANDOM()
--:order_sequence_asc
ORDER BY sequence ASC

--:insert_into_master
INSERT INTO master
VALUES (:uniqid, :seq, :btime, :etime, :caption);

--:insert_into_label
INSERT INTO label VALUES (?, ?, ?, ?, ?);

--:get_uniqid_from_label
SELECT uniqid FROM label WHERE rowIndex = ?;

--:get_times_from_master_by_uniqid
SELECT begin_time, end_time FROM master WHERE uniqid = ?;

--:test
SELECT ftime_to_srtime(begin_time) FROM master LIMIT 10;

--:test1

SELECT oneline(caption) FROM master LIMIT 10;

--:count_rows
SELECT count(uniqid) FROM label;

--:number_of_rows
SELECT count(*) FROM master;
