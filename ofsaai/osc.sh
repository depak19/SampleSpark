#!/bin/ksh
# ------------------------------------------------------------------------------------------
#   Prerequisites	:
#   SHELL       (Required) Use KSH shell            
#   Execute the .profile of the logged user
#   This script waits for user input hence don't execute as backend process.
#   Assumes that OFSAAI installation is over and all the environment variables 
#   related to OFSAAI are set.
#
# --------------------------------------------------------------------------------------------
#VARIABLE INITILISATION
. ~/.profile
OFSAAI_HOME=$FIC_HOME
if [[ -z "${FIC_HOME}" ]] ; then
  echo " FIC_HOME variable is not set. For installation, FIC_HOME variable should be set in .profile file to User Installation directory value."
  exit 1
fi
if [[ $PWD = *$FIC_HOME* ]];then
	  echo "ERROR: Installation kit cannot be a directory under $FIC_HOME."
      exit 1	  
fi
cd ..

currdir=`pwd`
PackName=$(basename $(dirname $currdir))
PACK_ID=${PackName%"_PACK"}


mode='online'
issilent='false'

if [[ -z "$IS_ADW" ]]; then
IS_ADW=FALSE
export IS_ADW
fi
if [[ -z "$OFS_ORA_WAL_ENABLED" ]]; then
OFS_ORA_WAL_ENABLED=FALSE
export OFS_ORA_WAL_ENABLED
fi
# if [ $# -eq 0 ]; then
# echo Error: - Please provide proper number of arguments;
# exit 0;
# fi

if [ $# -gt 3 -o $# -eq 0 ]; then
echo Error: - Please provide proper number of arguments; 
exit;
elif [ $# -eq 2 ]; then
arg1=$(echo $1 | tr '[:lower:]' '[:upper:]')
arg2=$(echo $2 | tr '[:lower:]' '[:upper:]') 

 if [ $arg1 = "-O" -o $arg2 = "-O" ]; then
    mode='offline';  
 fi
 
 if [ $arg1 = "-S" -o $arg2 = "-S" ]; then
    issilent='true';  
 fi
 
 if [ $arg1 != "-O" -a $arg1 != "-S" ] ||  [ $arg2 != "-O" -a $arg2 != "-S" ]; then
    echo Error: - Please provide proper arguments; 
	exit; 
 fi
elif [ $# -eq 1 ]; then
arg1=$(echo $1 | tr '[:lower:]' '[:upper:]')
	if [[ $arg1 = "-O" ]]; then
	mode='offline'
	elif [[ $arg1 = "-S" ]]; then
	issilent='true'
	else
	echo Error: - Please provide proper arguments; 
	exit;
	fi
elif [ $# -eq 3 ]; then
arg1=$(echo $1 | tr '[:lower:]' '[:upper:]')
arg2=$(echo $2 | tr '[:lower:]' '[:upper:]') 
arg3=$(echo $3 )
 if [ $arg1 = "-O" -o $arg2 = "-O" ]; then
    mode='offline';  
 fi
 
 if [ $arg1 = "-S" -o $arg2 = "-S" ]; then
    issilent='true';  
 fi
echo $arg1
echo $arg2
echo $arg3

if [ $arg2 -eq "TCPS" ]; then
if [ ! -z $OFS_ORA_WAL_ENABLED ] && [ $(echo $OFS_ORA_WAL_ENABLED | tr '[:lower:]' '[:upper:]') = "FALSE" ] ; then
X_ARGS_GEN="-Doracle.net.tns_admin=$TNS_ADMIN -Doracle.net.wallet_location=(SOURCE=(METHOD=file)(METHOD_DATA=(DIRECTORY=$arg3))) -Doracle.net.ssl_server_dn_match=true -Djavax.net.ssl.trustStoreType=SSO -Djavax.net.ssl.trustStore=cwallet.sso -Doracle.net.ssl_version=1.2" 
echo $X_ARGS_GEN
export X_ARGS_GEN
elif [ ! -z $OFS_ORA_WAL_ENABLED ] && [ $(echo $OFS_ORA_WAL_ENABLED | tr '[:lower:]' '[:upper:]') = "TRUE" ] ; then
X_ARGS_GEN="-Doracle.net.tns_admin=$TNS_ADMIN -Doracle.net.wallet_location=$arg3 -Doracle.net.ssl_server_dn_match=true -Djavax.net.ssl.trustStoreType=SSO -Djavax.net.ssl.trustStore=cwallet.sso -Doracle.net.ssl_version=1.2" 
echo $X_ARGS_GEN
export X_ARGS_GEN
fi
if [ ! -z $OFS_ORA_WAL_ENABLED ] && [ $(echo $OFS_ORA_WAL_ENABLED | tr '[:lower:]' '[:upper:]') = "FALSE" ] ; then
count=$(cat $HOME/.profile | grep 'export OFS_TCPS_ENABLED' | wc -l )
	if [[ $count -eq 0 ]];then 
			echo "exporting wallet FALSE "
			OFS_ORA_WAL_ENABLED=FALSE
			export OFS_ORA_WAL_ENABLED
			echo "##Entries created by schema creator ##"
			echo "" >> $HOME/.profile
			echo 'OFS_ORA_WAL_ENABLED=FALSE' >> $HOME/.profile
			echo 'export OFS_ORA_WAL_ENABLED' >> $HOME/.profile
			echo 'OFS_TCPS_ENABLED=TRUE' >> $HOME/.profile
			echo 'export OFS_TCPS_ENABLED' >> $HOME/.profile
			echo "wallet_loc=$arg3" >> $HOME/.profile
			echo 'export wallet_loc' >> $HOME/.profile
			echo "WALLET_HOME=$arg3" >> $HOME/.profile
			echo 'export WALLET_HOME' >> $HOME/.profile
			echo 'X_ARGS_GEN="-Doracle.net.tns_admin=$TNS_ADMIN -Doracle.net.wallet_location=$wallet_loc -Doracle.net.ssl_server_dn_match=true -Djavax.net.ssl.trustStoreType=SSO -Djavax.net.ssl.trustStore=cwallet.sso -Doracle.net.ssl_version=1.2"' >> $HOME/.profile
			echo 'export X_ARGS_GEN' >> $HOME/.profile
	fi
fi

if [ ! -z $OFS_ORA_WAL_ENABLED ] && [ $(echo $OFS_ORA_WAL_ENABLED | tr '[:lower:]' '[:upper:]') = "TRUE" ] ; then
count=$(cat $HOME/.profile | grep 'export OFS_TCPS_ENABLED' | wc -l )
	if [[ $count -eq 0 ]];then 
		echo "exporting wallet true "
		OFS_ORA_WAL_ENABLED=TRUE
		export OFS_ORA_WAL_ENABLED
		echo "##Entries created by schema creator ##"
		echo "" >> $HOME/.profile
		echo 'OFS_ORA_WAL_ENABLED=TRUE' >> $HOME/.profile
		echo 'export OFS_ORA_WAL_ENABLED' >> $HOME/.profile
		echo 'OFS_TCPS_ENABLED=TRUE' >> $HOME/.profile
		echo 'export OFS_TCPS_ENABLED' >> $HOME/.profile
		echo "wallet_loc=$arg3" >> $HOME/.profile
		echo 'export wallet_loc' >> $HOME/.profile
		echo "WALLET_HOME=$arg3" >> $HOME/.profile
		echo 'export WALLET_HOME' >> $HOME/.profile
		echo 'X_ARGS_GEN="-Doracle.net.tns_admin=$TNS_ADMIN -Doracle.net.wallet_location=$wallet_loc -Doracle.net.ssl_server_dn_match=true -Djavax.net.ssl.trustStoreType=SSO -Djavax.net.ssl.trustStore=cwallet.sso -Doracle.net.ssl_version=1.2"' >> $HOME/.profile
		echo 'export X_ARGS_GEN' >> $HOME/.profile
	fi
 fi
fi

if [[ -z "$arg2" ]]; then
X_ARGS_GEN="-Doracle.net.tns_admin=$TNS_ADMIN -Doracle.net.wallet_location=$arg3" 
echo $X_ARGS_GEN
export X_ARGS_GEN
count=$(cat $HOME/.profile | grep 'OFS_ORA_WAL_ENABLED' | wc -l )
if [[ $count -eq 0 ]];then 
		echo "exporting wallet true "
		OFS_ORA_WAL_ENABLED=TRUE
		export OFS_ORA_WAL_ENABLED
		echo "" >> $HOME/.profile
		echo 'OFS_ORA_WAL_ENABLED=TRUE' >> $HOME/.profile
		echo 'export OFS_ORA_WAL_ENABLED' >> $HOME/.profile
		echo "WALLET_HOME=$arg3" >> $HOME/.profile
		echo 'export WALLET_HOME' >> $HOME/.profile
fi
fi
fi
export issilent

 

#Validation to check argument
echo "============================================================="
echo  You have chosen $(echo $mode | tr '[:lower:]' '[:upper:]') mode 
echo "============================================================="

if [[ $mode = "online" ]]; then
echo "Triggering the utility in ONLINE mode will execute the DDLs directly on the Database. Do you wish to proceed? (Y/N):"
else
echo "Triggering the utility in OFFLINE mode will generate the script. Do you wish to proceed? (Y/N):"
fi

read yesno < /dev/tty

if [[ $yesno = "y" || $yesno = "Y" ]];then
mode=$mode
elif [[ $yesno = "n" || $yesno = "N" ]];then
echo "Aborting Installation..."
exit
else
echo "Error:- Invalid Entry." 
exit
fi

#Java Validation
echo "============================================================="
echo "Java Validation Started ..."
jflag=0
flag=1
pwd=$PWD
javaDir=""
for i in $(echo "$PATH" | tr ":" "\n")
do
  if test -d $i 
  then
      javaDir=$i
	  cd $i	 
	  ls | grep "^java$" >/dev/null 
	  if [[ $? -eq 0 ]];then
		 flag=0
		 break
	  fi 
  fi	  
done
cd $pwd
if [[ $flag -eq 1 ]];then
   echo
   echo "Error:- JAVA_HOME/bin not found in PATH variable."  
   echo
   jflag=1
else
   echo "Java found in : $i"
fi

myvar=`uname`	
VER=`which java`
export VER
 
isSymbolicLink=$(ls -l $VER | grep ^l | wc -l)
os=`uname`
if test $isSymbolicLink = "1";then
   if test $os != "AIX";then
       VER=$(python3 -c 'import os.path; import os; print(os.path.realpath(os.environ["VER"]))')
   fi
fi
export VER
VER=`dirname $VER`
$VER/java -version >tmp.ver 2>&1
REQUIRED_VERSION=`grep JAVA_VERSION ../OFS_AAI/bin/VerInfo.txt | cut -d "=" -f2`
ORG_REQUIRED_VERSION=$REQUIRED_VERSION
REQUIRED_VERSION=`echo $REQUIRED_VERSION | sed -e 's;\.;0;g'`
VERSION=`cat tmp.ver | grep "java version" | awk '{ print substr($3, 2, length($3)-2); }'`

orgVersion=$VERSION
rm tmp.ver
VERSION=`echo $VERSION | awk '{ print substr($1, 1, 3); }' | sed -e 's;\.;0;g'`

if [ $VERSION ];then
	if [[ $REQUIRED_VERSION != *$VERSION* ]];then
	   echo
	   echo Error:- Make sure Java version is $ORG_REQUIRED_VERSION. Use java -version to check.
	   echo
	   jflag=1
	fi
else
	echo
	echo Error: - Make sure Java version is $ORG_REQUIRED_VERSION. Use java -version to check.
	echo
	jflag=1
fi

file $VER/java >tmp.ver 2>&1
BITVALUE=64-bit
if test $myvar = "AIX" ; then
	VALUE=`cat tmp.ver | grep "64-bit" | awk '{ print substr($2, 1); }'`
elif test $myvar = "HP-UX" ; then
	VALUE=`cat tmp.ver | grep "ELF-64" | awk '{ print substr($2, 1); }'`
	BITVALUE=ELF-64
else
	VALUE=`cat tmp.ver | grep "64-bit" | awk '{ print substr($3, 1); }'`
fi
rm tmp.ver
if [ $VERSION ];then
   if [[ $VALUE != $BITVALUE ]];then
      echo Error: - Make sure 64-bit java executable is set in the PATH variable
      jflag=1
   fi
else 
	echo Error: - Make sure 64-bit java executable is set in the PATH variable
	jflag=1
fi
export PATH=$VER:$PATH:.

if test $jflag -eq 1;then
  echo "Java Validation Completed. Status : FAIL"
  exit
else
  echo "JAVA Version found : $orgVersion"
  echo "JAVA Bit Version found : $BITVALUE"
  echo "Java Validation Completed. Status : SUCCESS"
fi
echo "============================================================="
#Validation ends here

#count=`find . -type f -iname "${PACK_ID}_schema*.xml" | grep -c /`
count=`find ./conf \( -name "*.xml" -o -name "*.XML" \) | grep -i "${PACK_ID}_SCHEMA_IN.xml" | wc -l | tr -d ' '`

if [[ $count != "1" ]];then
count=`find ./conf \( -name "*.xml" -o -name "*.XML" \) | grep -i "${PACK_ID}_SCHEMA_BIGDATA_IN.xml" | wc -l | tr -d ' '`
if [[ $count != "1" ]];then
echo "ERROR : Improper configuration of SCHEMA_IN.xml"
exit
fi
fi

SchemaInfile=`find ./conf \( -name "*.xml" -o -name "*.XML" \) | grep -i "${PACK_ID}_SCHEMA_IN.xml"`

if [[ -z "$SchemaInfile" ]]; then
SchemaInfile=`find ./conf \( -name "*.xml" -o -name "*.XML" \) | grep -i "${PACK_ID}_SCHEMA_BIGDATA_IN.xml"`
if [[ -z "$SchemaInfile" ]]; then
echo ${PACK_ID}_schema_in.xml/${PACK_ID}_schema_bigdata_in.xml file is missing under `pwd`/conf path
exit
fi
fi

url=$(perl -ne 'if (/JDBC_URL/){ s/.*?>//; s/<.*//;print;}' $SchemaInfile)

hivejars=$(perl -ne 'if (/HIVE_LIB_PATH/){ s/.*?>//; s/<.*//;print;}' $SchemaInfile)


if [ -z $url ]; then
echo JDBC_URL should be configured in `basename $SchemaInfile`
exit
fi

#start of wallet check
if [ -z $OFS_ORA_WAL_ENABLED ] || [ $(echo $OFS_ORA_WAL_ENABLED | tr '[:lower:]' '[:upper:]') = "FALSE" ] ; then
isLdapUrl=$(echo $url | grep ":@ldaps*:" | wc -l)
if [[ $isLdapUrl -eq 1 ]]; then
    # Parse OID string   
    DATABASENAME=$(echo $url | sed -n -e "s/^.*[0-9]*\///p" | cut -d ',' -f1) 
else
	DATABASENAME=$(echo $url|cut -d ':' -f6)
	if [[ -z "$DATABASENAME" ]];then 
	 if [[ "$url" == */* ]];then
		   DATABASENAME=`echo $url|cut -d "/" -f2` 	   
		   if [[ -z "$DATABASENAME" ]];then
			  DATABASENAME=`echo $url|cut -d "/" -f4`		  
		   fi	   
	  else
		   DATABASENAME=`echo $url|sed -n 's/^.*\(SERVICE[^)]*\).*/\1/p'|cut -d "=" -f2`	   
	 fi
	fi
fi	

if [ $IS_ADW = "TRUE" ]; then	
	var="$(cut -d'@' -f 2 <<< $url)"
	DATABASENAME=${var%"</JDBC_URL>"} 	
fi
echo 'DATABASENAME = '$DATABASENAME	
if [ -z $DATABASENAME ]; then
echo Could not able to fetch SID from JDBC URL configured in `basename $SchemaInfile`
exit
fi

fi
#end of wallet check


JAR_LIST=.


if [ -z "${TNS_ADMIN}" ];then
   echo " TNS_ADMIN variable not set."
exit
fi 
 
if [  -z $ORACLE_HOME ]; then
echo ORACLE_HOME is not set
exit
fi


if [ ! -d $ORACLE_HOME/jdbc/lib ]; then
echo $ORACLE_HOME/jdbc/lib folder not found
exit
fi

#cp $ORACLE_HOME/jdbc/lib/ojdbc6.jar ./lib

echo "DB specific Validation Started ..."
dbflag=0
ORG_USERNAME=''
if test $mode = "online"; then
	if [ $(echo $OFS_ORA_WAL_ENABLED | tr '[:lower:]' '[:upper:]') = "TRUE" ] ; then
	echo "Enter the DB alias With SYSDBA Privileges:"
	else
	echo "Enter the DB User Name With SYSDBA Privileges:"
	fi
	read USERNAME
	ORG_USERNAME=$USERNAME
	USERNAME=$(echo $USERNAME | tr -s '\t' ' ' | cut -d ' ' -f1)
	if [ $(echo $OFS_ORA_WAL_ENABLED | tr '[:lower:]' '[:upper:]') = "FALSE" ] ; then	
	echo "Enter the User Password:"
	stty -echo
	read PASS
	stty echo
	fi 	
elif test $mode = "offline" ; then
	if [ $(echo $OFS_ORA_WAL_ENABLED | tr '[:lower:]' '[:upper:]') = "TRUE" ] ; then
	echo "Enter the DB alias with the following privileges:"
	else
	echo "Enter the DB User Name with the following privileges:"
	fi	
	echo "1. CREATE SESSION"
	echo "2. SELECT on DBA_ROLES"
	echo "3. SELECT on DBA_USERS"
	echo "4. SELECT on DBA_DIRECTORIES"
	echo "5. SELECT on DBA_TABLESPACES"
	echo "Enter the User Name:"
	read USERNAME
	ORG_USERNAME=$USERNAME	
	USERNAME=$(echo $USERNAME | tr -s '\t' ' ' | cut -d ' ' -f1)
	if [ $(echo $OFS_ORA_WAL_ENABLED | tr '[:lower:]' '[:upper:]') = "FALSE" ] ; then
	echo "Enter the User Password:"
	stty -echo
	read PASS
	stty echo 
	fi
fi

if [ $(echo $OFS_ORA_WAL_ENABLED | tr '[:lower:]' '[:upper:]') = "TRUE" ] ; then
if [ -z "${USERNAME}" ];   
    then
		echo "Error: Username alias cannot be EMPTY"
		dbflag=1
fi
else
if [ -z "${USERNAME}" ] || [ -z "${PASS}" ];   
    then
		echo "Error: Username or Password are empty"
		dbflag=1
fi
fi

LOGFILE=EnvCheck.log


if test $mode = "online"; then
dbaflag='as sysdba'	
echo "user name is $USERNAME"
elif test $mode = "offline" ; then
	if [[ $(echo $USERNAME | tr '[:lower:]' '[:upper:]') = "SYS" ]]; then
		dbaflag='as sysdba'
	else
		dbaflag=''
	fi
fi
if [ $IS_ADW = "TRUE" ]; then
	dbaflag=''
fi
 
if [ $(echo $OFS_ORA_WAL_ENABLED | tr '[:lower:]' '[:upper:]') = "TRUE" ] ; then
	sqlplus -s /nolog <<-EOF> ${LOGFILE}
	WHENEVER OSERROR EXIT 9;
	WHENEVER SQLERROR EXIT SQL.SQLCODE;
	connect /@$USERNAME $dbaflag
	EOF
else
	sqlplus -s /nolog <<-EOF> ${LOGFILE}
	WHENEVER OSERROR EXIT 9;
	WHENEVER SQLERROR EXIT SQL.SQLCODE;
	connect $USERNAME/$PASS@$DATABASENAME $dbaflag
	EOF
	
fi
exitStaus=$?
if test $exitStaus == 0;then

    #Checking client version
	[[ ! -f "$ORACLE_HOME/bin/sqlplus" ]] && { echo "sqlplus file not present in $ORACLE_HOME/bin folder."; dbflag=1; }
	clientVersion=$(sqlplus -v | grep . | cut -d ' ' -f3)

	ORACLE_CLIENT_VERSION_EXTN=$(echo $clientVersion | cut -c1-4)
	 export ORACLE_CLIENT_VERSION_EXTN
						 
	fileversion=`grep DB_CLIENT_VERSION ../OFS_AAI/bin/VerInfo.txt | cut -d "=" -f2`
	if [[ $fileversion != *$(echo $clientVersion | cut -c1-2)* ]];then
	   echo "Oracle Client version validation failed. Only Oracle 18 and 19 series are supported. Current version : $clientVersion. Expected version : 11 Series. Status : FAIL"
	  dbflag=1
	  else
	  echo "Oracle Client version : $clientVersion. Status : SUCCESS"	  
	fi   
    
	#function to connect & retrieve value from DB 
	#$1->query $2->Error message $3->Success message $4->SQL error $5->expected value $6->Unlimited table space
	
    checkDbRetrieveVal () {
if [ $(echo $OFS_ORA_WAL_ENABLED | tr '[:lower:]' '[:upper:]') = "TRUE" ] ; then
		res=`sqlplus -s /nolog <<-EOF 
		   WHENEVER OSERROR EXIT 9;
		   WHENEVER SQLERROR EXIT SQL.SQLCODE;			   
		   connect /@$USERNAME $dbaflag
		   SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF 
		   $1;	
		   exit 0;
		   EOF`
else	
		res=`sqlplus -s /nolog <<-EOF 
		   WHENEVER OSERROR EXIT 9;
		   WHENEVER SQLERROR EXIT SQL.SQLCODE;			   
		   connect $USERNAME/$PASS@$DATABASENAME $dbaflag
		   SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF 
		   $1;	
		   exit 0;
		   EOF`	
fi		
		exitStaus=$?	
		if [[ $exitStaus != "0" ]];then
			echo " $4 Status : FAIL";                                         #SQL error
			dbflag=1
		else	
            if ! echo "${res}" | egrep '^[0-9]+$' >/dev/null; then         #Result value is not a number		
			   
			     if [ -z "${res}" ];then
				   echo " $2 Current value : NULL. Status : FAIL"             #FAILURE
				   dbflag=1
				 else
				   if [[ $5 == *"ORACLE_DB_SERVER"* ]];then					     
					  res=$(echo $res | cut -d '-' -f1 | awk '{print $NF}' )
					  									
	               fi
				   if test ${res} != "$5";then                                #character value
				      if [[ $2 == *"Oracle Database Partitioning feature is"* ]];then
					    echo "$2 Current value : Non-Partitioned. Status : FAIL"
						dbflag=1
                      elif [[ $5 == *"ORACLE_DB_SERVER"* ]];then
					     fileversion=`grep DB_SERVER_VERSION ../OFS_AAI/bin/VerInfo.txt | cut -d "=" -f2`
						 ORACLE_DB_VERSION=$(echo $res | cut -c1-2)
                         export ORACLE_DB_VERSION						 
	                     if [[ $fileversion != *$(echo $res | cut -c1-2)* ]];then                                     
	                         echo
							 echo "$2 Current value : ${res}."
							 echo
                         else
						     echo "$3 Current value : ${res}. Status : SUCCESS"   
                         fi							
					  else
						echo "$2 Current value : ${res}. Status : FAIL"      #FAILURE
					    dbflag=1
					  fi						
			       else
				      if [[ $3 == *"Oracle Database Partitioning feature is"* ]];then
					    echo "$3 Current value : Partitioned. Status : SUCCESS"                      					
					  else
						echo "$3 Current value : ${res}. Status : SUCCESS"   #SUCCESS
					  fi
			       fi
				 fi  
			   
			else			   
			   if test ${res} -lt $5;then                                     #numeric value
				  echo "$2 Current value : ${res}. Status : FAIL"            #FAILURE
				  dbflag=1
			   else
				  echo "$3 Current value : ${res}. Status : SUCCESS"         #SUCCESS
			   fi	   
			fi				   
		fi	
    }
	
	#Checking Oracle Server
	checkDbRetrieveVal "select BANNER from v\$version where BANNER like 'Oracle%'" "[WARNING]:-Oracle Database Server version mismatch - The version of your Oracle Database Server does not match the version of Oracle Database on which this release of OFS AAI has been qualified." "Oracle Server version" "Error while fetching Oracle Server version from v\$version." "ORACLE_DB_SERVER"	 
	if  [[ $(echo $VERSION | sed -e 's;\.;0;g') -lt "108" && $(echo $ORACLE_CLIENT_VERSION_EXTN | sed -e 's;\.;0;g') -ge "1202" ]];then
	echo "ERROR: Java version - $orgVersion is not supported for the CLIENT version - $ORACLE_CLIENT_VERSION_EXTN."; 
	dbflag=1;
	fi

    #Checking Ojdbc.jar	
	
	if  [[ $(echo $ORACLE_CLIENT_VERSION_EXTN | sed -e 's;\.;0;g') -ge "1202" ]];then
	 [[ ! -f "$ORACLE_HOME/jdbc/lib/ojdbc8.jar" ]] && { echo "ERROR: Compatible version(ojdbc8) of the JDBC driver is not found. Please download & copy the ojdbc8.jar in $ORACLE_HOME/jdbc/lib directory."; dbflag=1; } || { cp $ORACLE_HOME/jdbc/lib/ojdbc8.jar ./lib; }    
   	elif  [[ $ORG_REQUIRED_VERSION == *"1.7"* && $ORACLE_DB_VERSION == "12" ]];then		
	  [[ ! -f "$ORACLE_HOME/jdbc/lib/ojdbc7.jar" ]] && { echo "ERROR: Compatible version(ojdbc7) of the JDBC driver is not found. Please download & copy the ojdbc7.jar in $ORACLE_HOME/jdbc/lib directory."; dbflag=1; } || { cp $ORACLE_HOME/jdbc/lib/ojdbc7.jar ./lib; }    
	else
	  [[ ! -f "$ORACLE_HOME/jdbc/lib/ojdbc6.jar" ]] && { echo "ERROR: Compatible version(ojdbc6) of the JDBC driver is not found."; dbflag=1; } || { cp $ORACLE_HOME/jdbc/lib/ojdbc6.jar ./lib; }    
	fi
   else
    echo " ERROR -> $(head -2 ${LOGFILE} | tail -1)"
    dbflag=1 
 fi

 rm ${LOGFILE} 
  

if test $dbflag -eq 1; then
echo 'DB specific Validation Completed. Status : FAIL';
exit;
else
echo 'DB specific Validation Completed. Status : SUCCESS'
fi





if  [ -d $FIC_APP_HOME/common/FICServer/lib ] ; then

	cp $FIC_APP_HOME/common/FICServer/lib/FICServer.jar ./lib
	cp $FIC_APP_HOME/common/FICServer/lib/AESCryptor.jar ./lib

elif [ -d $FIC_WEB_HOME/webroot/WEB-INF/lib ] ; then

	cp $FIC_WEB_HOME/webroot/WEB-INF/lib/FICServer.jar ./lib
	cp $FIC_WEB_HOME/webroot/WEB-INF/lib/AESCryptor.jar ./lib
	
elif  [ ! -z $FIC_DB_HOME ] && [ -d $FIC_DB_HOME/lib ]; then

	cp $FIC_DB_HOME/lib/FICServer.jar ./lib
	cp $FIC_DB_HOME/lib/AESCryptor.jar ./lib
	
fi


	cp $ORACLE_HOME/jlib/oraclepki.jar ./lib
	cp $ORACLE_HOME/jlib/osdt_cert.jar ./lib
	cp $ORACLE_HOME/jlib/osdt_core.jar ./lib


JAR_FILELIST=`find ./lib \( -name *.jar -o -name *.zip \)`

for arg in `echo $JAR_FILELIST`
do
  JAR_LIST=$JAR_LIST:$arg
done



if  [ ! -z $hivejars ] && [ -d $hivejars ]; then
JAR_FILELIST=`find $hivejars \( -name *.jar -o -name *.zip \)`
for arg in `echo $JAR_FILELIST`
do
  JAR_LIST=$JAR_LIST:$arg
done
fi

_CLASSPATH=$JAR_LIST

myvar=`uname`

if test $myvar = "AIX" ; then
 machineIP=`ifconfig -a | grep -w "inet"|head -1|tr -s '\t' ' '|cut -d ' ' -f3|cut -d ':' -f2`
elif test $myvar = "Linux" ; then
 machineIP=`/sbin/ifconfig | grep "inet addr"|head -1|tr -s '\t' ' '|cut -d ' ' -f3|cut -d ':' -f2`
elif test $myvar = "SunOS" ; then
 machineIP=`ifconfig -a | grep -w "inet"|tail -1|tr -s '\t' ' '|cut -d ' ' -f3|cut -d ':' -f2`
fi




if [ $(echo $OFS_ORA_WAL_ENABLED | tr '[:lower:]' '[:upper:]') = "FALSE" ] ; then	
USERNAME=$ORG_USERNAME
else
#USERNAME="sairam"
USERNAME=$(echo $ORG_USERNAME | tr -s '\t' ' ' | cut -d ' ' -f1)
fi


export USERNAME
export PASS
if [ ! "$machineIP" ];then
   machineIP='dummy'
fi

if [ ! -z $OFS_ORA_WAL_ENABLED ] && [ $(echo $OFS_ORA_WAL_ENABLED | tr '[:lower:]' '[:upper:]') = "TRUE" ] && [ ! -z $arg2 ] && [ ! -z $arg3 ] ; then
echo "triggering tcps with wallet case"
java -classpath $_CLASSPATH $X_ARGS_GEN Main $machineIP $mode $OFSAAI_HOME $arg2 $arg3
elif [ ! -z $OFS_ORA_WAL_ENABLED ] && [ $(echo $OFS_ORA_WAL_ENABLED | tr '[:lower:]' '[:upper:]') = "FALSE" ] && [ ! -z $arg2 ] && [ ! -z $arg3 ] ; then
echo "triggering tcps case"
java -classpath $_CLASSPATH $X_ARGS_GEN Main $machineIP $mode $OFSAAI_HOME $arg2 $arg3
elif [ ! -z $OFS_ORA_WAL_ENABLED ] && [ $(echo $OFS_ORA_WAL_ENABLED | tr '[:lower:]' '[:upper:]') = "TRUE" ] ; then
echo "triggering wallet case"
java -classpath $_CLASSPATH -Doracle.net.tns_admin=$TNS_ADMIN -Doracle.net.wallet_location=$WALLET_HOME Main $machineIP $mode $OFSAAI_HOME
else
	java -classpath $_CLASSPATH Main $machineIP $mode $OFSAAI_HOME
fi
rm -rf ./lib/FICServer.jar ./lib/AESCryptor.jar
#Check the return code
if [ $? -ne 0 ] ; then
	exit
fi


