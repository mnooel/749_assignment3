-- BUS-ADM 749 Data and Information Management
-- Michael Noel
-- Continental Palms DVD
-- check_in_out.sql


-- check some copies out.
BEGIN CHECKOUT('D00001',1,'M000000001'); END;
BEGIN CHECKOUT('D00002',3,'M000000002'); END;
COMMIT;

BEGIn CHECKIN(100000, 'WI02'); END;
BEGIN CHECKIN(100001, 'WI01'); END;
COMMIT;

