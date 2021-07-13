#!/bin/bash

#d  finitions des variables :
datedujour=$(date +%d-%m-%Y)
datequinze=$(date -d '15 days ago' +%d-%m-%Y)
day_of_week=$(date +%u)

# On afficher les infos date du jour et autre pour le log.
echo "Date du jour : $datedujour"


# attributs pour la connexion    la base
MYSQL_USER="root"
MYSQL_PASS="K3fmFLa445xG"
MYSQL_HOST="127.0.0.1"



for file_id in $(mysql -B -s -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASS -e 'use backup; select id from backup_list')
do

        file_persist=$(mysql -B -s -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASS -e "use backup; select day_${day_of_week} from backup_list where id=${file_id}")
        true="1"
        if [ "$file_persist" -eq "$true" ]; then
                
		file_name=$(mysql -B -s -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASS -e "use backup; select name from backup_list where id=${file_id}")
                file_path=$(mysql -B -s -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASS -e "use backup; select path from backup_list where id=${file_id}")
                file_saved_path=$(mysql -B -s -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASS -e "use backup; select saved_path from backup_list where id=${file_id}")
                file_parent_directory=$(mysql -B -s -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASS -e "use backup; select parent_directory from backup_list where id=${file_id}")
                file_nb_persist=$(mysql -B -s -h $MYSQL_HOST -u $MYSQL_USER --password=$MYSQL_PASS -e "use backup; select nb_persist from backup_list where id=${file_id}")


                if [ $file_parent_directory == "null" ]; then
                        BACKUP_DIR=/$file_saved_path/$datedujour
                        BACKUP_OLD=/$file_saved_path/*
                else
                        BACKUP_DIR=/$file_saved_path/$datedujour/$file_parent_directory
                        BACKUP_OLD=/$file_saved_path/*/$file_parent_directory
                fi
                test -d $BACKUP_DIR || mkdir -p $BACKUP_DIR
                
                cd $file_path
                tar -zcvf $BACKUP_DIR/$file_name.tar.gz  $file_name


                count=$(find $BACKUP_OLD -name "${file_name}.tar.gz"  -type f | wc -l)
                echo $count

                if [ "$count" -ge "$file_nb_persist" ]; then
                        oldest=$(find  $BACKUP_OLD -name "${file_name}.tar.gz" -type f -printf '%T+ %p\n' | sort | head -n 1)
                        echo $oldest

                        oldest_path=$(cut -d' ' -f2 <<< "$oldest")
                        echo $oldest_path
                        rm -rf $oldest_path
                fi
        fi
done
