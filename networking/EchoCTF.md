# EchoCTF Network Challenges Report

**Name:** <Joel Nartey Annan>
**Index Number:** <7352323>
**Date:** <21/09/2026>
**EchoCTF Profile/Username:** <GODISTHEGREATEST>

---

## Challenge: bender

- **Tool(s) Used:** < A web browser (Safari) and safari's built-in Web inspector >
- **Steps:**
  1. < 1.Connected to the EchoCTF VPN and visited http://10.0.41.1:1337/
2.Viewed the page's HTML source via Safari's Web Inspector — found no hidden comments on the main page
3.Noticed a deliberate typo on the page ("robots ash" instead of the expected phrase) as a hint pointing to robots.txt
4.Visited http://10.0.41.1:1337/robots.txt directly
5.Found the first flag in a comment line, and also found a Disallow: /nogooglebot/ entry — a second hint pointing to a hidden path
6.Visited http://10.0.41.1:1337/nogooglebot/, which displayed a page saying "Look closer..." — indicating the second flag is likely hidden in this page's source (still in progress >
- **Flag / Result Obtained:** <flag 1   ETSCTF_ae1764e05e046f3770ac7b396c4ab0a2  flag 2  ETSCTF_e79422930da899e5634d7f9da9c601a2 >
- **Evidence:** <  mv ~/Downloads/"Screenshot 2026-09-21 at 1.13.12 PM.png" networking/evidence/bender.png >

---

## Challenge: headoffice

(     *Tool(s) Used:* < 'curl' HTTP CLI client >
•⁠  ⁠*Steps:*
  1. < 1. Connected to the echoCTF network via OpenVPN.
2. Executed an HTTP `HEAD` request to inspect response headers without requesting the response body:
   ```bash
   curl -I [http://10.0.41.4:1337/](http://10.0.41.4:1337/) >
•⁠  ⁠*Flag / Result Obtained:* <flag 1 ETSCTF_764762092a32a29c2694d8c67209e5ce  flag 2 ETSCTF_138cdb84157cf6e761c48072d034d4d0 >
•⁠  ⁠*Evidence:* < mv ~/Downloads/headoffice.png networking/evidence/headoffice.png >

---

## Challenge: hostel

( *Tool(s) Used:* <'curl' HTTP CLI client >
•⁠  ⁠*Steps:*
  1. < 1. Connected to the echoCTF network via OpenVPN.
2. Sent a request to the target web server with a custom Host header to bypass virtual host restrictions:
   ```bash
   curl -H "Host: hostel" [http://10.0.41.5:1337/](http://10.0.41.5:1337/)  >
 
•⁠  ⁠*Flag / Result Obtained:* < flag ETSCTF_283364c182f1f502b52dad45fef141dc  >
•⁠  ⁠*Evidence:* < mv ~/Downloads/hostel.png networking/evidence/hostel.png  >    

---

## Challenge: idiotr

( *Tool(s) Used:* <'curl' HTTP CLI client/ Safari Web inspector >
•⁠  ⁠*Steps:*
  1. < 1. Connected to the echoCTF network via OpenVPN.
2. Navigated to the home page at `http://10.0.41.2:1337/` and inspected the DOM source code.
3. Identified a hidden navigation bar link pointing to a query parameter endpoint (`/?id=4` titled "Secret"):
   ```bash
   curl [http://10.0.41.2:1337/?id=4](http://10.0.41.2:1337/?id=4)  >
  2. <...>
•⁠  ⁠*Flag / Result Obtained:* <flag 1 ETSCTF_764762092a32a29c2694d8c67209e5ce >
•⁠  ⁠*Evidence:* < mv ~/Downloads/idiotr.png networking/evidence/idiotr.png >

---

## Challenge: argonauts

( ### 1. Tools Used
* `curl` (HTTP CLI client) / Browser Developer Tools

### 2. Key Commands & Steps
1. Connected to the echoCTF network via OpenVPN.
2. Navigated to the web service for the `argonauts` challenge.
3. Inspected the application responses, HTTP headers, and client-side source files to locate the flag.
   ```bash  curl [http://10.0.41.](http://10.0.41.)x:1337/
•⁠  ⁠*Flag / Result Obtained:* <flag 1 TSCTF_f6790962f2546af47505b6c21b00e624 flag ETSCTF_7c59a2421f94a24cbd084c046d273b3e flag 3 ETSCTF_144e0d1eb30a6b2ce3093b8319e2017a  >
•⁠  ⁠*Evidence:* < mv ~/Downloads/argonauts.png networking/evidence/argonauts.png >

 )

---

## Challenge: getip

(1. Tools Used
* `curl` (HTTP CLI client) / Browser Developer Tools

### 2. Key Commands & Steps
1. Connected to the echoCTF network via OpenVPN.
2. Interacted with the `getip` web service to inspect client network detection parameters (e.g., standard HTTP headers like `X-Forwarded-For` or `Client-IP`).
   ```bash
   curl -H "X-Forwarded-For: 127.0.0.1" [http://10.0.41.](http://10.0.41.)x:1337/  )
•⁠  ⁠*Flag / Result Obtained:* <ETSCTF_5fb2e42ab9fae6de704a818e3ce92226 >
•⁠  ⁠*Evidence:* < mv ~/Downloads/getip.png networking/evidence/getip.png >
