-- BUS-ADM 749 Data and Information Management
-- Michael Noel
-- Continental Palms DVD
-- insert_data.sql

-- Insert Branch data
INSERT INTO Branch (branchNo, street, city, state, zip) VALUES ('WI01', '100 E Capital Dr', 'Milwaukee', 'WI', 53201);
INSERT INTO Branch (branchNo, street, city, state, zip) VALUES ('WI02', '250 N Swan Ave', 'Milwaukee', 'WI', 53217);
INSERT INTO Branch (branchNo, street, city, state, zip) VALUES ('WI03', '750 W Mequon Rd', 'Milwaukee', 'WI', 53221);
INSERT INTO Branch (branchNo, street, city, state, zip) VALUES ('IL01', '844 E Milwaukee Ave', 'Chicago', 'IL', 60601);
INSERT INTO Branch (branchNo, street, city, state, zip) VALUES ('IL02', '777 W Canal St', 'Chicago', 'IL', 60612);

-- Insert Staff data
INSERT INTO Staff (staffNo, firstName, lastName, position, salary, DOB, branchNo, supervisor) VALUES ('WI0101', 'Bob', 'Johnstone', 'manager', 58000, '12-Dec-50', 'WI01', Null);
INSERT INTO Staff (staffNo, firstName, lastName, position, salary, DOB, branchNo, supervisor) VALUES ('WI0102', 'Dan', 'Nieley', 'supervisor', 48000, '17-Oct-60', 'WI01', 'WI0101');
INSERT INTO Staff (staffNo, firstName, lastName, position, salary, DOB, branchNo, supervisor) VALUES ('WI0103', 'Lisa', 'Swan', 'assistant', 38000, '1-Jan-90', 'WI01', 'WI0102');
INSERT INTO Staff (staffNo, firstName, lastName, position, salary, DOB, branchNo, supervisor) VALUES ('WI0104', 'John', 'Smith', 'assistant', 38000, '21-Feb-81', 'WI01', 'WI0102');
INSERT INTO Staff (staffNo, firstName, lastName, position, salary, DOB, branchNo, supervisor) VALUES ('WI0201', 'Lance', 'Oniel', 'manager', 68000, '12-Dec-68', 'WI02', Null);
INSERT INTO Staff (staffNo, firstName, lastName, position, salary, DOB, branchNo, supervisor) VALUES ('WI0202', 'Linda', 'Zahedi', 'supervisor', 58000, '17-Oct-87', 'WI02', 'WI0201');
INSERT INTO Staff (staffNo, firstName, lastName, position, salary, DOB, branchNo, supervisor) VALUES ('WI0203', 'Jennifer', 'Haseman', 'supervisor', 56000, '1-Jan-86', 'WI02', 'WI0202');
INSERT INTO Staff (staffNo, firstName, lastName, position, salary, DOB, branchNo, supervisor) VALUES ('WI0204', 'Ben', 'Sinha', 'assistant', 52000, '21-Feb-88', 'WI02', 'WI0202');

-- Insert ActorDirector data
INSERT INTO ActorDirector (stageName, name, gender) VALUES ('Tom Hanks', 'Thomas Jeffrey Hanks', 'M');
INSERT INTO ActorDirector (stageName, name, gender) VALUES ('Robert Zemeckis', 'Robert Lee Zemeckis', 'M');
INSERT INTO ActorDirector (stageName, name, gender) VALUES ('Liv Tyler', 'Liv Rundgren Tyler', 'F');
INSERT INTO ActorDirector (stageName, name, gender) VALUES ('Steven Spielberg', 'Steven A Spielberg', 'M');
INSERT INTO ActorDirector (stageName, name, gender) VALUES ('Bruce Lee', 'Bruce Lee', 'M');

-- Insert Member data
INSERT INTO Member (firstName, lastName, street, city, state, zip, branchNo, registDate) VALUES ('Min', 'Zhao', '100 W Bradley St', 'Milwaukee', 'WI', 53217, 'WI02', '10-OCT-2002');
INSERT INTO Member (firstName, lastName, street, city, state, zip, branchNo, registDate) VALUES ('Julia', 'Wilson', '200 E Calumet', 'Milwaukee', 'WI', 53216, 'WI02', '11-OCT-2004');
INSERT INTO Member (firstName, lastName, street, city, state, zip, branchNo, registDate) VALUES ('Julia', 'Wilson', '200 E Calumet', 'Milwaukee', 'WI', 53216, 'WI01', '11-OCT-2004');
INSERT INTO Member (firstName, lastName, street, city, state, zip, branchNo, registDate) VALUES ('Michael', 'Noel', 'N53W14170 Invery Dr', 'Menomonee Falls', 'WI', 53051, 'WI01', '11-NOV-2020');

-- Insert DVD data
INSERT INTO DVD (catalogNo, title, category, dailyRent) VALUES ('D00001', 'Forrest Gump', 'drama', 1.99);
INSERT INTO DVD (catalogNo, title, category, dailyRent) VALUES ('D00002', 'That Thing You Do!', 'drama', 1.99);
INSERT INTO DVD (catalogNo, title, category, dailyRent) VALUES ('D00003', 'Saving Private Ryan', 'drama', 1.99);
INSERT INTO DVD (catalogNo, title, category, dailyRent) VALUES ('D00004', 'Band of Brothers', 'tv series', 9.99);
INSERT INTO DVD (catalogNo, title, category, dailyRent) VALUES ('D00005', 'Larry Crowne', 'drama', 2.99);
INSERT INTO DVD (catalogNo, title, category, dailyRent) VALUES ('D00006', 'From the Earth to the Moon', 'tv series', 10.99);
INSERT INTO DVD (catalogNo, title, category, dailyRent) VALUES ('D00007', 'Way of the Dragon', 'action', 1.99);

-- Insert DVDCopy data
INSERT INTO DVDCopy (catalogNo, copyNo, condition, branchNo) VALUES ('D00001', 1, 2, 'WI01');
INSERT INTO DVDCopy (catalogNo, copyNo, condition, branchNo) VALUES ('D00001', 2, 2, 'WI02');
INSERT INTO DVDCopy (catalogNo, copyNo, condition, branchNo) VALUES ('D00001', 3, 3, 'WI03');
INSERT INTO DVDCopy (catalogNo, copyNo, condition, branchNo) VALUES ('D00002', 1, 1, 'IL01');
INSERT INTO DVDCopy (catalogNo, copyNo, condition, branchNo) VALUES ('D00002', 2, 1, 'IL01');
INSERT INTO DVDCopy (catalogNo, copyNo, condition, branchNo) VALUES ('D00002', 3, 1, 'IL02');
INSERT INTO DVDCopy (catalogNo, copyNo, condition, branchNo) VALUES ('D00003', 1, 1, 'WI01');
INSERT INTO DVDCopy (catalogNo, copyNo, condition, branchNo) VALUES ('D00004', 1, 1, 'WI01');
INSERT INTO DVDCopy (catalogNo, copyNo, condition, branchNo) VALUES ('D00004', 2, 1, 'WI02');
INSERT INTO DVDCopy (catalogNo, copyNo, condition, branchNo) VALUES ('D00004', 3, 1, 'IL02');
INSERT INTO DVDCopy (catalogNo, copyNo, condition, branchNo) VALUES ('D00005', 1, 1, 'WI01');
INSERT INTO DVDCopy (catalogNo, copyNo, condition, branchNo) VALUES ('D00005', 2, 1, 'WI01');
INSERT INTO DVDCopy (catalogNo, copyNo, condition, branchNo) VALUES ('D00005', 3, 1, 'WI02');
INSERT INTO DVDCopy (catalogNo, copyNo, condition, branchNo) VALUES ('D00005', 4, 1, 'WI02');
INSERT INTO DVDCopy (catalogNo, copyNo, condition, branchNo) VALUES ('D00006', 1, 1, 'WI01');
INSERT INTO DVDCopy (catalogNo, copyNo, condition, branchNo) VALUES ('D00006', 2, 1, 'WI01');
INSERT INTO DVDCopy (catalogNo, copyNo, condition, branchNo) VALUES ('D00006', 3, 2, 'WI02');
INSERT INTO DVDCopy (catalogNo, copyNo, condition, branchNo) VALUES ('D00006', 4, 1, 'WI03');
INSERT INTO DVDCopy (catalogNo, copyNo, condition, branchNo) VALUES ('D00007', 1, 3, 'WI01');
INSERT INTO DVDCopy (catalogNo, copyNo, condition, branchNo) VALUES ('D00007', 2, 4, 'WI02');
INSERT INTO DVDCopy (catalogNo, copyNo, condition, branchNo) VALUES ('D00007', 3, 4, 'WI03');

-- Insert Makes data
INSERT INTO Makes (stageName, catalogNo, role) VALUES ('Tom Hanks', 'D00001', 'lead actor');
INSERT INTO Makes (stageName, catalogNo, role) VALUES ('Robert Zemeckis', 'D00001', 'director');
INSERT INTO Makes (stageName, catalogNo, role) VALUES ('Tom Hanks', 'D00002', 'director');
INSERT INTO Makes (stageName, catalogNo, role) VALUES ('Liv Tyler', 'D00002', 'lead actress');
INSERT INTO Makes (stageName, catalogNo, role) VALUES ('Tom Hanks', 'D00003', 'lead actor');
INSERT INTO Makes (stageName, catalogNo, role) VALUES ('Steven Spielberg', 'D00003', 'director');
INSERT INTO Makes (stageName, catalogNo, role) VALUES ('Tom Hanks', 'D00004', 'director');
INSERT INTO Makes (stageName, catalogNo, role) VALUES ('Tom Hanks', 'D00005', 'director');
INSERT INTO Makes (stageName, catalogNo, role) VALUES ('Tom Hanks', 'D00006', 'director');
INSERT INTO Makes (stageName, catalogNo, role) VALUES ('Bruce Lee', 'D00007', 'director');

