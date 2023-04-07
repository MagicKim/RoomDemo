#!/bin/bash

full=false
curDir=$(pwd)
srcFolder=""
desFolder=""
ROOTFOLDER="IDCU"
mpu=false
mcu=false
mpuSeq=0
mcuSeq=0
baseVersion=""
newVersion=""

pkgFile=""
idcu_crypto_pri_key=""
idcu_crypto_pub_key=""
idcu_sign_pri_key=""
idcu_sign_pub_key=""
head_signature=""

#HEAD INFO
fileSize=0
UPDATEFULL=1
UPDATEDELTA=2
PARTITIONINFOPOSITION=1024
MANIFESTPOSITION=10240
MANIFESTTOTALPOSITION=2096128
PUBLICKEYPOSITION=2097152
PRIVATEKEYPOSITION=3145728
SIGNATUREPOSITION=4194304
HEADER_SIZE=5242880
MAGIC="ROX_IDCU"
MAGIC_SIZE=16
pkgName=IDCU.zip
PKGNAME_SIZE=64
buildTime=""
BUILDTIME_SIZE=32
VERSION_SIZE=32
updateType=
UPDATETYPE_SIZE=4
allowDegrade=0
ALLOWDEGRADE_SIZE=4
updateobjects=0
UPDATEOBJECTS_SIZE=4
isSignature=0
isCheckManifest=0
ISSIGNATURE_SIZE=4
PRILICKEY_SIZE=256
PUBLICKEY_SIZE=256

# delta algorithm info
BSDIFF="bsdiff"
REPLACE="replace" # copy new file into payload
MOVE="move" # Don't need copy data into payload, copy old file into new device node
ZERO="zero" # Don't need copy data into payload, write 0 into new device node
BSPATCH="bspatch"
ZERO_4M_HASH256="bb9f8df61474d25e71fa00722318cd387396ca1736605e1248821cc0de3d3af8"
ZERO_8M_HASH256="2daeb1f36095b44b318410b3f4e8b5d989dcc7bb023d1426c492dab0a3053e74"
ZERO_16M_HASH256="080acf35a507ac9849cfcba47dc2ad83e01b75663a516279c8b9d243b719643e"
ZERO_32M_HASH256="83ee47245398adee79bd9c0a8bc57b821e92aba10f5f9ade8a5d1fae4d8c4302"
ZERO_64M_HASH256="3b6a07d0d404fab4e23b6d34bc6696a6a312dd92821332385e5af7c01c421351"
ZERO_128M_HASH256="254bcc3fc4f27172636df4bf32de9f107f620d559b20d760197e452b97453917"
ZERO_256M_HASH256="a6d72ac7690f53be6ae46ba88506bd97302a093f7108472bd9efc3cefda06484"
#CHUNKSIZE=8388608 #8M
#CHUNKSIZE=16777216  #16M
#CHUNKSIZE=33554432  #32M
#CHUNKSIZE=67108864  #64M
#CHUNKSIZE=134217728  #128M
CHUNKSIZE=268435456  #256M
ZERO_HASH256=$ZERO_256M_HASH256
PAYLOADBIN=./payload.bin
payloadPath=""

#partition info
PARTITIONTOTALSIZE=16
partitionTotal=0
PARTITIONNAMESIZE=32
PARTITIONINDEXFILESIZE=16
#manifest info
MANIFESTLENGTHSIZE=8
manifestlength=0
PARTITIONCOUNTSIZE=4
partitionCount=0
TOTALCHUNKSIZE=4
totalChunk=0
PARTITIONINFOSIZE=48
CHUNKINFOSIZE=256
PARTITIONIDSIZE=8
partitionId=0
FSTYPESIZE=8
fstype=""
IMAGECHUNKCOUNTSIZE=8
imageChunkCount=0
CHUNKINDEXSIZE=8
chunkIndex=0
DIFFALGORITHMSIZE=16
diffAlgorithm=""
PATCHOFFSETSIZE=16
patchOffset=0
PATCHFILESIZESIZE=16
patchFileSize=0
oldFileChunkPos=0
totalpatchsize=0
checkAllChunkIndex=0

HASHSIZE=64
baseHash=""
newHash=""

metasize=0
METADATA_SIZE=8
signature_size=128
METADATASIGN_SIZE=8
signature=""
SIGNATURE_SIZE=128

#####################package header####################
####################MetaData: 0~2M#####################
#  |                        16                         |
#  |                       MAGIC                       |
#  |                        64                         |
#  |                    PACAKGENAME                    |
#  |                        32                         |
#  |                    BUILDTIME                      |
#  |                        32                         |
#  |                   BASEVERSION                     |
#  |                        32                         |
#  |                    NEWVERSION                     |
#  |      4     |      4     |      4      |     4     |
#  | UDPATETYPE |ALLOWDEGRADE|UPDATEOBJECTS|ISSIGNATURE|
###################PartitionInfo Delta##################
#1k|                        16                         |
#  |                  PARTITIONTOTAL                   |
#  |                        32                         |
#  |                  PARTITIONNAME 1                  |
#  |           16           |             16           |
#  |     partitionBaseSize  |    PartitionNewSize      |
#  |                        64                         |
#  |            PARTITION 1 RAW OLD HASH               |
#  |                        64                         |
#  |            PARTITION 1 RAW NEW HASH               |
#  |                      ......                       |
#  |                        32                         |
#  |                  PARTITIONNAME N                  |
#  |           16           |             16           |
#  |     partitionBaseSize  |    PartitionNewSize      |
#  |                        64                         |
#  |               PARTITION N OLD HASH                |
#  |                        64                         |
#  |               PARTITION N NEW HASH                |
#  |                      ......                       |
#####################MANIFEST Delta####################
#10K|           32          |       8      |     8     |
#  |     PARTITIONNAME      | PartitionId  |    FSTYPE |
#  |      8      |     8    |          16              |
#  | image Chunk |  Chunk N |     DIFF ALGORITHM       |
#  |            16          |          16              |
#  |       Patch Offset     |       Patch Size         |
#  |                        64                         |
#  |                     BASE HASH                     |
#  |                        64                         |
#  |                     NEW HASH                      |
#  |                        64                         |
#  |                    PATCH HASH                     |
#  |                    ...........                    |
#  |      8      |     8    |          16              |
#  | image Chunk |  Chunk N |     DIFF ALGORITHM       |
#  |            16          |          16              |
#  |       Patch Offset     |       Patch Size         |
#  |                        64                         |
#  |                     BASE HASH                     |
#  |                        64                         |
#  |                     NEW HASH                      |
#  |                        64                         |
#  |                    PATCH HASH                     |
#  |                    ...........                    |
#  |           32           |       8      |     8     |
#  |     PARTITIONNAME      | PartitionId  |    FSTYPE |
#  |                    ...........                    |
#2047K
#  |           8            |      4       |      4    |
#  |      MANIFEST SIZE     |  PARTITIONS  |   Chunks  |
########################Security#######################
#2M|                       xxx                         |
#  |                    PUBLIC KEY                     |
#3M|                       xxx                         |
#  |                    PRIVATE KEY                    |
#4M|     8     |      8     |            16            |
#  |   MDSIZE  |MD SIGN SIZE|        RESERVERD         |
#  |                       128                         |
#  |                METADATA SIGNATURE                 |
####################package header#####################


usage() {
    cat <<- EOF

    package MPU/MCU into update.zip

    Usage:
        For full:
            ./build_package.sh -s ~/Documents/IDCU/full/input -d ~/Documents/IDCU/full/output -f --sign -p 1 -c 2 -n 0504
        For delta:
            ./build_package.sh -s ~/Documents/IDCU/delta/input -d ~/Documents/IDCU/delta/output -o R11_DDD1_221223_0504_ota_mpu_mcu.zip -w R11_DDE1_221228_0543_ota_mpu_mcu.zip --sign -p 1 -c 2

    folder arch(full):
        └── full
            ├── input
            │   ├── MCU
            │   │   ├── mcuupgrade.bin
            │   │   └── mcuupgrade.md5
            │   └── MPU
            │       ├── abl_fastboot.elf
            │       ├── aop.mbn
            │       ├── boot.img
            │       ├── BTFM.bin
            │       ├── cmnlib64.mbn
            │       ├── cmnlib.mbn
            │       ├── devcfg_auto.mbn
            │       ├── dspso.bin
            │       ├── dtbo.img
            │       ├── ifs2_la.img
            │       ├── metadata.img
            │       ├── mifs_hyp_la.img
            │       ├── NON-HLOS.bin
            │       ├── qupv3fw.elf
            │       ├── system.img
            │       ├── system_la.img.sparse
            │       ├── tz.mbn
            │       ├── uefi_sec.mbn
            │       ├── vbmeta.img
            │       ├── vendor.img
            │       ├── xbl_config.elf
            │       └── xbl.elf
            └── output
                ├── R11_DDD1_221223_0504_ota_mpu_mcu.zip

    folder arch(delta):
        └── delta
            ├── input
            │   ├── MCU
            │   │   ├── mcuupgrade.bin
            │   │   └── mcuupgrade.md5
            │   └── MPU
            │       ├── R11_DDD1_221223_0504_ota_mpu_mcu.zip
            │       ├── R11_DDD1_221230_0562_ota_mpu_mcu.zip
            ├── output
            │   └── IDCU_delta_0504_0562_mpu_mcu.zip



    Options:
        a) allow degrade
        b) base version, it is not need for full update
        c) the sequence of updating mcu
        d) des folder, including MPU and MCU
        f) full update, delta without this parameter
        n) new version
        p) the sequence of updating mpu
        s) src folder, including MPU and MCU
        o) old package name
        w) new package name
        --sign) add signature
        --check) check manifest data

EOF

exit 1
}

DELTA_TOOL=(
    "bsdiff"
    "simg2img"
    "img2simg"
)

MPU_IMAGE_LIST=(
    "abl_fastboot.elf"
    "aop.mbn"
    "BTFM.bin"
    "cmnlib64.mbn"
    "cmnlib.mbn"
    "devcfg_auto.mbn"
    "dspso.bin"
    "mifs_hyp_la.img"
    "ifs2_la.img"
    "dtbo.img"
    "boot.img"
    "vbmeta.img"
    "NON-HLOS.bin"
    "qupv3fw.elf"
    "tz.mbn"
    "uefi_sec.mbn"
    "xbl.elf"
    "xbl_config.elf"
    "system_la.img.sparse"
    "system.img"
    "vendor.img"
    "metadata.img"
)

MPU_SPARSE_IMAGE_LIST=(
    "map.img.sparse"
    "metadata.img"
    "speech.img.sparse"
    "system.img"
    "system_la.img.qtd.sparse"
    "system_la.img.sparse"
    "vendor.img"
)

MPU_RWPARITION_IMAGE_LIST=(
    "metadata.img"
    "persist.img"
    "logfs_ufs_8mb.bin"
    "multi_image.mbn"
    "persist_qnx.img"
    "speech.img.sparse"
    "storsec.mbn"
    "userdata.img"
    "map.img.sparse"
)

function deleteTempFiles() {
    rm -rf $idcu_crypto_pri_key $idcu_crypto_pub_key $idcu_sign_pri_key $idcu_sign_pub_key $head_signature $originFile
    rm -rf $payloadPath
    rm -rf $desFolder/$ROOTFOLDER/old
    rm -rf $desFolder/$ROOTFOLDER/new
}

function deleteAllFiles() {
    deleteTempFiles
    rm -rf $pkgFile
    rm -rf $desFolder
    rm -rf ${imageFile%/*}/tmp
}

function showTime() {
    timestamp=$(date '+%s')
    echo $timestamp
}

function checkenv() {
    echo -e "#####################check environment##########################"
    for toolIndex in ${DELTA_TOOL[@]};
    do
        if [[ $PATH =~ "./delta/bin" ]]; then
            echo "PATH has included delta/bin"
        else
            if [ -z $PATH ]; then
                PATH=./delta/bin
            else
                PATH=$PATH:./delta/bin
            fi
        fi
        echo "PATH=$PATH"
        if [[ $LD_LIBRARY_PATH =~ "./delta/lib64" ]]; then
            echo "LD_LIBRARY_PATH has included delta/lib64"
        else
            if [ -z $LD_LIBRARY_PATH ]; then
                LD_LIBRARY_PATH=./delta/lib64
            else
                LD_LIBRARY_PATH=$LD_LIBRARY_PATH:./delta/lib64
            fi
        fi
        echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"

        toolInfo=$(which $toolIndex)
        if [[ $toolInfo =~ $toolIndex ]]; then
            echo -e "$toolIndex is in $toolInfo"
        else
            deleteAllFiles
            echo -e "\e[31m please install $toolIndex \e[0m"
            exit
        fi
    done
}

function checkParameters() {
    echo -e "#####################checkParameters##########################"
    if [ ! -d $srcFolder ]; then
        echo "$srcFolder is not existed"
        usage
    else
        if [ $mpu = true ]; then
            if [ $full = false ]; then
                if [ ! -e $srcFolder/MPU/$oldPkgFile ]; then
                    echo "$srcFolder/MPU/$oldPkgFile is not existed"
                    usage
                fi
                if [ ! -e $srcFolder/MPU/$newPkgFile ]; then
                    echo "$srcFolder/MPU/$newPkgFile is not existed"
                    usage
                fi
            elif [ $full = true ]; then
                if [ ! -d $srcFolder/MPU ]; then
                    echo "$srcFolder/MPU is not existed"
                    usage
                else
                    mkdir -p $desFolder/$ROOTFOLDER
                fi
            fi
            mkdir -p $desFolder/$ROOTFOLDER/MPU
        fi
        if [ $full = false ]; then
            mkdir -p $desFolder/$ROOTFOLDER/old
            mkdir -p $desFolder/$ROOTFOLDER/new
            mcuSrcFileDir=${desFolder}/$ROOTFOLDER/new/MCU
        fi
        if [ $mcu = true ]; then
            if [ ! -d $srcFolder/MCU ]; then
                echo "$srcFolder/MCU is not existed"
                usage
            else
                mkdir -p $desFolder/$ROOTFOLDER/MCU
            fi
        fi
    fi
}

function getVersion() {
    # version_1=${1#*_}
    # echo $version_1
    # version_2=${version_1#*_}
    # echo $version_2
    # version_3=${version_2#*_}
    # echo $version_3
    # version=${version_3%%_*}
    # echo $version
    suffixVersion=${1%_ota*}
    version=${suffixVersion##*_}
    echo $version
}

function genCA() {
    # Generate CA private key
    openssl genrsa -out ca.key 2048
    # Generate CSR
    openssl req -new -key ca.key -out ca.csr
    # Generate Self Signed certificate
    openssl x509 -req -days 365 -in ca.csr -signkey ca.key -out ca.crt

    # private key
    openssl genrsa -out private.key 1024
    # public key
    openssl rsa -in private.key -pubout -out public.key
    # generate csr
    openssl req -new -key private.key -out private.csr
    # generate certificate
    openssl ca -in private.csr -out private.crt -cert ca.crt -keyfile ca.key
}

function genKeyPair() {
    echo "######################genKeyPair#####################"
    # genCA

    # encryto&&decryto pri&&pub key
    # private key
    openssl genrsa -out $idcu_crypto_pri_key 1024
    # openssl req -new -x509 -key $idcu_crypto_pri_key -out idcu_sign_pri.pem -days 1095
    # cat private key
    openssl rsa -inform PEM -in $idcu_crypto_pri_key -text
    # public key
    openssl rsa -in $idcu_crypto_pri_key -pubout -out $idcu_crypto_pub_key
    # openssl req -new -x509 -key $idcu_crypto_pub_key -out idcu_sign_pub.pem -days 1095

    # sign&&verify pri&&pub key
    # private key
    openssl genrsa -out $idcu_sign_pri_key 1024
    # openssl req -new -x509 -key $idcu_sign_pri_key -out idcu_sign_pri.pem -days 1095
    # cat private key
    openssl rsa -inform PEM -in $idcu_sign_pri_key -text
    # public key
    openssl rsa -in $idcu_sign_pri_key -pubout -out $idcu_sign_pub_key
    # openssl req -new -x509 -key $idcu_sign_pub_key -out idcu_sign_pub.pem -days 1095
    echo -e "\n"
}

function genSign() {
    echo "####################generate Sign####################"
    #calculate sign
    openssl dgst -sha256 -out $head_signature -sign $idcu_sign_pri_key -keyform PEM $pkgFile
    #verify signature
    openssl dgst -sha256 -keyform PEM -verify $idcu_sign_pub_key -signature $head_signature $pkgFile
    result=$?
    if [ $result -ne 0 ]; then
        echo "sign failed"
        deleteAllFiles
        exit
    fi
    echo -e "\n"
    return $result
}

function handleHeader() {
    echo -e "\e[32m ####################handler header################### \e[0m"
    fileSize=$MAGIC_SIZE
    echo $MAGIC > $pkgFile
    truncate -s $fileSize $pkgFile

    ((fileSize = $fileSize + $PKGNAME_SIZE))
    echo $pkgName  >> $pkgFile
    truncate -s $fileSize $pkgFile

    buildTime=`showTime`
    ((fileSize = $fileSize + $BUILDTIME_SIZE))
    echo $buildTime  >> $pkgFile
    truncate -s $fileSize $pkgFile

    ((fileSize = $fileSize + $VERSION_SIZE ))
    echo $baseVersion  >> $pkgFile
    truncate -s $fileSize $pkgFile

    ((fileSize = $fileSize + $VERSION_SIZE ))
    echo $newVersion  >> $pkgFile
    truncate -s $fileSize $pkgFile


    if [ $full = false ]; then
        updateType=$UPDATEDELTA
    elif [ $full = true ]; then
        updateType=$UPDATEFULL
    fi
    ((fileSize = $fileSize + $UPDATETYPE_SIZE ))
    echo $updateType  >> $pkgFile
    truncate -s $fileSize $pkgFile

    ((fileSize = $fileSize + $ALLOWDEGRADE_SIZE ))
    echo $allowDegrade  >> $pkgFile
    truncate -s $fileSize $pkgFile

    ((fileSize = $fileSize + $UPDATEOBJECTS_SIZE ))
    echo $updateobjects  >> $pkgFile
    truncate -s $fileSize $pkgFile

    ((fileSize = $fileSize + $ISSIGNATURE_SIZE ))
    echo $isSignature  >> $pkgFile
    truncate -s $fileSize $pkgFile

    # set file size to PARTITIONINFOPOSITION
    truncate -s $PARTITIONINFOPOSITION $pkgFile
    fileSize=$PARTITIONINFOPOSITION
}

function handleSecurity() {
    echo -e "\e[32m ####################handler security################### \e[0m"
    fileSize=$PUBLICKEYPOSITION
    #Set header size before public key
    truncate -s $PUBLICKEYPOSITION $pkgFile

    #generate key pair
    # genKeyPair

    #Set sign public key
    cmd=$(dd if=$idcu_sign_pub_key of=$pkgFile seek=$PUBLICKEYPOSITION bs=1)
    if [ $? -ne 0 ];then
        echo "write public key failed"
        deleteAllFiles
        exit
    fi

    #Set decrypto private key
    cmd=$(dd if=$idcu_crypto_pri_key of=$pkgFile seek=$PRIVATEKEYPOSITION bs=1)
    if [ $? -ne 0 ];then
        echo "write public key failed"
        deleteAllFiles
        exit
    fi

    #Set header size before signature
    truncate -s $SIGNATUREPOSITION $pkgFile

    fileSize=$SIGNATUREPOSITION

    #metadata size
    metasize=$(stat --format=%s $pkgFile)
    ((fileSize = $fileSize + $METADATA_SIZE ))
    echo $metasize  >> $pkgFile
    truncate -s $fileSize $pkgFile

    #metadata signature size
    ((fileSize = $fileSize + $METADATASIGN_SIZE ))
    echo $signature_size  >> $pkgFile
    truncate -s $fileSize $pkgFile

    #fill reserved size
    ((fileSize = $fileSize + 16 ))


    #generate signature
    genSign
    #Set signature
    cmd=$(dd if=$head_signature of=$pkgFile seek=$fileSize bs=1)
    if [ $? -ne 0 ];then
        echo "write signature key failed"
        deleteAllFiles
        exit
    fi

    #Set Header Size
    truncate -s $HEADER_SIZE $pkgFile
    return 0
}

function writeComponentIntoJsonFile() {
    componentCount=0
    if [ $mcu = true ];then
        ((componentCount=$componentCount+1))
    fi
    if [ $mpu = true ];then
        ((componentCount=$componentCount+1))
    fi

    echo '    "component": [' >> $jsonFile
    if [ $mcuSeq -eq 1 ];then
        if [ $componentCount -eq 1 ];then
            echo '        "MCU"' >> $jsonFile
        else
            echo '        "MCU",' >> $jsonFile
        fi
    fi
    if [ $mpuSeq -eq 1 ];then
        if [ $componentCount -eq 1 ];then
            echo '        "MPU"' >> $jsonFile
        else
            echo '        "MPU",' >> $jsonFile
        fi
    fi
    if [ $mcuSeq -eq 2 ];then
        if [ $componentCount -eq 2 ];then
            echo '        "MCU"' >> $jsonFile
        else
            echo '        "MCU",' >> $jsonFile
        fi
    fi
    if [ $mpuSeq -eq 2 ];then
        if [ $componentCount -eq 2 ];then
            echo '        "MPU"' >> $jsonFile
        else
            echo '        "MPU",' >> $jsonFile
        fi
    fi
    echo "    ]," >> $jsonFile
}

function writeRWParitionInftoJsonFile() {
    echo '    "RWParition": [' >> $jsonFile

    count=0
    for i in ${MPU_RWPARITION_IMAGE_LIST[@]};
    do
        imagefile=$desFolder/$ROOTFOLDER/new/MPU/$i

        ((count=$count+1))
        echo "        {" >> $jsonFile
        echo '            "image":"'$i'"' >> $jsonFile
        if [ $count -ne ${#MPU_RWPARITION_IMAGE_LIST[@]} ];then
            echo "        }," >> $jsonFile
        else
            echo "        }" >> $jsonFile
        fi
    done
    echo '    ],' >> $jsonFile
}

function extractFullPkg() {
    echo -e "dd if=$2 of=${desFolder}/$ROOTFOLDER/$1/update.zip_raw skip=5 bs=1M"
    cmd=$(dd if=$2 of=${desFolder}/$ROOTFOLDER/$1/update.zip_raw skip=5 bs=1M)
    cmd=$(unzip -d ${desFolder}/$ROOTFOLDER/$1 ${desFolder}/$ROOTFOLDER/$1/update.zip_raw);
    cmd=$(rm -rf ${desFolder}/$ROOTFOLDER/$1/update.zip_raw)
}

function handleSparseImage() {
    echo -e "\e[32m ####################convert sparse image into raw image################### \e[0m"
    for i in ${MPU_IMAGE_LIST[@]};
    do
        nonsparse=true
        fileInfoStr=$(file $1/$i| awk '{print $2 $3 $4}')
        if [[ "$fileInfoStr" =~ "sparseimage" ]]; then
            echo -e "$1/$i is sparse file"
        else
            nonsparse=false
        fi

        if [ $nonsparse = true ]; then
            echo -e "simg2img $1/$i $1/${i}_raw"
            simg2img $1/$i $1/${i}_raw
            mv $1/${i}_raw $1/${i}
        fi
    done
}

function convertToSparseImage() {
    echo -e "\e[32m ####################convert some raw images into into image################### \e[0m"
    for i in ${MPU_SPARSE_IMAGE_LIST[@]};
    do
        if [ ! -e $1/$i ]; then
            echo -e "\e[31m $1/$i is not existed, skip it \e[0m"
            continue
        fi

        nonsparse=false
        fileInfoStr=$(file $1/$i| awk '{print $2 $3 $4}')
        if [[ "$fileInfoStr" =~ "sparseimage" ]]; then
            echo -e "$1/$i is sparse file"
            nonsparse=true
        else
            nonsparse=false
        fi

        if [ $nonsparse = false ]; then
            echo -e "img2simg $1/$i $1/${i}_sparse"
            img2simg $1/$i $1/${i}_sparse
            rm -rf $1/${i}
            mv $1/${i}_sparse $1/${i}
        fi
    done
}

function handlePartitionInfo() {
    partitionTotal=${#MPU_IMAGE_LIST[@]}
    echo "partitionTotal:$partitionTotal"
    #set partitionTotal into file
    ((fileSize = $fileSize + $PARTITIONTOTALSIZE))
    echo $partitionTotal >> $pkgFile
    truncate -s $fileSize $pkgFile

    for i in ${MPU_IMAGE_LIST[@]};
    do
        partitionIndexFile=$1/$i
        if [ ! -e $partitionIndexFile ]; then
            echo -e "\e[31m $partitionIndexFile is not existed \e[0m"
            deleteAllFiles
            exit
        fi
        #set image file name into file
        ((fileSize = $fileSize + $PARTITIONNAMESIZE))
        echo $i >> $pkgFile
        truncate -s $fileSize $pkgFile

        if [ $full = false ]; then
            partitionOldIndexFile=$2/$i
            partitionIndexOldFileSize=$(stat --format=%s $partitionOldIndexFile)
            #set image file size into file
            ((fileSize = $fileSize + $PARTITIONINDEXFILESIZE))
            echo $partitionIndexOldFileSize >> $pkgFile
            truncate -s $fileSize $pkgFile
        fi

        partitionIndexFileSize=$(stat --format=%s $partitionIndexFile)
        #set image file size into file
        ((fileSize = $fileSize + $PARTITIONINDEXFILESIZE))
        echo $partitionIndexFileSize >> $pkgFile
        truncate -s $fileSize $pkgFile

        if [ $full = false ]; then
            partitionOldIndexFile=$2/$i
            partitionIndexOldFileHash=$(sha256sum $partitionOldIndexFile|awk '{print $1}')
            #set raw image file hash256 into file
            ((fileSize = $fileSize + $HASHSIZE))
            echo $partitionIndexOldFileHash >> $pkgFile
            truncate -s $fileSize $pkgFile
        fi

        partitionIndexFileHash=$(sha256sum $partitionIndexFile|awk '{print $1}')
        #set raw image file hash256 into file
        ((fileSize = $fileSize + $HASHSIZE))
        echo $partitionIndexFileHash >> $pkgFile
        truncate -s $fileSize $pkgFile
    done

    # set file size to MANIFESTPOSITION
    fileSize=$MANIFESTPOSITION
    truncate -s $fileSize $pkgFile
}

function splitFile() {
    chunkIndex=0
    imageName=${1##*/}
    # 1.1 handler old image
    tempOldDir=$desFolder/${imageName}_old_split
    mkdir -p $tempOldDir
    cd ${tempOldDir}
    # file count will not exceed 9999
    # echo -e "\e[33m split -b ${CHUNKSIZE} $1 -d -a 4 old_ \e[0m"
    split -b ${CHUNKSIZE} $1 -d -a 4 old_
    # tree .

    # calculate file count
    imageFileSize=$(stat --format=%s $1)
    oldCount=$(($imageFileSize/$CHUNKSIZE))
    if [ 0 -ne $(($imageFileSize%$CHUNKSIZE)) ]; then
        let oldCount=oldCount+1
    fi
    cd -

    # 1.2 handler new image
    tempNewDir=$desFolder/${imageName}_new_split
    mkdir -p $tempNewDir
    cd ${tempNewDir}
    # file count will not exceed 9999
    # echo -e "\e[33m split -b ${CHUNKSIZE} $2 -d -a 4 new_ \e[0m"
    split -b ${CHUNKSIZE} $2 -d -a 4 new_
    # tree .

    # calculate file count
    imageFileSize=$(stat --format=%s $2)
    newCount=$(($imageFileSize/$CHUNKSIZE))
    if [ 0 -ne $(($imageFileSize%$CHUNKSIZE)) ]; then
        let newCount=newCount+1
    fi
    cd -

    #1.3 calculate delta
    tempPatchDir=$desFolder/${imageName}_patch_split
    mkdir -p $tempPatchDir
    imageChunkCount=$oldCount
    # old file is more than new file, the additional chunk will be discard
    if [ $oldCount -gt $newCount ]; then
        echo -e "\e[32m old files are more than new file \e[0m"
        imageChunkCount=$newCount
    fi
    if [ $oldCount -lt $newCount ]; then
        echo -e "\e[32m old files are less than new file \e[0m"
    fi

    echo -e "\e[33m ${imageName} is splitted into $imageChunkCount files \e[0m"
    let totalChunk=totalChunk+imageChunkCount
    count=0
    while (($count < $imageChunkCount))
    do
        fileCount=""
        if [ $count -lt 10 ]; then
            fileCount=000$count
        elif [ $count -lt 100 ]; then
            fileCount=00$count
        elif [ $count -lt 1000 ]; then
            fileCount=0$count
        elif [ $count -lt 10000 ]; then
            fileCount=$count
        fi
        echo -e "\e[35m start to handle $fileCount file \e[0m"
        handleDeltaData $tempOldDir/old_$fileCount $tempNewDir/new_$fileCount $tempPatchDir/patch_$fileCount $1
        # echo -e "\e[35m finsh to handle $fileCount file \e[0m"
        ((count++))
        echo -e "\n"
    done
    # echo -e "ls -lt ${tempOldDir} ${tempNewDir} ${tempPatchDir}"
    rm -rf ${tempOldDir} ${tempNewDir} ${tempPatchDir}
    return $count
}

function handleDeltaData() {
    #set chunk total size into file
    ((fileSize = $fileSize + $IMAGECHUNKCOUNTSIZE))
    echo $imageChunkCount >> $pkgFile
    truncate -s $fileSize $pkgFile

    #set current chunk id into file
    ((fileSize = $fileSize + $CHUNKINDEXSIZE))
    echo $chunkIndex >> $pkgFile
    truncate -s $fileSize $pkgFile

    ((manifestlength = $manifestlength + $CHUNKINFOSIZE))

    if [ ! -e $1 ]; then
        # old file is not existed, new file copy into payload.bin
        echo -e "\e[33m [operate:REPLACE] $4_$chunkIndex old file is not existed, copy new_$chunkIndex into payload.bin \e[0m"
        newHash=$(sha256sum $2|awk '{print $1}')
        diffAlgorithm=$REPLACE
	    patchHash=$newHash
        cat $2 >> $payloadPath
        patchFileSize=$CHUNKSIZE
        let totalpatchsize+=patchFileSize
    else
        baseHash=$(sha256sum $1|awk '{print $1}')
        newHash=$(sha256sum $2|awk '{print $1}')

        if [ $baseHash == $newHash ]; then
            if [ $baseHash == ${ZERO_HASH256} ]; then
                echo -e "\033[32m $4_$chunkIndex [operate:ZERO] base and new are 0 data, write zero data \033[0m"
                diffAlgorithm=$ZERO
                patchHash=${ZERO_HASH256}
            else
                echo -e "\033[32m $4_$chunkIndex [operate:MOVE] copy old_$chunkIndex file \033[0m"
                diffAlgorithm=$MOVE
                patchHash=$baseHash
                let oldFileChunkPos=chunkIndex*CHUNKSIZE
                eval checkChunkImage_$checkAllChunkIndex=$4
            fi
        else
            if [ $baseHash == ${ZERO_HASH256} ]; then
                echo -e "\033[32m $4_$chunkIndex [operate:REPLACE] old file is 0 data, copy new_$chunkIndex file \033[0m"
                diffAlgorithm=$REPLACE
                patchHash=$newHash
                cat $2 >> $payloadPath
                patchFileSize=$CHUNKSIZE
                let totalpatchsize+=patchFileSize
            elif [ $newHash == ${ZERO_HASH256} ]; then
                echo -e "\033[32m $4_$chunkIndex [operate:ZERO] new file is 0 data, write zero data \033[0m"
                diffAlgorithm=$ZERO
                patchHash=${ZERO_HASH256}
            else
                # diffAlgorithm=$BSDIFF
                diffStartTime=`showTime`
                echo -e "\e[32m start $BSDIFF $1 $2 $3 at $diffStartTime \e[0m"

                $BSDIFF $1 $2 $3

                diffFinishTime=`showTime`
                diffCostTime=$(($diffFinishTime - $diffStartTime))

                # write patch into payload.bin
                # cat $3 >> $payloadPath
                patchHash=$(sha256sum $3|awk '{print $1}')
                patchFileSize=$(stat --format=%s $3)
                echo -e "\033[32m $BSDIFF cost $diffCostTime seconds for the $4_$chunkIndex patch size:$patchFileSize \033[0m"
                ((standardchunksize=CHUNKSIZE*3/4))
                if [ $patchFileSize -gt $standardchunksize ]; then
                    echo -e "\033[32m patch size:$patchFileSize is large than standard, using REPLACE\033[0m"
                    echo -e "\033[32m $4_$chunkIndex [operate:REPLACE] old file is 0 data, copy new_$chunkIndex file \033[0m"
                    diffAlgorithm=$REPLACE
                    patchHash=$newHash
                    cat $2 >> $payloadPath
                    patchFileSize=$CHUNKSIZE
                else
                    diffAlgorithm=$BSDIFF
                    patchFileSize=$(stat --format=%s $3)
                    payloadsize=$(stat --format=%s $payloadPath)
                    echo -e "\033[32m write $patchFileSize into payload($payloadsize)\033[0m"
                    cat $3 >> $payloadPath
                    patchHash=$(sha256sum $3|awk '{print $1}')
                fi
                let totalpatchsize+=patchFileSize
            fi
        fi
    fi

    eval checkChunkBaseHash_$checkAllChunkIndex=$baseHash
    eval checkChunkNewHash_$checkAllChunkIndex=$newHash
    eval checkChunkPatchHash_$checkAllChunkIndex=$patchHash

    eval checkChunkAlgorithm_$checkAllChunkIndex=$diffAlgorithm
    eval echo -e "checkChunkAlgorithm_$checkAllChunkIndex:\$checkChunkAlgorithm_$checkAllChunkIndex"

    #set diff algorithm into file
    ((fileSize = $fileSize + $DIFFALGORITHMSIZE))
    echo $diffAlgorithm >> $pkgFile
    truncate -s $fileSize $pkgFile

    if [ $diffAlgorithm == $BSDIFF ]; then
        #set chunk/patch offset into file
        ((fileSize = $fileSize + $PATCHOFFSETSIZE))
        echo $patchOffset >> $pkgFile
        truncate -s $fileSize $pkgFile

        #set chunk/patch size into file
        ((fileSize = $fileSize + $PATCHFILESIZESIZE))
        echo $patchFileSize >> $pkgFile
        truncate -s $fileSize $pkgFile

        eval checkChunkOffset_$checkAllChunkIndex=$patchOffset
        eval checkChunkSize_$checkAllChunkIndex=$patchFileSize

        let patchOffset=patchOffset+patchFileSize
    elif [ $diffAlgorithm == $REPLACE ]; then
        #set chunk/patch offset into file
        ((fileSize = $fileSize + $PATCHOFFSETSIZE))
        echo $patchOffset >> $pkgFile
        truncate -s $fileSize $pkgFile

        #set chunk/patch size into file
        ((fileSize = $fileSize + $PATCHFILESIZESIZE))
        echo $CHUNKSIZE >> $pkgFile
        truncate -s $fileSize $pkgFile

        eval checkChunkOffset_$checkAllChunkIndex=$patchOffset
        eval checkChunkSize_$checkAllChunkIndex=$CHUNKSIZE

        let patchOffset=patchOffset+CHUNKSIZE
    elif [ $diffAlgorithm == $MOVE ]; then
        #set chunk/patch offset into file
        ((fileSize = $fileSize + $PATCHOFFSETSIZE))
        echo $oldFileChunkPos >> $pkgFile
        truncate -s $fileSize $pkgFile

        #set chunk/patch size into file
        ((fileSize = $fileSize + $PATCHFILESIZESIZE))
        echo $CHUNKSIZE >> $pkgFile
        truncate -s $fileSize $pkgFile

        eval checkChunkOffset_$checkAllChunkIndex=$oldFileChunkPos
        eval checkChunkSize_$checkAllChunkIndex=$CHUNKSIZE
    elif [ $diffAlgorithm == $ZERO ]; then
        #set chunk/patch offset into file
        ((fileSize = $fileSize + $PATCHOFFSETSIZE))
        echo $patchOffset >> $pkgFile
        truncate -s $fileSize $pkgFile

        #set chunk/patch size into file
        ((fileSize = $fileSize + $PATCHFILESIZESIZE))
        echo $CHUNKSIZE >> $pkgFile
        truncate -s $fileSize $pkgFile

        eval checkChunkOffset_$checkAllChunkIndex=$patchOffset
        eval checkChunkSize_$checkAllChunkIndex=$CHUNKSIZE
    fi

    #set base hash into file
    ((fileSize = $fileSize + $HASHSIZE))
    echo $baseHash >> $pkgFile
    truncate -s $fileSize $pkgFile

    #set new hash into file
    ((fileSize = $fileSize + $HASHSIZE))
    echo $newHash >> $pkgFile
    truncate -s $fileSize $pkgFile

    #set patch hash into file
    ((fileSize = $fileSize + $HASHSIZE))
    echo $patchHash >> $pkgFile
    truncate -s $fileSize $pkgFile

    ((chunkIndex++))
    ((checkAllChunkIndex++))
}

function deltaMPU() {
    echo "#####################delta MPU#####################"

    fileLack=false
    for i in ${MPU_IMAGE_LIST[@]};
    do
        oldImagefile=$desFolder/$ROOTFOLDER/old/MPU/$i
        if [ ! -e $oldImagefile ]; then
            echo -e "\e[31m $oldImagefile is not existed \e[0m"
            fileLack=true
        fi

        newImagefile=$desFolder/$ROOTFOLDER/new/MPU/$i
        if [ ! -e $newImagefile ]; then
            echo -e "\e[31m $newImagefile is not existed \e[0m"
            fileLack=true
        fi
    done
    # file lack, return
    if [ $fileLack = true ]; then
        deleteAllFiles
        exit
    fi
    # handle sparse
    handleSparseImage $desFolder/$ROOTFOLDER/old/MPU
    handleSparseImage $desFolder/$ROOTFOLDER/new/MPU
    handlePartitionInfo $desFolder/$ROOTFOLDER/new/MPU $desFolder/$ROOTFOLDER/old/MPU
    # ((manifestlength = $manifestlength + $PARTITIONTOTALSIZE))

    for i in ${MPU_IMAGE_LIST[@]};
    do
        echo -e "####################################################\n"
        echo -e "\e[41;33m ###############################start to handle $i##################### \e[0m"
        oldImagefile=$desFolder/$ROOTFOLDER/old/MPU/$i
        newImagefile=$desFolder/$ROOTFOLDER/new/MPU/$i

        baseImageHash=$(sha256sum ${oldImagefile}|awk '{print $1}')
        newImageHash=$(sha256sum ${newImagefile}|awk '{print $1}')
        if [ $baseImageHash == $newImageHash ]; then
            echo -e "\e[32m $i is same, skip \e[0m"
            continue
        fi

        ((manifestlength = $manifestlength + $PARTITIONINFOSIZE))

        #set partitionTotal into file
        ((fileSize = $fileSize + $PARTITIONNAMESIZE))
        echo $i >> $pkgFile
        truncate -s $fileSize $pkgFile

        ((partitionId++))
        #set partition id into file
        ((fileSize = $fileSize + $PARTITIONIDSIZE))
        echo $partitionId >> $pkgFile
        truncate -s $fileSize $pkgFile

        fstype=ext4
        #set fs type into file
        ((fileSize = $fileSize + $FSTYPESIZE))
        echo $fstype >> $pkgFile
        truncate -s $fileSize $pkgFile

        splitFile $oldImagefile $newImagefile

        echo -e "\e[41;33m ###############################finish to handle $i##################### \e[0m"
        echo -e "\n"
    done

    fileSize=$MANIFESTTOTALPOSITION
    truncate -s $fileSize $pkgFile

    #set manifest length into file
    ((fileSize = $fileSize + $MANIFESTLENGTHSIZE))
    echo $manifestlength >> $pkgFile
    truncate -s $fileSize $pkgFile

    partitionCount=$partitionId
    ((fileSize = $fileSize + $PARTITIONCOUNTSIZE))
    echo $partitionCount >> $pkgFile
    truncate -s $fileSize $pkgFile

    #set total chunk count into file
    ((fileSize = $fileSize + $TOTALCHUNKSIZE))
    echo $totalChunk >> $pkgFile
    truncate -s $fileSize $pkgFile

    echo -e "\e[41;33m ###############################total patch size: $totalpatchsize##################### \e[0m"

    payloadhash=$(sha256sum $payloadPath|awk '{print $1}')
    echo -e "\e[41;33m ###############################payload hash: $payloadhash##################### \e[0m"
}

function handleMPU() {
    if [ $full = false ]; then
        updateType=$UPDATEDELTA
        deltaMPU

        # record into json
        echo "{" > $jsonFile

        typeJson=""
        if [ $full = false ]; then
            typeJson="delta"
        elif [ $full = true ]; then
            typeJson="full"
        fi
        echo '    "type":"'$typeJson'",' >> $jsonFile

        writeComponentIntoJsonFile

        # some partition is mounted as rw mode, it will not be updated
        writeRWParitionInftoJsonFile

        echo '    "MPU": [' >> $jsonFile

        count=0
        for i in ${MPU_IMAGE_LIST[@]};
        do
            imagefile=$desFolder/$ROOTFOLDER/new/MPU/$i

            ((count=$count+1))
            echo "        {" >> $jsonFile
            echo '            "image":"'$i'",' >> $jsonFile

            imageFileSize=$(stat --format=%s $imagefile)
            echo '            "size":"'$imageFileSize'",' >> $jsonFile

            # raw image hash
            hashcode=$(sha256sum $imagefile|awk '{print $1}')
            echo '            "hash":"'$hashcode'"' >> $jsonFile
            if [ $count -ne ${#MPU_IMAGE_LIST[@]} ];then
                echo "        }," >> $jsonFile
            else
                echo "        }" >> $jsonFile
            fi
        done
        echo '    ]' >> $jsonFile

        echo '}' >> $jsonFile
    elif [ $full = true ]; then
        updateType=$UPDATEFULL

        fileLack=false
        for i in ${MPU_IMAGE_LIST[@]};
        do
            imagefile=$srcFolder/MPU/$i
            if [ ! -e $imagefile ]; then
                echo -e "\e[31m $imagefile is not existed \e[0m"
                fileLack=true
            fi
        done
        # file lack, return
        if [ $fileLack = true ]; then
            deleteAllFiles
            exit
        fi

        # record into json
        echo "{" > $jsonFile

        typeJson=""
        if [ $full = false ]; then
            typeJson="delta"
        elif [ $full = true ]; then
            typeJson="full"
        fi
        echo '    "type":"'$typeJson'",' >> $jsonFile

        writeComponentIntoJsonFile

        echo '    "MPU": [' >> $jsonFile

        # copy all the images into destinator folder
        for i in ${MPU_IMAGE_LIST[@]};
        do
            imagefile=$srcFolder/MPU/$i
            cp $imagefile $desFolder/$ROOTFOLDER/MPU/
        done

        # convert sparse image into raw image
        handleSparseImage $desFolder/$ROOTFOLDER/MPU
        handlePartitionInfo $desFolder/$ROOTFOLDER/MPU

        #convert raw image which is origin-sparse image into sparse image
        convertToSparseImage $desFolder/$ROOTFOLDER/MPU

        count=0
        for i in ${MPU_IMAGE_LIST[@]};
        do
            imagefile=$desFolder/$ROOTFOLDER/MPU/$i

            ((count=$count+1))
            echo "        {" >> $jsonFile
            echo '            "image":"'$i'",' >> $jsonFile

            imageFileSize=$(stat --format=%s $imagefile)
            echo '            "size":"'$imageFileSize'",' >> $jsonFile

            # origin image hash
            hashcode=$(sha256sum $imagefile|awk '{print $1}')
            echo '            "hash":"'$hashcode'"' >> $jsonFile
            if [ $count -ne ${#MPU_IMAGE_LIST[@]} ];then
                echo "        }," >> $jsonFile
            else
                echo "        }" >> $jsonFile
            fi
        done
        echo '    ]' >> $jsonFile
        echo '}' >> $jsonFile
    fi
}

function handleMCU() {
    if [ -z $mcuSrcFileDir ]; then
        echo -e "\e[35m mcu src dir is $mcuSrcFileDir \e[0m"
        deleteAllFiles
        usage
        exit
    fi
    if [ ! -d $mcuSrcFileDir ]; then
        echo -e "\e[35m mcu src dir[$mcuSrcFileDir] is not existed \e[0m"
        deleteAllFiles
        usage
        exit
    fi
    echo -e "\e[35m copy $mcuSrcFileDir/* to $desFolder/$ROOTFOLDER/MCU/ \e[0m"
    cp -rf $mcuSrcFileDir/* $desFolder/$ROOTFOLDER/MCU/
}

function writeZipImage() {
    startZipTime=`showTime`

    # cmd=$(cd ${imageFile%/*}; zip -r $imageFile $ROOTFOLDER/* ; cd -)
    cmd=$(cd $desFolder/$ROOTFOLDER; zip -r $imageFile * ; cd -)
    if [ $? -ne 0 ];then
        echo "zip image folder failed"
        deleteAllFiles
        exit
    else
        cmd=$(rm -rf $desFolder/$ROOTFOLDER)
        echo -e "\e[32m start to check zip file \e[0m"
        # check zipfile
        cmd=$(mkdir -p ${imageFile%/*}/tmp)
        cmd=$(unzip -d ${imageFile%/*}/tmp $imageFile);
        if [ $? -ne 0 ];then
            echo -e "\e[31m check zip file failed \e[0m"
            deleteAllFiles
            exit
        else
            echo -e "\e[32m check zip file successful \e[0m"
            cmd=$(tree  ${imageFile%/*})
            cmd=$(rm -rf ${imageFile%/*}/tmp)
        fi
    fi
    finishZipTime=`showTime`
    echo "zip cost $(($finishZipTime - $startZipTime)) seconds"

    # cmd=$(dd if=$imageFile of=$pkgFile seek=$HEADER_SIZE bs=1)
    cmd=$(cat $imageFile >> $pkgFile)
    if [ $? -ne 0 ];then
        echo -e "\e[31m write image zip failed \e[0m"
        deleteAllFiles
        exit
    fi
    finishWriteTime=`showTime`
    echo "write cost $(($finishWriteTime - $finishZipTime)) seconds"
}

function checkManifestData() {
    echo -e "\e[32m ####################check manifest data################### \e[0m"
    checkManifestDataStartTime=`showTime`
    echo -e "\e[32m start at $checkManifestDataStartTime \e[0m"

    number=0
    while (($number < $checkAllChunkIndex))
    do
        eval echo -e "checkChunkAlgorithm_$number:\$checkChunkAlgorithm_$number"
        if [[ $(eval echo \$checkChunkAlgorithm_$number) == $ZERO ]]; then
            if [[ $ZERO_HASH256 != $(eval echo \$checkChunkBaseHash_$number) ]]; then
                echo -e "\e[31m fail, $number chunk is not zero \e[0m"
                deleteAllFiles
                exit
            else
                echo -e "\e[32m check $(eval echo \$checkChunkAlgorithm_$number) successful \e[0m"
            fi
        elif [[ $(eval echo \$checkChunkAlgorithm_$number) == $MOVE ]]; then
            ((skip_param=$(eval echo \$checkChunkOffset_$number)/1048576))
            ((count_param=$(eval echo \$checkChunkSize_$number)/1048576))
            echo -e "\e[35m dd if=$(eval echo \$checkChunkImage_$number) of=checkChunkFile skip=$skip_param count=$count_param bs=1M \e[0m"
            cmd=$(dd if=$(eval echo \$checkChunkImage_$number) of=checkChunkFile skip=$skip_param count=$count_param bs=1M)
            checkChunkFileHash=$(sha256sum checkChunkFile|awk '{print $1}')
            if [[ $checkChunkFileHash != $(eval echo \$checkChunkBaseHash_$number) ]]; then
                echo -e "\e[31m hash is not same, $checkChunkFileHash $(eval echo \$checkChunkBaseHash_$number) \e[0m"
                deleteAllFiles
                exit
            else
                echo -e "\e[32m check $checkChunkFileHash successful \e[0m"
            fi
        elif [[ $(eval echo \$checkChunkAlgorithm_$number) == $REPLACE ]]; then
            ((skip_param=$(eval echo \$checkChunkOffset_$number)/1048576))
            ((count_param=$(eval echo \$checkChunkSize_$number)/1048576))
            echo -e "\e[35m dd if=$payloadPath of=checkChunkFile skip=$skip_param count=$count_param bs=1M \e[0m"
            cmd=$(dd if=$payloadPath of=checkChunkFile skip=$skip_param count=$count_param bs=1M)
            checkChunkFileHash=$(sha256sum checkChunkFile|awk '{print $1}')
            if [[ $checkChunkFileHash != $(eval echo \$checkChunkNewHash_$number) ]]; then
                echo -e "\e[31m hash is not same, $checkChunkFileHash $(eval echo \$checkChunkNewHash_$number) \e[0m"
                deleteAllFiles
                exit
            else
                echo -e "\e[32m check $checkChunkFileHash successful \e[0m"
            fi
        elif [[ $(eval echo \$checkChunkAlgorithm_$number) == $BSDIFF ]]; then
            echo -e "\e[35m dd if=$payloadPath of=checkChunkFile skip=$(eval echo \$checkChunkOffset_$number) count=$(eval echo \$checkChunkSize_$number) bs=1 \e[0m"
            cmd=$(dd if=$payloadPath of=checkChunkFile skip=$(eval echo \$checkChunkOffset_$number) count=$(eval echo \$checkChunkSize_$number) bs=1)
            checkChunkFileHash=$(sha256sum checkChunkFile|awk '{print $1}')
            if [[ $checkChunkFileHash != $(eval echo \$checkChunkPatchHash_$number) ]]; then
                echo -e "\e[31m hash is not same, $checkChunkFileHash $(eval echo \$checkChunkPatchHash_$number) \e[0m"
                deleteAllFiles
                exit
            else
                echo -e "\e[32m check $checkChunkFileHash successful \e[0m"
            fi
        fi
        rm -rf checkChunkFile
        ((number++))
    done

    checkManifestDataFinishTime=`showTime`
    echo -e "\e[32m finish at $checkManifestDataFinishTime \e[0m"
    costTime=$(($checkManifestDataFinishTime - $checkManifestDataStartTime))
    echo -e "\e[32m check Manifest Data cost $costTime seconds \e[0m"
    echo -e "\n"
}

long_opts="allowdegrade,mpu,mcu,full,oldPkg,newPkg,sign,srcfolder,desfolder,baseversion,newversion"
if ! getopts=$(getopt -o ap:c:fo:w:s:d:b:n: -l $long_opts -- "$@"); then
   echo "Error processing options"
   usage
fi

eval set -- "$getopts"

while true; do
    case "$1" in
       -a|--allowdegrade)
            allowDegrade=1
        ;;
       -p|--mpu)
            mpu=true
            mpuSeq=$2 ; shift
        ;;
       -c|--mcu)
            mcu=true
            mcuSeq=$2 ; shift
        ;;
       -f|--full)
            full=true
        ;;
        -o|--oldPkg)
            oldPkgFile=$2 ; shift
        ;;
        -w|--newPkg)
            newPkgFile=$2 ; shift
        ;;
       --sign)
            isSignature=1
        ;;
       --check)
            isCheckManifest=1
        ;;
       -s|--srcfolder)
            srcFolder=$2 ; shift
        ;;
       -d|--desfolder)
            desFolder=$2 ; shift
        ;;
       -b|--baseversion)
            baseVersion=$2 ; shift
        ;;
       -n|--newversion)
            newVersion=$2 ; shift
        ;;
       --)
            shift ; break
        ;;
       *)
            echo "Error processing args -- unrecognized option $1" >&2
            usage
        ;;
    esac
    shift
done

if [ $full = false ]; then
    baseVersion=$(getVersion $oldPkgFile)
    newVersion=$(getVersion $newPkgFile)
    echo "baseVersion($baseVersion) from $oldPkgFile"
    echo "newVersion($newVersion) from $newPkgFile"
fi

# fit absolute path and relative path
absolPath=false
if [[ $srcFolder == /* ]] ; then
    absolPath=true
elif [[ $srcFolder == ~* ]] ; then
    absolPath=true
fi

if [ $absolPath = false ]; then
    echo -e "update src and des folder"
    tempFolder=$srcFolder
    srcFolder=$curDir/$tempFolder
    tempFolder=$desFolder
    desFolder=$curDir/$tempFolder
fi

if [ $newVersion != "" ];then
    if [ $full = true ]; then
        name=IDCU_${newVersion}
    else
        name=IDCU_delta_${baseVersion}_${newVersion}
    fi
    if [ $mpu = true ];then
        name=${name}_mpu
    fi
    if [ $mcu = true ];then
        name=${name}_mcu
    fi
    pkgName=${name}.zip
else
    # it can't be impossible delta
    name="IDCU_1234"
    if [ $mpu = true ];then
        name=${name}_mpu
    fi
    if [ $mcu = true ];then
        name=${name}_mcu
    fi
    pkgName=${name}.zip
fi


if [ $mpu = true ]; then
    ((updateobjects = updateobjects + 1))
fi
if [ $mcu = true ]; then
    ((updateobjects = updateobjects + 2))
fi
if [ $updateobjects -eq 0 ];then
    echo "no invalid update objects"
    usage
    exit
fi

echo "pkgName:$pkgName"

originFile=$desFolder/IDCU.zip
pkgFile=$desFolder/$pkgName
imageFile=$desFolder/$ROOTFOLDER.zip
jsonFile=$desFolder/$ROOTFOLDER/IDCU_FOTA.json

payloadPath=$desFolder/$ROOTFOLDER/MPU/$PAYLOADBIN

idcu_crypto_pri_key=idcu_cryto_pri.key
idcu_crypto_pub_key=idcu_cryto_pub.key
idcu_sign_pri_key=idcu_sign_pri.key
idcu_sign_pub_key=idcu_sign_pub.key
head_signature=header.sig

deleteAllFiles

checkenv
echo "###################check two folder##################"
checkParameters
echo -e "\n"

handleHeader
echo -e "\n"

#generate key pair
genKeyPair


if [ $full = false ]; then
    extractFullPkg old $srcFolder/MPU/$oldPkgFile
    extractFullPkg new $srcFolder/MPU/$newPkgFile
fi

if [ $mpu = true ]; then
    echo "#####################handler MPU#####################"
    startTime=`showTime`
    echo -e "\e[32m start at $startTime \e[0m"

    handleMPU

    finishTime=`showTime`
    echo -e "\e[32m finish at $finishTime \e[0m"
    costTime=$(($finishTime - $startTime))
    echo "Handle MPU cost $costTime seconds"
    echo -e "\n"
fi

if [ $full = true ]; then
    mcuSrcFileDir=$srcFolder/MCU
fi

if [ $mcu = true ]; then
    echo "#####################handler MCU#####################"
    startTime=`showTime`
    echo -e "\e[32m start at $startTime \e[0m"

    handleMCU

    finishTime=`showTime`
    echo -e "\e[32m finish at $finishTime \e[0m"
    costTime=$(($finishTime - $startTime))
    echo "Handle MCU cost $costTime seconds"
    echo -e "\n"
fi

handleSecurity

if [ $full = false ]; then
    if [ isCheckManifest -eq 1 ]; then
        checkManifestData
    fi
    rm -rf $desFolder/$ROOTFOLDER/old
    rm -rf $desFolder/$ROOTFOLDER/new
fi

writeZipImage

deleteTempFiles

echo -e "\e[32m generate package:$pkgFile successful"

echo -e "\n"

echo "####################package finished#################"


