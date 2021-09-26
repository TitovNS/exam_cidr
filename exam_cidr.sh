#!/bin/sh

DIALOG=${DIALOG=dialog}

#функция проверки адреса
exam_cidr() {
    # разбиваем на две части
    ip=$(echo $cidr | awk -F "/" \
        '{
         print $1
      }')
    mask=$(echo $cidr | awk -F "/" \
        '{
         print $2
      }')
    # проверяем ip
    flag_ip=$(echo $ip | awk -F "." \
        '{if ( NF != 4) 
          print "0"; 
        else if ($1 >= 0 && $1 <= 255 && $2 >=0 && $2 <= 255 && $3 >=0 && $3 <= 255 && $4 >= 0 && $4 <= 255)
          print "1"; 
        else 
          print "0"}')
    # проверяем маску
    flag_mask=$(echo $mask | awk -F "." \
        '{if ( NF != 4 && NF != 1) 
          print "0"; 
        else if ((($1==0 || $1==128 || $1==192 || $1==224 || $1==240 || $1==248 || $1==252 || $1==254 || $1==255) \
          &&  ($2<=$1 && ($2==0 || $2==128 || $2==192 || $2==224 || $2==240 || $2==248 || $2==252 || $2==254 || $2==255)) \
          && ($3<=$2 && ($3==0 || $3==128 || $3==192 || $3==224 || $3==240 || $3==248 || $3==252 || $3==254 || $3==255)) \
          && ($4<=$3 && ($4==0 || $4==128 || $4==192 || $4==224 || $4==240 || $4==248 || $4==252 || $4==254 || $4==255))) \
          || ($1>=0 && $1<=32 && NF == 1)) 
          print "1"; 
        else 
          print "0"
      }')
    # если обе проверки прошли, то будет 2
    result=$(($flag_ip + $flag_mask))
}

# окно выхода
exit_func() {
    $DIALOG --title "Выход" --clear \
        --yesno "Вы хотите выйти?" 10 40
    case $? in
    0)
        exit
        ;;
    1)
        return 0
        ;;
    255)
        return 0
        ;;
    esac
}
# предложение дальнейшего действия
repeat_func() {

    choice=$($DIALOG --title "CIDR" --clear \
        --menu "Выберите дальнейшее действие" 10 40 2 \
        "1." "Повторить" \
        "2." "Выход" \
        3>&1 1>&2 2>&3 3>&-)
    case $? in
    0)
        if [ "$choice" = "2." ]; then
            exit_func
        else
            return 0
        fi
        ;;
    1)
        exit_func
        ;;
    255)
        exit_func
        ;;
    esac
}
# основная программа
while :; do
    cidr=$($DIALOG --title "CIDR" --clear \
        --inputbox "Введите CIDR \n(пример: a.b.c.d/e или a.b.c.d/e.f.g.k)" 10 40 \
        3>&1 1>&2 2>&3 3>&-)

    case $? in
    0)
        exam_cidr
        if [ $result -eq 2 ]; then
            $DIALOG --title "CIDR" --clear \
                --msgbox "Введено верно" 5 40
        else
            $DIALOG --title "notCIDR" --clear \
                --msgbox "Введено НЕ верно" 5 40
        fi
        repeat_func
        ;;
    1)
        exit_func
        ;;
    255)
        exit_func
        ;;
    esac
done
