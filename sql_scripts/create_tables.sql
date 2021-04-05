-- BUS-ADM 749 Data and Information Management
-- Michael Noel
-- Continental Palms DVD
-- create_tables.sql

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
    CONSTRAINT Staff_salary_c CHECK (salary > 0),
    CONSTRAINT Staff_pos_c CHECK (position IN ('manager', 'supervisor', 'assistant')),
    CONSTRAINT Staff_sup_c CHECK (position <> 'manager' OR supervisor IS NULL)
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
CREATE TABLE Member
(
    memberNo   CHAR(10) PRIMARY KEY,
    firstName  VARCHAR(15)                          NOT NULL,
    lastName   VARCHAR(15)                          NOT NULL,
    street     VARCHAR(25)                          NOT NULL,
    city       VARCHAR(15)                          NOT NULL,
    state      CHAR(2)                              NOT NULL,
    branchNo   CHAR(4) REFERENCES Branch (branchNo) NOT NULL,
    registDate DATE DEFAULT SYSDATE                 NOT NULL,
    CONSTRAINT Member_memberNo_c CHECK (REGEXP_LIKE(memberNo, 'M\d{9}'))
);

-- Create ActorDirector Table
CREATE TABLE ActorDirector
(
    stageName VARCHAR(35) PRIMARY KEY,
    name      VARCHAR(50) NOT NULL,
    gender    CHAR(1) DEFAULT 'M',
    CONSTRAINT ActorDirector_gender_c CHECK (gender IN ('M', 'F'))
);

-- Create DVD Table
CREATE TABLE DVD
(
    catalogNo CHAR(6) PRIMARY KEY,
    title     VARCHAR(50) NOT NULL,
    category  VARCHAR(15) NOT NULL,
    dailyRent FLOAT       NOT NULL,
    CONSTRAINT DVD_category_c CHECK (category IN ('action', 'children', 'drama', 'horror', 'tv series', 'sci-fi')),
    CONSTRAINT DVD_dailyRent_c CHECK (dailyRent >= 0.0),
    CONSTRAINT DVD_catalogNo_c CHECK (REGEXP_LIKE(catalogNo, 'D\d{5}'))
);

-- TODO Create ChildrenDVD Table

-- TODO Create ForeignDVD Table

-- Create Makes Table
CREATE TABLE Makes
(
    stageName   VARCHAR(50) REFERENCES ActorDirector (stageName) NOT NULL,
    catalogNo   CHAR(6) REFERENCES DVD (catalogNo) NOT NULL,
    role        VARCHAR(50) NOT NULL,
    CONSTRAINT Makes_pk_c  PRIMARY KEY (stageName, catalogNo)
);

-- Create DVDCopy Table
CREATE TABLE DVDCopy
(
    catalogNo CHAR(6) REFERENCES DVD (catalogNo) NOT NULL ,
    copyNo    INTEGER NOT NULL,
    condition INTEGER NOT NULL,
    branchNo  CHAR(4) REFERENCES Branch (branchNo),
    CONSTRAINT DVDCopy_pk_c PRIMARY KEY (catalogNo, copyNo),
    CONSTRAINT DVDCopy_condition_c CHECK (condition IN (1, 2, 3, 4))
);
