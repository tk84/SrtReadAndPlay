--:master
INSERT INTO master
VALUES (:uniqid, :seq, :btime, :etime, :caption);


--:label_from_master
INSERT INTO label (uniqid, beginLabel, endLabel, textLabel)
SELECT
  uniqid,
  ftime_to_srtime(begin_time) AS beginLabel,
  ftime_to_srtime(end_time) AS endLabel,
  oneline(caption) AS textLabel
FROM master
;

