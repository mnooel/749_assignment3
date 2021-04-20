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
            RAISE_APPLICATION_ERROR(-20005,
                                    'DVDCOPY.BRANCHNO: ' || theBranchNo ||
                                    ' RENTAL.RETURNEDTO: ' || theReturnedTo ||
                                    ' RENTAL.RETURNDATE: ' || theReturnDate);
        ELSIF theBranchNo IS NULL AND (theReturnedTo IS NOT NULL OR theReturnDate IS NOT NULL) THEN
            RAISE_APPLICATION_ERROR(-20005,
                                    'DVDCOPY.BRANCHNO: ' || theBranchNo ||
                                    ' RENTAL.RETURNEDTO: ' || theReturnedTo ||
                                    ' RENTAL.RETURNDATE: ' || theReturnDate);
            -- The last rental has been returned.
        ELSIF theBranchNo IS NOT NULL AND theReturnedTo IS NOT NULL AND theReturnDate IS NOT NULL THEN
            theResult := FALSE;
            -- Some strange condition passed through unchecked.
        ELSE
            RAISE_APPLICATION_ERROR(-20006,
                                    'UNKNWON HUGE CONDITIONAL OVERSIGHT ERROR IN CHECKEDOUT FUNCTION. ' ||
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
            RAISE_APPLICATION_ERROR(-20007, 'The DVDCopy specified is currently broken.' ||
                                            ' CATALOGNO: ' || theCatalogNo ||
                                            ' COPYNO: ' || theCopyNo ||
                                            ' CONDITON: ' || theCondition);
        END IF;
    END IF;

    RETURN (theResult);

END;


-- Write a test function function to check if the other functions are working.
CREATE OR REPLACE FUNCTION fx_FunFunTest(theCatalogNo DVDCopy.catalogNo%TYPE,
                                         theCopyNo DVDCopy.copyNo%TYPE)
    RETURN CHAR
AS
    -- declare blah
    theResult CHAR := 'UNKNOWN';
BEGIN
    IF fx_CheckedOut(theCatalogNo, theCopyNo) THEN
        theResult := 'YES';
    ELSIF NOT fx_CheckedOut(theCatalogNo, theCopyNo) THEN
        theResult := 'NO';
    ELSE
        RAISE_APPLICATION_ERROR(-20008, 'HUGE FUCKING ERROR IN TEST FX.');
    end if;

    RETURN (theResult);
end;


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

BEGIN

    IF fx_CheckedOut(theCatalogNo, theCopyNo) THEN
        RAISE isCheckedOut;
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
        RAISE_APPLICATION_ERROR(-20009, 'DVDCopy is currently checked out.' ||
                                        ' CATALOGNO: ' || theCatalogNo || ' COPYNO: ' || theCopyNo);
END;


-- EXTRA PROCEDURE checkOut. Placed before CheckIn since it's the logical sequence of events.
-- Write a procedure named checkOut to checks out a DVDCopy.
-- The procedure takes four parameters: the memberNo, the branchNo, the catalogNo and the copyNo.
-- Since rentalNo is auto sequenced then we should not need a rental number.

CREATE OR REPLACE PROCEDURE CheckOut(theCatalogNo DVDCopy.catalogNo%TYPE,
                                     theCopyNo DVDCopy.copyNo%TYPE,
                                     theMember Member.memberNo%TYPE,
                                     theRentalDate DATE DEFAULT SYSDATE)
AS
    -- declare necessary variables.
    flag      NUMBER(1);
    errorNo   NUMBER(5);
    errorMsg  VARCHAR2(255);
    theBranch CHAR(4);
    no_member EXCEPTION;
    copy_broken EXCEPTION;
    no_dvd EXCEPTION;
    no_copy EXCEPTION;
    checked_out EXCEPTION;

BEGIN

    -- CASCADING CONDITION CHECKS.
    -- Procedure must pass all conditions to be rentable.
    -- After all conditions are met the insert/update statements are executed.

    -- Check to see if the member exists.
    SELECT COUNT(*)
    INTO flag
    FROM MEMBER
    WHERE MEMBERNO = theMember;
    IF flag < 1
    THEN
        RAISE no_member;
    ELSE
        -- Check to see if the DVD exists.
        SELECT COUNT(*)
        INTO flag
        FROM DVD
        WHERE CATALOGNO = theCatalogNo;
        IF flag < 1
        THEN
            RAISE no_dvd;
        ELSE
            -- Check to see if the copy exists.
            SELECT COUNT(*)
            INTO flag
            FROM DVDCOPY
            WHERE CATALOGNO = theCatalogNo
              AND COPYNO = theCopyNo;
            IF flag < 1
            THEN
                RAISE no_copy;
            ELSE
                -- Check to see if the copy is already checked out in the DVDCopy table.
                SELECT COUNT(*)
                INTO flag
                FROM DVDCOPY
                WHERE CATALOGNO = theCatalogNo
                  AND COPYNO = theCopyNo
                  AND BRANCHNO IS NULL;
                IF flag > 0
                THEN
                    RAISE checked_out;
                ELSE
                    -- Check to see that the copy is already check out in the Rental table.
                    SELECT COUNT(*)
                    INTO flag
                    FROM RENTAL
                    WHERE CATALOGNO = theCatalogNo
                      AND COPYNO = theCopyNo
                      AND ((RETURNDATE IS NULL) OR (RETURNEDTO IS NULL));
                    IF flag > 0
                    THEN
                        RAISE checked_out;
                    ELSE
                        -- Check to see if the copy is rentable. Condition <> 4
                        SELECT COUNT(*)
                        INTO flag
                        FROM DVDCOPY
                        WHERE CATALOGNO = theCatalogNo
                          AND COPYNO = theCopyNo
                          AND CONDITION <> 4;
                        IF flag < 1
                        THEN
                            RAISE copy_broken;
                        ELSE
                            -- All cascading conditions are satisfied.
                            SELECT DISTINCT BRANCHNO
                            INTO theBranch
                            FROM DVDCOPY
                            WHERE CATALOGNO = theCatalogNo
                              AND COPYNO = theCopyNo;
                            -- Insert a Rental into the rental table.
                            -- 1 passed as the rental number to be replaced with the rental sequence.
                            INSERT INTO RENTAL
                            (CATALOGNO, COPYNO, MEMBERNO, RENTEDFROM, RENTDATE, RETURNEDTO, RETURNDATE)
                            VALUES (theCatalogNo, theCopyNo, theMember, theBranch, theRentalDate, NULL, NULL);

                            -- Update the DVDCopy record to set the branchNo to null.
                            UPDATE DVDCOPY
                            SET BRANCHNO = NULL
                            WHERE CATALOGNO = theCatalogNo
                              AND COPYNO = theCopyNo;

                            -- Commit the changes.
                            COMMIT;
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;


EXCEPTION
    WHEN no_member THEN
        RAISE_APPLICATION_ERROR(
                -20001, 'The specified Member does not exist.'
            || ' MEMBERNO: ' || theMember);
    WHEN no_dvd THEN
        RAISE_APPLICATION_ERROR(
                -20002, 'The specified DVD does not exist.'
            || ' CATALOGNO: ' || theCatalogNo);
    WHEN no_copy THEN
        RAISE_APPLICATION_ERROR(
                -20003, 'The specified DVDCopy does not exist.'
            || ' CATALOGNO: ' || theCatalogNo || ' COPYNO: ' || theCopyNo);
    WHEN checked_out THEN
        RAISE_APPLICATION_ERROR(
                -20004, 'The specified DVDCopy is already checked out.'
            || ' CATALOGNO: ' || theCatalogNo || ' COPYNO: ' || theCopyNo);
    WHEN copy_broken THEN
        RAISE_APPLICATION_ERROR(
                -20005,
                'The specified DVDCopy is broken and cannot be rented.'
                    || ' CATALOGNO: ' || theCatalogNo || ' COPYNO: ' || theCopyNo);
END;/


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

BEGIN

    -- Copy is already checked in if not checked out.
    IF NOT fx_CheckedOut(theCatalogNo, theCopyNo) THEN
        RAISE isCheckedIn;
    ELSIF theRentalNo IS NULL THEN
        RAISE noRental;
    ELSE
        -- Update the rental record.
        UPDATE RENTAL
        SET RETURNDATE = theReturnDate,
            RETURNEDTO = theBranchNo
        WHERE RENTALNO = theRentalNo;

        -- Update the DVDCopy.
        UPDATE DVDCOPY
        SET BRANCHNO = theBranchNo,
            CONDITION = theCondition
        WHERE CATALOGNO = theCatalogNo
          AND COPYNO = theCopyNo;
    END IF;

EXCEPTION
    WHEN noRental THEN
    RAISE_APPLICATION_ERROR(-20010, 'The DVDCopy has never been rented.' ||
                                    ' CATALOGNO: ' || theCatalogNo ||
                                    ' COPYNO: ' || theCopyNo);
    WHEN isCheckedIn THEN
    RAISE_APPLICATION_ERROR(-20011, 'The DVDCopy has already been checked in.' ||
                                    ' CATALOGNO: ' || theCatalogNo ||
                                    ' COPYNO: ' || theCopyNo);

END;


CREATE OR REPLACE PROCEDURE CheckIn(
    theRental Rental.rentalNo%TYPE,
    theBranch Branch.branchNo%TYPE,
    theReturnDate DATE DEFAULT SYSDATE)
AS
    -- declare necessary variables.
    flag         NUMBER(1);
    errorNo      NUMBER(5);
    errorMsg     VARCHAR2(255);
    theCatalogNo CHAR(6);
    theCopyNo    INTEGER;
    no_rental EXCEPTION;
    date_or_to_null_check EXCEPTION;
    branch_not_null EXCEPTION;
    no_branch EXCEPTION;
    checked_in EXCEPTION;

BEGIN

    -- CASCADING CONDITION CHECKS.
    -- Procedure must pass all conditions to be returnable.
    -- After all conditions are met the update statements are executed.

    -- Check whether rental exists.
    SELECT COUNT(*)
    INTO flag
    FROM RENTAL
    WHERE RENTALNO = theRental;
    IF flag < 1 THEN
        RAISE no_rental;
    ELSE
        -- Check if returnedDate is Null and returnTo is not and vice versa.
        SELECT COUNT(*)
        INTO flag
        FROM RENTAL
        WHERE ((RETURNDATE IS NULL) AND (RETURNEDTO IS NOT NULL))
           OR ((RETURNDATE IS NOT NULL) AND (RETURNEDTO IS NULL));
        IF flag > 0
        THEN
            RAISE date_or_to_null_check;
        ELSE
            -- Check whether returnDate and returnBranch indicates rental is NOT checked in.
            SELECT COUNT(*)
            INTO flag
            FROM RENTAL
            WHERE RENTALNO = theRental
              AND ((RETURNDATE IS NULL) AND (RETURNEDTO IS NULL));
            IF flag <> 1 THEN
                RAISE checked_in;
            ELSE
                -- RENTAL exists, not checked in via both returnedTo and returnedDate.
                -- RENTALNO is unique so it's known that only one rental record exists at this point.
                -- Set useful Variables.
                BEGIN
                    SELECT DISTINCT CATALOGNO
                    INTO theCatalogNo
                    FROM RENTAL
                    WHERE RENTALNO = theRental;
                    SELECT DISTINCT COPYNO
                    INTO theCopyNo
                    FROM RENTAL
                    WHERE RENTALNO = theRental;
                END;
                -- Check whether the branch exists.
                SELECT COUNT(*)
                INTO flag
                FROM BRANCH
                WHERE BRANCHNO = theBranch;
                IF flag < 1
                THEN
                    RAISE no_branch;
                ELSE
                    -- Check that the branch on DVDCopy is Null.
                    SELECT COUNT(*)
                    INTO flag
                    FROM DVDCOPY
                    WHERE CATALOGNO = theCatalogNo
                      AND COPYNO = theCopyNo
                      AND BRANCHNO IS NULL;
                    IF flag < 1
                    THEN
                        RAISE branch_not_null;
                    ELSE

                        -- Update the rental record.
                        UPDATE RENTAL
                        SET RETURNDATE = theReturnDate,
                            RETURNEDTO = theBranch
                        WHERE RENTALNO = theRental;

                        -- Update the DVDCopy.
                        UPDATE DVDCOPY
                        SET BRANCHNO = theBranch
                        WHERE CATALOGNO = theCatalogNo
                          AND COPYNO = theCopyNo;

                        -- Commit the updates.
                        COMMIT;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;

EXCEPTION
    WHEN
        no_rental THEN
        RAISE_APPLICATION_ERROR(
                -20006, 'The specified Rental does not exist.'
            || ' RENTALNO: ' || theRental);
    WHEN
        date_or_to_null_check THEN
        RAISE_APPLICATION_ERROR(
                -20007, 'Both returnDate and returnTo for the rental must be null. '
            || 'RENTALNO: ' || theRental);
    WHEN
        branch_not_null THEN
        RAISE_APPLICATION_ERROR(
                -20008, 'The DVDCopy branchNo of the rental specified is not Null. '
            || 'CATALOGNO: ' || theCatalogNo || ' COPYNO: ' || theCopyNo);
    WHEN
        no_branch THEN
        RAISE_APPLICATION_ERROR(
                -20009, 'The specified branch does not exist. '
            || 'BRANCHNO: ' || theBranch);
    WHEN
        checked_in THEN
        RAISE_APPLICATION_ERROR(
                -20010, 'The specified rental is already checked in. '
            || 'RENTALNO: ' || theRental);
END;
/



-- FUNCTION
-- Write a function named RentalAmount to calculate the total amount of a rental.
-- The function takes the rental number as input and returns the total amount.
-- If the rental has not been returned yet, use the current date as the ending date for the calculation.


-- TRIGGER
-- Write a trigger to check and enforce the following constraints when a new record is inserted into the Staff table.
--      1. A staff member can supervise up to 10 others.
--      2. A staff member who supervises others is in the position of supervisor or manager.
--      3. The staff supervision relationship is hierarchical up to three levels.
