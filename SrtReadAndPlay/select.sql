
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


--:insert_into_label
INSERT INTO label VALUES (?, ?, ?, ?, ?);

--:get_uniqid_from_label
SELECT uniqid FROM label WHERE rowIndex = ?;

--:get_times_from_master_by_uniqid
SELECT begin_time, end_time FROM master WHERE uniqid = ?;

--:select_label_count
SELECT count(uniqid) FROM label;

