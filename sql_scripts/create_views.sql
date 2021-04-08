-- BUS-ADM 749 Data and Information Management
-- Michael Noel
-- Continental Palms DVD
-- create_views.sql

-- Create DVDCopyLocation VIEW
CREATE OR REPLACE VIEW DVDCopyLocation AS
SELECT
    D.TITLE,
    C.CATALOGNO,
    C.COPYNO,
    C.CONDITION,
    B.BRANCHNO,
    B.STREET,
    B.CITY,
    B.STATE,
    B.ZIP
FROM DVDCOPY C, BRANCH B, DVD D
WHERE C.BRANCHNO = B.BRANCHNO
AND D.CATALOGNO = C.CATALOGNO;
