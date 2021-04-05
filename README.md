# [749_assignment3](https://github.com/mnooel/749_assignment3)
#### Michael Noel
Source code repository for assignment 3 project, BUS ADM 749 Spring 2021.

See [sql_scripts](https://github.com/mnooel/749_assignment3/tree/main/sql_scripts) for the bare requirements of the 
assignment.

### Project Structure

This project has four major components found in the directories of the repository.
1. [engine](https://github.com/mnooel/749_assignment3/blob/main/engine/models.py) - 
   python based engine object to interact with the database.
2. [external_data](https://github.com/mnooel/749_assignment3/tree/main/external_data) - 
   .csv files of data to import
3. [logs](https://github.com/mnooel/749_assignment3/blob/main/logs/oracle.log) -
   logs of commands performed by the OracleConnection object found in the engine directory.
4. [sql_scripts](https://github.com/mnooel/749_assignment3/tree/main/sql_scripts) - variety of sql scripts required for the assignment.

There are four other files used to deconstruct then reconstruct the database.
1. [drop_tables.py](https://github.com/mnooel/749_assignment3/blob/main/drop_tables.py) - does just what it sounds like.
2. [create_tables.py](https://github.com/mnooel/749_assignment3/blob/main/create_tables.py) - does just what it sounds like.
3. [insert_data.py](https://github.com/mnooel/749_assignment3/blob/main/insert_data.py) - does just what it sounds like.
4. [tear_down_and_build.py](https://github.com/mnooel/749_assignment3/blob/main/tear_down_and_build.py) - a combination of the three prior files/functions to do it all at once.

