#!/bin/bash

#d  finitions des variables :
datedujour=$(date +%d-%m-%Y)
datequinze=$(date -d '15 days ago' +%d-%m-%Y)

# On afficher les infos date du jour et autre pour le log.
echo "Date du jour : $datedujour"
echo "Date il y a 15 jours : $datequinze"

# attributs pour la connexion    la base
MYSQL_USER="root"
MYSQL_PASS="K3fmFLa445xG"
MYSQL_HOST="127.0.0.1"
# Sauvegarde de l'ensemble des bases de donnees
BACKUP_DIR=/backup/bdds/$datedujour
BACKUP_DIR_OLD=/backup/bdds/$datequinze
test -d $BACKUP_DIR || mkdir -p $BACKUP_DIR
# Get the database list, exclude information_schema
DB_LIST=$(mysql -B -s -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASS -e 'SELECT schema_name FROM information_schema.schemata' | grep -v information_schema | grep -v mysql | grep -v performance_schema | grep -v sys | grep -v backup)
echo ${DB_LIST}
for db in ${DB_LIST}
do
  # dump each dabase in a separate file
  mysqldump -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASS $db | gzip > $BACKUP_DIR/$db.sql.gz
done

# Suppression du re pertoire de 15 jours s'il existe
if test -d ${BACKUP_DIR_OLD}; then
echo "suppression des anciens backups de BDD vieux de 15 jours : $datequinze"
rm -rf ${BACKUP_DIR_OLD}
fi

