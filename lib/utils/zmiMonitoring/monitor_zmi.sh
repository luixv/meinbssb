#!/bin/bash

# --- Configuration ---
# All configuration can be overridden by environment variables

# Target URL to monitor (default: BSSB ZMI server)
TARGET_URL="${TARGET_URL:-https://webintern.bssb.bayern:56400/rest/zmi/api/serverping}"

# Expected HTTP status code (e.g., 200 for OK)
EXPECTED_HTTP_CODE="${EXPECTED_HTTP_CODE:-200}"

# Maximum allowed total response time in seconds
MAX_RESPONSE_TIME="${MAX_RESPONSE_TIME:-5.0}"

# Connection timeout in seconds
CONNECT_TIMEOUT="${CONNECT_TIMEOUT:-3}"

# Maximum total time in seconds
MAX_TIME="${MAX_TIME:-10}"

# Path for logs (CSV file). This MUST be accessible by your web server.
# This path should match what your web page's JavaScript is trying to read.
LOG_FILE="${LOG_FILE:-/volume1/web/zmi/https_monitor.csv}"

# --- End Configuration ---

# Ensure the log directory exists
LOG_DIR=$(dirname "$LOG_FILE")
mkdir -p "$LOG_DIR"

# Check if the log file is new or if header is missing, and add a header for CSV
# All original columns are back: Timestamp,Target_URL,HTTP_Code,Response_Time_s,Status_Message
if [ ! -f "$LOG_FILE" ] || [ -z "$(head -n 1 "$LOG_FILE" | grep 'Timestamp,Target_URL')" ]; then
    echo "Timestamp,Target_URL,HTTP_Code,Response_Time_s,Status_Message" >> "$LOG_FILE"
fi

# Perform the HTTPS request and capture status code and total time
CURL_OUTPUT=$(curl -s -o /dev/null -w "%{http_code}:%{time_total}" -L --connect-timeout "$CONNECT_TIMEOUT" --max-time "$MAX_TIME" "$TARGET_URL")
CURL_STATUS=$? # Capture curl's exit status

# Parse the output from curl
HTTP_CODE=$(echo "$CURL_OUTPUT" | cut -d':' -f1)
RESPONSE_TIME=$(echo "$CURL_OUTPUT" | cut -d':' -f2) # Floating-point number

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
STATUS_DESCRIPTION="OK" # Default status message for logging

# --- Determine status message for logging ---
if [ "$CURL_STATUS" -ne 0 ]; then
    # Check if it's a timeout due to max_time being exceeded
    if [ "$CURL_STATUS" -eq 28 ]; then
        STATUS_DESCRIPTION="Server_Timeout"
    else
        # Detailed curl error classification
        case $CURL_STATUS in
            1)  STATUS_DESCRIPTION="Curl_Protocol_Error" ;;
            2)  STATUS_DESCRIPTION="Curl_Bad_Option" ;;
            3)  STATUS_DESCRIPTION="Curl_URL_Malformed" ;;
            4)  STATUS_DESCRIPTION="Curl_URL_User_Required" ;;
            5)  STATUS_DESCRIPTION="Curl_Could_Not_Resolve_Proxy" ;;
            6)  STATUS_DESCRIPTION="Curl_Could_Not_Resolve_Host" ;;
            7)  STATUS_DESCRIPTION="Curl_Could_Not_Connect" ;;
            8)  STATUS_DESCRIPTION="Curl_FTP_Weird_Server_Reply" ;;
            9)  STATUS_DESCRIPTION="Curl_Remote_Access_Denied" ;;
            10) STATUS_DESCRIPTION="Curl_FTP_Accept_Failed" ;;
            11) STATUS_DESCRIPTION="Curl_FTP_Weird_Pass_Reply" ;;
            12) STATUS_DESCRIPTION="Curl_FTP_Accept_Timeout" ;;
            13) STATUS_DESCRIPTION="Curl_FTP_Weird_PASV_Reply" ;;
            14) STATUS_DESCRIPTION="Curl_FTP_Weird_227_Format" ;;
            15) STATUS_DESCRIPTION="Curl_FTP_Cant_Get_Host" ;;
            16) STATUS_DESCRIPTION="Curl_HTTP2_Error" ;;
            17) STATUS_DESCRIPTION="Curl_FTP_Could_Not_Set_Type" ;;
            18) STATUS_DESCRIPTION="Curl_Partial_File" ;;
            19) STATUS_DESCRIPTION="Curl_FTP_Could_Not_Retr_File" ;;
            20) STATUS_DESCRIPTION="Curl_Quote_Error" ;;
            21) STATUS_DESCRIPTION="Curl_HTTP_Returned_Error" ;;
            22) STATUS_DESCRIPTION="Curl_Write_Error" ;;
            23) STATUS_DESCRIPTION="Curl_Upload_Failed" ;;
            24) STATUS_DESCRIPTION="Curl_Read_Error" ;;
            25) STATUS_DESCRIPTION="Curl_Out_Of_Memory" ;;
            26) STATUS_DESCRIPTION="Curl_Operation_Timeout" ;;
            27) STATUS_DESCRIPTION="Curl_SSL_Connect_Error" ;;
            28) STATUS_DESCRIPTION="Curl_Operation_Timed_Out" ;;
            29) STATUS_DESCRIPTION="Curl_SSL_Certificate_Problem" ;;
            30) STATUS_DESCRIPTION="Curl_SSL_Cipher" ;;
            31) STATUS_DESCRIPTION="Curl_Peer_Failed_Verification" ;;
            33) STATUS_DESCRIPTION="Curl_Range_Error" ;;
            34) STATUS_DESCRIPTION="Curl_HTTP_Post_Error" ;;
            35) STATUS_DESCRIPTION="Curl_SSL_Connect_Error" ;;
            36) STATUS_DESCRIPTION="Curl_Bad_Download_Resume" ;;
            37) STATUS_DESCRIPTION="Curl_File_Could_Not_Read_File" ;;
            38) STATUS_DESCRIPTION="Curl_LDAP_Cannot_Bind" ;;
            39) STATUS_DESCRIPTION="Curl_LDAP_Search_Failed" ;;
            40) STATUS_DESCRIPTION="Curl_Library_Not_Found" ;;
            41) STATUS_DESCRIPTION="Curl_Function_Not_Found" ;;
            42) STATUS_DESCRIPTION="Curl_Aborted_By_Callback" ;;
            43) STATUS_DESCRIPTION="Curl_Bad_Function_Argument" ;;
            44) STATUS_DESCRIPTION="Curl_Interface_Failed" ;;
            45) STATUS_DESCRIPTION="Curl_Too_Many_Redirects" ;;
            46) STATUS_DESCRIPTION="Curl_Unknown_Option" ;;
            47) STATUS_DESCRIPTION="Curl_Telnet_Option_Syntax" ;;
            48) STATUS_DESCRIPTION="Curl_Peer_Failed_Verification" ;;
            49) STATUS_DESCRIPTION="Curl_Got_Nothing" ;;
            50) STATUS_DESCRIPTION="Curl_SSL_Engine_Not_Found" ;;
            51) STATUS_DESCRIPTION="Curl_SSL_Engine_Set_Failed" ;;
            52) STATUS_DESCRIPTION="Curl_Send_Error" ;;
            53) STATUS_DESCRIPTION="Curl_Recv_Error" ;;
            54) STATUS_DESCRIPTION="Curl_SSL_Certificate_Verify_Failed" ;;
            55) STATUS_DESCRIPTION="Curl_SSL_Shutdown_Failed" ;;
            56) STATUS_DESCRIPTION="Curl_Again" ;;
            57) STATUS_DESCRIPTION="Curl_SSL_CRL_Badfile" ;;
            58) STATUS_DESCRIPTION="Curl_SSL_Issuer_Error" ;;
            59) STATUS_DESCRIPTION="Curl_FTP_PRET_Failed" ;;
            60) STATUS_DESCRIPTION="Curl_RTSP_Cseq_Error" ;;
            61) STATUS_DESCRIPTION="Curl_RTSP_Session_Error" ;;
            62) STATUS_DESCRIPTION="Curl_FTP_Bad_File_List" ;;
            63) STATUS_DESCRIPTION="Curl_Chunk_Failed" ;;
            64) STATUS_DESCRIPTION="Curl_No_Connection_Available" ;;
            65) STATUS_DESCRIPTION="Curl_SSL_Pinned_Pubkey_Not_Match" ;;
            66) STATUS_DESCRIPTION="Curl_SSL_Invalid_Certificate_Status" ;;
            67) STATUS_DESCRIPTION="Curl_HTTP2_Stream" ;;
            68) STATUS_DESCRIPTION="Curl_Recursive_API_Call" ;;
            69) STATUS_DESCRIPTION="Curl_Auth_Error" ;;
            70) STATUS_DESCRIPTION="Curl_HTTP3" ;;
            71) STATUS_DESCRIPTION="Curl_Quic_Connect_Error" ;;
            72) STATUS_DESCRIPTION="Curl_Proxy" ;;
            73) STATUS_DESCRIPTION="Curl_SSL_Client_Cert" ;;
            74) STATUS_DESCRIPTION="Curl_Unrecoverable_Proxy" ;;
            75) STATUS_DESCRIPTION="Curl_SSL_Engine_Init_Failed" ;;
            76) STATUS_DESCRIPTION="Curl_Login_Denied" ;;
            77) STATUS_DESCRIPTION="Curl_TFTP_Not_Found" ;;
            78) STATUS_DESCRIPTION="Curl_TFTP_Perm" ;;
            79) STATUS_DESCRIPTION="Curl_Remote_Disk_Full" ;;
            80) STATUS_DESCRIPTION="Curl_TFTP_Illegal" ;;
            81) STATUS_DESCRIPTION="Curl_TFTP_Unknown_ID" ;;
            82) STATUS_DESCRIPTION="Curl_Remote_File_Exists" ;;
            83) STATUS_DESCRIPTION="Curl_TFTP_No_Such_User" ;;
            84) STATUS_DESCRIPTION="Curl_Conversion_Failed" ;;
            85) STATUS_DESCRIPTION="Curl_Conversion_Required" ;;
            86) STATUS_DESCRIPTION="Curl_SSL_CACert_Badfile" ;;
            87) STATUS_DESCRIPTION="Curl_Remote_File_Not_Found" ;;
            88) STATUS_DESCRIPTION="Curl_SSH" ;;
            89) STATUS_DESCRIPTION="Curl_SSL_Shutdown_Failed" ;;
            90) STATUS_DESCRIPTION="Curl_Again" ;;
            91) STATUS_DESCRIPTION="Curl_SSL_CRL_Badfile" ;;
            92) STATUS_DESCRIPTION="Curl_SSL_Issuer_Error" ;;
            93) STATUS_DESCRIPTION="Curl_FTP_PRET_Failed" ;;
            94) STATUS_DESCRIPTION="Curl_RTSP_Cseq_Error" ;;
            95) STATUS_DESCRIPTION="Curl_RTSP_Session_Error" ;;
            96) STATUS_DESCRIPTION="Curl_FTP_Bad_File_List" ;;
            97) STATUS_DESCRIPTION="Curl_Chunk_Failed" ;;
            98) STATUS_DESCRIPTION="Curl_No_Connection_Available" ;;
            99) STATUS_DESCRIPTION="Curl_SSL_Pinned_Pubkey_Not_Match" ;;
            100) STATUS_DESCRIPTION="Curl_SSL_Invalid_Certificate_Status" ;;
            *)  STATUS_DESCRIPTION="Curl_Unknown_Error_${CURL_STATUS}" ;;
        esac
    fi
elif [ "$HTTP_CODE" != "$EXPECTED_HTTP_CODE" ]; then
    STATUS_DESCRIPTION="HTTP_Code_Mismatch"
else
    if (( $(echo "$RESPONSE_TIME > $MAX_RESPONSE_TIME" | awk '{print ($1 > $2)}') )); then
        STATUS_DESCRIPTION="Slow_Response"
    else
        STATUS_DESCRIPTION="Online" # Changed from "Responded successfully." for conciseness
    fi
fi

# --- Always log the data for statistics (all 5 columns) ---
echo "$TIMESTAMP,$TARGET_URL,$HTTP_CODE,$RESPONSE_TIME,$STATUS_DESCRIPTION" >> "$LOG_FILE"

exit 0

