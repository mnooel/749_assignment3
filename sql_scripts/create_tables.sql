-- BUS-ADM 749 Data and Information Management
-- Michael Noel
-- Continental Palms DVD
-- create_tables.sql

-- -- Create Rental Sequence
-- CREATE SEQUENCE rental_sequence
--     INCREMENT BY 1
--     START WITH 100000
--     NOMAXVALUE
--     NOCYCLE
--     CACHE 10;
--
-- -- Create Member Sequence
-- CREATE SEQUENCE member_sequence
--     INCREMENT BY 1
--     START WITH 10000
--     NOMAXVALUE
--     NOCYCLE
--     CACHE 10;

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

-- Create BranchTel table
CREATE TABLE BranchTel
(
    branchNo CHAR(4),
    telNo    VARCHAR2(30),
    CONSTRAINT BranchTel_PK PRIMARY KEY (branchNo, telNo),
    CONSTRAINT BranchTel_branchNo_FK FOREIGN KEY (branchNo) REFERENCES Branch (branchNo),
    CONSTRAINT BranchTel_telNo_unique UNIQUE (telNo),
    CONSTRAINT BranchTel_telNo_c CHECK (REGEXP_LIKE(telNo, '\d{3}-\d{3}-\d{4}'))
);

-- Create Staff Table
CREATE TABLE Staff
(
    staffNo    CHAR(6),
    firstName  VARCHAR2(15)      NOT NULL,
    lastName   VARCHAR2(15)      NOT NULL,
    position   VARCHAR2(10)      NOT NULL,
    salary     NUMBER(7, 2)     NOT NULL,
    DOB        DATE             NOT NULL,
    branchNo   CHAR(4)          NOT NULL,
    supervisor CHAR(6),
    CONSTRAINT Staff_PK PRIMARY KEY (staffNo),
    CONSTRAINT Staff_staffNo_c1 CHECK (staffNo LIKE CONCAT(branchNo, '__')),
    CONSTRAINT Staff_staffNo_c2 CHECK (REGEXP_LIKE(staffNo, '[A-Z]{2}\d{4}')),
    CONSTRAINT Staff_branchNo_FK FOREIGN KEY (branchNo) REFERENCES Branch (branchNo),
    CONSTRAINT Staff_supervisor_FK FOREIGN KEY (supervisor) REFERENCES Staff (staffNo),
    CONSTRAINT Staff_salary_c CHECK (salary > 0),
    CONSTRAINT Staff_pos_c CHECK (position IN ('manager', 'supervisor', 'assistant')),
    CONSTRAINT Staff_sup_c CHECK (position <> 'manager' OR supervisor IS NULL)
);

-- Create Manager Table
CREATE TABLE Manager
(
    staffNo   CHAR(6),
    cellPhone VARCHAR2(20),
    eMail     VARCHAR2(50),
    CONSTRAINT Manager_PK PRIMARY KEY (staffNo),
    CONSTRAINT Manager_staffNo_FK FOREIGN KEY (staffNo) REFERENCES Staff (staffNo),
    CONSTRAINT Manager_cellPhone_c1 CHECK (REGEXP_LIKE(cellPhone, '\d{3}-\d{3}-\d{4}')),
    CONSTRAINT Manager_cellPhone_unique UNIQUE (cellPhone),
    CONSTRAINT Manager_eMail_c CHECK (REGEXP_LIKE(eMail, '[A-Za-z]+[A-Za-z0-9.]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}')),
    CONSTRAINT Manager_eMail_unique UNIQUE (eMail)
);

-- Create Member Table
CREATE TABLE Member
(
    memberNo   INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 10000 INCREMENT BY 1),
    firstName  VARCHAR2(15)                      NOT NULL,
    lastName   VARCHAR2(15)                      NOT NULL,
    street     VARCHAR2(25)                      NOT NULL,
    city       VARCHAR2(15)                      NOT NULL,
    state      CHAR(2)                           NOT NULL,
    zip        CHAR(5)                           NOT NULL,
    branchNo   CHAR(4)                           NOT NULL,
    registDate DATE         DEFAULT SYSDATE      NOT NULL,
    CONSTRAINT Member_PK PRIMARY KEY (memberNo),
    CONSTRAINT Member_branchNo_FK FOREIGN KEY (branchNo) REFERENCES Branch (branchNo)
);

-- Create ActorDirector Table
CREATE TABLE ActorDirector
(
    stageName VARCHAR2(35),
    name      VARCHAR2(50)       NOT NULL,
    gender    CHAR(1)           DEFAULT 'M',
    CONSTRAINT ActorDirector_PK PRIMARY KEY (stageName),
    CONSTRAINT ActorDirector_gender_c CHECK (gender IN ('M', 'F'))
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

-- Create ChildrenDVD Table
CREATE TABLE ChildrenDVD
(
    catalogNo CHAR(6),
    ageGroup  VARCHAR2(15) NOT NULL,
    CONSTRAINT ChildrenDVD_PK PRIMARY KEY (catalogNo),
    CONSTRAINT ChildrenDVD_catalogNo_FK FOREIGN KEY (catalogNo) REFERENCES DVD (catalogNo),
    CONSTRAINT ChildrenDVD_ageGroup_c CHECK ( ageGroup IN ('infant', 'toddler', 'teenager'))
);

-- Create ForeignDVD Table
CREATE TABLE ForeignDVD
(
    catalogNo        CHAR(6),
    spokenLanguage   VARCHAR2(20) NOT NULL,
    subtitleLanguage VARCHAR2(20),
    CONSTRAINT ForeignDVD_PK PRIMARY KEY (catalogNo),
    CONSTRAINT ForeignDVD_catalogNo_FK FOREIGN KEY (catalogNo) REFERENCES DVD (catalogNo)
);

-- Create Makes Table
CREATE TABLE Makes
(
    stageName VARCHAR2(50)   NOT NULL,
    catalogNo CHAR(6)       NOT NULL,
    role      VARCHAR2(50)   NOT NULL,
    CONSTRAINT Makes_pk_c PRIMARY KEY (stageName, catalogNo),
    CONSTRAINT Makes_stageName_FK FOREIGN KEY (stageName) REFERENCES ActorDirector (stageName),
    CONSTRAINT Makes_catalogNo_FK FOREIGN KEY (catalogNo) REFERENCES DVD (catalogNo)
);

-- Create DVDCopy Table
CREATE TABLE DVDCopy
(
    catalogNo CHAR(6)    NOT NULL,
    copyNo    INTEGER    NOT NULL,
    condition INTEGER    NOT NULL,
    branchNo  CHAR(4),
    CONSTRAINT DVDCopy_PK PRIMARY KEY (catalogNo, copyNo),
    CONSTRAINT DVDCopy_catalogNo_FK FOREIGN KEY (catalogNo) REFERENCES DVD (catalogNo),
    CONSTRAINT DVDCopy_condition_c CHECK (condition IN (1, 2, 3, 4)),
    CONSTRAINT DVDCopy_branchNo_FK FOREIGN KEY (branchNo) REFERENCES Branch (branchNo)
);

-- Create Rental Table
CREATE TABLE Rental
(
    rentalNo   INTEGER GENERATED ALWAYS AS IDENTITY (START WITH 100000 INCREMENT BY 1),
    catalogNo  CHAR(6)      NOT NULL,
    copyNo     INTEGER      NOT NULL,
    memberNo   INTEGER      NOT NULL,
    rentedFrom CHAR(4)      NOT NULL,
    rentDate   DATE         NOT NULL,
    returnedTo CHAR(4)      DEFAULT NULL,
    returnDate DATE         DEFAULT NULL,
    CONSTRAINT Rental_PK PRIMARY KEY (rentalNo),
    CONSTRAINT Rental_memberNo FOREIGN KEY (memberNo) REFERENCES Member (memberNo),
    CONSTRAINT Rental_copy_FK FOREIGN KEY (catalogNo, copyNo) REFERENCES DVDCopy (catalogNo, copyNo),
    CONSTRAINT Rental_rentedFrom_FK FOREIGN KEY (rentedFrom) REFERENCES Branch (branchNo),
    CONSTRAINT Rental_returnedTo_FK FOREIGN KEY (returnedTo) REFERENCES Branch (branchNo),
    CONSTRAINT Rental_return_c CHECK (((returnedTo IS NULL) AND (returnDate IS NULL)) OR
                                      ((returnedTo IS NOT NULL) AND (returnDate IS NOT NULL)))
);
