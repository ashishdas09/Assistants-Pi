#
# Copyright 2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
#
#  http://aws.amazon.com/apache2.0
#
# or in the "license" file accompanying this file. This file is distributed
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied. See the License for the specific language governing
# permissions and limitations under the License.
#

if [ -z "$PLATFORM" ]; then
    echo "You should run the setup.sh script."
    exit 1
fi

SOUND_CONFIG="$HOME/.asoundrc"
START_SCRIPT="$INSTALL_BASE/startsample.sh"
CMAKE_PLATFORM_SPECIFIC=(-DSENSORY_KEY_WORD_DETECTOR=ON \
    -DGSTREAMER_MEDIA_PLAYER=ON -DPORTAUDIO=ON \
    -DPORTAUDIO_LIB_PATH="$THIRD_PARTY_PATH/portaudio/lib/.libs/libportaudio.$LIB_SUFFIX" \
    -DPORTAUDIO_INCLUDE_DIR="$THIRD_PARTY_PATH/portaudio/include" \
    -DSENSORY_KEY_WORD_DETECTOR_LIB_PATH=$THIRD_PARTY_PATH/alexa-rpi/lib/libsnsr.a \
    -DSENSORY_KEY_WORD_DETECTOR_INCLUDE_DIR=$THIRD_PARTY_PATH/alexa-rpi/include)

GSTREAMER_AUDIO_SINK="alsasink"

install_dependencies() {
  sudo apt-get update
  sudo apt-get -y install git gcc cmake screen build-essential libsqlite3-dev libcurl4-openssl-dev libfaad-dev libsoup2.4-dev libgcrypt20-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-good libasound2-dev sox gedit vim python3-pip
  pip install flask commentjson
}

run_os_specifics() {
  build_port_audio
  build_kwd_engine
  }

build_kwd_engine() {

  LOCAL_DIR="${THIRD_PARTY_PATH}/alexa-rpi"
  if [ -d "${LOCAL_DIR}" ]; then
  {
    #checkout sensory and build
    echo
    echo "==============> Checkout sensory and build =============="
    echo

    cd ./${LOCAL_DIR}
    git checkout -- .
  }
  else
  {
    cd $THIRD_PARTY_PATH

    #get sensory and build
    echo
    echo "==============> CLONING AND BUILDING SENSORY =============="
    echo

     {
        git clone git://github.com/Sensory/alexa-rpi.git
     } || {
        git clone https://github.com/Sensory/alexa-rpi.git
     }
  }
  fi

  bash ./alexa-rpi/bin/license.sh
}

generate_start_script() {
  cat << EOF > "$START_SCRIPT"
  cd "$BUILD_PATH/SampleApp/src"

  ./SampleApp "$OUTPUT_CONFIG_FILE" "$THIRD_PARTY_PATH/alexa-rpi/models" INFO
EOF
}
