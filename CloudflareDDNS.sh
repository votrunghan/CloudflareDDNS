#!/bin/bash

# Current Version: 1.0.0

## How to get and use?
# curl -O https://raw.githubusercontent.com/hezhijie0327/CloudflareDDNS/master/CloudflareDDNS.sh && chmod 0777 ./CloudflareDDNS.sh
# ./CloudflareDDNS.sh -e user@example.com -k 123defghijk4567pqrstuvw890 -z example.com -r demo.example.com -t A -l 900 -p false -m create

## How to fix?
# Syntax error: "(" unexpected -> sudo dpkg-reconfigure dash -> No

## Configuration
# Cloudflare Email Address
XAuthEmail=""
# Cloudflare API Key
XAuthKey=""
# Zone Name
ZoneName=""
# Record Name
RecordName=""
# Type (A | AAAA)
Type=""
# TTL (1 | 120 | 300 | 600 | 900 | 1800 | 3600 | 7200 | 18000 | 43200 | 86400)
TTL=""
# Proxy Status (true | false)
ProxyStatus=""
# Running Mode (create | update | delete)
RunningMode=""

## Parameter
while getopts e:k:z:r:t:l:p:m: GetParameter; do
    case ${GetParameter} in
        # Cloudflare Email Address
        e) XAuthEmail="${OPTARG}";;
        # Cloudflare API Key
        k) XAuthKey="${OPTARG}";;
        # Zone Name
        z) ZoneName="${OPTARG}";;
        # Record Name
        r) RecordName="${OPTARG}";;
        # Type
        t) Type="${OPTARG}";;
        # TTL
        l) TTL="${OPTARG}";;
        # Proxy Status
        p) ProxyStatus="${OPTARG}";;
        # Running Mode
        m) RunningMode="${OPTARG}";;
    esac
done

## Function
# Check Configuration Validity
function CheckConfigurationValidity() {
    if [ "${XAuthEmail}" = "" ]; then
        echo "An error occurred during processing. Missing (XAuthEmail) value, please check it and try again."
        exit 1
    fi
    if [ "${XAuthKey}" = "" ]; then
        echo "An error occurred during processing. Missing (XAuthKey) value, please check it and try again."
        exit 1
    fi
    if [ "${ZoneName}" = "" ]; then
        echo "An error occurred during processing. Missing (ZoneName) value, please check it and try again."
        exit 1
    fi
    if [ "${RecordName}" = "" ]; then
        echo "An error occurred during processing. Missing (RecordName) value, please check it and try again."
        exit 1
    fi
    if [ "${RunningMode}" = "" ]; then
        echo "An error occurred during processing. Missing (RunningMode) value, please check it and try again."
        exit 1
    elif [ "${RunningMode}" != "create" ] && [ "${RunningMode}" != "update" ] && [ "${RunningMode}" != "delete" ]; then
        echo "An error occurred during processing. Invalid (RunningMode) value, please check it and try again."
        exit 1
    fi
    if [ "${RunningMode}" = "create" ] || [ "${RunningMode}" = "update" ]; then
        if [ "${Type}" = "" ]; then
            echo "An error occurred during processing. Missing (Type) value, please check it and try again."
            exit 1
        elif [ "${Type}" != "A" ] && [ "${Type}" != "AAAA" ]; then
            echo "An error occurred during processing. Invalid (Type) value, please check it and try again."
            exit 1
        fi
        if [ "${TTL}" = "" ]; then
            echo "An error occurred during processing. Missing (TTL) value, please check it and try again."
            exit 1
        elif [ "${TTL}" != "1" ] && [ "${TTL}" != "120" ] && [ "${TTL}" != "300" ] && [ "${TTL}" != "600" ] && [ "${TTL}" != "900" ] && [ "${TTL}" != "1800" ] && [ "${TTL}" != "3600" ] && [ "${TTL}" != "7200" ] && [ "${TTL}" != "18000" ] && [ "${TTL}" != "43200" ] && [ "${TTL}" != "86400" ]; then
            echo "An error occurred during processing. Invalid (TTL) value, please check it and try again."
            exit 1
        fi
        if [ "${ProxyStatus}" = "" ]; then
            echo "An error occurred during processing. Missing (ProxyStatus) value, please check it and try again."
            exit 1
        elif [ "${ProxyStatus}" != "true" ] && [ "${ProxyStatus}" != "false" ]; then
            echo "An error occurred during processing. Invalid (ProxyStatus) value, please check it and try again."
            exit 1
        fi
    fi
}
# Get Account Name
function GetAccountName() {
    CloudflareAPIv4Response=$(curl -s --connect-timeout 15 -X GET "https://api.cloudflare.com/client/v4/accounts?page=1&per_page=5&direction=desc" -H "X-Auth-Email: ${XAuthEmail}" -H "X-Auth-Key: ${XAuthKey}" -H "Content-Type: application/json")
    if [ "$(echo ${CloudflareAPIv4Response} | jq -r '.success')" = "true" ]; then
        if [ "$(echo ${CloudflareAPIv4Response} | jq -r '.result[] | {name} | .name')" = "" ]; then
            echo "false"
        else
            echo "$(echo ${CloudflareAPIv4Response} | jq -r '.result[] | {name} | .name')"
        fi
    elif [ "$(echo ${CloudflareAPIv4Response} | jq -r '.success')" = "false" ]; then
        echo "false"
    else
        echo "invalid"
    fi
}
# Get Zone ID
function GetZoneID() {
    CloudflareAPIv4Response=$(curl -s --connect-timeout 15 -X GET "https://api.cloudflare.com/client/v4/zones?name=${ZoneName}" -H "X-Auth-Email: ${XAuthEmail}" -H "X-Auth-Key: ${XAuthKey}" -H "Content-Type: application/json")
    if [ "$(echo ${CloudflareAPIv4Response} | jq -r '.success')" = "true" ]; then
        if [ "$(echo ${CloudflareAPIv4Response} | jq -r '.result[] | {id} | .id')" = "" ]; then
            echo "false"
        else
            echo "$(echo ${CloudflareAPIv4Response} | jq -r '.result[] | {id} | .id')"
        fi
    elif [ "$(echo ${CloudflareAPIv4Response} | jq -r '.success')" = "false" ]; then
        echo "false"
    else
        echo "invalid"
    fi
}
function GetRecordID() {
    CloudflareAPIv4Response=$(curl -s --connect-timeout 15 -X GET "https://api.cloudflare.com/client/v4/zones/${ZoneID}/dns_records?name=${RecordName}" -H "X-Auth-Email: ${XAuthEmail}" -H "X-Auth-Key: ${XAuthKey}" -H "Content-Type: application/json")
    if [ "$(echo ${CloudflareAPIv4Response} | jq -r '.success')" = "true" ]; then
        if [ "$(echo ${CloudflareAPIv4Response} | jq -r '.result[] | {id} | .id')" = "" ]; then
            echo "false"
        else
            echo "$(echo ${CloudflareAPIv4Response} | jq -r '.result[] | {id} | .id')"
        fi
    elif [ "$(echo ${CloudflareAPIv4Response} | jq -r '.success')" = "false" ]; then
        echo "false"
    else
        echo "invalid"
    fi
}
# Get DNS Record
function GetDNSRecord() {
    CloudflareAPIv4Response=$(curl -s --connect-timeout 15 -X GET "https://api.cloudflare.com/client/v4/zones/${ZoneID}/dns_records/${RecordID}" -H "X-Auth-Email: ${XAuthEmail}" -H "X-Auth-Key: ${XAuthKey}" -H "Content-Type: application/json")
    if [ "$(echo ${CloudflareAPIv4Response} | jq -r '.success')" = "true" ]; then
        if [ "$(echo ${CloudflareAPIv4Response} | jq -r '.result.content')" = "" ]; then
            echo "false"
        else
            echo "$(echo ${CloudflareAPIv4Response} | jq -r '.result.content')"
        fi
    elif [ "$(echo ${CloudflareAPIv4Response} | jq -r '.success')" = "false" ]; then
        echo "false"
    else
        echo "invalid"
    fi
}
# Get WAN IP
function GetWANIP() {
    if [ "${Type}" = "A" ]; then
        GoogleAPIResponse=$(dig -4 TXT +short o-o.myaddr.l.google.com @ns$(( ( RANDOM % 2 ) + 1 )).google.com | awk '{ match( $0, /[0-9\.]+/ ); print substr( $0, RSTART, RLENGTH ) }')
        if [ "${GoogleAPIResponse}" = "" ]; then
            OpenDNSAPIResponse=$(dig -4 A +short myip.opendns.com @resolver$(( ( RANDOM % 2 ) + 1 )).opendns.com | awk '{ match( $0, /[0-9\.]+/ ); print substr( $0, RSTART, RLENGTH ) }')
            if [ "${OpenDNSAPIResponse}" = "" ]; then
                echo "invalid"
            else
                echo "${OpenDNSAPIResponse}"
            fi
        else
            echo "${GoogleAPIResponse}"
        fi
    elif [ "${Type}" = "AAAA" ]; then
        GoogleAPIResponse=$(dig -6 TXT +short o-o.myaddr.l.google.com @ns$(( ( RANDOM % 2 ) + 1 )).google.com | awk '{ match( $0, /[0-9a-f\:]+/ ); print substr( $0, RSTART, RLENGTH ) }')
        if [ "${GoogleAPIResponse}" = "" ]; then
            OpenDNSAPIResponse=$(dig -6 AAAA +short myip.opendns.com @resolver$(( ( RANDOM % 2 ) + 1 )).opendns.com | awk '{ match( $0, /[0-9a-f\:]+/ ); print substr( $0, RSTART, RLENGTH ) }')
            if [ "${OpenDNSAPIResponse}" = "" ]; then
                echo "invalid"
            else
                echo "${OpenDNSAPIResponse}"
            fi
        else
            echo "${GoogleAPIResponse}"
        fi
    fi
}
# Get POST Response
function GetPOSTResponse() {
    CloudflareAPIv4Response=$(curl -s --connect-timeout 15 -X POST "https://api.cloudflare.com/client/v4/zones/${ZoneID}/dns_records" -H "X-Auth-Email: ${XAuthEmail}" -H "X-Auth-Key: ${XAuthKey}" -H "Content-Type: application/json" --data "{\"type\":\"${Type}\",\"name\":\"${RecordName}\",\"content\":\"${WANIP}\",\"ttl\":${TTL},\"proxied\":${ProxyStatus}}")
    if [ "$(echo ${CloudflareAPIv4Response} | jq -r '.success')" = "true" ]; then
        echo "true"
    elif [ "$(echo ${CloudflareAPIv4Response} | jq -r '.success')" = "false" ]; then
        echo "false"
    else
        echo "invalid"
    fi
}
# Get PUT Response
function GetPUTResponse() {
    CloudflareAPIv4Response=$(curl -s --connect-timeout 15 -X PUT "https://api.cloudflare.com/client/v4/zones/${ZoneID}/dns_records/${RecordID}" -H "X-Auth-Email: ${XAuthEmail}" -H "X-Auth-Key: ${XAuthKey}" -H "Content-Type: application/json" --data "{\"type\":\"${Type}\",\"name\":\"${RecordName}\",\"content\":\"${WANIP}\",\"ttl\":${TTL},\"proxied\":${ProxyStatus}}")
    if [ "$(echo ${CloudflareAPIv4Response} | jq -r '.success')" = "true" ]; then
        echo "true"
    elif [ "$(echo ${CloudflareAPIv4Response} | jq -r '.success')" = "false" ]; then
        echo "false"
    else
        echo "invalid"
    fi
}
# Get DELETE Response
function GetDELETEResponse() {
    CloudflareAPIv4Response=$(curl -s --connect-timeout 15 -X DELETE "https://api.cloudflare.com/client/v4/zones/${ZoneID}/dns_records/${RecordID}" -H "X-Auth-Email: ${XAuthEmail}" -H "X-Auth-Key: ${XAuthKey}" -H "Content-Type: application/json")
    if [ "$(echo ${CloudflareAPIv4Response} | jq -r '.success')" = "true" ]; then
        echo "true"
    elif [ "$(echo ${CloudflareAPIv4Response} | jq -r '.success')" = "false" ]; then
        echo "false"
    else
        echo "invalid"
    fi
}

## Process
# Call CheckConfigurationValidity
CheckConfigurationValidity
if [ "${RunningMode}" = "create" ]; then
    # Call GetAccountName
    AccountName=$(GetAccountName)
    if [ "${AccountName}" = "invalid" ]; then
        echo "An error occurred during processing. Invalid (AccountName) value, please check your network connectivity, and try again."
        exit 1
    elif [ "${AccountName}" = "false" ]; then
        echo "An error occurred during processing. Invalid (AccountName) value, please check (XAuthEmail) and (XAuthKey) value, and try again."
        exit 1
    else
        echo "Current Account Name: ${AccountName}"
        # Call GetZoneID
        ZoneID=$(GetZoneID)
        if [ "${ZoneID}" = "invalid" ]; then
            echo "An error occurred during processing. Invalid (ZoneID) value, please check your network connectivity, and try again."
            exit 1
        elif [ "${ZoneID}" = "false" ]; then
            echo "An error occurred during processing. Invalid (ZoneID) value, please check (ZoneName) value, and try again."
            exit 1
        else
            echo "Current Zone ID: ${ZoneID}"
            # Call GetRecordID
            RecordID=$(GetRecordID)
            if [ "${RecordID}" = "invalid" ]; then
                echo "An error occurred during processing. Invalid (RecordID) value, please check your network connectivity, and try again."
                exit 1
            elif [ "${RecordID}" != "invalid" ] && [ "${RecordID}" != "false" ]; then
                echo "An error occurred during processing. ${RecordName} has been existed."
                exit 1
            else
                # Call GetWANIP
                WANIP=$(GetWANIP)
                if [ "${WANIP}" = "invalid" ]; then
                    if [ "${Type}" = "A" ]; then
                        echo "An error occurred during processing. Invalid (WANIP) value, please check your IPv4 connectivity."
                        exit 1
                    else
                        echo "An error occurred during processing. Invalid (WANIP) value, please check your IPv6 connectivity."
                        exit 1
                    fi
                else
                    echo "Current WAN IP: ${WANIP}"
                    # Call GetPOSTResponse
                    POSTResponse=$(GetPOSTResponse)
                    if [ "${POSTResponse}" = "true" ]; then
                        echo "No error occurred during processing. ${RecordName} has been created."
                        exit 0
                    else
                        echo "An error occurred during processing. Invalid (POSTResponse) value, please check your network connectivity, and try again."
                        exit 1
                    fi
                fi
            fi
        fi
    fi
elif [ "${RunningMode}" = "update" ]; then
    # Call GetAccountName
    AccountName=$(GetAccountName)
    if [ "${AccountName}" = "invalid" ]; then
        echo "An error occurred during processing. Invalid (AccountName) value, please check your network connectivity, and try again."
        exit 1
    elif [ "${AccountName}" = "false" ]; then
        echo "An error occurred during processing. Invalid (AccountName) value, please check (XAuthEmail) and (XAuthKey) value, and try again."
        exit 1
    else
        echo "Current Account Name: ${AccountName}"
        # Call GetZoneID
        ZoneID=$(GetZoneID)
        if [ "${ZoneID}" = "invalid" ]; then
            echo "An error occurred during processing. Invalid (ZoneID) value, please check your network connectivity, and try again."
            exit 1
        elif [ "${ZoneID}" = "false" ]; then
            echo "An error occurred during processing. Invalid (ZoneID) value, please check (ZoneName) value, and try again."
            exit 1
        else
            echo "Current Zone ID: ${ZoneID}"
            # Call GetRecordID
            RecordID=$(GetRecordID)
            if [ "${RecordID}" = "invalid" ]; then
                echo "An error occurred during processing. Invalid (RecordID) value, please check your network connectivity, and try again."
                exit 1
            elif [ "${RecordID}" = "false" ]; then
                echo "An error occurred during processing. ${RecordName} has not been existed."
                exit 1
            else
                echo "Current Record ID: ${RecordID}"
                # Call GetWANIP
                WANIP=$(GetWANIP)
                if [ "${WANIP}" = "invalid" ]; then
                    if [ "${Type}" = "A" ]; then
                        echo "An error occurred during processing. Invalid (WANIP) value, please check your IPv4 connectivity."
                        exit 1
                    else
                        echo "An error occurred during processing. Invalid (WANIP) value, please check your IPv6 connectivity."
                        exit 1
                    fi
                else
                    echo "Current WAN IP: ${WANIP}"
                    # Call GetDNSRecord
                    DNSRecord=$(GetDNSRecord)
                    if [ "${DNSRecord}" = "invalid" ]; then
                        echo "An error occurred during processing. Invalid (DNSRecord) value, please check your network connectivity, and try again."
                        exit 1
                    elif [ "${DNSRecord}" = "false" ]; then
                        echo "An error occurred during processing. Invalid (DNSRecord) value, please check (ZoneName) and (RecordName) value, and try again."
                        exit 1
                    else
                        if [ "${DNSRecord}" = "${WANIP}" ]; then
                            echo "An error occurred during processing. WAN IP has not been changed."
                            exit 1
                        else
                            echo "Current DNS Record: ${DNSRecord}"
                            # Call GetPOSTResponse
                            PUTResponse=$(GetPUTResponse)
                            if [ "${PUTResponse}" = "true" ]; then
                                echo "No error occurred during processing. ${RecordName} has been updated."
                                exit 0
                            else
                                echo "An error occurred during processing. Invalid (PUTResponse) value, please check your network connectivity, and try again."
                                exit 1
                            fi
                        fi
                    fi
                fi
            fi
        fi
    fi
else
    # Call GetAccountName
    AccountName=$(GetAccountName)
    if [ "${AccountName}" = "invalid" ]; then
        echo "An error occurred during processing. Invalid (AccountName) value, please check your network connectivity, and try again."
        exit 1
    elif [ "${AccountName}" = "false" ]; then
        echo "An error occurred during processing. Invalid (AccountName) value, please check (XAuthEmail) and (XAuthKey) value, and try again."
        exit 1
    else
        echo "Current Account Name: ${AccountName}"
        # Call GetZoneID
        ZoneID=$(GetZoneID)
        if [ "${ZoneID}" = "invalid" ]; then
            echo "An error occurred during processing. Invalid (ZoneID) value, please check your network connectivity, and try again."
            exit 1
        elif [ "${ZoneID}" = "false" ]; then
            echo "An error occurred during processing. Invalid (ZoneID) value, please check (ZoneName) value, and try again."
            exit 1
        else
            echo "Current Zone ID: ${ZoneID}"
            # Call GetRecordID
            RecordID=$(GetRecordID)
            if [ "${RecordID}" = "invalid" ]; then
                echo "An error occurred during processing. Invalid (RecordID) value, please check your network connectivity, and try again."
                exit 1
            elif [ "${RecordID}" = "false" ]; then
                echo "An error occurred during processing. ${RecordName} has not been existed."
                exit 1
            else
                echo "Current Record ID: ${RecordID}"
                # Call GetDELETEResponse
                DELETEResponse=$(GetDELETEResponse)
                if [ "${DELETEResponse}" = "true" ]; then
                    echo "No error occurred during processing. ${RecordName} has been deleted."
                    exit 0
                else
                    echo "An error occurred during processing. Invalid (DELETEResponse) value, please check your network connectivity, and try again."
                    exit 1
                fi
            fi
        fi
    fi
fi