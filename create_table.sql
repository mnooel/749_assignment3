-- BUS-ADM 749 Data and Information Management
-- Michael Noel
-- Continental Palms DVD

-- Drop tables before running script.
DROP TABLE Branch CASCADE CONSTRAINTS PURGE;
DROP TABLE BranchTel CASCADE CONSTRAINTS PURGE;
DROP TABLE Staff CASCADE CONSTRAINTS PURGE;
DROP TABLE Manager CASCADE CONSTRAINTS PURGE;
DROP TABLE Member CASCADE CONSTRAINTS PURGE;
DROP TABLE ActorDirector CASCADE CONSTRAINTS PURGE;
DROP TABLE DVD CASCADE CONSTRAINTS PURGE;


-- Create Sequences


-- Create Branch table
CREATE TABLE Branch
(
    branchNo CHAR(4) PRIMARY KEY,
    street   VARCHAR(25) NOT NULL,
    city     VARCHAR(15) NOT NULL,
    state    CHAR(2)     NOT NULL,
    zip      VARCHAR(5)  NOT NULL,
    CONSTRAINT Branch_states CHECK (state IN
                                    ('MA', 'RI', 'NH', 'ME', 'VT', 'CT', 'NY', 'NJ', 'PA', 'DE', 'DC', 'VA', 'MD', 'WV',
                                     'NC', 'SC', 'GA', 'FL', 'AL', 'TN', 'MS', 'KY', 'OH', 'IN', 'MI', 'IA', 'WI', 'MN',
                                     'SD', 'ND', 'MT', 'IL', 'MO', 'KS', 'NE', 'LA', 'AR', 'OK', 'TX', 'CO', 'WY', 'ID',
                                     'UT', 'AZ', 'NM', 'NV', 'CA', 'HI', 'OR', 'WA', 'AK')),
    CONSTRAINT Branch_branchNo_c1 CHECK (branchNo LIKE CONCAT(state, '__')),
    CONSTRAINT Branch_branchNo_c2 CHECK (REGEXP_LIKE(branchNo, '[A-Z]{2}\d{2}')),
    CONSTRAINT Branch_zip_c CHECK (REGEXP_LIKE(zip, '\d{4,5}'))
);

-- Create BranchTel table
CREATE TABLE BranchTel
(
    branchNo CHAR(4) REFERENCES Branch (branchNo),
    telNo    VARCHAR(30) UNIQUE,
    PRIMARY KEY (branchNo, telNo),
    CONSTRAINT BranchTel_telNo_c CHECK (REGEXP_LIKE(telNo, '\d{3}-\d{3}-\d{4}'))
);

-- Create Staff Table
CREATE TABLE Staff
(
    staffNo    CHAR(6) PRIMARY KEY,
    firstName  VARCHAR(15)                          NOT NULL,
    lastName   VARCHAR(15)                          NOT NULL,
    position   VARCHAR(10)                          NOT NULL,
    salary     NUMBER(7, 2)                         NOT NULL,
    DOB        DATE                                 NOT NULL,
    branchNo   CHAR(4) REFERENCES Branch (branchNo) NOT NULL,
    supervisor CHAR(6) REFERENCES Staff (staffNo),
    CONSTRAINT Staff_staffNo_c1 CHECK (staffNo LIKE CONCAT(branchNo, '__')),
    CONSTRAINT Staff_staffNo_c2 CHECK (REGEXP_LIKE(staffNo, '[A-Z]{2}\d{4}')),
    CONSTRAINT Staff_salary_c   CHECK (salary > 0),
    CONSTRAINT Staff_pos_c CHECK (position IN ('Manager', 'Supervisor', 'Assistant')),
    CONSTRAINT Staff_sup_c CHECK (position <> 'Manager' OR supervisor IS NULL)
);


-- Create Manager Table
CREATE TABLE Manager
(
    staffNo   CHAR(6) REFERENCES Staff (staffNo) PRIMARY KEY,
    cellPhone VARCHAR(20) UNIQUE,
    eMail     VARCHAR(50) UNIQUE,
    CONSTRAINT Manager_cellPhone_c CHECK (REGEXP_LIKE(cellPhone, '\d{3}-\d{3}-\d{4}')),
    CONSTRAINT Manager_eMail_c CHECK (REGEXP_LIKE(eMail, '[A-Za-z]+[A-Za-z0-9.]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}'))
);

-- Create Member Table
CREATE TABLE Member(
    memberNo    CHAR(10)         PRIMARY KEY,
    firstName   VARCHAR(15)     NOT NULL,
    lastName    VARCHAR(15)     NOT NULL,
    street      VARCHAR(25)     NOT NULL,
    city        VARCHAR(15)     NOT NULL,
    state       CHAR(2)         NOT NULL,
    branchNo    CHAR(4)         REFERENCES Branch(branchNo)     NOT NULL,
    registDate  DATE            DEFAULT SYSDATE                 NOT NULL,
    CONSTRAINT Member_memberNo  CHECK (REGEXP_LIKE(memberNo, 'M\d{9}'))
);

-- Create ActorDirector Table
CREATE TABLE ActorDirector
(
    stageName VARCHAR(35) PRIMARY KEY,
    name      VARCHAR(50) NOT NULL,
    gender    CHAR(1) DEFAULT 'M',
    CONSTRAINT c_ActorDirector_gender CHECK (gender IN ('M', 'F'))
);

-- Create DVD Table
CREATE TABLE DVD
(
    catalogNo CHAR(6) PRIMARY KEY,
    title     VARCHAR(50) NOT NULL,
    category  VARCHAR(15) NOT NULL,
    dailyRent FLOAT       NOT NULL,
    CONSTRAINT c_DVD_category CHECK (category IN ('action', 'children', 'drama', 'horror', 'tv series', 'sci-fi')),
    CONSTRAINT c_DVD_dailyRent CHECK (dailyRent >= 0.0),
    CONSTRAINT c_DVD_catalogNo CHECK (REGEXP_LIKE(catalogNo, 'D\d{5}'))
);

-- TODO Create ChildrenDVD Table

-- TODO Create ForeignDVD Table

-- TODO Create Makes Table

-- TODO Create DVDCopy Table

-- TODO Create Rental Table

-- list all tables
SELECT *
FROM tab;

-- Insert Branch Data
INSERT INTO Branch (branchNo, street, city, state, zip)
VALUES ('WI01', '100 E Capital Dr', 'Milwaukee', 'WI', '53201');

INSERT INTO Branch (branchNo, street, city, state, zip)
VALUES ('WI02', '250 N Swan Ave', 'Milwaukee', 'WI', '53217');

INSERT INTO Branch (branchNo, street, city, state, zip)
VALUES ('WI03', '750 W Mequon Rd', 'Milwaukee', 'WI', '53221');

INSERT INTO Branch (branchNo, street, city, state, zip)
VALUES ('IL01', '844 E Milwaukee Ave', 'Chicago', 'IL', '60601');

INSERT INTO Branch (branchNo, street, city, state, zip)
VALUES ('IL02', '777 W Canal St', 'Chicago', 'IL', '60612');

-- Insert BranchTel Data
INSERT INTO BranchTel (branchNo, telNo)
VALUES  ('WI01', '414-299-1111');

INSERT INTO BranchTel (branchNo, telNo)
VALUES  ('WI02', '414-299-1112');

INSERT INTO BranchTel (branchNo, telNo)
VALUES  ('WI03', '414-299-1113');

INSERT INTO BranchTel (branchNo, telNo)
VALUES  ('IL01', '312-299-1111');

INSERT INTO BranchTel (branchNo, telNo)
VALUES  ('IL02', '312-299-1112');

-- TODO Insert Staff Data
INSERT INTO Staff (staffNo, firstName, lastName, position, salary, DOB, branchNo, supervisor)
VALUES ()


-- TODO Insert Manager Data

-- TODO Insert Member Data

-- TODO Insert ActorDirector Data

-- TODO Insert DVD Data

-- TODO Insert ChildrenDVD Data

-- TODO Insert ForeignDVD Data

-- TODO Insert Makes Data

-- TODO Insert DVDCopy Data

-- TODO Insert Rental Data



