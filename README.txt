#Import Procedure

1. **Enrollments deleted**

    Enrollment.delete_all
  
2. **Observations deleted**

    Observation.delete_all
  
3. **Students imported**
  
  Run the query 'student export.sql' in SQLDeveloper and export the result as
  'students\_import.csv'. No modification needed.
  
    ActiveRecord::Base.logger.level = 1

    Student.import('csvs/students_import.csv')
  
4. **Teachers imported**

  Run the query 'teacher export query.sql' in SQLDeveloper and export the result
  as 'teachers\_import.csv'. Check for missing ID numbers and either update
  in PowerSchool and re-run, or add temporary IDs.

    Teacher.import('csvs/teachers_import.csv')
  
5. **Enrollments imported**

  Run the query 'cc export query.sql' in SQLDeveloper and export the result as
  'enrollments_import.csv'. No modification needed.

    ActiveRecord::Base.logger.level = 1
    
    Enrollment.import('csvs/enrollments_import.csv')
  
6. **Scores imported**

  Take the student scores excel doc and save the students tab as values into
  the file 'master raw'.
  Then save that as a .csv and remove all the student information columns
  except scores and the student id, saving it as 'master raw.csv'.
  
  Run the R script 'master scores cleanup.r', which results in
  'scores_import.csv'. No modification needed.
  
  The following code hides SQL statements from the console:
    
    ActiveRecord::Base.logger.level = 1
    
  Then import.
  
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