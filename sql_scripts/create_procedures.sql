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
        RAISE_APPLICATION_ERROR(-20004, 'The Branch specified not exist.' ||
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
            RAISE_APPLICATION_ERROR(-20006,
                                    'DVDCOPY.BRANCHNO: ' || theBranchNo ||
                                    ' RENTAL.RETURNEDTO: ' || theReturnedTo ||
                                    ' RENTAL.RETURNDATE: ' || theReturnDate);
        ELSIF theBranchNo IS NULL AND (theReturnedTo IS NOT NULL OR theReturnDate IS NOT NULL) THEN
            RAISE_APPLICATION_ERROR(-20006,
                                    'DVDCOPY.BRANCHNO: ' || theBranchNo ||
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
    theRentalNo INTEGER := fx_LastRentalNo(theCatalogNo, theCopyNo);
    noRental EXCEPTION;
    isCheckedIn EXCEPTION;
    futureReturn EXCEPTION;

BEGIN

    -- Copy is already checked in if not checked out.
    IF NOT fx_CheckedOut(theCatalogNo, theCopyNo) THEN
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
        RAISE_APPLICATION_ERROR(-20012, 'The DVDCopy has never been rented.' ||
                                        ' CATALOGNO: ' || theCatalogNo ||
                                        ' COPYNO: ' || theCopyNo);
    WHEN isCheckedIn THEN
        RAISE_APPLICATION_ERROR(-20013, 'The DVDCopy has already been checked in.' ||
                                        ' CATALOGNO: ' || theCatalogNo ||
                                        ' COPYNO: ' || theCopyNo);

    WHEN futureReturn THEN
        RAISE_APPLICATION_ERROR(-20014, 'The ReturnDate may not be in the future:' ||
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
    nSubordinates   NUMBER;

    -- 2. A staff member who supervises others is in the position of supervisor or manager.
    supPos          Staff.position%TYPE;

    --  3. The staff supervision relationship is hierarchical up to three levels.
    supCount        NUMBER;
    super           Staff.supervisor%TYPE;

BEGIN

    --  1. A staff member can supervise up to 10 others.
    IF :NEW.supervisor IS NOT NULL THEN
        SELECT COUNT(*)
            INTO nSubordinates
        FROM STAFF
        WHERE SUPERVISOR = :NEW.supervisor;
        IF nSubordinates > 9 THEN
            RAISE_APPLICATION_ERROR(-20015, 'A supervisor may not oversee more than 10 other staff.' ||
                                            ' SUPERVISOR: ' || :NEW.supervisor || 'N_SUPERVISING' || nSubordinates);
        END IF;
    END IF;

    --  2. A staff member who supervises others is in the position of supervisor or manager.
    IF :NEW.position = 'manager' THEN
        RETURN;
    ELSE
        SELECT POSITION
        INTO supPos
        FROM STAFF
        WHERE STAFFNO = :NEW.supervisor;
        IF NOT (supPos = 'manager' OR supPos = 'supervisor') THEN
            RAISE_APPLICATION_ERROR(-20016, 'The supervisor specified is not in a position of manager or supervisor.' ||
                                            ' SUPERVISOR: ' || :NEW.SUPERVISOR);
        END IF;
    END IF;

    --  3. The staff supervision relationship is hierarchical up to three levels.
    IF :NEW.position = 'manger' AND :NEW.supervisor IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(-20017, 'A staff member specified is a manager and cannot have a supervisor.' ||
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
        RAISE_APPLICATION_ERROR(-20018, 'The staff supervisor relationship is higher than 3.');
    END IF;

END;

