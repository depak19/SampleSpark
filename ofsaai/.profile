# Profile for ksh login shells
# Set ENV to ensure ksh reads the correct initialization file
export ENV=$HOME/.kshrc

# Get the aliases and functions
export JAVA_HOME=/usr/java/java-21
export ORACLE_HOME=/u01/app/oracle/product/19.0.0/client_1
export PATH=$ORACLE_HOME/bin:$PATH:$JAVA_HOME/bin
export ORACLE_SID=XE
export TNS_ADMIN=$ORACLE_HOME/network/admin
 
export OS_VERSION="8"
export DB_CLIENT_VERSION="19.0"

export FIC_HOME="/ofsaai/ofsaai/"