# 749_assignment3
Source code for assignment 3 project, BUS ADM 749 Spring 2021.

### Project Structure

This project has 4 major components found in the directories of the repository.
1. engine: python based engine object to interact with the database.
2. external_data: .csv files of data to import
3. logs: logs of commands performed by the OracleConnection object found in the engine directory.
4. sql_scripts: variety of sql scripts.

There are four other files used to deconstruct then reconstruct the database.
1. drop_tables.py: does just what it sounds like.
2. create_tables.py does just what it sounds like.
3. insert_data.py: does just what it sounds like.
4. tear_down_and_build.py: a combination of the three prior files/functions to do it all at once.

