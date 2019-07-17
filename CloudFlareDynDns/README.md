CloudFlareDynDns
--------------
Updates specified CloudFlare DNS hostname to the current connection's external IP address using CloudFlare API v4
https://api.cloudflare.com/

This module is useful for homelabs. Remember how DynDns used to dynamically update your IP address for free? The functionality provided by this module is similar but updates CloudFlare hosted domains. CloudFlare is free and awesome, and I recommend it, if even for its simplified DNS management and free HTTPS.

This should be setup as a scheduled task. I set mine for 30 minutes.

#### -Token

CloudFlare API Key.

As of 17 July 2019, you can find your API key at: https://dash.cloudflare.com/ -> <Profile Picture in Top Right> -> My Profile -> API Tokens -> Global API Key

Or if you know your Account.ID value https://dash.cloudflare.com/<Account.ID>/profile/api-tokens -> Global API Key

#### -Email
The email address associated with your CloudFlare account

#### -Zone
The zone you want to modify. For example, netnerds.net

#### -Record
This is the record you'd like to update or add. For example, homelab.

Using -Zone netnerds.net and -Record homelab would update homelab.netnerds.net

#### -UseDns
Resolves hostname using DNS instead of checking CloudFlare. The intention is to reduce the number of calls to CloudFlare (they allow 1,200 reqs every 5 minutes, which is usually plenty), but the downside is that if the IP changes, it won't be updated until the hostname expires from cache.

Do not use if you have DNS Proxy enabled for the record you want to update, otherwise the IP address that is visible will never be your external IP and will always trigger an update.

#### -IPv6
Uses your external IPv6 Address and will update/create an AAAA record rather than the IPv4 A record

Examples
----
```
Update-CloudFlareDynamicDns -Token 1234567893feefc5f0q5000bfo0c38d90bbeb -Email example@example.com -Zone example.com
```

Checks ipv6-test.com for current external IP address. Checks CloudFlare's API for current IP of example.com. (Root Domain)

If record doesn't exist within CloudFlare, it will be created. If record exists, but does not match to current external IP, the record will be updated. If the external IP and the CloudFlare IP match, no changes will be made.


```
Update-CloudFlareDynamicDns -Token 1234567893feefc5f0q5000bfo0c38d90bbeb -Email example@example.com -Zone example.com -Record homelab
```

Checks ipv6-test.com for current external IP address. Checks CloudFlare's API for current IP of homelab.example.com.

If record doesn't exist within CloudFlare, it will be created. If record exists, but does not match to current external IP, the record will be updated. If the external IP and the CloudFlare IP match, no changes will be made.

```
Update-CloudFlareDynamicDns -Token 1234567893feefc5f0q5000bfo0c38d90bbeb -Email example@example.com -Zone example.com -Record homelab -UseDns
```

Checks ipv6-test.com for current external IP address. Checks DNS for current IP of homelab.example.com. Beware of cached entries.

If record doesn't exist within CloudFlare, it will be created. If record exists, but does not match to current external IP, the record will be updated. If the external IP and the CloudFlare IP match, no changes will be made.

```
Update-CloudFlareDynamicDns -Token 1234567893feefc5f0q5000bfo0c38d90bbeb -Email example@example.com -Zone example.com -Record homelab -Ipv6
```

Checks ipv6-test.com for current external IPv6 address. Checks CloudFlare's API for current IPv6 of homelab.example.com.

If record doesn't exist within CloudFlare, it will be created. If record exists, but does not match to current external IPv6, the record will be updated. If the external IPv6 and the CloudFlare IPv6 match, no changes will be made.
