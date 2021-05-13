-- BUS-ADM 749 Data and Information Management
-- Michael Noel
-- Continental Palms DVD
-- assignment 6


-- DROP TABLES

DROP TABLE Branch CASCADE CONSTRAINTS PURGE;
DROP TABLE DVD CASCADE CONSTRAINTS PURGE;
DROP TABLE Rental CASCADE CONSTRAINTS PURGE;


-- CREATE TABLES

-- Create Branch table
CREATE TABLE Branch
(
    branchNo CHAR(4),
    street   VARCHAR2(25) NOT NULL,
    city     VARCHAR2(15) NOT NULL,
    state    CHAR(2)     NOT NULL,
    zip      VARCHAR2(5)  NOT NULL,
    CONSTRAINT Branch_states CHECK (state IN
                                    ('MA', 'RI', 'NH', 'ME', 'VT', 'CT', 'NY', 'NJ', 'PA', 'DE', 'DC', 'VA', 'MD', 'WV',
                                     'NC', 'SC', 'GA', 'FL', 'AL', 'TN', 'MS', 'KY', 'OH', 'IN', 'MI', 'IA', 'WI', 'MN',
                                     'SD', 'ND', 'MT', 'IL', 'MO', 'KS', 'NE', 'LA', 'AR', 'OK', 'TX', 'CO', 'WY', 'ID',
                                     'UT', 'AZ', 'NM', 'NV', 'CA', 'HI', 'OR', 'WA', 'AK')),
    CONSTRAINT Branch_PK PRIMARY KEY (branchNo),
    CONSTRAINT Branch_branchNo_c1 CHECK (branchNo LIKE CONCAT(state, '__')),
    CONSTRAINT Branch_branchNo_c2 CHECK (REGEXP_LIKE(branchNo, '[A-Z]{2}\d{2}')),
    CONSTRAINT Branch_zip_c CHECK (REGEXP_LIKE(zip, '\d{4,5}'))
);

-- Create DVD Table
CREATE TABLE DVD
(
    catalogNo CHAR(6),
    title     VARCHAR2(50) NOT NULL,
    category  VARCHAR2(15) NOT NULL,
    dailyRent FLOAT       NOT NULL,
    CONSTRAINT DVD_PK PRIMARY KEY (catalogNo),
    CONSTRAINT DVD_category_c CHECK (category IN ('action', 'children', 'drama', 'horror', 'tv series', 'sci-fi')),
    CONSTRAINT DVD_dailyRent_c CHECK (dailyRent >= 0.0),
    CONSTRAINT DVD_catalogNo_c CHECK (REGEXP_LIKE(catalogNo, 'D\d{5}'))
);


-- Create Rental Table
CREATE TABLE Rental
(
    branchNo    CHAR(4)     NOT NULL,
    catalogNo   CHAR(6)     NOT NULL,
    yearMonth   CHAR(7)     NOT NULL,
    days        INTEGER     NOT NULL,
    CONSTRAINT  Rental_PK   PRIMARY KEY (branchNo, catalogNo, yearMonth),
    CONSTRAINT  Rental_branchNo_FK  FOREIGN KEY (branchNo) REFERENCES Branch (branchNo),
    CONSTRAINT  Rental_catalogNo_FK  FOREIGN KEY (catalogNo) REFERENCES DVD (catalogNo),
    CONSTRAINT Rental_yearMonth_c1  CHECK (REGEXP_LIKE(yearMonth, '\d{4}-\d{2}')),
    CONSTRAINT  Rental_days_c1  CHECK (days > 0)
);


-- INSERT DATA

-- Insert Branch data
INSERT INTO Branch (branchNo, street, city, state, zip) VALUES ('WI01', '100 E Capital Dr', 'Milwaukee', 'WI', 53201);
INSERT INTO Branch (branchNo, street, city, state, zip) VALUES ('WI04', '199 N Appletree Ave', 'Fox Point', 'WI', 53217);
INSERT INTO Branch (branchNo, street, city, state, zip) VALUES ('IL01', '844 E Milwaukee Ave', 'Chicago', 'IL', 60601);
INSERT INTO Branch (branchNo, street, city, state, zip) VALUES ('IL03', '712 W Lincoln St', 'Rockford', 'IL', 60619);

-- Insert DVD data
INSERT INTO DVD (catalogNo, title, category, dailyRent) VALUES ('D00001', 'Forrest Gump', 'drama', 1.99);
INSERT INTO DVD (catalogNo, title, category, dailyRent) VALUES ('D00002', 'That Thing You Do!', 'drama', 1.99);
INSERT INTO DVD (catalogNo, title, category, dailyRent) VALUES ('D00004', 'Band of Brothers', 'tv series', 9.99);
INSERT INTO DVD (catalogNo, title, category, dailyRent) VALUES ('D00006', 'From the Earth to the Moon', 'tv series', 10.99);

-- Insert Rental data
INSERT INTO Rental VALUES ('WI01', 'D00001', '2019-11', '20');
INSERT INTO Rental VALUES ('WI04', 'D00001', '2019-11', '19');
INSERT INTO Rental VALUES ('IL01', 'D00001', '2019-11', '18');
INSERT INTO Rental VALUES ('IL03', 'D00001', '2019-11', '11');
INSERT INTO Rental VALUES ('WI01', 'D00002', '2019-11', '21');
INSERT INTO Rental VALUES ('WI04', 'D00002', '2019-11', '20');
INSERT INTO Rental VALUES ('IL01', 'D00002', '2019-11', '19');
INSERT INTO Rental VALUES ('IL03', 'D00002', '2019-11', '17');
INSERT INTO Rental VALUES ('WI01', 'D00004', '2019-11', '22');
INSERT INTO Rental VALUES ('WI04', 'D00004', '2019-11', '21');
INSERT INTO Rental VALUES ('IL01', 'D00004', '2019-11', '20');
INSERT INTO Rental VALUES ('IL03', 'D00004', '2019-11', '24');
INSERT INTO Rental VALUES ('WI01', 'D00006', '2019-11', '19');
INSERT INTO Rental VALUES ('WI04', 'D00006', '2019-11', '17');
INSERT INTO Rental VALUES ('IL01', 'D00006', '2019-11', '19');
INSERT INTO Rental VALUES ('IL03', 'D00006', '2019-11', '20');
INSERT INTO Rental VALUES ('WI01', 'D00001', '2019-12', '21');
INSERT INTO Rental VALUES ('WI04', 'D00001', '2019-12', '21');
INSERT INTO Rental VALUES ('IL01', 'D00001', '2019-12', '23');
INSERT INTO Rental VALUES ('IL03', 'D00001', '2019-12', '27');
INSERT INTO Rental VALUES ('WI01', 'D00002', '2019-12', '21');
INSERT INTO Rental VALUES ('WI04', 'D00002', '2019-12', '22');
INSERT INTO Rental VALUES ('IL01', 'D00002', '2019-12', '17');
INSERT INTO Rental VALUES ('IL03', 'D00002', '2019-12', '19');
INSERT INTO Rental VALUES ('WI01', 'D00004', '2019-12', '21');
INSERT INTO Rental VALUES ('WI04', 'D00004', '2019-12', '26');
INSERT INTO Rental VALUES ('IL01', 'D00004', '2019-12', '22');
INSERT INTO Rental VALUES ('IL03', 'D00004', '2019-12', '19');
INSERT INTO Rental VALUES ('WI01', 'D00006', '2019-12', '20');
INSERT INTO Rental VALUES ('WI04', 'D00006', '2019-12', '21');
INSERT INTO Rental VALUES ('IL01', 'D00006', '2019-12', '21');
INSERT INTO Rental VALUES ('IL03', 'D00006', '2019-12', '23');
INSERT INTO Rental VALUES ('WI01', 'D00001', '2020-01', '27');
INSERT INTO Rental VALUES ('WI04', 'D00001', '2020-01', '21');
INSERT INTO Rental VALUES ('IL01', 'D00001', '2020-01', '22');
INSERT INTO Rental VALUES ('IL03', 'D00001', '2020-01', '17');
INSERT INTO Rental VALUES ('WI01', 'D00002', '2020-01', '19');
INSERT INTO Rental VALUES ('WI04', 'D00002', '2020-01', '21');
INSERT INTO Rental VALUES ('IL01', 'D00002', '2020-01', '20');
INSERT INTO Rental VALUES ('IL03', 'D00002', '2020-01', '21');
INSERT INTO Rental VALUES ('WI01', 'D00004', '2020-01', '21');
INSERT INTO Rental VALUES ('WI04', 'D00004', '2020-01', '23');
INSERT INTO Rental VALUES ('IL01', 'D00004', '2020-01', '27');
INSERT INTO Rental VALUES ('IL03', 'D00004', '2020-01', '21');
INSERT INTO Rental VALUES ('WI01', 'D00006', '2020-01', '22');
INSERT INTO Rental VALUES ('WI04', 'D00006', '2020-01', '17');
INSERT INTO Rental VALUES ('IL01', 'D00006', '2020-01', '20');
INSERT INTO Rental VALUES ('IL03', 'D00006', '2020-01', '21');
INSERT INTO Rental VALUES ('WI01', 'D00001', '2020-02', '21');
INSERT INTO Rental VALUES ('WI04', 'D00001', '2020-02', '23');
INSERT INTO Rental VALUES ('IL01', 'D00001', '2020-02', '27');
INSERT INTO Rental VALUES ('IL03', 'D00001', '2020-02', '21');
INSERT INTO Rental VALUES ('WI01', 'D00002', '2020-02', '22');
INSERT INTO Rental VALUES ('WI04', 'D00002', '2020-02', '17');
INSERT INTO Rental VALUES ('IL01', 'D00002', '2020-02', '19');
INSERT INTO Rental VALUES ('IL03', 'D00002', '2020-02', '21');
INSERT INTO Rental VALUES ('WI01', 'D00004', '2020-02', '20');
INSERT INTO Rental VALUES ('WI04', 'D00004', '2020-02', '21');
INSERT INTO Rental VALUES ('IL01', 'D00004', '2020-02', '21');
INSERT INTO Rental VALUES ('IL03', 'D00004', '2020-02', '23');
INSERT INTO Rental VALUES ('WI01', 'D00006', '2020-02', '27');
INSERT INTO Rental VALUES ('WI04', 'D00006', '2020-02', '21');
INSERT INTO Rental VALUES ('IL01', 'D00006', '2020-02', '22');
INSERT INTO Rental VALUES ('IL03', 'D00006', '2020-02', '17');


-- PERFORM QUERIES

-- Show the grand total of rentals from all branches between 2019 and 2020.
-- Q1
SELECT SUM(dailyRent * days) AS RENTALS
FROM DVD, Rental
WHERE Rental.catalogNo = DVD.catalogNo
AND ((yearMonth LIKE '2019-%') OR (yearMonth LIKE '2020-%'));

-- Show the total of rentals in Wisconsin in 2020.
-- Q2
SELECT SUM(dailyRent * days) AS RENTALS
FROM DVD, Rental, Branch
WHERE Rental.catalogNo = DVD.catalogNo
  AND Rental.branchNo = Branch.branchNo
  AND yearMonth LIKE '2020-%'
  AND state = 'WI';

-- Show the total of rentals by city, DVD category, and month.
-- Q3
SELECT city,
       state as st,
       category,
       yearMonth AS yearMon,
       SUM(dailyRent * days) AS RENTALS
FROM DVD, RENTAL, BRANCH
WHERE RENTAL.catalogNo = DVD.catalogNo
    AND RENTAL.branchNo = Branch.branchNo
GROUP BY (state, city, category, yearMonth)
ORDER BY state, city, category, yearMonth;


-- Show the total of rentals by state, DVD category, and year.
-- Q4
SELECT state as st,
       category,
       SUBSTR(yearMonth, 0, 4) AS year,
       SUM(dailyRent * days) AS RENTALS
FROM DVD, RENTAL, BRANCH
WHERE RENTAL.catalogNo = DVD.catalogNo
    AND RENTAL.branchNo = Branch.branchNo
GROUP BY (state, category, SUBSTR(yearMonth, 0, 4))
ORDER BY state, category, year;

-- Show the total of rentals by state and year.
-- Q5
SELECT state AS st,
       SUBSTR(yearMonth, 0, 4) AS year,
       SUM(dailyRent * days) AS RENTALS
FROM DVD, RENTAL, BRANCH
WHERE RENTAL.catalogNo = DVD.catalogNo
    AND RENTAL.branchNo = Branch.branchNo
GROUP BY (state, SUBSTR(yearMonth, 0, 4))
ORDER BY state, year;


-- Show the total of rentals by state.
-- Q6
SELECT state AS st,
       SUM(dailyRent * days) AS RENTALS
FROM DVD, RENTAL, BRANCH
WHERE RENTAL.catalogNo = DVD.catalogNo
    AND RENTAL.branchNo = Branch.branchNo
GROUP BY (state)
ORDER BY state;


-- Show the totals, subtotals, and grand total (i.e., rollup) of rentals by state, DVD category, and year.
-- TODO Q7


-- Show all possible subtotals (i.e., cube) of rentals by state, DVD category, and year.
-- TODO Q8


-- Rank the cities by their total rentals in 2020.
-- TODO Q9


-- Show the monthly total rentals and bimonthly moving total rentals in Wisconsin.
-- TODO Q10

