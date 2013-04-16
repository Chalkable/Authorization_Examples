from flask import Flask
from flask import request
import requests

app = Flask(__name__)

APP_CONFIG = {
    'url': "http://localhost:9494/",
    #"api_key": "73fae808f45540a8973e31d9946182541d5d0773d2084d2baaf980464877bdb4ee5749396f4f43eab48147682b58bf7eb8e44cb30aff43308446a628dbe910d0"
    "api_key": "e662aad75619466ea0ac2614bb23a60af86cb8a8bbd943c39b3d52353b24d17ef24c3809b98c4969875532e71a0f70fbb99810d218c04d0a8d1eee75d80720c8"
}

def get_current_user(access_token):
    args = {
        'authorization': 'Bearer:' + access_token
    }
    try:
        r = requests.get("https://chalkable.com/User/Me.json", headers=args)
        parsed = r.json()['data']
        parsed['is_teacher'] = parsed['rolename'] == 'Teacher'
        return parsed
    except Exception, ex:
        print "Something horribly wrong happened..."

def render_user(me):
    html = "<html style=background:white;font-size:24px><div>%(displayname)s</div><div>%(email)s</div></html>" %  me
    html += "<br/>DICT BELOW <br/>"
    for k,v in me.items():
        html += "key: %s  value: %s<br/>" % (k,v)
    return html

@app.route("/")
def chalkable_api():
    args = {
        "client_id": APP_CONFIG['url'],
        "client_secret": APP_CONFIG['api_key'],
        "scope": "https://chalkable.com",
        "redirect_uri": APP_CONFIG['url'],
        "grant_type": "authorization_code",
        "code": request.args.get("code", '')
    }
    r = requests.post("https://chalkable-access-control.accesscontrol.windows.net/v2/OAuth2-13", data=args)
    result = r.json()
    access_token = result['access_token']
    me = get_current_user(access_token)
    return render_user(me)

if __name__ == "__main__":
    app.run(None, 9494)