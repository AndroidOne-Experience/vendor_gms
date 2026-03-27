#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

# =========================
# CONFIG
# =========================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/.."

APEX_LIST="${SCRIPT_DIR}/proprietary-files_apex.txt"
OUT_BASE="${ROOT_DIR}/custom-gms"

# =========================
# ARGUMENTS
# =========================
SECTION=
SRC=

while [ "$#" -gt 0 ]; do
    case "$1" in
        --kang)
            SECTION="$2"
            shift
            ;;
        *)
            SRC="$1"
            ;;
    esac
    shift
done

if [[ -z "${SRC}" ]]; then
    echo "Usage: $0 [--kang section] <PATH TO firmware dump>"
    exit 1
fi

if [[ ! -d "${SRC}" ]]; then
    echo "Invalid source path: ${SRC}"
    exit 1
fi

if [[ ! -f "${APEX_LIST}" ]]; then
    echo "Missing proprietary-files_apex.txt"
    exit 1
fi

mkdir -p "${OUT_BASE}"

echo "===== APEX Extraction Started ====="
[[ -n "$SECTION" ]] && echo "Section filter: $SECTION"

# =========================
# READ LIST
# =========================
mapfile -t APEX_ENTRIES < <(sed 's/\r$//' "${APEX_LIST}")

CURRENT_SECTION=""

for RAW_ENTRY in "${APEX_ENTRIES[@]}"; do
    LINE=$(echo "$RAW_ENTRY" | xargs)

    [[ -z "$LINE" ]] && continue

    # section header
    if [[ "$LINE" =~ ^# ]]; then
        CURRENT_SECTION=$(echo "$LINE" | sed 's/^# *//')
        continue
    fi

    # filter section
    if [[ -n "$SECTION" && "$CURRENT_SECTION" != "$SECTION" ]]; then
        continue
    fi

    # =========================
    # PARSE FLAGS
    # =========================
    CLEAN_PATH=$(echo "$LINE" | cut -d';' -f1)
    FLAGS=$(echo "$LINE" | cut -s -d';' -f2-)

    OVERRIDE=""
    PRESIGNED=false

    if [[ "$FLAGS" == *"OVERRIDES="* ]]; then
        OVERRIDE=$(echo "$FLAGS" | sed -n 's/.*OVERRIDES=\([^;]*\).*/\1/p')
    fi

    if [[ "$FLAGS" == *"PRESIGNED"* ]]; then
        PRESIGNED=true
    fi

    BASENAME=$(basename "$CLEAN_PATH")

    echo ">>> Processing: ${BASENAME}"

    # =========================
    # FIND APEX
    # =========================
    if [[ -f "${SRC}/${CLEAN_PATH}" ]]; then
        APEX_PATH="${SRC}/${CLEAN_PATH}"
    elif [[ -f "${SRC}/system/apex/${BASENAME}" ]]; then
        APEX_PATH="${SRC}/system/apex/${BASENAME}"
    elif [[ -f "${SRC}/system/system/apex/${BASENAME}" ]]; then
        APEX_PATH="${SRC}/system/system/apex/${BASENAME}"
    else
        echo "❌ Not found: ${BASENAME}"
        continue
    fi

    echo "✔ Found: ${APEX_PATH}"

    # =========================
    # DETECT PARTITION
    # =========================
    PARTITION="system"

    if [[ "${APEX_PATH}" == *"/system_ext/"* ]]; then
        PARTITION="system_ext"
    elif [[ "${APEX_PATH}" == *"/product/"* ]]; then
        PARTITION="product"
    fi

    echo "✔ Partition: ${PARTITION}"

    TMPDIR=$(mktemp -d)

    # =========================
    # EXTRACT APEX
    # =========================
    apktool d "${APEX_PATH}" -o "${TMPDIR}/out" >/dev/null
    7z e "${TMPDIR}/out/unknown/original_apex" -o"${TMPDIR}/extracted" >/dev/null
    7z e "${TMPDIR}/extracted/apex_payload.img" -o"${TMPDIR}/payload" >/dev/null

    # =========================
    # FIND APK (MULTI SUPPORT)
    # =========================
    APK_FILES=$(find "${TMPDIR}/payload" \( -path "*/priv-app/*" -o -path "*/app/*" \) -name "*.apk")

    [[ -z "$APK_FILES" ]] && APK_FILES=$(find "${TMPDIR}/payload" -name "*.apk")

    if [[ -z "$APK_FILES" ]]; then
        echo "❌ No APK found"
        rm -rf "${TMPDIR}"
        continue
    fi

    for APK_FILE in $APK_FILES; do
        APK_NAME=$(basename "$APK_FILE")
        MODULE_NAME=$(basename "$APK_NAME" .apk)

        OUT_DIR="${OUT_BASE}/${MODULE_NAME}"
        mkdir -p "${OUT_DIR}"

        echo "✔ APK: ${APK_NAME}"

        cp "${APK_FILE}" "${OUT_DIR}/${APK_NAME}"

        # =========================
        # COPY PERMISSIONS (MATCH BY PACKAGE NAME)
        # =========================
        HAS_PERM=false

        APK_PKG=$(aapt dump badging "$APK_FILE" 2>/dev/null | awk -F"'" '/package: name=/{print $2}')

        if [[ -n "$APK_PKG" ]]; then
            PERM_DIR="${OUT_DIR}/permissions"
            mkdir -p "${PERM_DIR}"

            for XML in $(find "${TMPDIR}/payload" -name "privapp*.xml"); do
                XML_NAME=$(basename "$XML")

                if [[ "$XML_NAME" == *"$APK_PKG"* ]]; then
                    cp "$XML" "${PERM_DIR}/${XML_NAME}"
                    HAS_PERM=true
                fi
            done
        fi

        # =========================
        # GENERATE Android.bp
        # =========================
        BP_FILE="${OUT_DIR}/Android.bp"

        cat > "$BP_FILE" <<EOF
android_app_import {
    name: "${MODULE_NAME}",
    owner: "gms",
    apk: "${APK_NAME}",
EOF

        [[ -n "$OVERRIDE" ]] && echo "    overrides: [\"${OVERRIDE}\"]," >> "$BP_FILE"

        echo "    preprocessed: true," >> "$BP_FILE"

        [[ "$PRESIGNED" == true ]] && echo "    presigned: true," >> "$BP_FILE"

        cat >> "$BP_FILE" <<EOF
    dex_preopt: {
        enabled: false,
    },
    privileged: true,
}
EOF

        # =========================
        # ADD prebuilt_etc FOR EACH XML
        # =========================
        if [[ "$HAS_PERM" == true ]]; then
            for XML in "${PERM_DIR}"/*.xml; do
                XML_NAME=$(basename "$XML")
                MODULE_PERM_NAME="${XML_NAME}"

                cat >> "$BP_FILE" <<EOF

prebuilt_etc {
    name: "${MODULE_PERM_NAME}",
    src: "permissions/${XML_NAME}",
    sub_dir: "permissions",
EOF

                if [[ "$PARTITION" == "system_ext" ]]; then
                    echo "    system_ext_specific: true," >> "$BP_FILE"
                elif [[ "$PARTITION" == "product" ]]; then
                    echo "    product_specific: true," >> "$BP_FILE"
                fi

                echo "}" >> "$BP_FILE"
            done
        fi

        echo "✔ Done: ${MODULE_NAME}"
        echo
    done

    rm -rf "${TMPDIR}"

done

echo "===== DONE ====="