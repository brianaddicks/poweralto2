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
		public XmlDocument LastXmlResult { get; set; }
		
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
		
		//Holds the raw result of the last query
		//Would like to convert this to emulate UrlHistory, but I think we need to get the HttpQuery helper as a method to PaDevice first
		
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
		public string QosType { get; set; }
		public string QosMarking { get; set; }
		
		public bool DisableSRI { get; set; }
		
		public string LastUncommitedChangeBy { get; set; }
		public string LastUncommitedChangeTimestamp { get; set; }	// This should be a datetime object
		
		public XElement Xml () {
                    
			// Create root, this will be stripped off, but is required to use the builtin xml functions
			XDocument XmlObject = new XDocument(
				//new XElement("entry")
			);
			
			XElement EntryXml = new XElement("entry");
			EntryXml.SetAttributeValue("name",this.Name);
			XmlObject.Add(EntryXml);
			//XmlObject.Element("entry").SetAttributeValue("name",this.Name);
			
			if (!(String.IsNullOrEmpty(this.Description))) {
				XElement ThisDescription = new XElement("description",this.Description);
				XmlObject.Element("entry").Add(ThisDescription);
			}
			
			// Set Tags
			if (this.Tags != null) {
				XElement ThisTags = new XElement("tag");
				  
				foreach (string ThisTag in this.Tags) {
					ThisTags.Add(
						new XElement("member",ThisTag)
					);
				}
				XmlObject.Element("entry").Add(ThisTags);
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
			
			XmlObject.Element("entry").Add(ThisSourceZones);
			
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
			
			XmlObject.Element("entry").Add(ThisSourceAddresses);
			
			// Set Source Negate
			if (this.SourceNegate) {
				XElement ThisSourceNegate = new XElement("negate-source","yes");
				XmlObject.Element("entry").Add(ThisSourceNegate);
			} else {
				XElement ThisSourceNegate = new XElement("negate-source","no");
				XmlObject.Element("entry").Add(ThisSourceNegate);
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
			
			XmlObject.Element("entry").Add(ThisSourceUsers);
			
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
			
			XmlObject.Element("entry").Add(ThisHipProfiles);
			
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
			
			XmlObject.Element("entry").Add(ThisDestinationZones);
			
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
			
			XmlObject.Element("entry").Add(ThisDestinationAddresses);
			
			// Set Destination Negate
			if (this.DestinationNegate) {
				XElement ThisDestinationNegate = new XElement("negate-destination","yes");
				XmlObject.Element("entry").Add(ThisDestinationNegate);
			} else {
				XElement ThisDestinationNegate = new XElement("negate-destination","no");
				XmlObject.Element("entry").Add(ThisDestinationNegate);
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
			
			XmlObject.Element("entry").Add(ThisApplications);
			
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
			
			XmlObject.Element("entry").Add(ThisUrlCategorys);
			
			// Set Action
			if (this.Allow) {
				XElement ThisAllow = new XElement("action","allow");
				XmlObject.Element("entry").Add(ThisAllow);
			} else {
				XElement ThisAllow = new XElement("action","deny");
				XmlObject.Element("entry").Add(ThisAllow);
			}
			
			// Set Profile Group
			if (!(String.IsNullOrEmpty(this.ProfileGroup))) {
				XElement ThisProfileGroup = new XElement("profile-setting");
				ThisProfileGroup.Add(
					new XElement("group",
						new XElement("member",this.ProfileGroup)   // NEED TO ACCOUNT FOR GROUP NONE
					)
				);
				XmlObject.Element("entry").Add(ThisProfileGroup);
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
				
				// Set Data Filtering Profile
				if (!(String.IsNullOrEmpty(this.DataFilteringProfile))) {
					XElement DataFilteringProfileXml = new XElement("data-filtering",
						new XElement("member",this.DataFilteringProfile)
					);
					ThisProfileSetting.Element("profiles").Add(DataFilteringProfileXml);
				}
				
				XmlObject.Element("entry").Add(ThisProfileSetting);
			}
			
			// Set Log At Start
			if (this.LogAtSessionStart) {
				XElement LogAtSessionStartXml = new XElement("log-start","yes");
				XmlObject.Element("entry").Add(LogAtSessionStartXml);
			} else {
				XElement LogAtSessionStartXml = new XElement("log-start","no");
				XmlObject.Element("entry").Add(LogAtSessionStartXml);
			}
			
			// Set Log At End
			if (this.LogAtSessionEnd) {
				XElement LogAtSessionEndXml = new XElement("log-end","yes");
				XmlObject.Element("entry").Add(LogAtSessionEndXml);
			} else {
				XElement LogAtSessionEndXml = new XElement("log-end","no");
				XmlObject.Element("entry").Add(LogAtSessionEndXml);
			}
			
			// Set Log Forwarding
			if (!(String.IsNullOrEmpty(this.LogForwarding))) {
				XElement LogForwardingXml = new XElement("log-setting",this.LogForwarding);
				XmlObject.Element("entry").Add(LogForwardingXml);
			}
			
			// Set Schedule
			if (!(String.IsNullOrEmpty(this.Schedule))) {
				XElement ScheduleXml = new XElement("schedule",this.Schedule);
				XmlObject.Element("entry").Add(ScheduleXml);
			}
			
			// Set Qos Marking
			if (!(String.IsNullOrEmpty(this.QosMarking)) && !(String.IsNullOrEmpty(this.QosType))) {
				XElement QosXml = new XElement("qos",
					new XElement("marking")
				);
				
				if (this.QosType == "dscp") {
					XElement QosMarkingXml = new XElement("ip-dscp",this.QosMarking);
					QosXml.Element("marking").Add(QosMarkingXml);
				} else {
					XElement QosMarkingXml = new XElement("ip-precedence",this.QosMarking);
					QosXml.Element("marking").Add(QosMarkingXml);
				}
				
				XmlObject.Element("entry").Add(QosXml);
			}
			
			// Set Disable Server Response Inspection
			if (this.DisableSRI) {
				XElement DisableSRIXml = new XElement("option",
					new XElement("disable-server-response-inspection","yes")
				);
				XmlObject.Element("entry").Add(DisableSRIXml);
			} else {
				XElement DisableSRIXml = new XElement("option",
					new XElement("disable-server-response-inspection","no")
				);
				XmlObject.Element("entry").Add(DisableSRIXml);
			}
			
			return XmlObject.Element("entry");
	    }

		public string PrintPrettyXml() {
			return Xml().ToString();
		}
		
		public string PrintPlainXml() {
			return Xml().ToString(SaveOptions.DisableFormatting);
		}
		public string PrintCliOutput () {
			List<string> CliList = new List<string>();
			
			// Start command and add name
			CliList.Add("set rulebase security rules ");
			CliList.Add(this.Name);
			
			// Description
			if (!(String.IsNullOrEmpty(this.Description))) {
				CliList.Add(" description ");
				CliList.Add(this.Description);
			}
			
			// Tags
			if (this.Tags != null) {
				CliList.Add(" tag [");
				foreach (string singleTag in this.Tags) {
					CliList.Add(" ");
					CliList.Add(singleTag);
				}
				CliList.Add(" ]");
			}
			
			// Source Zones
			if (this.SourceZone != null) {
				CliList.Add(" from [");
				foreach (string singleSourceZone in this.SourceZone) {
					CliList.Add(" ");
					CliList.Add(singleSourceZone);
				}
				CliList.Add(" ]");
			} else {
				CliList.Add(" from any");
			}
			
			// Source Addresses
			if (this.SourceAddress != null) {			
				CliList.Add(" source [");
				foreach (string singleSourceAddress in this.SourceAddress) {
					CliList.Add(" ");
					CliList.Add(singleSourceAddress);
				}
				CliList.Add(" ]");
			} else {
				CliList.Add(" source any");
			}
			
			// Source Negate
			if (this.SourceNegate) {
				CliList.Add(" negate-source yes");
			} else {
				CliList.Add(" negate-source no");
			}
			
			// Source User
			if (this.SourceUser != null) {
				CliList.Add(" source-user [");
				foreach (string singleSourceUser in this.SourceUser) {
					CliList.Add(" ");
					CliList.Add(singleSourceUser);
				}
				CliList.Add(" ]");
			} else {
				CliList.Add(" source-user any");
			}
			
			// Hip Profiles
			if (this.HipProfile != null) {
				CliList.Add(" hip-profiles [");
				foreach (string singleHipProfile in this.HipProfile) {
					CliList.Add(" ");
					CliList.Add(singleHipProfile);
				}
				CliList.Add(" ]");
			} else {
				CliList.Add(" hip-profiles any");
			}
			
			// Destination Zones
			if (this.DestinationZone != null) {
				CliList.Add(" to [");
				foreach (string singleDestinationZone in this.DestinationZone) {
					CliList.Add(" ");
					CliList.Add(singleDestinationZone);
				}
				CliList.Add(" ]");
			} else {
				CliList.Add(" to any");
			}
			
			// Destination Addresses
			if (this.DestinationAddress != null) {
				CliList.Add(" destination [");
				foreach (string singleDestinationAddress in this.DestinationAddress) {
					CliList.Add(" ");
					CliList.Add(singleDestinationAddress);
				}
				CliList.Add(" ]");
			} else {
				CliList.Add(" destination any");
			}
			
			//Destination Negate
			if (this.DestinationNegate) {
				CliList.Add(" negate-destination yes");
			} else {
				CliList.Add(" negate-destination no");
			}
			
			
			
			
			string CliString = string.Join("",CliList.ToArray());
			return CliString;
		}
	}
}

/*
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
		public string QosType { get; set; }
		public string QosMarking { get; set; }
		
		public bool DisableSRI { get; set; }
*/








