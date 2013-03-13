using System;
using System.IO;
using System.Linq;
using System.Net;
using System.Runtime.Serialization.Json;
using System.Text;
using System.Web;
using System.Web.Http;
using System.Web.Mvc;

namespace MyEdTechApp.Controllers
{
    public class OauthController : ApiController
    {
        public class AcsResponse
        {
            public string access_token_base_64 { get; set; }
            public string access_token { get; set; }
        }

        public AcsResponse Call(string url, NameValueCollection nvc)
        {
            WebRequest req = WebRequest.Create(url);
            req.Method = "POST";
            
            StringBuilder parameters = new StringBuilder();
            bool first = true;
            foreach (string key in nvc.Keys)
            {
                if (first)
                    first = false;
                else
                    parameters.Append("&");

                var val = HttpUtility.UrlEncode(nvc[key]);
                parameters.Append(key).Append("=").Append(val);
            }
            byte[] bytes = Encoding.ASCII.GetBytes(parameters.ToString());
            req.ContentLength = bytes.Length;
            Stream rs = req.GetRequestStream();
            rs.Write(bytes, 0, bytes.Length);
            rs.Close();

            WebResponse resp = req.GetResponse();
            var responseStream = resp.GetResponseStream();
            var ser = new DataContractJsonSerializer(typeof(AcsResponse));
            return (AcsResponse)ser.ReadObject(responseStream);
        }

        public AcsResponse Get(string id, string code)
        {
            code = HttpUtility.UrlDecode(code);
            NameValueCollection ps = new NameValueCollection {
                    {"client_id", "MyEdTechApp"},
                    {"client_secret", "Your API Key from the Chalkable Developer Portal"},
                    {"scope", "https://chalkable.com"},
                    {"grant_type", "authorization_code"},
                    {"redirect_uri", "http://MyEdTechApp.com"},
                    {"code", code},
            };
            var response = Call("https://chalkable-access-control.accesscontrol.windows.net/v2/OAuth2-13", ps);
            response.access_token_base_64 = Convert.ToBase64String(Encoding.UTF8.GetBytes(response.access_token));
            return response;
        }

    }
}
