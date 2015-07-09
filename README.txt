#Import Procedure

1. **Date Enrollments**

    Enrollment.delete_all
  
2. **Delete Observations**

    Observation.delete_all
  
3. **Import Students**
  
  Run the query 'student export.sql' in SQLDeveloper and export the result as
  'students\_import.csv' to '/csvs'. No modification needed.
  
  Set the logger to 1 so that you can see the progress bar.
    
    ActiveRecord::Base.logger.level = 1
    
  Run the student import method. This should import new students, update existing
  ones, and delete ones no longer included in the file.

    Student.import('csvs/students_import.csv')
  
4. **Import Teachers**

  Run the query 'teacher export query.sql' in SQLDeveloper. Visually check for
  missing ID numbers. Get any missing IDs from HR and update them in PowerSchool
  on the staff custom page for ReNEW ID. Or add a temporary ID, usually
  't-lastname'. Re-run and export the result as 'teachers\_import.csv' to
  '/csvs'.
  
  Run the teacher import method.

    Teacher.import('csvs/teachers_import.csv')
  
5. **Update Enrollments**

  Run the query 'cc export query.sql' in SQLDeveloper and export the result as
  'enrollments_import.csv' to '/csvs'. No modification needed.

  Make sure the logger is set to 1 to see the progress bar.
  
    ActiveRecord::Base.logger.level = 1
    
  Run the import method.
    
    Enrollment.import('csvs/enrollments_import.csv')
    
  Any enrollments that are not successfully created will be echoed back with
  some true/false information about the source of the error. Check the import
  method to see the meaning of those.
  
6. **Import Scores**

  Take the finalized scanning report spreadsheet for an MLQ or benchmark. From
  the 'Students' tab, copy the student id, ela benchmark grade, ela average,
  math average, science average, and social average columns onto a new document.
  Name the columns, 'student_number', 'grade', 'ela', 'math', 'sci', and 'soc'.
  Save as a .csv file, with the name of the file being the name of the test.
  For example, 'B1.csv', or 'MLQ2.csv'. Put that file into 'csvs/scores/raw'.
  
  To add additional LEAP scores, add new rows to 'csvs/scores/leap.csv' with the
  appropriate information.
  
  Run 'csvs/scores/scores processing.r'. This will combine all files in the
  'raw' directory with the 'leap.csv' file, format the data for import, and save
  to the 'csvs' directory as 'scores\_import.csv'. No modification is needed.
  
  Make sure the logger is set to 1 to see the progress bar.
    
    ActiveRecord::Base.logger.level = 1
    
  Run the scores import method.
  
    Score.import('csvs/scores_import.csv')
  
7. **Observations imported**

  * Export TIF observations from Whetstone for all dates
  and save as 'observations raw.csv'.
  * Get IDs and emails from HR.
  * Match ID numbers to observations via emails, correcting any errors,
  and labeling the column, "teacher\_number".
  * Manually delete the row columns.
  * Change "RSE" to "SCH" in the school column.
  * Make sure all schools are in the small school format. (Not just "RCAA".)
  * Delete the "course", "grade", and "rubric" columns.
  * Delete teacher email.
  * Find quarter for each observation.
  * Column titles should be...
      * teacher\_number
      * school
      * teacher\_name
      * observer
      * date
      * score
      * year
      * quarter

    Observation.import('csvs/observations_import.csv')