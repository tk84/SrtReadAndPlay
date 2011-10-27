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

