FasdUAS 1.101.10   ��   ��    l      ��  i         I      �� ���� 0 construct_playlist     ��  o      ���� 0 args  ��  ��    l    ~ 	 
 	 k     ~       O     y    Q    x  ��  k    o       O    D    k    C       Z    <  ��   H       l    ��  E         l    !�� ! n     " # " 1    ��
�� 
pnam # 2   ��
�� 
cPly��     m     $ $  	NanoFibre   ��    l   + % & % l   + ' ( ' r    + ) * ) I   )���� +
�� .corecrel****      � null��   + �� , -
�� 
kocl , m     ��
�� 
cPly - �� .��
�� 
prdt . K   ! % / / �� 0��
�� 
pnam 0 m   " # 1 1  	NanoFibre   ��  ��   * o      ���� 0 newplaylist newPlaylist (  No? Then make it    & ' !check if playlist already exists    ��    k   . < 2 2  3 4 3 l  . 4 5 6 5 r   . 4 7 8 7 4   . 2�� 9
�� 
cPly 9 m   0 1 : :  	NanoFibre    8 o      ���� 0 newplaylist newPlaylist 6  Yes?     4  ;�� ; l  5 < < = < I  5 <�� >��
�� .coredelonull���    obj  > n   5 8 ? @ ? 2   6 8��
�� 
cTrk @ o   5 6���� 0 newplaylist newPlaylist��   = $ Then delete current references   ��     A B A r   = A C D C J   = ?����   D o      ���� 0 filelist fileList B  E�� E l  B B������  ��  ��    4    �� F
�� 
cSrc F l  	  G�� G n   	  H I H 4   
 �� J
�� 
cobj J m    ����  I o   	 
���� 0 args  ��     K L K l  E E������  ��   L  M N M Y   E c O�� P Q�� O s   U ^ R S R l  U [ T�� T c   U [ U V U l  U Y W�� W n   U Y X Y X 4   V Y�� Z
�� 
cobj Z o   W X���� 0 i   Y o   U V���� 0 args  ��   V m   Y Z��
�� 
alis��   S n       [ \ [  ;   \ ] \ o   [ \���� 0 filelist fileList�� 0 i   P m   H I����  Q l  I P ]�� ] I  I P�� ^��
�� .corecnte****       **** ^ n   I L _ ` _ 2  J L��
�� 
cobj ` o   I J���� 0 args  ��  ��  ��   N  a b a l  d d������  ��   b  c d c l  d m e f e I  d m�� g h
�� .hookAdd cTrk      @ alis g o   d e���� 0 filelist fileList h �� i��
�� 
insh i o   h i���� 0 newplaylist newPlaylist��   f ` Z If anyone knows how to prevent itunes scanning for artwork all over again, let me know...    d  j k j l  n n������  ��   k  l m l l  n n������  ��   m  n o n l  n n�� p��   p ) #			tell application "System Events"    o  q r q l  n n�� s��   s  				tell process "iTunes"    r  t u t l  n n�� v��   v  					tell menu bar 1    u  w x w l  n n�� y��   y % 						tell menu bar item "File"    x  z { z l  n n�� |��   |  							tell menu "File"    {  } ~ } l  n n�� ��    ) #								click menu item "Sync iPod"    ~  � � � l  n n�� ���   �  							end tell    �  � � � l  n n�� ���   �  						end tell    �  � � � l  n n�� ���   �  					end tell    �  � � � l  n n�� ���   �  				end tell    �  � � � l  n n�� ���   �  			end tell    �  � � � l  n n������  ��   �  ��� � l  n n������  ��  ��    R      ������
�� .ascrerr ****      � ****��  ��  ��    m      � ��null      ߀��  )
iTunes.app��   �_� �[���0    w0(   )       ��(�^鈿��` xhook   alis    2  Zim                        ���H+    )
iTunes.app                                                      0�۾痗        ����  	                Applications    ���      �片      )  Zim:Applications:iTunes.app    
 i T u n e s . a p p    Z i m  Applications/iTunes.app   / ��     � � � l  z z������  ��   �  � � � L   z | � � m   z {����   �  ��� � l  } }������  ��  ��   
 T Nargs - item 1 is the library name, the rest is the filenames of the track list   ��       �� � ���   � ���� 0 construct_playlist   � �� ���� � ����� 0 construct_playlist  �� �� ���  �  ���� 0 args  ��   � ���������� 0 args  �� 0 newplaylist newPlaylist�� 0 filelist fileList�� 0 i   �  ��������� $���� 1���� :����������������
�� 
cSrc
�� 
cobj
�� 
cPly
�� 
pnam
�� 
kocl
�� 
prdt�� 
�� .corecrel****      � null
�� 
cTrk
�� .coredelonull���    obj 
�� .corecnte****       ****
�� 
alis
�� 
insh
�� .hookAdd cTrk      @ alis��  ��  �� � v m*��k/E/ 3*�-�,� *�����l� 
E�Y *��/E�O��-j OjvE�OPUO l��-j kh ��/�&�6G[OY��O�a �l OPW X  hUOjOPascr  ��ޭ