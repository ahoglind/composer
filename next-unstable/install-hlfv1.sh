ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
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
WORKDIR="$(pwd)/composer-data"
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
export FABRIC_VERSION=hlfv11
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.17.0
docker tag hyperledger/composer-playground:0.17.0 hyperledger/composer-playground:latest

# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d

# manually create the card store
docker exec composer mkdir /home/composer/.composer

# build the card store locally first
rm -fr /tmp/onelinecard
mkdir /tmp/onelinecard
mkdir /tmp/onelinecard/cards
mkdir /tmp/onelinecard/client-data
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/client-data/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials

# copy the various material into the local card store
cd fabric-dev-servers/fabric-scripts/hlfv11/composer
cp creds/* /tmp/onelinecard/client-data/PeerAdmin@hlfv1
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/certificate
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/114aab0e76bf0c78308f89efc4b8c9423e31568da0c340ca187a9b17aa9a4457_sk /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/privateKey
echo '{"version":1,"userName":"PeerAdmin","roles":["PeerAdmin", "ChannelAdmin"]}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/metadata.json
echo '{
    "type": "hlfv1",
    "name": "hlfv1",
    "orderers": [
       { "url" : "grpc://orderer.example.com:7050" }
    ],
    "ca": { "url": "http://ca.org1.example.com:7054",
            "name": "ca.org1.example.com"
    },
    "peers": [
        {
            "requestURL": "grpc://peer0.org1.example.com:7051",
            "eventURL": "grpc://peer0.org1.example.com:7053"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org1MSP",
    "timeout": 300
}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/connection.json

# transfer the local card store into the container
cd /tmp/onelinecard
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer
rm -fr /tmp/onelinecard

cd "${WORKDIR}"

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
� ��<Z �<KlIv���Ճ$Nf�1�@��36?����h�&ْh�IQ�eǫivɖ�������^�%�I	0� � �9�l� 2��r�%A�yU�$�eɶ,g``�U��W�ޯ>ݪ�`;��]�tp���A�6=C���;�S�P��$�Md�x��|�O|�O	�8��i!�y�ω�s�縲��;�-j��p��C�!��4r�p��lj
vr���v��_�+k����s�Vڨu�6�u�u����T��Z��:%Btm9�ϑ��qv{�}@[Uܒ=�e���bې�a�I�|X�M��XZr�֔��#d�Ab�N��x&�:�����?-��'�T��:wNf����g�?��J�N�h��O�<�	��?�'`�!M�&)���E�ŏcM͈5e��9�g+���#E�?�f_�O�������v� =�?~F7���Ud�Tx��馬b������K ���4&D�Q$bٸ��I7@�,�G�� �7-�oj�a�.�m����iv��^����ؿ��D�D!��s����nE-�P\H
�ۑ]t��5ʆ�l�51Tbd{���qR�p�N�kZ�opO9�ʯ,]W�
!�A�'78�����`���p=�MP��a�c���#��8N'��U�3�����T�Q�|R�\K��$q9H]8�z�rH�,d�.�Q�E�>#R\	�J�f���Àb$1BeV3�C2)��g��ǰF80���64���ؑ9b�a�hL��S}�r�#?'oΰ��oLi�i�*��|}pa�$d���KZ����@��G� t5Osi'»j���퀠W�J���:���c�E���t�i����9��\�ʉ�"*l���Qɗy���|D��6��;�nlEEH.Q]��4�Ԝn#Դ�|p��p��������5��}���#+�jx>��2#���ܖ ���� L��X ���E��������E����9�8���d"A��x"��t�7����^HayRbݴ��pYv�(�f���ߌL�dc��Ò��5[n�ͳm� �$?�=�^v#��^���*�K��������-��O�������� �k�%�+G� �]��RaoG�o�6+7���Y���N  �A��`����%:z�|�l\��+a��>'`$+�kK�M�,Y��w�!�{�RY��n����,����`�,չql�W�Im�r�����K�H0�1z�-�$��#�dc��1�Hhny"�9T�L\F��mb;�>�*ܦY)�I_"�S:-�	 _��M"��1�vb�i� ��A�t'�v��ߒ�XTD��8��/y���Cl ��@�JR���������L.L�k8��Ǖ!|�����$�Gy�U���ߴ�u�h�1Pz�0+���8.�8��\���l����l�Pv	o��aZech�Hx�ڧ�ل]�@8h�
���l��t\�rr��t�fT1������i�N����(!�s;�M�p���k
�K�D0���8k:���i��=b,�l�r�td��8��ѽ��c���\��6=MW#��t�C�Ё{��"���t��L[c��x<(�w[�P��h8��@L?HD�Q~�����4��G���M0�~Kv�e�z@��={;<�7�<g��������_D�����2��ߴ����%�?��$��en�ow�a���!�bl�jW3
���#8�����,�2ir������)s��ˉ�?\�Vm�,)_��f����������Ŕ�z����V6R�T'���b��
���e�]t��h!�6��f�"4w2�Uf��Ԇ���x��ߙx:=��}����G\����i�8�i>#$����N���"ʙ���
8e�a�y:���I�s"A����S���J��4PK�a�6�[Ȳ5��/�v���:Q��F0�m;r_���r��6<|�-9���(���E��=�ɮJ��>~ۅ>�����u#�76�&dLe��I�k��8v�/w-}[��,��Ue��{���N����!	�#���"m���jr�B'O�s.,,D"�[7��ºt�Z��n��c,Z��I_�##C �u������^y�(M�[X��6���r�z��8�h�7�7<d �&�W���E���%�W��y�l̉�����M#��_ӽ��S�?���faC�ﭖ�I+���^L�|�$L^j�/k�`oړ��Jb���&!P�E�L#��9�v�,�"����xgx�
`�A��l1suP�3�9�C�l����ݎ��{�S]�	%v=�3��cl����7U�!��	�n�|k�0���{V��XOBGdP��?S��lX��k츏d�� 5�6�̲�/���K1���)�\&����2z�t�f&�]e��him�?>6���n�0{�Ԍ�X���qq�ͺ�W�@�[��fe��V�+ǘ�:VVF����4%>�`�	����У�P��mѿ�æ��^�eSM���s+��g�i0�7��r���n��v�3������&���E�W���<���b9B�哄ET��7�\�Mѓ(7��$r{��4��t���瘣a:�G�h���z���i���z)�8|��~{)���t��̮oZ�協3��Q^��4κ�3��<�.���\@y��f�с|�/=��/O'���_�����L	���)��2����;.*���mE��N�T�T/�(�H�}�� r��z��T�ZK�`���_��D"��9J!� ��+��Z��in�ӳe�ޮ��ԕ�	K^��PQ��j�+�}���d�6� .y�x�^󕽍��ܦNȞ�����.���M�װ�m��$������ѧ���'~K�}ə ش۲��lsm��}�i� G��5mW�S]�<���<��j��v��Bs3��͠;-K�Jm�h�/-`�u)��_�M�1��F���¾��*�^|)��(�H���j���f�i�N���ۘvR����f��7���P�)1S9�S��6�l��Vy�q"�9�1E��"�cz��1��s���Ө���W�s�>��;����"[T&P�m�	����&��|�	�K8N�/s�J��6?���g�h+������X$h�i��Q�
��Y�� �R��.�P�X�����@K�
 
��?��M��|�4p@`�ݎ?4�{ΈȄ1T���r���#������
2�z�bj�l��Y�	�� ���rU�,Yϡ�	�R9/չ�����t�����'fq���
wR�v�&z���r�@��1mr�c��.�&fA7��&R�h��~� �6?�D�Sl�!_-i�6<hݶ�������.�`Feݣ�Q�k�S��)�?�m��V��C��}w[����;acv*�T!��P&�z�G*4J���8=�PI�Ĉ�$ ϲo��cÑY7Ӧ�&F=-#H��~�	��6,S9�Q���_�,�A͞�hdf��������_]eM����3�'�R�7��0ݕ
ȭ9L�}�a�EU�����%DN<����]����Ŧ�2~���N�G/M��oOя�&�K�P,#$�3�}K;�$Ϣ/x��gA�FX���بeP`'#��DD�����j`�1ߕ�Z���" h-lwa(`gA�s��>6R��%:L��.��jX�n�@�N�Gn��v�_�mM�aX��1cѱ��I e�pv��A�4���{֨���C���{.N�ƇT��O�d�`�M ��	�Y��<F�$�h×���\�r�6Hx �u͡zMaP�5P��+x �@Įn;��9z�i��dn2�5�y!�/���0���9L��,�7&�	��T�����H��}ڋ�;��s����ߘ̔��9N��@��P �ń��
]��"|]��'���^f�����)4Ny�?��S��tb~�w!���w�=���w��w���?�v�W��|r'�q%���-�W�dVn5[Ie9�M��Y!)dd��q2��6���"'��l�of�SBs9�
�ѻ�O�����or��0ą.s�D�2�w�,q�x�'�Q�׹��ݟ+})��K�H��t��O8̽GW'N�{�_���7���0d�0߹�P��o�~�FA�:&w�0~����l���g��������h����Lħ�?����_L��WPb�����2��?�׭��-�o���_��������|�;����B�s_����܀{t��w/�����cwz�GS?��L'�*��r2�f��'�d��&�,N���&��TR�
)�ZVyAH��嬠&�\E�J�{�n������|����\����m~����c�� ��8��x�?��lL����Џ?�e`���0������?��p�*oUC��A��B����$��EH�Kk�
*H�Fi�T��ʥR��_(���{���.Պw�����훮~7��S��v/_7�������f�V+����r��q��nq�V[�zww���F���Tȗ7jª#�x�tS�nC�_��h[�_�l�^Iz8�v���������WX�N��L�5�[)����Z_�׭6�RΛF����q�E�ڋ�+G�P����k���C���6�����~�H��oWv��nC�w�z�'�����Uܽ߷v��fW�뻽U���K=�CH����N�[��rX��V{`C��a�J�^w'�{��5׶�]!���Z��9�_���J�\=�I����a�h?^k�%��(֔b�-J�AM�ӻ�����s�t�qw����tb�b��0��Ov-g�?r+��v�����������̓&�9Z]�n�Oz�x����TG��ʫ�^��Y�W��z,/�ܷ׺eq�̂z�Sw׸�*�C�{����{bO�ǎD�w���J�Z{Mv�'Gj���5�'�.��n��1���Z�9��k�:֓d���W-�e],�{?�o��]Yj�]��]�SG7�{�i�f�JU)�m��څ��]�N����[�n]\3��C��nl��{�d���Z��g+�QӐ*�����S�i�X�RZS]�x��N��@���惌fJzmz\=�H�Ǖ�f!�rag�ܗ��:S�v�pP�4��.�'ߗ����6kS�h��k��]�яv���ZC|� ̆���{Wף8��G�Ѩ㝝1���N����m�o㋕�_l06�Y��6�l0p5��]�(���u.�/�����WSTWUWw۞���E����>�9�}O/������a_'F6
o�<c]����������QÉՑ�*�7	5�c��c��d�X;a��td�3b����ql���e�����C
���n)�
N3� r���X�2�İ�\۲"����t���v�^��!�e�luV�j�j{=���*�@B��T�eU��P4[dv��F�����g��?֒���<�\u���2^Y`F�p�U�bm�p5Fb�����X���U�>�k��b���d5+���J��D�����O�uh:��}Fڜ�qxX�H���m�\�l�i¤K�Y�H���3�w�7(���5r>U��`^�K�b���:��(զ;���@m��?>�1د�/�*��L�'H��(:����)�����hv�GHU�Ó7�]�4��s��*�@��$��O聒�J����%��y��W/ %�G��a�����Ow���z�DJ^c[����E�7��3�M6iN�Ut<�h�*]�	���W��oœ��t���Gh���:Ɵw	?T�xE��q؂趠n��N�j�bF�q��D��P[�o?u������
M��'|"n�l��+�������"��cNb�u����:F]Al�:��+�	`�����q�M��
���a+������`	�+�*|y�����^�"qo7��t|��~��7>튓C�����W�ڜ�����������ts^�f&�t����u��B���|Q��`��|�¿}��۫C���𿿆����������������������|������ۘ/E�M��ɚ;U�Z]r�91�2>t̯��~��z��;q�Xx!&�.�\�sT�r�G悞��ϙ��.-�ꊣ��U����	��+(�(�������
��*�0DzUc�H�J�I������VFD�M����QSX�{�b0����6tH��ڮ.�8��q&,{�;��~ -��)�P�`�,S���Wa��irhΘ�{B���`&!�jIᮾ���c-[�O�)����"�)RTd��偁�;�W��C��z�=S�~(}����L�uw�fW�c؞N;l�]
w�Ä]���;�A���ݘ,�P�=�4dg�����fV7����I���N�������h���l���֓K�Ԟjʺ^��F诇��E�_|���VX���wre�t�����c|�N��Ż�!`
�۩#a���:��I���ӱ�3���=���;t��GL����_el���&>-�C�r/c�� 
�Ҍ6�5i֛hO������l��j�T���^��2�q�m�ݨ��}9���&5�Y9�F�R_eH��TUE�	�.�0�P��2�0L\��,#��bi���t�s_k�_�n7��[)s��<���ʶ�R��DY�����4i�(ֺ�t�MW�w\�j���`!�:��!�xj-��PݶZơ�����Ū荹j 	�9�]	:=D�2����iļ,�?��&��G��j$�dwHu3��n@��f냡�)�$��t�<��@����z��"�W�z��1�@�:��`b��1��9(й�}<�������-�!9ћ�$js*�+A����D˛��K>*���&����FuD%'���3�ɾ��Py?\%�:F�{
ծ��%Vd��l[.�
g��˛RU#�#�:�
[�R5�0�)����e�q����!��L�Ko��f
��p��^<8L6h�,6ַ=xmM�Xa�m���P����������!<ԙN��ե�P��A�>ӥ_�:�n��Гn|�5حd~�E'��з7Z���*��0��'����h�;�a����M�K�d����8-9)����W�7?��#����t��׼�.|}�����#�+6���X�`p=��>�@O�MztV��9��M�
�-���??���4���e�����"��=Z�������������M�#��k�o[��V/�ɧ�
�������?YR���xb��y�	# �+�o�߻���k�s�c����S�Gi���=��1�
ޔޔ�T���z0{p�{�l��U[��	#�O�Ɏ0��_���~~�c������{�g�����k�d}� oA������� �|��)�.��0�?���׵���B������O^�?��� 3�O�Xf}� ���g��(|�#���@���X��� [� <���g���2B.�߱���!9�f��$C��FZ��@�'�K�������6@�ƻ�md�c?,r���{��@���L�_�30�)����/��߳����������` ������c$��i d������u���r��	���@��/��`	@� ��e�\�?�]����_=� RG.������?�j[������j[Y���\�?��3C���J���%����/��f��� � ���g0�������E.�L��2�cwF��f ��e�<�?�\���SB>��!Qqa�Lˡq�"�G�.�x���ʄ�Reqp��<������ a��s�����:���y��A�:8��͖�9آ�kB����*��C��"[�؀��$����^�`��\ZUT�"�J��lm���P�a�I��e�5T�ɽv-��v9,�}k����R9w ��D�,��'���Zӯ��X�?ú��r��e��I��A�a~!�~�⦲��s�<�P�3;d��	��������y�P�#;d��ׯ��`��^,�����e���X�WPq]i5Q��ea(�jŘvܕ��?�58jUFk���_M��a�������ee:E�Ɣ@Jk��ag3�ʕ�rM�U�)-k^{ [l��"q<X�dsfб��Ku.�����S����`�7#d�덳�?՟r���e���@����?@�e5�4`vȅ�#��G�@���G��_�ƭ�k�~��,Bn��b'V��ON�Uz\�ݾE���}Y�c��d�w۠��6�V��L��a�����zX��ew{�-ReݚŮ��%�� ��� ��Bwڬ�V]*k��,�Z�尶]5	�6�yv�0��:�^�4e����J��mẙ��Vs��4��ǲZ���;�\iA�:�@��o]_�2��5߹��4�t�|&����`��!�&:e�ѨE4����N�|���[v��#���JyW�x���])��R����zK�q�a�Q�ZLK��5�9�����@������>��F����|����H�����_RA*�������g��(|���0��4�*��
��CZ��������t �����_�������+��/%����>/���/[���Q��+X������K������?���`�?X������G�`�������������g�����/���߳��* ����_��//y����
=�ߜ �>�F�?��c��o*��S��!`�*H��o������9 ��Ϛ�Q���_�Ȗ�Aq��������2C��2C������?~��/X����� -$����Z��?�P�� �@��l��=����K��0�AnHf ��e�\�?���B����3�0�GF.��=�(��1<��y>��8��G^��Zu1F0�Y����������?�E�X�B�8��ęvv�4��r@��_N9 �M��Л�
o�j:��%�rJ$5��~k�����tdS��%H�6�2���^�*XgXB�ʶ��qc��Έ��z�|{�$��O�$�<�Ҋ��up�fmR������h0tEr&C�%�	��қ���i[�$��*�m��H@0Kj���0Q�&ɢ�uM�������wF.�r�� �#d��@q�,�������b�_��CJ���␩#�������� ��A�GP�������8d� ��e�\�?���!W��C��\�0��@�GP��|�ȅ�Cp��2B��o���h�r������l���ǐ���0�?��q��<���.[� �m�#`��m�@=�˴K �[�y�����e
��Ï�������K�������o����}_zG�/V_`V��R��>�.r���X��"[�؀��է� ���z����PG���ZȨ���n�Ր�q��Etq�b��jcW�ͻh����be	��W��j�'HR<\��e���@&�� -����[Q��j�w�[1�\�wMx�E�[�wqSY�9C�?�������L�f�<����C.��������˾9���?���<�?���C�������Q�n�2[�_�9bՙ�֣��j�҂��H[��s;b�6��b���Z}=�'%.F�5���N:D�:�]E��`���k��Z�n�m�QH�Ԝ���nOB����(�OE>��E��"@�O���z�>ŏ�g�\���_����/��������� �	���/#<���D��ܭ���i�6M�������bY��^��� ����y5 �c"�y@q�kk"��Ҳ�"P���š��&k�v�ÊۡU� �hh\Q�LE;�Ի+c8�r�n{{ªלE(�U��/��;q�x�S�%:�������<��^�Z�cY�]e�dL0�]ac��[/���;��D�-��W�9.v�D@A�;ΞQQQ�����I��I���t�3US݆$�~Y���{�4�2y��73���޻a�Wt9l��^�S�b,��zhIx�u�lK��O����/��w�ь�k =ѵ���/b/H$��Be�vGK����H����9�!]�����:i^�Y���b��D΢��}w�	�#�3���;�m����.`�t�����Y���_�!�'����E��0ӫ����w��b	
���/����`����ﳞ�L�Ft��<O�Tʓ���7b��b�$IÐ	��x�����<��I0�W^������P��"~e�_[cW�H�6h����e�,�Ɖ���*{�"N�i�o��?l�E-�G���{+ux����������O3ݡɫ������s4���P�'�W��,N��� ��s�m�A!��MBJEDp}�f#!�i'�4�8�Ҁ�B6b"<	"H����~u��G�_�?$�J��b�T���A���e�c��&���懤s
�>��19����{]��c�2��r�[�2���R��?NB�WE z��f��������/���?
����������S��$/����x����?�����2�/M^���Rp�QP�G0���"���Cq��U���CP���?���G$�A�I���'���d����:8*���z�0����P���6�T�|e@�A�+���Uu��(������������W��̫��?"��Q��ˏC��'�J��v�#�j�#ÐP������,&����A���<�6�ˎ�%L1wK���2g.]�AQb�XJU��Ƚ(�y�F�'Y2��.�?F+f3qϔ�Z��i�d��+��x�<[�����?yjB��6���"�Ȕ��"*�V@�=���u`���߇�|��q̽lQ��ou`'���G�W3 ��)��Z����hV$��;�Z�bQ4��9K����6��B�}�l'�� .{k���ͲX&{���<[k,Blzi���ؖ�D�]�z!3��l�e+{����J�$�V���L�*��\�S���Ծ�F|.s���xy7��2ZѳA���+�L#�����v�����4{���ܝ��t��_V��뗴E=�ϻys����$P2s��~�\����ن��8jM.F��ɺ:^F.�Go��mQ]��q�N�_�}�8
6HM~T��[AX-�G����	u���Y��@5�����_-��a_�?�FB����E��<���i�}����	?�����G?�����j�㦤��17˕�r��+����/����_�*���_��$~�Zbp��tҚb���KmY���\'MG�{�Nz���O��ϯa�\
o����2��\���Ԕ�{��,����#>�TH>�w��"���z���4 ��i蘣�{��lbxsf϶��g;I[wވ[�n:	�h�p6cL���M��!�fܷY�V�jVsǑ��H��S��}����jYK4��*�EѼ��^����)�.�v~p�$]���]��j�Y�Hz�.�YsFv���)�����2<Mŕ��Lƀ�d%ۆ�$���"0�М���ҙd���r$帙�ِ1�|eu�q�ΕM��)p�!6�Z?�gg��cl�����v��Z�/� �������p H T�����B���_�������}N$ �Q�ϐ��a�~����������r;�-H��Z��/my}~}�OVr����>��m�
v+�'5 ��0m�� ��B��� �O��L�y�ͻ� ��B��4�����U�s�N�m��E�g��9n4?/�m=<�\�aL�9-��<���n@�v����xG���̃��?����S����6dQ�� \�:^�=�X�Z/痒��XgKj:ؾ�>���+jGZ��AilB�h&c�^!�����x�0;3Ծ��B��q�����-�DQ{�hƺ���E},��V�.�T^yv��.ɃZ���+��_p���J ����Z�?��ʨ��C b������:�������_m��������$�(�C��H��>�%�����k�u��|0��?j��q�C<��0�#��p>�$�萏���`X>����( x.B�!�i��-q���`��D���o8��ݮd䳦0[�,���>$Ɖ�z��q�n%��6k��m���;������..�@�����y#L2�-���f�L{�0�H#�Y&O�����G&d�͖{8w[��'�D2��)����R��?��������%�VI��������?*����\m`���ף���:~���G�ɜ��S�kc���4��y?����3�D��?�e|�N��åuiҽ�C�vS=�-�A:��u�z���S[�6��A
w�z�N6'U���f�ߣ�M3)q����zޟ*������OA��"�����?�������C��U�A��A�� ��8�1`�"��ɇ���>����������O��#J�������K������W����ڵ$_�Ub.ǁ�[f�S���[l���h���df�F�X�
��L׊8��ƑP����vA{FdgƜ����^ئTaY�Y7c7�{N`�������˾�ӷ�O�N���ܶT�����Nʔ�t�Ӊs��~�,�#QkfY?���Hj�<q��:�tYe:�cָG{�E�F�Y Me �w
ݭ�2�g��㐚����:uO~:<���]��8�t{S�Z��N��b�oĂH��F3�䰥�t�a���?�o�@�� ����+^k�����?�A��H���������H�a�kM���Z�I������]k*���W��"����W��
�_�����?����?X�RS������O�$��Uz��/u���A�?��H�����������'��⥦�����_��u��X�R'�����a�`����/�j���C�G���a�+<�� <mAq�?���!!��A�I���?�h���
*�o�?�_� ��P���P�_i�Ǽ:�����@�B�L�!N�81A&t�B,K	��,�PA��AIƼ��\Bl��b�Ϣ����
�?��+�?���������Cb�,$G#Q>����Z�}a-��L�m���n��M����ᅞ��ZW}����c������z�٪܍{8�L��w����K�WR�>h��B������]�Vm���V���'=�	x�� ��?5|�@=Aq�?���9�����O����/��?���T����?0�	������������d�_���	��)���U<h�Ôb�$"��(ay�O��b8*�h>	�8!h2���S���������2�_���l�����<h[�1r�mS3�=�g�C��O������v�n��-��JX��T�&Gf�R	��/}̲�}���ٜ���M��29E��;��.ٻ�R�G.$�q0[��Msق��[�����Ձ@�o�@�MAq�?��� ���:�?�?��Ӡ�(@��������X�������A��� �j������_����?H����f�� ���\��W��D�I��>=�����a�#`����0��Z��`�#�@B�b��n�� ����Z�?þ�����z��� 	�y���?�����G$�t��s�����Ήt��d/�,i��Ϻ����v������[[g�{��)�{����������$$Oz�L�Ԗ�f�����҇0m���T����P�8�Q�]]ҳ��/B�_o5�M��Dڅ<�k��,S)��=�W���X>�{�B6E�4��~.ɃR�ſ�x��ǿ���_��SѠg�v!1�x�8�,Xr���d=�.�	��,J������P��=�D���,4iI��;&�¨��ت�uA>������ʚ��n�"�{�`�:����������k����A��?"�f�S�S��h�͂�G���O0�	�?����������U�_��_;����������x����#�����������H~���hz��8�MI=�cn�+���+����Lqq��SS�̓r����yaMCu����C�)��\t���������bѪ}���˄�O�#��䎢
g����t���2��OZK�ט�BZS��zxa�M#�t�Қ���x��I�����5��5̛K�-���T����!��g��,��g��g)$���"���z���4 ��i蘣�{��lbxsf϶��g;I[wވ[�n:	�h�p6cL���M��!�fܷY�V�jVsǑ��H���÷�g��{�e-�|��)�)��sQ4������`aʆ�K��8I�lgw���nV�$҃^o��m֜�F���`����z�d�DSqe} Ӆ1`1Yɶ�3Ih>��'4�k���t&�=�	G9nfz6d6_Y�s��se(zi
�a��G����Y��[�-����Z�ă�O����:���\��]�=���v�W������#�V��!�E)C��1�3!�38#a�'tȇ\�QD�T�rI�NEl�P�	;�M������H�����K�7槙������bE^���E8mV�Р��6o��m��������#mO����{��q$?�~F�v�It_���;�l+�%E�s���"!�6E*<,+�o�* �H�����y�!A�P(T�p�jC�C�|�v|6���Te|�<<9��>ݴ�_+�9�J϶
Ձ=�i���I+ٚ2S�����q��M��G������0�o�>]z���ѷ��O��������.=�����d�9��p�����^z���=]�����x_�ǵ7���AaЉ���~�4�˟]�X5Ÿ<?�Trf�����N2�f�Ce�Jhژ��w{�ƻC���F����T*7���� �ؙƵY=��y3�'壾����8��'�����VJg��yn��m�����ٮ�>Qz�B�������s8�����ti{�k{�k{�k{�k������x�gk>Az�8{�?����i��w��A~v��5�:��e��S�䦚�i�������'9����z����kk�#w "<�� D����; `�*�t岴�R��%��w J��f�}v\J�9q���W�H_%�έ~��� Q>~7����N�}X�����'��O�����k����U��읃��޺�k8��rp�L"���K컏�����[�; ��ʓ�2�VyP;(��)]npa������`�b����jo7�ձޱ��QdP��m|jf:M��=;�O+�����i�M��(����C��DʟD�śJ���R�}8N[�� ����*�7�?�5�s�Z?1"f���ˇ�ؾl����%�K����N+�|IwF��Q�������dpSn��W�w�_���h��|JG��6���|!���t.[�����^��9�Z�`�z�ެq��t��1�&m��B�G^D^�N��)v�)̰Y��2������4�ʐ���$������ Z�i��▆%1Re}���� f��A����A�1�l^���쟌R �b����� v�4�-R5GT3�$`�����6B�v�L��a����h���	�AM�3�6��`X�J�?"a�L�18q$��|F���1��� ,�a�P�;H=(�r�3Ν�:�}��؏@�g���f
g�$̠=�A69뚢9 "A��D3��t-	O�Ӯ��*N�)�!.�t�L4P��M��E��G�VH�� ��n���Z�b��	x9��l�]�9`�7ŶmQ����$0U誔�sGȫ6��jS_��K?��Na��Ħ �}�z< �43���\eP�5�'(Q͑�f�Q����T���NX�Ҁ���Hp���[1:Zp1D�;S�۷�����8�	N����	d2Ԁ�fρ��>����.t�o�#�������"$�|K,f��Ѯ�>�?k�����M�}J����Zt%8�P6]�ҹ`i(���7�Q���}���ڃ2KQ�QkE�ׇS.�>�~�Μ�|��R )��i1�J�!��b1�J�}q�裺>� 9�Q_�R����ծ��t�_jT�J�⩘���R�}6]���3�D,wԃi0�3!y�+�~�?���T�*�!�:��Z����E��чVQ59��8>��+o�_�C"�0A�}݈%�!�02r	JE�]�t��N`Fz�3��J�9$l����[���ތ�8V��h�lw���8�뚍`�s�!GİIJ��t#ً$�g�D�[�:����c���JH6y8q:�y��dIҠ�P�[	U�f�����r	�@��n#�ݹZ�D���WM�Y1��5�ӻ� ����l����t2�M� ?�O����%�k����HY �{�CK�0��Ft B=����3u <!YF�ŝR�r�<O���֘0#�q�Y������:(����E�tq�<��'��$������b���Pk�S� � �Ʀ�<�hخ��v@��q��CS�����$�g����5�����m���Z��b���L��^>G{�^2��,�TM�YVI�=Ji>��c��n~�ehO�V�I���=�-��Sva_�X���[E�w<!1�%�Ƶ��# W���>
M7��Zf]�Ic�PJ�|�-��/)��}e���p�]���k�Z�trq�<<�}��쫬�V�w��F�Zm�:��d��[Y���;���Q�������A�d�@	r;7�6��~������T�tr�iի�r�^֖��ۋ(��oIh|�@&�u܅�YE�0�Nb`��3Lؖ�����8O-�YXx���֜���'Qޓ�\��"�z�
K��/�!(���XH��V�)�/�<_���ˮa}�t?��4�5d��z��b����R�QiV�Vk��p���F�լ7������z!�kj%,א�G�2*�٪�k���pYO�V��$��[�Y9��G�N��l�/���f��z����EФ7��A*(@�B�+��JݣE�A�}���B�zu;�R�&�VK�R�ԩ����;�W�g��jY�I�yR���+��v�?UR�UMbŜ�2NV ��}p��
QN��^Ҙ��d0'�J�}�*����5�O�������g�|�o���8t�����`��\5��7�#��<vY>��rw+"�*]4�Ș3�\���勳�	4�8@��rT��#�^�b��[�O����͉c�\MW���F'����l*;���-d������+��%h�"TLj�������A�=���>U��>V#�vDp �&wi*�q��x(N3]g�:e�;Q�-7H�XR�`���df�&T����{�W��Y��Gj�]�Y���i��O���[��e����GI������v�g���]�ٮ�l���?O��#�Ǘ���T�7_ �.�l�{��=�N���jN��5n7oc]��B�0��e�����{���o��f$z�����4H_�l�0�2��dli�C��{�ێG��\�A�*s���Ĕ��O��"(���r�����_�Т=~�Iq-O���Mk����yE����׌�|�9���<kWj&�����Q��d<Q�	�v�.��䰫�B��";"gmn<h�6z�RFD���	&�>���`ӈ��F�8��uNk��������q��@i�C�$�$����H#;�B	J��I��k��t�5������(:����mc��s���i���r�9�O�����ç���GQ�$�_s��H�SF�m��5��34:6_���xi��`��5��"X#��T�����)�ͧq�'��l��1RP����/�g6�?�^�o�_�24I4�=�/E�,��gl�ϓ�O�_х�⾆]�2b ��t��i�c���:�t�:�Z�K%CqR�������p=c��;#�����aj#�2��T�x�� �q��?S�؁��V� Ti���F"-j��d\talA��ׁ�$;/Hl��$��7�&��/
Ͳ�l����ǯ���I��8h����o����$6|�{�^��Z�՛�.��Tԫ,6#�1D��f���lw�d6U�?	HȰ����w���#���aИ^G@]��(B�b�a<ői�i��v������V�L�S�`%1x��!��x7����u2��aW� K�:�?�\��끎��c1��	�\��A���P^��O�_�.�ba�j翁���T�2�F{Y�^J��\�����ooȻ���Mh��dM�)�b�V�l�p1�_�5��Ϋ�~	΃!�4L\��k���u>H�j%u��t��!#(P���I�y@� Uv����L�㗶iD��zQ�h�D��}+2ob�t�,�[s�ڈ���3ɤ�&;�uR�r����!��O�h�b'V��?Y^��Q�����o���,�¿2C5A԰D�.v��M����+�P�v�bT�#-�s	?�z��v��s[������˟+Y�K楿��s�ګ�����eo7�`�o���3�6�ǚ�1�i�]��~���ή�Ƥ��@�X�u���9[���D��+$)�ô@�����RL$`Ҁ��o�DW4�8�w↍��G��٪�U���v���Py�r�3�tvS�6��s�$�0��ncER�8�}^�}�����(X*����d�|��T
���nw���loW�˦3,���wU�T2٤BS���K(ݣ�l�pa_E0�ʣ`mk��~�|f�x�#[j�TJ�j��:��'��8�����U-���(�� �3}��Za���x��Ib.��	�i
8Ǯ�%��gK[D�ɒ�1~�ag��=h�����إd��`,3�0�뫌��X���-��:��Y9&dIUDwfE�f;"��� �x0'I�1C6�Է���m6��hh0����B���j�L��a#/�n���}�mZL�\��آ%\��V�֭������O�tz����{���h��I�����$�d�O�>u'�ie�P��7���R��W`�'��綿��i����tf�����x���������������?����&ܺ}<����`�1����	bȖ�9-$�oS� A1���0Kr*�dN��I0Ҋ��l�%�m�<�W��M�[jw/����Q����D �?���mY�ۈ�36^��wi�x��1��aʊ3��T�,ﻕ��#۸^������{�S˳�<��;��(����z�A��O����G7"�%���w]�~d��T����&U�g
X{�K���d!��?��m��=J�q�O:�����}�\@��Ϣq�
T �D�b�7qv��1�^w>Ϯ+��Ii����0e�6��b���S�����������
���(����M�E������d>��Jҩl:��_6��n��c������^����'D�<ʷ�j�>�SK(ҭw���A{`;��"d��*�,����6Sf ��4�SD��s�4ul�g�K��.������g�Yd~1�����E�w��*.�ء���p]���Ն���
��CsGsU��~�E�kZ�[����.�� Q\Ү_�4�ر��%�	|�n� �����V���x7	Z���}��*�:Ѹh�V���1E94�{��J
H��3gG���������J�;J���5�c�姌x�W^Dơ ��{h��J���{"����q�W]A���x:�9�E�厺	-X�H��5b��%"�H�	��@���(��C �<�(��<��5��1����	��G���UT]�q�H�@�_:��z��W ��fy���j7��<Ym���x�&@�=���[�B�k��>��ki�ԏ^�M�J ]��+�6�z��M�xZ;-�ڑ٠R�r8Q�|�@��k��	��I��6�;/d(C����9�"�)4
xlԋM�O�x�
"(�3H�$,Ӷq� �1w[]C�P�YƦ���qhMCF����L9��<��4^f`b�54
�qB�D�;og�R�#�k�7��*�z�1���s��3���_Z�Ǣ��|��aSQʹ8�0����?�b1�G��\3�K�W���/'
�M��I�0������R��ĺ�dW���@�Q���(_��^���/d�,"�.���l;|Iy�:��n�:���8����0�3W:��x����^�v�B)�a]�C��0�����e8���s��G�2��ơq��,0��p��ސSQ73{Do��;Z� �3k�����\��	�B��V��]�۱��e��b���t�lo���=�-إ)�.h2ӱ_�A#�oI��I�8W��q�8�͉��5iF����7�!���� ��
���h� �έR����ꉳ��Z�:>�9�����?���33�}��g�.?�nݫ�p��e��m
��^���V㸋�{xLq�&ܖWS�"�ݻ�B��[��^s�����.~��خ�\���խ+���Z\D�w_Tw�l]��ENt{y���������Aj�DR�<yo�ef��x����bc�{�:���|!�ɺڬ6ںP&+��y����N�g��M�m��i%�X��(�B��b;9�J5Zw���/Zv�c�%i6V�mx2���a��h��#/��Jg�4ۋ��⍓��3'�Sb`K��F([�s7�`�B|���,��j���������k�����]��e�q��� �!H$�}���x�m' �{|�����;�������G���K�����*��T��"*�QJ����(E�:�b(�h�aFթ�*�SR'�8Z��8����wo���h�+७y� ���2��_�x�zz@gW����['/��������;�d��r��������7�Ηʮq��Л�]�җ7�u��8QgU�����������/q��"r؅m\���E���@#���	���H�S�GF��o�K�/�1�k�o���sy��������'�����
}#�;��_;�u��?Zp�K��u��h��FD�����
i��!��z#�P�p��S)��hAQ��D)�qq�:��z�W�i���/�$�����N��'��O�]|�~�������4�7o@�~�	�����__��~�����B���Ч�����Z6����"��i��6��Zw�[��l+-�l3I%4|�.:G�]�:�lN�8��̽���:y���F����5�Q�'�D�|�u�WE���--WQ~ίHk1�f�4*��S�-�b���e�e��)bB��s:�L�]�i�$�y�ᗷ&�N�����Z��ջfK�W��8��Dvo��V�U�f�*�����sR��q�_���%�ZF�z�8���-�'�/�p��f��~~�X��jb�����M2r��TN�it$!��tF!a�JΘn#=h���_�mGT��2�3-���͑��t,����D�S�y,����3���"�V�[J�)��s�cǻ"]��D�L���v8gQY^V.:��3�9�_�Ȗ0^�%=����z���L�AԒ���a�D*�Y�ju��� ;�|�˻��ӂ�Ά��Yl�LU�u�S*j��.Ð���QC��Tz��B�b�E�P&�B���q+JO�uB�N��0%�5�RS��F��)�������f��'�ό�V)�5�L|֫�F��ҙ���ܗ�������h�n�P�+7I(��0����W�V�8}��gj�҄��q45e$$ޙd��KO�LŨ��m�&�(��$��ҝr�4��fUIѩ��(.�5��w�h�@
#���5���u'Ֆe&-�Xx3��^|G��6�sW��t�5eL2C�a>�qR�A�[�TA�f�0#DM�	LQ�gS���YAb�QJ" �냺\հ�2��2nY��	�V��E�DM�FX��"z�Lr���z|_�G��qTJb"��ƌ�(r����E�ޙW����Bw��q"���N�牝�F�𓊌�)�=G�L��y֚�;�/b�����F|:�칉�^���^[� O�\O�D��� �d?������X˟J�9�c����82e�t��d"�A��rQm��IL�Q��i��+I� �(+*X-�*W"h����&.����?O#~�Z�n�X��`PE>3�W����Y�n�D%�DZ��y��IӉ	Fe0�c�!]�q';b����e�2fx�NF��
t%M���$:��ǳ��Ak��Ṕ��f��d��(��/�e�-�1����k�	@wܟ�^8|ɳ�V�����»�k��jgl,��뫍��֮ݚ���e�e׶<X�����^x�I����G���o:p��"t�5��\r�oz�]A�y����V�{�'���J}��}����߻�9����T���T�P�e�`G'Yyd09�<��d�B4������Z��8����,zzޫNlI,��ޔ_0���,��s�\�:Z�6s�%uI���˱O3pEd�k�z仭� OE)˴���JX̱��ɰ4-E����9K�c�%�!���bm	PD+OR��d�]X�W!��jF��4ۭk�w�i�G�fy^�ƒ�!���u@E��K��.d�B,+�5#��p:�^��i��m��L{d����]hp�d0,���y�`�n��f<ĖB$i+���e�錫�
�V���9�'��I���mT�Y'W���U�vK,k�T����x=,�����W	��z���#�k"�ci-��B���.�$V�,��3�lu.��~��I�z�r}�(K�dX�]I��|4���V~~F�����/�������
rlN��
2�ʹ��lf�U8���\u�i�יe̞[&,˸M�Sj���tם���:~�������N�l����D8�6!��ȼݰGF9��'�b��9���L��I�U�2�p�S6�b_+�cL>��5'߭Q�k\$!G[Q�mwµM��LF�G�p�ig�(�KE�i�I-'K�a%G��z�;�.�0A�%��l�Cd�5H�6��� e�����xFT��%�E��8�V�9-^+i�D�#}>Y 'I�D���U5�OL�yٝ0:'c�x"��	C�I��Z3��T�$aFeV�{��\z��t⿺tNddO�̎���t��U1ȱ�PL��R"��ĩs�$='N��4��Mp�%1�,�	���Z��c=�Ba����Z��=u~-P���{�@)$��T,�)�f!ǃ�2�]��q�����,��IM*:��CrQL�*T3a���H�0��^�����xb��5�$�u
XK�s
YLW�A$�Hk�(�Y��''ᄄ��:U�!�(���O1�F�0h+m��cI\�O��(��LW*�4GO� 3Q\Cz��ka2F1�0NaZ��J��1��9\��f��ZM-S�,gf��&�F/�륿}�����W���U��I�Fo��9�c���'mt�_�W�h^�Cc�0A늇��z���5��4�=�x��D��r���r��t �=~�y����:_/o�y�^�^��c�����E��b���&^�+z�.�Jm��7���2j�N�� ���T{����}����N���	{8^|��=���s�ꦺ �g�	¡C�֓�!=�������O��j���}v�ￎ������v�k��&*�Uڸd����p���N��*$��fD��YG�<8y4�^TB/��;GJ�i��*��{T��㦷]����}������x�DZ~3f��*7��6al���v$E��X������+�Ўxd���Ⱥ��uS?�#릎(�I�����]Q�����Y7uF=�n�zd��zd=�\xd}��G���{��6��w�\[�����~����`!`���Ϩ?'���a�wa2�ˎ��������n\�������d�/J'���K H���[zR�Ȥ�A��.
l�RHg�Ǹ�"ǒ⴬��#DK�}%׍��l�;����ʸ�S�^���H*���m��Zt�A�#Ù�T�o鲠p����w�W��������M��E6�Kڸd����<e��8�;A�U/تl�;��??f?�?���G��.���74&~�{����"��A���`��[�p�6 �x�U9�T&;��J�Â�N3����N��jY������Msb�8M��S���[�.��t~8aGR1����<��dh^º���5�.�J��L��3<fjx��@�ζ�V���YTC�s��,�%dX�j�����x���~���k���BWj�j�_%0#P/������p��?7���6�z�#0A���>��ߎ'�q��?��ċ���g����02�����z�/S&�}���]����?技��w���9��h����n��2�^��������_��S�����������?��.�'����y0X����;�G���'X��	���Ue;���^�þ�'�?���_���@��?���	��}Aؾ l�ӄ��{�>[�����#��v?�?/$H��/���������s��;�~�����"����?���� ��ND "�?�����>c/�?>���$������m��- >#���o�o/�C���H���������`���?y��?��w� �R�m)ȶt�lK~��g������7���)^i`��������������{��� ��������?�����{���D���?���6ٽ�X��!���o�o�?������A���`/�_%P��z�l���>�$�&�j��T�H�42�!*F��f�R�#8��LF���5��^��=���#�Y�?��7� ��S�!�yW#�R��3���a,C(x��BIJ�P�I�K�=��"���"�V3�A�Y�Z�!fP���5]�f1��Vk$1x&�J�)�x],K9=��b1��X�A�֣ls&��2Ձ�~�xr����;�}��A�O������������a�?������e�]3����b�?���ó��E��8�ϡ�p���C�B�jò��u��eɱk��jam���R'��d�N��{yx�v���ő���1*M�H46��L"���f��T�ޞ��Nc�N�-��v�C=�fG�<�g����	�}���_U����C��^��
������;Q�۞g~�yw�-���y ADE����EAQ��1�Ύ~;�ޝ����Sb�E0�欚k�� �_P��_P��?��
��X ���x��8�8�n��'�����ZN���IoP'*�g��u������/���D]�jc�I���Fj㷛m���6��T��t�@�B�;�N�i�� �?i��aI�5�8(�|P�J)M�si�(I�1��v�Fvk/�$ᐋ���6���`4澮mm����[��z+��FW'OZ�����بjn�?�)�#Ms�������݊��"�v��m�����5�k�G��|�E�Uՙ�2���̶�5øfP���"����q��Gj�<j��HΌ
eU�S)M�zy]�;�ڲǗ[}�7�GQ�[�I�V�Ԏ��k���l����>~��Ip��$�Fx����X����<����������?
���8�:<�\�������<���0��?���B��x���a���<���_[����,s��򿘀��a�a ����/��X �_��B����A�}��s������H����3�Ü�@�����p���X �`���� A�1��*
���??�?��q�?��y������������?`���^��ÚP<�������~��+ ��@���,�|q ����p�W
��)������?7���@�CYH!������������ ����(�������	��tCmHq �����/@�_Q ��<�>D���������q�=������W�?����Q�fjo�6�~݉{�����5���?����=�sV�e��^�T���z��[�|H�U�p���u�ӆl�((�Ҧ^w�V׶��aWs_�aZ��찑��������2T�5N�[�J7�+����������Z�O5 �\�;�>h,KS�HT��ԃ��'���uj���)[�VS�v��KRe�]�^�Bf&�d��Ay��l�bɏ�����t�e���A��c���,(\�As�B��k�?"��0��_X@�CsH� ��?��΀�������#������!�����������$����A������ ���#��� B�1��.��ExJ��.�_��m�G�s̃���?�����K�(Q�����H�}����X���P`��FEB��*��ND����z��� ��9���C�?����տآ�m��o���Pm�6����ڼr�ܬT�?΍�f�9���nܓ�RwƯe�9'ҙ����8���;�t8��Ѣ�2�4�����ީt��r���d��];ɹ��ǋ�2��O��C�9&u�,��������h�ɠV�C#�v����Omz�f��~��E}�		�?��,����}	�?���@�C���P8��~�_X���� �����_����~9�Ϋ~۬k�	M���s�Yw�fVuXwTN�|����'v+'a���l�$:�h����\əfc PIv�}aHs}ɯ������{��K�a�2��_KL��^n��ʗi4<�y�ߏ������� ���@����
v��=@D��
�A��A�����+r�4`1 A�	�� ���W�W���4H���Ў�l��2oK��bݿ��{��+���� �^
^��q�GKC̶���LJJ�(O��i�G~��Vþ�0��P�2�ǲ��D�;���+�U/)^tP�$iݯ1��l[�r^���<��4��5�Y�iO��j�#Ms���_�SSu���ە���GE!Sa/9��,�����aU��nE.K��(�{]�s�~��V���wy�,���2�	�#���k��z�z38@c�L��t��I̠"���z���u�SO�x|r�^�ɭ�uh6)�"�E(Ys*���h����o�Ʊ;�F|��F
��	���� ����翜�Hp��$�F���i������Ӌ`���������DQ��0����/���_@�}��/ 1��P�e��"�e�'��x�H��0�}1HF2}�Jp��X�2��FV8(��D�������������_�&��	���j�v�:*�(\6JG���h=o���JP�=����l���ge��~$��̣�꿰�����;y������E��?����pW�+�,�?��ɿv�`8�K�|�'GJ��<̋��<K�b�)�$_��}�A!0�����Q���X�+��.ƑZg{�=�>M��n���[4߇��/�+��ӱ>������2�3q�kZ�ߏ����f��� �Y�a���������a������/�����_�����-�?���{	�����f3+����ϱW����A��c�;�����������C�~����q����t��$�?K�����p��m��q(�������]����	��uLї�K���p���_�� ��m�wї�K���p�����1� ��_o�1��.����������!�����y�����������T��R��+�PH�^��o�9s�l�iNUna)���}�l���/�f�*��p�j��C��Q�ؚ{ˊm�c�{����@���3����ւ�7Om���k�+�Q��y	Q��*��<F�5�[3��ɁQ����r`���?������ǻ��zER��)����o�E>�I-\�G�./i�:7�'m5in��f95�B����$m0�̙Z��,�e���V�tj��OM�ժs�2���O�<Q�"'��t��Oٯ�5ڥ��T���U�)�U�\[��V�~���z�'{�zmyV�[��7�؍M�-�Rj�563�=u��+j\���5ܜ���"�&[�m�P�\~dG���i7//�y����uT�p.͚��+�	_I'�>:7���b��e�	":�^�Q͵�_쵎�bװ��gPnd���[��aD�G����,^�@A �����{o���������� �������_��_X��7��?x5��ٷ�}�t��5�J���X�w�_��W��=u�R�e��i|�{�T���5]E���=�u�Ts���ym8v/ȝ���=�n�,vp}l����5�k�u/�g�2����W[��ѷm�<\Lv���x�BS�T}�Җ��{�q�\�\�=��i$g85s!�)5���Zm�\�Ҳ�E#�PU4��f�-��q��ӕ�Ԟ�;�7Nf�7潞ִUޤ�ʵn�������ǫ:WU�:���<+wv��Z�j7F{I�4��u�����&�nX���ѕ�h�غP�������z**�c�6���V���Tň�~o�2:+�@)O�㒤[B�]���*�rl�]�!nVN�4�T7F�+�iߥ�}��F��T��0q�����v���̃�o�����Ss � (�����#����������[�� ����>8���oX�������ҷ��0�1E���q���SY�����B����=�6Q��!�������F?��������4p��������p�z	�ѹ-��tǔ�{�Ҙq�l&�=/������Q5v1�'l��ú:�R�l`�|�C���/'J{�c�M�oP$���9 �%��4ިQ��*<�(�3��y�b�%_k!u~Ι@�Xb�M��]��o9��Z;�J���FUCf����R����z4���I಺������zЗNm����j�g�7�Z��MM�HG�"�*��,��?e����0����K��������������,��  n������8��?�����om����̃�'����f�]� ��������޼��������a.bЧCI�#:�d��#Y	����@�Y.�A�'�8�#KH�	!� ������4��?���o4m�ͦ�����l�Ը���.3s�\�U=Ν��f����:�C%u=�����\E�t���rS�Ø����v��P]��ׯ��,�Lko���ZlȢ@-�����k=:\��=������ a����š��?[¡o� a��W����Q������b��_$�?����+�_;�l�X�Z��ZZ7*+5��R��'�y��*�>f'51������E��w�ι̷J=v��Z��r���pJS�>AV�c�ږ��^�w�<%GSݶ���nqlRs�kX{}���������Q������[X��W����� �_P�U��꿠��`��_��?�� �����h�����=��z��o~�Z}��*��N\w�n:?�Z��p�WM���i���ӵ�66��_<ցԏ��璦�[$��\�e+���(�c����D����UK'A��80f3�t'���7��\=�3eq��f�XL�3�i�����&��� ~����O��r���^U�m��^�i�Q�.�:Wm��b���Z9�ۡc�����9��C���-Y��a��R���}�@�چ[�j�����nOO,��>7�'V�ʇ>�:6�㨻�+%��7ԙfu��Y+M���I�Xf�����8��R��r�r�Ni��ߟ[+@��c�����>���$�����~��� ��D��������?�w%����E�?�p��.x����\���������
�_a�+�-���w�O8��<�F��
��_[����,�@�� `��B�������� ������?�������<�#^H�����H����;�È�@��4����?X �_`����-��	�������p���� ��'8������C��1��g�������?�\����������������?��������,��Q�/
��}��ii�&����(�J(Ѳ(��'4�H��{�ޝ�����SԤ{��9Q|e&w��~GˣD��͙��>U��&���6���������W{�
�Rsy�daJ�H0��߇�)���������������è!{�{q�K�Q�"ҺL��,�*�}fR��3��z��Zi}���.�7Mh�;�{fZ�L�4"��rny�	sNs��>��I	�Vc>X�3$�cn$�3m�\���|u`�yfT������?��Na�O���x�?}<�>�%��C��������C���Tj�����߃С�?��w�t(�����&��������x��q���s�?��B�������8�d�gsj
a�"UyL��JJ>�K)0�#scZ��YZ�29(�*DF���K C�������?C�����7���e��^��8�w�w�rm�D-�5��Ё�U)l��܆�d-y��ٙg�By�L�=RU����Y�z�45K�KK�Õ2�+v�z8��~۞e�O�y���t��,�F!����Na����ǣ���%���t�����?������S�����c�?
��_�Y�?��M1���|�����r :2���<2������?�g�'���N ��/C�b�������~����@tB��z:�������������������9�1���A��?G��oC�b��׶�N�C������ǃ�I���Lq����}�@I�� z��]��ˏ�?�+���.;�P�J�Л��������{����h[�?��5�e��xͿo6˽E�\��J�8�y����n�=;%���.Y��3�h����ʹ�TEN���/�̻� 3fCΖ��)��L�^���'v�{��X?���|�e�J��O9�����?��n|1l��	[at�|O:��.�׳e��dVfm�Ns�dI$Kd���FwEg|o�O2�ϡ�G����sG��z��[�Z^����?`:	�/�}n�����N����8��{�ף������������o��ǃ�i�|Jԡ���}�?QL�����������b�?���d�m}�ؽ��Q������I����N�Y��c��pt
���<zu��������ֽ�ٯ���$WZ[7Y�fF��+�B����Ч���~����v�Dk]~V��%c��sO�����n����\�P�E���C*�*uٛ0��J���^�F7��|�9�Nz*S�\`�0O�+P�	Q����'J��U��T�j]�ltEj�ӦA�I#SNƱ��e�X�V(�1L���֠�J�4�?J���Ȓ"˕�\eŵR�٪ӭ���2[�ч��4�f
b��^se�:��F�7J�R�Ԏ��k�Qv���z'+:5��Όa]��ʴ��5�)؇/�k�xl�Z���z�Ʊ��NY��;��/��Y���"7�G���D.O���̯���TD�ѰI�����u��H�Wc��f���YRckB�[<�TZ��;�;�LN�ϧ����gbv�A��痼��D���d�y�z�ZEKXH����Y�C��k�D�k��g�j��f��L'a������� t���ײa���b��׶�N��'������S�u,���8�R2�Rӹ����d:��!	9'g%�(t��2Y��e�������LB2�F���)�����c��0����;��Qe��9��,&�±��Ҿϯs6N/��X���������Ԏ�dړ�,L�~z�*�5��R��D'Ց=�Y5[KŴ&s��e��4G�B�Wm��5�Ty���Z����J��r|��[�������ё�׈}�J�0������$�?>��ht���@n�;��S����;�����[B׫�Ks�e������gz��-(�t4�*�t,o��	U:����L�Y��v2��E��$���	1�;���C�4��9t}iz�������;�vs?�;Js�X��$��(�o�Ә��8�{$:��_����ط�t
�����G���x�W��+���b����<�����>���tl��^��F����2���75�-���M��*�]X����N����=�n��/�m�@����� ��?��ضg��@��R�ʔ�k�x��{ ��rl1�^�M�W]���[&5#g#{L4ϋI�r�բ9�t
��P�Z�ݯf+7���g��kI.���Ϗ��ֲ���kΧ�H�	m��c���	�����<���9��!��4��!�`�o�0Р$��Դ&���}� �R��}��9���\��AwN��U���'�Z�w�M�݈����x��	3<�i��5�ŋB�BVloQL�T��^�·�J���� VM�ʌ����6���Ma>	;V����k�s�Vf�]m��WO%�Y��r7fO���?����47^-���dj��4Cfc�?}��Xۺ6q���Е�H �0@�9��P�'��47U]��/D��>֡}	؅�L�� Q>����q;k�*�S�9� Ǻ�c�Xc`m `.����J���B睫�U�K��e��E| �P���r� 
�\��K�e���]6�x�Y@%������a�`l� C�]а����jT�2��;�l9�tN$;�/ț��Y����!"���Gɯ��P��?J�S�������LT�9V�Nt8P	ĵ 4%ـ("=]���HE�Eh����	֖gG�ڳ�J PCy��0���`ޗpQN]��Or��6�">A���dɶ�5.'�z���[@s�c����J(��[ M��ۧ'��6��t�_Awh?����	)n�zb����2C��� C2�u�T��5	�cZ��ub�y`�K�Y���ǭq�K��������r�ǾKg���4�۷�
%�۷��2�':�cKvQ^T>�ۥdx��cۚ��m~`�FK}�R���߁��%4։�-�}:�c�Bi�<c�Pʳp��VS�G奲8wz;7ʸ\硨Yr�P[�:�-H2ʳ�J�d��~�q�����d�Y�L��*� H
��ܲa%�DB]�.�Z����<l�I����'=�@⹖�5C�gx:�w�,|����[��^�6b7�<4�������2�Q��|	��{p�.�*uS�+𥃯�F�f>���G���ɵ=��cU��㯉�[H��kT��cL�s��p� PQ�AZ��bӎ��!�-w� �	8��%�+C�[����x��#�]	������~A��0t�� ���`����K�ݸ�/A�!�Qe�5m��o��Oӷo(G$&�N=<�}�.E}�ݑP<�IQ�=ܢ�XR�@�n��G�|P���>�W����'��Z��j�]�-b���O2)���d���?��� �mBQp�*�'�C �ɲ]Pd�������m�햯>7"��0���m�ud���D�f	��Bpay��s9�Rf � _Zx?!����O$ӄƆ�e��]m3U�D$�`�[,���(����#�뿊��hx�X���_:��C᷄�,^��t6��!�8��.�o�o�E@W`0��9�=�Z����I}�^@ۀ���"E��̶�2���d��R�-;��q�x���FM�JBWI�e��;B�/��:�X�,��{O�H|Q�����R狧�}���0��r$�R�1��Ȕ$��l��R��tz�Ɍ�Sjv��$J���yJ���8��&%*#�:3"�0��[���,�f.�� �ad�^g�@���>�]�g)��@�[�c�C�3��1���$gҒ,�$�#����(�(���$)�a�0K�29HK����hԓ�<d�0%e$�:\� 8n�2������[�K���p��?�ҭH�˷�&��о��}R�2F������=_��艷�m�]�H�KB]h���j�T�B�J�����M�t�:[(��N�L�����;5�[n�����u�zm,��,��ų�Z�)�"�]��� ��Wnu0�0�-{�|�[U�/A�Z�I�ZH�$��JRCN�'��|�v��ڊ�?Qt��$�sr�`���\L7ݵ�mW��5�-%ؖ�(���#�������P��_�/���"�����;�hX�KbY���~"��}�̊u�Qx��DA�z�ݬ�ڭP/4b�{���2�L�8Kr)�I�3#�*�l�g�$.�I�w��w�m/�&��Գ�|=Znt�|�^K�u�;h�+5Ժ���n;�����֛�L(5���$W�AYA(�г�.�¿��rlG�Bn�2)p���7z|��Em��6���U�2��1猪�6�(N��z��y5���©�AB4N�_R�!�ܕ�?���p���r���O��c쇕�V�]�h��-�r��ߋD��F:���Q���͆�S�y2�X��p��^���p]ԝI4�I������-�����o��\(٪���f�@���L�R��?*E�4�J�������;}�����IYr&��a���L0�m�ж-�w��u��al��Ix��.�3�B�(��lH`Y���D�/����K�$�nųm��� ��u������/@Q��	�<�����m��k������v�����,|��l;�B��.裦>�s8k�E���>(�T췳�0�t��`7�.��y��p�U�M�qq}m8���F��xvp!��F^����L<�'H���i�p�`�4Ⱋنj�X�$��Ux0�(xj
+�~� ���:��e�&��Wpq�3Z���R�AӜJ�/B������Z���~L���O3���,B���Si����t��� Xʞ�9��0� ��&��fNx�}Op`�9aX|s�?X\���<����?2����"�2^�����߃�����wU��*�V&P��:)�p \��Q@�d��$)���`�j����$���`n��1o_\l�/���(&�o ._>S��J�e� �-��������:��ۻ�޴� ���b����b�L�V�z�}i+E�K�cꆫ"E��ޙ��6��5��ޝ�]�3��N�+�pU��4�N/gIr۠�w[��<ci��%�P;,���Ć�o��S���M�f�a>,��%'w㘖�����L��0���[ej_>�7�,(��.c�J"�^T83ғI�BX�P��ZA#e?.�PxD��B�\\��w��)�-'s��邴�,fS��"%=#�1Hmbd�\\b�s1M-�O鲬A���l;J�Q)(�����nzeeD!���H�v ��F�V�x���t£����t��
�K�e�~�ܲ.��Ԟ���oM̜_k��G���M�7/���ekO�l��;�㈍��L��9tr�d��}_��旝����~����N�<'=5��~��sOyn�B'�|'
ݠ��n7{�ﷻt�E�z���"��U�,Tn��q��4����g�a����r��k�w{��,75����]�U.�� q�h��F7��M�A�kI�u��¾o��<gK�鲥Y<�E$w�Bcbc�j3����y�-�)�%��@���vh5�b�392w�/�8����uk2�;�߹������h�t�RA�����~+<&�u����v�+��o�D��?�#�A.C3@O�1_�3�kT�lg�T�+@j��v"E�U�$7�ةՌ^��+Q��V����n�U�D���n�G��cD}O�T崩~"�O�pI��,n�gL�(3�X�3�mP�er~��1Q����I��`0��`0��`0��� �5� 0 