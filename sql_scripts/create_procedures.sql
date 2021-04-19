-- BUS-ADM 749 Data and Information Management
-- Michael Noel
-- Continental Palms DVD
-- create_procedures.sql


-- EXTRA PROCEDURE checkOut. Placed before CheckIn since it's the logical sequence of events.
-- Write a procedure named checkOut to checks out a DVDCopy.
-- The procedure takes four parameters: the memberNo, the branchNo, the catalogNo and the copyNo.
-- Since rentalNo is auto sequenced then we should not need a rental number.

CREATE OR REPLACE PROCEDURE CheckOut(
    theCatalogNo DVDCopy.catalogNo%TYPE,
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
