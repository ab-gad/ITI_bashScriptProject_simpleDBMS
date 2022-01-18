#!/bin/bash

echo 'Welcome to SDBMS !'

if [[ ! -d $HOME/SDBMS ]];
then	  mkdir $HOME/SDBMS;
	  cd $HOME/SDBMS;
else
	  cd $HOME/SDBMS;
fi

function mainOptions {
	clear;
	select option in 'CREATE DB' 'LIST DBs' 'CONNECT TO DB' 'DROP DB' 'Clear' 'Quit';
	do 
		case $REPLY in 
			1) echo -e "\n ---------------------------------------------------- \n CREATE DATABASE\n"; createDB;
				;;
			2) echo -e "\n ---------------------------------------------------- \n LIST DATABASES\n"; ls $HOME/SDBMS;
				;;
			3) echo -e "\n ---------------------------------------------------- \n CONTECT TO DATABASE\n"; connectDB;
				;;
			4) echo -e "\n ---------------------------------------------------- \n DROP DATABASE\n"; dropDB;
				;;
			5) clear;
				;;
			6) echo -e "\n ---------------------------------------------------- \n";  echo 'EXIT'; cd $HOME ; break; 
				;;	
			*) echo 'Pls choose a valid option'
				;;
		esac
	done	

}


function createDB {
	read -p "Enter Database Name : " dbName;
	if [[ ! -d $HOME/SDBMS/$dbName ]];
		then	
			mkdir $HOME/SDBMS/$dbName;
			echo $dbName" Database Created Successfully" ;
		else
			echo "This Database is Exists";
	fi

}

function connectDB {
	echo  "Enter Database Name: "
	read dbName
	cd $HOME/SDBMS/$dbName 2>>$HOME/.error.logi
  	if [[ $? == 0 ]]; 
		then
			clear;
    			echo "Database $dbName was Successfully Selected";
			showTableOptions
				
 		else
   			echo "Database $dbName wasn't found"
   
	fi
}

function dropDB {
	echo  "Enter Database Name:"
	read dbName
	rm -r $HOME/SDBMS/$dbName 2>>$HOME/.error.log
	if [[ $? == 0 ]]; 
		then
    			echo "Database Dropped Successfully"
  		else
    			echo "Database Not found"
  	fi
 
}

function showTableOptions {

	select option in 'SHOW TABLES' 'CREATE TABLE' 'DROP TABLE' 'SELECT FROM' 'DELETE FROM' 'INSERT INTO' 'UPDATE TABLE' 'Back to Main Menu' 'Clear';
	do
		case $REPLY in
			1)echo -e "\n ---------------------------------------------------- \n Tables List:\n"; ls;
				;;
			2)echo -e "\n ---------------------------------------------------- \n Create table:\n"; createTable;
				;;
			3)echo -e "\n ---------------------------------------------------- \n Drop table:\n"; dropTable;
				;;
			4)echo -e "\n ---------------------------------------------------- \n Select from:\n"; selectFromTable;
				;;
			5)echo -e "\n ---------------------------------------------------- \n Delete from:\n"; deleteFromTable;
				;;
			6)echo -e "\n ---------------------------------------------------- \n Insert into:\n"; insertIntoTable;
				;;
			7)echo -e "\n ---------------------------------------------------- \n Update Table:\n"; updateTable;
				;;
			8)cd ../ ; mainOptions ;
				;;
			9)clear; 
				;;
			*)echo 'Please choose a valid option'
				;;
		esac

	done
}


function createTable {
	echo -e "Table Name: \c"
  	read tableName
  	if [[ -f $tableName ]]; then
    		echo -e "table already existed ,choose another name\n";
    		showTableOptions;
  	fi
  	echo -e "Number of Columns: \c"
  	read colsNum

  	counter=1
  	sep="|"
  	rSep="\n"
  	pKey=""
  	metaData="Field"$sep"Type"$sep"key"
	tableData=""

  	while [ $counter -le $colsNum ]
  	do
  		echo -e "Name of Column No.$counter: \c"
    		read colName

    		echo -e "Type of Column $colName: "
    		select var in "int" "str"
    		do
    			case $var in
        			int ) colType="int";break
					;;
        			str ) colType="str";break
					;;
        			* ) echo "Wrong Choice" 
					;;
      			esac
    		done

    		if [[ $pKey == "" ]]; 
		then
      			echo -e "Make PrimaryKey ? "
      			select var in "yes" "no"
      			do
        			case $var in
          				yes ) pKey="PK";
          					metaData+=$rSep$colName$sep$colType$sep$pKey;
          					break;;
          				no )
          					metaData+=$rSep$colName$sep$colType$sep""
          					break;;
          				* ) echo "Wrong Choice" ;;
        			esac
      			done
    		else
      			metaData+=$rSep$colName$sep$colType$sep""
    		fi

    		if [[ $counter == $colsNum ]]; 
    		then
    			tableData=$tableData$colName
    		else
      			tableData=$tableData$colName$sep
    		fi
    		((counter++))
	done

	touch .$tableName
  	echo -e $metaData  >> .$tableName
  	touch $tableName
  	echo -e $tableData >> $tableName
  	if [[ $? == 0 ]]
  	then
    		echo "Table Created Successfully"
    		showTableOptions;
  	else
    		echo "Error Creating Table $tableName"
    		showTableOptions;
  	fi
}

function dropTable {
	echo -e "Enter Table Name: \c"
  	read tableName
  	rm $tableName .$tableName 2>>./.error.log
  	if [[ $? == 0 ]]
  	then
    		echo -e "Table $tableName Dropped Successfully \n"
  	else
   		echo -e "Table $tableName is Not Existed \n"
  	fi
  	showTableOptions;
}

function insertIntoTable {
	echo -e "Table Name: \c"
  	read tableName
  	if ! [[ -f $tableName ]]; 
	then
    		echo "Table $tableName isn't existed ,choose another Table"
    		showTableOptions;
  	fi
  	colsNum=`awk 'END{print NR}' .$tableName`
  	sep="|"
  	rSep="\n"
  	for (( i = 2; i <= $colsNum; i++ )); 
	do
    		colName=$(awk 'BEGIN{FS="|"}{ if(NR=='$i') print $1}' .$tableName)
    		colType=$( awk 'BEGIN{FS="|"}{if(NR=='$i') print $2}' .$tableName)
    		colKey=$( awk 'BEGIN{FS="|"}{if(NR=='$i') print $3}' .$tableName)
    		echo -e "$colName ($colType) = \c"
    		read data

    		# Validate Input
		if [[ $colType == "str" ]];
		then
			while ! [[ $data =~ ^[a-zA-Z]*$ ]];
			do
				echo -e "DataType should be string"
				echo -e "$colName ($colType) = \c"
				read data
			done
		fi

    		if [[ $colType == "int" ]]; 
		then
      			while ! [[ $data =~ ^[0-9]*$ ]]; 
			do
        			echo -e "DataType should be integer"
        			echo -e "$colName ($colType) = \c"
        			read data
      			done
    		fi

    		if [[ $colKey == "PK" ]]; 
		then
      			while [[ true ]]; 
			do
				existedVal=$(awk 'BEGIN{FS="|"}{if ($(('$i'-1)) =="'$data'") print $(('$i'-1))}' $tableName 2>>./.error.log)
                		if [[ $existedVal == "" ]]
                     		then
          				break;
        			else
          				echo -e "$existedVal is existed choose anothe vlue for the PK"
        				echo -e "$colName ($colType) = \c"
        				read data
				fi
      			done
    		fi

    		#Set row
    		if [[ $i == $colsNum ]]; 
		then
      			row=$row$data$rSep
    		else
      			row=$row$data$sep
    		fi
  	done
  	echo -e $row"\c" >> $tableName
  	if [[ $? == 0 ]]
  	then
    		echo "Data Inserted Successfully"
  	else
    		echo "Error Inserting Data into Table $tableName"
  	fi
  	row=""
  	showTableOptions;
}

function selectFromTable {
	
	echo 'SELECT OPTIONS:';
	select option in 'Select All' 'Select All Where' 'Back to table Menu' 
	do
		case $REPLY in 
			1)echo -e "\n ---------------------------------------------------- \n SELECT ALL \n"; selectAll;
				;;
			2)echo -e "\n ---------------------------------------------------- \n SELECT ALL WHERE\n"; selectAllWhere;
				;;
			3)echo -e "\n ---------------------------------------------------- \n BACK TO TABLES MENUE\n"; showTableOptions;
				;;
			*)echo -e "\n ---------------------------------------------------- \n Pls Enter a valid Option\n"
				;;
		esac
	done

}

function selectAll {
  	echo -e "Enter Table Name: \c";
 	read tableName

	if ! [[ -f $tableName ]];
        then
                echo "Table $tableName isn't existed ,choose another Table";
	else
	       	column -t -s '|' $tableName 2>>./.error.log;	
		if [[ $? != 0 ]]
        	then
                	echo "Error Displaying Table $tName"
        	fi

       	fi
}

function selectAllWhere {
  	echo -e "SELECT ALL FROM: \c"
  	read tName

	if ! [[ -f $tName ]];
        then
                echo "Table $tName isn't existed ,choose another Table";
                selectFromTable;
        fi

	echo -e "WHERE (COL): \c"
  	read field
  	fid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tName)
  	if [[ $fid == "" ]]
  	then
    		echo "Column $field not found";
    		selectFromTable;	
  	else
  		echo -e "Operators: [==, !=, >, <, >=, <=] \nSelect OPERATOR: \c"
    		read op
    		if [[ $op == "==" ]] || [[ $op == "!=" ]] || [[ $op == ">" ]] || [[ $op == "<" ]] || [[ $op == ">=" ]] || [[ $op == "<=" ]]
    		then
      			echo -e "Select all where $field $op: TYPE VALUE \c"
      			read val
      			res=$(awk 'BEGIN{FS="|"}{if ($'$fid$op$val') print $0}' $tName 2>>./.error.log)
      			if [[ $res == "" ]]
      			then
        			echo "No Results";
        			selectFromTable;
      			else
        			echo -e "\n ---------------------------------------------------- \n"
				awk 'BEGIN{FS="|"}{if ($'$fid$op$val' || NR == 1) print $0}' $tName 2>>./.error.log |  column -t -s '|';
        			echo -e "\n ---------------------------------------------------- \n"
      			fi
    		else
      			echo "Unsupported Operator\n";
      			selectFromTable
    		fi
  	fi
}





function updateTable {
  	echo -e "Enter Table Name: \c"
  	read tName

  	if ! [[ -f $tName ]];
        then
                echo "Table $tName isn't existed ,choose another Table";
		showTableOptions;
	fi

	echo -e "WHERE TO UPDATE (COL): \c"
  	read field
  	fid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tName)
  	
	if [[ $fid == "" ]]
  	then
    		echo "Not Found"
    		showTableOptions;
  	else
		echo -e "WHERE TO UPDATE (VAL): \c"
    		read val
    		res=$(awk 'BEGIN{FS="|"}{if ($'$fid'=="'$val'") print $'$fid'}' $tName 2>>./.error.log)
    		if [[ $res == "" ]]
    		then
      			echo "Value Not Found"
      			showTableOptions;
    		else
			echo -e "WHAT TO UPDATE (COL): \c"
      			read setField
      			setFid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$setField'") print i}}}' $tName)
      			if [[ $setFid == "" ]]
      			then
        			echo "Not Found"
        			showTableOptions;
     		 	else
				echo -e "WHAT TO UPDATE (VAL): \c"
        			read newValue
        			NR=$(awk 'BEGIN{FS="|"}{if ($'$fid' == "'$val'") print NR}' $tName 2>>./.error.log)
        			oldValue=$(awk 'BEGIN{FS="|"}{if(NR=='$NR'){for(i=1;i<=NF;i++){if(i=='$setFid') print $i}}}' $tName 2>>./.error.log)
        			echo $oldValue
        			sed -i "$NR s/$oldValue/'$newValue'/g" $tName 2>>./.error.log
        			echo "Row Updated Successfully"
        			showTableOptions;
      			fi
    		fi
  	fi
}

function deleteFromTable {
  	echo -e "Enter Table Name: \c"
  	read tName

	if ! [[ -f $tName ]];
        then
                echo "Table $tName isn't existed ,choose another Table";
                showTableOptions;
        fi

	echo -e "Delete WHERE (Col): \c"
  	read field
  	fid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tName)
  	if [[ $fid == "" ]]
  	then
    		echo "Not Found"
    		showTableOptions;
  	else
    		echo -e "Enter WHERE $field equl to: \c"
    		read val
    		res=$(awk 'BEGIN{FS="|"}{if ($'$fid'=="'$val'") print $'$fid'}' $tName 2>>./.error.log)
    		if [[ $res == "" ]]
    		then
      			echo "Value Not Found"
      			showTableOptions;
    		else
      			NR=$(awk 'BEGIN{FS="|"}{if ($'$fid'=="'$val'") print NR}' $tName 2>>./.error.log)
      			sed -i ''$NR'd' $tName 2>>./.error.log
      			echo "Record Deleted Successfully"
      			showTableOptions;
    		fi
  	fi
}


mainOptions
