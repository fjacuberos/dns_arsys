#!/usr/bin/bash

#This is the Arsys api wrapper for acme.sh
#
#Author: F.J. Cuberos



ARSYS_API_URL="https://api.servidoresdns.net:54321/hosting/api/soap/index.php"

########  Public functions #####################

#Usage: dns_myapi_add   _acme-challenge.www.domain.com   "XKrxpRBosdIKFzxW_CT3KLZNf6q0HG9i01zxXp5CPBs"
dns_arsys_add() {
  fulldomain=$1
  txtvalue=$2

  if [ -z "$ARSYS_API_KEY" ]; then
    ARSYS_API_KEY=""
    _err "You didn't specify the AD api key yet."
    _err "Please create you key and try again."
    return 1
  fi

  _saveaccountconf ARSYS_API_KEY "$ARSYS_API_KEY"

  ARSYS_Zone_ID="${ARSYS_Zone_ID:-$(_readaccountconf_mutable ARSYS_Zone_ID)}"

  _debug "First detect the root zone"
  if ! _get_root "$fulldomain"; then
    _err "invalid domain"
    return 1
  fi

  _debug _sub_domain "$_sub_domain"
  _debug _domain "$_domain"


  _arsys_tmpl_xml="<soapenv:Envelope><soap:Body><CreateDNSEntry xmlns=\"CreateDNSEntry\"><input><dns xsi:type=\"xsd:string\">"$fulldomain"</dns><domain xsi:type=\"xsd:string\">"$_domain"</domain><value xsi:type=\"xsd:string\">"$txtvalue"</value><type xsi:type=\"xsd:string\">TXT</type></input></CreateDNSEntry></soap:Body></soapenv:Envelope>" 
  
  _arsys_rest POST "CreateDNSEntry" "$_arsys_tmpl_xml"
  _debug "response_CreateDNSEntry" "$response"

  # Response must contains  <errorCode xsi:type="xsd:int">0</errorCode>
  if _contains "$response" '<errorCode xsi:type="xsd:int">0</errorCode>'; then
    _info "txt record updated success."
    return 0
  fi

  return 1
}

#Usage: dns_myapi_rm   _acme-challenge.www.domain.com   "XKrxpRBosdIKFzxW_CT3KLZNf6q0HG9i01zxXp5CPBs"
dns_arsys_rm() {
  fulldomain=$1
  txtvalue=$2

  _debug "First detect the root zone"
  if ! _get_root "$fulldomain"; then
    _err "invalid domain"
    return 1
  fi

  _debug _sub_domain "$_sub_domain"
  _debug _domain "$_domain"

  _arsys_tmpl_xml="<soapenv:Envelope><soap:Body><DeleteDNSEntry xmlns=\"DeleteDNSEntry\"><input><dns xsi:type=\"xsd:string\">"$fulldomain"</dns><domain xsi:type=\"xsd:string\">"$_domain"</domain><value xsi:type=\"xsd:string\">"$txtvalue"</value><type xsi:type=\"xsd:string\">TXT</type></input></DeleteDNSEntry></soap:Body></soapenv:Envelope>" 

  _debug "Deleting txt records"
  _arsys_rest POST "DeleteDNSEntry" "$_arsys_tmpl_xml"
  _debug "response_DeleteDNSEntry" "$response"
  
  if _contains "$response" '<errorCode xsi:type="xsd:int">0</errorCode>'; then
    _info "txt record delete success."
    return 0
  fi

  return 1

}

####################  Private functions below ##################################
#_acme-challenge.www.domain.com
#returns
# _sub_domain=_acme-challenge.www
# _domain=domain.com
_get_root() {
  domain=$1
  i=2
  p=1

   ARSYS_Zone_ID="${ARSYS_Zone_ID:-$(_readaccountconf_mutable ARSYS_Zone_ID)}"

   if [ -z "$ARSYS_Zone_ID" ]; then
    ARSYS_Zone_ID=""
    _err "You didn't specify the main domain key."
    _err "Please create your domain key and try again."
    return 1
  fi
  _domain="${ARSYS_Zone_ID:-$(_readaccountconf_mutable ARSYS_Zone_ID)}"
  _sub_domain="$(echo "$domain" | sed 's/.'$_domain'//g')"

}

#method uri qstr data
_arsys_rest() {
  mtd="$1"
  ep="$2"
  data="$3"

  _debug mtd "$mtd"
  _debug ep "$ep"

  export _H1="Content-Type: text/xml" 
  export _H2='SOAPAction: "urn:'$ep'#'$ep'"'
  export _H3="Authorization:Basic "$ARSYS_API_KEY 

  _debug3 Headers "$_H1 $_H2 $_H3"
  
  if [ "$mtd" != "GET" ]; then
    # both POST and DELETE.
    _debug data "$data"
    response="$(_post "$data" "$ARSYS_API_URL" "" "$mtd")"
  else
    response="$(_get "$ARSYS_API_URL/$ep")"
  fi

  if [ "$?" != "0" ]; then
    _err "error $ep"
    return 1
  fi
  _debug2 response "$response"
  return 0
}
