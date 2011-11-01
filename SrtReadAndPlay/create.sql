--
--  create.sql
--


--:master
CREATE TABLE master (
  uniqid TEXT,
  sequence INTEGER,
  begin_time REAL,
  end_time REAL,
  caption TEXT
);

CREATE UNIQUE INDEX uniqid ON master (uniqid);
CREATE UNIQUE INDEX time ON master (begin_time, end_time);

--:label
CREATE TEMPORARY TABLE label (
  uniqid TEXT,
  rowIndex INTEGER PRIMARY KEY AUTOINCREMENT,
  beginLabel TEXT,
  endLabel TEXT,
  textLabel TEXT
);

CREATE UNIQUE INDEX uniqid ON label (uniqid);
CREATE UNIQUE INDEX rowIndex ON label (rowIndex);
