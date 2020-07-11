#!/bin/bash
x="aws"
menu ()
{
while true $x != "aws"
do
clear
echo "================================================"
echo "Menu AWS"
echo ""
echo "1)Instalar um programa"
echo""
echo "2)Remover um programa"
echo ""
echo "3)Atualizar o sitema"
echo ""
echo "4)Instalar dependências"
echo""
echo "5)Limpando programas defeituosos "
echo""
echo "6)Corrigir erros"
echo""
echo "7)Sair do programa"
echo ""
echo "================================================"

echo "Digite a opção desejada:"
read x
echo "Opção informada ($x)"
echo "================================================"

case "$x" in


    1)
      echo "Informe o nome do pacote para ser instalado?"
      read nome
      apt-get install $nome
      sleep 5

echo "================================================"
;;
    2)
      echo "Informe o nome do pacote para ser removido?"
      read nome
      apt-get remove --purge $nome
      sleep 5
echo "================================================"
;;
   3)
      echo "Atualizando sistema..."
      apt-get update
      sleep 5
echo "================================================"
;;
    4)
       echo "Iniciando o processo..."
       apt-get -f install
       sleep 5
echo "================================================"
;;
     5)
       echo "Corrigindo erros..."
       apt-get autoremove
       sleep 5
echo "================================================"
;;
    6)
    echo "Reparando..."
    dpkg --configure -a
    sleep 5

echo "================================================"
 ;;
       7)
         echo "saindo..."
         sleep 2
         clear;
         exit;
echo "================================================"
;;

*)
        echo "Opção inválida!"
esac
done

}
menu
