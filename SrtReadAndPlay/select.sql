--
--  select.sql
--


--:row_from_label
SELECT * FROM label WHERE rowIndex = :index;

--:count_from_label
SELECT count(uniqid) FROM label;

--:uniqid_from_label
SELECT uniqid FROM label WHERE rowIndex = ?;

--:times_from_master_by_uniqid
SELECT begin_time, end_time FROM master WHERE uniqid = ?;
