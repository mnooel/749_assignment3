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
