#!/bin/bash
# Xcode Build Phase: Copy LiteRT-LM resources
# Add this as a "Run Script" build phase in Xcode

RESOURCES_SRC="${PROJECT_DIR}/Runner/Resources"
FRAMEWORKS_SRC="${PROJECT_DIR}/Runner/Frameworks/litertlm"
RESOURCES_DST="${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Resources"
FRAMEWORKS_DST="${BUILT_PRODUCTS_DIR}/${CONTENTS_FOLDER_PATH}/Frameworks/litertlm"

# Copy JAR
if [ -f "${RESOURCES_SRC}/litertlm-server.jar" ]; then
    mkdir -p "${RESOURCES_DST}"
    cp "${RESOURCES_SRC}/litertlm-server.jar" "${RESOURCES_DST}/"
    echo "Copied litertlm-server.jar to Resources"
fi

# Copy natives
if [ -d "${FRAMEWORKS_SRC}" ]; then
    mkdir -p "${FRAMEWORKS_DST}"
    cp -r "${FRAMEWORKS_SRC}"/* "${FRAMEWORKS_DST}/"
    echo "Copied LiteRT-LM natives to Frameworks"
fi
