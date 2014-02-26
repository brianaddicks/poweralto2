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
		public List<string> HipProfile { get; set; }
		
		public List<string> DestinationZone { get; set; }
		public List<string> DestinationAddress { get; set; }
		public bool DestinationNegate { get; set; }
		
		public List<string> Application { get; set; }
		
		public List<string> Service { get; set; }
		public List<string> UrlCategory { get; set; }
		
		public bool Allow { get; set; } //true = allow, false = deny
		
		//private bool IsGroup = false;
		private bool ProfileExists = false;
		
		private string profilegroup;
		public string ProfileGroup {
			get {
				return this.profilegroup;
			}
			set {
				if (this.ProfileExists) {
					throw new System.ArgumentException("Profile Group cannot be set with individual profiles");
				} else {
					this.profilegroup = value;
				}
			}
		}
		
		
		private string antivirusprofile;
		public string AntivirusProfile {
			get {
				return this.antivirusprofile;
			}
			set {
				this.antivirusprofile = value;
				this.ProfileExists = true;
			}
		}
		
		//public string VulnerabilityProfile { get; set; }
		private string vulnerabilityprofile;
		public string VulnerabilityProfile {
			get {
				return this.vulnerabilityprofile;
			}
			set {
				this.vulnerabilityprofile = value;
				this.ProfileExists = true;
			}
		}
		
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
			
			// Set Source Negate
			if (this.SourceNegate) {
				XElement ThisSourceNegate = new XElement("negate-source","yes");
				XmlObject.Element("fakeroot").Add(ThisSourceNegate);
			} else {
				XElement ThisSourceNegate = new XElement("negate-source","no");
				XmlObject.Element("fakeroot").Add(ThisSourceNegate);
			}
			
			// Set Source User
			XElement ThisSourceUsers = new XElement("source-user");
			
			if (this.SourceUser != null) {			
				foreach (string ThisSourceUser in this.SourceUser) {
					ThisSourceUsers.Add(
						new XElement("member",ThisSourceUser)
					);
				}
			} else {
				ThisSourceUsers.Add(
					new XElement("member","any")
				);
			}
			
			XmlObject.Element("fakeroot").Add(ThisSourceUsers);
			
			// Set Hip Profile
			XElement ThisHipProfiles = new XElement("hip-profiles");
			
			if (this.HipProfile != null) {			
				foreach (string ThisHipProfile in this.HipProfile) {
					ThisHipProfiles.Add(
						new XElement("member",ThisHipProfile)
					);
				}
			} else {
				ThisHipProfiles.Add(
					new XElement("member","any")
				);
			}
			
			XmlObject.Element("fakeroot").Add(ThisHipProfiles);
			
			// Set Destination Zones
			XElement ThisDestinationZones = new XElement("to");
			
			if (this.DestinationZone != null) {			
				foreach (string ThisDestinationZone in this.DestinationZone) {
					ThisDestinationZones.Add(
						new XElement("member",ThisDestinationZone)
					);
				}
			} else {
				ThisDestinationZones.Add(
					new XElement("member","any")
				);
			}
			
			XmlObject.Element("fakeroot").Add(ThisDestinationZones);
			
			// Set Destination Addresses
			XElement ThisDestinationAddresses = new XElement("destination");
			
			if (this.DestinationAddress != null) {			
				foreach (string ThisDestinationAddress in this.DestinationAddress) {
					ThisDestinationAddresses.Add(
						new XElement("member",ThisDestinationAddress)
					);
				}
			} else {
				ThisDestinationAddresses.Add(
					new XElement("member","any")
				);
			}
			
			XmlObject.Element("fakeroot").Add(ThisDestinationAddresses);
			
			// Set Destination Negate
			if (this.DestinationNegate) {
				XElement ThisDestinationNegate = new XElement("negate-destination","yes");
				XmlObject.Element("fakeroot").Add(ThisDestinationNegate);
			} else {
				XElement ThisDestinationNegate = new XElement("negate-destination","no");
				XmlObject.Element("fakeroot").Add(ThisDestinationNegate);
			}
			
			// Set Application
			XElement ThisApplications = new XElement("application");
			
			if (this.Application != null) {			
				foreach (string ThisApplication in this.Application) {
					ThisApplications.Add(
						new XElement("member",ThisApplication)
					);
				}
			} else {
				ThisApplications.Add(
					new XElement("member","any")
				);
			}
			
			XmlObject.Element("fakeroot").Add(ThisApplications);
			
			// Set Url Category
			XElement ThisUrlCategorys = new XElement("category");
			
			if (this.UrlCategory != null) {			
				foreach (string ThisUrlCategory in this.UrlCategory) {
					ThisUrlCategorys.Add(
						new XElement("member",ThisUrlCategory)
					);
				}
			} else {
				ThisUrlCategorys.Add(
					new XElement("member","any")
				);
			}
			
			XmlObject.Element("fakeroot").Add(ThisUrlCategorys);
			
			// Set Action
			if (this.Allow) {
				XElement ThisAllow = new XElement("action","allow");
				XmlObject.Element("fakeroot").Add(ThisAllow);
			} else {
				XElement ThisAllow = new XElement("action","deny");
				XmlObject.Element("fakeroot").Add(ThisAllow);
			}
			
			// Set Profile Group
			if (!(String.IsNullOrEmpty(this.ProfileGroup))) {
				XElement ThisProfileGroup = new XElement("profile-setting");
				ThisProfileGroup.Add(
					new XElement("group",
						new XElement("member",this.ProfileGroup)
					)
				);
				XmlObject.Element("fakeroot").Add(ThisProfileGroup);
			}
			
			// Set Individual Profiles
			if (this.ProfileExists) {
				
				XElement ThisProfileSetting = new XElement("profile-setting",
					new XElement("profiles")
				);
				
				// Set Antivirus Profile
				if (!(String.IsNullOrEmpty(this.AntivirusProfile))) {
					XElement AntivirusProfileXml = new XElement("virus",
						new XElement("member",this.AntivirusProfile)
					);
					ThisProfileSetting.Element("profiles").Add(AntivirusProfileXml);
				}
				
				// Set Vulnerability Profile
				if (!(String.IsNullOrEmpty(this.VulnerabilityProfile))) {
					XElement VulnerabilityProfileXml = new XElement("vulnerability",
						new XElement("member",this.VulnerabilityProfile)
					);
					ThisProfileSetting.Element("profiles").Add(VulnerabilityProfileXml);
				}
				
				// Set AntiSpyware Profile
				if (!(String.IsNullOrEmpty(this.AntiSpywareProfile))) {
					XElement AntiSpywareProfileXml = new XElement("spyware",
						new XElement("member",this.AntiSpywareProfile)
					);
					ThisProfileSetting.Element("profiles").Add(AntiSpywareProfileXml);
				}
				
				// Set Url Filtering Profile
				if (!(String.IsNullOrEmpty(this.UrlFilteringProfile))) {
					XElement UrlFilteringProfileXml = new XElement("url-filtering",
						new XElement("member",this.UrlFilteringProfile)
					);
					ThisProfileSetting.Element("profiles").Add(UrlFilteringProfileXml);
				}
				
				// Set File Blocking Profile
				if (!(String.IsNullOrEmpty(this.FileBlockingProfile))) {
					XElement FileBlockingProfileXml = new XElement("file-blocking",
						new XElement("member",this.FileBlockingProfile)
					);
					ThisProfileSetting.Element("profiles").Add(FileBlockingProfileXml);
				}
				
				XmlObject.Element("fakeroot").Add(ThisProfileSetting);
			}
			
			// return beautiful, well-formatted xml
			return XmlObject.Element("fakeroot").ToString();
	    }
	}
}

/*
public string Name { get; set; }

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