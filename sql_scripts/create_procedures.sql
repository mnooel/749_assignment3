-- BUS-ADM 749 Data and Information Management
-- Michael Noel
-- Continental Palms DVD
-- create_procedures.sql


-- TRIGGER
-- I wanted to try my hand out at using sequences.
-- In create_table.sql I have define a sequence for rental. In drop_tables.sql I drop it for testing purposes.
-- The trigger should use the next val of the sequence when a rental is inserted.
-- Note that in the test data for assignment 4 the rental number is a type char(6).
--      I am using an integer for the rentalNo starting at 100000.
--      Another digit place to the rentalNo should not be needed for 1 million rentals.
--      Continental Palms DVD should be doing pretty go then.

CREATE OR REPLACE TRIGGER rental_on_insert
    BEFORE INSERT ON RENTAL
    FOR EACH ROW
BEGIN
    SELECT RENTAL_SEQUENCE.nextval
        INTO :new.rentalNo
        FROM DUAL;
END;/


-- EXTRA PROCEDURE checkOut. Placed before CheckIn since it's the logical sequence of events.
-- Write a procedure named checkOut to checks out a DVDCopy.
-- The procedure takes four parameters: the memberNo, the branchNo, the catalogNo and the copyNo.
-- Since rentalNo is auto sequenced then we should not need a rental number.

CREATE OR REPLACE PROCEDURE CheckOut (
    theCatalogNo    DVDCopy.catalogNo%TYPE,
    theCopyNo       DVDCopy.copyNo%TYPE,
    theMember       Member.memberNo%TYPE)
AS
    -- declare necessary variables.
    flag            NUMBER(1);
    theBranch       CHAR(4);
    errorNo         NUMBER(5);
    errorMsg        VARCHAR2(100);
    no_member       EXCEPTION;
    no_branch       EXCEPTION;
    no_dvd          EXCEPTION;
    no_copy         EXCEPTION;
    checked_out     EXCEPTION;

BEGIN

    -- Check to see if the member exists.
    SELECT COUNT(*) INTO flag
        FROM MEMBER
    WHERE
        MEMBERNO = theMember;
    IF flag < 1 THEN
        RAISE no_member;
    END IF;

    -- put branch into the branch
    SELECT
        DISTINCT BRANCHNO INTO thebranch
    FROM DVDCOPY
    WHERE
          CATALOGNO = theCatalogNo
      AND COPYNO = theCopyNo;

    -- Check to see if the DVD exists.
    SELECT COUNT(*) INTO flag
        FROM DVD
    WHERE CATALOGNO = theCatalogNo;
    IF flag < 1 THEN
        RAISE no_dvd;
    END IF;

    -- Check to see if the copy exists.
    SELECT COUNT(*) INTO flag
        FROM DVDCOPY
    WHERE
        CATALOGNO = theCatalogNo
        AND COPYNO = theCopyNo;
    IF flag < 1 THEN
        RAISE no_copy;
    END IF;

    -- Check to see that the copy is not already check out in the DVDCopy table.
    SELECT COUNT(*) INTO flag
        FROM DVDCOPY
    WHERE
        CATALOGNO = theCatalogNo
    AND COPYNO = theCopyNo
    AND BRANCHNO IS NULL;
    IF flag <> 0 THEN
        RAISE checked_out;
    END IF;

    -- Check to see that the copy is not already check out in the Rental table.
    SELECT COUNT(*) INTO flag
        FROM RENTAL
    WHERE
        CATALOGNO = theCatalogNo
    AND COPYNO = theCopyNo
    AND ((RETURNDATE IS NOT NULL) OR (RETURNEDTO IS NOT NULL));
    IF flag <> 0 THEN
        RAISE checked_out;
    END IF;

    -- INSERT a rental.
    INSERT INTO RENTAL (CATALOGNO, COPYNO, MEMBERNO, RENTEDFROM, RENTDATE, RETURNEDTO, RETURNDATE)
    VALUES (theCatalogNo, theCopyNo, theMember, theBranch, SYSDATE, NULL, NULL);
    -- UPDATE the DVDCopy.
    UPDATE  DVDCOPY
        SET
            BRANCHNO = NULL
        WHERE
            CATALOGNO = theCatalogNo
        AND COPYNO = theCopyNo;

EXCEPTION
    WHEN no_member THEN
    RAISE_APPLICATION_ERROR(
        -20001, 'PROCEDURE.CHECKOUT EXCEPTION | The specified member does not exist. MEMBERNO: ' || theMember);
    WHEN no_branch THEN
    RAISE_APPLICATION_ERROR(
        -20002, 'PROCEDURE.CHECKOUT EXCEPTION | The specified branch does not exist. BRANCHNO: ' || theBranch);
    WHEN no_dvd THEN
    RAISE_APPLICATION_ERROR(
        -20003, 'PROCEDURE.CHECKOUT EXCEPTION | The specified DVD does not exist. CATALOGNO: ' || theCatalogNo);
    WHEN no_copy THEN
    RAISE_APPLICATION_ERROR(
        -20004, 'PROCEDURE.CHECKOUT EXCEPTION | The specified DVDCopy is already checked out. CATALOGNO: '
                    || theCatalogNo || ' COPYNO: ' || theCopyNo);
    WHEN checked_out THEN
    RAISE_APPLICATION_ERROR(
        -20005, 'PROCEDURE.CHECKOUT EXCEPTION | The specified DVDCopy is already checked out. CATALOGNO: '
                    || theCatalogNo || ' COPYNO: ' || theCopyNo);
END;/


-- PROCEDURE
-- Write a procedure named CheckIn to check in a returned DVDCopy.
-- The procedure takes two parameters: the rentalNo and the branchNo where the DVDCopy is returned.
-- The procedure should fill in the returnedTo and returnDate attributes of the Rental record and update the \
-- the branchNo of the DVDCopy record.
-- Note that a rental cannot be checked in multiple times.

CREATE OR REPLACE PROCEDURE CheckIn (theRental Rental.rentalNo%TYPE, theBranch Branch.branchNo%TYPE)
AS
    -- declare necessary variables.
    flag            NUMBER(1);
    errorNo         NUMBER(5);
    errorMsg        VARCHAR2(100);
    no_rental       EXCEPTION;
    no_branch       EXCEPTION;
    checked_in      EXCEPTION;

BEGIN
    -- Check whether rental exists.
    SELECT COUNT(*) INTO flag
    FROM RENTAL
    WHERE RENTALNO = theRental;
    IF flag < 1 THEN
        RAISE no_rental;
    END IF;

    -- Check whether branch exists.
    SELECT COUNT(*) INTO flag
    FROM BRANCH
        WHERE BRANCHNO = theBranch;
    IF flag < 1 THEN
        RAISE no_branch;
    END IF;

    -- Check whether rental still outstanding.
    SELECT COUNT(*) INTO flag
    FROM RENTAL
    WHERE RENTALNO = theRental
    AND RETURNEDTO IS NULL
    AND RETURNDATE IS NULL;
    IF flag <> 1 THEN
        RAISE checked_in;
    END IF;

    -- Pass properties to the rental.
    UPDATE  RENTAL
        SET
            RETURNDATE = SYSDATE,
            RETURNEDTO = theBranch
        WHERE
            RENTALNO = theRental;
    -- Pass properties to DVDCopy.
    UPDATE DVDCOPY
        SET
            BRANCHNO = theBranch
        WHERE
            CATALOGNO = (SELECT CATALOGNO FROM RENTAL WHERE RENTALNO = theRental)
            AND COPYNO = (SELECT COPYNO FROM RENTAL WHERE RENTALNO = theRental);

EXCEPTION
    WHEN no_rental THEN
    RAISE_APPLICATION_ERROR(
        -20006, CONCAT('PROCEDURE.CHECKIN EXCEPTION | The specified rental does not exist. RENTALNO: ',
                        theRental));
    WHEN no_branch THEN
    RAISE_APPLICATION_ERROR(
        -20007, CONCAT('PROCEDURE.CHECKIN EXCEPTION | The specified branch does not exist. BRANCHNO: ',
                        theBranch));
    WHEN checked_in THEN
    RAISE_APPLICATION_ERROR(
        -20008, CONCAT('PROCEDURE.CHECKIN EXCEPTION | The specified rental is already checked in. RENTALNO: ',
                        theRental));

END;/


-- FUNCTION
-- Write a function named RentalAmount to calculate the total amount of a rental.
-- The function takes the rental number as input and returns the total amount.
-- If the rental has not been returned yet, use the current date as the ending date for the calculation.



-- TRIGGER
-- Write a trigger to check and enforce the following constraints when a new record is inserted into the Staff table.
--      1. A staff member can supervise up to 10 others.
--      2. A staff member who supervises others is in the position of supervisor or manager.
--      3. The staff supervision relationship is hierarchical up to three levels.
