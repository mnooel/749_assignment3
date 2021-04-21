-- BUS-ADM 749 Data and Information Management
-- Michael Noel
-- Continental Palms DVD
-- drop_tables.sql

-- Drop sequences before running script.
-- DROP SEQUENCE rental_sequence;
-- DROP SEQUENCE member_sequence;

-- Drop functions before running script.
DROP FUNCTION FX_BRANCHEXISTS;
DROP FUNCTION FX_CHECKEDOUT;
DROP FUNCTION FX_COPYEXISTS;
DROP FUNCTION FX_DVDCOPYBROKEN;
DROP FUNCTION FX_DVDEXISTS;
DROP FUNCTION FX_LASTRENTALNO;
DROP FUNCTION FX_MEMBEREXISTS;
DROP FUNCTION FX_RENTALAMOUNT;
DROP FUNCTION FX_RENTALEXISTS;
DROP FUNCTION FX_RETURNRENTALENDDATE;
DROP FUNCTION FX_STARTBEFOREEND;

-- Drop procedures before running script.
DROP PROCEDURE PROC_CHECKOUT;
DROP PROCEDURE PROC_CHECKIN;

-- Drop triggers before running script.
DROP TRIGGER TRIG_STAFFHANDLINGTOOMUCH;

-- Drop tables before running script.
DROP TABLE Branch CASCADE CONSTRAINTS PURGE;
DROP TABLE BranchTel CASCADE CONSTRAINTS PURGE;
DROP TABLE Staff CASCADE CONSTRAINTS PURGE;
DROP TABLE Manager CASCADE CONSTRAINTS PURGE;
DROP TABLE Member CASCADE CONSTRAINTS PURGE;
DROP TABLE ActorDirector CASCADE CONSTRAINTS PURGE;
DROP TABLE DVD CASCADE CONSTRAINTS PURGE;
DROP TABLE ChildrenDVD CASCADE CONSTRAINTS PURGE;
DROP TABLE ForeignDVD CASCADE CONSTRAINTS PURGE;
DROP TABLE Makes CASCADE CONSTRAINTS PURGE;
DROP TABLE DVDCopy CASCADE CONSTRAINTS PURGE;
DROP TABLE Rental CASCADE CONSTRAINTS PURGE;

-- Drop views before running script.
DROP VIEW DVDCOPYLOCATION CASCADE CONSTRAINTS;

-- BUS-ADM 749 Data and Information Management
-- Michael Noel
-- Continental Palms DVD
-- create_tables.sql

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
    CONSTRAINT Staff_sup_c1 CHECK (position <> 'manager' OR supervisor IS NULL),
    CONSTRAINT Staff_sup_c2 CHECK (staffNo <> supervisor)
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


-- Create RentalAmount VIEW
CREATE OR REPLACE VIEW RentalTotalAmount AS
SELECT
    RENTALNO AS RentalNo,
    RENTDATE AS RentDate,
    RETURNDATE AS ActualReturnDate,
    FX_RETURNRENTALENDDATE(RENTALNO) AS HypotheticalReturnDate,
    CEIL(FX_RETURNRENTALENDDATE(RENTALNO) - RENTDATE) AS Days,
    FX_RENTALAMOUNT(RENTALNO) AS RentalAmount
FROM RENTAL;

-- BUS-ADM 749 Data and Information Management
-- Michael Noel
-- Continental Palms DVD
-- create_procedures.sql


-- Create a function to check if the copy exists.
CREATE OR REPLACE FUNCTION fx_DVDExists(theCatalogNo DVD.catalogNo%TYPE)
    RETURN BOOLEAN
AS
    -- Declare necessary variables.
    flag NUMBER(1);

BEGIN
    -- If a DVDCopy exists then it's know that a DVD also exists.
    -- Check to see that a DVDCopy exists.
    SELECT COUNT(*)
    INTO flag
    FROM DVD
    WHERE CATALOGNO = theCatalogNo;
    IF flag < 1 THEN
        RAISE_APPLICATION_ERROR(-20001, 'The DVD specified does not exist.' ||
                                        ' CATALOGNO: ' || theCatalogNo);
    END IF;

    RETURN (TRUE);
END;


-- Create a function to check if the copy exists.
CREATE OR REPLACE FUNCTION fx_CopyExists(theCatalogNo DVDCopy.catalogNo%TYPE,
                                         theCopyNo DVDCopy.copyNo%TYPE)
    RETURN BOOLEAN
AS
    -- Declare necessary variables.
    flag NUMBER(1);

BEGIN
    -- If a DVDCopy exists then it's know that a DVD also exists.
    -- Check to see that a DVDCopy exists.
    SELECT COUNT(*)
    INTO flag
    FROM DVDCOPY
    WHERE CATALOGNO = theCatalogNo
      AND COPYNO = theCopyNo;

    IF flag < 1 AND fx_DVDExists(theCatalogNo) THEN
        RAISE_APPLICATION_ERROR(-20002, 'The DVDCopy specified does not exist.' ||
                                        ' CATALOGNO: ' || theCatalogNo || ' COPYNO: ' || theCopyNo);
    END IF;

    RETURN (TRUE);
END;


-- Create a function to determine if the member exists.
CREATE OR REPLACE FUNCTION fx_MemberExists(theMemberNo Member.memberNo%TYPE)
    RETURN BOOLEAN
AS
    -- Declare necessary variables.
    flag NUMBER(1);

BEGIN
    SELECT COUNT(*)
    INTO flag
    FROM MEMBER
    WHERE MEMBERNO = theMemberNo;
    IF flag < 1 THEN
        RAISE_APPLICATION_ERROR(-20003, 'The Member specified not exist.' ||
                                        ' MEMBERNO: ' || theMemberNo);
    END IF;

    RETURN (TRUE);

END;


-- Create a function to determine if the branch exists.
CREATE OR REPLACE FUNCTION fx_BranchExists(theBranchNo Branch.branchNo%TYPE)
    RETURN BOOLEAN
AS
    -- Declare necessary variables.
    flag NUMBER(1);

BEGIN
    SELECT COUNT(*)
    INTO flag
    FROM BRANCH
    WHERE BRANCHNO = theBranchNo;
    IF flag < 1 THEN
        RAISE_APPLICATION_ERROR(-20004, 'The Branch specified does not exist.' ||
                                        ' BRANCHNO: ' || theBranchNo);
    END IF;

    RETURN (TRUE);

END;


-- Create a function to determine if the rental exists.
CREATE OR REPLACE FUNCTION fx_RentalExists(theRentalNo Rental.rentalNo%TYPE)
    RETURN BOOLEAN
AS
    -- Declare necessary variables.
    flag NUMBER(1);

BEGIN
    SELECT COUNT(*)
    INTO flag
    FROM RENTAL
    WHERE RENTALNO = theRentalNo;
    IF flag < 1 THEN
        RAISE_APPLICATION_ERROR(-20005, 'The Rental specified not exist.' ||
                                        ' RENTALNO: ' || theRentalNo);
    END IF;

    RETURN (TRUE);

END;


-- Create a function to return the last rentalNo or null for a DVDCopy.
-- If a rental has been made for a DVDCopy previously return the rentalNo of the last rental.
-- Else return NULL is there has never been a rental for the DVDCopy.
CREATE OR REPLACE FUNCTION fx_LastRentalNo(theCatalogNo DVDCopy.catalogNo%TYPE,
                                           theCopyNo DVDCopy.copyNo%TYPE)
    RETURN INTEGER
AS
    -- Declare necessary variables.
    theRentalNo INTEGER := NULL;

BEGIN

    -- Check to make sure the copy exists.
    IF fx_CopyExists(theCatalogNo, theCopyNo) THEN
        -- Proceed with the rest of the function.
        SELECT MAX(RENTALNO)
        INTO theRentalNo
        FROM RENTAL
        WHERE CATALOGNO = theCatalogNo
          AND COPYNO = theCopyNo;
    END IF;

    RETURN (theRentalNo);

END;


-- Create a function to check if a DVDCopy is checked out.
CREATE OR REPLACE FUNCTION fx_CheckedOut(theCatalogNo DVDCopy.catalogNo%TYPE,
                                         theCopyNo DVDCopy.copyNo%TYPE)
    RETURN BOOLEAN
AS
    -- Declare necessary variables.
    theRentalNo   INTEGER := fx_LastRentalNo(theCatalogNo, theCopyNo);
    theBranchNo   CHAR(4) := NULL;
    theReturnedTo CHAR(4) := NULL;
    theReturnDate DATE    := NULL;
    theResult     BOOLEAN;

BEGIN
    -- If there has been a rental for a DVDCopy:
    IF theRentalNo IS NOT NULL THEN
        -- Check to make sure DVDCopy.branchNo is Null AND Rental.returnedTo is Null AND and Rental.returnDate is NULL.

        -- Set DVDCopy.branchNo variable.
        SELECT DISTINCT(BRANCHNO)
        INTO theBranchNo
        FROM DVDCOPY
        WHERE CATALOGNO = theCatalogNo
          AND COPYNO = theCopyNo;
        -- Set Rental.returnedTo variable.
        SELECT DISTINCT(RETURNEDTO)
        INTO theReturnedTo
        FROM RENTAL
        WHERE RENTALNO = theRentalNo;
        -- Set Rental.returnDate variable.
        SELECT DISTINCT(RETURNDATE)
        INTO theReturnDate
        FROM RENTAL
        WHERE RENTALNO = theRentalNo;

        -- The DVDCopy is checked out.
        IF theBranchNo IS NULL AND theReturnedTo IS NULL AND theReturnDate IS NULL THEN
            theResult := TRUE;
            -- Error - DVDCopy.branchNo must be NULL if theReturnTo is NULL AND theReturnDate is NULL.
        ELSIF theBranchNo IS NOT NULL AND (theReturnedTo IS NULL OR theReturnDate IS NULL) THEN
            RAISE_APPLICATION_ERROR(-20006, 'ERROR CHECKOUT NULL CONDITIONS VIOLATED!' ||
                                            ' DVDCOPY.BRANCHNO: ' || theBranchNo ||
                                            ' RENTAL.RETURNEDTO: ' || theReturnedTo ||
                                            ' RENTAL.RETURNDATE: ' || theReturnDate);
        ELSIF theBranchNo IS NULL AND (theReturnedTo IS NOT NULL OR theReturnDate IS NOT NULL) THEN
            RAISE_APPLICATION_ERROR(-20006, 'ERROR CHECKOUT NULL CONDITIONS VIOLATED!' ||
                                            ' DVDCOPY.BRANCHNO: ' || theBranchNo ||
                                            ' RENTAL.RETURNEDTO: ' || theReturnedTo ||
                                            ' RENTAL.RETURNDATE: ' || theReturnDate);
            -- The last rental has been returned.
        ELSIF theBranchNo IS NOT NULL AND theReturnedTo IS NOT NULL AND theReturnDate IS NOT NULL THEN
            theResult := FALSE;
            -- Some strange condition passed through unchecked.
        ELSE
            RAISE_APPLICATION_ERROR(-20007,
                                    'UNKNWON HUGE CONDITIONAL OVERSIGHT ERROR IN CHECKEDOUT FUNCTION. ' ||
                                    'THIS ABSOLUTELY SHOULD NOT HAPPEN GIVEN THE RENTAL_RETURN_C CONSTRAINT. ' ||
                                    'DVDCOPY.BRANCHNO: ' || theBranchNo ||
                                    ' RENTAL.RETURNEDTO: ' || theReturnedTo ||
                                    ' RENTAL.RETURNDATE: ' || theReturnDate);
        END IF;
        -- There has not been a rental for the DVDCopy.
    ELSE
        theResult := FALSE;

    END IF;

    RETURN (theResult);

END;


-- Create a function to see if the DVDCopy is Rentable.
CREATE OR REPLACE FUNCTION fx_DVDCopyBroken(theCatalogNo DVDCopy.catalogNo%TYPE,
                                            theCopyNo DVDCopy.copyNo%TYPE)
    RETURN BOOLEAN
AS
    -- Declare necessary variables.
    theCondition NUMBER(1);
    theResult    BOOLEAN;

BEGIN
    -- If the copy is not checked out then see if the condition is not 4.
    IF fx_CopyExists(theCatalogNo, theCopyNo) THEN
        SELECT DISTINCT CONDITION
        INTO theCondition
        FROM DVDCOPY
        WHERE CATALOGNO = theCatalogNo
          AND COPYNO = theCopyNo;

        IF theCondition < 4 THEN
            theResult := FALSE;
        ELSE
            RAISE_APPLICATION_ERROR(-20008, 'The DVDCopy specified is currently broken.' ||
                                            ' CATALOGNO: ' || theCatalogNo ||
                                            ' COPYNO: ' || theCopyNo ||
                                            ' CONDITON: ' || theCondition);
        END IF;
    END IF;

    RETURN (theResult);

END;


-- Create a function to determine that a startDate is before an endDate
CREATE OR REPLACE FUNCTION fx_StartBeforeEnd(theStartDate DATE, theEndDate DATE)
    RETURN BOOLEAN
AS
    -- Declare necessary variables
    timeDelta NUMBER := theStartDate - theEndDate;
    theResult BOOLEAN;

BEGIN
    -- If theStartDate - theEndDate < 0 raise ERROR
    IF timeDelta < 0 THEN
        theResult := TRUE;
    ELSE
        RAISE_APPLICATION_ERROR(-20009, 'Provided StartDate must be before EndDate. ' ||
                                        ' THESTARTDATE: ' || theStartDate ||
                                        ' THEENDDATE: ' || theEndDate);
    END IF;

    RETURN (theResult);

END;


-- Create a function to return the real or hypothetical endDate of a rental.
-- If the rental has been returned return the actual returnDate.
-- If the rental is outstanding return the SYSDATE.
CREATE OR REPLACE FUNCTION fx_ReturnRentalEndDate(theRentalNo Rental.rentalNo%TYPE)
    RETURN DATE
AS
    -- Declare necessary variables.
    theResult     DATE := SYSDATE;
    theReturnDate DATE := NULL;


BEGIN

    -- Check to see if the rental Exists.
    IF fx_RentalExists(theRentalNo) THEN
        SELECT DISTINCT RETURNDATE
        INTO theReturnDate
        FROM RENTAL
        WHERE RENTALNO = theRentalNo;
    END IF;
    -- If the rental is returned theReturnDate IS NOT NULL.
    IF theReturnDate IS NOT NULL THEN
        theResult := theReturnDate;
    END IF;

    RETURN (theResult);
END;


-- EXTRA PROCEDURE checkOut. Placed before CheckIn since it's the logical sequence of events.
-- Write a procedure named checkOut to checks out a DVDCopy.
-- The procedure takes four parameters: the memberNo, the branchNo, the catalogNo and the copyNo.
-- Since rentalNo is auto sequenced then we should not need a rental number.
CREATE OR REPLACE PROCEDURE proc_CheckOut(
    theCatalogNo DVDCopy.catalogNo%TYPE,
    theCopyNo DVDCopy.copyNo%TYPE,
    theMemberNo Member.memberNo%TYPE,
    theRentalDate DATE DEFAULT SYSDATE)
AS
    -- declare necessary variables.
    theBranchNo CHAR(4);
    isCheckedOut EXCEPTION;
    futureRental EXCEPTION;

BEGIN

    IF fx_CheckedOut(theCatalogNo, theCopyNo) THEN
        RAISE isCheckedOut;

        -- NOTE. This might break due to differences in processing time. Testing indicated it would not.
    ELSIF theRentalDate - SYSDATE > 0 THEN
        RAISE futureRental;
    ELSIF NOT fx_DVDCopyBroken(theCatalogNo, theCopyNo) THEN
        -- Set theBranchNo variable to the DVDCopy.branchNo.
        SELECT DISTINCT BRANCHNO
        INTO theBranchNo
        FROM DVDCOPY
        WHERE CATALOGNO = theCatalogNo
          AND COPYNO = theCopyNo;

        IF fx_MemberExists(theMemberNo) THEN
            -- Insert Rental.
            INSERT INTO RENTAL
            (CATALOGNO, COPYNO, MEMBERNO, RENTEDFROM, RENTDATE, RETURNEDTO, RETURNDATE)
            VALUES (theCatalogNo, theCopyNo, theMemberNo, theBranchNo, theRentalDate, NULL, NULL);
            -- Update the DVDCopy.
            UPDATE DVDCOPY
            SET BRANCHNO = NULL
            WHERE CATALOGNO = theCatalogNo
              AND COPYNO = theCopyNo;
        END IF;

    END IF;

EXCEPTION

    WHEN isCheckedOut THEN
        RAISE_APPLICATION_ERROR(-20010, 'DVDCopy is currently checked out.' ||
                                        ' CATALOGNO: ' || theCatalogNo || ' COPYNO: ' || theCopyNo);
    WHEN futureRental THEN
        RAISE_APPLICATION_ERROR(-20011, 'The RentalDate may not be in the future:' ||
                                        ' TODAY: ' || SYSDATE || ' THERENTALDATE: ' || theRentalDate);
END;


-- PROCEDURE
-- Write a procedure named CheckIn to check in a returned DVDCopy.
-- The procedure takes two parameters: the rentalNo and the branchNo where the DVDCopy is returned.
-- The procedure should fill in the returnedTo and returnDate attributes of the Rental record and update the \
-- the branchNo of the DVDCopy record.
-- Note that a rental cannot be checked in multiple times.
CREATE OR REPLACE PROCEDURE proc_CheckIn(theCatalogNo DVDCopy.catalogNo%TYPE,
                                         theCopyNo DVDCopy.copyNo%TYPE,
                                         theCondition DVDCopy.condition%TYPE,
                                         theBranchNo Branch.branchNo%TYPE,
                                         theReturnDate DATE DEFAULT SYSDATE)
AS
    -- Declare necessary variables.
    theRentalNo     INTEGER:= fx_LastRentalNo(theCatalogNo, theCopyNo);
    theRentalDate   DATE;
    noRental        EXCEPTION;
    isCheckedIn     EXCEPTION;
    futureReturn    EXCEPTION;

BEGIN

    -- Check to make sure the returnDate is before the rentDate.
    SELECT RENTDATE
    INTO theRentalDate
    FROM RENTAL
    WHERE RENTALNO = theRentalNo;
    IF NOT FX_STARTBEFOREEND(theRentalDate, theReturnDate) THEN
        RETURN;
    ELSIF NOT FX_BRANCHEXISTS(theBranchNo) THEN
        RETURN;
        -- Copy is already checked in if not checked out.
    ELSIF NOT fx_CheckedOut(theCatalogNo, theCopyNo) THEN
        RAISE isCheckedIn;
    ELSIF theRentalNo IS NULL THEN
        RAISE noRental;
    ELSIF theReturnDate - SYSDATE > 0 THEN
        RAISE futureReturn;
    ELSE
        -- Update the rental record.
        UPDATE RENTAL
        SET RETURNDATE = theReturnDate,
            RETURNEDTO = theBranchNo
        WHERE RENTALNO = theRentalNo;

        -- Update the DVDCopy.
        UPDATE DVDCOPY
        SET BRANCHNO  = theBranchNo,
            CONDITION = theCondition
        WHERE CATALOGNO = theCatalogNo
          AND COPYNO = theCopyNo;
    END IF;

EXCEPTION
    WHEN noRental THEN
        RAISE_APPLICATION_ERROR(-20013, 'The DVDCopy has never been rented.' ||
                                        ' CATALOGNO: ' || theCatalogNo ||
                                        ' COPYNO: ' || theCopyNo);
    WHEN isCheckedIn THEN
        RAISE_APPLICATION_ERROR(-20014, 'The DVDCopy has already been checked in.' ||
                                        ' CATALOGNO: ' || theCatalogNo ||
                                        ' COPYNO: ' || theCopyNo);

    WHEN futureReturn THEN
        RAISE_APPLICATION_ERROR(-20015, 'The ReturnDate may not be in the future:' ||
                                        ' TODAY: ' || SYSDATE || ' THERETURNDATE: ' || theReturnDate);

END;


-- FUNCTION
-- Write a function named RentalAmount to calculate the total amount of a rental.
-- The function takes the rental number as input and returns the total amount.
-- If the rental has not been returned yet, use the current date as the ending date for the calculation.
CREATE OR REPLACE FUNCTION fx_RentalAmount(theRentalNo Rental.rentalNo%TYPE)
    RETURN FLOAT
AS
    -- Declare necessary variables.
    theCatalogNo  CHAR(6) := NULL;
    theRentalRate FLOAT   := NULL;
    theReturnDate DATE    := fx_ReturnRentalEndDate(theRentalNo);
    theRentDate   DATE    := NULL;
    totalAmount   FLOAT   := NULL;


BEGIN

    -- Set theCatalogNo to query theRentalRate.
    SELECT DISTINCT CATALOGNO
    INTO theCatalogNo
    FROM RENTAL
    WHERE RENTALNO = theRentalNo;

    -- Set theRentalRate.
    SELECT DISTINCT DAILYRENT
    INTO theRentalRate
    FROM DVD
    WHERE CATALOGNO = theCatalogNo;

    -- Set theRentalDate.
    SELECT DISTINCT RENTDATE
    INTO theRentDate
    FROM RENTAL
    WHERE RENTALNO = theRentalNo;

    -- Calculate the total amount of the rental. Partial days = 1 day.
    totalAmount := (CEIL((theReturnDate - theRentDate))) * theRentalRate;

    RETURN (totalAmount);
END;


-- TRIGGER
-- Write a trigger to check and enforce the following constraints when a new record is inserted into the Staff table.
--      1. A staff member can supervise up to 10 others.
--      2. A staff member who supervises others is in the position of supervisor or manager.
--      3. The staff supervision relationship is hierarchical up to three levels.
CREATE OR REPLACE TRIGGER TRIG_StaffHandlingTooMuch
    BEFORE INSERT OR UPDATE
    ON Staff

    FOR EACH ROW
DECLARE
    -- Declare Necessary Variables.
    -- 1. A staff member can supervise up to 10 others.
    nSubordinates NUMBER;

    -- 2. A staff member who supervises others is in the position of supervisor or manager.
    supPos        Staff.position%TYPE;


    --  3. The staff supervision relationship is hierarchical up to three levels.
    supCount      NUMBER;
    super         Staff.supervisor%TYPE;

BEGIN

    --  1. A staff member can supervise up to 10 others.
    IF :NEW.supervisor IS NOT NULL THEN
        SELECT COUNT(*)
        INTO nSubordinates
        FROM STAFF
        WHERE SUPERVISOR = :NEW.supervisor;
        IF nSubordinates > 9 THEN
            RAISE_APPLICATION_ERROR(-20016, 'A supervisor may not oversee more than 10 other staff.' ||
                                            ' SUPERVISOR: ' || :NEW.supervisor || 'N_SUPERVISING' || nSubordinates);
        END IF;
    END IF;

    --  2. A staff member who supervises others is in the position of supervisor or manager.
    IF NOT (:NEW.position = 'manager' OR :NEW.position = 'supervisor' OR :NEW.position = 'assistant') THEN
        RAISE_APPLICATION_ERROR(-20017, 'The position specified must be in (manager, supervisor, or assistant).' ||
                                        ' POSITION: ' || :NEW.position);
    ELSIF :NEW.position = 'manager' THEN
        RETURN;
    ELSE
        SELECT DISTINCT POSITION
        INTO supPos
        FROM STAFF
        WHERE STAFFNO = :NEW.supervisor;
        IF NOT (supPos = 'manager' OR supPos = 'supervisor') THEN
            RAISE_APPLICATION_ERROR(-20018, 'The supervisor specified is not in a position of manager or supervisor.' ||
                                            ' SUPERVISOR: ' || :NEW.SUPERVISOR);
        END IF;
    END IF;

    --  3. The staff supervision relationship is hierarchical up to three levels.
    IF :NEW.position = 'manger' AND :NEW.supervisor IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(-20019, 'A staff member specified is a manager and cannot have a supervisor.' ||
                                        ' STAFFNO: ' || :NEW.STAFFNO);
    ELSIF :NEW.position <> 'manager' THEN
        -- go for a loop ride.
        supCount := 1;
        super := :NEW.supervisor;
        WHILE supCount <= 3 AND super is NOT NULL
            LOOP
                SELECT supervisor
                INTO super
                FROM STAFF
                WHERE STAFFNO = super;
                supCount := supCount + 1;
            END LOOP;
    END IF;

    IF supCount > 3 THEN
        RAISE_APPLICATION_ERROR(-20012, 'The staff supervisor relationship is higher than 3.');
    END IF;

END;


-- BUS-ADM 749 Data and Information Management
-- Michael Noel
-- Continental Palms DVD
-- test_execute_procedures.sql


-- FAIL. Member does not exist.
BEGIN DBMS_OUTPUT.PUT_LINE('TEST SHOULD FAIL. ORA-20003. Member does not exist.'); END;
BEGIN PROC_CHECKOUT( THECATALOGNO => 'D00001', THECOPYNO => 1, THEMEMBERNO => 12345); END;

-- FAIL. DVD does not exist.
BEGIN DBMS_OUTPUT.PUT_LINE('TEST SHOULD FAIL. ORA-20001. DVD does not exist.'); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D12345', THECOPYNO => 1, THEMEMBERNO => 10000); END;

-- FAIL. DVDCopy does not exist.
BEGIN DBMS_OUTPUT.PUT_LINE('TEST SHOULD FAIL. ORA-20002. DVDCopy does not exist.'); END;
BEGIN PROC_CHECKOUT( THECATALOGNO => 'D00001', THECOPYNO => 25, THEMEMBERNO => 10000); END;

-- FAIL. DVDCopy Condition is 4
BEGIN DBMS_OUTPUT.PUT_LINE('TEST SHOULD FAIL. ORA-20008. DVDCopy Broken.'); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00007', THECOPYNO => 3, THEMEMBERNO => 10000); END;

-- Create scenarios where:
-- 1. DVDCopy.branchNo is NOT NULL and the DVD is checked out.
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00001', THECOPYNO => 1, THEMEMBERNO => 10000, THERENTALDATE => '01-MAY-2020'); END;
-- create error
UPDATE DVDCOPY SET BRANCHNO = 'IL01' WHERE CATALOGNO = 'D00001' AND COPYNO = 1; COMMIT;
BEGIN DBMS_OUTPUT.PUT_LINE('TEST SHOULD FAIL. ORA-20006. ERROR CHECKOUT NULL CONDITIONS VIOLATED! * 2'); END;
-- check that error runs
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00001', THECOPYNO => 1, THEMEMBERNO => 10000, THERENTALDATE => '03-MAY-2020'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00001', THECOPYNO => 1, THECONDITION => 1, THEBRANCHNO => 'IL02', THERETURNDATE => '04-MAY-2020'); END;
-- correct error and checkin
UPDATE DVDCOPY SET BRANCHNO = Null WHERE CATALOGNO = 'D00001' AND COPYNO = 1; COMMIT;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00001', THECOPYNO => 1, THECONDITION => 1, THEBRANCHNO => 'WI02', THERETURNDATE => '04-MAY-2020'); END;

-- 2. DVDCopy.branchNo is NULL and the Rental.returnDate and Rental.ReturnTo NOT NULL.
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00002', THECOPYNO => 1, THEMEMBERNO => 10001, THERENTALDATE => '04-MAY-2020'); END;
-- create error
UPDATE RENTAL SET RETURNDATE = '05-MAY-2020', RETURNEDTO = 'IL02' WHERE CATALOGNO = 'D00002' AND COPYNO = 1;
BEGIN DBMS_OUTPUT.PUT_LINE('TEST SHOULD FAIL. ORA-20006. ERROR CHECKOUT NULL CONDITIONS VIOLATED! * 2'); END;
-- check that the error runs
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00002', THECOPYNO => 1, THEMEMBERNO => 10000, THERENTALDATE => '04-MAY-2020'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00002', THECOPYNO => 1, THECONDITION => 1, THEBRANCHNO => 'IL02', THERETURNDATE => '05-MAY-2020'); END;
-- correct error and checkin
UPDATE RENTAL SET RETURNDATE = Null, RETURNEDTO = Null WHERE CATALOGNO = 'D00002' AND COPYNO = 1;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00002', THECOPYNO => 1, THECONDITION => 1, THEBRANCHNO => 'WI02', THERETURNDATE => '05-MAY-2020'); END;

-- FAIL. Branch not exist.
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00006', THECOPYNO => 1, THEMEMBERNO => 10002, THERENTALDATE => '07-MAY-2020'); END;
BEGIN DBMS_OUTPUT.PUT_LINE('TEST SHOULD FAIL. ORA-20004. The Branch specified does not exist.'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00006', THECOPYNO => 1, THECONDITION => 1, THEBRANCHNO => 'GA01', THERETURNDATE => '08-MAY-2020'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00006', THECOPYNO => 1, THECONDITION => 1, THEBRANCHNO => 'WI01', THERETURNDATE => '08-MAY-2020'); END;


-- FAIL. ReturnDate before RentDate.
BEGIN DBMS_OUTPUT.PUT_LINE('TEST SHOULD FAIL. ORA-20009. ReturnDate before RentDate.'); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00005', THECOPYNO => 1, THEMEMBERNO => 10001, THERENTALDATE => '01-JUN-2020'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00005', THECOPYNO => 1, THECONDITION => 1, THEBRANCHNO => 'WI01', THERETURNDATE => '31-MAY-2020'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00005', THECOPYNO => 1, THECONDITION => 1, THEBRANCHNO => 'WI01', THERETURNDATE => '04-JUN-2020'); END;

-- SUCCESS. Conditions satisfied.
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00001', THECOPYNO => 2, THEMEMBERNO => 10000, THERENTALDATE=> '01-OCT-2020'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00001', THECOPYNO => 2, THECONDITION => 1, THEBRANCHNO => 'WI01', THERETURNDATE => '31-OCT-2020'); END;

-- FAIL. DVD does not exist.
BEGIN DBMS_OUTPUT.PUT_LINE('TEST SHOULD FAIL. ORA-20001. DVD does not exist.'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D12345', THECOPYNO => 2, THECONDITION => 1, THEBRANCHNO => 'WI01', THERETURNDATE => '02-NOV-2020'); END;

-- FAIL. DVDCopy does not exist.
BEGIN DBMS_OUTPUT.PUT_LINE('TEST SHOULD FAIL. ORA-20002. DVDCopy does not exist.'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00001', THECOPYNO => 25, THECONDITION => 1, THEBRANCHNO => 'WI01', THERETURNDATE => '02-NOV-2020'); END;

-- FAIL DVDCopy already checked in.
BEGIN DBMS_OUTPUT.PUT_LINE('TEST SHOULD FAIL. ORA-200014. DVDCopy already checked in.'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00001', THECOPYNO => 2, THECONDITION => 1, THEBRANCHNO => 'WI01', THERETURNDATE => '02-NOV-2020'); END;


-- Check out a ton of DVDs.
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00001', THECOPYNO => 1, THEMEMBERNO => 10000, THERENTALDATE=> '01-NOV-2020'); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00002', THECOPYNO => 1, THEMEMBERNO => 10000, THERENTALDATE=> '01-NOV-2020'); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00003', THECOPYNO => 1, THEMEMBERNO => 10000, THERENTALDATE=> '01-NOV-2020'); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00004', THECOPYNO => 1, THEMEMBERNO => 10000, THERENTALDATE=> '01-NOV-2020'); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00005', THECOPYNO => 1, THEMEMBERNO => 10000, THERENTALDATE=> '01-NOV-2020'); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00006', THECOPYNO => 1, THEMEMBERNO => 10000, THERENTALDATE=> '01-NOV-2020'); END;

-- FAIL. Try to check out all the DVDs just checked out.
BEGIN DBMS_OUTPUT.PUT_LINE('TEST SHOULD FAIL. ORA-20010. DVDCopy already checked out * 6.'); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00001', THECOPYNO => 1, THEMEMBERNO => 10000, THERENTALDATE=> '02-NOV-2020'); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00002', THECOPYNO => 1, THEMEMBERNO => 10000, THERENTALDATE=> '02-NOV-2020'); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00003', THECOPYNO => 1, THEMEMBERNO => 10000, THERENTALDATE=> '02-NOV-2020'); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00004', THECOPYNO => 1, THEMEMBERNO => 10000, THERENTALDATE=> '02-NOV-2020'); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00005', THECOPYNO => 1, THEMEMBERNO => 10000, THERENTALDATE=> '02-NOV-2020'); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00006', THECOPYNO => 1, THEMEMBERNO => 10000, THERENTALDATE=> '02-NOV-2020'); END;

-- Check them all back in.
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00001', THECOPYNO => 1, THECONDITION => 1, THEBRANCHNO => 'WI02', THERETURNDATE => '02-NOV-2020'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00002', THECOPYNO => 1, THECONDITION => 1, THEBRANCHNO => 'WI02', THERETURNDATE => '02-NOV-2020'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00003', THECOPYNO => 1, THECONDITION => 1, THEBRANCHNO => 'WI02', THERETURNDATE => '02-NOV-2020'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00004', THECOPYNO => 1, THECONDITION => 1, THEBRANCHNO => 'WI02', THERETURNDATE => '02-NOV-2020'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00005', THECOPYNO => 1, THECONDITION => 1, THEBRANCHNO => 'WI02', THERETURNDATE => '02-NOV-2020'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00006', THECOPYNO => 1, THECONDITION => 1, THEBRANCHNO => 'WI02', THERETURNDATE => '02-NOV-2020'); END;

-- Check out a ton of DVDs again.
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00001', THECOPYNO => 1, THEMEMBERNO => 10001, THERENTALDATE=> '01-DEC-2020'); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00002', THECOPYNO => 1, THEMEMBERNO => 10001, THERENTALDATE=> '01-DEC-2020'); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00003', THECOPYNO => 1, THEMEMBERNO => 10001, THERENTALDATE=> '01-DEC-2020'); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00004', THECOPYNO => 1, THEMEMBERNO => 10001, THERENTALDATE=> '01-DEC-2020'); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00005', THECOPYNO => 1, THEMEMBERNO => 10001, THERENTALDATE=> '01-DEC-2020'); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00006', THECOPYNO => 1, THEMEMBERNO => 10001, THERENTALDATE=> '01-DEC-2020'); END;

-- FAIL. Try to check the DVD into a Branch that does not exist.
BEGIN DBMS_OUTPUT.PUT_LINE('TEST SHOULD FAIL. ORA-20004. Branch does not exist * 6.'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00001', THECOPYNO => 1, THECONDITION => 1, THEBRANCHNO => 'IL99', THERETURNDATE => '03-DEC-2020'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00002', THECOPYNO => 1, THECONDITION => 1, THEBRANCHNO => 'IL99', THERETURNDATE => '03-DEC-2020'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00003', THECOPYNO => 1, THECONDITION => 1, THEBRANCHNO => 'IL99', THERETURNDATE => '03-DEC-2020'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00004', THECOPYNO => 1, THECONDITION => 1, THEBRANCHNO => 'IL99', THERETURNDATE => '03-DEC-2020'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00005', THECOPYNO => 1, THECONDITION => 1, THEBRANCHNO => 'IL99', THERETURNDATE => '03-DEC-2020'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00006', THECOPYNO => 1, THECONDITION => 1, THEBRANCHNO => 'IL99', THERETURNDATE => '03-DEC-2020'); END;

-- FAIL. Try to checkin the DVD and the condition is not in (1,2,3,4).
BEGIN DBMS_OUTPUT.PUT_LINE('TEST SHOULD FAIL. ORA-02290. Improper condition * 6.'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00001', THECOPYNO => 1, THECONDITION => 8, THEBRANCHNO => 'IL01', THERETURNDATE => '03-DEC-2020'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00002', THECOPYNO => 1, THECONDITION => 8, THEBRANCHNO => 'IL01', THERETURNDATE => '03-DEC-2020'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00003', THECOPYNO => 1, THECONDITION => 8, THEBRANCHNO => 'IL01', THERETURNDATE => '03-DEC-2020'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00004', THECOPYNO => 1, THECONDITION => 8, THEBRANCHNO => 'IL01', THERETURNDATE => '03-DEC-2020'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00005', THECOPYNO => 1, THECONDITION => 8, THEBRANCHNO => 'IL01', THERETURNDATE => '03-DEC-2020'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00006', THECOPYNO => 1, THECONDITION => 8, THEBRANCHNO => 'IL01', THERETURNDATE => '03-DEC-2020'); END;

-- Check in a ton of DVDs again.
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00001', THECOPYNO => 1, THECONDITION => 2, THEBRANCHNO => 'IL01', THERETURNDATE => '03-DEC-2020'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00002', THECOPYNO => 1, THECONDITION => 2, THEBRANCHNO => 'IL01', THERETURNDATE => '03-DEC-2020'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00003', THECOPYNO => 1, THECONDITION => 2, THEBRANCHNO => 'IL01', THERETURNDATE => '03-DEC-2020'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00004', THECOPYNO => 1, THECONDITION => 2, THEBRANCHNO => 'IL01', THERETURNDATE => '03-DEC-2020'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00005', THECOPYNO => 1, THECONDITION => 2, THEBRANCHNO => 'IL01', THERETURNDATE => '03-DEC-2020'); END;
BEGIN PROC_CHECKIN(THECATALOGNO => 'D00006', THECOPYNO => 1, THECONDITION => 2, THEBRANCHNO => 'IL01', THERETURNDATE => '03-DEC-2020'); END;

-- Check out a ton of DVDs again.
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00001', THECOPYNO => 2, THEMEMBERNO => 10002); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00002', THECOPYNO => 2, THEMEMBERNO => 10002); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00003', THECOPYNO => 1, THEMEMBERNO => 10002); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00004', THECOPYNO => 2, THEMEMBERNO => 10002); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00005', THECOPYNO => 2, THEMEMBERNO => 10002); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00006', THECOPYNO => 2, THEMEMBERNO => 10002); END;

-- FAIL. Check out DVDs with a future date.
BEGIN DBMS_OUTPUT.PUT_LINE('TEST SHOULD FAIL. ORA-20011. Future Rental * 5.'); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00001', THECOPYNO => 1, THEMEMBERNO => 10000, THERENTALDATE => '31-DEC-2021'); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00002', THECOPYNO => 1, THEMEMBERNO => 10000, THERENTALDATE => '31-DEC-2021'); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00004', THECOPYNO => 1, THEMEMBERNO => 10000, THERENTALDATE => '31-DEC-2021'); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00005', THECOPYNO => 1, THEMEMBERNO => 10000, THERENTALDATE => '31-DEC-2021'); END;
BEGIN PROC_CHECKOUT(THECATALOGNO => 'D00006', THECOPYNO => 1, THEMEMBERNO => 10000, THERENTALDATE => '31-DEC-2021'); END;

-- Insert staff into WI03 for staff testing.
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0301','Michael','Noel','manager',99999, '29-MAY-1987','WI03',Null); COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0302','Minion','No1','supervisor',100, '1-JAN-2000','WI03','WI0301'); COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0303','Minion','No2','supervisor',100, '2-JAN-2000','WI03','WI0301'); COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0304','Minion','No3','assistant',50, '3-JAN-2000','WI03','WI0301'); COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0305','Minion','No4','assistant',50, '4-JAN-2000','WI03','WI0301'); COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0306','Minion','No5','assistant',50, '5-JAN-2000','WI03','WI0301'); COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0307','Minion','No6','assistant',50, '6-JAN-2000','WI03','WI0301'); COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0308','Minion','No7','assistant',50, '7-JAN-2000','WI03','WI0301'); COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0309','Minion','No8','assistant',50, '8-JAN-2000','WI03','WI0301'); COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0310','Minion','No9','assistant',50, '9-JAN-2000','WI03','WI0301'); COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0311','Minion','No10','assistant',50, '10-JAN-2000','WI03','WI0301'); COMMIT;
BEGIN DBMS_OUTPUT.PUT_LINE('TEST SHOULD FAIL. ORA-20016. A supervisor may not oversee more than 10 staff.'); END;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0312','Minion','No11','assistant',50, '11-JAN-2000','WI03','WI0301'); COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0313','Minion','No12','assistant',50, '12-JAN-2000','WI03','WI0301'); COMMIT;
-- Correct the error and try to update to make the same error
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0312','Minion','No11','assistant',50, '11-JAN-2000','WI03','WI0302'); COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0313','Minion','No12','assistant',50, '12-JAN-2000','WI03','WI0302'); COMMIT;
-- Update incorrectly
BEGIN DBMS_OUTPUT.PUT_LINE('TEST SHOULD FAIL. ORA-20016. A supervisor may not oversee more than 10 staff.'); END;
UPDATE STAFF SET SUPERVISOR = 'WI0301' WHERE STAFFNO IN ('WI0312', 'WI0313'); COMMIT;

-- DELETE RECORDS FROM TABLE TEST NEXT CONSTRAINT. A supervisor must be in a position of manager or supervisor.
DELETE FROM STAFF WHERE BRANCHNO = 'WI03'; COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0301','Michael','Noel','manager',99999, '29-MAY-1987','WI03',Null); COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0302','Minion','No1','supervisor',100, '1-JAN-2000','WI03','WI0301'); COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0303','Minion','No2','supervisor',100, '2-JAN-2000','WI03','WI0301'); COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0304','Minion','No3','assistant',50, '3-JAN-2000','WI03','WI0302'); COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0305','Minion','No4','assistant',50, '4-JAN-2000','WI03','WI0302'); COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0306','Minion','No5','assistant',50, '5-JAN-2000','WI03','WI0302'); COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0307','Minion','No6','assistant',50, '6-JAN-2000','WI03','WI0302'); COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0308','Minion','No7','assistant',50, '7-JAN-2000','WI03','WI0303'); COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0309','Minion','No8','assistant',50, '8-JAN-2000','WI03','WI0303'); COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0310','Minion','No9','assistant',50, '9-JAN-2000','WI03','WI0303'); COMMIT;
BEGIN DBMS_OUTPUT.PUT_LINE('TEST SHOULD FAIL. ORA-20018. Supervisor specified must be in a position of manager or supervisor.'); END;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0311','Minion','No10','assistant',50, '10-JAN-2000','WI03','WI0304'); COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0312','Minion','No11','assistant',50, '11-JAN-2000','WI03','WI0304'); COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0313','Minion','No12','assistant',50, '12-JAN-2000','WI03','WI0304'); COMMIT;
-- Correct the issue then.
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0312','Minion','No11','assistant',50, '11-JAN-2000','WI03','WI0303'); COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0313','Minion','No12','assistant',50, '12-JAN-2000','WI03','WI0303'); COMMIT;
-- Test the update prevention of the trigger.
UPDATE STAFF SET SUPERVISOR = 'WI0304' WHERE STAFFNO = 'WI0312'; COMMIT;
UPDATE STAFF SET SUPERVISOR = 'WI0304' WHERE STAFFNO = 'WI0313'; COMMIT;

-- DELETE RECORDS FROM TABLE TEST NEXT CONSTRAINT. A supervisor must be in a position of manager or supervisor.
DELETE FROM STAFF WHERE BRANCHNO = 'WI03'; COMMIT;
BEGIN DBMS_OUTPUT.PUT_LINE('TEST SHOULD FAIL. ORA-20018. Supervisor specified is in the position of manager and cannot have a supervisor.'); END;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0301','Michael','Noel','manager',99999, '29-MAY-1987','WI03','WI0102'); COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0301','Michael','Noel','manager',99999, '29-MAY-1987','WI03', Null); COMMIT;
BEGIN DBMS_OUTPUT.PUT_LINE('TEST SHOULD FAIL. ORA-20018. Supervisor specified is in the position of manager and cannot have a supervisor.'); END;
UPDATE STAFF SET SUPERVISOR = 'WI0102' WHERE STAFFNO = 'WI0301'; COMMIT;

INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0302','Minion','No1','supervisor',100, '1-JAN-2000','WI03','WI0301'); COMMIT;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0303','Minion','No2','supervisor',100, '2-JAN-2000','WI03','WI0302'); COMMIT;
BEGIN DBMS_OUTPUT.PUT_LINE('TEST SHOULD FAIL. ORA-200. > 3 hierarchy error.'); END;
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0304','Minion','No3','assistant',50, '3-JAN-2000','WI03','WI0303'); COMMIT;
-- Correct the issue.
INSERT INTO STAFF (STAFFNO, FIRSTNAME, LASTNAME, POSITION, SALARY, DOB, BRANCHNO, SUPERVISOR) VALUES ('WI0304','Minion','No3','assistant',50, '3-JAN-2000','WI03','WI0302'); COMMIT;
BEGIN DBMS_OUTPUT.PUT_LINE('TEST SHOULD FAIL. ORA-200. > 3 hierarchy error.'); END;
-- Test update trigger constraint
UPDATE STAFF SET SUPERVISOR = 'WI0303' WHERE STAFFNO = 'WI0304'; COMMIT;
