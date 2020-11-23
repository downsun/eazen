#!/bin/bash

sudo apt update
sudo apt install net-tools jq -y
sudo apt install -y software-properties-common
wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | sudo apt-key add -
sudo add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/
sudo apt update
sudo apt install adoptopenjdk-8-hotspot -y
sudo apt install maven -y
java -version
mvn --version
echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add
sudo apt update
sudo apt install sbt
echo "Cloning Sidechains-SDK from the Horizen GitHub"
git clone https://github.com/ZencashOfficial/Sidechains-SDK.git
cd Sidechains-SDK/
export JAVA_HOME=/usr/lib/jvm/adoptopenjdk-8-hotspot-amd64/
mvn clean install
if [[ "$?" -ne 0 ]] ; then
  echo 'error'; exit $rc
fi

BOOTSTRAP='java -jar tools/sctool/target/sidechains-sdk-scbootstrappingtools-*.jar'
SEED1=`openssl rand -base64 32` && echo SEED1 = $SEED1 >  keys.txt
SEED2=`openssl rand -base64 32` && echo SEED2 = $SEED2 >> keys.txt
SEED3=`openssl rand -base64 32` && echo SEED3 = $SEED3 >> keys.txt
SEED4=`openssl rand -base64 32` && echo SEED4 = $SEED4 >> keys.txt

GK1=`$BOOTSTRAP generatekey '{"seed": "'"$SEED1"'"}'`
GKSECRET=`echo $GK1 | jq -r .secret` && echo GKSECRET = $GKSECRET >>keys.txt
GKPUBLIC=`echo $GK1 | jq -r .publicKey` && echo GKPUBLIC = $GKPUBLIC >> keys.txt

GVK=`$BOOTSTRAP generateVrfKey '{"seed": "'"$SEED2"'"}'`
GVKSECRET=`echo $GVK | jq -r .vrfSecret` && echo GVKSECRET = $GVKSECRET >>keys.txt
GVKPUBLIC=`echo $GVK | jq -r .vrfPublicKey` && echo GVKPUBLIC = $GVKPUBLIC >>keys.txt

GPI=`$BOOTSTRAP generateProofInfo '{"seed": "'"$SEED3"'","'"keyCount"'":7,"threshold":5}'`
GPIGENSYS=`echo $GPI | jq -r .genSysConstant` && echo GPIGENSYS = $GPIGENSYS >> keys.txt
GPIVK=`echo $GPI | jq -r .verificationKey` && echo GPIVK = $GPIVK >> keys.txt
GPISCHSEC1=`echo $GPI | jq -r .schnorrKeys[0].schnorrSecret` && echo GPISCHSEC1 = $GPISCHSEC1 >> keys.txt
GPISCHPUB1=`echo $GPI | jq -r .schnorrKeys[0].schnorrPublicKey` && echo GPISCHPUB1 = $GPISCHPUB1 >> keys.txt
GPISCHSEC2=`echo $GPI | jq -r .schnorrKeys[1].schnorrSecret` && echo GPISCHSEC2 = $GPISCHSEC2 >> keys.txt
GPISCHPUB2=`echo $GPI | jq -r .schnorrKeys[1].schnorrPublicKey` && echo GPISCHPUB2 = $GPISCHPUB2 >> keys.txt
GPISCHSEC3=`echo $GPI | jq -r .schnorrKeys[2].schnorrSecret` && echo GPISCHSEC3 = $GPISCHSEC3 >> keys.txt
GPISCHPUB3=`echo $GPI | jq -r .schnorrKeys[2].schnorrPublicKey` && echo GPISCHPUB3 = $GPISCHPUB3 >> keys.txt
GPISCHSEC4=`echo $GPI | jq -r .schnorrKeys[3].schnorrSecret` && echo GPISCHSEC4 = $GPISCHSEC4 >> keys.txt
GPISCHPUB4=`echo $GPI | jq -r .schnorrKeys[3].schnorrPublicKey` && echo GPISCHPUB4 = $GPISCHPUB4 >> keys.txt
GPISCHSEC5=`echo $GPI | jq -r .schnorrKeys[4].schnorrSecret` && echo GPISCHSEC5 = $GPISCHSEC5 >> keys.txt
GPISCHPUB5=`echo $GPI | jq -r .schnorrKeys[4].schnorrPublicKey` && echo GPISCHPUB5 = $GPISCHPUB5 >> keys.txt
GPISCHSEC6=`echo $GPI | jq -r .schnorrKeys[5].schnorrSecret` && echo GPISCHSEC6 = $GPISCHSEC6 >> keys.txt
GPISCHPUB6=`echo $GPI | jq -r .schnorrKeys[5].schnorrPublicKey` && echo GPISCHPUB6 = $GPISCHPUB6 >> keys.txt
GPISCHSEC7=`echo $GPI | jq -r .schnorrKeys[6].schnorrSecret` && echo GPISCHSEC7 = $GPISCHSEC7 >> keys.txt
GPISCHPUB7=`echo $GPI | jq -r .schnorrKeys[6].schnorrPublicKey` && echo GPISCHPUB7 = $GPISCHPUB7 >> keys.txt

echo "daemon=1" >> ~/.zen/zen.conf
echo "txindex=1" >> ~/.zen/zen.conf
sed -i -e "s/testnet=1/testnet=0/" ~/.zen/zen.conf
sed -i -e "s/#regtest=0/regtest=1/" ~/.zen/zen.conf
sudo ln -s /opt/zend_oo/src/zen-cli /usr/local/bin/zen-cli

zend -websocket
sleep 10
zen-cli generate 220
sleep 15

CREATE=`zen-cli sc_create 10 "$GKPUBLIC" 100 "$GPIVK" "$GVKPUBLIC" "$GPIGENSYS"` && echo CREATE = $CREATE > id.json
sleep 10
TXID=`echo $CREATE | jq -r .txid`
SCID=`echo $CREATE | jq -r .scid`

GENERATE1=`zen-cli generate 1`
sleep 10
GENERATE=`echo $GENERATE1 | jq -r .[0]`
sleep 2

zen-cli getblock "$GENERATE"
sleep 5
zen-cli gettransaction "$TXID" | grep confirmations
sleep 10

SCGENESISINFO=`zen-cli getscgenesisinfo "$SCID"`
sleep 3

GENESIS=`$BOOTSTRAP genesisinfo {\"info\": \"$SCGENESISINFO\", \"secret\": \"$GKSECRET\", \"vrfSecret\": \"$GVKSECRET\"}`
sleep 10

BLOCKHEX=`echo $GENESIS |jq -r .scGenesisBlockHex`
POWDATA=`echo $GENESIS |jq -r .powData`
MCBH=`echo $GENESIS |jq -r .mcBlockHeight`
MCNT=`echo $GENESIS |jq -r .mcNetwork`
EPOCH=`echo $GENESIS | jq -r .withdrawalEpochLength`

cp examples/simpleapp/src/main/resources/settings_basic.conf examples/simpleapp/src/main/resources/my-sidechain.conf

sed -i -e "s/signersPublicKeys =/signersPublicKeys = [\"$GPISCHPUB1\",\r\n\"$GPISCHPUB2\",\r\n\"$GPISCHPUB3\",\r\n\"$GPISCHPUB4\",\r\n\"$GPISCHPUB5\",\r\n\"$GPISCHPUB6\",\r\n\"$GPISCHPUB7\"\r\n]\r\n/" examples/simpleapp/src/main/resources/my-sidechain.conf
sed -i -e "s/signersSecrets =/signersSecrets = [\"$GPISCHSEC1\",\r\n\"$GPISCHSEC2\",\r\n\"$GPISCHSEC3\",\r\n\"$GPISCHSEC4\",\r\n\"$GPISCHSEC5\",\r\n\"$GPISCHSEC6\",\r\n\"$GPISCHSEC7\"\r\n]\r\n/" examples/simpleapp/src/main/resources/my-sidechain.conf
sed -i -e "s/signersThreshold =/signersThreshold = 5\r\n/" examples/simpleapp/src/main/resources/my-sidechain.conf
sed -i -e "s/zencliCommandLine = \"\"/zencliCommandLine = \"zen-cli\"/" examples/simpleapp/src/main/resources/my-sidechain.conf
sed -i -e "s/verificationKeyFilePath = \"..\/..\/sdk\/src\/test\/resources\/sample_vk_7_keys_with_threshold_5\"/verificationKeyFilePath = \"sdk\/src\/test\/resources\/sample_vk_7_keys_with_threshold_5\"/" examples/simpleapp/src/main/resources/my-sidechain.conf
sed -i -e "s/provingKeyFilePath = \"..\/..\/sdk\/src\/test\/resources\/sample_proving_key_7_keys_with_threshold_5\"/provingKeyFilePath = \"sdk\/src\/test\/resources\/sample_proving_key_7_keys_with_threshold_5\"/" examples/simpleapp/src/main/resources/my-sidechain.conf
sed -i -e "s/genesisSecrets =/genesisSecrets =[\"$GKSECRET\",\r\n\"$GVKSECRET\"\r\n]\r\n/" examples/simpleapp/src/main/resources/my-sidechain.conf
sed -i "$ d" examples/simpleapp/src/main/resources/my-sidechain.conf
sed -i -e "s/submitterIsEnabled =/submitterIsEnabled = true\r\n/" examples/simpleapp/src/main/resources/my-sidechain.conf
echo "genesis {" >> examples/simpleapp/src/main/resources/my-sidechain.conf
echo "scGenesisBlockHex = \"$BLOCKHEX\"" >> examples/simpleapp/src/main/resources/my-sidechain.conf
echo "scId = \"$SCID\"">> examples/simpleapp/src/main/resources/my-sidechain.conf
echo "powData = \"$POWDATA\"" >> examples/simpleapp/src/main/resources/my-sidechain.conf
echo "mcBlockHeight = $MCBH">> examples/simpleapp/src/main/resources/my-sidechain.conf
echo "mcNetwork = $MCNT" >> examples/simpleapp/src/main/resources/my-sidechain.conf
echo "withdrawalEpochLength = $EPOCH" >> examples/simpleapp/src/main/resources/my-sidechain.conf
echo "}" >> examples/simpleapp/src/main/resources/my-sidechain.conf
echo "}" >> examples/simpleapp/src/main/resources/my-sidechain.conf
sed -i -e "s/seed1/$SEED4/" examples/simpleapp/src/main/resources/my-sidechain.conf
SSS=$(ls examples/simpleapp/target/sidechains-sdk-simpleapp-*.jar)

java -cp ./$SSS:./examples/simpleapp/target/lib/* com.horizen.examples.SimpleApp ./examples/simpleapp/src/main/resources/my-sidechain.conf &


