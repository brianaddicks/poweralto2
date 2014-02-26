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
		
		
		public string UrlBuilder (string QueryString) {
			
			string[] Pieces = new string[5];
			Pieces[0] = this.ApiUrl;
			Pieces[1] = "?";
			Pieces[2] = this.AuthString;
			Pieces[3] = "&";
			Pieces[4] = QueryString;
			
			//if (QueryType == "op") {
			//	Pieces[5] += ("&cmd=" + Query);
			//}
			
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
	
	public class SecurityRule {
		public string Name { get; set; }
		public string Description { get; set; }
		public List<string> Tags { get; set; }
		
		public List<string> SourceZone { get; set; }
		public List<string> SourceAddress { get; set; }
		public bool SourceNegate { get; set; }
		
		public List<string> SourceUser { get; set; }
		public List<string> HipProfiles { get; set; }
		
		public List<string> DestinationZone { get; set; }
		public List<string> DestinationAddress { get; set; }
		public bool DestinationNegate { get; set; }
		
		public List<string> Applications { get; set; }
		
		public List<string> Service { get; set; }
		public List<string> UrlCategory { get; set; }
		
		public bool Allow { get; set; } //true = allow, false = deny
		
		public string ProfileGroup { get; set; }
		
		public string AntivirusProfile { get; set; }
		public string VulnerabilityProfile { get; set; }
		public string AntiSpywareProfile { get; set; }
		public string UrlFilteringProfile { get; set; }
		public string FileBlockingProfile { get; set; }
		public string DataFilteringProfile { get; set; }
		
		public bool LogAtSessionStart { get; set; }
		public bool LogAtSessionEnd { get; set; }
		public string LogForwarding { get; set; }
		
		public string Schedule { get; set; }
		public string QoSMarking { get; set; }
		
		public bool DisableSRI { get; set; }
		
		public string PrintOutput () {
                    
			// Create root, this will be stripped off, but is required to use the builtin xml functions
			XDocument XmlObject = new XDocument(
				new XElement("fakeroot")
			);
			
			if (!(String.IsNullOrEmpty(this.Description))) {
				XElement ThisDescription = new XElement("description",this.Description);
				XmlObject.Element("fakeroot").Add(ThisDescription);
			}
			
			// Set Tags
			if (this.Tags != null) {
				XElement ThisTags = new XElement("tag");
				  
				foreach (string ThisTag in this.Tags) {
					ThisTags.Add(
						new XElement("member",ThisTag)
					);
				}
				XmlObject.Element("fakeroot").Add(ThisTags);
			}
			
			// Set Source Zones
			
			XElement ThisSourceZones = new XElement("from");
			
			if (this.SourceZone != null) {			
				foreach (string ThisSourceZone in this.SourceZone) {
					ThisSourceZones.Add(
						new XElement("member",ThisSourceZone)
					);
				}
			} else {
				ThisSourceZones.Add(
					new XElement("member","any")
				);
			}
			
			XmlObject.Element("fakeroot").Add(ThisSourceZones);
			
			// Set Source Addresses
			
			XElement ThisSourceAddresses = new XElement("source");
			
			if (this.SourceAddress != null) {			
				foreach (string ThisSourceAddress in this.SourceAddress) {
					ThisSourceAddresses.Add(
						new XElement("member",ThisSourceAddress)
					);
				}
			} else {
				ThisSourceAddresses.Add(
					new XElement("member","any")
				);
			}
			
			XmlObject.Element("fakeroot").Add(ThisSourceAddresses);
			
			
			// return beautiful, well-formatted xml
			return XmlObject.Element("fakeroot").ToString();
	    }
	}
}

/*
public string Name { get; set; }
		public List<string> SourceZone { get; set; }
		public List<string> SourceAddress { get; set; }
		public bool SourceNegate { get; set; }
		
		public List<string> SourceUser { get; set; }
		public List<string> HipProfiles { get; set; }
		
		public List<string> DestinationZone { get; set; }
		public List<string> DestinationAddress { get; set; }
		public bool DestinationNegate { get; set; }
		
		public List<string> Applications { get; set; }
		
		public List<string> Service { get; set; }
		public List<string> UrlCategory { get; set; }
		
		public bool Allow { get; set; } //true = allow, false = deny
		
		public string ProfileGroup { get; set; }
		
		public string AntivirusProfile { get; set; }
		public string VulnerabilityProfile { get; set; }
		public string AntiSpywareProfile { get; set; }
		public string UrlFilteringProfile { get; set; }
		publsic string FileBlockingProfile { get; set; }
		public string DataFilteringProfile { get; set; }
		
		public bool LogAtSessionStart { get; set; }
		public bool LogAtSessionEnd { get; set; }
		public string LogForwarding { get; set; }
		
		public string Schedule { get; set; }
		public string QoSMarking { get; set; }
		
		public bool DisableSRI { get; set; }
*/