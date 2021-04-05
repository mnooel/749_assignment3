-- BUS-ADM 749 Data and Information Management
-- Michael Noel
-- Continental Palms DVD
-- drop_tables.sql

-- Drop tables before running script.
DROP TABLE Branch CASCADE CONSTRAINTS PURGE;
DROP TABLE BranchTel CASCADE CONSTRAINTS PURGE;
DROP TABLE Staff CASCADE CONSTRAINTS PURGE;
DROP TABLE Manager CASCADE CONSTRAINTS PURGE;
DROP TABLE Member CASCADE CONSTRAINTS PURGE;
DROP TABLE ActorDirector CASCADE CONSTRAINTS PURGE;
DROP TABLE DVD CASCADE CONSTRAINTS PURGE;
-- DROP TABLE ChildrenDVD CASCADE CONSTRAINTS PURGE;
-- DROP TABLE ForeignDVD CASCADE CONSTRAINTS PURGE;
DROP TABLE Makes CASCADE CONSTRAINTS PURGE;
DROP TABLE DVDCopy CASCADE CONSTRAINTS PURGE;
-- DROP TABLE Rental CASCADE CONSTRAINTS PURGE;
