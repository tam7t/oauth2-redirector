# oauth2-redirector
Utility for testing OAuth2 CSRF vulnerabilities

The OAuth2 specification lists the `state` parameter as optional even though it
is an important protection against Cross Site Forgery Requests. This has been
known for [a long time](http://homakov.blogspot.com/2012/07/saferweb-most-common-oauth2.html)
but is an easy mistake to make when integrating OAuth without a library. This
lead to a Vimeo [account takeover](https://tam7t.com/vimeo-account-takeover/)
vulnerability in Feb 2015.

This project sets up a server that helps automate testing of this vulnerability.
The `redirect.rb` server responds to HTTP requests by opening Firefox, logging
into Facebook, and attempting to authorize a given application (`CONNECT_URI`).
Once authorized, the script will intercept Facebook's redirect and respond to
the original HTTP request with a redirect to the URL from Facebook.

This helps remove many of the repetative steps of testing for OAuth CSRF
vulnerabilities and provides a nice starting point for developing a proof of
concept exploit.

This project relies on the [noredirect](http://code.kliu.org/noredirect/)
Firefox extension to manually step through 302 redirects.

# Usage
The following environment variables must be set:
* `CONNECT_URI` The facebook connect URI
* `REDIRECT_URI` The URI to block and reflect back to victim
* `FB_USER` The attacker's facebook username
* `FB_PASS` The attacker's facebook password

```bash
CONNECT_URI='https://www.facebook.com/v2.1/dialog/oauth?client_id=19884028963&redirect_uri=https%3A%2F%2Fvimeo.com%2Fsettings%2Fapps%3Faction%3Dconnect%26service%3Dfacebook&scope=email,public_profile,publish_actions,user_friends' REDIRECT_URI='https://vimeo.com' FB_USER='facebookusername' FB_PASS='facebookpassword' ruby redirect.rb
```