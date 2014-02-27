using System;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Management.Automation;
using System.Collections.Specialized;
using System.Web;
using System.Xml;
using System.Xml.Linq;
using System.IO;

namespace PowerAlto {
    [Cmdlet( VerbsCommon.Get, "PaFirewall" )]
    public class Get_PaFirewall : System.Management.Automation.Cmdlet {
        [Parameter( Mandatory = true, Position = 0 )]
        public string Device;

        [Parameter( ParameterSetName = "keyonly", Mandatory = true, Position = 1 )]
        public string ApiKey;

        [Parameter( ParameterSetName = "credential", Mandatory = true, Position = 1 )]
        public PSCredential PaCred;

        [Parameter( Mandatory = false, Position = 2 )]
        public int? Port { get; set; }

        [Parameter( Mandatory = false )]
        public SwitchParameter HttpOnly {
            get { return httpOnly; }
            set { httpOnly = value; }
        }
        private bool httpOnly;

        [Parameter( Mandatory = false )]
        public bool Quiet;

        private string protocol;
        private PaFirewall FirewallObject = new PaFirewall();

        // BEGIN
        protected override void BeginProcessing() {
            if ( httpOnly ) {
                this.protocol = "http";
                if ( !this.Port.HasValue ) { this.Port = 80; }
            } else {
                this.protocol = "https";
                if ( !this.Port.HasValue ) { this.Port = 443; }
            }

            FirewallObject.Device = this.Device;
            FirewallObject.Port = this.Port.Value;
            FirewallObject.Protocol = this.protocol;

            if ( this.ApiKey != null ) {
                FirewallObject.ApiKey = this.ApiKey;
            } else {
                //use the cred to get a key and assign it to FirewallObject
            }

            FirewallObject.OverrideValidation();

        }

        // PROCESS
        private string QueryString {
            get {
                NameValueCollection queryString = HttpUtility.ParseQueryString( string.Empty );

                queryString["type"] = "op";
                queryString["cmd"] = "<show><system><info></info></system></show>";

                return queryString.ToString();
            }

        }

        protected override void EndProcessing() {
            string url = FirewallObject.UrlBuilder( QueryString );

            WriteObject( FirewallObject, true );
        }
    }

    public class HttpQueryReturnObject {
        public string Statuscode;
        public string DetailedError;
        public XmlDocument Data;
    }

    public class PaFirewall {
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

            string CompletedString = string.Join( "", Pieces );

            this.urlhistory.Push( CompletedString );
            return CompletedString;
        }

        // ------------------------ Helper HTTP Query ------------------------ //

        public HttpQueryReturnObject HttpQuery(string Url) {
            HttpWebResponse Response = null;
            HttpStatusCode StatusCode = new HttpStatusCode();
            try {
                HttpWebRequest Request = WebRequest.Create( Url ) as HttpWebRequest;
                Response = Request.GetResponse() as HttpWebResponse;
                if ( Response.ContentLength > 0 ) {
                    StatusCode = Response.StatusCode;
                    string DetailedError = Response.GetResponseHeader( "X-Detailed-Error" );
                }
            } catch {
                /*
                    $ErrorMessage = $Error[0].Exception.ErrorRecord.Exception.Message
		            $Matched = ($ErrorMessage -match '[0-9]{3}')
		            if ($Matched) {
			            throw ('HTTP status code was {0} ({1})' -f $HttpStatusCode, $matches[0])
		            }
		            else {
			            throw $ErrorMessage
		            }
                */
                throw new HttpException( "httperror" );
            }

            if ( Response.StatusCode.ToString() == "OK" ) {
                StreamReader Reader = new StreamReader( Response.GetResponseStream() );
                string Result = Reader.ReadToEnd();
                XmlDocument XResult = new XmlDocument();
                XResult.LoadXml( Result );

                Reader.Close();
                Response.Close();

                HttpQueryReturnObject ReturnObject = new HttpQueryReturnObject();
                ReturnObject.Statuscode = StatusCode.ToString();
                ReturnObject.Data = XResult;

                return ReturnObject;
            } else {
                throw new HttpException( "httperror" );
            }
        }

        // ------------------------ Helper HTTP Query ------------------------ //

        private static bool OnValidateCertificate(object sender, X509Certificate certificate, X509Chain chain, SslPolicyErrors sslPolicyErrors) {
            return true;
        }

        public void OverrideValidation() {
            ServicePointManager.ServerCertificateValidationCallback = OnValidateCertificate;
            ServicePointManager.Expect100Continue = true;
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Ssl3;
        }
    }
}
