-- BUS-ADM 749 Data and Information Management
-- Michael Noel
-- Continental Palms DVD
-- queries.sql

-- Get the address of every branch
-- QUERY 1
SELECT street, city, state, ZIP
FROM BRANCH;

-- Get the street address of every branch in Milwaukee
-- QUERY 2
SELECT STREET
FROM BRANCH
WHERE CITY = 'Milwaukee';

-- Get the title of every DVD directed by Tom Hanks
-- QUERY 3
SELECT TITLE
FROM DVD
WHERE CATALOGNO IN (
    SELECT CATALOGNO
    FROM MAKES
    WHERE STAGENAME = 'Tom Hanks'
    AND ROLE = 'director'
    );

-- Find which DVDs directed by Tom Hanks are currently available in a branch in Milwaukee.
-- Get the title of every such DVD and the street address of the branch that currently has it.
-- TODO QUERY 4

-- Find which DVDs directed by Tom Hanks are currently available with multiple (more than one) copies in a branch in Milwaukee.
-- Get the title and number of copies of every such DVD and the street address of the branch that currently has it.
-- TODO QUERY 5

-- Find which DVDs directed by Tom Hanks are currently NOT available in any branch in Milwaukee but are available somewhere else.
-- Get the title of every such DVD and the address of the branch that currently has it.
-- TODO QUERY 6

-- Find which DVDs directed by Tom Hanks are currently available in ALL branches in Milwaukee.
-- Get the title of every such. (Hint: This query involves the Division operation in relational algebra, but is notoriously difficult to write in SQL.
-- Consider using sub-queries. Restate the query as “Find every DVD directed by Tom Hanks, such that there does NOT exist a branch in Milwaukee that does NOT stock it”).
-- TODO QUERY 7

-- List the first name, last name, and DOB of each staff member.
-- QUERY 8
SELECT
       FIRSTNAME,
       LASTNAME,
       DOB
FROM STAFF;

-- List the name and age of each staff member.
-- QUERY 9
SELECT
       FIRSTNAME||' '||LASTNAME AS NAME,
       FLOOR (MONTHS_BETWEEN(SYSDATE, DOB) / 12) AS AGE
FROM STAFF;

-- List the name and age of each staff member.
-- If he/her has a supervisor, also list the name of his/her supervisor.
-- QUERY 10
SELECT
       S.FIRSTNAME||' '||S.LASTNAME AS NAME,
       FLOOR (MONTHS_BETWEEN(SYSDATE, S.DOB) / 12) AS AGE,
       SUP.SUPERVISOR
FROM
     STAFF S LEFT OUTER JOIN (SELECT STAFFNO, FIRSTNAME||' '||LASTNAME AS SUPERVISOR FROM STAFF) SUP
         ON SUP.STAFFNO = S.SUPERVISOR;