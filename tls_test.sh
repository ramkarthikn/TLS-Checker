openssl s_client -connect <I.P> -servername <Domain-name> -tls1_3 </dev/null 2>&1 | grep -E "Protocol|Cipher"
openssl s_client -connect <I.P> -servername <Domain-name> -tls1_2 </dev/null 2>&1 | grep -E "Protocol|Cipher"
openssl s_client -connect <I.P> -servername <Domain-name> -tls1_1 </dev/null 2>&1 | grep -E "Protocol|Cipher"
openssl s_client -connect <I.P> -servername <Domain-name> -tls1 </dev/null 2>&1 | grep -E "Protocol|Cipher"
