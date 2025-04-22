#!/bin/bash
#
# Copyright (C) 2021-2022 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEBUG=0
if [[ ${DEBUG} != 0 ]]; then
    log="/dev/tty"
else
    log="/dev/null"
fi

if [[ -z "${SRC}" ]] && [[ -z "${1}" ]]; then
    echo "Missing source"
    exit
elif [[ -z "${SRC}" ]]; then
    echo "Using '${1}' as source"
    SRC="${1}"
fi

if [[ -z "${ANDROID_ROOT}" ]] || [[ -z "${OUTDIR}" ]] && [[ -z "${2}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    out="${SCRIPT_DIR}/../custom-gms"
elif [[ -z "${ANDROID_ROOT}" ]] || [[ -z "${OUTDIR}" ]]; then
    out="${2}"
else
    out="${ANDROID_ROOT}/${OUTDIR}"
fi

if [[ -z "${MY_DIR}" ]]; then
    MY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    echo "Detected MY_DIR as: ${MY_DIR}"
fi

if [[ -f "${SRC}/system/apex/com.google.android.extservices.apex" ]]; then
    APEX_PATH="${SRC}/system/apex/com.google.android.extservices.apex"
elif [[ -f "${SRC}/system/system/apex/com.google.android.extservices.apex" ]]; then
    APEX_PATH="${SRC}/system/system/apex/com.google.android.extservices.apex"
else
    echo "APEX file not found in expected locations!"
    exit
fi

# Create a temporary working directory
TMPDIR=$(mktemp -d)

# Unpack the apex
apktool d "${APEX_PATH}" -o "${TMPDIR}"/out > "${log}"

# Unpack the resulting original_apex.
7z e "${TMPDIR}"/out/unknown/original_apex -o"${TMPDIR}/extracted_apex" > "${log}"

# Unpack the resulting apex_payload.img
7z e "${TMPDIR}"/extracted_apex/apex_payload.img -o"${TMPDIR}" > "${log}"

# Prepare output directories
mkdir -p "${out}/proprietary/system/priv-app/GoogleExtServices"
mkdir -p "${out}/proprietary/system/etc/permissions"

# Copy files
cp "${TMPDIR}/GoogleExtServices.apk" "${out}/proprietary/system/priv-app/GoogleExtServices/GoogleExtServices.apk"
cp "${TMPDIR}/privapp_allowlist_com.google.android.ext.services.xml" "${out}/proprietary/system/etc/permissions/privapp_allowlist_com.google.android.ext.services.xml"

# Clear the temporary working directory
rm -rf "${TMPDIR}"

# Pin SHA1 of filename (not content) in proprietary-files-GoogleExtServices.txt
if [[ -f "${MY_DIR}/proprietary-files-GoogleExtServices.txt" ]]; then
    file1="system/priv-app/GoogleExtServices/GoogleExtServices.apk"
    file2="system/etc/permissions/privapp_allowlist_com.google.android.ext.services.xml"

    # Calculate SHA1 of the filenames (not the file content)
    hash1=$(echo "${file1}" | sha1sum | awk '{print $1}')
    hash2=$(echo "${file2}" | sha1sum | awk '{print $1}')

    # Print the filenames and the corresponding hashes for debugging
    echo "Updating ${file1} with hash ${hash1}"
    echo "Updating ${file2} with hash ${hash2}"

    # Check if the filename is already in the file
    if grep -q "${file1}" "${MY_DIR}/proprietary-files-GoogleExtServices.txt"; then
        # Update the existing entry with the new SHA1 hash
        sed -i "s#${file1}.*#${file1};OVERRIDES=ExtServices;PRESIGNED|${hash1}#" "${MY_DIR}/proprietary-files-GoogleExtServices.txt"
    else
        # Append the new entry if it doesn't exist
        echo "${file1};OVERRIDES=ExtServices;PRESIGNED|${hash1}" >> "${MY_DIR}/proprietary-files-GoogleExtServices.txt"
    fi

    if grep -q "${file2}" "${MY_DIR}/proprietary-files-GoogleExtServices.txt"; then
        # Update the existing entry with the new SHA1 hash
        sed -i "s#${file2}.*#${file2}|${hash2}#" "${MY_DIR}/proprietary-files-GoogleExtServices.txt"
    else
        # Append the new entry if it doesn't exist
        echo "${file2}|${hash2}" >> "${MY_DIR}/proprietary-files-GoogleExtServices.txt"
    fi
fi

echo "Updated GoogleExtServices with filename hashes!"
