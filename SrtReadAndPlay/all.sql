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
CREATE TEMP TABLE label (
  uniqid TEXT,
  rowIndex INTEGER,
  beginLabel TEXT,
  endLabel TEXT,
  textLabel TEXT
);

CREATE UNIQUE INDEX uniqid ON label (uniqid);
CREATE UNIQUE INDEX rowIndex ON label (rowIndex);

--:select_first_value
SELECT #{id} FROM label
WHERE rowIndex = :index

--:select_master_with_order
SELECT * FROM master
ORDER BY #{order}

--:insert_into_master
INSERT INTO master
VALUES (:uniqid, :seq, :btime, :etime, :caption);

--:get_uniqid_from_label
SELECT uniqid FROM label WHERE rowIndex = ?

--:get_times_from_master_by_uniqid
SELECT begin_time, end_time FROM master WHERE uniqid = ?