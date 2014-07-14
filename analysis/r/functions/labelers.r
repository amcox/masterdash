short_labeller <- function(var, value){
    value <- as.character(value)
    if (var=="subject") { 
        value[value=="ela"] <- "ELA"
        value[value=="math"]   <- "Math"
				value[value=="sci"]   <- "Science"
				value[value=="ss"]   <- "Soc. Stud."
        value[value=="soc"]   <- "Soc. Stud."
				value[value=="t"]   <- "All"
        value[value=="all"]   <- "All"
        value[value=="All"]   <- "All"
				value[value=="T"]   <- "All"
    }
		if (var=="grade") { 
				value[value==0] <- "K"
				value[value==1] <- "1st"
				value[value==2] <- "2nd"
        value[value==3] <- "3rd"
        value[value==4]   <- "4th"
				value[value==5]   <- "5th"
				value[value==6]   <- "6th"
				value[value==7]   <- "7th"
				value[value==8]   <- "8th"
				value[value=="0-2"]   <- "K-2"
				value[value=="3-5"]   <- "3-5"
				value[value=="6-8"]   <- "6-8"
				value[value=="3-8"]   <- "3-8"
				value[value=="0_2"]   <- "K-2"
				value[value=="3_5"]   <- "3-5"
				value[value=="6_8"]   <- "6-8"
				value[value=="3_8"]   <- "3-8"
				value[value=="All"]   <- "All"
				value[value=="all"]   <- "All"
        value[value=="0-8"]   <- "K-8"
        value[value=="0_8"]   <- "K-8"
    }
		if (var=="school") { 
        value[value=="RCAA"] <- "RCAA"
        value[value=="STA"]   <- "STA"
				value[value=="DTA"]   <- "DTA"
				value[value=="SCH"]   <- "SCH"
				value[value=="All"]   <- "All"
        value[value=="all"]   <- "All"
    }
    return(value)
}
long_labeller <- function(var, value){
    value <- as.character(value)
    if (var=="subject") { 
        value[value=="ela"] <- "ELA"
        value[value=="math"]   <- "Math"
				value[value=="sci"]   <- "Science"
				value[value=="ss"]   <- "Social Studies"
        value[value=="soc"]   <- "Social Studies"
				value[value=="t"]   <- "All Subjects"
				value[value=="T"]   <- "All Subjects"
        value[value=="all"]   <- "All Subjects"
    }
		if (var=="grade") { 
				value[value==0] <- "Kindergarten"
				value[value==1] <- "1st Grade"
				value[value==2] <- "2nd Grade"
        value[value==3] <- "3rd Grade"
        value[value==4]   <- "4th Grade"
				value[value==5]   <- "5th Grade"
				value[value==6]   <- "6th Grade"
				value[value==7]   <- "7th Grade"
				value[value==8]   <- "8th Grade"
				value[value=="0-2"]   <- "K-2 Grades"
				value[value=="3-5"]   <- "3-5 Grades"
				value[value=="6-8"]   <- "6-8 Grades"
				value[value=="3-8"]   <- "3-8 Grades"
				value[value=="0_2"]   <- "K-2 Grades"
				value[value=="3_5"]   <- "3-5 Grades"
				value[value=="6_8"]   <- "6-8 Grades"
				value[value=="3_8"]   <- "3-8 Grades"
				value[value=="t"]   <- "All Grades"
				value[value=="T"]   <- "All Grades"
        value[value=="all"]   <- "All Grades"
    }
		if (var=="school") { 
        value[value=="RCAA"] <- "RCAA"
        value[value=="STA"]   <- "STA"
				value[value=="DTA"]   <- "DTA"
				value[value=="SCH"]   <- "SCH"
				value[value=="All"]   <- "All Schools"
        value[value=="all"]   <- "All Schools"
    }
    return(value)
}