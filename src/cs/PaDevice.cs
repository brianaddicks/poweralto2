using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
using System.Xml;
using System.Web;

namespace PowerAlto {

    public class HttpQueryReturnObject {
        public HttpStatusCode Statuscode;
        public string DetailedError;
        public XmlDocument Data;
        public string RawData;
        public int HttpStatusCode {
            get {
                return (int)this.Statuscode;
            }
        }
    }

    public class PaDevice {
        // can we rewrite the helper functions as methods in this class?

        private DateTime clock;
        private Stack<string> urlhistory = new Stack<string>();
        private string poweraltoversion = "2.0";

        public string Device { get; set; }
        public int Port { get; set; }
        public string ApiKey { get; set; }
        public string Protocol { get; set; }

        public string Name { get; set; }
        public string Model { get; set; }
        public string Serial { get; set; }

        public string OsVersion { get; set; }
        public string GpAgent { get; set; }
        public string AppVersion { get; set; }
        public string ThreatVersion { get; set; }
        public string WildFireVersion { get; set; }
        public string UrlVersion { get; set; }
        public XmlDocument LastXmlResult { get; set; }

        public string ApiUrl {
            get {
                if ( !string.IsNullOrEmpty( this.Protocol ) && !string.IsNullOrEmpty( this.Device ) && this.Port > 0 ) {
                    return this.Protocol + "://" + this.Device + ":" + this.Port + "/api/";
                } else {
                    return null;
                }
            }
        }

        public string AuthString {
            get {
                if ( !string.IsNullOrEmpty( this.ApiKey ) ) {
                    return "key=" + this.ApiKey;
                } else {
                    return null;
                }
            }
        }


        public string PowerAltoVersion {
            get {
                return this.poweraltoversion;
            }
        }

        public string Clock {
            get {
                return this.clock.ToString();
            }
            set {
                this.clock = DateTime.Parse( value );
            }
        }
        public DateTime ClockasDateTime {
            get {
                return this.clock;
            }
            set {
                this.clock = value;
            }
        }

        public string[] UrlHistory {
            get {
                return this.urlhistory.ToArray();
            }
        }

        public void FlushHistory() {
            this.urlhistory.Clear();
        }


        public string UrlBuilder(string QueryString) {

            string[] Pieces = new string[5];
            Pieces[0] = this.ApiUrl;
            Pieces[1] = "?";
            Pieces[2] = this.AuthString;
            Pieces[3] = "&";
            Pieces[4] = QueryString;

            //if (QueryType == "op") {
            //  Pieces[5] += ("&cmd=" + Query);
            //}

            string CompletedString = string.Join( "", Pieces );

            this.urlhistory.Push( CompletedString );
            return CompletedString;
        }

        private static bool OnValidateCertificate(object sender, X509Certificate certificate, X509Chain chain, SslPolicyErrors sslPolicyErrors) {
            return true;
        }

        public void OverrideValidation() {
            ServicePointManager.ServerCertificateValidationCallback = OnValidateCertificate;
            ServicePointManager.Expect100Continue = true;
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3;
        }

        //Holds the raw result of the last query
        //Would like to convert this to emulate UrlHistory, but I think we need to get the HttpQuery helper as a method to PaDevice first

        private Stack<string> rawqueryhistory = new Stack<string>();

        public string[] RawQueryHistory {
            get {
                return this.rawqueryhistory.ToArray();
            }
        }

        public void FlushRawQueryHistory() {
            this.rawqueryhistory.Clear();
        }

        /*
        private Stack<XmlDocument> queryhistory = new Stack<XmlDocument>();

        public string[] QueryHistory {
          get {
            return this.queryhistory.ToArray();
          }
        }
    
        public void FlushQueryHistory () {
          this.queryhistory.Clear();
        }
        */

        public HttpQueryReturnObject HttpQuery(string Url, bool AsXml = true) {
            // this works. there's some logic missing from the original powershell version of this
            // that may or may not be important (it was error handling of some flavor)
            // also, all requests should not be treated as XML for this to be more generic
            // (the powershell version had an "-asxml" flag to handle this)

            HttpWebResponse Response = null;
            HttpStatusCode StatusCode = new HttpStatusCode();

            try {
                HttpWebRequest Request = WebRequest.Create( Url ) as HttpWebRequest;

                //if (Response.ContentLength > 0) {

                try {
                    Response = Request.GetResponse() as HttpWebResponse;
                    StatusCode = Response.StatusCode;
                } catch ( WebException we ) {
                    StatusCode = ( (HttpWebResponse)we.Response ).StatusCode;
                }

                string DetailedError = Response.GetResponseHeader( "X-Detailed-Error" );
                // }

            } catch {
                throw new HttpException( "httperror" );
            }

            if ( Response.StatusCode.ToString() == "OK" ) {
                StreamReader Reader = new StreamReader( Response.GetResponseStream() );
                string Result = Reader.ReadToEnd();
                XmlDocument XResult = new XmlDocument();

                if ( AsXml ) {
                    XResult.LoadXml( Result );
                }

                Reader.Close();
                Response.Close();

                HttpQueryReturnObject ReturnObject = new HttpQueryReturnObject();
                ReturnObject.Statuscode = StatusCode;
                if ( AsXml ) { ReturnObject.Data = XResult; }
                ReturnObject.RawData = Result;

                this.rawqueryhistory.Push( Result );
                //this.queryhistory.Push(XResult);

                return ReturnObject;

            } else {

                throw new HttpException( "httperror" );
            }
        }
    }
}