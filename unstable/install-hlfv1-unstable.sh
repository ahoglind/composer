ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ��Z �=�r��r�Mr�A��)U*�}��V��$ Ey�,x-�o�%�G;�$D�q!E9:�O8U���F�!���@^33 I��E2%ڻfW٤fzzz.=���3�J��hw:�7L��k�~[{t?�a�DD��
���@X�"����IaI�E��G��p�T�\p,� <�M�U��x����E������BfWU���0 xs�����_�U��:l��a.�T۰�Ӛ�25Tk 34��M)��1L�rI [��6�C�ۢiH益���n�����R�x�8̧����� ���V�f�bw����a~ٰm�Q�cP,�K0�b6��ۖ�=���#�L��VuvN��������b"���+�Tr^1\�6�D�h�a�"&�Pב���D}?5�z:m�)6�#Ө������mM�����k~Y��vlw@ؽ�iZt� 7����x�u�y�-�?�Z�6L�jm4�ơ�pB����QT�fͭWm#�!Ì�9x�YC&�r�xv�i9�FXo�e'�(�%lw4DZ��$n����=)�Bq��}�Q��9��V'�$e��+��U�-���ߴ�n���;�~q�����n�lP�tO�k���J��7̄:7�����&���|[��O�;w[P|"�tG�n�]�(^3:�{�٢�Jա�y�����Cm����]�.�w���
��n�l�x�����E��,���P��a����y�{�d
|��ߔ�V�����A��lt�����!�K"G���(�k���������j2��
��S���GM5Ɋ���˥���a��H���_��~�tz5�-t�+x�|�k���?�}2��U�9i-������0E���m4t($�6��"pg��0���Wk���a��w�҂���^��q����R?��GDA\��*�8������:�|q�r���:�EZ��D�,`���f�lA�0�	iF�8ű�i٠��3���1�.ފ0u�tM2�Wm����CoC�=���h�B8��T�+4���6�
���b�c7s���J��i��t��-c�i������3�gx�.K��\V5Ci)M8�ڳ��9�C-����n'[��VU���4�.=`��� � �wt'k�$`15
�wu�^C��"M�I(�1�nC�h\�n��v7�������%���|�\�w�/��dMK���eM����s'�?.]��� ���<D�uG��y�nB�TMP���.����zct(l1�B�mt�>c>2�����F��X �����[�M�X���.`Y��%!��5)M���>B�jo�����
���y�^�OJ����ra�r�]�Y{�4rP�m�5ۀ�:����bz؁����)��z����B��hĴ���x�-f�-7�a�p�c�%���1i�+�c��Sݰ��i�:�#����Q�A �O� C���C|��S��1�9�]�;�X�ڠ��0&WpT�"����o7qG�8�Q)��iZXHC�zMUi�j6�`�����NN����X���z}Β��g�G��U'��x�36�^b&܈
R�&�eMV����K ��(o�|9B��y��v�˛(k]����,�05CG��k�)�?�H���%pw�oD�����*`����a������X ��(D&��������'%G~W;s��G3E�#ژih,C�݌	����&!���f�If�����0�l鼔(f�ʻ��	y�8�O�+z����G��a��ʁ+���x1�8?NK���������c@���[�~�ut�i�
ܨA�IW�x�]/��A��f���%��9���%��M~Ke�X>/gs��Jy6�ch�x�%��Bx�jֳM+��Kn�Zh�ݭ?�����7iP.f���[�9���?�M�����"���LVw@k��N��L��AxI�R����O4t�C��nœO�k6�p�-�NN��"�+��f��,9/�w��`��'Dn�H��z�_ܿ�G�j*���rjL�ND�k��7
�Wu�h�.� �g�;����h�	��T���}���?�s��_4,��p���<�T���iU��i ��C]���2�m�k�si�"�
��u�=�;�E�u��*`��Sg�Y�h��?Y�#a��<����m��K��?��q�?��������o��ᆎ�pӲ2M�|:���ށh���d�	@]��#��u�x��1#{��8t����&
~���-5���Q�7�.���X}�Fm@��0��"O�^d�Lo�������x�O�����3f�VȄE¯�LS3�� )1O�6�u�'�=��Z�
Q��F{ytc.���"]�5Ǝ�1��8x�̙��3�;�Jנ��զ=�`M_�\�����̥�E�T�������+���P�_ɪ��U���BDl�p�RH�G��U��w]2�p R���xr�y�n >��E�
�����]
x���T��(�Zu�����/s)d��cY���DAZ�+�����Ü����'XMAJˍ7tý\�f����!��H΍�ht��8�Er|��܏���Qo��av 0 �o �Z �������M�'^z�E]����ù����;�!�V�0��P����P5ԫ�U��D����D�_M�r#!
�����|z�a�h�����|���s�&�qB��gc��/�נ�1��y\�0�'@�5�7\ȴպJ|��a���'�:L�W d�;DMt�U�xQ羇`�O�L}�e�#)�00z��j�Mò�gN��(�gK�D&	+#�/�?��=X1�E�������1V�����+�{{c�a�l~�;̥��X����Yo���k�\3x�樘=�˩������
o��m���6��"�&��+H�"C��"�+Y!���|#3�M�H{C</BX�P4R�sJt;�m׷c����m%&
aD�J�5�)a�S ���*�0EQ��[-&�*�Wµ�6t"+��$3�Am0Z�f4� ���[��T@�/�w�jG�֐���)��8���t�K.8# ���F���PM�f��M�|
�Wti��L�$�Lp��i�¢Rx�l��K�@2�R��WJ	o+x�F�W5����1a~�v�m��e�B��8�%Rxm��� ��j�T�l����ez���\1����-c����D����������"��/F���������0V�]����O�����FM@w��c��2�>E�i�0�D�A�Q:S ��+�Y�0�jX�o����ͨ}����u�^�a�}n�k�$Z�����c,6�X�"���za�޺3�6<+�uc�z	��5��������`���:�����|����?Vw��"�.OA�rQd����I���?I
��W��}˜3�����}�?�����W��O�??���UNE!�]Wx�c�^���v,�Wc�(D!y$F�X5(ƤX��F�%��-I��-��o�I��ƿ0+w:�cEd�����K��m<�~�a�n��:���fc���ҿ��o6���8���oFtX��u�X���w���3������7���'&6^Mk�6c��&�q��D��p��Ώ���x��#����j�w�����[����O����6u,X����/J��z�_|�l,�HSC�ᴡ�1�
r����ul?��}��Ź7�b<���Ȓ�Uod��c�1ʲG7�
uH�#�;����L6��D6�M��M}���D�"���DC�e�r#[��Ρ~�ޯ�♾�&���V�%��}�,{u��0nO�J`
r+#�T��K�.SWr1��cR�D+߬f�v5�ځ'���\q�r����;]i��SA�:�/3e���a�S�X��*圽i6�o��YI��
��^R�.N����w�A{*fo���se����
�r�;,g��vAӸA�;��"^��^�p�<.2�����U���GZ����Bڂ'g]�-uN˩�\���2��W���M��OO��&Q�J�sq�bȽ�I�h�I�}��J��2i[�\j�|�Z��ឌ�2���L)'��F*�Hx�{�=���񌳽/��e��;6����t��B�#I�'�����~�:9�j�J����iX+�����E�:��v��Z��Q1r&���Fo��\��d�涖��^���^#)�H_�sq����/d9��H�j�^��K���x�<�N4�����f���o贱d���%ґ�*����,wr�1l���5�\�����_����Ƈj����*&��BM��y4��PI?��c�D-��6J�~�h�_�kF�Hu`*��ŢN���8�w9��c�n-_)ʻ�t:�S��1`�����`��Co�z����O���O��Kc� ��������0�yx��������kw�<���۾����?<y���u��j��'y�`?uJS3�lf���=:��z��P�B�㲽������bj�y̜��\���M�j�$R���]p�X�J�r��&�B%_��*��4LD�_��f<���cF<nU���ԗ��*�{BFm$�'z�0���ȡd��$��j�x�i�����w�a��׿X���{A����$����;�Y�Lb����e�$fY�Y�Db����e$fY��Y�<b����e�#f�m��4�~�1}w�/��o����[|6�ϩ~�їa�	��������_%~�M�Ϳt����yz]B.u��\P�����ў�J'+��~��<i8!�G�x�?f���Y:�J!�)��q���X�0d������l�n��Q�?���%���r&���߀���s��o>A�}�b�}��ֱ@�#7�K���?������4.>���NȚ�$�ED�E-�<!Q�G�7��go�Y^]E����È��L�=t#P͆ł H����4b֨���ѵ,І:l���^�*Ѝ}��>Y��C~Z�~�z^@; ��G�G5 �4�P�w�/����w݄"[� ��b	!z��"�"���T����j��z n(+���=ò�_����O�A{o=�Id�L�'5��N�?6s'��z�>��N.Y�{v�>u<�%�ê�>�.I��j���M!�N�3���=w�vL:�� �0�7UA�<`ԃ:}L���ZF����^���R���f����i�>��$b�lSE���{�(�O��}�j���
���ۓ	��i}pTl^<�&�~�mAy,�[�ｐA��$p�����,1�$Y��C�3���$5̷�����ؖ6ә����7].�C)ҙNg9�t9�N۫F�!��H -h.�nH�+,�!�8p@�p��ȏ�.קk�zW���.;2����"��{.n|T�,� ������P��
�� �|P�\��]�3��ԝ}��ƈ]���;��?~��r1����+�x�idt���v�� v�����FNR.�Iȫ�Sr�Z�hs�X>�3�q����&L�G�Kr�\r���Jx�a^:�r'ùaFr�����B��\�2̳�I2�^���;��S����ڙ��/�&�i��s
���K�`�WD,t��\1�@�x �����0�!�ԇ�{Q�}e�-C�'g����G��9��o��K�J�U<j!���G��ǟ��ݐ�b�j���&�����f@�3�u]�X�=��\�T>����$X1!e��r�!Tj4�gh@ S�3R�~?� ��l�����HV�v�iSUC���a�,��r G�@% ǰ��u� n|�4��#̑6x�Nۡ�S7�C2$�Ir�v���1�*�iz������ȩe��bw�iC�l%A���Y�)��@Q0��"�ç�w�"�ݭ	�f}���:��z���^Y���*�m��S4����sy���d��E����_���_�?����������������?��o<����R�g�=�X����/�m�������v1�+�|;��g�
b Wҩ�J%b�DZV�TVM%S1�Jd��^�N�ɌB�t�2YZ��/IZ�܏������o��ԏ2���>�ӅS�<��'�3��N��n,�[��?�M���EaE����w��u�"�_oE���w�ߺ�������Z���E����{�O{�͑�{����ut���c�:W���L�u`�lQMZg-��#V��ój�^�3v����۞�G�D��+�=��@��>3�{"k���Q����؝�Q�NlQY1�x�Y�g��x�0m�Ճ4B,��܊)����1�%�!:��5�w&\���tG٥<2b������;������@U&=�2C'��G�����-ʣ�D�M9r�5��Y[l8NA�y8�_T�:���7ب&�u�JuX.3Z�ꨴdGJ�|-G-����3����]-nbX�j3�j��n�21X��y�:w�j��J������|��P3�S/FYνV�L�����L�@�y�q8g���-�Ag�+f����	^��Z��y��"m�3�9�#�[J:3��ׅsY���<�m|�5 �#h���,j��l�xM��E6c$Wz���h�D�Rz\guT�i9�pb�Z����-���f>�SRua�G�D�x��3�V3z�����_KM/�J^���3*a�J��,2t�5��L���ZBirH�b���HT#˞��T�ҍ��xyQ��?������V
��dϗ=J��[�ɞۉ��S�H���nL.�N���9�W��lkҥY|���.U��z�ۖZ���1�f�]�����-������m!�ȷ@��p%[;�R�9qL�O�S׋?O#~�]���l"�l���W'U�2�*`�V�K+Bʉ��Υ���l�"f|>�R�Q"�%��Ŷ8'?��L��R�JssRN3sΨ����G�z��mU���������h�I��+�,��.������#�D�"�����t�ut{������ߛ���߬DpC���[�/�Z�#O������#o�}%����;Q/_�;��z�.{���A�#�=ؖW#�D^
pY����Z��"�{'�_'B�\�}���x��݋|�^����Q�_���+��������W%Kgkl{Y�Ӎ����]��@z�2?�1M_���m��9y��p��D$�9q�Y����\�m��0�"\�Uwx�c]��́OD��s�*b�a�@*J[b$V�y�B`ׂCdY�����,���/�g�\�t�Mjj��NdS�D{~�dGT�:�	r�x��b��~4襘�HV{֤�؋n��2���d�/i�0)�T�!N$��r���X,��ϑ8��ux���ZX`%1�bT�a\P8���9��j��LTәV�p�;>H�mP0�!Z,�N�iڌ���#bCPj�"ñ<�3����N
2%Z��1�ԓtbxR��K�Ѻ5���M���$fչ>�cu�0ԃ�|\ng�D�'�F3:]
���*}`�7�%�R��@Q�wJQAh���\�3媥����?y��%��/���
r~��
27�|�HT�&N8���\gY9�n��&L�4.Hs����O��m��'w��gL�k���C�m�ꅛ�p"��\��3Ŷ�v�f�5`��5�S��Y�����Z)G�m�ޚ��U~�%�QV���u�\\�ׅ3�蹳a�[aR��y�"���2"㸊2�*�9�a�#�X��\�LFk�b��굄�勋�f�g������ĞF�l�\8�r��xAT7!�F]0"��N25��=VK��Pj)��L�K���wE��h4$H0'%2�b�?�u�O3��x��|3;�����\=ifJ����҉��Z��HH�,ׂD��G���DO�D*˖����G枯 1��	�E���[0b�����/L��|�0p9��R�}�B�׼��fi���{G�Ɂ�2�5��%�����N�Bl8�s�oәy��4�_H
L�٩D��]�*)��2�������:�Y�H��V��D�!PҭrG:������*հ�N]+ͣ�z��L�=nJAB,J[�7(,=(��Ki�R�./fTR9n3]�99�.j�|D$:�Rf� �0Y���\tb30��M-��*��\�XJ�n��mV9��_EL�^_�E�	u��!����7ª[P��ƛ���U�
t�_"�y�hC��E������Y������%-'j���kī�i�A�}�gX`�M}�Fފ��G������'O� �7�7p�u��j�U�z����k,:�8���>����z��+Q0No�5��ch&4!՞�Xf�����~p�^�&>�M����/|�d�7��ae�Z�jE���Ļ��S�({t�t-�c�=�%�ߋ��<�8�C�D��f������/��_����/����s7��H���\?Iz���_HN��U�wx����rja#Y%UO!03:��I�g�`P�"'`
F��݅�^ �5�����Y���uH�a�4���cv�T���v�	��ַ�O�7�kUamd�]�Y�����z�'x:f�,r��"�kjj�9���9�ш���B. wM����6�����n�#�q)l	�y��򇭇�Az����k1�l�04��S�Aj@=Sd1�Fv�T�.P}k�}�@�g�wA����#9�!�����]:!I�&��93r�B��:��<x:�~e掗<�}��� ���հm�	k��,�\�x@~��$�#=�	7�0<ޘ�I�5z��C���o]��P�F�s�0'�X���9F߃2���q!h�X�Ԉ��Q���5�\ f
��?9}�۶b��F�� {�u��`�l�N �uHn��1�����l��	7*��:��H`U�e`��y]3�֦���O�qH6LQ�E�o�Iը���D������k�1�n<����g��];���_m���ۦb�>�A��5$|�djZ����/��-��=�����lS��4�Zs�Y��a�*�7�����Đ`	84"uao@s-�q/b��N�D���'��I>'	���е�Ƴ3�p@a6x�OB�xl��9��6sZ�J�T5�e�Z�i�jJ#D�'(�dm.�f�~�%�����/���oC=��^ƀ%]C�}�/��mz���?�٩W�[���,�ה���l��7�b��6��^0BV����d�N�a#
H��p�{!�$mmBG)H��SӰ���G��8@4��)� ��5pcC��)�e�6�#��G�Ѯ
 ؉:�� ��P�1s�o����p�gP��j٥�+?�b�2ʅ"���kof��׫S�[ʺ��=\�8�
X�Wq6C�l�u5�}��-[͛/�y�H�O�
��u���tٸ_k"�߫[�CD�D��d��n��x�]H���#oD���jf����`�v�!e�Fp,��z�L��JU�qDN�v��ƍM{S7���b��~����l,K�9E�r���M4��E�Y��LS����d"2n1��n�+��0Vmǜ=���)?s�%Br�����G�W���V�w5���p���S��]qvm���O������x*�b��y<^��C�C�C�@(��\�dG�%�W�`�7��2�<�{�y�m��s�"#=��v/����;
6��1�@�*����{W�B�gy�|��׫�˂�^Y��y�z M+�O�d 9���*H��x��J�{=�O)�> -���,��}��M�D"�:PD[<`H�.��[n�-���r�Z� r�p�=��K>�)�ɣv����1!���0����@RY ��@��X"K+@�h5ы�,  �Jd�t,�ʨq +(��Ñ�d�DZ�@
�p`����N�↷�C�m�����������M{�M���Խ'��a�]낝�wd��b�7#�j���|�o0��r�P���#E�g��ل��W�k���֮b��F�BS�b�{����ɺ�����K.�]ѩS�5�{��.7�tx�	(�7�x_�@���N�;5'vT3ѾZԚ���nf2ƥ�s�I���������qb��}M�������v~���<Dp������� ٍ�Wl�\�����=Wm��B�pZ�������"#TrUn�ӥ	�g[�ͬ��)_�jU�"=����a4E���s0�NgcO�zh���D��B��r�(�ק�KFo-m����`�b�)媕�P8��R��8a��dt���Y���3�Tz���i58 ��$�\�mJ(�8���a�&�(g�z��"���9�����*�ȇ�l&�L	4���Q���=|g�Q�z		S����M⠓�u�D��8�������Fw#�n�ߚ�[֋���f+����u�X����[m�;%3�c����]�n|�gk����p;���V�����
EG*�*:E�~�����v�8`h��t���"���x���_��u<���c4���b���y���G�f��t*�b������;I]��{���y<wO��a����w&ˉc���)B}38G �B���P�=H ��_�ӕU�,g:�[���T8�N��W��sl4� ����Ӡ�H�A�i�|������� ��?���%��߆O*������ߛ���w$��@h~�����?��{p��?$��q$��(p�"9Ĉ�jK�Q0c�0��PD*�y�gL�p�dS,���>�����!�gx���1p����^����?��$���f�֏�=Qf�z��r�H��.ӛfq�<:�����q�n������Z��������+�����9�邚��>�3~9=�K�<���␌������R�O?ݨ�]}�}��������������x����u�Aq�ߓ��(��� ����������U��O�?������n����<���S���S��_��S�}��?0���Q�[#d����_��s�����(�K�����DсJ�������{����8��ꄣ:��-�?��z��	�H����>������X�?w�������C+ ������?)����������?�?�vН�Ⱆ��R+�ŰP��?�J�?CKپ�n�����~�#��������'��Ϣh>�̪��}s�/c��ҡ)~�h�r�Ռ�l_�u����z�{\^��]fRenύ��[e�8�ݶ3�jˀ����}r�}q���!}"7�ߞ�|�$~d��竽��I����@���5ᵹb�e��cL���t���w{��s��尨���\��zb��YW\YK;C�PKv��E�6-��1Q��d9�?��aޗ�Q>�~�=�˃i��N83Ken�wK`����_���QHT�����a��P�����D������'
��F���O��	�?U�?�4�?`���4�������s�?,�����w��@�Q���?~���?��WǛ���k�|��gzp*��<�i�tVi�n�q�������s\�%�/���b��뉷���^k�j�4��F��ǳ����}�;���p	����0m��vR��Z�v�H
J-%M��[c~�v��!ؑ����y۶��)�'��ǲ%Oq��<�Z�\��!�BQ����+�/u��-��_�w��l�)�*i�d$qpZ��<���m��Η�T8(6����A6IWN�������"�YE��+�zҨf�:�I�x��Y��=u���7����G��C�o_�|{�!�� ��?���A��W����_P�GN��Jg�$OE���ȑ�$1��a(�!�3>/�4�$�!�HL@�$��������C���_��?+;��8�ʶWo�m�ȶ�x:��y���s*Z��5�'AS������ݜ�������$�^�ݑRwMb:�x����sN�f;_o5���d��jڰ�#{�x�z�%����?j������?��������
���������B����20�����5��������Uǯ�������^;mƉ������xy'��e砇���-B΍���%��;��Gjҫ��o_2�-��v�g����n���c�eB����O[m8rk�U��f����������e�d��� ��^��Ӑ������Gx���8���Wu������A��_����U����;�Gs��P���ʫ�K����{	�7Uُ���9k��������hQ���R�^��76������Ϝ@<=�g ��� �Zհ9Z���S%n� �y��f[�?4�z��o��n�%��3�Wk��]��f�Z���!]K���#�Y�jg��@;��B���9,$;߬�D�9��8��n{��^�z;�6��R���AI�r5�������/��Iҋ��i�h�H���+�HQ�']��f6;43KM�'gn)5��QV��(_jZ%����OeKwTC��y8�u1:��P�M�fKI��L3:b������ݎ�*�X���;��/����j��|o��"9+6U_������x���(���c�������������U�#��?8������+_���$ ���-�����s�?
`�?����������O��W�GI~�s~$+�B�G�!�K���<+�)�b��At;�gh:��b���;?����O�����W��z��,�ݐ���ހ&�4�G#Y=kv�����-y�b���u�Z0�%z��%������}K<Պ>�Y3Jw���äK����ǗO�Cv�x���[�pHK��A�X�18tIf݀�����?�>8��?H�x���x��U���G���Y��� ��������4��G�v���?���O�w�?��Cr��o?�����J�t�;CA�o���C�k��}�nFv�Օ�e;ҭ�\9w��aYI��&�/��:mω����=F�L����M�c�wQ��q?�ǜ��R�xě��ͣh��j.���m;'���Ss��r^������6��x$�����7e��Gn�r��	ޮ�D��̊z}�c�K3)��`�t,�m�Z�����vm[��������GA1�8�;��\�wk7��=�j��R�͵X�?�we'��U�Q��txBՓ}0�Ƭ�7���W4����xX����#q9�߮��%�6���׍��KLFV���Ee%��þ�u[62p�W���V���
�������4���׊@����8����y��!������������>���R X����8�?�����?�Y \�"���� �G���������V[�0�M��C�������V�:�Ǡ�����������$y�3��(@������P5������?��]�?,��������z0��	�?,��������{p�� /����A��?�����H�����?��[8~
,�u����D`��`2�B ��������?@�����XH��?�����$���� �`�����U��`9D�@���������K�a9j����``�`���������������H���ei��U����X���g����#+������C�u@�?��C���:��)����G��C�o_�|{�!�� ��?���A��W�8�8�?E]�`@���PR��R<�@%�f�@�b�!Ò�O��/����ϲ���>��/8�?�S�W�_��^�]#��3��K��l]#N��"P�I�-7�8	IE���۴.�ˀ'��<"]j���juZ5�8,������l���?������5\�_j�]��m-��-���]��*憣�Lu>����KǴ�umx�t�ր�ױbͷ��5��{QU�ᘁ���VG���|U�J����_u`����S������V�f|Bp�����W�����s-��Fmc֙�jkы�~��6��9��;}����2w���.�l�6��������&s���;�H�3un��pzT�C�YΧ�sS������2��$cGm�Y��:gC����q��;�����������7�C��U���������U��XX����Q�������>��k�����vĨc��o܉�-N��8�o��ٯ����f�4�S�&���} �=;��]gxX�a����Ҟg��t$d�b�H���heQ�w���$c��g������rY��~�d�}I;	�cK���vf5�q���ɗw�����ҩ��g�P
K�~J�7��N^���@���V=Iz��<�-�2?�c�\'�(��˸��f�fv?,ʖ�FK8ý�Y�M�I��bd�~�4"���ٛ�ǣTkv��)��џD��:�֠�d��k�$��dךp���g���f�	{�?���O���Ň׷����뿤@A�	q�_���ן�h��H�!����?a�	����-^؂������$E��� ��I��˂�� ��?������J��q���:��^5�(x+�gTU�._�X�i��6�T8Z��t���Xw�"�~����&�/�?T�u�t[4�3n��W��JW�{�����Sʏx�/)?�k��)��Kͷ�_�.}KI^R��[�򖹼m-!���d<�J~ɴ�׬��(ŭ��mog8
MuW����Ӊg��k]:�Mr���L��i��9���zY�(%K�ԮsJޡl~5nG�&�*��)%�r~�Rb1�������{ʾ�ӗr��zY%�귟eM���'�9���>}&"-qREU�ag:�35��o��~�)��}������s����Z���,sb�dM��T���*aۜ���Ʋ7�'�ܓOk�]�\Lm�Zb$J:��Jឧ��_�����)IO�k��2�p,�]m��߼�X�?��꿈@����#�b�@��K�Ҍ	)��0ˇҌd�7~6��f>#|ȅdH��!�d�G�C�������	���_㓙����K�U@������Ǹ}�g�"z�)���{��W�B�Ǯ��
��/���%�Q��H�(���Qs�� �����a���f��������!��_�������?#O�A�*=e|�u�?�Yx���h�a���P��S��`#ޗ�[���G�L���#�#�7���K����{I�ߗ�s�4w[�RR��p�U�]�v���p���Ik��I#��j��y�9yY]q��E~�X9g�r�n���صG���޼�Kڏx����\��\ORy8k��QMr����Fr�hӆ���ec�,e�x����I|Y�&��o�Z��Զ�w~����u���<�]}�
|�]]���| �z�����6{'����l��9��@���5�Zs���{�^�pl`Lr9i�!��Q���a�#���M���[5q��\�&WFq�wcy���.7W}�?ʌ�����.ȃ�#n��@�o*H���TZ'u�.�q�d�	"��������i���e���{�X��8E�N�[�r��o�4����+=���{{���?�F�=	7�"���r�ScU/�^�cը�l�@�z�y���lIT���^��~����c�����<�X�]�?�_H��W��_X�1� ��Ϛ���+;���g�����?��������?|k��O��O�?v�
*��u��k4�r�X;�w����t��a��/��/�}O���cuݲ/&
ȧ	"��TB�Y�[�ت.���&�&��U?m�F�q��B~t��2s�<.]�`�O����R�v]�u^�K���R:-�a���N���U��!�R0صF�j�u�F���c�;��I\VI��5�p�ֳ
N��+wX����%:k�t�m��Bp���`�lt^�Q8���7Y6���}ߍ�k�ׇ&���R���ao��]��ۺ��M�Bn��G/)�+��~|�^W�٦���rǐf#C�������>�W�d��Z�ΚB���X����,�$s��Y`XSw�Q(�+6�T0#|�ڔ�ӯl�����Z��RA���B�W@���/��?e�4�A�\�����L	�S�B�'�B�'����{����� r	���[���a�?;���`�3�"�������O���o���o����-����_Y�%�kH������� �O������?SB:���=BN ���=�������T��'�Y�; ��?{�'��X�)%d����=����3����/8��	��/DFH�����!���H�� ���p�ȅ��n��B�G*�R�AQH������_.��t�� �)!�!�!�������C: �� �����i�?����߷�����f�	��/DF�E�����0��
������������ �?� K�8��g���[��������
������r�C�f��������E.�F��OF�R�-�cn|��� ��}�<�	���a������i�L+3sJ�+$��sͬ����,�)�`����n�ZE��P��U0�Dc4�1x���/�<�����!�?���;=y�E��0���R����5%�M��_���בP�$,R���nע��ڠO�VՎ~��b�V��W'��Z%�p�����c���A�5�-�8*�a�(r�a9@g�zh��h��xc����{���W��w;�(�4�r��-M\o�V�7�r�=�,���8����Me��9C����Y���
f}�<���e�<�?��d�,����q�u+�/����e���q��$����ct�aH�ԋQE7�qԲ�մ�3�P\�i��ՅѲ=o�˵�����k|2XS8�Cb�F�U�,�;�U+��n�ʉ��J��v��]uN,%�B|���=��"�	�3B����>���ب!�"��2�A��A������h�4`�ȅ���k�W������������ݲB_�k����ȑ��X����?]�=_b����{ڒ�Br�/ې��m,&�\s�w)���Yx�ٵ�f�j�y[s'E���qqbF��	0s����K��0Yw��#�͕:�JjW�U�A��w(��ЪܶɒguvN�O�J�T��������d��%�\W�>�)DS��k��^e���\D G���󛛂Re땚��C^h>9�|"�,ΞN-g�8ޕt��7+�J�+�m��ꔍn~��C�Gd�|,A��}1]��,I�="5iw�騭K�ڮT����5�K�A���?e������d��"���[��U�G�I��!����gn�1��i 5�z���������5������?��2���,��s ��g������I����E��n�{�?���O������T�'�������c��$����G��_�B��7�A������ �) ��o�����2Cn���������_�?R�7�?NI���\�!��}{8\�[ӛ�sS���P����}�����ڏ�������c�G�aȟ��HJ?�W��N���R�۾��^�7����vKNدu�.֘��J��uq�E*t�����o�ט�MkEg�ufN��i�_k�xRf$���i�ˑ=e���"?Z�{)�En����pZ;�Z;4�"?*2L�J�-+[�cu*�7�����[Gn�����8.;I��p�����0�r�����Q���a�#���M���[5q��\�&WFq�wcy���.7W}�?ʌ����\�?�������g�����[���a�?3��_�(@��E������T �_���_���m�O��OF�\�=/�uS�% ��o����0����#��q �5r�C�f�V�_�&��/���xS��!;p\�<RZ֠9�R��������H�.��������x)S�� ��?�j ��`+V�G��u���e���(�le������N[�z�1�����7e�zԦA�n�F6J��V�����닊�5F��k �����  I�� �"6걲5���vE��..��j��ۆD�
2�2��(�bPٻ�=VѺ��QAeݒ�C��C�{U�,tԎ��h����ۊ4�����F.�~c���J��O��g��	���[���K����������c������j�K�F��Ѥ�S�IX�bP�nb*��&�C�2C�i�c�V��_y��[�B�:�����wH��5�3�9!#	;�/F�~0��ڊ��iX)^��<��	���VQ�|U�#��Pg-W+DZRrd{VIU[��\�Oe�(.NÎ:I8��5tM��Y:��l�'���k����?�C���T�p��C��_v��C�OfȜ��������.����/;�����Vc{!jI��9�T�%��\�����"�S��"'�n/����v8���U�zc�+���F}L!^x�#j��F�V#���rO�R��#lK�N��C;�M���*0'�$ �{-���_�QI���o���]��3D.��+3@��A�����,�@f�<�?�*������D�Y���kغG��}�D�"���-�^�t����S���?V�\xYP\Z�N]	t�U�n�w���Q��W;Uӗ�h�*-<�Od���Ŭ̄G��O���.��beh�(�Q׽@�jxyVlm��j�s���2It��Q�����{��є��%c���v�"5�/��[����ְ�˒5�,ȼ����)����)iW�Q�o�q||y�h������s!=�k��-��"�q G�!�	Ku�SjF˓t�I'�v�B��ʚ[���D���7�S�`蕰a�{|��#B��zmfu��)��K�
�������&
7��Y������o�?F���3�'H�� ���swnn!�c�jh><u�=|��?�ųo���z2����vP��}g\E�ǅ��t<c:+��?�r�g� �8A��fz��[m�e�����u���%;���������������6/O��7ƿ���\-\v?m����x��<%����!���3�1��������v�`������������F����6n�t� ,����Y�|��j�<1k՝H`���>~O�=�?FN�j���k��k��N��J�,��Vm���|߈�7w���D�r�w��Q���x��߽�7��k��a��������]��/x�<~�9�����<&��Y??Յfr��ܿ�{�>?��^�o�ܟp��W�0On4R�&47~�v�e�-�/���B�)<>H�a�����7湕�Bd���\�q��*f2�Ss�����(|ν��|�M�=���+�O>�ݭ5�����M���o�;��������\z�����|��5z�3{���2��|9���O�aS����QX��_rp�ܨ���x������*���%�-��&>���o�o���A�}l�;|�%��cvuI��.H��Lᗟ���U�H.����?�xY              ����O!�z � 