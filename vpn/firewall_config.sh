#!/bin/bash

# ############################################## #
#   Desenvolvido por: Danilo Valle de Oliveira   #
#   SO: Arch Linux                               #
# ############################################## #

# Var: Comandos
CMD_IPTABLES_V6=$(which ip6tables) # caminho do executável do comando iptables
CMD_IPTABLES_V4=$(which iptables)  # caminho do executável do comando iptables
CMD_MODPROBE=$(which modprobe)     # caminho do executável do comamdo modprobe
CMD_SAVE=$(which iptables-save)    # caminho do executável do comamdo iptables-save
CMD_SAVE6=$(which ip6tables-save)    # caminho do executável do comamdo iptables-save

# Var: REDE
INTERFACE_WIFI="wlp3s0"
INTERFACE_LAN="enp2s0"
VPN_INTERFACE_TUN="tun0"

v_IP_HOST_LAN=$(ip -o -4 addr list enp2s0 | awk '{print $4}' | cut -d/ -f1)
v_IP_HOST_WIFI=$(ip -o -4 addr list wlp3s0 | awk '{print $4}' | cut -d/ -f1)

PORTAS_ALTAS=1024:65535
vIP_RANGE_MATRIZ="172.16.200.0/22"
vIP_RANGE_DATACENTER="172.23.12.128/25"
vIP_RANGE_VPN="172.20.200.0/24"
v_IP_LAN_MATRIZ_Dev="172.20.80.0/24"

func_CLEAR_RULES() {
  echo -e "\033[34m Limpando regras existentes ********************* [OK] \033[m "

  $CMD_IPTABLES_V4 -F
  $CMD_IPTABLES_V4 -X
  $CMD_IPTABLES_V4 -t nat -F
  $CMD_IPTABLES_V4 -t nat -X
  $CMD_IPTABLES_V4 -t mangle -F
  $CMD_IPTABLES_V4 -t mangle -X
  $CMD_IPTABLES_V4 -t raw -F
  $CMD_IPTABLES_V4 -t raw -X
  $CMD_IPTABLES_V4 -t security -F
  $CMD_IPTABLES_V4 -t security -X
  $CMD_IPTABLES_V4 -P INPUT ACCEPT
  $CMD_IPTABLES_V4 -P FORWARD ACCEPT
  $CMD_IPTABLES_V4 -P OUTPUT ACCEPT

  $CMD_IPTABLES_V6 -F
  $CMD_IPTABLES_V6 -X
  $CMD_IPTABLES_V6 -t nat -F
  $CMD_IPTABLES_V6 -t nat -X
  $CMD_IPTABLES_V6 -t mangle -F
  $CMD_IPTABLES_V6 -t mangle -X
  $CMD_IPTABLES_V6 -t raw -F
  $CMD_IPTABLES_V6 -t raw -X
  $CMD_IPTABLES_V6 -t security -F
  $CMD_IPTABLES_V6 -t security -X
  $CMD_IPTABLES_V6 -P INPUT ACCEPT
  $CMD_IPTABLES_V6 -P FORWARD ACCEPT
  $CMD_IPTABLES_V6 -P OUTPUT ACCEPT  
}

func_MODPROBE() {
  echo -e "\033[34m Caregando módulos necessarios ****************** [OK] \033[m "
  $CMD_MODPROBE iptable_nat
  $CMD_MODPROBE ip_conntrack_ftp
  $CMD_MODPROBE ip_nat_ftp
  $CMD_MODPROBE ip_conntrack
  $CMD_MODPROBE ip_conntrack_irc
  $CMD_MODPROBE ip_nat_irc
  $CMD_MODPROBE ipt_state
  $CMD_MODPROBE ip_tables
  $CMD_MODPROBE ipt_REDIRECT
  $CMD_MODPROBE ipt_LOG
  $CMD_MODPROBE ipt_REJECT
  $CMD_MODPROBE ipt_MASQUERADE
  $CMD_MODPROBE ipt_limit

  # Desabilitando roteamento entre as placas
  ip_forward=$(cat /proc/sys/net/ipv4/ip_forward)
  if [ $ip_forward -eq 1 ]; then
    echo "0" > /proc/sys/net/ipv4/ip_forward
  fi

  #Setting up default kernel tunings here (don't worry too much about these right now, they are acceptable defaults) #DROP ICMP echo-requests sent to broadcast/multi-cast addresses.
  ip_forward=$(cat /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts)
  if [ $ip_forward -eq 0 ]; then
    echo "1" > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
  fi

  #DROP source routed packets
  ip_forward=$(cat /proc/sys/net/ipv4/conf/all/accept_source_route)
  if [ $ip_forward -eq 1 ]; then
    echo "0" > /proc/sys/net/ipv4/conf/all/accept_source_route
  fi

  #Enable TCP SYN cookies
  ip_forward=$(cat /proc/sys/net/ipv4/tcp_syncookies)
  if [ $ip_forward -eq 0 ]; then
    echo "1" > /proc/sys/net/ipv4/tcp_syncookies
  fi

  #Do not ACCEPT ICMP redirect
  ip_forward=$(cat /proc/sys/net/ipv4/conf/all/accept_redirects)
  if [ $ip_forward -eq 1 ]; then
    echo "0" > /proc/sys/net/ipv4/conf/all/accept_redirects
  fi

  #Don't send ICMP redirect
  ip_forward=$(cat /proc/sys/net/ipv4/conf/all/send_redirects)
  if [ $ip_forward -eq 1 ]; then
    echo "0" > /proc/sys/net/ipv4/conf/all/send_redirects
  fi
  #Enable source spoofing protection
  ip_forward=$(cat /proc/sys/net/ipv4/conf/all/rp_filter)
  if [ $ip_forward -eq 0 ]; then
    echo "1" > /proc/sys/net/ipv4/conf/all/rp_filter
  fi
  #Log impossible (martian) packets
  ip_forward=$(cat /proc/sys/net/ipv4/conf/all/log_martians)
  if [ $ip_forward -eq 0 ]; then
    echo "1" > /proc/sys/net/ipv4/conf/all/log_martians
  fi

}

func_POLICY_ACCEPT() {
  echo -e "\033[34m Criando uma politica padrão ACCEPT ************* [OK] \033[m "

  $CMD_IPTABLES_V4 -P INPUT ACCEPT
  $CMD_IPTABLES_V4 -P OUTPUT ACCEPT
  $CMD_IPTABLES_V4 -P FORWARD ACCEPT

  $CMD_IPTABLES_V6 -P INPUT ACCEPT
  $CMD_IPTABLES_V6 -P OUTPUT ACCEPT
  $CMD_IPTABLES_V6 -P FORWARD ACCEPT
}

func_POLICY_DROP() {
  echo -e "\033[34m Criando uma politica padrão DROP *************** [OK] \033[m "
  $CMD_IPTABLES_V4 -P INPUT DROP
  $CMD_IPTABLES_V4 -P OUTPUT DROP
  $CMD_IPTABLES_V4 -P FORWARD DROP

  $CMD_IPTABLES_V6 -P INPUT DROP
  $CMD_IPTABLES_V6 -P OUTPUT DROP
  $CMD_IPTABLES_V6 -P FORWARD DROP
}

func_POLICY_DROP_V6() {
  echo -e "\033[34m Criando uma politica padrão DROP IP V6 ********* [OK] \033[m "
  $CMD_IPTABLES_V6 -F
  $CMD_IPTABLES_V6 -X
  $CMD_IPTABLES_V6 -t nat -F
  $CMD_IPTABLES_V6 -t nat -X
  $CMD_IPTABLES_V6 -t mangle -F
  $CMD_IPTABLES_V6 -t mangle -X
  $CMD_IPTABLES_V6 -t raw -F
  $CMD_IPTABLES_V6 -t raw -X
  $CMD_IPTABLES_V6 -t security -F
  $CMD_IPTABLES_V6 -t security -X

  $CMD_IPTABLES_V6 -P INPUT DROP
  $CMD_IPTABLES_V6 -P OUTPUT DROP
  $CMD_IPTABLES_V6 -P FORWARD DROP
}

func_ENABLEVPN_V4() {
  echo -e "\033[34m Habilitar VPN IPv4 ***************************** [OK] \033[m "

  $CMD_IPTABLES_V4 -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
  $CMD_IPTABLES_V4 -A OUTPUT -d $vIP_RANGE_MATRIZ -p udp --dport 1194 -j ACCEPT

  $CMD_IPTABLES_V4 -t mangle -A PREROUTING -i $INTERFACE_WIFI -p esp -j MARK --set-mark 1
  $CMD_IPTABLES_V4 -t mangle -A PREROUTING -i $INTERFACE_LAN -p esp -j MARK --set-mark 1

  $CMD_IPTABLES_V4 -t nat -A PREROUTING -s $vIP_RANGE_MATRIZ -i $INTERFACE_WIFI -m mark --mark 1 -j ACCEPT
  $CMD_IPTABLES_V4 -t nat -A PREROUTING -s $vIP_RANGE_MATRIZ -i $INTERFACE_LAN -m mark --mark 1 -j ACCEPT

  $CMD_IPTABLES_V4 -t nat -A PREROUTING -s $vIP_RANGE_DATACENTER -i $INTERFACE_WIFI -m mark --mark 1 -j ACCEPT
  $CMD_IPTABLES_V4 -t nat -A PREROUTING -s $vIP_RANGE_DATACENTER -i $INTERFACE_LAN -m mark --mark 1 -j ACCEPT

  $CMD_IPTABLES_V4 -t nat -A PREROUTING -s $vIP_RANGE_VPN -i $INTERFACE_WIFI -m mark --mark 1 -j ACCEPT
  $CMD_IPTABLES_V4 -t nat -A PREROUTING -s $vIP_RANGE_VPN -i $INTERFACE_LAN -m mark --mark 1 -j ACCEPT

  $CMD_IPTABLES_V4 -t nat -A POSTROUTING -s $vIP_RANGE_VPN -o $INTERFACE_WIFI -j MASQUERADE
  $CMD_IPTABLES_V4 -t nat -A POSTROUTING -s $vIP_RANGE_VPN -o $INTERFACE_LAN -j MASQUERADE

  $CMD_IPTABLES_V4 -t nat -A POSTROUTING -s $vIP_RANGE_MATRIZ -o $INTERFACE_WIFI -j MASQUERADE
  $CMD_IPTABLES_V4 -t nat -A POSTROUTING -s $vIP_RANGE_MATRIZ -o $INTERFACE_LAN -j MASQUERADE

  $CMD_IPTABLES_V4 -t nat -A POSTROUTING -s $vIP_RANGE_DATACENTER -o $INTERFACE_WIFI -j MASQUERADE
  $CMD_IPTABLES_V4 -t nat -A POSTROUTING -s $vIP_RANGE_DATACENTER -o $INTERFACE_LAN -j MASQUERADE

  # Enable NAT
  $CMD_IPTABLES_V4 -t nat -A POSTROUTING -o $VPN_INTERFACE_TUN -j MASQUERADE
  $CMD_IPTABLES_V4 -t nat -A POSTROUTING -o $INTERFACE_WIFI -j MASQUERADE # Needed to SSH to VPN server
  $CMD_IPTABLES_V4 -t nat -A POSTROUTING -o $INTERFACE_LAN -j MASQUERADE  # Needed to SSH to VPN server
  $CMD_IPTABLES_V4 -t nat -A PREROUTING -m state --state RELATED,ESTABLISHED -j ACCEPT

  # Allow SSH to the VPN server itself
  $CMD_IPTABLES_V4 -A FORWARD -o $INTERFACE_WIFI -d $vIP_RANGE_VPN --protocol tcp --dport 22 -j ACCEPT
  $CMD_IPTABLES_V4 -A FORWARD -i $INTERFACE_WIFI -s $vIP_RANGE_VPN --protocol tcp --sport 22 -j ACCEPT
  $CMD_IPTABLES_V4 -A FORWARD -o $INTERFACE_LAN -d $vIP_RANGE_VPN --protocol tcp --dport 22 -j ACCEPT
  $CMD_IPTABLES_V4 -A FORWARD -i $INTERFACE_LAN -s $vIP_RANGE_VPN --protocol tcp --sport 22 -j ACCEPT

  # Allow VPN traffic
  $CMD_IPTABLES_V4 -A FORWARD -i $VPN_INTERFACE_TUN -j ACCEPT
  $CMD_IPTABLES_V4 -A FORWARD -i $VPN_INTERFACE_TUN -o $INTERFACE_LAN -m state --state RELATED,ESTABLISHED -j ACCEPT
  $CMD_IPTABLES_V4 -A FORWARD -i $INTERFACE_LAN -o $VPN_INTERFACE_TUN -m state --state RELATED,ESTABLISHED -j ACCEPT
  $CMD_IPTABLES_V4 -A FORWARD -i $INTERFACE_LAN -d $vIP_RANGE_VPN --protocol udp --dport 1194 -o $VPN_INTERFACE_TUN -j ACCEPT
  $CMD_IPTABLES_V4 -A FORWARD -i $VPN_INTERFACE_TUN -s $vIP_RANGE_VPN --protocol udp --sport 1194 -o $INTERFACE_LAN -j ACCEPT

  # Allow VPN client to connect to VPN server
  $CMD_IPTABLES_V4 -A OUTPUT -o $INTERFACE_WIFI -d $vIP_RANGE_VPN --protocol udp --dport 1194 -j ACCEPT
  $CMD_IPTABLES_V4 -A OUTPUT -o $INTERFACE_LAN -d $vIP_RANGE_VPN --protocol udp --dport 1194 -j ACCEPT
  $CMD_IPTABLES_V4 -A OUTPUT -o $VPN_INTERFACE_TUN -j ACCEPT

}

func_ENABLEVPN_V6() {
  echo -e "\033[34m Habilitar VPN IPv6 ***************************** [OK] \033[m "

  $CMD_IPTABLES_V6 -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
  $CMD_IPTABLES_V6 -A OUTPUT -p udp --dport 1194 -j ACCEPT
  $CMD_IPTABLES_V6 -t mangle -A PREROUTING -i $INTERFACE_WIFI -p esp -j MARK --set-mark 1
  $CMD_IPTABLES_V6 -t mangle -A PREROUTING -i $INTERFACE_LAN -p esp -j MARK --set-mark 1
  $CMD_IPTABLES_V6 -t nat -A POSTROUTING -o $VPN_INTERFACE_TUN -j MASQUERADE
  $CMD_IPTABLES_V6 -t nat -A POSTROUTING -o $INTERFACE_WIFI -j MASQUERADE # Needed to SSH to VPN server
  $CMD_IPTABLES_V6 -t nat -A POSTROUTING -o $INTERFACE_LAN -j MASQUERADE  # Needed to SSH to VPN server
  $CMD_IPTABLES_V6 -t nat -A PREROUTING -m state --state RELATED,ESTABLISHED -j ACCEPT
  $CMD_IPTABLES_V6 -A FORWARD -i $VPN_INTERFACE_TUN -j ACCEPT
  $CMD_IPTABLES_V6 -A FORWARD -i $VPN_INTERFACE_TUN -o $INTERFACE_LAN -m state --state RELATED,ESTABLISHED -j ACCEPT
  $CMD_IPTABLES_V6 -A FORWARD -i $INTERFACE_LAN -o $VPN_INTERFACE_TUN -m state --state RELATED,ESTABLISHED -j ACCEPT
  $CMD_IPTABLES_V6 -A OUTPUT -o $VPN_INTERFACE_TUN -j ACCEPT
}

func_HOST_PING() {
  echo -e "\033[34m Liberando PING ********************************* [OK] \033[m "
  $CMD_IPTABLES_V4 -A OUTPUT -p icmp --icmp-type 8 -o $INTERFACE_WIFI -j ACCEPT
  $CMD_IPTABLES_V4 -A OUTPUT -p icmp --icmp-type 8 -o $INTERFACE_LAN -j ACCEPT  
}

func_HOST_FTP() {
  echo -e "\033[34m Liberando FTP ********************************** [OK] \033[m "
  $CMD_IPTABLES_V4 -A OUTPUT -p tcp -o $INTERFACE_WIFI --sport $PORTAS_ALTAS --dport 21 -j ACCEPT
  $CMD_IPTABLES_V4 -A OUTPUT -p tcp -o $INTERFACE_LAN --sport $PORTAS_ALTAS --dport 21 -j ACCEPT  
  $CMD_IPTABLES_V4 -A INPUT -p tcp --sport 21 -i $INTERFACE_WIFI -j DROP
  $CMD_IPTABLES_V4 -A INPUT -p tcp --sport 21 -i $INTERFACE_LAN -j DROP 
  $CMD_IPTABLES_V6 -A INPUT -p tcp --sport 21 -i $INTERFACE_WIFI -j DROP
  $CMD_IPTABLES_V6 -A INPUT -p tcp --sport 21 -i $INTERFACE_LAN -j DROP    
}


func_ESTABILIZA_CONEXOES() {
  echo -e "\033[34m ESTABILIZA CONEXOES **************************** [OK] \033[m "
  $CMD_IPTABLES_V4 -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
  $CMD_IPTABLES_V4 -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
  $CMD_IPTABLES_V4 -A INPUT -i lo -p all -j ACCEPT
  $CMD_IPTABLES_V4 -A OUTPUT -o lo -p all -j ACCEPT
  $CMD_IPTABLES_V4 -A INPUT -p tcp -m tcp --tcp-flags RST RST -m limit --limit 2/second --limit-burst 2 -j ACCEPT

  $CMD_IPTABLES_V6 -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
  $CMD_IPTABLES_V6 -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
  $CMD_IPTABLES_V6 -A INPUT -i lo -p all -j ACCEPT
  $CMD_IPTABLES_V6 -A OUTPUT -o lo -p all -j ACCEPT
  $CMD_IPTABLES_V6 -A INPUT -p tcp -m tcp --tcp-flags RST RST -m limit --limit 2/second --limit-burst 2 -j ACCEPT  
}

func_PROTECTPORTSCAN_V4() {
  echo -e "\033[34m Protecting portscans *************************** [OK] \033[m "
  # Attacking IP will be locked for 24 hours (3600 x 24 = 86400 Seconds)
  $CMD_IPTABLES_V4 -A INPUT -m recent --name portscan --rcheck --seconds 86400 -j DROP
  $CMD_IPTABLES_V4 -A FORWARD -m recent --name portscan --rcheck --seconds 86400 -j DROP

  # Remove attacking IP after 24 hours
  $CMD_IPTABLES_V4 -A INPUT -m recent --name portscan --remove
  $CMD_IPTABLES_V4 -A FORWARD -m recent --name portscan --remove

  # These rules add scanners to the portscan list, and log the attempt.
  # $CMD_IPTABLES_V4 -A INPUT -p tcp -m tcp --dport 139 -m recent --name portscan --set -j LOG --log-prefix "portscan:"
  $CMD_IPTABLES_V4 -A INPUT -p tcp -m tcp --dport 139 -m recent --name portscan --set -j DROP

  # $CMD_IPTABLES_V4 -A FORWARD -p tcp -m tcp --dport 139 -m recent --name portscan --set -j LOG --log-prefix "portscan:"
  $CMD_IPTABLES_V4 -A FORWARD -p tcp -m tcp --dport 139 -m recent --name portscan --set -j DROP
}

func_PROTECTPORTSCAN_V6() {
  echo -e "\033[34m Protecting portscans *************************** [OK] \033[m "
  $CMD_IPTABLES_V6 -A INPUT -m recent --name portscan --rcheck --seconds 86400 -j DROP
  $CMD_IPTABLES_V6 -A FORWARD -m recent --name portscan --rcheck --seconds 86400 -j DROP
  $CMD_IPTABLES_V6 -A INPUT -m recent --name portscan --remove
  $CMD_IPTABLES_V6 -A FORWARD -m recent --name portscan --remove
  $CMD_IPTABLES_V6 -A INPUT -p tcp -m tcp --dport 139 -m recent --name portscan --set -j DROP
  $CMD_IPTABLES_V6 -A FORWARD -p tcp -m tcp --dport 139 -m recent --name portscan --set -j DROP
}

func_INVALID_INPUT_DROP() {
  $CMD_IPTABLES_V4 -A INPUT -m state --state INVALID -j DROP
  $CMD_IPTABLES_V4 -A OUTPUT -m state --state INVALID -j DROP
  $CMD_IPTABLES_V4 -A FORWARD -m state --state INVALID -j DROP

  $CMD_IPTABLES_V6 -A INPUT -m state --state INVALID -j DROP
  $CMD_IPTABLES_V6 -A OUTPUT -m state --state INVALID -j DROP
  $CMD_IPTABLES_V6 -A FORWARD -m state --state INVALID -j DROP  
}

func_ATIVA_LOG() {
  echo -e "\033[34m ATIVANDO LOG *********************************** [OK] \033[m "
  $CMD_IPTABLES_V4 -A OUTPUT -j LOG --log-level 6 --log-prefix "<<fw-output>>: "
  $CMD_IPTABLES_V4 -A INPUT -j LOG --log-level 6 --log-prefix "<<fw-input>>: "
  $CMD_IPTABLES_V4 -A FORWARD -j LOG --log-level 6 --log-prefix "<<fw-forward>>: "
}

func_DESATIVA_LOG() {
  echo -e "\033[34m DESATIVANDO LOG ******************************** [OK] \033[m "
  $CMD_IPTABLES_V4 -D OUTPUT -j LOG --log-level 6 --log-prefix "<<fw-output>>: "
  $CMD_IPTABLES_V4 -D INPUT -j LOG --log-level 6 --log-prefix "<<fw-input>>: "
  $CMD_IPTABLES_V4 -D FORWARD -j LOG --log-level 6 --log-prefix "<<fw-forward>>: "
}

func_PCT_FRAGMENTADOS() {
  echo -e "\033[34m BLOQUEANDO pacotes fragmentados***************** [OK] \033[m "
  $CMD_IPTABLES_V4 -A INPUT -i $INTERFACE_WIFI -f -j DROP
}

func_IPSPOOFING() {
  echo -e "\033[34m BLOQUEANDO IP SPOOFING************************** [OK] \033[m "
  $CMD_IPTABLES_V4 -A INPUT -s 224.0.0.0/4 -j DROP
  $CMD_IPTABLES_V4 -A INPUT -s 240.0.0.0/5 -j DROP
  $CMD_IPTABLES_V4 -A INPUT -s 10.0.0.0/8 -j DROP
  $CMD_IPTABLES_V4 -A INPUT -s 169.254.0.0/16 -j DROP
  $CMD_IPTABLES_V4 -A INPUT -s 172.16.0.0/12 -j DROP
  $CMD_IPTABLES_V4 -A INPUT -s 127.0.0.0/8 -j DROP
  $CMD_IPTABLES_V4 -A INPUT -s 192.168.0.0/16 -j DROP
  $CMD_IPTABLES_V4 -A INPUT -d 224.0.0.0/4 -j DROP
  $CMD_IPTABLES_V4 -A INPUT -d 240.0.0.0/5 -j DROP
  $CMD_IPTABLES_V4 -A INPUT -s 0.0.0.0/8 -j DROP
  $CMD_IPTABLES_V4 -A INPUT -d 0.0.0.0/8 -j DROP
  $CMD_IPTABLES_V4 -A INPUT -d 239.255.255.0/24 -j DROP
  $CMD_IPTABLES_V4 -A INPUT -d 255.255.255.255 -j DROP
}

func_SmurfProtection() {
  echo -e "\033[34m For SMURF attack protection********************* [OK] \033[m "
  $CMD_IPTABLES_V4 -A INPUT -p icmp -m icmp --icmp-type address-mask-request -j DROP
  $CMD_IPTABLES_V4 -A INPUT -p icmp -m icmp --icmp-type timestamp-request -j DROP
}

func_OUTPUTCHAIN_ALLOW_V4() {
  echo -e "\033[34m Enable Output ********************************** [OK] \033[m "
  $CMD_IPTABLES_V4 -A OUTPUT -p tcp -m tcp --dport 22 -m comment --comment "SSH" -j ACCEPT
  $CMD_IPTABLES_V4 -A OUTPUT -p tcp -m tcp --dport 25 -m comment --comment "Email" -j ACCEPT
  $CMD_IPTABLES_V4 -A OUTPUT -p tcp -m tcp --dport 53 -m comment --comment "DNS-TCP" -j ACCEPT
  $CMD_IPTABLES_V4 -A OUTPUT -p udp -m udp --dport 53 -m comment --comment "DNS-UDP" -j ACCEPT
  $CMD_IPTABLES_V4 -A OUTPUT -p udp -m udp --dport 67:68 -m comment --comment "DHCP" -j ACCEPT
  $CMD_IPTABLES_V4 -A OUTPUT -p tcp -m tcp --dport 80 -m comment --comment "HTTP" -j ACCEPT
  $CMD_IPTABLES_V4 -A OUTPUT -p tcp -m tcp --dport 443 -m comment --comment "HTTPS 443" -j ACCEPT
  $CMD_IPTABLES_V4 -A OUTPUT -p tcp -m tcp --dport 8443 -m comment --comment "HTTPS 8443" -j ACCEPT  
  $CMD_IPTABLES_V4 -A OUTPUT -p tcp -m tcp --dport 465 -m comment --comment "SMTPS" -j ACCEPT
  $CMD_IPTABLES_V4 -A OUTPUT -p tcp -m tcp --dport 587 -m comment --comment "SMTPS" -j ACCEPT
  $CMD_IPTABLES_V4 -A OUTPUT -p tcp -m tcp --dport 993 -m comment --comment "IMAPS" -j ACCEPT
  $CMD_IPTABLES_V4 -A OUTPUT -p tcp -m tcp --dport 8001 -m comment --comment "IRC" -j ACCEPT
  $CMD_IPTABLES_V4 -A OUTPUT -p tcp -m tcp --dport 1433 -m comment --comment "SQL Server" -j ACCEPT
  $CMD_IPTABLES_V4 -A OUTPUT -p tcp -m tcp --dport 3306 -m comment --comment "MySql Server" -j ACCEPT
  $CMD_IPTABLES_V4 -A OUTPUT -p tcp -m tcp --dport 5432 -m comment --comment "PostGreSQL" -j ACCEPT
  $CMD_IPTABLES_V4 -A OUTPUT -p tcp -m tcp --dport 25432 -m comment --comment "PostGreSQL" -j ACCEPT
  $CMD_IPTABLES_V4 -A OUTPUT -p tcp -m tcp --dport 9200 -m comment --comment "Elastic 1" -j ACCEPT
  $CMD_IPTABLES_V4 -A OUTPUT -p tcp -m tcp --dport 9201 -m comment --comment "Elastic 2" -j ACCEPT
  $CMD_IPTABLES_V4 -A OUTPUT -p tcp -m tcp --dport 9202 -m comment --comment "Elastic 3" -j ACCEPT
  $CMD_IPTABLES_V4 -A OUTPUT -p tcp -m tcp --dport 26379 -m comment --comment "RedisSentinel" -j ACCEPT
  $CMD_IPTABLES_V4 -A OUTPUT -p tcp -m tcp --dport 6379 -m comment --comment "Redis" -j ACCEPT
}

func_OUTPUTCHAIN_ALLOW_V6() {
  echo -e "\033[34m Enable Output ********************************** [OK] \033[m "
  $CMD_IPTABLES_V6 -A OUTPUT -p tcp -m tcp --dport 22 -m comment --comment "SSH" -j ACCEPT
  $CMD_IPTABLES_V6 -A OUTPUT -p tcp -m tcp --dport 25 -m comment --comment "Email" -j ACCEPT
  $CMD_IPTABLES_V6 -A OUTPUT -p tcp -m tcp --dport 53 -m comment --comment "DNS-TCP" -j ACCEPT
  $CMD_IPTABLES_V6 -A OUTPUT -p udp -m udp --dport 53 -m comment --comment "DNS-UDP" -j ACCEPT
  $CMD_IPTABLES_V6 -A OUTPUT -p udp -m udp --dport 67:68 -m comment --comment "DHCP" -j ACCEPT
  $CMD_IPTABLES_V6 -A OUTPUT -p tcp -m tcp --dport 80 -m comment --comment "HTTP" -j ACCEPT
  $CMD_IPTABLES_V6 -A OUTPUT -p tcp -m tcp --dport 443 -m comment --comment "HTTPS 443" -j ACCEPT
  $CMD_IPTABLES_V6 -A OUTPUT -p tcp -m tcp --dport 8443 -m comment --comment "HTTPS 8443" -j ACCEPT  
  $CMD_IPTABLES_V6 -A OUTPUT -p tcp -m tcp --dport 465 -m comment --comment "SMTPS" -j ACCEPT
  $CMD_IPTABLES_V6 -A OUTPUT -p tcp -m tcp --dport 587 -m comment --comment "SMTPS" -j ACCEPT
  $CMD_IPTABLES_V6 -A OUTPUT -p tcp -m tcp --dport 993 -m comment --comment "IMAPS" -j ACCEPT
  $CMD_IPTABLES_V6 -A OUTPUT -p tcp -m tcp --dport 8001 -m comment --comment "IRC" -j ACCEPT
  $CMD_IPTABLES_V6 -A OUTPUT -p tcp -m tcp --dport 1433 -m comment --comment "SQL Server" -j ACCEPT
  $CMD_IPTABLES_V6 -A OUTPUT -p tcp -m tcp --dport 3306 -m comment --comment "MySql Server" -j ACCEPT
  $CMD_IPTABLES_V6 -A OUTPUT -p tcp -m tcp --dport 5432 -m comment --comment "PostGreSQL" -j ACCEPT
  $CMD_IPTABLES_V6 -A OUTPUT -p tcp -m tcp --dport 25432 -m comment --comment "PostGreSQL" -j ACCEPT
  $CMD_IPTABLES_V6 -A OUTPUT -p tcp -m tcp --dport 9200 -m comment --comment "Elastic 1" -j ACCEPT
  $CMD_IPTABLES_V6 -A OUTPUT -p tcp -m tcp --dport 9201 -m comment --comment "Elastic 2" -j ACCEPT
  $CMD_IPTABLES_V6 -A OUTPUT -p tcp -m tcp --dport 9202 -m comment --comment "Elastic 3" -j ACCEPT
  $CMD_IPTABLES_V6 -A OUTPUT -p tcp -m tcp --dport 26379 -m comment --comment "RedisSentinel" -j ACCEPT
  $CMD_IPTABLES_V6 -A OUTPUT -p tcp -m tcp --dport 6379 -m comment --comment "Redis" -j ACCEPT
}

func_NTPCHAIN_ALLOW() {
  echo -e "\033[34m NTP CHAIN ************************************** [OK] \033[m "

  $CMD_IPTABLES_V4 -A OUTPUT -p udp --dport 123 -j ACCEPT
  $CMD_IPTABLES_V4 -A INPUT -p udp --sport 123 -j ACCEPT

  $CMD_IPTABLES_V6 -A OUTPUT -p udp --dport 123 -j ACCEPT
  $CMD_IPTABLES_V6 -A INPUT -p udp --sport 123 -j ACCEPT  
}

func_SAVEALL() {
  echo -e "\033[34m GRAVANDO ALTERACOES **************************** [OK] \033[m "
  $CMD_SAVE -f /etc/iptables/iptables.rules
  $CMD_SAVE6 -f /etc/iptables/ip6tables.rules
  #  iptables -nvL --line-numbers
  #  ip6tables -nvL --line-numbers
}

case $1 in
stop)
  func_CLEAR_RULES
  func_MODPROBE
  func_POLICY_ACCEPT
  echo -e "\033[31m FIREWALL DESATIVADO **************************** [OK] \033[m "
  ;;
start)
  echo -e "\033[34m INICIANDO FIREWALL ***************************** [OK] \033[m "
  func_CLEAR_RULES
  func_MODPROBE
  func_POLICY_DROP
  func_ESTABILIZA_CONEXOES
  func_OUTPUTCHAIN_ALLOW_V4
  func_OUTPUTCHAIN_ALLOW_V6
  func_HOST_PING
  func_HOST_FTP
  func_ENABLEVPN_V4
  func_ENABLEVPN_V6
  func_NTPCHAIN_ALLOW    
  func_PCT_FRAGMENTADOS
  func_IPSPOOFING
  func_SmurfProtection
  func_PROTECTPORTSCAN_V4
  func_PROTECTPORTSCAN_V6
  func_INVALID_INPUT_DROP
  func_POLICY_DROP_V6
  func_SAVEALL

  echo -e "\033[32m FIREWALL ATIVADO ******************************* [OK] \033[m "

  ;;
restart)
  $0 stop
  $0 start
  ;;
--enable-log)
  func_ATIVA_LOG
  echo -e "\033[34m LOG ATIVADO ************************************ [OK] \033[m "
  ;;
--desable-log)
  func_DESATIVA_LOG
  echo -e "\033[31m LOG DESATIVADO ********************************* [OK] \033[m "
  ;;
--list)
  clear
  iptables -nL -v --line-number
  ;;
--list-nat)
  clear
  iptables -nL -v --line-number -t nat
  ;;
--list-mangle)
  clear
  iptables -nL -v --line-number -t mangle
  ;;

*)
  echo -e "\033[31m ERRO !!! ************************************* [fail] \033[m "
  echo -e "\033[31m Use $0 [stop|start|restart] ****************** [fail] \033[m "
  ;;
esac
