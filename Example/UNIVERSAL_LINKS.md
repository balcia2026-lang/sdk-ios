Universal Links for the Example app
=================================

Steps to test universal-link redirect for `https://localhost:8001/auth/redirect`:

1. Replace `YOUR_TEAM_ID` in `Example/.well-known/apple-app-site-association` with your Apple Team ID (eg `ABCDE12345.com.testpos.sdk.app.v1.0`).

2. Place the AASA file at: `Example/.well-known/apple-app-site-association` (this repo contains an example).

3. Prepare TLS certificate and private key (PEM). If you have a combined file like `cert_key_pem.txt` that contains both key and cert, split them into `key.pem` and `cert.pem` (examples shown below).

PowerShell (Windows) example to split combined file:
```powershell
# Extract cert block(s)
Select-String -Path 'cert_key_pem.txt' -Pattern '-----BEGIN CERTIFICATE-----' -Context 0,200 | ForEach-Object { $_.Line } | Out-File cert.pem -Encoding ascii
# Extract private key block
Select-String -Path 'cert_key_pem.txt' -Pattern '-----BEGIN .*PRIVATE KEY-----' -Context 0,200 | ForEach-Object { $_.Line } | Out-File key.pem -Encoding ascii
```

Unix (awk) example:
```bash
awk '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/ {print}' cert_key_pem.txt > cert.pem
awk '/-----BEGIN .*PRIVATE KEY-----/,/-----END .*PRIVATE KEY-----/ {print}' cert_key_pem.txt > key.pem
```

4. Run the HTTPS AASA server from repository root:
```bash
python3 scripts/serve_aasa.py --cert cert.pem --key key.pem --port 8001
```

5. In Xcode: add `Example/iZettleSDKSample/TESTPOS.entitlements` to the Example app target and ensure the `applinks:` entry matches the host (this repo sets it to `applinks:adnanplus_api2.icloud.com` to match the provided certificate). If you use a different host, update the entitlements accordingly.

Certificate and key files were placed in `scripts/ssl/` as `cert.pem` and `key.pem` for convenience. Do NOT commit production private keys — remove them after testing if needed.

6. Implement `application:continueUserActivity:restorationHandler:` in `AppDelegate` to handle universal-link open if you want link-based callbacks (this sample currently uses `application:openURL:options:` for URL-scheme callbacks).

Notes:
- iOS devices require the AASA host certificate to be trusted by the device. Self-signed certs typically won't work on real devices; use a valid public cert or test via Simulator / private device trust.
- The AASA file must be served over HTTPS at `https://<host>/.well-known/apple-app-site-association` with `Content-Type: application/json` and without redirects.
