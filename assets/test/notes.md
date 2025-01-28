# aqui tenho anotações pessoais e coisas que posso (o não) incluir em versões futuras do Pimp my Decky
aqui é basicamente meu bloco de notas e/ou rascunho pra esse projeto

<!-- 
!#CTRL+E cria ``isso``
-->


### rotação de tela em distros linux

``echo 3 > /sys/class/graphics/fbcon/rotate_all``

ou

``fbcon=rotate:3 no boot loader``

ou 

``xrandr -o right``

ou ainda

``GRUB_CMDLINE_LINUX="fbcon=rotate:1"``

(não esqueça de rodar: ``sudo update-grub`` para salvar as alterações no grub)
