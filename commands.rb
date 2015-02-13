# Load the postgresql console
psql -h /var/pgsql_socket masterdash


# --Import Proceedure--
# 1. Enrollments deleted
  Enrollment.delete_all
# 2. Observations deleted
  Observation.delete_all
# 3. Students imported
  Student.import('csvs/students_import.csv')
# 4. Teachers imported
  Teacher.import('csvs/teachers_import.csv')
# 5. Enrollments imported
  Enrollment.import('csvs/enrollments_import.csv')
# 6. Scores imported 
  Scores.import('csvs/scores_import.csv')
# 7. Observations imported
  Observation.import('csvs/observations_import.csv')


# Drop the existing database from AWS
dropdb masterdash -h masterdashcurrent.cmyogvwshjn6.us-west-2.rds.amazonaws.com -p 5432 -U masteruser

# Create a new DB on AWS from a local dump
createdb -h masterdashcurrent.cmyogvwshjn6.us-west-2.rds.amazonaws.com -p 5432 -U masteruser -T template0 masterdash

# Pipe local data onto the AWS server
# (might need to change the hostname for the local db)
pg_dump -d masterdash_development -h /var/pgsql_socket | psql -h masterdashcurrent.cmyogvwshjn6.us-west-2.rds.amazonaws.com -p 5432 -U masteruser -d masterdash