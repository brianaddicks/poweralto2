using System;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Web;
using System.Xml;
using System.Xml.Linq;

namespace PowerAlto {
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
		
		public string ApiUrl {
			get {
				if (!string.IsNullOrEmpty(this.Protocol) && !string.IsNullOrEmpty(this.Device) && this.Port > 0) {
					return this.Protocol + "://" + this.Device + ":" + this.Port + "/api/";
				} else {
					return null;
				}
			}
		}
		
		public string AuthString {
			get {
				if (!string.IsNullOrEmpty(this.ApiKey)) {
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
				this.clock = DateTime.Parse(value);
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
		
		public void FlushHistory () {
			this.urlhistory.Clear();
		}
		
		
		public string UrlBuilder (string QueryType, string Query) {
			
			string[] Pieces = new string[6];
			Pieces[0] = this.ApiUrl;
			Pieces[1] = "?type=";
			Pieces[2] = QueryType;
			Pieces[3] = "&";
			Pieces[4] = this.AuthString;
			
			if (QueryType == "op") {
				Pieces[5] += ("&cmd=" + Query);
			}
			
			string CompletedString = string.Join ("",Pieces);
			
			this.urlhistory.Push(CompletedString);
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
	}
}